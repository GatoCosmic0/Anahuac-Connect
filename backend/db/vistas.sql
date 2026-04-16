-- ============================================
-- CÁLCULO DE POBREZA EN SQLITE
-- ============================================


-- Vista principal de pobreza
CREATE VIEW IF NOT EXISTS vista_pobreza_hogar AS
WITH 
-- Convertir ultimoGrado a años estimados 
anios_educacion_cte AS (
    SELECT 
        idIntegrante,
        ultimoGrado,
        CASE 
            WHEN ultimoGrado LIKE '%preescolar%' OR ultimoGrado LIKE '%kinder%' THEN 0
            WHEN ultimoGrado LIKE '%primaria%' THEN 6
            WHEN ultimoGrado LIKE '%secundaria%' THEN 9
            WHEN ultimoGrado LIKE '%preparatoria%' OR ultimoGrado LIKE '%bachillerato%' THEN 12
            WHEN ultimoGrado LIKE '%licenciatura%' OR ultimoGrado LIKE '%universidad%' THEN 16
            WHEN ultimoGrado LIKE '%maestría%' THEN 18
            WHEN ultimoGrado LIKE '%doctorado%' THEN 20
            ELSE 0
        END AS anios_educacion
    FROM estudios
),
-- Número de integrantes por hogar
integrantes_por_hogar AS (
    SELECT idHogar, COUNT(*) AS num_personas
    FROM integrante
    GROUP BY idHogar
),
-- Ingreso total del hogar
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
-- Carencias por hogar
carencias AS (
    SELECT 
        h.idHogar,
        iph.num_personas,
        -- Rezago educativo 
        MAX(CASE 
            WHEN (CAST(strftime('%Y', 'now') AS INTEGER) - CAST(strftime('%Y', i.fechaNacimiento) AS INTEGER) 
                  BETWEEN 3 AND 15)
                 AND (e.asisteEscuela = 0 OR ae.anios_educacion < 9)
            THEN 1
            WHEN (CAST(strftime('%Y', 'now') AS INTEGER) - CAST(strftime('%Y', i.fechaNacimiento) AS INTEGER)) > 44
                 AND ae.anios_educacion < 6
            THEN 1
            WHEN (CAST(strftime('%Y', 'now') AS INTEGER) - CAST(strftime('%Y', i.fechaNacimiento) AS INTEGER)) <= 44
                 AND ae.anios_educacion < 9
            THEN 1
            ELSE 0 
        END) AS rezago_educativo,
        -- Salud
        MAX(CASE WHEN s.tieneServicioMedico = 0 THEN 1 ELSE 0 END) AS carencia_salud,
        -- Seguridad social
        MAX(CASE WHEN ss.tieneAfore = 0 AND ss.recibeIncapacidad = 0 THEN 1 ELSE 0 END) AS carencia_seguridad,
        -- Calidad de vivienda y hacinamiento
        MAX(CASE 
            WHEN cv.materialPrincipal IN ('Lámina metálica', 'Lámina de cartón', 'Material de desecho', 'Palma / Bambú', 'Barro', 'Adobe')
              OR cv.materialTecho IN ('Lámina metálica', 'Lámina de cartón', 'Material de desecho', 'Palma / Paja')
              OR (iph.num_personas > 0 AND sv.numHabitaciones > 0 
                  AND (CAST(iph.num_personas AS REAL) / sv.numHabitaciones) > 2.5)
            THEN 1 ELSE 0 
        END) AS carencia_vivienda,
        -- Servicios básicos
        MAX(CASE 
            WHEN sv.aguaObtencion NOT IN ('Entubada dentro de la vivienda', 'Entubada en el terreno')
              OR sv.tieneEnergia = 0
              OR sv.tieneDrenaje = 0
            THEN 1 ELSE 0 
        END) AS carencia_servicios,
        -- Alimentación
        MAX(CASE 
            WHEN a.preocupacionComida = 1 
              OR a.menorDejoComer = 1 
              OR a.adultoDejoComer = 1
              OR a.menorSinComida = 1
              OR a.adultoSinComida = 1
            THEN 1 ELSE 0 
        END) AS carencia_alimentacion
    FROM hogar h
    LEFT JOIN integrantes_por_hogar iph ON h.idHogar = iph.idHogar
    LEFT JOIN vivienda v ON h.idVivienda = v.idVivienda
    LEFT JOIN integrante i ON h.idHogar = i.idHogar
    LEFT JOIN estudios e ON i.idIntegrante = e.idIntegrante
    LEFT JOIN anios_educacion_cte ae ON e.idIntegrante = ae.idIntegrante
    LEFT JOIN salud s ON i.idIntegrante = s.idIntegrante
    LEFT JOIN seguridadsocial ss ON i.idIntegrante = ss.idIntegrante
    LEFT JOIN caracteristicasvivienda cv ON v.idVivienda = cv.idVivienda
    LEFT JOIN serviciosvivienda sv ON v.idVivienda = sv.idVivienda
    LEFT JOIN alimentacion a ON h.idHogar = a.idHogar
    GROUP BY h.idHogar, iph.num_personas
)
-- Clasificación final
SELECT 
    h.idHogar,
    h.folio,
    NULL AS ambito,
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

-- Consulta ejemplo
SELECT folio, num_personas, ingreso_per_capita, total_carencias 
FROM vista_pobreza_hogar;