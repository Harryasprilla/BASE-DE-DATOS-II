-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-03-2025 a las 21:12:05
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
-- Base de datos: `parqueadero`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_estado_vehiculo` (IN `p_id_vehiculo` INT, IN `p_estado` ENUM('Buen estado','En reparación','Lavado','Averiado'))   BEGIN
    UPDATE estado_vehiculo
    SET estado = p_estado, fecha_estado = NOW()
    WHERE id_vehiculo = p_id_vehiculo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generar_factura` (IN `p_id_vehiculo` INT, IN `p_id_puesto` INT, IN `p_total` DECIMAL(10,2))   BEGIN
    INSERT INTO facturas (id_vehiculo, id_puesto, fecha_factura, total)
    VALUES (p_id_vehiculo, p_id_puesto, NOW(), p_total);
    
    UPDATE puestos
    SET estado_puesto = 'Ocupado'
    WHERE id_puesto = p_id_puesto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_vehiculo` (IN `p_placa` VARCHAR(20), IN `p_marca` VARCHAR(50), IN `p_modelo` VARCHAR(50), IN `p_tipo_vehiculo` VARCHAR(20))   BEGIN
    INSERT INTO vehiculos (placa, marca, modelo, tipo_vehiculo)
    VALUES (p_placa, p_marca, p_modelo, p_tipo_vehiculo);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_vehiculo`
--

