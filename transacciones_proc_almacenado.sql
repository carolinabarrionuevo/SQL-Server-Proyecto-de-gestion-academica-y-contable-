USE [Gestion Academica];
GO

ALTER PROCEDURE sp_MatricularAlumno
    @id_estudiante INT,
    @anio INT,
    @monto_matricula DECIMAL(10, 2)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Matriculacion WHERE id_estudiante = @id_estudiante AND anio = @anio)
    BEGIN
        RAISERROR ('el alumno ya se encuentra matriculado en ese anio.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY       
        INSERT INTO Matriculacion (id_estudiante, anio, fecha_pago, monto, estado_pago)
        VALUES (@id_estudiante, @anio, GETDATE(), @monto_matricula, 'pendiente');      
        INSERT INTO Factura (id_estudiante, mes, anio, fecha_emision, fecha_vencimiento, monto_total, estado_pago)
        VALUES (@id_estudiante, MONTH(GETDATE()), @anio, GETDATE(), DATEADD(day, 10, GETDATE()), @monto_matricula, 'pendiente');        
        COMMIT TRANSACTION;       
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;       
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al matricular: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO


ALTER PROCEDURE sp_InscribirAlumnoCurso
    @id_estudiante INT,
    @id_curso INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY

        DECLARE @vacantes INT;
        SET @vacantes = dbo.fn_ObtenerVacantesCurso(@id_curso);

        IF (@vacantes <= 0)
        BEGIN
            RAISERROR ('No hay vacantes disponibles para este curso', 16, 1);
            ROLLBACK TRANSACTION; 
            RETURN;
        END

        INSERT INTO Inscripcion (id_estudiante, id_curso, fecha_inscripcion)
        VALUES (@id_estudiante, @id_curso, GETDATE());

        DECLARE @id_factura_actual INT;
        SELECT TOP 1 @id_factura_actual = id_factura
        FROM Factura
        WHERE 
            id_estudiante = @id_estudiante
            AND estado_pago = 'pendiente'
            AND MONTH(fecha_emision) = MONTH(GETDATE())
            AND YEAR(fecha_emision) = YEAR(GETDATE())
        ORDER BY fecha_emision DESC;

        IF (@id_factura_actual IS NOT NULL)
        BEGIN
            INSERT INTO ItemFactura (id_factura, id_curso)
            VALUES (@id_factura_actual, @id_curso);
        END
        ELSE
        BEGIN
            PRINT 'Inscripcion registrada. No se encontro factura pendiente para asociar el item';
        END

        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al inscribir: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO


ALTER PROCEDURE sp_RegistrarPago
    @id_cuota INT,
    @id_estudiante INT
AS
BEGIN
    DECLARE @monto_cuota DECIMAL(10, 2);
    SELECT @monto_cuota = monto FROM Cuota WHERE id_cuota = @id_cuota;

    IF (@monto_cuota IS NULL)
    BEGIN
        RAISERROR ('La cuota especificada no existe', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        
        UPDATE Cuota
        SET estado_pago = 'pagado'
        WHERE id_cuota = @id_cuota;
        
        INSERT INTO [Cuenta Corriente] (id_estudiante, fecha, concepto, monto, estado)
        VALUES (@id_estudiante, GETDATE(), 'pago cuota ID: ' + CAST(@id_cuota AS VARCHAR), @monto_cuota * -1, 'aplicado');
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al registrar el pago: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO


ALTER PROCEDURE sp_GenerarCuotasMensuales
AS
BEGIN
    DECLARE @mes_actual INT = MONTH(GETDATE());
    DECLARE @anio_actual INT = YEAR(GETDATE());
    DECLARE @id_cuatrimestre_actual INT;
    
    SELECT @id_cuatrimestre_actual = id_cuatrimestre 
    FROM Cuatrimestre
    WHERE GETDATE() BETWEEN fecha_inicio AND fecha_fin;

    IF (@id_cuatrimestre_actual IS NULL)
    BEGIN
        RAISERROR ('No hay un cuatrimestre activo configurado para la fecha actual', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY

        INSERT INTO Factura (id_estudiante, mes, anio, fecha_emision, fecha_vencimiento, monto_total, estado_pago)
        SELECT 
            E.id_estudiante,
            @mes_actual,
            @anio_actual,
            GETDATE(),
            DATEADD(day, 10, GETDATE()),
            0,
            'pendiente'
        FROM Estudiante E
        WHERE E.estado_baja = 0;

        INSERT INTO Cuota (id_estudiante, id_cuatrimestre, id_factura, mes, monto, fecha_vencimiento, estado_pago)
        SELECT
            F.id_estudiante,
            @id_cuatrimestre_actual,
            F.id_factura,
            @mes_actual,
            ISNULL(SUM(M.costo_curso_mensual), 0) AS MontoTotal,
            F.fecha_vencimiento,
            'pendiente'
        FROM Factura F
        LEFT JOIN Inscripcion I ON F.id_estudiante = I.id_estudiante
        LEFT JOIN Curso C ON I.id_curso = C.id_curso AND C.anio = @anio_actual
        LEFT JOIN Materia M ON C.id_materia = M.id_materia
        WHERE 
            F.mes = @mes_actual 
            AND F.anio = @anio_actual
        GROUP BY 
            F.id_estudiante, F.id_factura, F.fecha_vencimiento;

        UPDATE F
        SET F.monto_total = C.MontoTotal
        FROM Factura F
        JOIN (
            SELECT id_factura, SUM(monto) AS MontoTotal 
            FROM Cuota 
            WHERE mes = @mes_actual AND id_cuatrimestre = @id_cuatrimestre_actual
            GROUP BY id_factura
        ) AS C ON F.id_factura = C.id_factura
        WHERE F.mes = @mes_actual AND F.anio = @anio_actual;
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al generar cuotas mensuales: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO


ALTER PROCEDURE sp_BajaEstudiante
    @id_estudiante INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        
        DECLARE @saldo DECIMAL(10, 2);
        SET @saldo = dbo.fn_ObtenerSaldoCC(@id_estudiante);

        IF (@saldo != 0)
        BEGIN
            DECLARE @saldo_str VARCHAR(20) = CAST(@saldo AS VARCHAR(20));
            RAISERROR ('No se puede dar de baja. El alumno tiene un saldo pendiente de $%s', 16, 1, @saldo_str);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        UPDATE Estudiante
        SET estado_baja = 1
        WHERE id_estudiante = @id_estudiante;
        
        COMMIT TRANSACTION;
        PRINT 'Alumno dado de baja';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al dar de baja: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO


ALTER PROCEDURE sp_CargarNota
    @id_estudiante INT,
    @id_curso INT,
    @tipo_examen VARCHAR(50),
    @nota DECIMAL(4, 2)
AS
BEGIN
    IF @tipo_examen NOT IN ('nota_teorica_1', 'nota_teorica_2', 'nota_practica', 'nota_teorica_recuperatorio')
    BEGIN
        RAISERROR ('El tipo de examen no es valido', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        
        IF @tipo_examen = 'nota_teorica_recuperatorio'
        BEGIN
            DECLARE @n1 DECIMAL(4, 2), @n2 DECIMAL(4, 2), @np DECIMAL(4, 2);
            SELECT 
                @n1 = nota_teorica_1, 
                @n2 = nota_teorica_2, 
                @np = nota_practica 
            FROM Inscripcion 
            WHERE id_estudiante = @id_estudiante AND id_curso = @id_curso;

            DECLARE @desaprobados INT = 0;
            IF @n1 < 4 SET @desaprobados = @desaprobados + 1;
            IF @n2 < 4 SET @desaprobados = @desaprobados + 1;
            IF @np < 4 SET @desaprobados = @desaprobados + 1;

            IF @desaprobados = 0
            BEGIN
                RAISERROR ('No puede rendir recuperatorio si no desaprobo instancias previas', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
            IF @desaprobados > 1
            BEGIN
                RAISERROR ('No puede rendir recuperatorio, desaprobo mas de una instancia', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END
        
        DECLARE @sql NVARCHAR(MAX);
        SET @sql = 'UPDATE Inscripcion SET ' + @tipo_examen + ' = @nota_param 
                    WHERE id_estudiante = @id_est_param AND id_curso = @id_curso_param';
        
        EXEC sp_executesql @sql, 
            N'@nota_param DECIMAL(4, 2), @id_est_param INT, @id_curso_param INT', 
            @nota, @id_estudiante, @id_curso;

        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al cargar la nota: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO


ALTER PROCEDURE sp_CalcularInteresesPorMora
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        
        INSERT INTO [Cuenta Corriente] (id_estudiante, fecha, concepto, monto, estado)
        SELECT 
            DISTINCT C.id_estudiante,
            GETDATE(),
            'Interes por mora',
            (C.monto * IM.porcentaje_interes) / 100, 
            'Pendiente'
        FROM Cuota C
        JOIN Estudiante E ON C.id_estudiante = E.id_estudiante
        JOIN [Interes por Mora] IM ON E.anio_ingreso = IM.anio_carrera
        WHERE 
            C.fecha_vencimiento < GETDATE()
            AND C.estado_pago = 'Pendiente'
            AND NOT EXISTS (
                SELECT 1 FROM [Cuenta Corriente] CC
                WHERE CC.id_estudiante = C.id_estudiante
                AND CC.concepto = 'Interes por mora'
                AND MONTH(CC.fecha) = MONTH(GETDATE())
            );
        
        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al calcular intereses: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO


ALTER PROCEDURE sp_FacturarCuotasVencidasSinFactura
    @id_estudiante INT
AS
BEGIN
    DECLARE @mes_actual INT = MONTH(GETDATE());
    DECLARE @anio_actual INT = YEAR(GETDATE());

    BEGIN TRANSACTION;
    BEGIN TRY
        
        INSERT INTO Factura (id_estudiante, mes, anio, fecha_emision, fecha_vencimiento, monto_total, estado_pago)
        VALUES (@id_estudiante, @mes_actual, @anio_actual, GETDATE(), DATEADD(day, 10, GETDATE()), 0, 'Pendiente');
        
        DECLARE @id_factura_nueva INT = SCOPE_IDENTITY();
        
        UPDATE Cuota
        SET id_factura = @id_factura_nueva
        WHERE 
            id_estudiante = @id_estudiante
            AND id_factura IS NULL
            AND fecha_vencimiento < GETDATE()
            AND estado_pago = 'Pendiente';
            
        UPDATE Factura
        SET monto_total = (
            SELECT SUM(monto) 
            FROM Cuota 
            WHERE id_factura = @id_factura_nueva
        )
        WHERE id_factura = @id_factura_nueva;

        COMMIT TRANSACTION;
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al facturar vencidas: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO


ALTER PROCEDURE sp_AltaEstudiante
    @id_estudiante INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        
        UPDATE Estudiante
        SET estado_baja = 0
        WHERE id_estudiante = @id_estudiante;
        
        COMMIT TRANSACTION;
        PRINT 'Alumno dado de alta exitosamente.';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR ('Error al dar de alta: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO