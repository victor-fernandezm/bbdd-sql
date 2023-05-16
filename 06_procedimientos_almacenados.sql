DROP DATABASE IF EXISTS banco;
CREATE DATABASE banco;

-- Crear dos tablas la de cuentas con id, saldo, la otra de movimientos con id, tipo de movimiento y monto
CREATE TABLE cuentas(
    id_cuenta SERIAL PRIMARY KEY,
    saldo FLOAT
);

CREATE TABLE movimientos(
    id_movimiento SERIAL PRIMARY KEY,
    id_cuenta INT,
    tipo_movimiento VARCHAR(30),
    monto FLOAT,
    CONSTRAINT movimiento_cuenta_fk FOREIGN KEY (id_cuenta) REFERENCES cuentas(id_cuenta)
);


-- Realizar un pa que: inserte en la tabla de movimientos y actualice el saldo en una transacción

CREATE OR REPLACE PROCEDURE hacer_movimiento(cuenta INT, movimiento VARCHAR(30), cantidad FLOAT) as $$
BEGIN
    IF NOT EXISTS (SELECT id_cuenta FROM cuentas WHERE id_cuenta = cuenta) THEN
        ROLLBACK;
        RAISE EXCEPTION 'La cuenta % no existe.', cuenta;
    END IF;

    IF cantidad < 0 THEN
        ROLLBACK;
        RAISE EXCEPTION 'No puedes hacer un movimiento de tipo % con un valor negativo.', movimiento;
    END IF;

    IF UPPER(movimiento) = 'INGRESO' THEN
        INSERT INTO movimientos(tipo_movimiento, monto) VALUES ('INGRESO', cantidad);

        UPDATE cuentas SET saldo = saldo + cantidad WHERE id_cuenta = cuenta;
    ELSIF UPPER(movimiento) = 'RETIRO' THEN
        IF (SELECT saldo FROM cuentas WHERE id_cuenta = cuenta) < cantidad THEN
            ROLLBACK;
            RAISE EXCEPTION 'No tienes suficiente saldo en la cuenta para retirar la cantidad solicitada.';
        END IF;
        INSERT INTO movimientos(tipo_movimiento, monto) VALUES ('RETIRO', cantidad);

        UPDATE cuentas SET saldo = saldo - cantidad WHERE id_cuenta = cuenta;
    ELSE
        ROLLBACK;
        RAISE EXCEPTION 'El movimiento de tipo "%" no es válido.', movimiento;
    END IF;

    COMMIT;
    
    -- EXCEPTION
    --     WHEN P0001 THEN
    --         RAISE NOTICE 'OOPS. ERROR';
    --     WHEN OTHERS THEN
    --         RAISE NOTICE 'OTRA EXCEPCION NO CONTROLADA';
END;
$$ language 'plpgsql';

-- Este tendria que dar error
CALL ingresa_saldo(99,5);

-- insertamlos datos para probar el procedimiento
INSERT INTO cuentas(saldo) VALUES (0);
INSERT INTO cuentas(saldo) VALUES (10);
INSERT INTO cuentas(saldo) VALUES (50);
INSERT INTO cuentas(saldo) VALUES (1000);

SELECT * FROM cuentas;
SELECT * FROM movimientos;

CALL ingresa_saldo(1, 'ingreso', 5);
CALL ingresa_saldo(2, 'retiro', 3);


-- trigger para el registro de movimientos

CREATE TABLE pista_auditoria(
    id_pista SERIAL PRIMARY KEY,
    descripcion VARCHAR(100)
);

CREATE OR REPLACE FUNCTION cambia_saldo() returns TRIGGER as $$
BEGIN
    IF UPPER(new.tipo_movimiento) = 'INGRESO' THEN
        UPDATE cuentas SET saldo = saldo + new.monto WHERE id_cuenta = new.id_cuenta;
    ELSIF UPPER(new.tipo_movimiento) = 'RETIRO' THEN
        UPDATE cuentas SET saldo = saldo - new.monto WHERE id_cuenta = new.id_cuenta;
    ELSE
        RETURN old;
    END IF;
    RETURN new;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_cambia_saldo 
BEFORE INSERT ON movimientos
FOR EACH ROW
EXECUTE FUNCTION cambia_saldo();


CREATE OR REPLACE FUNCTION crea_movimiento() returns TRIGGER as $$
BEGIN
    IF new.saldo > old.saldo THEN
        INSERT INTO movimientos(id_cuenta, tipo_movimiento, monto) VALUES (new.id_cuenta, 'INGRESO', new.saldo - old.saldo);
    ELSIF new.saldo < old.saldo THEN
        INSERT INTO movimientos(id_cuenta, tipo_movimiento, monto) VALUES (new.id_cuenta, 'RETIRO', old.saldo - new.saldo);
    ELSE
        RETURN old;
    END IF;
    RETURN new;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_crea_movimiento 
BEFORE UPDATE ON cuentas
FOR EACH ROW
EXECUTE FUNCTION crea_movimiento();
