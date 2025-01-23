
CREATE DATABASE IF NOT EXISTS TiendaVirtual;
USE TiendaVirtual;

DROP VIEW IF EXISTS Vista_Productos_Stock;
DROP VIEW IF EXISTS Vista_Ventas_Totales;
DROP VIEW IF EXISTS Vista_Clientes_Activos;
DROP VIEW IF EXISTS Vista_Pedidos_Completados;
DROP VIEW IF EXISTS Vista_Inventario_Bajo;

DROP PROCEDURE IF EXISTS ObtenerVentasPorCategoria;
DROP PROCEDURE IF EXISTS ResumenDeInventario;

DROP TRIGGER IF EXISTS ActualizarStock;
DROP TRIGGER IF EXISTS RegistroDevolucion;
DROP TRIGGER IF EXISTS RegistroTransaccion;

DROP FUNCTION IF EXISTS CalcularDescuento;
DROP FUNCTION IF EXISTS ObtenerStockDisponible;

CREATE TABLE Categorias (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(50) NOT NULL
);

CREATE TABLE Proveedores (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Contacto VARCHAR(100)
);

CREATE TABLE Productos (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    CategoriaID INT NOT NULL,
    ProveedorID INT NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    FOREIGN KEY (CategoriaID) REFERENCES Categorias(ID),
    FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ID)
);

CREATE TABLE Clientes (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    Nombre VARCHAR(100) NOT NULL,
    Correo VARCHAR(100) NOT NULL UNIQUE,
    Telefono VARCHAR(15)
);

CREATE TABLE Pedidos (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ClienteID INT,
    Fecha DATETIME NOT NULL,
    Estado VARCHAR(50) NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ID)
);

CREATE TABLE DetallesPedidos (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT,
    ProductoID INT,
    Cantidad INT NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(ID),
    FOREIGN KEY (ProductoID) REFERENCES Productos(ID)
);

CREATE TABLE Inventario (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT,
    NivelStock INT NOT NULL,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ID)
);

CREATE TABLE Transacciones (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT NOT NULL,
    Tipo VARCHAR(50) NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    Fecha DATETIME NOT NULL,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(ID)
);

CREATE TABLE Pagos (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT,
    MetodoPago VARCHAR(50) NOT NULL,
    Fecha DATETIME NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(ID)
);

CREATE TABLE HistorialPrecios (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT,
    Fecha DATETIME NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ID)
);

CREATE TABLE DireccionesClientes (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ClienteID INT,
    Direccion VARCHAR(255) NOT NULL,
    Ciudad VARCHAR(50) NOT NULL,
    Pais VARCHAR(50) NOT NULL,
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ID)
);

CREATE TABLE Devoluciones (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT,
    Fecha DATETIME NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(ID)
);

CREATE TABLE Ofertas (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT,
    Descuento INT NOT NULL,
    FechaInicio DATETIME NOT NULL,
    FechaFin DATETIME NOT NULL,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ID)
);

CREATE TABLE OpinionesClientes (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    ProductoID INT,
    ClienteID INT,
    Opinion TEXT NOT NULL,
    Fecha DATETIME NOT NULL,
    FOREIGN KEY (ProductoID) REFERENCES Productos(ID),
    FOREIGN KEY (ClienteID) REFERENCES Clientes(ID)
);

CREATE TABLE Facturas (
    ID INT PRIMARY KEY AUTO_INCREMENT,
    PedidoID INT,
    Fecha DATETIME NOT NULL,
    MontoTotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (PedidoID) REFERENCES Pedidos(ID)
);

CREATE VIEW Vista_Productos_Stock AS
SELECT p.ID AS ProductoID, p.Nombre AS NombreProducto, p.Stock AS StockDisponible
FROM Productos p
WHERE p.Stock > 0;

CREATE VIEW Vista_Ventas_Totales AS
SELECT p.Nombre AS Producto, SUM(dp.Cantidad * dp.Precio) AS TotalVentas
FROM DetallesPedidos dp
JOIN Productos p ON dp.ProductoID = p.ID
GROUP BY p.Nombre;

CREATE VIEW Vista_Clientes_Activos AS
SELECT c.ID AS ClienteID, c.Nombre AS NombreCliente, COUNT(p.ID) AS TotalPedidos
FROM Clientes c
LEFT JOIN Pedidos p ON c.ID = p.ClienteID
GROUP BY c.ID, c.Nombre;

CREATE VIEW Vista_Pedidos_Completados AS
SELECT p.ID AS PedidoID, c.Nombre AS Cliente, p.Fecha, p.Estado
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ID
WHERE p.Estado = 'Completado';

CREATE VIEW Vista_Inventario_Bajo AS
SELECT p.ID AS ProductoID, p.Nombre AS NombreProducto, p.Stock AS StockDisponible
FROM Productos p
WHERE p.Stock < 10;

DELIMITER //
CREATE PROCEDURE ObtenerVentasPorCategoria()
BEGIN
    SELECT c.Nombre AS Categoria, SUM(dp.Cantidad * dp.Precio) AS TotalVentas
    FROM DetallesPedidos dp
    JOIN Productos p ON dp.ProductoID = p.ID
    JOIN Categorias c ON p.CategoriaID = c.ID
    GROUP BY c.Nombre;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ResumenDeInventario()
BEGIN
    SELECT p.Nombre AS Producto, i.NivelStock AS StockActual
    FROM Inventario i
    JOIN Productos p ON i.ProductoID = p.ID;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER ActualizarStock AFTER INSERT ON DetallesPedidos
FOR EACH ROW
BEGIN
    UPDATE Productos SET Stock = Stock - NEW.Cantidad WHERE ID = NEW.ProductoID;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER RegistroDevolucion AFTER INSERT ON Devoluciones
FOR EACH ROW
BEGIN    
    INSERT INTO Transacciones (PedidoID, Tipo, Monto, Fecha)
    VALUES (NEW.PedidoID, 'Devolución', NEW.Monto, NEW.Fecha);
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER RegistroTransaccion AFTER INSERT ON DetallesPedidos
FOR EACH ROW
BEGIN
    DECLARE totalMonto DECIMAL(10, 2);
    
    SELECT SUM(dp.Cantidad * dp.Precio) INTO totalMonto
    FROM DetallesPedidos dp
    WHERE dp.PedidoID = NEW.PedidoID;
    
    IF EXISTS (SELECT 1 FROM Transacciones WHERE PedidoID = NEW.PedidoID) THEN        
        UPDATE Transacciones
        SET Monto = totalMonto, Fecha = NOW()
        WHERE PedidoID = NEW.PedidoID;
    ELSE        
        INSERT INTO Transacciones (PedidoID, Tipo, Monto, Fecha)
        VALUES (NEW.PedidoID, 'Venta', totalMonto, NOW());
    END IF;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION CalcularDescuento(Monto DECIMAL(10, 2), Porcentaje INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    RETURN Monto - (Monto * Porcentaje / 100);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION ObtenerStockDisponible(ProductoID INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE Stock INT;
    
    SELECT NivelStock INTO Stock
    FROM Inventario
    WHERE ProductoID = ProductoID
    LIMIT 1;

    RETURN Stock;
END //
DELIMITER ;
