USE [Gestion Academica];
GO

DROP TABLE IF EXISTS ItemFactura;
DROP TABLE IF EXISTS Cuota;
DROP TABLE IF EXISTS Inscripcion;
DROP TABLE IF EXISTS Matriculacion;
DROP TABLE IF EXISTS [Cuenta Corriente];
DROP TABLE IF EXISTS Factura;
DROP TABLE IF EXISTS Curso;
DROP TABLE IF EXISTS Cuatrimestre;
DROP TABLE IF EXISTS [Interes por Mora];
DROP TABLE IF EXISTS Estudiante;
DROP TABLE IF EXISTS Profesor;
DROP TABLE IF EXISTS Materia;
GO

CREATE TABLE Estudiante (
    id_estudiante INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Profesor (
    id_profesor INT PRIMARY KEY,
    nombre VARCHAR(100),
    apellido VARCHAR(100),
    especialidad VARCHAR(100)
);

CREATE TABLE Materia (
    id_materia INT PRIMARY KEY,
    nombre_materia VARCHAR(100),
    creditos INT
);

CREATE TABLE Curso (
    id_curso INT PRIMARY KEY,
    nombre_curso VARCHAR(100),
    descripcion TEXT,
    anio INT,
    id_profesor INT,
    id_materia INT,
    FOREIGN KEY (id_profesor) REFERENCES Profesor(id_profesor),
    FOREIGN KEY (id_materia) REFERENCES Materia(id_materia)
);

CREATE TABLE Inscripcion (
    id_estudiante INT,
    id_curso INT,
    fecha_inscripcion DATE,
    nota_teorica DECIMAL(4, 2),
    nota_practica DECIMAL(4, 2),
    nota_final DECIMAL(4, 2),
    PRIMARY KEY (id_estudiante, id_curso),
    FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante),
    FOREIGN KEY (id_curso) REFERENCES Curso(id_curso)
);
GO