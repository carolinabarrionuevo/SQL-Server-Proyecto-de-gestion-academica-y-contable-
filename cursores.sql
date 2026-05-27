USE [Gestion Academica];
GO

DROP PROCEDURE IF EXISTS sp_ListarNotasFinalesEstudiantes;
GO

CREATE PROCEDURE sp_ListarNotasFinalesEstudiantes
AS
BEGIN
    DECLARE @nombre VARCHAR(100), @apellido VARCHAR(100), @curso VARCHAR(100), @nota DECIMAL(4, 2);
    
    DECLARE NotasCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT 
            E.nombre, 
            E.apellido, 
            C.nombre_curso, 
            I.nota_final
        FROM Inscripcion I
        JOIN Estudiante E ON I.id_estudiante = E.id_estudiante
        JOIN Curso C ON I.id_curso = C.id_curso
        ORDER BY E.apellido, C.nombre_curso;

    OPEN NotasCursor;
    FETCH NEXT FROM NotasCursor INTO @nombre, @apellido, @curso, @nota;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @apellido + ', ' + @nombre + ' | Curso: ' + @curso + ' | Nota: ' + ISNULL(CAST(@nota AS VARCHAR(10)), 'N/A');
        FETCH NEXT FROM NotasCursor INTO @nombre, @apellido, @curso, @nota;
    END

    CLOSE NotasCursor;
    DEALLOCATE NotasCursor;
END
GO

-- 2.
DROP PROCEDURE IF EXISTS sp_ListarHistorialPagos;
GO

CREATE PROCEDURE sp_ListarHistorialPagos
AS
BEGIN
    DECLARE @nombre VARCHAR(100), @apellido VARCHAR(100), @fecha DATETIME, @concepto VARCHAR(255), @monto DECIMAL(10, 2);
    DECLARE @id_est_actual INT = 0;

    DECLARE PagosCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT 
            E.id_estudiante,
            E.nombre,
            E.apellido,
            CC.fecha,
            CC.concepto,
            CC.monto
        FROM [Cuenta Corriente] CC
        JOIN Estudiante E ON CC.id_estudiante = E.id_estudiante
        WHERE CC.monto < 0
        ORDER BY E.apellido, E.nombre, CC.fecha;
    
    OPEN PagosCursor;
    FETCH NEXT FROM PagosCursor INTO @id_est_actual, @nombre, @apellido, @fecha, @concepto, @monto;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @apellido + ', ' + @nombre + ' | ' + CONVERT(VARCHAR(10), @fecha, 103) + ' | ' + @concepto + ' | ' + CAST(@monto AS VARCHAR(20));
        FETCH NEXT FROM PagosCursor INTO @id_est_actual, @nombre, @apellido, @fecha, @concepto, @monto;
    END

    CLOSE PagosCursor;
    DEALLOCATE PagosCursor;
END
GO


-- 3.
DROP PROCEDURE IF EXISTS sp_ListarMateriaProfesorCurso;
GO

CREATE PROCEDURE sp_ListarMateriaProfesorCurso
AS
BEGIN
    DECLARE @materia VARCHAR(100), @curso VARCHAR(100), @prof_nombre VARCHAR(100), @prof_apellido VARCHAR(100);

    DECLARE MateriaCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT 
            M.nombre_materia,
            C.nombre_curso,
            P.nombre,
            P.apellido
        FROM Materia M
        JOIN Curso C ON M.id_materia = C.id_materia
        JOIN Profesor P ON C.id_profesor = P.id_profesor
        ORDER BY P.apellido;

    OPEN MateriaCursor;
    FETCH NEXT FROM MateriaCursor INTO @materia, @curso, @prof_nombre, @prof_apellido;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Materia: ' + @materia + ' | Curso: ' + @curso + ' | Profesor: ' + @prof_apellido + ', ' + @prof_nombre;
        FETCH NEXT FROM MateriaCursor INTO @materia, @curso, @prof_nombre, @prof_apellido;
    END

    CLOSE MateriaCursor;
    DEALLOCATE MateriaCursor;
