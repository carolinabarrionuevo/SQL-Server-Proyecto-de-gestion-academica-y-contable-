USE [Gestion Academica];
GO

ALTER TABLE Estudiante
ADD anio_ingreso INT;
ALTER TABLE Estudiante
ADD estado_baja BIT DEFAULT 0 NOT NULL;
ALTER TABLE Materia
ADD costo_curso_mensual DECIMAL(10, 2);
ALTER TABLE Inscripcion
DROP COLUMN nota_practica;
ALTER TABLE Inscripcion
ADD nota_practica_1 DECIMAL(4, 2);
ALTER TABLE Inscripcion
ADD nota_teorica_2 DECIMAL(4, 2);
ALTER TABLE Inscripcion
ADD nota_teorica_recuperatorio DECIMAL(4, 2);

DROP TABLE IF EXISTS ItemFactura;
DROP TABLE IF EXISTS Cuota;
DROP TABLE IF EXISTS Matriculacion;
DROP TABLE IF EXISTS [Cuenta Corriente];
DROP TABLE IF EXISTS Factura;
DROP TABLE IF EXISTS Cuatrimestre;
DROP TABLE IF EXISTS [Interes por Mora];

CREATE TABLE Cuatrimestre (
    id_cuatrimestre INT PRIMARY KEY,
    nombre VARCHAR(100),
    fecha_inicio DATE,
    fecha_fin DATE
);

CREATE TABLE [Interes por Mora] (
    anio_carrera INT PRIMARY KEY,
    porcentaje_interes DECIMAL(5, 2)
);

CREATE TABLE Factura (
    id_factura INT PRIMARY KEY IDENTITY(1,1),
    id_estudiante INT,
    mes INT,
    anio INT,
    fecha_emision DATE,
    fecha_vencimiento DATE,
    monto_total DECIMAL(10, 2) DEFAULT 0,
    estado_pago VARCHAR(50) DEFAULT 'pendiente',
    FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante)
);

CREATE TABLE [Cuenta Corriente] (
    id_movimiento INT PRIMARY KEY IDENTITY(1,1),
    id_estudiante INT,
    fecha DATETIME DEFAULT GETDATE(),
    concepto VARCHAR(255),
    monto DECIMAL(10, 2),
    estado VARCHAR(50) DEFAULT 'pendiente',
    FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante)
);

CREATE TABLE Matriculacion (
    id_matricula INT PRIMARY KEY IDENTITY(1,1),
    id_estudiante INT,
    anio INT,
    fecha_pago DATE,
    monto DECIMAL(10, 2),
    estado_pago VARCHAR(50) DEFAULT 'pendiente',
    FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante),
    UNIQUE (id_estudiante, anio)
);

CREATE TABLE Cuota (
    id_cuota INT PRIMARY KEY IDENTITY(1,1),
    id_estudiante INT,
    id_cuatrimestre INT,
    id_factura INT,
    mes INT,
    monto DECIMAL(10, 2),
    fecha_vencimiento DATE,
    estado_pago VARCHAR(50) DEFAULT 'pendiente',
    FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante),
    FOREIGN KEY (id_cuatrimestre) REFERENCES Cuatrimestre(id_cuatrimestre),
    FOREIGN KEY (id_factura) REFERENCES Factura(id_factura)
);

CREATE TABLE ItemFactura (
    id_factura INT,
    id_curso INT,
    PRIMARY KEY (id_factura, id_curso),
    FOREIGN KEY (id_factura) REFERENCES Factura(id_factura),
    FOREIGN KEY (id_curso) REFERENCES Curso(id_curso)
);