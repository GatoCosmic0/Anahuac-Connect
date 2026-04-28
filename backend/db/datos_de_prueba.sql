INSERT INTO usuarios (email, nombre, apellido, rol) VALUES
('admin@diagnostico.com', 'Anahuac', 'Administradora', 'admin'),
('encuestador1@diagnostico.com', 'Karla', 'Trejo', 'encuestador'),
('encuestador2@diagnostico.com', 'Andrés', 'Chávez', 'encuestador'),
('investigador@diagnostico.com', 'Jerónimo', 'Galvez', 'investigador'),
('sistema@diagnostico.com', 'Sistema', 'Automático', 'sistema');

INSERT INTO public.encuesta (idVivienda, idEncuestador, fechaCaptura, fechaEnvio, fechaModificacion, estado, observaciones) VALUES
(1, 2, '2026-04-01 10:30:00', '2026-04-01 11:00:00', '2026-04-02 09:00:00', 'validada', 'Encuesta completa sin observaciones'),
(2, 2, '2026-04-02 11:45:00', '2026-04-02 12:30:00', '2026-04-02 12:30:00', 'enviada', NULL),
(3, 3, '2026-04-03 09:15:00', '2026-04-03 10:00:00', '2026-04-04 14:20:00', 'observada', 'Revisar datos de alimentación e ingresos'),
(4, 2, '2026-04-04 16:20:00', NULL, '2026-04-04 17:00:00', 'borrador', 'Faltan módulos de salud y alimentación'),
(5, 3, '2026-04-05 13:00:00', '2026-04-05 14:15:00', '2026-04-05 14:15:00', 'enviada', NULL);

-- ============================================
-- 1. VIVIENDAS (5 viviendas)
-- ============================================
INSERT INTO vivienda (idVivienda, estado, municipio, comunidad, ageb, manzana, domicilio, religion, comunidadIndigena, viviendaHabitada, usoPredio, tienePapelesPropiedad, situacionLegal) VALUES
(1, 'Jalisco', 'Zapopan', 'Las Águilas', '1234', '5', 'Calle Principal #123', 'Católica', false, true, 'Solo vivienda', true, 'Propiedad privada'),
(2, 'Estado de México', 'Ecatepec', 'San Agustín', '5678', '3', 'Av. Central #456', 'Cristiana', false, true, 'Vivienda y tienda', false, 'En trámite'),
(3, 'Chiapas', 'San Cristóbal', 'San Juan Chamula', '9012', '2', 'Calle Real #78', 'Católica', true, true, 'Solo vivienda', true, 'Propiedad comunal'),
(4, 'Nuevo León', 'Monterrey', 'Contry', '3456', '10', 'Privada del Valle #234', 'Católica', false, true, 'Solo vivienda', true, 'Propiedad privada'),
(5, 'Guerrero', 'Acapulco', 'Renacimiento', '7890', '8', 'Calle del Mar #567', 'Católica', false, true, 'Vivienda y taller', false, 'Posesión sin título');

UPDATE vivienda SET ambito = 'urbano' WHERE idVivienda IN (1, 2, 4);
UPDATE vivienda SET ambito = 'rural' WHERE idVivienda IN (3, 5);

-- ============================================
-- 2. HOGARES (1 por vivienda)
-- ============================================
INSERT INTO hogar (idHogar, idVivienda, folio) VALUES
(1, 1, 'HOG-2026-001'),
(2, 2, 'HOG-2026-002'),
(3, 3, 'HOG-2026-003'),
(4, 4, 'HOG-2026-004'),
(5, 5, 'HOG-2026-005');

