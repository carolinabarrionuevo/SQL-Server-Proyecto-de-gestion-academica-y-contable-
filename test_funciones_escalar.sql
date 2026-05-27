USE [Gestion Academica];
GO

UPDATE Inscripcion SET nota_final = 6 WHERE id_estudiante = 999 AND id_curso = 999;
PRINT 'Promedio alumno 999 tiene que ser 6.00:';
SELECT dbo.fn_ObtenerPromedioFinal(999, 999) AS Promedio;


DECLARE @id_cuota_pagada INT;
SELECT @id_cuota_pagada = id_cuota FROM Cuota WHERE id_estudiante = 999 AND mes = 11;
PRINT 'Estado cuota tiene que ser "pagado":';
SELECT dbo.fn_ObtenerEstadoCuota(@id_cuota_pagada) AS Estado;


PRINT 'Especialidad profesor 999 tiene que ser "testing"):';
SELECT dbo.fn_ObtenerEspecialidadProfesor('Claudio', 'Godio') AS Especialidad;


PRINT 'Deuda de "Nicolas" tiene que ser -1.00 por ambiguo:';
SELECT dbo.fn_ObtenerDeudaPorNombre('Nicolas') AS Deuda_Nicolas;

PRINT 'Deuda de "Alejandro" tiene que tener deuda de cuotas e interes:';
SELECT dbo.fn_ObtenerDeudaPorNombre('Alejandro') AS Deuda_Alejandro;

PRINT 'Deuda de "Juan" tiene que ser 0.00, no existe:';
SELECT dbo.fn_ObtenerDeudaPorNombre('Juan') AS Deuda_Juan;