USE [Gestion Academica];
GO
PRINT '1. Pruebas de carga de datos';

UPDATE Materia SET costo_curso_mensual = 2000 WHERE id_materia = 11; -- Ing. Datos
UPDATE Materia SET costo_curso_mensual = 1500 WHERE id_materia = 12; -- Progra 1
UPDATE Materia SET costo_curso_mensual = 1800 WHERE id_materia = 13; -- Ing. Software
GO

EXEC sp_CargarEstudiante 
    @id_estudiante = 999, 
    @nombre = 'Nicolas', 
    @apellido = 'Cieplak', 
    @email = 'test@test.com', 
    @anio_ingreso = 2024;

EXEC sp_CargarProfesor 
    @id_profesor = 999, 
    @nombre = 'Claudio', 
    @apellido = 'Godio', 
    @especialidad = 'Testing';

EXEC sp_CargarMateria 
    @id_materia = 999, 
    @nombre_materia = 'Testing 101', 
    @creditos = 4, 
    @costo_curso_mensual = 1000.00;

EXEC sp_CargarCuatrimestre 
    @id_cuatrimestre = 999, 
    @nombre = 'Cuatrimestre 1 2025', 
    @fecha_inicio = '2025-01-01', 
    @fecha_fin = '2025-12-31';

EXEC sp_CargarCurso 
    @id_curso = 999, 
    @nombre_curso = 'Curso de Testing', 
    @descripcion = 'Prueba de la BD', 
    @anio = 2025, 
    @id_profesor = 999, 
    @id_materia = 999;

EXEC sp_CargarInteresPorMora @anio_carrera = 1, @porcentaje_interes = 5.0;
EXEC sp_CargarInteresPorMora @anio_carrera = 1, @porcentaje_interes = 7.5;

PRINT 'Verificando datos cargados';
SELECT * FROM Estudiante WHERE id_estudiante = 999;
SELECT * FROM Materia WHERE id_materia = 999;
SELECT * FROM Curso WHERE id_curso = 999;
SELECT * FROM [Interes por Mora] WHERE anio_carrera = 1;
GO


PRINT '2. Prueba sp_MatricularAlumno';
EXEC sp_MatricularAlumno 
    @id_estudiante = 999, 
    @anio = 2025, 
    @monto_matricula = 15000;

PRINT 'Verificando Matriculacion, Factura y CC';
SELECT * FROM Matriculacion WHERE id_estudiante = 999;
SELECT * FROM Factura WHERE id_estudiante = 999 AND monto_total = 15000;
SELECT * FROM [Cuenta Corriente] WHERE id_estudiante = 999 AND monto = 15000;

PRINT 'Probando validacion de matrícula duplicada (tiene que fallar)';
EXEC sp_MatricularAlumno 
    @id_estudiante = 999, 
    @anio = 2025, 
    @monto_matricula = 15000;
GO

PRINT '3. Prueba sp_InscribirAlumnoCurso';

EXEC sp_InscribirAlumnoCurso 
    @id_estudiante = 999, 
    @id_curso = 999;

PRINT 'Verificando Inscripcion';
SELECT * FROM Inscripcion WHERE id_estudiante = 999 AND id_curso = 999;

PRINT 'Probando validacion de inscripcion duplicada';
EXEC sp_InscribirAlumnoCurso 
    @id_estudiante = 999, 
    @id_curso = 999;
GO


PRINT '6. Prueba sp_CargarNota';

EXEC sp_CargarNota @id_estudiante = 999, @id_curso = 999, @tipo_examen = 'nota_teorica', @nota = 3;
EXEC sp_CargarNota @id_estudiante = 999, @id_curso = 999, @tipo_examen = 'nota_teorica_2', @nota = 7;
EXEC sp_CargarNota @id_estudiante = 999, @id_curso = 999, @tipo_examen = 'nota_practica_1', @nota = 8;
EXEC sp_CargarNota @id_estudiante = 999, @id_curso = 999, @tipo_examen = 'nota_teorica_recuperatorio', @nota = 6;

EXEC sp_CargarNota @id_estudiante = 999, @id_curso = 999, @tipo_examen = 'nota_teorica_2', @nota = 2;
EXEC sp_CargarNota @id_estudiante = 999, @id_curso = 999, @tipo_examen = 'nota_teorica_recuperatorio', @nota = 6;
GO

PRINT '5. Prueba sp_GenerarCuotaAlumno';
EXEC sp_GenerarCuotaAlumno @id_estudiante = 999, @mes = 11, @anio = 2025;

PRINT 'Verificando Cuota, Factura y CC';
SELECT * FROM Cuota WHERE id_estudiante = 999 AND mes = 11;
SELECT * FROM [Cuenta Corriente] WHERE id_estudiante = 999 AND monto = 1000;
GO

PRINT '6. Prueba sp_RegistrarPago';
DECLARE @id_cuota_prueba INT;
SELECT @id_cuota_prueba = id_cuota FROM Cuota WHERE id_estudiante = 999 AND mes = 11;

EXEC sp_RegistrarPago @id_cuota = @id_cuota_prueba, @id_estudiante = 999;

PRINT 'Verificando estado de cuota';
SELECT * FROM Cuota WHERE id_cuota = @id_cuota_prueba;
PRINT 'Verificando CC';
SELECT * FROM [Cuenta Corriente] WHERE id_estudiante = 999 AND monto = -1000;
GO


PRINT '7. Pruebas sp_BajaEstudiante y sp_AltaEstudiante';
EXEC sp_BajaEstudiante @id_estudiante = 999;
SELECT id_estudiante, nombre, estado_baja FROM Estudiante WHERE id_estudiante = 999;

PRINT 'Saldando deuda del alumno 999';
INSERT INTO [Cuenta Corriente] (id_estudiante, fecha, concepto, monto, estado)
VALUES (999, GETDATE(), 'Pago saldo matricula', -15000, 'aplicado');

SELECT SUM(monto) AS Saldo FROM [Cuenta Corriente] WHERE id_estudiante = 999;

EXEC sp_BajaEstudiante @id_estudiante = 999;
SELECT id_estudiante, nombre, estado_baja FROM Estudiante WHERE id_estudiante = 999;

EXEC sp_AltaEstudiante @id_estudiante = 999;
SELECT id_estudiante, nombre, estado_baja FROM Estudiante WHERE id_estudiante = 999;
GO


PRINT '8. Pruebas de procesos generales';
PRINT 'Probando sp_GenerarCuotasMensuales (para alumnos 101, 102, 103)';
EXEC sp_GenerarCuotasMensuales;
PRINT 'Verificando cuotas generadas';
SELECT * FROM Cuota WHERE mes = 11 AND id_estudiante IN (101, 102, 103);
GO

PRINT 'Probando sp_CalcularInteresesPorMora';
INSERT INTO Cuota (id_estudiante, id_cuatrimestre, mes, monto, fecha_vencimiento, estado_pago)
VALUES (101, 999, 9, 2000, '2025-09-11', 'Pendiente');
INSERT INTO Cuota (id_estudiante, id_cuatrimestre, mes, monto, fecha_vencimiento, estado_pago)
VALUES (101, 999, 10, 2000, '2025-10-11', 'Pendiente');
GO

EXEC sp_CalcularInteresesPorMora;
GO

PRINT 'Verificando cargo por interes en CC';
SELECT * FROM [Cuenta Corriente] WHERE id_estudiante = 101 AND concepto = 'Interes por mora' AND monto = 300;
GO