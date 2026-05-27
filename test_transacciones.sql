USE [Gestion Academica];
GO

BEGIN TRY
    INSERT INTO Estudiante (id_estudiante, nombre, apellido, email, anio_ingreso, estado_baja)
    VALUES (701, 'Estudiante', 'Transaccion', 't1@test.com', 2025, 0),
           (702, 'Estudiante', 'BajaDeuda', 't2@test.com', 2025, 0),
           (703, 'Estudiante', 'BajaOK', 't3@test.com', 2025, 0),
           (704, 'Estudiante', 'AltaTest', 't4@test.com', 2025, 1),
           (705, 'Estudiante', 'NotasTest', 't5@test.com', 2025, 0),
           (706, 'Estudiante', 'InteresTest', 't6@test.com', 2025, 0),
           (707, 'Estudiante', 'FacturaVencida', 't7@test.com', 2025, 0);

    INSERT INTO Profesor (id_profesor, nombre, apellido, especialidad) VALUES (701, 'Prof', 'Transaccion', 'Testing');
    INSERT INTO Materia (id_materia, nombre_materia, creditos, costo_curso_mensual) VALUES (701, 'Materia Transaccion', 4, 2500.00);
    INSERT INTO Curso (id_curso, nombre_curso, anio, id_profesor, id_materia) VALUES (701, 'Curso Transaccion', 2025, 701, 701);
    
    INSERT INTO [Interes por Mora] (anio_carrera, porcentaje_interes) VALUES (1, 10.0);
    INSERT INTO Cuatrimestre (id_cuatrimestre, nombre, fecha_inicio, fecha_fin) VALUES (701, 'Cuatrimestre 2025', '2025-01-01', '2025-12-31');
END TRY
BEGIN CATCH
    PRINT 'Datos de prueba ya existian';
END CATCH
GO

EXEC sp_MatricularAlumno @id_estudiante = 701, @anio = 2025, @monto_matricula = 10000;

SELECT * FROM Matriculacion WHERE id_estudiante = 701;
SELECT * FROM Factura WHERE id_estudiante = 701 AND monto_total = 10000;
SELECT * FROM [Cuenta Corriente] WHERE id_estudiante = 701 AND concepto LIKE 'Cargo por Factura%';

BEGIN TRY
    EXEC sp_MatricularAlumno @id_estudiante = 701, @anio = 2025, @monto_matricula = 10000;
END TRY
BEGIN CATCH
    PRINT 'fallo correcto : ' + ERROR_MESSAGE();
END CATCH
GO


DECLARE @id_factura_test INT;
INSERT INTO Factura (id_estudiante, mes, anio, fecha_emision, fecha_vencimiento, monto_total, estado_pago)
VALUES (701, MONTH(GETDATE()), YEAR(GETDATE()), GETDATE(), DATEADD(day, 10, GETDATE()), 0, 'pendiente');
SET @id_factura_test = SCOPE_IDENTITY();


EXEC sp_InscribirAlumnoCurso @id_estudiante = 701, @id_curso = 701;


SELECT * FROM Inscripcion WHERE id_estudiante = 701 AND id_curso = 701;
SELECT * FROM ItemFactura WHERE id_factura = @id_factura_test AND id_curso = 701;
GO


SET IDENTITY_INSERT Factura ON;
INSERT INTO Factura (id_factura, id_estudiante, mes, anio, monto_total, estado_pago) VALUES (702, 701, 10, 2025, 5000, 'pendiente');
SET IDENTITY_INSERT Factura OFF;

SET IDENTITY_INSERT Cuota ON;
INSERT INTO Cuota (id_cuota, id_estudiante, id_cuatrimestre, id_factura, mes, monto, estado_pago) VALUES (701, 701, 701, 702, 10, 5000, 'pendiente');
SET IDENTITY_INSERT Cuota OFF;

EXEC sp_RegistrarPago @id_cuota = 701, @id_estudiante = 701;


SELECT estado_pago FROM Cuota WHERE id_cuota = 701;
SELECT * FROM [Cuenta Corriente] WHERE concepto LIKE 'pago cuota ID: 701';
SELECT estado_pago FROM Factura WHERE id_factura = 702;
GO


EXEC sp_GenerarCuotasMensuales;


SELECT * FROM Cuota WHERE mes = MONTH(GETDATE()) AND id_estudiante IN (701, 702, 703, 705, 706, 707);
SELECT * FROM [Cuenta Corriente] WHERE concepto LIKE 'Cargo por Factura%' AND id_estudiante IN (701, 702, 703, 705, 706, 707) AND MONTH(fecha) = MONTH(GETDATE());
GO


