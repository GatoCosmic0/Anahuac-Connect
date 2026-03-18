-- TABLA 1: VIVIENDA

CREATE TABLE Vivienda (
    idVivienda INTEGER PRIMARY KEY AUTOINCREMENT,
    estado TEXT NOT NULL,
    municipio TEXT NOT NULL,
    comunidad TEXT NOT NULL,
    ageb TEXT,
    manzana TEXT,
    domicilio TEXT NOT NULL,
    religion TEXT,
    comunidadIndigena INTEGER DEFAULT 0,
    viviendaHabitada INTEGER DEFAULT 1,
    usoPredio TEXT,
    tienePapelesPropiedad INTEGER,
    situacionLegal TEXT
);

-- TABLA 2: HOGAR

CREATE TABLE Hogar (
    idHogar INTEGER PRIMARY KEY AUTOINCREMENT,
    idVivienda INTEGER NOT NULL,
    folio TEXT UNIQUE NOT NULL,
    FOREIGN KEY (idVivienda)
        REFERENCES Vivienda(idVivienda)
        ON DELETE CASCADE
);

-- TABLA 3: INTEGRANTE

CREATE TABLE Integrante (
    idIntegrante INTEGER PRIMARY KEY AUTOINCREMENT,
    idHogar INTEGER NOT NULL,
    nombre TEXT NOT NULL,
    apellidoPaterno TEXT NOT NULL,
    apellidoMaterno TEXT,
    parentesco TEXT NOT NULL,
    curp TEXT UNIQUE,
    sexo TEXT NOT NULL CHECK (sexo IN ('M', 'F', 'O')),
    fechaNacimiento TEXT NOT NULL,
    estadoNacimiento TEXT,
    estadoCivil TEXT,
    hablaLenguaIndigena INTEGER DEFAULT 0,
    tieneDiscapacidad INTEGER DEFAULT 0,
    tipoDiscapacidad TEXT,
    tienePadecimiento INTEGER DEFAULT 0,
    tipoPadecimiento TEXT,
    FOREIGN KEY (idHogar)
        REFERENCES Hogar(idHogar)
        ON DELETE CASCADE
);

-- TABLA 4: ESTUDIOS

CREATE TABLE Estudios (
    idEstudios INTEGER PRIMARY KEY AUTOINCREMENT,
    idIntegrante INTEGER NOT NULL UNIQUE,
    asisteEscuela INTEGER DEFAULT 0,
    ultimoGrado TEXT,
    FOREIGN KEY (idIntegrante)
        REFERENCES Integrante(idIntegrante)
        ON DELETE CASCADE
);

-- TABLA 5: OCUPACION

CREATE TABLE Ocupacion (
    idOcupacion INTEGER PRIMARY KEY AUTOINCREMENT,
    idIntegrante INTEGER NOT NULL UNIQUE,
    trabaja INTEGER DEFAULT 0,
    actividad TEXT,
    posicion TEXT,
    salarioMensual REAL,
    FOREIGN KEY (idIntegrante)
        REFERENCES Integrante(idIntegrante)
        ON DELETE CASCADE
);

-- TABLA 6: SALUD

CREATE TABLE Salud (
    idSalud INTEGER PRIMARY KEY AUTOINCREMENT,
    idIntegrante INTEGER NOT NULL UNIQUE,
    tieneServicioMedico INTEGER DEFAULT 0,
    tipoServicio TEXT,
    proveedorServicio TEXT,
    FOREIGN KEY (idIntegrante)
        REFERENCES Integrante(idIntegrante)
        ON DELETE CASCADE
);

-- TABLA 7: SEGURIDAD SOCIAL

CREATE TABLE SeguridadSocial (
    idSeguridadSocial INTEGER PRIMARY KEY AUTOINCREMENT,
    idIntegrante INTEGER NOT NULL UNIQUE,
    tieneAfore INTEGER DEFAULT 0,
    recibeIncapacidad INTEGER DEFAULT 0,
    FOREIGN KEY (idIntegrante)
        REFERENCES Integrante(idIntegrante)
        ON DELETE CASCADE
);

-- TABLA 8: INGRESOSADICIONALES

