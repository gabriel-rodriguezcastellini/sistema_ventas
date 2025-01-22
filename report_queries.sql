USE SistemaVentas;

-- Report 1: Total Sales by Customer
SELECT c.nombre AS cliente, SUM(dp.cantidad * dp.precio_unitario) AS total_ventas
FROM Clientes AS c
JOIN Pedidos AS p ON c.cliente_id = p.cliente_id
JOIN Detalles_Pedido AS dp ON p.pedido_id = dp.pedido_id
GROUP BY c.nombre
ORDER BY total_ventas DESC;

-- Report 2: Products with Low Stock
SELECT nombre, stock
FROM Productos
WHERE stock < 10
ORDER BY stock ASC;

-- Report 3: Monthly Sales
SELECT DATE_FORMAT(p.fecha_pedido, '%Y-%m') AS mes, SUM(dp.cantidad * dp.precio_unitario) AS total_ventas
FROM Pedidos AS p
JOIN Detalles_Pedido AS dp ON p.pedido_id = dp.pedido_id
GROUP BY mes
ORDER BY mes DESC;

-- Report 4: Top Selling Products
SELECT pr.nombre AS producto, SUM(dp.cantidad) AS total_vendido
FROM Productos AS pr
JOIN Detalles_Pedido AS dp ON pr.producto_id = dp.producto_id
GROUP BY pr.nombre
ORDER BY total_vendido DESC;