USE [Gestion Academica];
GO

-- 1.
DROP PROCEDURE IF EXISTS sp_ListarEstudiantesDinamico;
GO

CREATE PROCEDURE sp_ListarEstudiantesDinamico
    @campo_busqueda VARCHAR(100),
    @valor_busqueda VARCHAR(100)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);

    SET @sql = N'SELECT * FROM Estudiante 
                WHERE ' + QUOTENAME(@campo_busqueda) + N' LIKE @valor_param';
    
    SET @params = N'@valor_param VARCHAR(100)';

    EXEC sp_executesql @sql, @params, @valor_param = @valor_busqueda;
END
GO

-- 2.
DROP PROCEDURE IF EXISTS sp_ConsultarInscripcionesPorNota;
GO

CREATE PROCEDURE sp_ConsultarInscripcionesPorNota
    @columna_nota VARCHAR(100),
    @operador VARCHAR(5),
    @valor_nota DECIMAL(4, 2)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);

    IF @operador NOT IN ('>', '<', '=', '>=', '<=')
    BEGIN
        RAISERROR('Operador no valido. usar >, <, =, >=, <=', 16, 1);
        RETURN;
    END

    SET @sql = N'SELECT * FROM Inscripcion 
                WHERE ' + QUOTENAME(@columna_nota) + N' ' + @operador + N' @valor_param';
    
    SET @params = N'@valor_param DECIMAL(4, 2)';

    EXEC sp_executesql @sql, @params, @valor_param = @valor_nota;
END
GO


-- 3.
DROP PROCEDURE IF EXISTS sp_ReporteCursosAgrupados;
GO

CREATE PROCEDURE sp_ReporteCursosAgrupados
    @limite_inscriptos INT,
    @campo_agrupacion VARCHAR(100)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);

    IF @campo_agrupacion NOT IN ('anio', 'id_materia', 'id_profesor')
    BEGIN
        RAISERROR('Campo de agrupacion no valido.', 16, 1);
        RETURN;
    END

    SET @sql = N'
        SELECT ' + QUOTENAME(@campo_agrupacion) + N', COUNT(i.id_estudiante) AS CantidadInscriptos
        FROM Inscripcion i
        JOIN Curso c ON i.id_curso = c.id_curso
        GROUP BY ' + QUOTENAME(@campo_agrupacion) + N'
        HAVING COUNT(i.id_estudiante) > @limite_param';

    SET @params = N'@limite_param INT';

    EXEC sp_executesql @sql, @params, @limite_param = @limite_inscriptos;
END
GO


-- 4.
DROP PROCEDURE IF EXISTS sp_ReporteFacturasAgrupado;
GO

CREATE PROCEDURE sp_ReporteFacturasAgrupado
    @campo_agrupacion VARCHAR(100)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    IF @campo_agrupacion NOT IN ('mes', 'estado_pago', 'id_estudiante', 'anio')
    BEGIN
        RAISERROR('Campo de agrupación no válido.', 16, 1);
        RETURN;
    END

    SET @sql = N'
        SELECT ' + QUOTENAME(@campo_agrupacion) + N', 
               COUNT(*) AS CantidadFacturas, 
               SUM(monto_total) AS MontoTotal
        FROM Factura
        GROUP BY ' + QUOTENAME(@campo_agrupacion) + N'
        ORDER BY ' + QUOTENAME(@campo_agrupacion);

    EXEC sp_executesql @sql;
END
GO


-- 5.
DROP PROCEDURE IF EXISTS sp_ListarCuotasVencidasOrdenDinamico;
GO

CREATE PROCEDURE sp_ListarCuotasVencidasOrdenDinamico
    @campo_orden VARCHAR(100),
    @direccion VARCHAR(4)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);

    IF @campo_orden NOT IN ('fecha_vencimiento', 'monto', 'estado_pago', 'mes')
    BEGIN
        RAISERROR('Campo de orden no valido.', 16, 1);
        RETURN;
    END
    IF @direccion NOT IN ('ASC', 'DESC')
    BEGIN
        SET @direccion = 'ASC';
    END

    SET @sql = N'
        SELECT * FROM Cuota
        WHERE estado_pago = ''pendiente'' AND fecha_vencimiento < GETDATE()
        ORDER BY ' + QUOTENAME(@campo_orden) + N' ' + @direccion;

    EXEC sp_executesql @sql;
END
GO


-- 6.
DROP PROCEDURE IF EXISTS sp_ListarCursosCondicionDinamica;
GO

