-- ============================================
-- CONSULTAS PARA DASHBOARD
-- ============================================

-- Resumen general de pobreza

CREATE OR REPLACE VIEW dashboard_resumen_pobreza AS
SELECT 
    clasificacion_pobreza,
    COUNT(*) AS total_hogares,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM vista_pobreza_hogar
GROUP BY clasificacion_pobreza
ORDER BY total_hogares DESC;

-- Carencias más frecuentes por comunidad

CREATE OR REPLACE VIEW dashboard_carencias_por_comunidad AS
SELECT 
    v.comunidad,
    AVG(c.rezago_educativo::int) * 100 AS pct_rezago_educativo,
    AVG(c.carencia_salud::int) * 100 AS pct_carencia_salud,
    AVG(c.carencia_seguridad::int) * 100 AS pct_carencia_seguridad,
    AVG(c.carencia_vivienda::int) * 100 AS pct_carencia_vivienda,
    AVG(c.carencia_servicios::int) * 100 AS pct_carencia_servicios,
    AVG(c.carencia_alimentacion::int) * 100 AS pct_carencia_alimentacion
FROM vista_pobreza_hogar c
JOIN hogar h ON c.idHogar = h.idHogar
JOIN vivienda v ON h.idVivienda = v.idVivienda
GROUP BY v.comunidad;

-- Ingreso promedio por clasificación

CREATE OR REPLACE VIEW dashboard_ingreso_por_clasificacion AS
SELECT 
    clasificacion_pobreza,
    ROUND(AVG(ingreso_per_capita), 2) AS ingreso_promedio,
    MIN(ingreso_per_capita) AS ingreso_minimo,
    MAX(ingreso_per_capita) AS ingreso_maximo
FROM vista_pobreza_hogar
GROUP BY clasificacion_pobreza
ORDER BY ingreso_promedio;

-- Resumen por comunidad

CREATE OR REPLACE VIEW public.vista_resumen_comunidad AS
SELECT 
    v.comunidad,
    v.ambito,
    COUNT(DISTINCT e.idEncuesta) AS total_encuestas_validas,
    COUNT(DISTINCT i.idIntegrante) AS total_personas,
    ROUND(AVG(pv.ingreso_per_capita), 2) AS ingreso_promedio,
    ROUND(AVG(pv.total_carencias), 2) AS carencias_promedio,
    COUNT(*) FILTER (WHERE pv.clasificacion_pobreza = 'Pobreza extrema') AS pobreza_extrema,
    COUNT(*) FILTER (WHERE pv.clasificacion_pobreza = 'Pobreza moderada') AS pobreza_moderada
FROM public.encuesta e
JOIN public.vivienda v ON e.idVivienda = v.idVivienda
LEFT JOIN public.hogar h ON v.idVivienda = h.idVivienda
LEFT JOIN public.integrante i ON h.idHogar = i.idHogar
LEFT JOIN public.vista_pobreza_hogar pv ON h.idHogar = pv.idHogar
WHERE e.estado = 'validada'
GROUP BY v.comunidad, v.ambito;