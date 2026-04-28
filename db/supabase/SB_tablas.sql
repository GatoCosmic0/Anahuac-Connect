----------------- TABLAS DE SISTEMA  -----------------

CREATE TABLE IF NOT EXISTS usuarios (
    idUsuario SERIAL PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    nombre TEXT,
    apellido TEXT,
    rol TEXT NOT NULL CHECK (rol IN ('admin', 'encuestador', 'investigador', 'sistema')),
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS encuesta (
    idEncuesta SERIAL PRIMARY KEY,
    idVivienda INTEGER NOT NULL
        REFERENCES vivienda(idVivienda)
        ON DELETE CASCADE,
    idEncuestador INTEGER NOT NULL 
        REFERENCES usuarios(idUsuario)
        ON DELETE CASCADE,
    fechaCaptura TIMESTAMPTZ DEFAULT now(),
    fechaEnvio TIMESTAMPTZ,
    fechaModificacion TIMESTAMPTZ DEFAULT now(),
    estado TEXT NOT NULL CHECK (estado IN ('borrador', 'enviada', 'observada', 'validada')),
    observaciones TEXT,  -- para cuando se rechaza o se piden cambios
    UNIQUE(idVivienda)   -- una vivienda solo puede tener una encuesta activa (la más reciente)
);

----------------- TABLAS DE ENCUESTA -----------------

-- TABLA 1: VIVIENDA

CREATE TABLE vivienda (
    idVivienda BIGSERIAL PRIMARY KEY,
    estado TEXT NOT NULL,
    municipio TEXT NOT NULL,
    comunidad TEXT NOT NULL,
    ageb TEXT,
    manzana TEXT,
    domicilio TEXT NOT NULL,
    religion TEXT,
    comunidadIndigena BOOLEAN DEFAULT false,
    viviendaHabitada BOOLEAN DEFAULT true,
    usoPredio TEXT,
    tienePapelesPropiedad BOOLEAN,
    situacionLegal TEXT,
    ambito TEXT CHECK (ambito IN ('rural', 'urbano'))
);

-- TABLA 2: HOGAR

CREATE TABLE hogar (
    idHogar BIGSERIAL PRIMARY KEY,
    idVivienda BIGINT NOT NULL
        REFERENCES vivienda(idVivienda)
        ON DELETE CASCADE,
    folio TEXT UNIQUE NOT NULL
);

-- TABLA 3: INTEGRANTE

CREATE TABLE integrante (
    idIntegrante BIGSERIAL PRIMARY KEY,
    idHogar BIGINT NOT NULL
        REFERENCES hogar(idHogar)
        ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    apellidoPaterno TEXT NOT NULL,
    apellidoMaterno TEXT,
    parentesco TEXT NOT NULL,
    curp TEXT UNIQUE,
    sexo TEXT NOT NULL CHECK (sexo IN ('M', 'F', 'O')),
    fechaNacimiento DATE NOT NULL,
    estadoNacimiento TEXT,
    estadoCivil TEXT,
    hablaLenguaIndigena BOOLEAN DEFAULT false,
    tieneDiscapacidad BOOLEAN DEFAULT false,
    tipoDiscapacidad TEXT,
    tienePadecimiento BOOLEAN DEFAULT false,
    tipoPadecimiento TEXT
);

-- TABLA 4: ESTUDIOS

CREATE TABLE estudios (
    idEstudios BIGSERIAL PRIMARY KEY,
    idIntegrante BIGINT NOT NULL UNIQUE
        REFERENCES integrante(idIntegrante)
        ON DELETE CASCADE,
    asisteEscuela BOOLEAN DEFAULT false,
    ultimoGrado TEXT
);

-- TABLA 5: OCUPACIÓN

CREATE TABLE ocupacion (
    idOcupacion BIGSERIAL PRIMARY KEY,
    idIntegrante BIGINT NOT NULL UNIQUE
        REFERENCES integrante(idIntegrante)
        ON DELETE CASCADE,
    trabaja BOOLEAN DEFAULT false,
    actividad TEXT,
    posicion TEXT,
    salarioMensual NUMERIC(10,2)
);

-- TABLA 6: SALUD

CREATE TABLE salud (
    idSalud BIGSERIAL PRIMARY KEY,
    idIntegrante BIGINT NOT NULL UNIQUE
        REFERENCES integrante(idIntegrante)
        ON DELETE CASCADE,
    tieneServicioMedico BOOLEAN DEFAULT false,
    tipoServicio TEXT,
    proveedorServicio TEXT
);

-- TABLA 7: SEGURIDAD SOCIAL

CREATE TABLE seguridadsocial (
    idSeguridadSocial BIGSERIAL PRIMARY KEY,
    idIntegrante BIGINT NOT NULL UNIQUE
        REFERENCES integrante(idIntegrante)
        ON DELETE CASCADE,
    tieneAfore BOOLEAN DEFAULT false,
    recibeIncapacidad BOOLEAN DEFAULT false
);

-- TABLA 8: INGRESOS ADICIONALES

CREATE TABLE ingresosadicionales (
    idIngresoAdicional BIGSERIAL PRIMARY KEY,
    idIntegrante BIGINT NOT NULL
        REFERENCES integrante(idIntegrante)
        ON DELETE CASCADE,
    tieneIngresosAdicionales BOOLEAN DEFAULT false,
    tieneRentas BOOLEAN DEFAULT false,
    tienePension BOOLEAN DEFAULT false,
    tieneRemesas BOOLEAN DEFAULT false,
    tieneProgramaSocial BOOLEAN DEFAULT false,
    tieneOtro BOOLEAN DEFAULT false
);

-- TABLA 9: PROGRAMA SOCIAL

CREATE TABLE programasocial (
    idProgramaSocial BIGSERIAL PRIMARY KEY,
    idIntegrante BIGINT NOT NULL
        REFERENCES integrante(idIntegrante)
        ON DELETE CASCADE,
    esBeneficiario BOOLEAN DEFAULT true,
    numApoyos INTEGER DEFAULT 1,
    nombrePrograma TEXT NOT NULL,
    montoMensual NUMERIC(10,2)
);

-- TABLA 10: GASTOHOGAR

CREATE TABLE gastohogar (
    idGasto BIGSERIAL PRIMARY KEY,
    idHogar BIGINT NOT NULL UNIQUE
        REFERENCES hogar(idHogar)
        ON DELETE CASCADE,
    alimentacion NUMERIC(10,2) DEFAULT 0,
    luz NUMERIC(10,2) DEFAULT 0,
    agua NUMERIC(10,2) DEFAULT 0,
    vivienda NUMERIC(10,2) DEFAULT 0,
    educacion NUMERIC(10,2) DEFAULT 0,
    salud NUMERIC(10,2) DEFAULT 0,
    otro NUMERIC(10,2) DEFAULT 0
);

-- TABLA 11: ALIMENTACIÓN

CREATE TABLE alimentacion (
    idAlimentacion BIGSERIAL PRIMARY KEY,
    idHogar BIGINT NOT NULL UNIQUE
        REFERENCES hogar(idHogar)
        ON DELETE CASCADE,
    comidasDia INTEGER,
    preocupacionComida BOOLEAN,
    menorPocaVariedad BOOLEAN,
    menorDejoComer BOOLEAN,
    menorComioMenos BOOLEAN,
    menorSinComida BOOLEAN,
    menorHambre BOOLEAN,
    menorComioUnaVez BOOLEAN,
    menorAccionVerguenza BOOLEAN,
    adultoPocaVariedad BOOLEAN,
    adultoDejoComer BOOLEAN,
    adultoComioMenos BOOLEAN,
    adultoSinComida BOOLEAN,
    adultoHambre BOOLEAN,
    adultoComioUnaVez BOOLEAN
);

-- TABLA 12: CARACTERÍSTICASVIVIENDA

CREATE TABLE caracteristicasvivienda (
    idCaracteristicas BIGSERIAL PRIMARY KEY,
    idVivienda BIGINT NOT NULL UNIQUE
        REFERENCES vivienda(idVivienda)
        ON DELETE CASCADE,
    tipoVivienda TEXT,
    tenencia TEXT,
    materialPrincipal TEXT,
    otroPrincipal TEXT,
    materialTecho TEXT,
    otroTecho TEXT
);

-- TABLA 13: SERVICIOSVIVIENDA

CREATE TABLE serviciosvivienda (
    idServicios BIGSERIAL PRIMARY KEY,
    idVivienda BIGINT NOT NULL UNIQUE
        REFERENCES vivienda(idVivienda) 
        ON DELETE CASCADE,
    aguaObtencion TEXT,
    tieneEnergia BOOLEAN DEFAULT false,
    numFocos INTEGER,
    tieneDrenaje BOOLEAN DEFAULT false,
    tipoDrenaje TEXT,
    numHabitaciones INTEGER,
    numBanos INTEGER,
    tieneLetrina BOOLEAN DEFAULT false
);

-- TABLA 14: EQUIPAMIENTOVIVIENDA

CREATE TABLE equipamientovivienda (
    idEquipamiento BIGSERIAL PRIMARY KEY,
    idVivienda BIGINT NOT NULL UNIQUE
        REFERENCES vivienda(idVivienda)
        ON DELETE CASCADE,
    tieneLavadora BOOLEAN DEFAULT false,
    tieneRefrigerador BOOLEAN DEFAULT false,
    tieneEstufa BOOLEAN DEFAULT false,
    tieneMicroondas BOOLEAN DEFAULT false,
    tieneInternet BOOLEAN DEFAULT false,
    tieneComputadora BOOLEAN DEFAULT false,
    tieneTelevision BOOLEAN DEFAULT false,
    tieneTinaco BOOLEAN DEFAULT false,
    tieneAbanico BOOLEAN DEFAULT false,
    tieneAireAC BOOLEAN DEFAULT false,
    tieneTelefono BOOLEAN DEFAULT false,
    tieneTVPaga BOOLEAN DEFAULT false,
    tieneCelular BOOLEAN DEFAULT false,
    tieneBoiler BOOLEAN DEFAULT false,
    tieneVehiculo BOOLEAN DEFAULT false,
    numVehiculos INTEGER DEFAULT 0,
    cocinaCon TEXT,
    tieneChimenea BOOLEAN DEFAULT false,
    tieneHuertoFamiliar BOOLEAN DEFAULT false
);

-- TABLA 15: FACILIDADVIVIENDA

CREATE TABLE facilidadvivienda (
    idFacilidad BIGSERIAL PRIMARY KEY,
    idVivienda BIGINT NOT NULL UNIQUE
        REFERENCES vivienda(idVivienda)
        ON DELETE CASCADE,
    facilidadMedica INTEGER,
    facilidadRecursos INTEGER,
    facilidadTrabajo INTEGER,
    facilidadAcompanamiento INTEGER,
    facilidadComunidad INTEGER,
    facilidad INTEGER
);

-- TABLA 16: VIOLENCIA

CREATE TABLE violencia (
    idViolencia BIGSERIAL PRIMARY KEY,
    idHogar BIGINT NOT NULL
        REFERENCES hogar(idHogar)
        ON DELETE CASCADE,
    sufridoViolencia TEXT,
    afectado TEXT,
    afectadoOtros TEXT,
    tipoViolencia TEXT,
    tipoOtros TEXT,
    lugarIncidente TEXT,
    lugarOtros TEXT,
    autorIncidente TEXT,
    denuncia TEXT,
    observaciones TEXT
);

-- TABLA 17: ACCESOSERVICIOS

CREATE TABLE accesoservicios (
    idAcceso BIGSERIAL PRIMARY KEY,
    idVivienda BIGINT NOT NULL UNIQUE
        REFERENCES vivienda(idVivienda)
        ON DELETE CASCADE,
    distanciaCentroSalud TEXT,
    distanciaEscuela TEXT,
    nivelesEducativos TEXT
);

-- TABLA 18: COHESIÓN SOCIAL

CREATE TABLE cohesionsocial (
    idCohesion BIGSERIAL PRIMARY KEY,
    idHogar BIGINT NOT NULL UNIQUE
        REFERENCES hogar(idHogar)
        ON DELETE CASCADE,
    confianzaComunidad TEXT,
    ayudaMutua TEXT,
    participaActividades BOOLEAN DEFAULT false,
    respetoDiferencia TEXT,
    trabajoUnido TEXT
);

-- TABLA 19: FICHA TÉCNICA

CREATE TABLE fichatecnica (
    idFicha BIGSERIAL PRIMARY KEY,
    idHogar BIGINT NOT NULL UNIQUE
        REFERENCES hogar(idHogar)
        ON DELETE CASCADE,
    fechaEntrevista DATE NOT NULL,
    horaEntrevista TIME NOT NULL,
    numVisita INTEGER DEFAULT 1,
    nombreEntrevistado TEXT,
    firmaEntrevistado TEXT,
    nombreEntrevistador TEXT NOT NULL,
    firmaEntrevistador TEXT
);

-- ÍNDICES PARA BÚSQUEDA RÁPIDA

CREATE INDEX idx_hogar_vivienda ON hogar(idVivienda);
CREATE INDEX idx_integrante_hogar ON integrante(idHogar);
CREATE INDEX idx_integrante_curp ON integrante(curp);
CREATE INDEX idx_programa_integrante ON programasocial(idIntegrante);
CREATE INDEX idx_violencia_hogar ON violencia(idHogar);
CREATE INDEX idx_ingresos_integrante ON ingresosadicionales(idIntegrante);

-- RLS (protección)
ALTER TABLE vivienda ENABLE ROW LEVEL SECURITY;
ALTER TABLE hogar ENABLE ROW LEVEL SECURITY;
ALTER TABLE integrante ENABLE ROW LEVEL SECURITY;
ALTER TABLE estudios ENABLE ROW LEVEL SECURITY;
ALTER TABLE ocupacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE salud ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguridadsocial ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingresosadicionales ENABLE ROW LEVEL SECURITY;
ALTER TABLE programasocial ENABLE ROW LEVEL SECURITY;
ALTER TABLE gastohogar ENABLE ROW LEVEL SECURITY;
ALTER TABLE alimentacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE caracteristicasvivienda ENABLE ROW LEVEL SECURITY;
ALTER TABLE serviciosvivienda ENABLE ROW LEVEL SECURITY;
ALTER TABLE equipamientovivienda ENABLE ROW LEVEL SECURITY;
ALTER TABLE facilidadvivienda ENABLE ROW LEVEL SECURITY;
ALTER TABLE violencia ENABLE ROW LEVEL SECURITY;
ALTER TABLE accesoservicios ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohesionsocial ENABLE ROW LEVEL SECURITY;
ALTER TABLE fichatecnica ENABLE ROW LEVEL SECURITY;

-- Políticas básicas
CREATE POLICY "Acceso público de lectura" ON vivienda FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON hogar FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON integrante FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON estudios FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON ocupacion FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON salud FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON seguridadsocial FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON ingresosadicionales FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON programasocial FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON gastohogar FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON alimentacion FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON caracteristicasvivienda FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON serviciosvivienda FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON equipamientovivienda FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON facilidadvivienda FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON violencia FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON accesoservicios FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON cohesionsocial FOR SELECT USING (true);
CREATE POLICY "Acceso público de lectura" ON fichatecnica FOR SELECT USING (true);