CREATE PROCEDURE sp_ListarCursosCondicionDinamica
    @campo VARCHAR(100),
    @operador VARCHAR(5),
    @valor VARCHAR(100)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);
    DECLARE @tabla_alias CHAR(2) = 'c.';

    IF @campo IN ('costo_curso_mensual', 'creditos')
        SET @tabla_alias = 'm.';
    ELSE IF @campo NOT IN ('anio')
    BEGIN
        RAISERROR('Campo no valido.', 16, 1);
        RETURN;
    END
    
    IF @operador NOT IN ('>', '<', '=', '>=', '<=') SET @operador = '=';

    SET @sql = N'
        SELECT c.nombre_curso, m.nombre_materia, c.anio, m.creditos, m.costo_curso_mensual
        FROM Curso c
        JOIN Materia m ON c.id_materia = m.id_materia
        WHERE ' + @tabla_alias + QUOTENAME(@campo) + N' ' + @operador + N' @valor_param';
    
    SET @params = N'@valor_param VARCHAR(100)';

    EXEC sp_executesql @sql, @params, @valor_param = @valor;
END
GO


-- 7.
DROP PROCEDURE IF EXISTS sp_ListarProfesoresOrdenDinamico;
GO

CREATE PROCEDURE sp_ListarProfesoresOrdenDinamico
    @id_cuatrimestre INT,
    @campo_orden VARCHAR(100),
    @direccion VARCHAR(4)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);

    IF @campo_orden NOT IN ('nombre', 'apellido', 'especialidad') SET @campo_orden = 'apellido';
    IF @direccion NOT IN ('ASC', 'DESC') SET @direccion = 'ASC';

    SET @sql = N'
        SELECT DISTINCT p.id_profesor, p.nombre, p.apellido, p.especialidad
        FROM Profesor p
        JOIN Curso c ON p.id_profesor = c.id_profesor
        JOIN Cuatrimestre q ON c.anio = YEAR(q.fecha_inicio)
        WHERE q.id_cuatrimestre = @cuatri_param
        ORDER BY ' + QUOTENAME(@campo_orden) + N' ' + @direccion;
    
    SET @params = N'@cuatri_param INT';

    EXEC sp_executesql @sql, @params, @cuatri_param = @id_cuatrimestre;
END
GO


-- 8.
DROP PROCEDURE IF EXISTS sp_ListarMovimientosCCConceptos;
GO

CREATE PROCEDURE sp_ListarMovimientosCCConceptos
    @id_estudiante INT,
    @conceptos_csv VARCHAR(8000)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);

    SET @sql = N'
        SELECT * FROM [Cuenta Corriente]
        WHERE id_estudiante = @id_est_param
          AND concepto IN (SELECT value FROM STRING_SPLIT(@conceptos_param, '',''))';
    
    SET @params = N'@id_est_param INT, @conceptos_param VARCHAR(8000)';

    EXEC sp_executesql @sql, @params, 
        @id_est_param = @id_estudiante, 
        @conceptos_param = @conceptos_csv;
END
GO


-- 9.
DROP PROCEDURE IF EXISTS sp_ListarInscripcionesColumnasDinamicas;
GO

CREATE PROCEDURE sp_ListarInscripcionesColumnasDinamicas
    @columnas VARCHAR(1000)
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    IF CHARINDEX(';', @columnas) > 0 OR CHARINDEX('DROP', @columnas) > 0
    BEGIN
        RAISERROR('Columnas no validas.', 16, 1);
        RETURN;
    END

    SET @sql = N'SELECT id_estudiante, id_curso, ' + @columnas + N' FROM Inscripcion';

    EXEC sp_executesql @sql;
END
GO


-- 10.
DROP PROCEDURE IF EXISTS sp_ListarEstudiantesFiltroCombinado;
GO

CREATE PROCEDURE sp_ListarEstudiantesFiltroCombinado
    @anio_ingreso INT = NULL,
    @apellido_like VARCHAR(100) = NULL
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @params NVARCHAR(MAX);
    
    SET @sql = N'SELECT * FROM Estudiante WHERE 1=1';
    SET @params = N'@anio_param INT, @apellido_param VARCHAR(100)';

    IF @anio_ingreso IS NOT NULL
    BEGIN
        SET @sql = @sql + N' AND anio_ingreso > @anio_param';
    END

    IF @apellido_like IS NOT NULL
    BEGIN
        SET @sql = @sql + N' AND apellido LIKE @apellido_param';
    END

    EXEC sp_executesql @sql, @params, 
        @anio_param = @anio_ingreso, 
        @apellido_param = @apellido_like;
END
GO