INSERT INTO [Cuenta Corriente] (id_estudiante, concepto, monto, estado) VALUES (702, 'Deuda Test', 500.00, 'pendiente');
BEGIN TRY
    EXEC sp_BajaEstudiante @id_estudiante = 702;
END TRY
BEGIN CATCH
    PRINT 'fallo correcto : ' + ERROR_MESSAGE();
END CATCH

EXEC sp_BajaEstudiante @id_estudiante = 703;
SELECT * FROM Estudiante WHERE id_estudiante = 703 AND estado_baja = 1;
GO


INSERT INTO Inscripcion (id_estudiante, id_curso, fecha_inscripcion) VALUES (705, 701, GETDATE());

EXEC sp_CargarNota @id_estudiante = 705, @id_curso = 701, @tipo_examen = 'nota_teorica_1', @nota = 3;
EXEC sp_CargarNota @id_estudiante = 705, @id_curso = 701, @tipo_examen = 'nota_teorica_2', @nota = 8;
EXEC sp_CargarNota @id_estudiante = 705, @id_curso = 701, @tipo_examen = 'nota_practica', @nota = 8;
EXEC sp_CargarNota @id_estudiante = 705, @id_curso = 701, @tipo_examen = 'nota_teorica_recuperatorio', @nota = 6;
SELECT nota_teorica_recuperatorio FROM Inscripcion WHERE id_estudiante = 705 AND id_curso = 701;

EXEC sp_CargarNota @id_estudiante = 705, @id_curso = 701, @tipo_examen = 'nota_teorica_2', @nota = 2;
BEGIN TRY
    EXEC sp_CargarNota @id_estudiante = 705, @id_curso = 701, @tipo_examen = 'nota_teorica_recuperatorio', @nota = 7;
END TRY
BEGIN CATCH
    PRINT 'fallo correcto : ' + ERROR_MESSAGE();
END CATCH
GO

SET IDENTITY_INSERT Cuota ON;
INSERT INTO Cuota (id_cuota, id_estudiante, id_cuatrimestre, id_factura, mes, monto, fecha_vencimiento, estado_pago) 
VALUES (703, 706, 701, NULL, 9, 2000, DATEADD(day, -30, GETDATE()), 'pendiente');
SET IDENTITY_INSERT Cuota OFF;

EXEC sp_CalcularInteresesPorMora;
SELECT * FROM [Cuenta Corriente] WHERE id_estudiante = 706 AND concepto = 'Interes por mora';
GO

SET IDENTITY_INSERT Cuota ON;
INSERT INTO Cuota (id_cuota, id_estudiante, id_cuatrimestre, mes, monto, fecha_vencimiento, estado_pago, id_factura) 
VALUES (704, 707, 701, 9, 3000, DATEADD(day, -30, GETDATE()), 'pendiente', NULL);
SET IDENTITY_INSERT Cuota OFF;

EXEC sp_FacturarCuotasVencidasSinFactura @id_estudiante = 707;
SELECT * FROM Factura WHERE id_estudiante = 707 AND monto_total = 3000;
SELECT id_factura FROM Cuota WHERE id_cuota = 704;
GO

EXEC sp_AltaEstudiante @id_estudiante = 704;
SELECT * FROM Estudiante WHERE id_estudiante = 704 AND estado_baja = 0;
GO

DELETE FROM ItemFactura WHERE id_factura >= @id_factura_test OR id_curso = 701;
DELETE FROM Cuota WHERE id_cuota IN (701, 703, 704) OR id_estudiante IN (701, 702, 703, 705, 706, 707);
DELETE FROM Factura WHERE id_factura >= 702 OR id_factura = @id_factura_test OR id_estudiante IN (701, 702, 703, 705, 706, 707);
DELETE FROM Inscripcion WHERE id_estudiante IN (701, 705);
DELETE FROM Matriculacion WHERE id_estudiante = 701;
DELETE FROM [Cuenta Corriente] WHERE id_estudiante IN (701, 702, 703, 705, 706, 707);
DELETE FROM Curso WHERE id_curso = 701;
DELETE FROM Materia WHERE id_materia = 701;
DELETE FROM [Interes por Mora] WHERE anio_carrera = 1;
DELETE FROM Cuatrimestre WHERE id_cuatrimestre = 701;
DELETE FROM Estudiante WHERE id_estudiante IN (701, 702, 703, 704, 705, 706, 707);
DELETE FROM Profesor WHERE id_profesor = 701;
GO