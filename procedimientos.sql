USE [Gestion Academica];
GO

DROP PROCEDURE IF EXISTS sp_CargarEstudiante;
GO

CREATE PROCEDURE sp_CargarEstudiante
    @id_estudiante INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @email VARCHAR(100),
    @anio_ingreso INT
AS
BEGIN
    INSERT INTO Estudiante (
        id_estudiante,
        nombre,
        apellido,
        email,
        anio_ingreso
    )
    VALUES (
        @id_estudiante,
        @nombre,
        @apellido,
        @email,
        @anio_ingreso
    );
END
GO

DROP PROCEDURE IF EXISTS sp_CargarProfesor;
GO

CREATE PROCEDURE sp_CargarProfesor
    @id_profesor INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @especialidad VARCHAR(100)
AS
BEGIN
    INSERT INTO Profesor (
        id_profesor, 
        nombre, 
        apellido, 
        especialidad
    )
    VALUES (
        @id_profesor, 
        @nombre, 
        @apellido, 
        @especialidad
    );
END
GO

DROP PROCEDURE IF EXISTS sp_CargarMateria;
GO

CREATE PROCEDURE sp_CargarMateria
    @id_materia INT,
    @nombre_materia VARCHAR(100),
    @creditos INT,
    @costo_curso_mensual DECIMAL(10, 2)
AS
BEGIN
    INSERT INTO Materia (
        id_materia, 
        nombre_materia, 
        creditos, 
        costo_curso_mensual
    )
    VALUES (
        @id_materia, 
        @nombre_materia, 
        @creditos, 
        @costo_curso_mensual
    );
END
GO

DROP PROCEDURE IF EXISTS sp_CargarCurso;
GO

CREATE PROCEDURE sp_CargarCurso
    @id_curso INT,
    @nombre_curso VARCHAR(100),
    @descripcion TEXT,
    @anio INT,
    @id_profesor INT,
    @id_materia INT
AS
BEGIN
    INSERT INTO Curso (
        id_curso, 
        nombre_curso, 
        descripcion, 
        anio, 
        id_profesor, 
        id_materia
    )
    VALUES (
        @id_curso, 
        @nombre_curso, 
        @descripcion, 
        @anio, 
        @id_profesor, 
        @id_materia
    );
END
GO

DROP PROCEDURE IF EXISTS sp_CargarCuatrimestre;
GO

CREATE PROCEDURE sp_CargarCuatrimestre
    @id_cuatrimestre INT,
    @nombre VARCHAR(100),
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    INSERT INTO Cuatrimestre (
        id_cuatrimestre, 
        nombre, 
        fecha_inicio, 
        fecha_fin
    )
    VALUES (
        @id_cuatrimestre, 
        @nombre, 
        @fecha_inicio, 
        @fecha_fin
    );
END
GO

DROP PROCEDURE IF EXISTS sp_CargarInteresPorMora;
GO

CREATE PROCEDURE sp_CargarInteresPorMora
    @anio_carrera INT,
    @porcentaje_interes DECIMAL(5, 2)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM [Interes por Mora] WHERE anio_carrera = @anio_carrera)
    BEGIN
        UPDATE [Interes por Mora]
        SET porcentaje_interes = @porcentaje_interes
        WHERE anio_carrera = @anio_carrera;
    END
    ELSE
    BEGIN
        INSERT INTO [Interes por Mora] (
            anio_carrera, 
            porcentaje_interes
        )
        VALUES (
            @anio_carrera, 
            @porcentaje_interes
        );
    END
END
GO

DROP PROCEDURE IF EXISTS sp_BajaEstudiante;
GO

CREATE PROCEDURE sp_BajaEstudiante
    @id_estudiante INT
