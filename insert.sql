USE [Gestion Academica];
GO

INSERT INTO Profesor (id_profesor, nombre, apellido, especialidad) VALUES
(1, 'Claudio', 'Godio', 'Ingenieria de datos'),
(2, 'Lionel', ';Messi', 'Programacion 1'),
(3, 'Gonzalo', 'Montiel', 'Ingenieria de software');

INSERT INTO Materia (id_materia, nombre_materia, creditos) VALUES
(11, 'Ingenieria de datos', 5),
(12, 'Programación 1', 3),
(13, 'Ingenieria de software', 4);

INSERT INTO Estudiante (id_estudiante, nombre, apellido, email) VALUES
(101, 'Alejandro', 'Yande', 'alejandroyande@g0il.com'),
(102, 'Nicolas', 'Cieplak', 'nicolascieplak@gmail.com'),
(103, 'Juani', 'Medina', 'juanimedina@gmail.com');

INSERT INTO Curso (id_curso, nombre_curso, descripcion, anio, id_profesor, id_materia) VALUES
(1001, 'ingenieria de datos', 'Introduccion a sql', 2025, 1, 11),
(1002, 'ingenieria de software', 'Introduccion a ingenieria de software', 2025, 2, 12),
(1003, 'Progra 1', 'Python', 2025, 3, 13);

INSERT INTO Inscripcion (id_estudiante, id_curso, fecha_inscripcion, nota_teorica, nota_practica, nota_final) VALUES
(101, 1001, '2025-05-01', 0, 0, 0),
(101, 1002, '2025-05-01', 0, 0, 0),
(101, 1003, '2025-05-01', 0, 0, 0),
(102, 1001, '2025-06-01', 0, 0, 0),
(102, 1002, '2025-06-01', 0, 0, 0),
(102, 1003, '2025-06-01', 0, 0, 0),
(103, 1001, '2025-06-02', 0, 0, 0),
(103, 1002, '2025-06-02', 0, 0, 0),
(103, 1003, '2025-06-02', 0, 0, 0);