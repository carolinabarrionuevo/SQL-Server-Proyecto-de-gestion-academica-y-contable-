USE [Gestion Academica];
GO

PRINT '-- 1.';
EXEC sp_ListarNotasFinalesEstudiantes;
GO

PRINT '-- 2.';
EXEC sp_ListarHistorialPagos;
GO

PRINT '-- 3.';
EXEC sp_ListarMateriaProfesorCurso;
GO

PRINT '-- 4.';
EXEC sp_ListarInscripcionesPorCuatrimestre;
GO

PRINT '-- 5.';
EXEC sp_ListarEstudiantesConCuotasVencidas;
GO

PRINT '-- 6.';
EXEC sp_ListarCursosCantidadInscriptos;
GO

PRINT '-- 7.';
EXEC sp_ListarFacturasPorEstado;
GO

PRINT '-- 8.';
EXEC sp_ListarInteresesPorAnioCarrera;
GO

PRINT '-- 9.';
EXEC sp_ListarCursosConMasInscripciones;
GO

PRINT '-- 10.';
EXEC sp_ListarEstudiantesSinMatricula;
GO