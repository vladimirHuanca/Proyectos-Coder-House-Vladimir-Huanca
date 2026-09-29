    -----------------------Pre-entrega evaluable – Módulo 5-----------------------


    -------------------Alumno: Vladimir Nicolas Huanca Grimaldes------------------

    -- Motor utilizado: SQL Server (SSMS)
    -- Pre-entrega: Consultas con JOINs — RetailPro
    -- Base de datos: Ventas_Tech_DB (esquema creado en M3: categorias, clientes, productos, ventas)
    -- Dimensión geográfica utilizada: clientes.ciudad (ya existía en el esquema del Checkpoint de M3,
    -- no fue necesario agregar una tabla nueva).
    USE Ventas_Tech_DB;


    SELECT * FROM categorias;
    SELECT * FROM clientes;
    SELECT * FROM productos;
    SELECT * FROM ventas;
    -- =========================================================
    -- CONSULTA 1: Vista base del proyecto (INNER JOIN)
    -- Cruza ventas con clientes, productos y categorias para tener,
    -- en una sola fila, todo lo que va a alimentar el dashboard de Power BI.
    -- =========================================================
    SELECT
        v.fecha_venta,
        v.id_cliente,
        c.nombre                           AS nombre_cliente,
        c.ciudad                           AS ciudad_cliente,
        p.nombre_producto,
        cat.nombre_categoria               AS categoria_producto,
        v.cantidad,
        v.precio_unitario,
        v.cantidad * v.precio_unitario     AS total_venta
    FROM ventas v
    INNER JOIN clientes   c   ON v.id_cliente = c.id_cliente
    INNER JOIN productos  p   ON v.id_producto = p.id_producto
    INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
    ORDER BY v.fecha_venta;

    -- =========================================================
    -- CONSULTA 2: Clientes sin ventas (LEFT JOIN)
    -- Clientes registrados que todavía no hicieron ninguna compra.
    -- Con el dataset actual del checkpoint (5 clientes, 2 pedidos c/u)
    -- esta consulta devuelve 0 filas: sirve igual para detectar el caso
    -- apenas se cargue un cliente nuevo sin ventas.
    -- =========================================================
    SELECT
        c.nombre,
        c.email,
        c.fecha_registro
    FROM clientes c
    LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
    WHERE v.id_cliente IS NULL;

    -- =========================================================
    -- CONSULTA 3: Productos sin ventas (LEFT JOIN)
    -- Productos del catálogo que no tienen ninguna venta registrada.
    -- Igual que en la Consulta 2, con el dataset actual (los 6 productos
    -- tienen al menos una venta) devuelve 0 filas.
    -- =========================================================
    SELECT
        p.nombre_producto,
        cat.nombre_categoria AS categoria,
        p.precio
    FROM productos p
    LEFT JOIN ventas v      ON p.id_producto = v.id_producto
    INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
    WHERE v.id_producto IS NULL;

    -- =========================================================
    -- CONSULTA 4: Consolidado por canal (UNION ALL)
    -- La columna "canal" no existe en la tabla: se genera acá como valor
    -- literal. Como el dataset no tiene sucursales, se usa como criterio
    -- la fecha de venta: primera quincena de marzo vs. segunda quincena.
    -- =========================================================
    WITH ventas_canal AS (
        SELECT fecha_venta, cantidad * precio_unitario AS total, 'Primera quincena' AS canal
        FROM ventas
        WHERE fecha_venta <= '2024-03-10'

        UNION ALL

        SELECT fecha_venta, cantidad * precio_unitario AS total, 'Segunda quincena' AS canal
        FROM ventas
        WHERE fecha_venta > '2024-03-10'
    )
    SELECT
        canal,
        COUNT(*)      AS cantidad_ventas,
        SUM(total)    AS total_facturado
    FROM ventas_canal
    GROUP BY canal;