END
GO

-- 4.
DROP PROCEDURE IF EXISTS sp_ListarInscripcionesPorCuatrimestre;
GO

CREATE PROCEDURE sp_ListarInscripcionesPorCuatrimestre
AS
BEGIN
    DECLARE @cuatri VARCHAR(100), @curso VARCHAR(100), @est_nombre VARCHAR(100), @est_apellido VARCHAR(100);


    DECLARE InscCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT 
            Q.nombre,
            C.nombre_curso,
            E.nombre,
            E.apellido
        FROM Inscripcion I
        JOIN Estudiante E ON I.id_estudiante = E.id_estudiante
        JOIN Curso C ON I.id_curso = C.id_curso
        JOIN Cuatrimestre Q ON C.anio = YEAR(Q.fecha_inicio)
        ORDER BY Q.nombre, C.nombre_curso, E.apellido;

    OPEN InscCursor;
    FETCH NEXT FROM InscCursor INTO @cuatri, @curso, @est_nombre, @est_apellido;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Cuatrimestre: ' + @cuatri + ' | Curso: ' + @curso + ' | Alumno: ' + @est_apellido + ', ' + @est_nombre;
        FETCH NEXT FROM InscCursor INTO @cuatri, @curso, @est_nombre, @est_apellido;
    END

    CLOSE InscCursor;
    DEALLOCATE InscCursor;
END
GO


-- 5.
DROP PROCEDURE IF EXISTS sp_ListarEstudiantesConCuotasVencidas;
GO

CREATE PROCEDURE sp_ListarEstudiantesConCuotasVencidas
AS
BEGIN
    DECLARE @nombre VARCHAR(100), @apellido VARCHAR(100), @email VARCHAR(100);

    DECLARE VencidosCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT DISTINCT
            E.nombre,
            E.apellido,
            E.email
        FROM Estudiante E
        JOIN Cuota C ON E.id_estudiante = C.id_estudiante
        WHERE C.estado_pago = 'pendiente'
          AND C.fecha_vencimiento < GETDATE();

    OPEN VencidosCursor;
    FETCH NEXT FROM VencidosCursor INTO @nombre, @apellido, @email;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @apellido + ', ' + @nombre + ' (' + @email + ')';
        FETCH NEXT FROM VencidosCursor INTO @nombre, @apellido, @email;
    END

    CLOSE VencidosCursor;
    DEALLOCATE VencidosCursor;
END
GO


-- 6.
DROP PROCEDURE IF EXISTS sp_ListarCursosCantidadInscriptos;
GO

CREATE PROCEDURE sp_ListarCursosCantidadInscriptos
AS
BEGIN
    DECLARE @curso VARCHAR(100), @cantidad INT;

    DECLARE CantidadCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT 
            C.nombre_curso,
            COUNT(I.id_estudiante) AS Cantidad
        FROM Curso C
        LEFT JOIN Inscripcion I ON C.id_curso = I.id_curso
        GROUP BY C.id_curso, C.nombre_curso
        ORDER BY Cantidad DESC;

    OPEN CantidadCursor;
    FETCH NEXT FROM CantidadCursor INTO @curso, @cantidad;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @curso + ': ' + CAST(@cantidad AS VARCHAR(10)) + ' inscriptos';
        FETCH NEXT FROM CantidadCursor INTO @curso, @cantidad;
    END

    CLOSE CantidadCursor;
    DEALLOCATE CantidadCursor;
END
GO


-- 7.
DROP PROCEDURE IF EXISTS sp_ListarFacturasPorEstado;
GO