CREATE TABLE IngresosAdicionales (
    idIngresoAdicional INTEGER PRIMARY KEY AUTOINCREMENT,
    idIntegrante INTEGER NOT NULL,
    tieneIngresosAdicionales INTEGER DEFAULT 0,
    tieneRentas INTEGER DEFAULT 0,
    tienePension INTEGER DEFAULT 0,
    tieneRemesas INTEGER DEFAULT 0,
    tieneProgramaSocial INTEGER DEFAULT 0,
    tieneOtro INTEGER DEFAULT 0,
    FOREIGN KEY (idIntegrante)
        REFERENCES Integrante(idIntegrante)
        ON DELETE CASCADE
);

-- TABLA 9: PROGRAMASOCIAL

CREATE TABLE ProgramaSocial (
    idProgramaSocial INTEGER PRIMARY KEY AUTOINCREMENT,
    idIntegrante INTEGER NOT NULL,
    esBeneficiario INTEGER DEFAULT 1,
    numApoyos INTEGER DEFAULT 1,
    nombrePrograma TEXT NOT NULL,
    montoMensual REAL,
    FOREIGN KEY (idIntegrante)
        REFERENCES Integrante(idIntegrante)
        ON DELETE CASCADE
);

-- TABLA 10: GASTOHOGAR

CREATE TABLE GastoHogar (
    idGasto INTEGER PRIMARY KEY AUTOINCREMENT,
    idHogar INTEGER NOT NULL UNIQUE,
    alimentacion REAL DEFAULT 0,
    luz REAL DEFAULT 0,
    agua REAL DEFAULT 0,
    vivienda REAL DEFAULT 0,
    educacion REAL DEFAULT 0,
    salud REAL DEFAULT 0,
    otro REAL DEFAULT 0,
    FOREIGN KEY (idHogar)
        REFERENCES Hogar(idHogar)
        ON DELETE CASCADE
);

-- TABLA 11: ALIMENTACIÓN

CREATE TABLE Alimentacion (
    idAlimentacion INTEGER PRIMARY KEY AUTOINCREMENT,
    idHogar INTEGER NOT NULL UNIQUE,
    comidasDia INTEGER,
    preocupacionComida INTEGER,
    menorPocaVariedad INTEGER,
    menorDejoComer INTEGER,
    menorComioMenos INTEGER,
    menorSinComida INTEGER,
    menorHambre INTEGER,
    menorComioUnaVez INTEGER,
    menorAccionVerguenza INTEGER,
    adultoPocaVariedad INTEGER,
    adultoDejoComer INTEGER,
    adultoComioMenos INTEGER,
    adultoSinComida INTEGER,
    adultoHambre INTEGER,
    adultoComioUnaVez INTEGER,
    FOREIGN KEY (idHogar)
        REFERENCES Hogar(idHogar)
        ON DELETE CASCADE
);

-- TABLA 12: CARACTERISTICASVIVIENDA

CREATE TABLE CaracteristicasVivienda (
    idCaracteristicas INTEGER PRIMARY KEY AUTOINCREMENT,
    idVivienda INTEGER NOT NULL UNIQUE,
    tipoVivienda TEXT,
    tenencia TEXT,
    materialPrincipal TEXT,
    otroPrincipal TEXT,
    materialTecho TEXT,
    otroTecho TEXT,
    FOREIGN KEY (idVivienda)
        REFERENCES Vivienda(idVivienda)
        ON DELETE CASCADE
);

-- TABLA 13: SERVICIOSVIVIENDA

CREATE TABLE ServiciosVivienda (
    idServicios INTEGER PRIMARY KEY AUTOINCREMENT,
    idVivienda INTEGER NOT NULL UNIQUE,
    aguaObtencion TEXT,
    tieneEnergia INTEGER DEFAULT 0,
    numFocos INTEGER,
    tieneDrenaje INTEGER DEFAULT 0,
    tipoDrenaje TEXT,
    numHabitaciones INTEGER,
    numBanos INTEGER,
    tieneLetrina INTEGER DEFAULT 0,
    FOREIGN KEY (idVivienda)
        REFERENCES Vivienda(idVivienda)
        ON DELETE CASCADE
);

-- TABLA 14: EQUIPAMIENTOVIVIENDA