-- ============================================
-- 3. INTEGRANTES (por hogar)
-- ============================================
-- Hogar 1: Familia de 4 (padre, madre, 2 hijos)
INSERT INTO integrante (idIntegrante, idHogar, nombre, apellidoPaterno, apellidoMaterno, parentesco, curp, sexo, fechaNacimiento, estadoNacimiento, estadoCivil, hablaLenguaIndigena, tieneDiscapacidad, tipoDiscapacidad, tienePadecimiento, tipoPadecimiento) VALUES
(1, 1, 'Carlos', 'Ramírez', 'López', 'Jefe(a) de familia', 'RALC750101HDFMPR01', 'M', '1975-01-01', 'Jalisco', 'Casado', false, false, NULL, true, 'Hipertensión'),
(2, 1, 'María', 'González', 'Pérez', 'Cónyuge', 'GOPM780202MJCRNR02', 'F', '1978-02-02', 'Jalisco', 'Casada', false, false, NULL, false, NULL),
(3, 1, 'Luis', 'Ramírez', 'González', 'Hijo(a)', 'RALG050303HJCRNR03', 'M', '2005-03-03', 'Jalisco', 'Soltero', false, false, NULL, false, NULL),
(4, 1, 'Ana', 'Ramírez', 'González', 'Hijo(a)', 'RAGA080404MJCRNR04', 'F', '2008-04-04', 'Jalisco', 'Soltera', false, false, NULL, false, NULL);

-- Hogar 2: Familia de 3 (madre soltera, 2 hijos)
INSERT INTO integrante (idIntegrante, idHogar, nombre, apellidoPaterno, apellidoMaterno, parentesco, curp, sexo, fechaNacimiento, estadoNacimiento, estadoCivil, hablaLenguaIndigena, tieneDiscapacidad, tipoDiscapacidad, tienePadecimiento, tipoPadecimiento) VALUES
(5, 2, 'Sofía', 'Martínez', 'Hernández', 'Jefe(a) de familia', 'MAHS850505MDFRRN05', 'F', '1985-05-05', 'Estado de México', 'Divorciada', false, false, NULL, false, NULL),
(6, 2, 'Jesús', 'Martínez', 'López', 'Hijo(a)', 'MALJ100606HDFRRL06', 'M', '2010-06-06', 'Estado de México', 'Soltero', false, false, NULL, false, NULL),
(7, 2, 'Karla', 'Martínez', 'López', 'Hijo(a)', 'MALK120707MJCRRL07', 'F', '2012-07-07', 'Estado de México', 'Soltera', false, false, NULL, false, NULL);

-- Hogar 3: Familia de 6 (padre, madre, 4 hijos, zona indígena)
INSERT INTO integrante (idIntegrante, idHogar, nombre, apellidoPaterno, apellidoMaterno, parentesco, curp, sexo, fechaNacimiento, estadoNacimiento, estadoCivil, hablaLenguaIndigena, tieneDiscapacidad, tipoDiscapacidad, tienePadecimiento, tipoPadecimiento) VALUES
(8, 3, 'Juan', 'Pérez', 'Gómez', 'Jefe(a) de familia', 'PEGJ680101HCHGRR08', 'M', '1968-01-01', 'Chiapas', 'Casado', true, false, NULL, true, 'Diabetes'),
(9, 3, 'Elena', 'López', 'Méndez', 'Cónyuge', 'LOME700202MCHGNR09', 'F', '1970-02-02', 'Chiapas', 'Casada', true, false, NULL, false, NULL),
(10, 3, 'Pedro', 'Pérez', 'López', 'Hijo(a)', 'PELP950303HCHGRR10', 'M', '1995-03-03', 'Chiapas', 'Soltero', true, false, NULL, false, NULL),
(11, 3, 'María', 'Pérez', 'López', 'Hijo(a)', 'PELM970404MJCHGRR11', 'F', '1997-04-04', 'Chiapas', 'Soltera', true, false, NULL, false, NULL),
(12, 3, 'José', 'Pérez', 'López', 'Hijo(a)', 'PELJ000505HCHGRR12', 'M', '2000-05-05', 'Chiapas', 'Soltero', true, false, NULL, false, NULL),
(13, 3, 'Lucía', 'Pérez', 'López', 'Hijo(a)', 'PELL020606MJCHGRR13', 'F', '2002-06-06', 'Chiapas', 'Soltera', true, false, NULL, false, NULL);

