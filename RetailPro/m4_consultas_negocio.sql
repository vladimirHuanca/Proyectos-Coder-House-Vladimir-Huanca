-- Motor utilizado: SQL Server (SSMS)
-- Pre-entrega: Consultas SQL de negocio — RetailPro
-- Base de datos: Ventas_Tech_DB (creada en M3)
-- Nota: SQL Server no soporta EXTRACT(MONTH FROM fecha). Se usa MONTH(fecha_venta),
-- que es el equivalente directo, para agrupar por mes.

-- =========================================================
-- CONSULTA 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- =========================================================
SELECT
    MONTH(fecha_venta)                         AS mes,
    SUM(cantidad * precio_unitario)            AS total_facturado,
    COUNT(*)                                   AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)            AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- =========================================================
-- CONSULTA 2: Ranking de productos
-- Top 5 de id_producto por total facturado.
-- =========================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                              AS unidades_vendidas,
    SUM(cantidad * precio_unitario)            AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- =========================================================
-- CONSULTA 3: Clientes recurrentes
-- Clientes con más de un pedido, cantidad de pedidos y total gastado.
-- =========================================================
SELECT
    id_cliente,
    COUNT(*)                                   AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)            AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- =========================================================
-- CONSULTA 4: Meses por encima/por debajo del promedio
-- Total facturado por mes, comparado contra el promedio mensual general.
-- =========================================================
WITH ventas_mensuales AS (
    SELECT
        MONTH(fecha_venta)                     AS mes,
        SUM(cantidad * precio_unitario)        AS total_mes
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_mes,
    CASE
        WHEN total_mes > (SELECT AVG(total_mes) FROM ventas_mensuales) THEN 'Por encima'
        WHEN total_mes < (SELECT AVG(total_mes) FROM ventas_mensuales) THEN 'Por debajo'
        ELSE 'En el promedio'
    END                                         AS comparacion_promedio
FROM ventas_mensuales
ORDER BY mes;

-- =========================================================
-- HALLAZGOS
-- =========================================================
-- 1. El producto con id_producto = 1 concentra $3600 de los $6444 facturados
--    en total (aprox. 56%), lo que lo convierte en el producto que más
--    factura pese a haberse vendido en solo 3 unidades: su precio alto
--    (1200.00) pesa más que el volumen.
-- 2. Los 5 clientes cargados en la base son recurrentes: cada uno realizó
--    exactamente 2 pedidos, por lo que la consulta de HAVING COUNT(*) > 1
--    devuelve el 100% de los clientes. El cliente 1 es el que más gastó
--    en total ($2640), seguido del cliente 5 ($2100).
-- 3. Todas las ventas cargadas corresponden a marzo de 2024 (un único mes),
--    por lo que la Consulta 4 devuelve una sola fila etiquetada
--    'En el promedio': con datos de un solo mes no hay variación posible
--    todavía. Esta comparación va a tener sentido real recién cuando se
--    carguen ventas de más de un mes.
