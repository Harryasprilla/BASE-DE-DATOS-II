-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 28-04-2025 a las 22:04:47
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `colegiodb`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoginUsuario` (IN `correo_input` VARCHAR(100), IN `password_input` VARCHAR(100))   BEGIN
    DECLARE user_id INT DEFAULT NULL;
    DECLARE user_estado VARCHAR(20);
    DECLARE user_intentos INT DEFAULT 0;
    DECLARE ultimo_intento_guardado DATETIME;

    -- Obtener datos del usuario
    SELECT id_usuario, estado, intentos_login, ultimo_intento
    INTO user_id, user_estado, user_intentos, ultimo_intento_guardado
    FROM Usuarios
    WHERE correo = correo_input
    LIMIT 1;

    IF user_id IS NULL THEN
        SELECT 'Correo no encontrado' AS Mensaje;
    ELSE
        IF user_estado = 'Bloqueado' THEN
            -- Verificar si pasaron 3 minutos
            IF TIMESTAMPDIFF(MINUTE, ultimo_intento_guardado, NOW()) >= 3 THEN
                UPDATE Usuarios 
                SET estado = 'Activo', intentos_login = 0 
                WHERE id_usuario = user_id;
                SET user_estado = 'Activo'; 
            ELSE
                SELECT 'Usuario bloqueado. Espere 3 minutos para reintentar.' AS Mensaje;
            END IF;
        END IF;

        -- Si el usuario quedó activo
        IF user_estado = 'Activo' THEN
            IF EXISTS (SELECT 1 FROM Usuarios WHERE correo = correo_input AND password = password_input) THEN
                UPDATE Usuarios SET intentos_login = 0, ultimo_intento = NOW() WHERE id_usuario = user_id;
                SELECT 'Login exitoso' AS Mensaje;
            ELSE
                UPDATE Usuarios 
                SET intentos_login = intentos_login + 1, ultimo_intento = NOW()
                WHERE id_usuario = user_id;

                SET user_intentos = user_intentos + 1;
                
                IF user_intentos >= 3 THEN
                    UPDATE Usuarios SET estado = 'Bloqueado' WHERE id_usuario = user_id;
                    INSERT INTO UsuariosBloqueados (id_usuario, fecha_bloqueo) VALUES (user_id, NOW());
                    SELECT 'Usuario bloqueado tras 3 intentos fallidos.' AS Mensaje;
                ELSE
                    SELECT CONCAT('Intento fallido ', user_intentos) AS Mensaje;
                END IF;
            END IF;
        END IF;
    END IF;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `NombreCompleto` (`id` INT) RETURNS VARCHAR(150) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
    DECLARE nombre_completo VARCHAR(150);
    SELECT CONCAT(nombre, ' ', apellido) INTO nombre_completo
    FROM Usuarios
    WHERE id_usuario = id;
    RETURN nombre_completo;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `areasinstitucion`
--

CREATE TABLE `areasinstitucion` (
  `id_area` int(11) NOT NULL,
  `nombre_area` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `areasinstitucion`
--

INSERT INTO `areasinstitucion` (`id_area`, `nombre_area`) VALUES
(1, 'Biblioteca'),
(2, 'Laboratorio');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `id_auditoria` int(11) NOT NULL,
  `tabla_afectada` varchar(100) DEFAULT NULL,
  `accion` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `id_registro` int(11) DEFAULT NULL,
  `fecha` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria`
--

