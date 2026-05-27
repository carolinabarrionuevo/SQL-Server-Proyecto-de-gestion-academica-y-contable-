USE [Gestion Academica];
GO

DROP FUNCTION IF EXISTS dbo.fn_ObtenerSaldoCC;
GO

CREATE FUNCTION dbo.fn_ObtenerSaldoCC (
    @id_estudiante INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @saldo DECIMAL(10, 2);
    SELECT @saldo = ISNULL(SUM(monto), 0.00)
    FROM [Cuenta Corriente]
    WHERE id_estudiante = @id_estudiante;
    RETURN @saldo;
END
GO


DROP FUNCTION IF EXISTS dbo.fn_ObtenerVacantesCurso;
GO

CREATE FUNCTION dbo.fn_ObtenerVacantesCurso (
    @id_curso INT
)
RETURNS INT
AS
BEGIN
    DECLARE @max_alumnos INT = 35;
    DECLARE @inscritos_actuales INT;
    DECLARE @vacantes INT;

    SELECT @inscritos_actuales = COUNT(*)
    FROM Inscripcion
    WHERE id_curso = @id_curso;

    SET @vacantes = @max_alumnos - @inscritos_actuales;
    
    IF @vacantes < 0
        SET @vacantes = 0;
    RETURN @vacantes;
END
GO

DROP FUNCTION IF EXISTS dbo.fn_ObtenerNombreCompletoEstudiante;
GO

CREATE FUNCTION dbo.fn_ObtenerNombreCompletoEstudiante (
    @id_estudiante INT
)
RETURNS VARCHAR(201)
AS
BEGIN
    DECLARE @nombre_completo VARCHAR(201);
    SELECT @nombre_completo = apellido + ', ' + nombre
    FROM Estudiante
    WHERE id_estudiante = @id_estudiante;
    IF @nombre_completo IS NULL
        SET @nombre_completo = 'Estudiante no encontrado';

    RETURN @nombre_completo;
END
GO