AS
BEGIN
    DECLARE @saldo_cc DECIMAL(10, 2);

    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante)
    BEGIN
        PRINT 'Error: El estudiante no existe';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante AND estado_baja = 1)
    BEGIN
        PRINT 'Error: El estudiante ya se encuentra dado de baja';
        RETURN;
    END

    SELECT @saldo_cc = ISNULL(SUM(monto), 0)
    FROM [Cuenta Corriente]
    WHERE id_estudiante = @id_estudiante;
    IF @saldo_cc = 0
    BEGIN
        UPDATE Estudiante
        SET estado_baja = 1
        WHERE id_estudiante = @id_estudiante;
        
        PRINT 'alumno dado de baja';
    END
    ELSE
    BEGIN
        PRINT 'Error: No se puede dar de baja. El alumno tiene un saldo pendiente de: ' + CAST(@saldo_cc AS VARCHAR(20));
    END
END
GO

DROP PROCEDURE IF EXISTS sp_AltaEstudiante;
GO

CREATE PROCEDURE sp_AltaEstudiante
    @id_estudiante INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante)
    BEGIN
        PRINT 'Error: El estudiante no existe';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante AND estado_baja = 0)
    BEGIN
        PRINT 'Error: El estudiante ya esta dado de alta';
        RETURN;
    END

    UPDATE Estudiante
    SET estado_baja = 0
    WHERE id_estudiante = @id_estudiante;
    F
    PRINT 'estudiante dado de alta';
END
GO

DROP PROCEDURE IF EXISTS sp_MatricularAlumno;
GO

CREATE PROCEDURE sp_MatricularAlumno
    @id_estudiante INT,
    @anio INT,
    @monto_matricula DECIMAL(10, 2)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante AND estado_baja = 0)
    BEGIN
        PRINT 'Error: El estudiante no existe';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Matriculacion WHERE id_estudiante = @id_estudiante AND anio = @anio)
    BEGIN
        PRINT 'Error: El estudiante ya esta matriculado para ese año';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        
        DECLARE @id_factura_nueva INT;
        DECLARE @fecha_actual DATE = GETDATE();

        INSERT INTO Matriculacion (
            id_estudiante, 
            anio, 
            fecha_pago,
            monto, 
            estado_pago
        )
        VALUES (
            @id_estudiante, 
            @anio,
            @fecha_actual,
            @monto_matricula,
            'pagado'
        );

        INSERT INTO Factura (
            id_estudiante, 
            mes, 
            anio, 
            fecha_emision, 
            fecha_vencimiento, 
            monto_total, 
            estado_pago
        )
        VALUES (
            @id_estudiante,
            MONTH(@fecha_actual),
            YEAR(@fecha_actual),
            @fecha_actual,
            DATEADD(day, 10, @fecha_actual),
            @monto_matricula,
            'pagado'
        );
        
        SET @id_factura_nueva = SCOPE_IDENTITY();
        INSERT INTO [Cuenta Corriente] (
            id_estudiante, 
            fecha, 
            concepto, 
            monto, 
            estado
        )
        VALUES (
            @id_estudiante,
            @fecha_actual,
            'Cargo por Matrícula ' + CAST(@anio AS VARCHAR(4)),
            @monto_matricula,
            'pagado'
        );

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
        PRINT 'Matriculación, factura y cargo en cuenta corriente generados';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error al matricular: ' + ERROR_MESSAGE();
    END CATCH
END
GO

DROP PROCEDURE IF EXISTS sp_InscribirAlumnoCurso;
GO

CREATE PROCEDURE sp_InscribirAlumnoCurso
    @id_estudiante INT,
    @id_curso INT
