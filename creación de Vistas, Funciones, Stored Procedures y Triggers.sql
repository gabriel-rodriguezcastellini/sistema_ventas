CREATE VIEW vista_pedidos_clientes AS
SELECT p.pedido_id, c.nombre AS cliente, c.email, p.fecha_pedido
FROM Pedidos p
JOIN Clientes c ON p.cliente_id = c.cliente_id;

CREATE VIEW vista_stock_productos AS
SELECT producto_id, nombre, precio, stock
FROM Productos;

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
