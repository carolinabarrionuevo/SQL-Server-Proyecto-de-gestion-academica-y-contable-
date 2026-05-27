USE [Gestion Academica];
GO

PRINT 'Cursos del alumno 101 (deberia mostrar 3 cursos)';
SELECT * FROM dbo.fn_ListarCursosEstudiante(101);
GO

PRINT 'Cursos del alumno 999 deberia mostrar Testing 101';
SELECT * FROM dbo.fn_ListarCursosEstudiante(999);
GO

PRINT 'Cuotas impagas alumno 101 deberia mostrar 3 cuotas pendientes';
SELECT * FROM dbo.fn_ObtenerCuotasImpagas(101);
GO

PRINT 'Cuotas impagas alumno 999 deberia estar vacia';
SELECT * FROM dbo.fn_ObtenerCuotasImpagas(999);
GO

PRINT 'Profesores del cuatrimestre 999 deberia mostrar 4 profesores';
SELECT * FROM dbo.fn_ListarProfesoresPorCuatrimestre(999);
GO

PRINT 'Materias con mas de 3 cursos activos debería estar vacia';
SELECT * FROM dbo.fn_ListarMateriasConCursosActivos();
GO

PRINT 'Matriculas activas para 2025 deberia mostrar al alumno 999';
SELECT * FROM dbo.fn_ListarMatriculasActivas(2025);
GO

PRINT 'Facturas de nov 2025 deberia mostrar 4 facturas';
SELECT * FROM dbo.fn_ObtenerFacturasPorMes(11, 2025);
GO

PRINT 'Cursos con mas de 30 inscriptos deberia estar vacia';
SELECT * FROM dbo.fn_ListarCursosPopulosos();
GO

PRINT 'Movimientos CC alumno 999 deberia mostrar 4 movimientos';
SELECT * FROM dbo.fn_ObtenerMovimientosCC(999)
ORDER BY fecha;
GO

PRINT 'Cursos del profesor 1 en 2025, deberia mostrar 1';
SELECT * FROM dbo.fn_ListarCursosProfesorPorAnio(1, 2025);
GO

PRINT 'Inscripciones con nota final > 8';
UPDATE Inscripcion SET nota_final = 9.50 WHERE id_estudiante = 101 AND id_curso = 1001;
UPDATE Inscripcion SET nota_final = 10.00 WHERE id_estudiante = 102 AND id_curso = 1003;
SELECT * FROM dbo.fn_ListarInscripcionesSobresalientes();
GO