AS
BEGIN
    DECLARE @inscriptos INT;
    DECLARE @id_materia_curso INT;
    DECLARE @anio_curso INT;
    DECLARE @max_vacantes INT = 35;

    BEGIN TRANSACTION;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante AND estado_baja = 0)
        BEGIN
            RAISERROR('Error: El estudiante no existe', 16, 1);
        END

        IF NOT EXISTS (SELECT 1 FROM Curso WHERE id_curso = @id_curso)
        BEGIN
            RAISERROR('Error: El curso no existe', 16, 1);
        END

        SELECT @inscriptos = COUNT(*) 
        FROM Inscripcion 
        WHERE id_curso = @id_curso;
        IF @inscriptos >= @max_vacantes
        BEGIN
            RAISERROR('Error: El curso no tiene vacantes disponibles', 16, 1);
        END

        SELECT @id_materia_curso = id_materia, @anio_curso = anio 
        FROM Curso 
        WHERE id_curso = @id_curso;
        IF EXISTS (
            SELECT 1
            FROM Inscripcion i
            JOIN Curso c ON i.id_curso = c.id_curso
            WHERE i.id_estudiante = @id_estudiante
              AND c.id_materia = @id_materia_curso
              AND c.anio = @anio_curso
        )
        BEGIN
            RAISERROR('Error: El alumno ya esta inscripto en esta materia', 16, 1);
        END

        INSERT INTO Inscripcion (
            id_estudiante,
            id_curso,
            fecha_inscripcion,
            nota_teorica,
            nota_teorica_2,
            nota_practica_1,
            nota_teorica_recuperatorio,
            nota_final
        )
        VALUES (
            @id_estudiante,
            @id_curso,
            GETDATE(),
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
        );

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
            
        PRINT 'Alumno inscripto al curso exitosamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'Error al inscribir al alumno: ' + ERROR_MESSAGE();
    END CATCH
END
GO

DROP PROCEDURE IF EXISTS sp_CargarNota;
GO

CREATE PROCEDURE sp_CargarNota
    @id_estudiante INT,
    @id_curso INT,
    @tipo_examen VARCHAR(50),
    @nota DECIMAL(4, 2)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Inscripcion WHERE id_estudiante = @id_estudiante AND id_curso = @id_curso)
        BEGIN
            RAISERROR('Error: No existe una inscripcion para ese alumno y curso', 16, 1);
        END

        IF @tipo_examen NOT IN ('nota_teorica', 'nota_teorica_2', 'nota_practica_1', 'nota_teorica_recuperatorio')
        BEGIN
            PRINT('Error: tipo de examen no valido.');
        END

        IF @nota < 0 OR @nota > 10
        BEGIN
            PRINT('Error: La nota tiene que estar entre 0 y 10');
        END

        PRINT @tipo_examen

        IF @tipo_examen = 'nota_teorica_recuperatorio'
        BEGIN
            DECLARE @desaprobados INT = 0;
            DECLARE @nota_t1 DECIMAL(4, 2);
            DECLARE @nota_t2 DECIMAL(4, 2);
            DECLARE @nota_p DECIMAL(4, 2);
            --PRINT @desaprobados
            SELECT
                @nota_t1 = nota_teorica,
                @nota_t2 = nota_teorica_2,
                @nota_p = nota_practica_1
            FROM Inscripcion
            WHERE id_estudiante = @id_estudiante AND id_curso = @id_curso;
            PRINT @desaprobados
            IF ISNULL(@nota_t1, 10) < 4 SET @desaprobados = @desaprobados + 1;
            IF ISNULL(@nota_t2, 10) < 4 SET @desaprobados = @desaprobados + 1;
            IF ISNULL(@nota_p, 10) < 4 SET @desaprobados = @desaprobados + 1;
            
            IF @desaprobados != 1
            BEGIN
                PRINT('Error: Solo se puede cargar recuperatorio si solo una de las 3 instancias es menor a 4');
            END
        END
        
        IF @tipo_examen = 'nota_teorica'
            UPDATE Inscripcion SET nota_teorica = @nota
            WHERE id_estudiante = @id_estudiante AND id_curso = @id_curso;
        ELSE IF @tipo_examen = 'nota_teorica_2'
            UPDATE Inscripcion SET nota_teorica_2 = @nota
            WHERE id_estudiante = @id_estudiante AND id_curso = @id_curso;
        ELSE IF @tipo_examen = 'nota_practica_1'
            UPDATE Inscripcion SET nota_practica_1 = @nota
            WHERE id_estudiante = @id_estudiante AND id_curso = @id_curso;           
        ELSE IF @tipo_examen = 'nota_teorica_recuperatorio'
            UPDATE Inscripcion SET nota_teorica_recuperatorio = @nota
            WHERE id_estudiante = @id_estudiante AND id_curso = @id_curso;
        PRINT 'Nota cargada';

    END TRY
    BEGIN CATCH
        PRINT 'Error al cargar la nota: ';
    END CATCH