-- Hogar 4: Pareja de adultos mayores (2 personas)
INSERT INTO integrante (idIntegrante, idHogar, nombre, apellidoPaterno, apellidoMaterno, parentesco, curp, sexo, fechaNacimiento, estadoNacimiento, estadoCivil, hablaLenguaIndigena, tieneDiscapacidad, tipoDiscapacidad, tienePadecimiento, tipoPadecimiento) VALUES
(14, 4, 'Roberto', 'Sánchez', 'Flores', 'Jefe(a) de familia', 'SAFR550707HNLLNR14', 'M', '1955-07-07', 'Nuevo León', 'Casado', false, true, 'Motriz', true, 'Hipertensión'),
(15, 4, 'Teresa', 'Garza', 'Ríos', 'Cónyuge', 'GART600808MNLRR15', 'F', '1960-08-08', 'Nuevo León', 'Casada', false, false, NULL, false, NULL);

-- Hogar 5: Persona sola (joven desempleado)
INSERT INTO integrante (idIntegrante, idHogar, nombre, apellidoPaterno, apellidoMaterno, parentesco, curp, sexo, fechaNacimiento, estadoNacimiento, estadoCivil, hablaLenguaIndigena, tieneDiscapacidad, tipoDiscapacidad, tienePadecimiento, tipoPadecimiento) VALUES
(16, 5, 'Alejandro', 'Rojas', 'Castro', 'Jefe(a) de familia', 'ROCA900909HGTRSR16', 'M', '1990-09-09', 'Guerrero', 'Soltero', false, false, NULL, false, NULL);

-- ============================================
-- 4. ESTUDIOS
-- ============================================
-- Hogar 1: Padre (secundaria), Madre (preparatoria), Hijos (primaria y secundaria en curso)
INSERT INTO estudios (idEstudios, idIntegrante, asisteEscuela, ultimoGrado) VALUES
(1, 1, false, 'Secundaria completa'),
(2, 2, false, 'Preparatoria completa'),
(3, 3, true, 'Secundaria (1er año)'),
(4, 4, true, 'Primaria (5to año)');

-- Hogar 2: Madre (secundaria), Hijos (primaria y preescolar)
INSERT INTO estudios (idEstudios, idIntegrante, asisteEscuela, ultimoGrado) VALUES
(5, 5, false, 'Secundaria completa'),
(6, 6, true, 'Primaria (4to año)'),
(7, 7, true, 'Preescolar');

-- Hogar 3: Padre (primaria incompleta), Madre (sin estudios), Hijos (varios niveles, algunos no asisten)
INSERT INTO estudios (idEstudios, idIntegrante, asisteEscuela, ultimoGrado) VALUES
(8, 8, false, 'Primaria (3er año)'),
(9, 9, false, 'Ninguno'),
(10, 10, false, 'Primaria (6to año)'),
(11, 11, false, 'Secundaria (3er año)'),
(12, 12, true, 'Primaria (4to año)'),
(13, 13, true, 'Primaria (2do año)');

-- Hogar 4: Ambos con profesionista (universidad)
INSERT INTO estudios (idEstudios, idIntegrante, asisteEscuela, ultimoGrado) VALUES
(14, 14, false, 'Licenciatura completa'),
(15, 15, false, 'Licenciatura completa');

-- Hogar 5: Preparatoria trunca
INSERT INTO estudios (idEstudios, idIntegrante, asisteEscuela, ultimoGrado) VALUES
(16, 16, false, 'Preparatoria (2do año)');

-- ============================================
-- 5. OCUPACION
-- ============================================
-- Hogar 1: Padre empleado formal, madre ama de casa
INSERT INTO ocupacion (idOcupacion, idIntegrante, trabaja, actividad, posicion, salarioMensual) VALUES
(1, 1, true, 'Operador de maquinaria', 'Empleado', 6500),
(2, 2, false, 'Quehaceres del hogar', NULL, 0),
(3, 3, false, NULL, NULL, 0),
(4, 4, false, NULL, NULL, 0);

-- Hogar 2: Madre empleada informal
INSERT INTO ocupacion (idOcupacion, idIntegrante, trabaja, actividad, posicion, salarioMensual) VALUES
(5, 5, true, 'Vendedora ambulante', 'Dueño', 2800),
(6, 6, false, NULL, NULL, 0),
(7, 7, false, NULL, NULL, 0);

