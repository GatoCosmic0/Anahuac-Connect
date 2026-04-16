-- ============================================
-- CÁLCULO DE POBREZA
-- ============================================

-- ============================================
-- 1. FUNCIÓN PARA CALCULAR AÑOS DE EDUCACIÓN
-- ============================================
CREATE OR REPLACE FUNCTION anios_educacion(ultimo_grado TEXT)
RETURNS INTEGER AS $$
BEGIN
    RETURN CASE
        WHEN ultimo_grado ILIKE '%preescolar%' OR ultimo_grado ILIKE '%kinder%' THEN 0
        WHEN ultimo_grado ILIKE '%primaria%' THEN 
            -- Extraer número si existe
            CAST(COALESCE(NULLIF(regexp_replace(ultimo_grado, '[^0-9]', '', 'g'), ''), '6') AS INTEGER)
        WHEN ultimo_grado ILIKE '%secundaria%' THEN 
            COALESCE(NULLIF(regexp_replace(ultimo_grado, '[^0-9]', '', 'g'), ''), '3')::INTEGER + 6
        WHEN ultimo_grado ILIKE '%preparatoria%' OR ultimo_grado ILIKE '%bachillerato%' THEN 
            COALESCE(NULLIF(regexp_replace(ultimo_grado, '[^0-9]', '', 'g'), ''), '3')::INTEGER + 9
        WHEN ultimo_grado ILIKE '%licenciatura%' OR ultimo_grado ILIKE '%universidad%' THEN 
            COALESCE(NULLIF(regexp_replace(ultimo_grado, '[^0-9]', '', 'g'), ''), '4')::INTEGER + 12
        WHEN ultimo_grado ILIKE '%maestría%' THEN 16
        WHEN ultimo_grado ILIKE '%doctorado%' THEN 18
        ELSE 0
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- 2. VISTA DE CÁLCULO DE POBREZA
-- ============================================
CREATE OR REPLACE VIEW vista_pobreza_hogar AS
WITH 
-- 1. Número de integrantes por hogar
integrantes_por_hogar AS (
    SELECT idHogar, COUNT(*) AS num_personas
    FROM integrante
    GROUP BY idHogar
),
-- 2. Ingreso total del hogar (salarios y programas sociales)
ingreso_hogar AS (
    SELECT 
        h.idHogar,
        COALESCE(SUM(o.salarioMensual), 0) + 
        COALESCE(SUM(ps.montoMensual), 0) AS ingreso_total,
        iph.num_personas
    FROM hogar h
    LEFT JOIN integrante i ON h.idHogar = i.idHogar
    LEFT JOIN ocupacion o ON i.idIntegrante = o.idIntegrante
    LEFT JOIN programasocial ps ON i.idIntegrante = ps.idIntegrante
    LEFT JOIN integrantes_por_hogar iph ON h.idHogar = iph.idHogar
    GROUP BY h.idHogar, iph.num_personas
),
-- 3. Carencias por hogar
carencias AS (
    SELECT 
        h.idHogar,
        iph.num_personas,
        -- Rezago educativo
        MAX(CASE 
            WHEN (EXTRACT(YEAR FROM age(CURRENT_DATE, i.fechaNacimiento)) BETWEEN 3 AND 15)
                 AND (e.asisteEscuela = false OR anios_educacion(e.ultimoGrado) < 9)
            THEN 1
            WHEN EXTRACT(YEAR FROM age(CURRENT_DATE, i.fechaNacimiento)) > 44
                 AND anios_educacion(e.ultimoGrado) < 6
            THEN 1
            WHEN EXTRACT(YEAR FROM age(CURRENT_DATE, i.fechaNacimiento)) <= 44
                 AND anios_educacion(e.ultimoGrado) < 9
            THEN 1
            ELSE 0 
        END) AS rezago_educativo,
        -- Salud
        MAX(CASE WHEN s.tieneServicioMedico = false THEN 1 ELSE 0 END) AS carencia_salud,
        -- Seguridad social (solo Afore e incapacidad)
        MAX(CASE WHEN ss.tieneAfore = false AND ss.recibeIncapacidad = false THEN 1 ELSE 0 END) AS carencia_seguridad,
        -- Calidad de vivienda (materiales y hacinamiento usando num_personas calculado)
        MAX(CASE 
            WHEN cv.materialPrincipal IN ('Lámina metálica', 'Lámina de cartón', 'Material de desecho', 'Palma / Bambú', 'Barro', 'Adobe')
              OR cv.materialTecho IN ('Lámina metálica', 'Lámina de cartón', 'Material de desecho', 'Palma / Paja')
              OR (iph.num_personas > 0 AND sv.numHabitaciones > 0 
                  AND (iph.num_personas::float / sv.numHabitaciones) > 2.5)
            THEN 1 ELSE 0 
        END) AS carencia_vivienda,
        -- Servicios básicos
        MAX(CASE 
            WHEN sv.aguaObtencion NOT IN ('Entubada dentro de la vivienda', 'Entubada en el terreno')
              OR sv.tieneEnergia = false
              OR sv.tieneDrenaje = false
            THEN 1 ELSE 0 
        END) AS carencia_servicios,
        -- Alimentación
        MAX(CASE 
            WHEN a.preocupacionComida = true 
              OR a.menorDejoComer = true 
              OR a.adultoDejoComer = true
              OR a.menorSinComida = true
              OR a.adultoSinComida = true
            THEN 1 ELSE 0 
        END) AS carencia_alimentacion
    FROM hogar h
    LEFT JOIN integrantes_por_hogar iph ON h.idHogar = iph.idHogar
    LEFT JOIN vivienda v ON h.idVivienda = v.idVivienda
    LEFT JOIN integrante i ON h.idHogar = i.idHogar
    LEFT JOIN estudios e ON i.idIntegrante = e.idIntegrante
    LEFT JOIN salud s ON i.idIntegrante = s.idIntegrante
    LEFT JOIN seguridadsocial ss ON i.idIntegrante = ss.idIntegrante
    LEFT JOIN caracteristicasvivienda cv ON v.idVivienda = cv.idVivienda
    LEFT JOIN serviciosvivienda sv ON v.idVivienda = sv.idVivienda
    LEFT JOIN alimentacion a ON h.idHogar = a.idHogar
    GROUP BY h.idHogar, iph.num_personas
)
-- 4. Clasificación final  !!!!!!!! (falta ámbito) !!!!!!!!!!!
SELECT 
    h.idHogar,
    h.folio,
    NULL AS ambito,  -- se asigna desde app ??? 
    ROUND(ih.ingreso_total / NULLIF(ih.num_personas, 0), 2) AS ingreso_per_capita,
    c.num_personas,
    (c.rezago_educativo + c.carencia_salud + c.carencia_seguridad + 
     c.carencia_vivienda + c.carencia_servicios + c.carencia_alimentacion) AS total_carencias,
    c.rezago_educativo,
    c.carencia_salud,
    c.carencia_seguridad,
    c.carencia_vivienda,
    c.carencia_servicios,
    c.carencia_alimentacion,
    'Pendiente (requiere ámbito)' AS clasificacion_pobreza
FROM hogar h
JOIN ingreso_hogar ih ON h.idHogar = ih.idHogar
JOIN carencias c ON h.idHogar = c.idHogar;

SELECT folio, num_personas, ingreso_per_capita, total_carencias 
FROM vista_pobreza_hogar;