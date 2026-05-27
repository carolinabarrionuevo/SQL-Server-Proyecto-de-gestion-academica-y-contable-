-- 1. ¿Qué estudiantes están inscriptos en cursos del año 2025?
SELECT E.nombre, E.apellido
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
JOIN Curso C ON I.id_curso = C.id_curso
WHERE C.anio = 2025;
-- 2. ¿Qué materias tienen más de 4 créditos y quiénes son sus profesores?
SELECT M.nombre_materia, P.nombre, P.apellido
FROM Materia M
JOIN Curso C ON M.id_materia = C.id_materia
JOIN Profesor P ON C.id_profesor = P.id_profesor
WHERE M.creditos > 4;
-- 3. ¿Qué cursos están dictados por profesores cuya especialidad contiene "Especialidad1"?
SELECT C.nombre_curso
FROM Curso C
JOIN Profesor P ON C.id_profesor = P.id_profesor
WHERE P.especialidad LIKE '%Especialidad1%';
-- 4. ¿Qué estudiantes obtuvieron una nota final mayor o igual a 8?
SELECT E.nombre, E.apellido
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
WHERE I.nota_final >= 8;
-- 5. ¿Qué cursos están asociados a materias con exactamente 3 créditos?
SELECT C.nombre_curso
FROM Curso C
JOIN Materia M ON C.id_materia = M.id_materia
WHERE M.creditos = 3;
-- 6. ¿Qué estudiantes se inscribieron después del 1 de junio de 2023?
SELECT E.nombre, E.apellido
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
WHERE I.fecha_inscripcion > '2023-06-01';
-- 7. ¿Qué materias dicta el profesor con especialidad "Especialidad5"?
SELECT M.nombre_materia
FROM Materia M
JOIN Curso C ON M.id_materia = C.id_materia
JOIN Profesor P ON C.id_profesor = P.id_profesor
WHERE P.especialidad = 'Especialidad5';
-- 8. ¿Qué estudiantes obtuvieron una nota teórica menor a 6?
SELECT E.nombre, E.apellido
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
WHERE I.nota_teorica < 6;
-- 9. ¿Qué cursos tienen inscripciones con nota final entre 7 y 9?
SELECT C.nombre_curso
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
WHERE I.nota_final BETWEEN 7 AND 9;
-- 10. ¿Qué profesores tienen un nombre que comienza con la letra 'L'?
SELECT nombre, apellido
FROM Profesor
WHERE nombre LIKE 'L%';
-- 11. ¿Cuál es la nota final promedio por curso?
SELECT C.nombre_curso, AVG(I.nota_final) AS promedio_nota_final
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso;
-- 12. ¿Cuántos cursos tiene cada estudiante?
SELECT E.nombre, E.apellido, COUNT(I.id_curso) AS numero_cursos
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
GROUP BY E.nombre, E.apellido;
-- 13. ¿Cuántas materias dicta cada profesor?
SELECT P.nombre, P.apellido, COUNT(M.id_materia) AS numero_materias
FROM Profesor P
JOIN Curso C ON P.id_profesor = C.id_profesor
JOIN Materia M ON C.id_materia = M.id_materia
GROUP BY P.nombre, P.apellido;
-- 14. ¿Cuál es la nota final máxima por curso?
SELECT C.nombre_curso, MAX(I.nota_final) AS nota_maxima
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso;
-- 15. ¿Cuál es la nota final mínima por curso?
SELECT C.nombre_curso, MIN(I.nota_final) AS nota_minima
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso;
-- 16. ¿Cuántos cursos están asociados a cada materia?
SELECT M.nombre_materia, COUNT(C.id_curso) AS numero_cursos
FROM Materia M
JOIN Curso C ON M.id_materia = C.id_materia
GROUP BY M.nombre_materia;
-- 17. ¿Cuál es el promedio de créditos por profesor?
SELECT P.nombre, P.apellido, AVG(M.creditos) AS promedio_creditos
FROM Profesor P
JOIN Curso C ON P.id_profesor = C.id_profesor
JOIN Materia M ON C.id_materia = M.id_materia
GROUP BY P.nombre, P.apellido;
-- 18. ¿Cuál es la suma total de notas finales por estudiante?
SELECT E.nombre, E.apellido, SUM(I.nota_final) AS suma_total_notas
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
GROUP BY E.nombre, E.apellido;
-- 19. ¿Cuántos estudiantes están inscriptos en cada curso?
SELECT C.nombre_curso, COUNT(I.id_estudiante) AS numero_estudiantes
FROM Curso C
LEFT JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso;
-- 20. ¿Cuántos cursos dicta cada profesor?
SELECT P.nombre, P.apellido, COUNT(C.id_curso) AS numero_cursos
FROM Profesor P
LEFT JOIN Curso C ON P.id_profesor = C.id_profesor
GROUP BY P.nombre, P.apellido;
-- 21. ¿Qué cursos tienen un promedio de nota final mayor a 7?
SELECT C.nombre_curso
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso
HAVING AVG(I.nota_final) > 7;
-- 22. ¿Qué estudiantes están inscriptos en 3 o más cursos?
SELECT E.nombre, E.apellido
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
GROUP BY E.nombre, E.apellido
HAVING COUNT(I.id_curso) >= 3;
-- 23. ¿Qué profesores dictan más de una materia?
SELECT P.nombre, P.apellido
FROM Profesor P
JOIN Curso C ON P.id_profesor = C.id_profesor
GROUP BY P.nombre, P.apellido
HAVING COUNT(C.id_materia) > 1;
-- 24. ¿Qué cursos tienen una nota final máxima igual a 10?
SELECT C.nombre_curso
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso
HAVING MAX(I.nota_final) = 10;
-- 25. ¿Qué cursos tienen una nota final mínima menor a 4?
SELECT C.nombre_curso
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso
HAVING MIN(I.nota_final) < 4;
-- 26. ¿Qué materias están asociadas a más de 2 cursos?
SELECT M.nombre_materia
FROM Materia M
JOIN Curso C ON M.id_materia = C.id_materia
GROUP BY M.nombre_materia
HAVING COUNT(C.id_curso) > 2;
-- 27. ¿Qué profesores tienen un promedio de créditos mayor o igual a 4?
SELECT P.nombre, P.apellido
FROM Profesor P
JOIN Curso C ON P.id_profesor = C.id_profesor
JOIN Materia M ON C.id_materia = M.id_materia
GROUP BY P.nombre, P.apellido
HAVING AVG(M.creditos) >= 4;
-- 28. ¿Qué estudiantes tienen una suma de notas finales mayor a 20?
SELECT E.nombre, E.apellido
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
GROUP BY E.nombre, E.apellido
HAVING SUM(I.nota_final) > 20;
-- 29. ¿Qué cursos tienen más de 5 inscriptos?
SELECT C.nombre_curso
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso
HAVING COUNT(I.id_estudiante) > 5;
-- 30. ¿Qué profesores dictan 2 o más cursos?
SELECT P.nombre, P.apellido
FROM Profesor P
JOIN Curso C ON P.id_profesor = C.id_profesor
GROUP BY P.nombre, P.apellido
HAVING COUNT(C.id_curso) >= 2;
-- 31. ¿Qué cursos tienen un promedio de nota final superior al promedio general?
SELECT C.nombre_curso
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso
HAVING AVG(I.nota_final) > (SELECT AVG(nota_final) FROM Inscripcion);
-- 32. ¿Qué estudiantes están inscriptos en más cursos que el promedio de inscripciones por estudiante?
SELECT E.nombre, E.apellido
FROM Estudiante E
JOIN Inscripcion I ON E.id_estudiante = I.id_estudiante
GROUP BY E.nombre, E.apellido
HAVING COUNT(I.id_curso) > (SELECT AVG(cursos_inscritos) FROM (SELECT COUNT(id_curso) AS cursos_inscritos FROM Inscripcion GROUP BY id_estudiante) AS subconsulta);
-- 33. ¿Qué profesores dictan más materias que el promedio general de materias por profesor?
SELECT P.nombre, P.apellido
FROM Profesor P
JOIN Curso C ON P.id_profesor = C.id_profesor
GROUP BY P.nombre, P.apellido
HAVING COUNT(C.id_materia) > (SELECT AVG(materias_dictadas) FROM (SELECT COUNT(id_materia) AS materias_dictadas FROM Curso GROUP BY id_profesor) AS subconsulta);
-- 34. ¿Qué cursos tienen una suma de notas finales superior a la suma máxima de notas finales de un solo estudiante?
SELECT C.nombre_curso
FROM Curso C
JOIN Inscripcion I ON C.id_curso = I.id_curso
GROUP BY C.nombre_curso
HAVING SUM(I.nota_final) > (SELECT MAX(suma_notas) FROM (SELECT SUM(nota_final) AS suma_notas FROM Inscripcion GROUP BY id_estudiante) AS subconsulta);