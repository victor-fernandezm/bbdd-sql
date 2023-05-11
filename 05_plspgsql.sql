-- función sin parametro de entrada para devolver el precio máximo

CREATE OR REPLACE FUNCTION max_precio() returns float as $$
DECLARE
    salida products.unit_price%TYPE;
BEGIN
    SELECT MAX(unit_price) INTO salida FROM products;
    RETURN salida;
END;
$$ language 'plpgsql';

SELECT max_precio();


--parametro de entrada
--Obtener el numero de ordenes por empleado

CREATE OR REPLACE FUNCTION num_ordenes_por_empleado(empleado int) returns int as $$
DECLARE
    salida int;
BEGIN
    SELECT COUNT(order_id) INTO salida FROM orders WHERE employee_id = empleado;
    RETURN salida;
END;
$$ language 'plpgsql';

SELECT num_ordenes_por_empleado(5);


-- Obtener la venta de un empleado con un determinado producto

CREATE OR REPLACE FUNCTION venta_empleado_producto(empleado int, producto int) returns int as $$
DECLARE
    salida int;
BEGIN
    SELECT SUM(quantity) INTO salida FROM orders o INNER JOIN order_details d ON o.order_id = d.order_id WHERE o.employee_id = empleado AND d.product_id = producto;
    RETURN salida;
END;
$$ language 'plpgsql';

SELECT venta_empleado_producto(5, 4);


-- Crear una funcion para devolver una tabla con producto_id, nombre, precio y unidades en strock, debe obtener los productos terminados en n

CREATE OR REPLACE FUNCTION get_productos_terminados_n()
returns table(
    product_id products.product_id%TYPE,
    product_name products.product_name%TYPE,
    price products.unit_price%TYPE,
    stock products.units_in_stock%TYPE
) as $$
DECLARE
BEGIN
    RETURN QUERY 
        SELECT product_id, product_name, unit_price, units_in_stock FROM products
        WHERE product_name LIKE '%n';
END;
$$ language 'plpgsql';

SELECT * FROM get_productos_terminados_n();


-- Creamos la función contador_ordenes_anio()
-- QUE CUENTE LAS ORDENES POR AÑO devuelve una tabla con año y contador

CREATE OR REPLACE FUNCTION contador_ordenes_anio()
returns table(
    anio NUMERIC,
    contador BIGINT
) as $$
DECLARE
BEGIN
    RETURN QUERY 
        SELECT EXTRACT('Year' FROM order_date) as yr, COUNT(order_id) FROM orders
        GROUP BY yr;
END;
$$ language 'plpgsql';

SELECT * FROM contador_ordenes_anio();


-- Lo mismo que el ejemplo anterior pero con un parametro de entrada que sea el año

CREATE OR REPLACE FUNCTION contador_ordenes_anio(in_anio NUMERIC)
returns table(
    anio NUMERIC,
    contador BIGINT
) as $$
DECLARE
BEGIN
    RETURN QUERY 
        SELECT EXTRACT('Year' FROM order_date) as yr, COUNT(order_id) FROM orders
        WHERE EXTRACT('Year' FROM order_date) = in_anio
        GROUP BY yr;
END;
$$ language 'plpgsql';

SELECT * FROM contador_ordenes_anio(2023);


-- PROCEDIMIENTO ALMACENADO PARA OBTENER PRECIO PROMEDIO Y SUMA DE 
-- UNIDADES EN STOCK POR CATEGORIA

CREATE OR REPLACE FUNCTION precio_promedio_suma_stock_por_categoria(categoria INT)
returns table(
    category_id SMALLINT,
    precio_promedio DOUBLE PRECISION,
    unidades_totales BIGINT
) as $$
DECLARE
BEGIN
    RETURN QUERY
        SELECT p.category_id, AVG(unit_price), SUM(units_in_stock) FROM products p
        WHERE p.category_id = categoria
        GROUP BY p.category_id;
END;
$$ language 'plpgsql';

SELECT * FROM precio_promedio_suma_stock_por_categoria(1);
