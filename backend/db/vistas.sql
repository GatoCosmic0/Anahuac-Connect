-- ============================================
-- CÁLCULO DE POBREZA EN SQLITE
-- ============================================

ALTER TABLE vivienda ADD COLUMN ambito TEXT CHECK (ambito IN ('rural', 'urbano'));
UPDATE vivienda SET ambito = 'urbano' WHERE idVivienda IN (1, 2, 4);
UPDATE vivienda SET ambito = 'rural' WHERE idVivienda IN (3, 5);

-- Trigger para actualizar fecha de modificación en la tabla encuesta

CREATE TRIGGER IF NOT EXISTS trigger_encuesta_modificacion
    AFTER UPDATE ON encuesta
    FOR EACH ROW
    BEGIN
        UPDATE encuesta SET fechaModificacion = CURRENT_TIMESTAMP
        WHERE id_encuesta = NEW.id_encuesta;
    END;


-- Vista principal de pobreza
CREATE VIEW IF NOT EXISTS vista_pobreza_hogar AS
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

-- 3. Función auxiliar para años de educación (mediante CTE)
anios_educacion_cte AS (
    SELECT 
        e.idIntegrante,
        e.ultimoGrado,
        CASE 
            WHEN e.ultimoGrado LIKE '%preescolar%' OR e.ultimoGrado LIKE '%kinder%' THEN 0
            WHEN e.ultimoGrado LIKE '%primaria%' THEN 6
            WHEN e.ultimoGrado LIKE '%secundaria%' THEN 9
            WHEN e.ultimoGrado LIKE '%preparatoria%' OR e.ultimoGrado LIKE '%bachillerato%' THEN 12
            WHEN e.ultimoGrado LIKE '%licenciatura%' OR e.ultimoGrado LIKE '%universidad%' THEN 16
            WHEN e.ultimoGrado LIKE '%maestría%' THEN 18
            WHEN e.ultimoGrado LIKE '%doctorado%' THEN 20
            ELSE 0
        END AS anios
    FROM estudios e
),

-- 4. Carencias por hogar
carencias AS (
    SELECT 
        h.idHogar,
        iph.num_personas,
        -- Rezago educativo
        MAX(CASE 
            WHEN (CAST(strftime('%Y', 'now') AS INTEGER) - CAST(strftime('%Y', i.fechaNacimiento) AS INTEGER) BETWEEN 3 AND 15)
                 AND (e.asisteEscuela = 0 OR ae.anios < 9)
            THEN 1
            WHEN (CAST(strftime('%Y', 'now') AS INTEGER) - CAST(strftime('%Y', i.fechaNacimiento) AS INTEGER)) > 44
                 AND ae.anios < 6
            THEN 1
            WHEN (CAST(strftime('%Y', 'now') AS INTEGER) - CAST(strftime('%Y', i.fechaNacimiento) AS INTEGER)) <= 44
                 AND ae.anios < 9
            THEN 1
            ELSE 0 
        END) AS rezago_educativo,
        -- Salud
        MAX(CASE WHEN s.tieneServicioMedico = 0 THEN 1 ELSE 0 END) AS carencia_salud,
        -- Seguridad social (solo Afore e incapacidad)
        MAX(CASE WHEN ss.tieneAfore = 0 AND ss.recibeIncapacidad = 0 THEN 1 ELSE 0 END) AS carencia_seguridad,
        -- Calidad de vivienda (materiales y hacinamiento)
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
    LEFT JOIN anios_educacion_cte ae ON i.idIntegrante = ae.idIntegrante
    LEFT JOIN salud s ON i.idIntegrante = s.idIntegrante
    LEFT JOIN seguridadsocial ss ON i.idIntegrante = ss.idIntegrante
    LEFT JOIN caracteristicasvivienda cv ON v.idVivienda = cv.idVivienda
    LEFT JOIN serviciosvivienda sv ON v.idVivienda = sv.idVivienda
    LEFT JOIN alimentacion a ON h.idHogar = a.idHogar
    GROUP BY h.idHogar, iph.num_personas
)

-- 5. Clasificación final usando ámbito
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

-- Resumen por comunidad

CREATE VIEW IF NOT EXISTS vista_resumen_comunidad AS
SELECT 
    v.comunidad,
    v.ambito,
    COUNT(DISTINCT e.id_encuesta) AS total_encuestas_validas,
    COUNT(DISTINCT i.idIntegrante) AS total_personas,
    ROUND(AVG(pv.ingreso_per_capita), 2) AS ingreso_promedio,
    ROUND(AVG(pv.total_carencias), 2) AS carencias_promedio,
    SUM(CASE WHEN pv.clasificacion_pobreza = 'Pobreza extrema' THEN 1 ELSE 0 END) AS pobreza_extrema,
    SUM(CASE WHEN pv.clasificacion_pobreza = 'Pobreza moderada' THEN 1 ELSE 0 END) AS pobreza_moderada
FROM encuesta e
JOIN vivienda v ON e.idVivienda = v.idVivienda
LEFT JOIN hogar h ON v.idVivienda = h.idVivienda
LEFT JOIN integrante i ON h.idHogar = i.idHogar
LEFT JOIN vista_pobreza_hogar pv ON h.idHogar = pv.idHogar
WHERE e.estado = 'validada'
GROUP BY v.comunidad, v.ambito;

-- Vista de indicadores por municipio

CREATE VIEW IF NOT EXISTS vista_indicadores_municipio AS
SELECT 
    v.municipio,
    COUNT(DISTINCT e.id_encuesta) AS total_encuestas_validas,
    AVG(pv.ingreso_per_capita) AS ingreso_promedio,
    AVG(pv.total_carencias) AS carencias_promedio,
    (SUM(pv.rezago_educativo) * 100.0 / COUNT(*)) AS pct_rezago_educativo,
    (SUM(pv.carencia_salud) * 100.0 / COUNT(*)) AS pct_carencia_salud,
    (SUM(pv.carencia_seguridad) * 100.0 / COUNT(*)) AS pct_carencia_seguridad,
    (SUM(pv.carencia_vivienda) * 100.0 / COUNT(*)) AS pct_carencia_vivienda,
    (SUM(pv.carencia_servicios) * 100.0 / COUNT(*)) AS pct_carencia_servicios,
    (SUM(pv.carencia_alimentacion) * 100.0 / COUNT(*)) AS pct_carencia_alimentacion
FROM encuesta e
JOIN vivienda v ON e.idVivienda = v.idVivienda
JOIN hogar h ON v.idVivienda = h.idVivienda
JOIN vista_pobreza_hogar pv ON h.idHogar = pv.idHogar
WHERE e.estado = 'validada'
GROUP BY v.municipio;

-- Consulta ejemplo

SELECT folio, ambito, ingreso_per_capita, total_carencias, clasificacion_pobreza
FROM vista_pobreza_hogar;