-- Hogar 3: Padre jornalero, madre ama de casa, hijos algunos trabajan informal
INSERT INTO ocupacion (idOcupacion, idIntegrante, trabaja, actividad, posicion, salarioMensual) VALUES
(8, 8, true, 'Jornalero', 'Empleado', 1800),
(9, 9, false, 'Quehaceres del hogar', NULL, 0),
(10, 10, true, 'Ayudante de albañil', 'Empleado', 2000),
(11, 11, false, NULL, NULL, 0),
(12, 12, false, NULL, NULL, 0),
(13, 13, false, NULL, NULL, 0);

-- Hogar 4: Ambos jubilados (sin salario activo)
INSERT INTO ocupacion (idOcupacion, idIntegrante, trabaja, actividad, posicion, salarioMensual) VALUES
(14, 14, false, 'Jubilado', NULL, 0),
(15, 15, false, 'Jubilada', NULL, 0);

-- Hogar 5: Desempleado
INSERT INTO ocupacion (idOcupacion, idIntegrante, trabaja, actividad, posicion, salarioMensual) VALUES
(16, 16, false, 'Busca empleo', NULL, 0);

-- ============================================
-- 6. SALUD
-- ============================================
-- Hogar 1: Todos tienen IMSS (excepto hijo menor que aún no está registrado)
INSERT INTO salud (idSalud, idIntegrante, tieneServicioMedico, tipoServicio, proveedorServicio) VALUES
(1, 1, true, 'IMSS', 'Instituto Mexicano del Seguro Social'),
(2, 2, true, 'IMSS', 'Instituto Mexicano del Seguro Social'),
(3, 3, true, 'IMSS', 'Instituto Mexicano del Seguro Social'),
(4, 4, false, NULL, NULL);

-- Hogar 2: Madre tiene INSABI (público), hijos no tienen
INSERT INTO salud (idSalud, idIntegrante, tieneServicioMedico, tipoServicio, proveedorServicio) VALUES
(5, 5, true, 'INSABI', 'Servicios de Salud del EdoMex'),
(6, 6, false, NULL, NULL),
(7, 7, false, NULL, NULL);

-- Hogar 3: Solo el padre tiene IMSS, el resto ninguno (comunidad indígena marginada)
INSERT INTO salud (idSalud, idIntegrante, tieneServicioMedico, tipoServicio, proveedorServicio) VALUES
(8, 8, true, 'IMSS', 'Instituto Mexicano del Seguro Social'),
(9, 9, false, NULL, NULL),
(10, 10, false, NULL, NULL),
(11, 11, false, NULL, NULL),
(12, 12, false, NULL, NULL),
(13, 13, false, NULL, NULL);

-- Hogar 4: Ambos tienen IMSS e ISSSTE (pensionados)
INSERT INTO salud (idSalud, idIntegrante, tieneServicioMedico, tipoServicio, proveedorServicio) VALUES
(14, 14, true, 'IMSS', 'Instituto Mexicano del Seguro Social'),
(15, 15, true, 'ISSSTE', 'Instituto de Seguridad y Servicios Sociales de los Trabajadores del Estado');

-- Hogar 5: No tiene seguro
INSERT INTO salud (idSalud, idIntegrante, tieneServicioMedico, tipoServicio, proveedorServicio) VALUES
(16, 16, false, NULL, NULL);

-- ============================================
-- 7. SEGURIDAD SOCIAL
-- ============================================
-- Hogar 1: Padre tiene Afore (por trabajo formal), madre no, hijos no
INSERT INTO seguridadsocial (idSeguridadSocial, idIntegrante, tieneAfore, recibeIncapacidad) VALUES
(1, 1, true, false),
(2, 2, false, false),
(3, 3, false, false),
(4, 4, false, false);

-- Hogar 2: Madre no tiene Afore (trabajo informal)
INSERT INTO seguridadsocial (idSeguridadSocial, idIntegrante, tieneAfore, recibeIncapacidad) VALUES
(5, 5, false, false),
(6, 6, false, false),
(7, 7, false, false);

