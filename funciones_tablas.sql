USE [Gestion Academica];
GO

DROP FUNCTION IF EXISTS dbo.fn_ListarCursosEstudiante;
GO

CREATE FUNCTION dbo.fn_ListarCursosEstudiante (
    @id_estudiante INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        c.id_curso,
        c.nombre_curso,
        c.descripcion,
        c.anio,
        m.nombre_materia
    FROM Inscripcion i
    JOIN Curso c ON i.id_curso = c.id_curso
    JOIN Materia m ON c.id_materia = m.id_materia
    WHERE i.id_estudiante = @id_estudiante
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ObtenerCuotasImpagas;
GO

CREATE FUNCTION dbo.fn_ObtenerCuotasImpagas (
    @id_estudiante INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        id_cuota,
        id_factura,
        mes,
        monto,
        fecha_vencimiento,
        estado_pago
    FROM Cuota
    WHERE id_estudiante = @id_estudiante
      AND estado_pago = 'pendiente'
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ListarProfesoresPorCuatrimestre;
GO

CREATE FUNCTION dbo.fn_ListarProfesoresPorCuatrimestre (
    @id_cuatrimestre INT
)
RETURNS TABLE
AS
RETURN (
    SELECT DISTINCT
        p.id_profesor,
        p.nombre,
        p.apellido,
        p.especialidad
    FROM Profesor p
    JOIN Curso c ON p.id_profesor = c.id_profesor
    JOIN Cuatrimestre cu ON c.anio = YEAR(cu.fecha_inicio)
    WHERE cu.id_cuatrimestre = @id_cuatrimestre
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ListarMateriasConCursosActivos;
GO

CREATE FUNCTION dbo.fn_ListarMateriasConCursosActivos ()
RETURNS TABLE
AS
RETURN (
    SELECT 
        m.id_materia,
        m.nombre_materia,
        COUNT(c.id_curso) AS CantidadCursosActivos
    FROM Materia m
    JOIN Curso c ON m.id_materia = c.id_materia
    WHERE c.anio = YEAR(GETDATE()) 
    GROUP BY m.id_materia, m.nombre_materia
    HAVING COUNT(c.id_curso) > 3
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ListarMatriculasActivas;
GO

CREATE FUNCTION dbo.fn_ListarMatriculasActivas (
    @anio INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        e.id_estudiante,
        e.nombre,
        e.apellido,
        e.email,
        m.estado_pago AS estado_matricula
    FROM Estudiante e
    JOIN Matriculacion m ON e.id_estudiante = m.id_estudiante
    WHERE m.anio = @anio
      AND m.estado_pago = 'pagado'
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ObtenerFacturasPorMes;
GO

CREATE FUNCTION dbo.fn_ObtenerFacturasPorMes (
    @mes INT,
    @anio INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        f.id_factura,
        f.id_estudiante,
        e.nombre,
        e.apellido,
        f.fecha_emision,
        f.monto_total,
        f.estado_pago
    FROM Factura f
    JOIN Estudiante e ON f.id_estudiante = e.id_estudiante
    WHERE f.mes = @mes AND f.anio = @anio
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ListarCursosPopulosos;
GO

CREATE FUNCTION dbo.fn_ListarCursosPopulosos ()
RETURNS TABLE
AS
RETURN (
    SELECT 
        c.id_curso,
        c.nombre_curso,
        m.nombre_materia,
        COUNT(i.id_estudiante) AS CantidadInscriptos
    FROM Curso c
    JOIN Materia m ON c.id_materia = m.id_materia 
    LEFT JOIN Inscripcion i ON c.id_curso = i.id_curso
    GROUP BY c.id_curso, c.nombre_curso, m.nombre_materia
    HAVING COUNT(i.id_estudiante) > 30
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ObtenerMovimientosCC;
GO

CREATE FUNCTION dbo.fn_ObtenerMovimientosCC (
    @id_estudiante INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        id_movimiento,
        fecha,
        concepto,
        monto,
        estado
    FROM [Cuenta Corriente]
    WHERE id_estudiante = @id_estudiante
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ListarCursosProfesorPorAnio;
GO

CREATE FUNCTION dbo.fn_ListarCursosProfesorPorAnio (
    @id_profesor INT,
    @anio INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        c.id_curso,
        c.nombre_curso,
        m.nombre_materia,
        c.descripcion
    FROM Curso c
    JOIN Materia m ON c.id_materia = m.id_materia
    WHERE c.id_profesor = @id_profesor
      AND c.anio = @anio
);
GO


DROP FUNCTION IF EXISTS dbo.fn_ListarInscripcionesSobresalientes;
GO

CREATE FUNCTION dbo.fn_ListarInscripcionesSobresalientes ()
RETURNS TABLE
AS
RETURN (
    SELECT 
        i.id_estudiante,
        e.nombre,
        e.apellido,
        i.id_curso,
        c.nombre_curso,
        i.nota_final
    FROM Inscripcion i
    JOIN Estudiante e ON i.id_estudiante = e.id_estudiante
    JOIN Curso c ON i.id_curso = c.id_curso
    WHERE i.nota_final > 8
);
GO