CREATE PROCEDURE sp_ListarFacturasPorEstado
AS
BEGIN
    DECLARE @estado VARCHAR(50), @cantidad INT, @total DECIMAL(10, 2);

    DECLARE FacturaCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT 
            estado_pago,
            COUNT(*) AS CantidadFacturas,
            SUM(monto_total) AS SumaTotal
        FROM Factura
        GROUP BY estado_pago;

    OPEN FacturaCursor;
    FETCH NEXT FROM FacturaCursor INTO @estado, @cantidad, @total;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Estado: ' + @estado + ' | Cantidad: ' + CAST(@cantidad AS VARCHAR(10)) + ' | Monto Total: ' + CAST(@total AS VARCHAR(20));
        FETCH NEXT FROM FacturaCursor INTO @estado, @cantidad, @total;
    END

    CLOSE FacturaCursor;
    DEALLOCATE FacturaCursor;
END
GO


-- 8.
DROP PROCEDURE IF EXISTS sp_ListarInteresesPorAnioCarrera;
GO

CREATE PROCEDURE sp_ListarInteresesPorAnioCarrera
AS
BEGIN
    DECLARE @anio INT, @porcentaje DECIMAL(5, 2);

    DECLARE InteresCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT 
            anio_carrera,
            porcentaje_interes
        FROM [Interes por Mora]
        ORDER BY anio_carrera;

    OPEN InteresCursor;
    FETCH NEXT FROM InteresCursor INTO @anio, @porcentaje;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Anio de Carrera: ' + CAST(@anio AS VARCHAR(5)) + ' | Porcentaje: ' + CAST(@porcentaje AS VARCHAR(10)) + '%';
        FETCH NEXT FROM InteresCursor INTO @anio, @porcentaje;
    END

    CLOSE InteresCursor;
    DEALLOCATE InteresCursor;
END
GO


-- 9.
DROP PROCEDURE IF EXISTS sp_ListarCursosConMasInscripciones;
GO

CREATE PROCEDURE sp_ListarCursosConMasInscripciones
AS
BEGIN
    DECLARE @curso VARCHAR(100), @cantidad INT;

    DECLARE TopCursosCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT TOP 5
            C.nombre_curso,
            COUNT(I.id_estudiante) AS Cantidad
        FROM Curso C
        JOIN Inscripcion I ON C.id_curso = I.id_curso
        GROUP BY C.id_curso, C.nombre_curso
        ORDER BY Cantidad DESC;

    OPEN TopCursosCursor;
    FETCH NEXT FROM TopCursosCursor INTO @curso, @cantidad;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @curso + ': ' + CAST(@cantidad AS VARCHAR(10)) + ' inscriptos';
        FETCH NEXT FROM TopCursosCursor INTO @curso, @cantidad;
    END

    CLOSE TopCursosCursor;
    DEALLOCATE TopCursosCursor;
END
GO


-- 10.
DROP PROCEDURE IF EXISTS sp_ListarEstudiantesSinMatricula;
GO

CREATE PROCEDURE sp_ListarEstudiantesSinMatricula
AS
BEGIN
    DECLARE @nombre VARCHAR(100), @apellido VARCHAR(100), @email VARCHAR(100);
    DECLARE @anio_actual INT = YEAR(GETDATE());

    DECLARE SinMatriculaCursor CURSOR LOCAL FORWARD_ONLY FOR
        SELECT 
            E.nombre,
            E.apellido,
            E.email
        FROM Estudiante E
        WHERE E.estado_baja = 0
          AND NOT EXISTS (
            SELECT 1 
            FROM Matriculacion M 
            WHERE M.id_estudiante = E.id_estudiante
              AND M.anio = @anio_actual
          );

    OPEN SinMatriculaCursor;
    FETCH NEXT FROM SinMatriculaCursor INTO @nombre, @apellido, @email;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @apellido + ', ' + @nombre + ' (' + @email + ')';
        FETCH NEXT FROM SinMatriculaCursor INTO @nombre, @apellido, @email;
    END

    CLOSE SinMatriculaCursor;
    DEALLOCATE SinMatriculaCursor;
END
GO