-- Hogar 3: Padre tiene Afore (aunque salario bajo), hijos no
INSERT INTO seguridadsocial (idSeguridadSocial, idIntegrante, tieneAfore, recibeIncapacidad) VALUES
(8, 8, true, false),
(9, 9, false, false),
(10, 10, false, false),
(11, 11, false, false),
(12, 12, false, false),
(13, 13, false, false);

-- Hogar 4: Ambos tienen Afore y pensión (jubilados)
INSERT INTO seguridadsocial (idSeguridadSocial, idIntegrante, tieneAfore, recibeIncapacidad) VALUES
(14, 14, true, false),
(15, 15, true, false);

-- Hogar 5: No tiene nada
INSERT INTO seguridadsocial (idSeguridadSocial, idIntegrante, tieneAfore, recibeIncapacidad) VALUES
(16, 16, false, false);

-- ============================================
-- 8. INGRESOS ADICIONALES (solo booleanos, sin montos)
-- ============================================
-- Hogar 1: Recibe becas para hijos
INSERT INTO ingresosAdicionales (idIngresoAdicional, idIntegrante, tieneIngresosAdicionales, tieneRentas, tienePension, tieneRemesas, tieneProgramaSocial, tieneOtro) VALUES
(1, 1, false, false, false, false, false, false),
(2, 2, false, false, false, false, false, false),
(3, 3, true, false, false, false, true, false),  -- beca Benito Juárez
(4, 4, true, false, false, false, true, false);   -- beca Benito Juárez

-- Hogar 2: Recibe remesas del extranjero
INSERT INTO ingresosAdicionales (idIngresoAdicional, idIntegrante, tieneIngresosAdicionales, tieneRentas, tienePension, tieneRemesas, tieneProgramaSocial, tieneOtro) VALUES
(5, 5, true, false, false, true, false, false),
(6, 6, false, false, false, false, false, false),
(7, 7, false, false, false, false, false, false);

-- Hogar 3: Recibe programas sociales (pensión adultos mayores y becas)
INSERT INTO ingresosAdicionales (idIngresoAdicional, idIntegrante, tieneIngresosAdicionales, tieneRentas, tienePension, tieneRemesas, tieneProgramaSocial, tieneOtro) VALUES
(8, 8, true, false, true, false, true, false),  -- pensión adultos mayores
(9, 9, true, false, false, false, true, false),  -- programa mujer bienestar
(10, 10, false, false, false, false, false, false),
(11, 11, false, false, false, false, false, false),
(12, 12, true, false, false, false, true, false), -- beca
(13, 13, true, false, false, false, true, false); -- beca

-- Hogar 4: Reciben pensión por jubilación (ya se considera ingreso, pero aquí solo booleano)
INSERT INTO ingresosAdicionales (idIngresoAdicional, idIntegrante, tieneIngresosAdicionales, tieneRentas, tienePension, tieneRemesas, tieneProgramaSocial, tieneOtro) VALUES
(14, 14, true, false, true, false, false, false),
(15, 15, true, false, true, false, false, false);

-- Hogar 5: No recibe nada adicional
INSERT INTO ingresosAdicionales (idIngresoAdicional, idIntegrante, tieneIngresosAdicionales, tieneRentas, tienePension, tieneRemesas, tieneProgramaSocial, tieneOtro) VALUES
(16, 16, false, false, false, false, false, false);

-- ============================================
-- 9. PROGRAMAS SOCIALES (con montos)
-- ============================================
-- Hogar 1: Beca Benito Juárez para los hijos
INSERT INTO programaSocial (idProgramaSocial, idIntegrante, esBeneficiario, numApoyos, nombrePrograma, montoMensual) VALUES
(1, 3, true, 1, 'Beca Benito Juárez', 800),
(2, 4, true, 1, 'Beca Benito Juárez', 800);

-- Hogar 2: Programa de apoyo alimentario
INSERT INTO programaSocial (idProgramaSocial, idIntegrante, esBeneficiario, numApoyos, nombrePrograma, montoMensual) VALUES
(3, 5, true, 1, 'Pensión para el bienestar de las personas con discapacidad', 0); -- no aplica monto real

