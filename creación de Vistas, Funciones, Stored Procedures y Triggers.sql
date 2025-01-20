USE SistemaVentas;

-- Vistas
DROP VIEW IF EXISTS vista_pedidos_clientes;
CREATE VIEW vista_pedidos_clientes AS
SELECT p.pedido_id, c.nombre AS cliente, c.email, p.fecha_pedido
FROM Pedidos AS p
JOIN Clientes AS c ON p.cliente_id = c.cliente_id;

DROP VIEW IF EXISTS vista_stock_productos;
CREATE VIEW vista_stock_productos AS
SELECT producto_id, nombre, precio, stock
FROM Productos;

-- Funciones
DROP FUNCTION IF EXISTS calcular_total_pedido;
DELIMITER //
CREATE FUNCTION calcular_total_pedido(pedidoID INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(cantidad * precio_unitario) INTO total
    FROM Detalles_Pedido
    WHERE pedido_id = pedidoID;
    RETURN total;
END;
//
DELIMITER ;

DROP FUNCTION IF EXISTS contar_articulos_con_stock;
DELIMITER //
CREATE FUNCTION contar_articulos_con_stock() RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Productos
    WHERE stock > 0;
    RETURN total;
END;
//
DELIMITER ;

-- Procedimientos
DROP PROCEDURE IF EXISTS insertar_pedido;
DELIMITER //
CREATE PROCEDURE insertar_pedido(
    IN clienteID INT,
    IN fecha DATE,
    IN productoID INT,
    IN cantidad INT,
    IN precio DECIMAL(10,2)
)
BEGIN
    DECLARE nuevoPedidoID INT;
    
    INSERT INTO Pedidos (cliente_id, fecha_pedido)
    VALUES (clienteID, fecha);
    
    SET nuevoPedidoID = LAST_INSERT_ID();
    
    INSERT INTO Detalles_Pedido (pedido_id, producto_id, cantidad, precio_unitario)
    VALUES (nuevoPedidoID, productoID, cantidad, precio);    
END;
//
DELIMITER ;

DROP PROCEDURE IF EXISTS actualizar_precio_producto;
DELIMITER //
CREATE PROCEDURE actualizar_precio_producto(
    IN productoID INT,
    IN nuevoPrecio DECIMAL(10,2)
)
BEGIN
    UPDATE Productos
    SET precio = nuevoPrecio
    WHERE producto_id = productoID;
END;
//
DELIMITER ;

-- Triggers
DROP TRIGGER IF EXISTS actualizar_stock;
DELIMITER //
CREATE TRIGGER actualizar_stock
AFTER INSERT ON Detalles_Pedido
FOR EACH ROW
BEGIN
    UPDATE Productos
    SET stock = stock - NEW.cantidad
    WHERE producto_id = NEW.producto_id;
END;
//
DELIMITER ;

DROP TRIGGER IF EXISTS actualizar_fecha_pedido;
DELIMITER //
CREATE TRIGGER actualizar_fecha_pedido
BEFORE UPDATE ON Pedidos
FOR EACH ROW
BEGIN
    SET NEW.fecha_pedido = CURDATE();
END;
//
DELIMITER ;
