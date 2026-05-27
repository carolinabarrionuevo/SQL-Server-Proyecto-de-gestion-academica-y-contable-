USE [Gestion Academica];
GO

DROP TRIGGER IF EXISTS tr_CalcularNotaFinalRecuperatorio;
GO

CREATE TRIGGER tr_CalcularNotaFinalRecuperatorio
ON Inscripcion
AFTER UPDATE
AS
BEGIN
    IF (UPDATE(nota_teorica_recuperatorio))
    BEGIN
        UPDATE i
        SET 
            i.nota_final = ins.nota_teorica_recuperatorio
        FROM 
            Inscripcion i
        JOIN 
            inserted ins ON i.id_estudiante = ins.id_estudiante AND i.id_curso = ins.id_curso
        WHERE 
            ins.nota_teorica_recuperatorio IS NOT NULL;
    END
END
GO


DROP TRIGGER IF EXISTS tr_ActualizarBajaPorBorrado;
GO

CREATE TRIGGER tr_ActualizarBajaPorBorrado
ON Inscripcion
AFTER DELETE
AS
BEGIN
    UPDATE Estudiante
    SET estado_baja = 1
    WHERE id_estudiante IN (SELECT id_estudiante FROM deleted)
    AND NOT EXISTS (
        SELECT 1 
        FROM Inscripcion i 
        WHERE i.id_estudiante = Estudiante.id_estudiante
    );
END
GO


DROP TRIGGER IF EXISTS tr_ValidarInscripcion;
GO

CREATE TRIGGER tr_ValidarInscripcion
ON Inscripcion
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Estudiante e
        JOIN inserted i ON e.id_estudiante = i.id_estudiante
        WHERE e.estado_baja = 1
    )
    BEGIN
        RAISERROR ('Error: Uno o mas estudiantes estan dados de baja', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM Inscripcion i_existente
        JOIN Curso c_existente ON i_existente.id_curso = c_existente.id_curso
        JOIN inserted i_nueva ON i_existente.id_estudiante = i_nueva.id_estudiante
        JOIN Curso c_nuevo ON i_nueva.id_curso = c_nuevo.id_curso
        WHERE c_existente.id_materia = c_nuevo.id_materia -- Misma Materia
          AND c_existente.anio = c_nuevo.anio -- Mismo Año
    )
    BEGIN
        RAISERROR ('Error: Uno o mas estudiantes ya estan inscriptos en esta materia para este año', 16, 1);
        RETURN;
    END

    INSERT INTO Inscripcion (
        id_estudiante, id_curso, fecha_inscripcion, 
        nota_teorica_1, nota_teorica_2, nota_practica, 
        nota_teorica_recuperatorio, nota_final
    )
    SELECT 
        id_estudiante, id_curso, fecha_inscripcion, 
        nota_teorica_1, nota_teorica_2, nota_practica, 
        nota_teorica_recuperatorio, nota_final
    FROM inserted;
END
GO


DROP TRIGGER IF EXISTS tr_ActualizarEstadoFactura;
GO

CREATE TRIGGER tr_ActualizarEstadoFactura
ON Cuota
AFTER UPDATE
AS
BEGIN
    IF (UPDATE(estado_pago))
    BEGIN
        UPDATE Factura
        SET estado_pago = 'pagado'
        FROM Factura f
        WHERE f.id_factura IN (SELECT id_factura FROM inserted)
        AND NOT EXISTS (
            SELECT 1 
            FROM Cuota c 
            WHERE c.id_factura = f.id_factura 
            AND c.estado_pago = 'pendiente'
        );
    END
END
GO


DROP TRIGGER IF EXISTS tr_ActualizarMontoTotalFactura;
GO

CREATE TRIGGER tr_ActualizarMontoTotalFactura
ON ItemFactura
AFTER INSERT
AS
BEGIN
    UPDATE f
    SET f.monto_total = ISNULL(f.monto_total, 0) + CostosAgregados.TotalCosto
    FROM Factura f
    JOIN (
        SELECT 
            i.id_factura, 
            SUM(m.costo_curso_mensual) AS TotalCosto
        FROM inserted i
        JOIN Curso c ON i.id_curso = c.id_curso
        JOIN Materia m ON c.id_materia = m.id_materia
        GROUP BY i.id_factura
    ) AS CostosAgregados ON f.id_factura = CostosAgregados.id_factura;
END
GO