CREATE TABLE `estado_vehiculo` (
  `id_estado` int(11) NOT NULL,
  `id_vehiculo` int(11) DEFAULT NULL,
  `fecha_estado` datetime DEFAULT NULL,
  `estado` enum('Buen estado','En reparación','Lavado','Averiado') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `estado_vehiculo`
--

INSERT INTO `estado_vehiculo` (`id_estado`, `id_vehiculo`, `fecha_estado`, `estado`) VALUES
(1, 1, '2025-03-19 08:00:00', 'Buen estado'),
(2, 2, '2025-03-19 09:00:00', 'Lavado'),
(3, 3, '2025-03-19 10:00:00', 'Averiado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturas`
--

CREATE TABLE `facturas` (
  `id_factura` int(11) NOT NULL,
  `id_vehiculo` int(11) DEFAULT NULL,
  `id_puesto` int(11) DEFAULT NULL,
  `fecha_factura` datetime DEFAULT NULL,
  `total` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `facturas`
--

INSERT INTO `facturas` (`id_factura`, `id_vehiculo`, `id_puesto`, `fecha_factura`, `total`) VALUES
(1, 1, 1, '2025-03-19 14:00:00', 30.00),
(2, 2, 2, '2025-03-19 15:00:00', 50.00);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `facturas_vehiculo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `facturas_vehiculo` (
`placa` varchar(20)
,`fecha_factura` datetime
,`total` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lavados`
--

CREATE TABLE `lavados` (
  `id_lavado` int(11) NOT NULL,
  `id_vehiculo` int(11) DEFAULT NULL,
  `fecha_lavado` datetime DEFAULT NULL,
  `tipo_lavado` varchar(50) DEFAULT NULL,
  `costo` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `lavados`
--

INSERT INTO `lavados` (`id_lavado`, `id_vehiculo`, `fecha_lavado`, `tipo_lavado`, `costo`) VALUES
(1, 1, '2025-03-19 11:00:00', 'Lavado exterior', 10.50),
(2, 2, '2025-03-19 12:00:00', 'Lavado completo', 20.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `puestos`
--

CREATE TABLE `puestos` (
  `id_puesto` int(11) NOT NULL,
  `numero_puesto` int(11) NOT NULL,
  `estado_puesto` enum('Libre','Ocupado') DEFAULT 'Libre'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `puestos`
--

INSERT INTO `puestos` (`id_puesto`, `numero_puesto`, `estado_puesto`) VALUES
(1, 1, 'Libre'),
(2, 2, 'Ocupado'),
(3, 3, 'Libre');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `puestos_ocupados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `puestos_ocupados` (
`numero_puesto` int(11)
,`placa` varchar(20)
,`marca` varchar(50)
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculos`
--

CREATE TABLE `vehiculos` (
  `id_vehiculo` int(11) NOT NULL,
  `placa` varchar(20) NOT NULL,
  `marca` varchar(50) DEFAULT NULL,
  `modelo` varchar(50) DEFAULT NULL,
  `tipo_vehiculo` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `vehiculos`
--

INSERT INTO `vehiculos` (`id_vehiculo`, `placa`, `marca`, `modelo`, `tipo_vehiculo`) VALUES
(1, 'ABC123', 'Toyota', 'Corolla', 'Sedán'),
(2, 'XYZ456', 'Honda', 'Civic', 'Sedán'),
(3, 'LMN789', 'BMW', 'X5', 'SUV');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vehiculos_buen_estado`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vehiculos_buen_estado` (
`placa` varchar(20)
,`marca` varchar(50)
,`modelo` varchar(50)
,`tipo_vehiculo` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `facturas_vehiculo`
--
DROP TABLE IF EXISTS `facturas_vehiculo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `facturas_vehiculo`  AS SELECT `v`.`placa` AS `placa`, `f`.`fecha_factura` AS `fecha_factura`, `f`.`total` AS `total` FROM (`facturas` `f` join `vehiculos` `v` on(`f`.`id_vehiculo` = `v`.`id_vehiculo`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `puestos_ocupados`
--
DROP TABLE IF EXISTS `puestos_ocupados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `puestos_ocupados`  AS SELECT `p`.`numero_puesto` AS `numero_puesto`, `v`.`placa` AS `placa`, `v`.`marca` AS `marca` FROM ((`puestos` `p` join `facturas` `f` on(`p`.`id_puesto` = `f`.`id_puesto`)) join `vehiculos` `v` on(`f`.`id_vehiculo` = `v`.`id_vehiculo`)) WHERE `p`.`estado_puesto` = 'Ocupado' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vehiculos_buen_estado`
--
DROP TABLE IF EXISTS `vehiculos_buen_estado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vehiculos_buen_estado`  AS SELECT `v`.`placa` AS `placa`, `v`.`marca` AS `marca`, `v`.`modelo` AS `modelo`, `v`.`tipo_vehiculo` AS `tipo_vehiculo` FROM (`vehiculos` `v` join `estado_vehiculo` `e` on(`v`.`id_vehiculo` = `e`.`id_vehiculo`)) WHERE `e`.`estado` = 'Buen estado' ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `estado_vehiculo`
--
ALTER TABLE `estado_vehiculo`
  ADD PRIMARY KEY (`id_estado`),
  ADD KEY `id_vehiculo` (`id_vehiculo`);

--
-- Indices de la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`id_factura`),
  ADD KEY `id_vehiculo` (`id_vehiculo`),
  ADD KEY `id_puesto` (`id_puesto`);

--
-- Indices de la tabla `lavados`
--
ALTER TABLE `lavados`
  ADD PRIMARY KEY (`id_lavado`),
  ADD KEY `id_vehiculo` (`id_vehiculo`);

--
-- Indices de la tabla `puestos`
--
ALTER TABLE `puestos`
  ADD PRIMARY KEY (`id_puesto`);

--
-- Indices de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  ADD PRIMARY KEY (`id_vehiculo`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `estado_vehiculo`
--
ALTER TABLE `estado_vehiculo`
  MODIFY `id_estado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id_factura` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `lavados`
--
ALTER TABLE `lavados`
  MODIFY `id_lavado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `puestos`
--
ALTER TABLE `puestos`
  MODIFY `id_puesto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  MODIFY `id_vehiculo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `estado_vehiculo`
--
ALTER TABLE `estado_vehiculo`
  ADD CONSTRAINT `estado_vehiculo_ibfk_1` FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculos` (`id_vehiculo`);

--
-- Filtros para la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `facturas_ibfk_1` FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculos` (`id_vehiculo`),
  ADD CONSTRAINT `facturas_ibfk_2` FOREIGN KEY (`id_puesto`) REFERENCES `puestos` (`id_puesto`);

--
-- Filtros para la tabla `lavados`
--
ALTER TABLE `lavados`
  ADD CONSTRAINT `lavados_ibfk_1` FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculos` (`id_vehiculo`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