-- Hogar 3: Pensión adultos mayores (padre), Pensión Mujeres Bienestar (madre), becas (hijos)
INSERT INTO programaSocial (idProgramaSocial, idIntegrante, esBeneficiario, numApoyos, nombrePrograma, montoMensual) VALUES
(4, 8, true, 1, 'Pensión para adultos mayores', 3100),
(5, 9, true, 1, 'Pensión Mujeres Bienestar', 3000),
(6, 12, true, 1, 'Beca Benito Juárez', 800),
(7, 13, true, 1, 'Beca Benito Juárez', 800);

-- Hogar 4: Pensión por jubilación (pero ya no tienen programa activo, solo ingreso)
INSERT INTO programaSocial (idProgramaSocial, idIntegrante, esBeneficiario, numApoyos, nombrePrograma, montoMensual) VALUES
(8, 14, false, 0, 'Ninguno', 0),
(9, 15, false, 0, 'Ninguno', 0);

-- Hogar 5: Ninguno
INSERT INTO programaSocial (idProgramaSocial, idIntegrante, esBeneficiario, numApoyos, nombrePrograma, montoMensual) VALUES
(10, 16, false, 0, 'Ninguno', 0);

-- ============================================
-- 10. GASTO HOGAR
-- ============================================
INSERT INTO gastoHogar (idGasto, idHogar, alimentacion, luz, agua, vivienda, educacion, salud, otro) VALUES
(1, 1, 3000, 500, 200, 2500, 400, 300, 200),   -- Hogar 1
(2, 2, 1800, 300, 100, 1500, 200, 100, 100),   -- Hogar 2
(3, 3, 2000, 200, 80, 800, 100, 50, 50),       -- Hogar 3
(4, 4, 3500, 800, 300, 4000, 0, 1000, 500),    -- Hogar 4
(5, 5, 1200, 200, 80, 1200, 0, 0, 100);        -- Hogar 5

-- ============================================
-- 11. ALIMENTACION (con preguntas de inseguridad)
-- ============================================
-- Hogar 1: Sin inseguridad alimentaria
INSERT INTO alimentacion (idAlimentacion, idHogar, comidasDia, preocupacionComida, menorPocaVariedad, menorDejoComer, menorComioMenos, menorSinComida, menorHambre, menorComioUnaVez, menorAccionVerguenza, adultoPocaVariedad, adultoDejoComer, adultoComioMenos, adultoSinComida, adultoHambre, adultoComioUnaVez) VALUES
(1, 1, 4, false, false, false, false, false, false, false, false, false, false, false, false, false, false);

-- Hogar 2: Inseguridad leve (preocupación)
INSERT INTO alimentacion (idAlimentacion, idHogar, comidasDia, preocupacionComida, menorPocaVariedad, menorDejoComer, menorComioMenos, menorSinComida, menorHambre, menorComioUnaVez, menorAccionVerguenza, adultoPocaVariedad, adultoDejoComer, adultoComioMenos, adultoSinComida, adultoHambre, adultoComioUnaVez) VALUES
(2, 2, 3, true, false, false, false, false, false, false, false, false, true, false, false, false, false);

-- Hogar 3: Inseguridad moderada (adultos dejaron de comer, niños comieron menos)
INSERT INTO alimentacion (idAlimentacion, idHogar, comidasDia, preocupacionComida, menorPocaVariedad, menorDejoComer, menorComioMenos, menorSinComida, menorHambre, menorComioUnaVez, menorAccionVerguenza, adultoPocaVariedad, adultoDejoComer, adultoComioMenos, adultoSinComida, adultoHambre, adultoComioUnaVez) VALUES
(3, 3, 2, true, true, false, true, false, true, false, false, true, true, false, true, false, false);

-- Hogar 4: Sin inseguridad
INSERT INTO alimentacion (idAlimentacion, idHogar, comidasDia, preocupacionComida, menorPocaVariedad, menorDejoComer, menorComioMenos, menorSinComida, menorHambre, menorComioUnaVez, menorAccionVerguenza, adultoPocaVariedad, adultoDejoComer, adultoComioMenos, adultoSinComida, adultoHambre, adultoComioUnaVez) VALUES
(4, 4, 4, false, false, false, false, false, false, false, false, false, false, false, false, false, false);