INSERT INTO `auditoria` (`id_auditoria`, `tabla_afectada`, `accion`, `id_registro`, `fecha`) VALUES
(1, 'Usuarios', 'INSERT', 1, '2025-04-28 14:58:52'),
(2, 'Usuarios', 'INSERT', 2, '2025-04-28 14:58:52'),
(3, 'Usuarios', 'INSERT', 3, '2025-04-28 14:58:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cursos`
--

CREATE TABLE `cursos` (
  `id_curso` int(11) NOT NULL,
  `nombre_curso` varchar(100) DEFAULT NULL,
  `id_programa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cursos`
--

INSERT INTO `cursos` (`id_curso`, `nombre_curso`, `id_programa`) VALUES
(1, 'Matemáticas', 1),
(2, 'Física', 1),
(3, 'Derecho Penal', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docentecurso`
--

CREATE TABLE `docentecurso` (
  `id_docente_curso` int(11) NOT NULL,
  `id_docente` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipostecnologicos`
--

CREATE TABLE `equipostecnologicos` (
  `id_equipo` int(11) NOT NULL,
  `nombre_equipo` varchar(100) DEFAULT NULL,
  `id_area` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `equipostecnologicos`
--

INSERT INTO `equipostecnologicos` (`id_equipo`, `nombre_equipo`, `id_area`) VALUES
(1, 'Computadora A', 1),
(2, 'Microscopio X', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `eventos`
--

CREATE TABLE `eventos` (
  `id_evento` int(11) NOT NULL,
  `nombre_evento` varchar(100) DEFAULT NULL,
  `tipo_evento` enum('Académico','Cultural','Deportivo') DEFAULT NULL,
  `fecha_evento` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inscripciones`
--

CREATE TABLE `inscripciones` (
  `id_inscripcion` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `fecha_inscripcion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inscripciones`
--

INSERT INTO `inscripciones` (`id_inscripcion`, `id_usuario`, `id_curso`, `fecha_inscripcion`) VALUES
(1, 1, 1, '2025-04-28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notas`
--

CREATE TABLE `notas` (
  `id_nota` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `nota` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personaladministrativo`
--

CREATE TABLE `personaladministrativo` (
  `id_personal` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `cargo` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `programas`
--

CREATE TABLE `programas` (
  `id_programa` int(11) NOT NULL,
  `nombre_programa` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `programas`
--

INSERT INTO `programas` (`id_programa`, `nombre_programa`) VALUES
(1, 'Ingeniería'),
(2, 'Derecho');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `apellido` varchar(50) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `tipo` enum('Estudiante','Docente','Administrativo') DEFAULT NULL,
  `estado` enum('Activo','Bloqueado') DEFAULT 'Activo',
  `intentos_login` int(11) DEFAULT 0,
  `ultimo_intento` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `apellido`, `correo`, `password`, `tipo`, `estado`, `intentos_login`, `ultimo_intento`) VALUES
(1, 'Carlos', 'Pérez', 'carlos@colegio.com', '1234', 'Estudiante', 'Activo', 0, NULL),
(2, 'María', 'Gómez', 'maria@colegio.com', 'abcd', 'Docente', 'Activo', 0, NULL),
(3, 'Luis', 'Martínez', 'luis@colegio.com', 'pass', 'Administrativo', 'Activo', 0, NULL);

--
-- Disparadores `usuarios`
--
DELIMITER $$
CREATE TRIGGER `trg_usuario_delete` AFTER DELETE ON `usuarios` FOR EACH ROW BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion, id_registro)
    VALUES ('Usuarios', 'DELETE', OLD.id_usuario);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_usuario_insert` AFTER INSERT ON `usuarios` FOR EACH ROW BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion, id_registro)
    VALUES ('Usuarios', 'INSERT', NEW.id_usuario);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_usuario_update` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
    INSERT INTO Auditoria (tabla_afectada, accion, id_registro)
    VALUES ('Usuarios', 'UPDATE', NEW.id_usuario);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuariosbloqueados`
--

CREATE TABLE `usuariosbloqueados` (
  `id_bloqueo` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `fecha_bloqueo` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vistaauditoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vistaauditoria` (
`id_auditoria` int(11)
,`tabla_afectada` varchar(100)
,`accion` enum('INSERT','UPDATE','DELETE')
,`id_registro` int(11)
,`fecha` datetime
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vistaequiposporarea`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vistaequiposporarea` (
`nombre_area` varchar(100)
,`nombre_equipo` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vistaestudiantesactivos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vistaestudiantesactivos` (
`id_usuario` int(11)
,`nombre` varchar(50)
,`apellido` varchar(50)
,`correo` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vistainscripciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vistainscripciones` (
`id_inscripcion` int(11)
,`nombre` varchar(50)
,`apellido` varchar(50)
,`nombre_curso` varchar(100)
,`fecha_inscripcion` date
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vistausuariosbloqueados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vistausuariosbloqueados` (
`id_bloqueo` int(11)
,`nombre` varchar(50)
,`apellido` varchar(50)
,`fecha_bloqueo` datetime
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vistaauditoria`
--
DROP TABLE IF EXISTS `vistaauditoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaauditoria`  AS SELECT `auditoria`.`id_auditoria` AS `id_auditoria`, `auditoria`.`tabla_afectada` AS `tabla_afectada`, `auditoria`.`accion` AS `accion`, `auditoria`.`id_registro` AS `id_registro`, `auditoria`.`fecha` AS `fecha` FROM `auditoria` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vistaequiposporarea`
--
DROP TABLE IF EXISTS `vistaequiposporarea`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaequiposporarea`  AS SELECT `a`.`nombre_area` AS `nombre_area`, `e`.`nombre_equipo` AS `nombre_equipo` FROM (`equipostecnologicos` `e` join `areasinstitucion` `a` on(`e`.`id_area` = `a`.`id_area`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vistaestudiantesactivos`
--
DROP TABLE IF EXISTS `vistaestudiantesactivos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistaestudiantesactivos`  AS SELECT `usuarios`.`id_usuario` AS `id_usuario`, `usuarios`.`nombre` AS `nombre`, `usuarios`.`apellido` AS `apellido`, `usuarios`.`correo` AS `correo` FROM `usuarios` WHERE `usuarios`.`tipo` = 'Estudiante' AND `usuarios`.`estado` = 'Activo' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vistainscripciones`
--
DROP TABLE IF EXISTS `vistainscripciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistainscripciones`  AS SELECT `i`.`id_inscripcion` AS `id_inscripcion`, `u`.`nombre` AS `nombre`, `u`.`apellido` AS `apellido`, `c`.`nombre_curso` AS `nombre_curso`, `i`.`fecha_inscripcion` AS `fecha_inscripcion` FROM ((`inscripciones` `i` join `usuarios` `u` on(`i`.`id_usuario` = `u`.`id_usuario`)) join `cursos` `c` on(`i`.`id_curso` = `c`.`id_curso`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vistausuariosbloqueados`
--
DROP TABLE IF EXISTS `vistausuariosbloqueados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vistausuariosbloqueados`  AS SELECT `ub`.`id_bloqueo` AS `id_bloqueo`, `u`.`nombre` AS `nombre`, `u`.`apellido` AS `apellido`, `ub`.`fecha_bloqueo` AS `fecha_bloqueo` FROM (`usuariosbloqueados` `ub` join `usuarios` `u` on(`ub`.`id_usuario` = `u`.`id_usuario`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `areasinstitucion`
--
ALTER TABLE `areasinstitucion`
  ADD PRIMARY KEY (`id_area`);

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id_auditoria`);

--
-- Indices de la tabla `cursos`
--
ALTER TABLE `cursos`
  ADD PRIMARY KEY (`id_curso`),
  ADD KEY `id_programa` (`id_programa`);

--
-- Indices de la tabla `docentecurso`
--
ALTER TABLE `docentecurso`
  ADD PRIMARY KEY (`id_docente_curso`),
  ADD KEY `id_docente` (`id_docente`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `equipostecnologicos`
--
ALTER TABLE `equipostecnologicos`
  ADD PRIMARY KEY (`id_equipo`),
  ADD KEY `id_area` (`id_area`);

--
-- Indices de la tabla `eventos`
--
ALTER TABLE `eventos`
  ADD PRIMARY KEY (`id_evento`);

--
-- Indices de la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD PRIMARY KEY (`id_inscripcion`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `notas`
--
ALTER TABLE `notas`
  ADD PRIMARY KEY (`id_nota`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `personaladministrativo`
--
ALTER TABLE `personaladministrativo`
  ADD PRIMARY KEY (`id_personal`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `programas`
--
ALTER TABLE `programas`
  ADD PRIMARY KEY (`id_programa`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `correo` (`correo`);

--
-- Indices de la tabla `usuariosbloqueados`
--
ALTER TABLE `usuariosbloqueados`
  ADD PRIMARY KEY (`id_bloqueo`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `areasinstitucion`
--
ALTER TABLE `areasinstitucion`
  MODIFY `id_area` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `cursos`
--
ALTER TABLE `cursos`
  MODIFY `id_curso` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `docentecurso`
--
ALTER TABLE `docentecurso`
  MODIFY `id_docente_curso` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `equipostecnologicos`
--
ALTER TABLE `equipostecnologicos`
  MODIFY `id_equipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `eventos`
--
ALTER TABLE `eventos`
  MODIFY `id_evento` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  MODIFY `id_inscripcion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `notas`
--
ALTER TABLE `notas`
  MODIFY `id_nota` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `personaladministrativo`
--
ALTER TABLE `personaladministrativo`
  MODIFY `id_personal` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `programas`
--
ALTER TABLE `programas`
  MODIFY `id_programa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `usuariosbloqueados`
--
ALTER TABLE `usuariosbloqueados`
  MODIFY `id_bloqueo` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cursos`
--
ALTER TABLE `cursos`
  ADD CONSTRAINT `cursos_ibfk_1` FOREIGN KEY (`id_programa`) REFERENCES `programas` (`id_programa`);

--
-- Filtros para la tabla `docentecurso`
--
ALTER TABLE `docentecurso`
  ADD CONSTRAINT `docentecurso_ibfk_1` FOREIGN KEY (`id_docente`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `docentecurso_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `equipostecnologicos`
--
ALTER TABLE `equipostecnologicos`
  ADD CONSTRAINT `equipostecnologicos_ibfk_1` FOREIGN KEY (`id_area`) REFERENCES `areasinstitucion` (`id_area`);

--
-- Filtros para la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD CONSTRAINT `inscripciones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `inscripciones_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `notas`
--
ALTER TABLE `notas`
  ADD CONSTRAINT `notas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `notas_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `personaladministrativo`
--
ALTER TABLE `personaladministrativo`
  ADD CONSTRAINT `personaladministrativo_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `usuariosbloqueados`
--
ALTER TABLE `usuariosbloqueados`
  ADD CONSTRAINT `usuariosbloqueados_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