END
GO

DROP PROCEDURE IF EXISTS sp_GenerarCuotasMensuales;
GO

CREATE PROCEDURE sp_GenerarCuotasMensuales
AS
BEGIN
    DECLARE @id_estudiante_actual INT;
    DECLARE @monto_total_cuota DECIMAL(10, 2);
    DECLARE @id_factura_nueva INT;
    DECLARE @fecha_actual DATE = GETDATE();
    DECLARE @mes_actual INT = 12;
    DECLARE @anio_actual INT = YEAR(@fecha_actual);
    DECLARE @fecha_vencimiento DATE = DATEADD(day, 10, @fecha_actual);  
    DECLARE @id_cuatrimestre_actual INT;

    SELECT @id_cuatrimestre_actual = id_cuatrimestre 
    FROM Cuatrimestre 
    WHERE @fecha_actual BETWEEN fecha_inicio AND fecha_fin;
    IF @id_cuatrimestre_actual IS NULL
    BEGIN
        PRINT 'No hay un cuatrimestre activo en la fecha, no se generaron cuotas';
        RETURN;
    END
    
    DECLARE EstudiantesCursor CURSOR LOCAL FOR 
        SELECT id_estudiante 
        FROM Estudiante 
        WHERE estado_baja = 0;
    OPEN EstudiantesCursor;
    FETCH NEXT FROM EstudiantesCursor INTO @id_estudiante_actual;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            SELECT @monto_total_cuota = ISNULL(SUM(m.costo_curso_mensual), 0)
            FROM Inscripcion i
            JOIN Curso c ON i.id_curso = c.id_curso
            JOIN Materia m ON c.id_materia = m.id_materia
            WHERE i.id_estudiante = @id_estudiante_actual
              AND c.anio = @anio_actual;

            IF @monto_total_cuota > 0 AND NOT EXISTS (
                SELECT 1 FROM Cuota 
                WHERE id_estudiante = @id_estudiante_actual 
                  AND id_cuatrimestre = @id_cuatrimestre_actual 
                  AND mes = @mes_actual
            )
            BEGIN
                INSERT INTO Factura (id_estudiante, mes, anio, fecha_emision, fecha_vencimiento, monto_total, estado_pago)
                VALUES (@id_estudiante_actual, @mes_actual, @anio_actual, @fecha_actual, @fecha_vencimiento, @monto_total_cuota, 'pendiente');
                
                SET @id_factura_nueva = SCOPE_IDENTITY();

                INSERT INTO Cuota (id_estudiante, id_cuatrimestre, id_factura, mes, monto, fecha_vencimiento, estado_pago)
                VALUES (@id_estudiante_actual, @id_cuatrimestre_actual, @id_factura_nueva, @mes_actual, @monto_total_cuota, @fecha_vencimiento, 'pendiente');

                INSERT INTO [Cuenta Corriente] (id_estudiante, fecha, concepto, monto, estado)
                VALUES (@id_estudiante_actual, @fecha_actual, 'Cargo por Cuota ' + CAST(@mes_actual AS VARCHAR(2)) + '/' + CAST(@anio_actual AS VARCHAR(4)), @monto_total_cuota, 'pendiente');
            END
            
            IF @@TRANCOUNT > 0
                COMMIT TRANSACTION;

        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            
            PRINT 'Error con el estudiante ' + CAST(@id_estudiante_actual AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
        END CATCH
        FETCH NEXT FROM EstudiantesCursor INTO @id_estudiante_actual;
    END

    CLOSE EstudiantesCursor;
    DEALLOCATE EstudiantesCursor;
    
    PRINT 'cuotas generadas.';
END
GO

DROP PROCEDURE IF EXISTS sp_GenerarCuotaAlumno;
GO

CREATE PROCEDURE sp_GenerarCuotaAlumno
    @id_estudiante INT,
    @mes INT,
    @anio INT
AS
BEGIN
    DECLARE @monto_total_cuota DECIMAL(10, 2);
    DECLARE @id_factura_nueva INT;
    DECLARE @id_cuatrimestre_actual INT;
    DECLARE @fecha_emision DATE = DATEFROMPARTS(@anio, @mes, 1);
    DECLARE @fecha_vencimiento DATE = DATEADD(day, 10, @fecha_emision);

    IF NOT EXISTS (SELECT 1 FROM Estudiante WHERE id_estudiante = @id_estudiante AND estado_baja = 0)
    BEGIN
        PRINT 'Error: El estudiante no existe';
        RETURN;
    END

    SELECT @id_cuatrimestre_actual = id_cuatrimestre 
    FROM Cuatrimestre 
    WHERE @fecha_emision BETWEEN fecha_inicio AND fecha_fin;

    IF @id_cuatrimestre_actual IS NULL
    BEGIN
        PRINT 'Error: El mes y año no validos';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Cuota 
        WHERE id_estudiante = @id_estudiante 
          AND id_cuatrimestre = @id_cuatrimestre_actual 
          AND mes = @mes
    )
    BEGIN
        PRINT 'Error:cuota ya generada';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        SELECT @monto_total_cuota = ISNULL(SUM(m.costo_curso_mensual), 0)
        FROM Inscripcion i
        JOIN Curso c ON i.id_curso = c.id_curso
        JOIN Materia m ON c.id_materia = m.id_materia
        WHERE i.id_estudiante = @id_estudiante
          AND c.anio = @anio;


        IF @monto_total_cuota > 0
        BEGIN
            INSERT INTO Factura (id_estudiante, mes, anio, fecha_emision, fecha_vencimiento, monto_total, estado_pago)
            VALUES (@id_estudiante, @mes, @anio, @fecha_emision, @fecha_vencimiento, @monto_total_cuota, 'pendiente');        
            SET @id_factura_nueva = SCOPE_IDENTITY();
            INSERT INTO Cuota (id_estudiante, id_cuatrimestre, id_factura, mes, monto, fecha_vencimiento, estado_pago)
            VALUES (@id_estudiante, @id_cuatrimestre_actual, @id_factura_nueva, @mes, @monto_total_cuota, @fecha_vencimiento, 'pendiente');
            INSERT INTO [Cuenta Corriente] (id_estudiante, fecha, concepto, monto, estado)
            VALUES (@id_estudiante, @fecha_emision, 'Cargo por Cuota ' + CAST(@mes AS VARCHAR(2)) + '/' + CAST(@anio AS VARCHAR(4)), @monto_total_cuota, 'pendiente');
            PRINT 'Cuota generada para el alumno';
        END
        ELSE
        BEGIN
            PRINT 'el alumno no tiene materias con costo este año. No se genero cuota';
        END
        
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error al generar la cuota: ' + ERROR_MESSAGE();
    END CATCH