CREATE TABLE EquipamientoVivienda (
    idEquipamiento INTEGER PRIMARY KEY AUTOINCREMENT,
    idVivienda INTEGER NOT NULL UNIQUE,
    tieneLavadora INTEGER DEFAULT 0,
    tieneRefrigerador INTEGER DEFAULT 0,
    tieneEstufa INTEGER DEFAULT 0,
    tieneMicroondas INTEGER DEFAULT 0,
    tieneInternet INTEGER DEFAULT 0,
    tieneComputadora INTEGER DEFAULT 0,
    tieneTelevision INTEGER DEFAULT 0,
    tieneTinaco INTEGER DEFAULT 0,
    tieneAbanico INTEGER DEFAULT 0,
    tieneAireAC INTEGER DEFAULT 0,
    tieneTelefono INTEGER DEFAULT 0,
    tieneTVPaga INTEGER DEFAULT 0,
    tieneCelular INTEGER DEFAULT 0,
    tieneBoiler INTEGER DEFAULT 0,
    tieneVehiculo INTEGER DEFAULT 0,
    numVehiculos INTEGER DEFAULT 0,
    cocinaCon TEXT,
    tieneChimenea INTEGER DEFAULT 0,
    tieneHuertoFamiliar INTEGER DEFAULT 0,
    FOREIGN KEY (idVivienda)
        REFERENCES Vivienda(idVivienda)
        ON DELETE CASCADE
);

-- TABLA 15: FACILIDADVIVIENDA

CREATE TABLE FacilidadVivienda (
    idFacilidad INTEGER PRIMARY KEY AUTOINCREMENT,
    idVivienda INTEGER NOT NULL UNIQUE,
    facilidadMedica INTEGER,
    facilidadRecursos INTEGER,
    facilidadTrabajo INTEGER,
    facilidadAcompanamiento INTEGER,
    facilidadComunidad INTEGER,
    facilidad INTEGER,
    FOREIGN KEY (idVivienda)
        REFERENCES Vivienda(idVivienda)
        ON DELETE CASCADE
);

-- TABLA 16: VIOLENCIA

CREATE TABLE Violencia (
    idViolencia INTEGER PRIMARY KEY AUTOINCREMENT,
    idHogar INTEGER NOT NULL,
    sufridoViolencia TEXT,
    afectado TEXT,
    afectadoOtros TEXT,
    tipoViolencia TEXT,
    tipoOtros TEXT,
    lugarIncidente TEXT,
    lugarOtros TEXT,
    autorIncidente TEXT,
    denuncia TEXT,
    observaciones TEXT,
    FOREIGN KEY (idHogar)
        REFERENCES Hogar(idHogar)
        ON DELETE CASCADE
);

-- TABLA 17: ACCESOSERVICIOS

CREATE TABLE AccesoServicios (
    idAcceso INTEGER PRIMARY KEY AUTOINCREMENT,
    idVivienda INTEGER NOT NULL UNIQUE,
    distanciaCentroSalud TEXT,
    distanciaEscuela TEXT,
    nivelesEducativos TEXT,
    FOREIGN KEY (idVivienda)
        REFERENCES Vivienda(idVivienda)
        ON DELETE CASCADE
);

-- TABLA 18: COHESIONSOCIAL

CREATE TABLE CohesionSocial (
    idCohesion INTEGER PRIMARY KEY AUTOINCREMENT,
    idHogar INTEGER NOT NULL UNIQUE,
    confianzaComunidad TEXT,
    ayudaMutua TEXT,
    participaActividades INTEGER DEFAULT 0,
    respetoDiferencia TEXT,
    trabajoUnido TEXT,
    FOREIGN KEY (idHogar)
        REFERENCES Hogar(idHogar)
        ON DELETE CASCADE
);

-- TABLA 19: FICHATECNICA

CREATE TABLE FichaTecnica (
    idFicha INTEGER PRIMARY KEY AUTOINCREMENT,
    idHogar INTEGER NOT NULL UNIQUE,
    fechaEntrevista TEXT NOT NULL,
    horaEntrevista TEXT NOT NULL,
    numVisita INTEGER DEFAULT 1,
    nombreEntrevistado TEXT,
    firmaEntrevistado TEXT,
    nombreEntrevistador TEXT NOT NULL,
    firmaEntrevistador TEXT,
    FOREIGN KEY (idHogar)
        REFERENCES Hogar(idHogar)
        ON DELETE CASCADE
);

-- ÍNDICES PARA BÚSQUEDA RÁPIDA

CREATE INDEX idx_hogar_vivienda ON Hogar(idVivienda);
CREATE INDEX idx_integrante_hogar ON Integrante(idHogar);
CREATE INDEX idx_integrante_curp ON Integrante(curp);
CREATE INDEX idx_programa_integrante ON ProgramaSocial(idIntegrante);
CREATE INDEX idx_violencia_hogar ON Violencia(idHogar);
CREATE INDEX idx_ingresos_integrante ON IngresosAdicionales(idIntegrante);