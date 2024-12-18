INSERT INTO Clientes (nombre, email, telefono) VALUES
('Juan Pérez', 'juanperez@mail.com', '123456789'),
('María Gómez', 'mariagomez@mail.com', '987654321');

INSERT INTO Productos (nombre, precio, stock) VALUES
('Laptop', 800.00, 10),
('Mouse', 20.00, 50);

INSERT INTO Pedidos (cliente_id, fecha_pedido) VALUES
(1, '2024-06-01'),
(2, '2024-06-05');

INSERT INTO Detalles_Pedido (pedido_id, producto_id, cantidad, precio_unitario) VALUES
(1, 1, 2, 800.00),
(2, 2, 5, 20.00);