END
GO

DROP PROCEDURE IF EXISTS sp_CalcularInteresesPorMora;
GO

CREATE PROCEDURE sp_CalcularInteresesPorMora
AS
BEGIN
    DECLARE @id_estudiante_actual INT;
    DECLARE @anio_ingreso_actual INT;    
    DECLARE @cuotas_adeudadas INT;
    DECLARE @total_adeudado DECIMAL(10, 2);
    DECLARE @anio_carrera INT;
    DECLARE @porcentaje_interes DECIMAL(5, 2);
    DECLARE @monto_interes DECIMAL(10, 2);    
    DECLARE @fecha_actual DATE = GETDATE();
    DECLARE @mes_actual INT = MONTH(@fecha_actual);
    DECLARE @anio_actual INT = YEAR(@fecha_actual);
    DECLARE EstudiantesActivosCursor CURSOR LOCAL FOR 
        SELECT id_estudiante, anio_ingreso
        FROM Estudiante 
        WHERE estado_baja = 0;

    OPEN EstudiantesActivosCursor;    
    FETCH NEXT FROM EstudiantesActivosCursor INTO @id_estudiante_actual, @anio_ingreso_actual;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @cuotas_adeudadas = 0;
        SET @total_adeudado = 0;
        SET @porcentaje_interes = 0;
        SET @monto_interes = 0;
        SET @anio_carrera = 0;

        SELECT 
            @cuotas_adeudadas = COUNT(*),
            @total_adeudado = ISNULL(SUM(monto), 0)
        FROM Cuota
        WHERE id_estudiante = @id_estudiante_actual
          AND estado_pago = 'pendiente'
          AND fecha_vencimiento < @fecha_actual;

        IF @cuotas_adeudadas > 1
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM [Cuenta Corriente]
                WHERE id_estudiante = @id_estudiante_actual
                  AND concepto = 'Interes por mora'
                  AND MONTH(fecha) = @mes_actual
                  AND YEAR(fecha) = @anio_actual
            )
            BEGIN
                SET @anio_carrera = @anio_actual - @anio_ingreso_actual + 1;
                SELECT @porcentaje_interes = ISNULL(porcentaje_interes, 0)
                FROM [Interes por Mora]
                WHERE anio_carrera = @anio_carrera;
                SET @monto_interes = @total_adeudado * (@porcentaje_interes / 100.0);
                IF @monto_interes > 0
                BEGIN
                    BEGIN TRANSACTION;
                    BEGIN TRY
                        INSERT INTO [Cuenta Corriente] (id_estudiante, fecha, concepto, monto, estado)
                        VALUES (@id_estudiante_actual, @fecha_actual, 'Interes por mora', @monto_interes, 'pendiente');
                        
                        IF @@TRANCOUNT > 0 COMMIT TRANSACTION;
                    END TRY
                    BEGIN CATCH
                        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                        PRINT 'Error al aplicar interes al alumno ' + CAST(@id_estudiante_actual AS VARCHAR) + ': ' + ERROR_MESSAGE();
                    END CATCH
                END
            END
        END
        FETCH NEXT FROM EstudiantesActivosCursor INTO @id_estudiante_actual, @anio_ingreso_actual;
    END

    CLOSE EstudiantesActivosCursor;
    DEALLOCATE EstudiantesActivosCursor;
    
    PRINT 'Proceso de calculo de intereses completado';