-- Hogar 5: Inseguridad severa (se quedaron sin comida y comieron solo una vez)
INSERT INTO alimentacion (idAlimentacion, idHogar, comidasDia, preocupacionComida, menorPocaVariedad, menorDejoComer, menorComioMenos, menorSinComida, menorHambre, menorComioUnaVez, menorAccionVerguenza, adultoPocaVariedad, adultoDejoComer, adultoComioMenos, adultoSinComida, adultoHambre, adultoComioUnaVez) VALUES
(5, 5, 1, true, false, false, false, false, false, false, false, false, true, false, true, true, true);

-- ============================================
-- 12. CARACTERISTICAS VIVIENDA
-- ============================================
INSERT INTO caracteristicasVivienda (idCaracteristicas, idVivienda, tipoVivienda, tenencia, materialPrincipal, otroPrincipal, materialTecho, otroTecho) VALUES
(1, 1, 'Casa independiente', 'Propia', 'Block', NULL, 'Concreto', NULL),        -- Buena calidad
(2, 2, 'Vivienda en vecindad', 'Rentada', 'Ladrillo', NULL, 'Lámina metálica', NULL),  -- Techo precario
(3, 3, 'Vivienda en vecindad', 'Propia', 'Madera', NULL, 'Palma / Paja', NULL),        -- Materiales precarios
(4, 4, 'Casa independiente', 'Propia', 'Block', NULL, 'Concreto', NULL),              -- Buena calidad
(5, 5, 'Vivienda en cuarto de azotea', 'Prestada', 'Lámina de cartón', NULL, 'Lámina metálica', NULL);  -- Muy precaria

-- ============================================
-- 13. SERVICIOS VIVIENDA
-- ============================================
INSERT INTO serviciosVivienda (idServicios, idVivienda, aguaObtencion, tieneEnergia, numFocos, tieneDrenaje, tipoDrenaje, numHabitaciones, numBanos, tieneLetrina) VALUES
(1, 1, 'Entubada dentro de la vivienda', true, 8, true, 'Red pública', 4, 2, false),   -- Todos servicios
(2, 2, 'Entubada fuera de la vivienda', true, 4, true, 'Red pública', 3, 1, false),    -- Agua fuera
(3, 3, 'Pipa', false, 2, false, 'Fosa séptica', 2, 0, true),                          -- Sin energía, sin drenaje, letrina
(4, 4, 'Entubada dentro de la vivienda', true, 12, true, 'Red pública', 5, 3, false),  -- Todos servicios
(5, 5, 'Llave comunitaria', true, 3, false, 'Tubería a barranca', 2, 1, false);       -- Sin drenaje, agua comunitaria

-- ============================================
-- 14. EQUIPAMIENTO VIVIENDA
-- ============================================
INSERT INTO equipamientoVivienda (idEquipamiento, idVivienda, tieneLavadora, tieneRefrigerador, tieneEstufa, tieneMicroondas, tieneInternet, tieneComputadora, tieneTelevision, tieneTinaco, tieneAbanico, tieneAireAC, tieneTelefono, tieneTVPaga, tieneCelular, tieneBoiler, tieneVehiculo, numVehiculos, cocinaCon, tieneChimenea, tieneHuertoFamiliar) VALUES
(1, 1, true, true, true, true, true, true, true, true, true, false, false, true, true, true, true, 1, 'Gas', false, false),
(2, 2, false, true, true, false, false, false, true, false, true, false, false, false, true, false, false, 0, 'Gas', false, false),
(3, 3, false, false, true, false, false, false, true, false, true, false, false, false, true, false, false, 0, 'Leña o carbón', true, true),
(4, 4, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, 2, 'Gas', false, false),
(5, 5, false, false, true, false, false, false, false, false, true, false, false, false, true, false, false, 0, 'Leña o carbón', false, false);

