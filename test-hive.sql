-- ========================================
-- Script de Prueba Rápida de Apache Hive
-- ========================================
-- Este script crea una base de datos de ejemplo
-- y realiza operaciones básicas para verificar
-- que Hive está funcionando correctamente

-- ========================================
-- 1. CREAR BASE DE DATOS
-- ========================================

CREATE DATABASE IF NOT EXISTS test_hive
COMMENT 'Base de datos de prueba para verificar Hive'
LOCATION '/user/hive/warehouse/test_hive.db';

-- Mostrar bases de datos
SHOW DATABASES;

-- Usar la base de datos
USE test_hive;

-- ========================================
-- 2. CREAR TABLAS
-- ========================================

-- Tabla simple de empleados
CREATE TABLE IF NOT EXISTS empleados (
    id INT,
    nombre STRING,
    departamento STRING,
    salario DECIMAL(10,2),
    fecha_ingreso DATE
)
COMMENT 'Tabla de empleados'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Tabla con particiones (ventas por año/mes)
CREATE TABLE IF NOT EXISTS ventas (
    id INT,
    producto STRING,
    cantidad INT,
    precio DECIMAL(10,2),
    fecha DATE
)
PARTITIONED BY (anio INT, mes INT)
COMMENT 'Tabla de ventas particionada'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS PARQUET;

-- Tabla externa (referencia a datos existentes)
CREATE EXTERNAL TABLE IF NOT EXISTS logs_externos (
    timestamp STRING,
    nivel STRING,
    mensaje STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/user/hive/external/logs';

-- Mostrar tablas creadas
SHOW TABLES;

-- ========================================
-- 3. INSERTAR DATOS DE PRUEBA
-- ========================================

-- Insertar empleados
INSERT INTO empleados VALUES
    (1, 'Juan Pérez', 'Ventas', 50000.00, '2020-01-15'),
    (2, 'María García', 'IT', 65000.00, '2019-03-20'),
    (3, 'Carlos López', 'Marketing', 55000.00, '2021-06-10'),
    (4, 'Ana Martínez', 'IT', 70000.00, '2018-11-05'),
    (5, 'Pedro Rodríguez', 'Ventas', 48000.00, '2022-02-28'),
    (6, 'Laura Sánchez', 'RRHH', 52000.00, '2020-09-12'),
    (7, 'Miguel Torres', 'IT', 68000.00, '2019-07-18'),
    (8, 'Isabel Ramírez', 'Marketing', 53000.00, '2021-12-03');

-- Insertar ventas (con particiones)
INSERT INTO ventas PARTITION (anio=2024, mes=10) VALUES
    (1, 'Laptop Dell', 5, 1200.00, '2024-10-01'),
    (2, 'Mouse Logitech', 20, 25.50, '2024-10-02'),
    (3, 'Teclado Mecánico', 10, 85.00, '2024-10-03'),
    (4, 'Monitor LG', 8, 350.00, '2024-10-05');

INSERT INTO ventas PARTITION (anio=2024, mes=9) VALUES
    (5, 'Laptop HP', 3, 1100.00, '2024-09-15'),
    (6, 'Mouse Inalámbrico', 15, 30.00, '2024-09-20'),
    (7, 'Webcam HD', 6, 75.00, '2024-09-25');

-- ========================================
-- 4. CONSULTAS BÁSICAS
-- ========================================

-- Consulta simple
SELECT '==== TODOS LOS EMPLEADOS ====' as info;
SELECT * FROM empleados;

-- Consulta con filtro
SELECT '==== EMPLEADOS DE IT ====' as info;
SELECT nombre, salario 
FROM empleados 
WHERE departamento = 'IT' 
ORDER BY salario DESC;

-- Agregaciones
SELECT '==== SALARIO PROMEDIO POR DEPARTAMENTO ====' as info;
SELECT 
    departamento,
    COUNT(*) as total_empleados,
    ROUND(AVG(salario), 2) as salario_promedio,
    MAX(salario) as salario_maximo,
    MIN(salario) as salario_minimo
FROM empleados
GROUP BY departamento
ORDER BY salario_promedio DESC;

-- Consulta de ventas (tabla particionada)
SELECT '==== VENTAS OCTUBRE 2024 ====' as info;
SELECT * FROM ventas WHERE anio=2024 AND mes=10;

-- ========================================
-- 5. OPERACIONES AVANZADAS
-- ========================================

-- Crear tabla de resumen
CREATE TABLE IF NOT EXISTS resumen_departamentos AS
SELECT 
    departamento,
    COUNT(*) as total_empleados,
    ROUND(AVG(salario), 2) as salario_promedio
FROM empleados
GROUP BY departamento;

-- Ver tabla de resumen
SELECT '==== RESUMEN POR DEPARTAMENTO ====' as info;
SELECT * FROM resumen_departamentos;

-- Consulta compleja con subconsulta
SELECT '==== EMPLEADOS CON SALARIO MAYOR AL PROMEDIO ====' as info;
SELECT 
    nombre,
    departamento,
    salario,
    ROUND(salario - avg_sal.promedio, 2) as diferencia
FROM empleados,
     (SELECT AVG(salario) as promedio FROM empleados) avg_sal
WHERE salario > avg_sal.promedio
ORDER BY diferencia DESC;

-- ========================================
-- 6. ANÁLISIS DE VENTAS
-- ========================================

-- Total de ventas por mes
SELECT '==== TOTAL VENTAS POR MES ====' as info;
SELECT 
    anio,
    mes,
    COUNT(*) as total_transacciones,
    SUM(cantidad) as total_unidades,
    ROUND(SUM(cantidad * precio), 2) as total_ingresos
FROM ventas
GROUP BY anio, mes
ORDER BY anio, mes;

-- Productos más vendidos
SELECT '==== TOP PRODUCTOS ====' as info;
SELECT 
    producto,
    SUM(cantidad) as total_vendido,
    ROUND(SUM(cantidad * precio), 2) as ingresos_totales
FROM ventas
GROUP BY producto
ORDER BY total_vendido DESC;

-- ========================================
-- 7. INFORMACIÓN DE METADATA
-- ========================================

-- Describir estructura de tabla
SELECT '==== ESTRUCTURA TABLA EMPLEADOS ====' as info;
DESCRIBE empleados;

-- Descripción detallada
SELECT '==== DESCRIPCIÓN DETALLADA ====' as info;
DESCRIBE FORMATTED empleados;

-- Ver particiones
SELECT '==== PARTICIONES DE VENTAS ====' as info;
SHOW PARTITIONS ventas;

-- Estadísticas de tabla
SELECT '==== ESTADÍSTICAS ====' as info;
ANALYZE TABLE empleados COMPUTE STATISTICS;
ANALYZE TABLE ventas COMPUTE STATISTICS;

-- ========================================
-- 8. LIMPIAR (OPCIONAL)
-- ========================================

-- Si quieres limpiar todo, descomenta:
-- DROP TABLE IF EXISTS empleados;
-- DROP TABLE IF EXISTS ventas;
-- DROP TABLE IF EXISTS logs_externos;
-- DROP TABLE IF EXISTS resumen_departamentos;
-- DROP DATABASE IF EXISTS test_hive CASCADE;

-- ========================================
-- RESUMEN
-- ========================================

SELECT '==== ✅ PRUEBA COMPLETADA ====' as info;
SELECT 'Base de datos: test_hive' as detalle;
SELECT 'Tablas creadas: empleados, ventas, logs_externos, resumen_departamentos' as detalle;
SELECT 'Registros insertados: 8 empleados, 11 ventas' as detalle;
SELECT '¡Hive está funcionando correctamente!' as mensaje;