END
GO

DROP PROCEDURE IF EXISTS sp_RegistrarPago;
GO

CREATE PROCEDURE sp_RegistrarPago
    @id_cuota INT,
    @id_estudiante INT
AS
BEGIN
    DECLARE @monto_cuota DECIMAL(10, 2);
    DECLARE @id_factura INT;
    DECLARE @estado_cuota VARCHAR(50);
    DECLARE @fecha_actual DATETIME = GETDATE();

    SELECT 
        @monto_cuota = monto,
        @id_factura = id_factura,
        @estado_cuota = estado_pago
    FROM Cuota
    WHERE id_cuota = @id_cuota AND id_estudiante = @id_estudiante;

    IF @monto_cuota IS NULL
    BEGIN
        PRINT 'Error: La cuota no existe o no pertenece a ese estudiante';
        RETURN;
    END

    IF @estado_cuota = 'pagado'
    BEGIN
        PRINT 'Error: cuota paga';
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO [Cuenta Corriente] (
            id_estudiante, 
            fecha, 
            concepto, 
            monto, 
            estado
        )
        VALUES (
            @id_estudiante,
            @fecha_actual,
            'Pago de cuota (ID Cuota: ' + CAST(@id_cuota AS VARCHAR) + ')',
            -@monto_cuota,
            'aplicado'
        );

        UPDATE Cuota
        SET 
            estado_pago = 'pagado'
        WHERE 
            id_cuota = @id_cuota;
        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;           
        PRINT 'Pago registrado';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;        
        PRINT 'Error al registrar el pago: ' + ERROR_MESSAGE();
    END CATCH
END
GO