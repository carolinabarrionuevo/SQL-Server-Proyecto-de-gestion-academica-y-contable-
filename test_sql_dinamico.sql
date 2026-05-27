USE [Gestion Academica];
GO

-- 1.
EXEC sp_ListarEstudiantesDinamico @campo_busqueda = 'apellido', @valor_busqueda = 'Yand%';
GO
EXEC sp_ListarEstudiantesDinamico @campo_busqueda = 'email', @valor_busqueda = 'test@test.com';
GO


-- 2.
EXEC sp_ConsultarInscripcionesPorNota 
    @columna_nota = 'nota_final', 
    @operador = '>=', 
    @valor_nota = 9;
GO

EXEC sp_ConsultarInscripcionesPorNota 
    @columna_nota = 'nota_practica', 
    @operador = '<', 
    @valor_nota = 3;
GO

-- 3.
EXEC sp_ReporteCursosAgrupados 
    @limite_inscriptos = 0, 
    @campo_agrupacion = 'id_profesor';
GO

EXEC sp_ReporteCursosAgrupados 
    @limite_inscriptos = 2, 
    @campo_agrupacion = 'anio';
GO


-- 4.
EXEC sp_ReporteFacturasAgrupado @campo_agrupacion = 'estado_pago';
GO

EXEC sp_ReporteFacturasAgrupado @campo_agrupacion = 'mes';
GO


-- 5.
EXEC sp_ListarCuotasVencidasOrdenDinamico 
    @campo_orden = 'monto', 
    @direccion = 'DESC';
GO

EXEC sp_ListarCuotasVencidasOrdenDinamico 
    @campo_orden = 'fecha_vencimiento', 
    @direccion = 'ASC';
GO


-- 6.
EXEC sp_ListarCursosCondicionDinamica 
    @campo = 'creditos', 
    @operador = '>=', 
    @valor = '5';
GO

EXEC sp_ListarCursosCondicionDinamica 
    @campo = 'costo_curso_mensual', 
    @operador = '<', 
    @valor = '1600';
GO


-- 7.
EXEC sp_ListarProfesoresOrdenDinamico 
    @id_cuatrimestre = 701, 
    @campo_orden = 'especialidad', 
    @direccion = 'ASC';
GO


-- 8.
EXEC sp_ListarMovimientosCCConceptos 
    @id_estudiante = 706, 
    @conceptos_csv = 'Interes por mora,Pago de cuota';
GO


-- 9.
EXEC sp_ListarInscripcionesColumnasDinamicas @columnas = 'nota_final, nota_practica';
GO


-- 10.
UPDATE Estudiante SET anio_ingreso = 2023 WHERE id_estudiante IN (101, 102, 103);
GO

EXEC sp_ListarEstudiantesFiltroCombinado 
    @anio_ingreso = 2024, 
    @apellido_like = 'C%';
GO

EXEC sp_ListarEstudiantesFiltroCombinado 
    @anio_ingreso = NULL, 
    @apellido_like = 'H%';
GO

EXEC sp_ListarEstudiantesFiltroCombinado 
    @anio_ingreso = 2022, 
    @apellido_like = NULL;
GO