-- ============================================
-- 15. FACILIDAD VIVIENDA (valores 1-6)
-- ============================================
INSERT INTO facilidadVivienda (idFacilidad, idVivienda, facilidadMedica, facilidadRecursos, facilidadTrabajo, facilidadAcompanamiento, facilidadComunidad, facilidad) VALUES
(1, 1, 5, 4, 5, 5, 4, 5),
(2, 2, 3, 2, 2, 3, 3, 3),
(3, 3, 2, 1, 1, 2, 2, 2),
(4, 4, 6, 5, 6, 6, 5, 6),
(5, 5, 2, 1, 1, 2, 1, 2);

-- ============================================
-- 16. VIOLENCIA
-- ============================================
INSERT INTO violencia (idViolencia, idHogar, sufridoViolencia, afectado, afectadoOtros, tipoViolencia, tipoOtros, lugarIncidente, lugarOtros, autorIncidente, denuncia, observaciones) VALUES
(1, 1, 'No', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Sin incidentes reportados'),
(2, 2, 'Si', 'Cónyuge', NULL, 'Verbal', NULL, 'Hogar', NULL, 'Cónyuge', 'No', 'Insultos recurrentes'),
(3, 3, 'Si', 'Jefe(a) del hogar', NULL, 'Física', NULL, 'Hogar', NULL, 'Vecino(a)', 'No', 'Golpes durante riña vecinal'),
(4, 4, 'No', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Sin incidentes'),
(5, 5, 'Si', 'Jefe(a) del hogar', NULL, 'Psicológica', NULL, 'Espacio público', NULL, 'Desconocido', 'No', 'Acoso callejero');

-- ============================================
-- 17. ACCESO SERVICIOS
-- ============================================
INSERT INTO accesoServicios (idAcceso, idVivienda, distanciaCentroSalud, distanciaEscuela, nivelesEducativos) VALUES
(1, 1, 'Menos de 1Km', 'Menos de 1Km', 'Preescolar, Primaria, Secundaria, Bachillerato, Universidad'),
(2, 2, 'Entre 1 y 5 Km', 'Menos de 1Km', 'Preescolar, Primaria, Secundaria'),
(3, 3, 'Más de 5 Km', 'Entre 1 y 5 Km', 'Preescolar, Primaria'),
(4, 4, 'Menos de 1Km', 'Menos de 1Km', 'Preescolar, Primaria, Secundaria, Bachillerato, Universidad'),
(5, 5, 'Más de 5 Km', 'Más de 5 Km', 'No hay escuela cercana');

-- ============================================
-- 18. COHESION SOCIAL
-- ============================================
INSERT INTO cohesionSocial (idCohesion, idHogar, confianzaComunidad, ayudaMutua, participaActividades, respetoDiferencia, trabajoUnido) VALUES
(1, 1, 'Mucho', 'Siempre', true, 'Si, en general', 'Si'),
(2, 2, 'Algo', 'A veces', false, 'A veces', 'A veces'),
(3, 3, 'Poco', 'Rara vez', true, 'No mucho', 'No mucho'),
(4, 4, 'Mucho', 'Siempre', true, 'Si, en general', 'Si'),
(5, 5, 'Nada', 'Nunca', false, 'No', 'No mucho');

-- ============================================
-- 19. FICHA TECNICA
-- ============================================
INSERT INTO fichaTecnica (idFicha, idHogar, fechaEntrevista, horaEntrevista, numVisita, nombreEntrevistado, firmaEntrevistado, nombreEntrevistador, firmaEntrevistador) VALUES
(1, 1, '2026-04-01', '10:30:00', 1, 'Carlos Ramírez', 'Firma digital', 'Ana López', 'Firma digital'),
(2, 2, '2026-04-02', '11:45:00', 2, 'Sofía Martínez', 'Firma digital', 'Ana López', 'Firma digital'),
(3, 3, '2026-04-03', '09:15:00', 1, 'Juan Pérez', 'Firma digital', 'Carlos Ruiz', 'Firma digital'),
(4, 4, '2026-04-04', '16:20:00', 1, 'Roberto Sánchez', 'Firma digital', 'Ana López', 'Firma digital'),
(5, 5, '2026-04-05', '13:00:00', 3, 'Alejandro Rojas', 'Firma digital', 'Carlos Ruiz', 'Firma digital');