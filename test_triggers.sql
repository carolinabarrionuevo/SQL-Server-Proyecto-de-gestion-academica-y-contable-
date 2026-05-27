USE [Gestion Academica];
GO

-- 1.
SET IDENTITY_INSERT Factura ON;
SET IDENTITY_INSERT Cuota ON;

BEGIN TRY
    INSERT INTO Estudiante (id_estudiante, nombre, apellido, email, anio_ingreso, estado_baja)
    VALUES (801, 'Estudiante', 'TriggerTest', 'trigger@test.com', 2025, 0);
    
    INSERT INTO Profesor (id_profesor, nombre, apellido, especialidad)
    VALUES (801, 'Profesor', 'TriggerTest', 'Triggers');
    
    INSERT INTO Materia (id_materia, nombre_materia, creditos, costo_curso_mensual)
    VALUES (801, 'Trigger Materia 1', 4, 100.00),
           (802, 'Trigger Materia 2', 4, 50.00);
           
    INSERT INTO Curso (id_curso, nombre_curso, anio, id_profesor, id_materia)
    VALUES (801, 'Curso T1', 2025, 801, 801),
           (802, 'Curso T2', 2025, 801, 802),
           (803, 'Curso T3 (Duplicado)', 2025, 801, 801);

    INSERT INTO Cuatrimestre (id_cuatrimestre, nombre, fecha_inicio, fecha_fin)
    VALUES (999, 'Cuatrimestre de Prueba', '2025-01-01', '2025-12-31');

    INSERT INTO Factura (id_factura, id_estudiante, mes, anio, monto_total, estado_pago)
    VALUES (801, 801, 1, 2025, 0, 'pendiente');
    
    INSERT INTO Cuota (id_cuota, id_estudiante, id_cuatrimestre, id_factura, mes, monto, estado_pago)
    VALUES (801, 801, 999, 801, 1, 100, 'pendiente'),
           (802, 801, 999, 801, 2, 100, 'pendiente');
           
    INSERT INTO Factura (id_factura, id_estudiante, mes, anio, monto_total, estado_pago)
    VALUES (802, 801, 2, 2025, 1000, 'pendiente');
END TRY
BEGIN CATCH
    PRINT 'Datos de prueba ya existían. Omitiendo inserts.';
END CATCH
SET IDENTITY_INSERT Factura OFF;
SET IDENTITY_INSERT Cuota OFF;
GO


-- 2.
PRINT 'tiene que fallar';
UPDATE Estudiante SET estado_baja = 1 WHERE id_estudiante = 801;
BEGIN TRY
    INSERT INTO Inscripcion (id_estudiante, id_curso, fecha_inscripcion) 
    VALUES (801, 802, GETDATE());
END TRY
BEGIN CATCH
    PRINT 'error correcto ' + ERROR_MESSAGE();
END CATCH
UPDATE Estudiante SET estado_baja = 0 WHERE id_estudiante = 801; -- Reset
GO

INSERT INTO Inscripcion (id_estudiante, id_curso, fecha_inscripcion) 
VALUES (801, 801, GETDATE());
SELECT * FROM Inscripcion WHERE id_estudiante = 801 AND id_curso = 801;
GO

BEGIN TRY
    INSERT INTO Inscripcion (id_estudiante, id_curso, fecha_inscripcion) 
    VALUES (801, 803, GETDATE());
END TRY
BEGIN CATCH
    PRINT 'error correcto ' + ERROR_MESSAGE();
END CATCH
GO


-- 3.
UPDATE Inscripcion 
SET nota_teorica_recuperatorio = 7.00
WHERE id_estudiante = 801 AND id_curso = 801;
SELECT nota_final FROM Inscripcion WHERE id_estudiante = 801 AND id_curso = 801;
GO


-- 4.
UPDATE Cuota SET estado_pago = 'pagado' WHERE id_cuota = 801;
SELECT estado_pago FROM Factura WHERE id_factura = 801;
UPDATE Cuota SET estado_pago = 'pagado' WHERE id_cuota = 802;
SELECT estado_pago FROM Factura WHERE id_factura = 801;
GO


-- 5.
INSERT INTO ItemFactura (id_factura, id_curso) VALUES (802, 801);
SELECT monto_total FROM Factura WHERE id_factura = 802;
INSERT INTO ItemFactura (id_factura, id_curso) VALUES (802, 802);
SELECT monto_total FROM Factura WHERE id_factura = 802;
GO


-- 6.
SELECT estado_baja FROM Estudiante WHERE id_estudiante = 801;
DELETE FROM Inscripcion WHERE id_estudiante = 801 AND id_curso = 801;
PRINT 'estado_baja tiene que ser 1';
SELECT estado_baja FROM Estudiante WHERE id_estudiante = 801;
GO

-- 7.
DELETE FROM ItemFactura WHERE id_factura IN (801, 802);
DELETE FROM Cuota WHERE id_cuota IN (801, 802);
DELETE FROM Factura WHERE id_factura IN (801, 802);
DELETE FROM Inscripcion WHERE id_estudiante = 801;
DELETE FROM Curso WHERE id_curso IN (801, 802, 803);
DELETE FROM Materia WHERE id_materia IN (801, 802);
DELETE FROM Estudiante WHERE id_estudiante = 801;
DELETE FROM Profesor WHERE id_profesor = 801;
DELETE FROM Cuatrimestre WHERE id_cuatrimestre = 999;
GO