-- ============================================
-- FUNCIONES Y VISTAS
-- ============================================

ALTER TABLE vivienda ADD COLUMN ambito TEXT CHECK (ambito IN ('rural', 'urbano'));
UPDATE vivienda SET ambito = 'urbano' WHERE idVivienda IN (1, 2, 4);
UPDATE vivienda SET ambito = 'rural' WHERE idVivienda IN (3, 5);


-- ============================================
-- FUNCIÓN PARA CALCULAR AÑOS DE EDUCACIÓN
-- ============================================

CREATE OR REPLACE FUNCTION anios_educacion(ultimo_grado TEXT)
RETURNS INTEGER AS $$
BEGIN
    RETURN CASE
        WHEN ultimo_grado ILIKE '%preescolar%' OR ultimo_grado ILIKE '%kinder%' THEN 0
        WHEN ultimo_grado ILIKE '%primaria%' THEN 6
        WHEN ultimo_grado ILIKE '%secundaria%' THEN 9
        WHEN ultimo_grado ILIKE '%preparatoria%' OR ultimo_grado ILIKE '%bachillerato%' THEN 12
        WHEN ultimo_grado ILIKE '%licenciatura%' OR ultimo_grado ILIKE '%universidad%' THEN 16
        WHEN ultimo_grado ILIKE '%maestría%' THEN 18
        WHEN ultimo_grado ILIKE '%doctorado%' THEN 20
        ELSE 0
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- FUNCIÓN PARA AXTUALIZAR FECHA DE MODIFICACIÓN EN LA TABLA ENCUESTA
-- ============================================

CREATE OR REPLACE FUNCTION public.actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fechaModificacion = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_encuesta_modificacion
    BEFORE UPDATE ON public.encuesta
    FOR EACH ROW
    EXECUTE FUNCTION public.actualizar_fecha_modificacion();

-- ============================================
-- VISTA DE CÁLCULO DE POBREZA
-- ============================================

CREATE OR REPLACE VIEW vista_pobreza_hogar AS
WITH 
-- 1. Número de integrantes por hogar
integrantes_por_hogar AS (
    SELECT idHogar, COUNT(*) AS num_personas
    FROM integrante
    GROUP BY idHogar
),

-- 2. Ingreso total del hogar (salarios + programas sociales)
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
        -- Calidad de vivienda (materiales y hacinamiento)
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

-- 4. Clasificación final (usando ámbito desde vivienda.ambito)
SELECT 
    h.idHogar,
    h.folio,
    v.ambito,
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
    CASE 
        -- Pobreza extrema
        WHEN (ih.ingreso_total / NULLIF(ih.num_personas, 0)) < 
             CASE WHEN v.ambito = 'rural' THEN 1854 ELSE 2467 END
             AND (c.rezago_educativo + c.carencia_salud + c.carencia_seguridad + 
                  c.carencia_vivienda + c.carencia_servicios + c.carencia_alimentacion) >= 3
        THEN 'Pobreza extrema'
        -- Pobreza moderada
        WHEN (ih.ingreso_total / NULLIF(ih.num_personas, 0)) < 
             CASE WHEN v.ambito = 'rural' THEN 3451 ELSE 4818 END
             AND (c.rezago_educativo + c.carencia_salud + c.carencia_seguridad + 
                  c.carencia_vivienda + c.carencia_servicios + c.carencia_alimentacion) >= 1
        THEN 'Pobreza moderada'
        -- Vulnerable por carencias
        WHEN (ih.ingreso_total / NULLIF(ih.num_personas, 0)) >= 
             CASE WHEN v.ambito = 'rural' THEN 3451 ELSE 4818 END
             AND (c.rezago_educativo + c.carencia_salud + c.carencia_seguridad + 
                  c.carencia_vivienda + c.carencia_servicios + c.carencia_alimentacion) >= 1
        THEN 'Vulnerable por carencias'
        -- Vulnerable por ingresos
        WHEN (ih.ingreso_total / NULLIF(ih.num_personas, 0)) < 
             CASE WHEN v.ambito = 'rural' THEN 3451 ELSE 4818 END
             AND (c.rezago_educativo + c.carencia_salud + c.carencia_seguridad + 
                  c.carencia_vivienda + c.carencia_servicios + c.carencia_alimentacion) = 0
        THEN 'Vulnerable por ingresos'
        -- No pobre y no vulnerable
        ELSE 'No pobre y no vulnerable'
    END AS clasificacion_pobreza
FROM hogar h
JOIN vivienda v ON h.idVivienda = v.idVivienda
JOIN ingreso_hogar ih ON h.idHogar = ih.idHogar
JOIN carencias c ON h.idHogar = c.idHogar;