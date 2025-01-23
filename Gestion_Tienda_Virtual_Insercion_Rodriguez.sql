
USE TiendaVirtual;

INSERT INTO Categorias (Nombre) VALUES
('Electrónica'), ('Hogar'), ('Ropa');

INSERT INTO Proveedores (Nombre, Contacto) VALUES
('Proveedor A', 'contacto@proveedora.com'), ('Proveedor B', 'contacto@proveedorb.com');

INSERT INTO Productos (Nombre, CategoriaID, ProveedorID, Precio, Stock) VALUES
('Laptop', 1, 1, 1500.00, 50),
('Televisor', 1, 2, 800.00, 30),
('Camisa', 3, 1, 25.00, 100),
('Sofá', 2, 2, 300.00, 10);

INSERT INTO Clientes (Nombre, Correo, Telefono) VALUES
('Juan Pérez', 'juan.perez@example.com', '123456789'),
('Ana Gómez', 'ana.gomez@example.com', '987654321');

INSERT INTO Pedidos (ClienteID, Fecha, Estado) VALUES
(1, '2025-01-28 10:00:00', 'Completado'),
(2, '2025-01-28 12:00:00', 'Pendiente');

INSERT INTO DetallesPedidos (PedidoID, ProductoID, Cantidad, Precio) VALUES
(1, 1, 1, 1500.00),
(1, 3, 2, 25.00),
(2, 2, 1, 800.00);

INSERT INTO Inventario (ProductoID, NivelStock) VALUES
(1, 49),
(2, 29),
(3, 98),
(4, 10);

INSERT INTO Transacciones (PedidoID, Tipo, Monto, Fecha) VALUES
(1, 'Venta', 1550.00, '2025-01-28 10:30:00'),
(2, 'Devolución', 50.00, '2025-01-29 12:00:00');

INSERT INTO Pagos (PedidoID, MetodoPago, Fecha, Monto) VALUES
(1, 'Tarjeta de Crédito', '2025-01-28 10:30:00', 1550.00),
(2, 'Transferencia Bancaria', '2025-01-28 12:30:00', 800.00);

INSERT INTO HistorialPrecios (ProductoID, Fecha, Precio) VALUES
(1, '2025-01-01 00:00:00', 1500.00),
(2, '2025-01-01 00:00:00', 800.00);

INSERT INTO DireccionesClientes (ClienteID, Direccion, Ciudad, Pais) VALUES
(1, 'Calle Falsa 123', 'Ciudad X', 'País Y'),
(2, 'Avenida Siempre Viva 742', 'Ciudad Z', 'País W');

INSERT INTO Devoluciones (PedidoID, Fecha, Monto) VALUES
(1, '2025-01-29 14:00:00', 50.00);

INSERT INTO Ofertas (ProductoID, Descuento, FechaInicio, FechaFin) VALUES
(1, 10, '2025-01-01 00:00:00', '2025-01-31 23:59:59');

INSERT INTO OpinionesClientes (ProductoID, ClienteID, Opinion, Fecha) VALUES
(1, 1, 'Muy buen producto', '2025-01-25 12:00:00');

INSERT INTO Facturas (PedidoID, Fecha, MontoTotal) VALUES
(1, '2025-01-28 10:45:00', 1550.00),
(2, '2025-01-28 12:45:00', 800.00);
