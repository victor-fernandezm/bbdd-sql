-- EJERCICIOS
/*

1 - Escriba un bloque de codigo PL/pgSQL que reciba una nota como parametro
    y notifique en la consola de mensaje las letras A,B,C,D,E o F segun el valor de la nota

*/

DO $$
DECLARE
    nota int := 10;
BEGIN
    CASE nota
        WHEN 10,9 THEN
            RAISE NOTICE 'A';
        WHEN 8 THEN
            RAISE NOTICE 'B';
        WHEN 7 THEN 
            RAISE NOTICE 'C';
        WHEN 6 THEN
            RAISE NOTICE 'D';
        WHEN 5 THEN
            RAISE NOTICE 'E';
        ELSE
            RAISE NOTICE 'F';
    END CASE;   
END;
$$ language 'plpgsql';

/*
2 - Escriba un bloque de codigo PL/pgSQL que reciba un numero como parametro
    y muestre la tabla de multiplicar de ese numero.
*/

DO $$
DECLARE
    num int := 4;
BEGIN
    FOR i IN 1..10 LOOP
        RAISE NOTICE '% x % = %', num, i, num*i;
    END LOOP;
END;
$$ language 'plpgsql';

/*
3 - Escriba una funcion PL/pgSQL que convierta de dolares a moneda nacional.
    La funcion debe recibir dos parametros, cantidad de dolares y tasa de cambio.
    Al final debe retornar el monto convertido a moneda nacional.
*/

CREATE OR REPLACE FUNCTION dolares_a_moneda_nacional(dolares float, tasa_cambio float) returns float language plpgsql as $$
DECLARE
BEGIN
    RETURN dolares*tasa_cambio;
END;
$$;

SELECT dolares_a_moneda_nacional(27, 0.1);

/*

4 - Escriba una funcion PL/pgSQL que reciba como parametro el monto de un prestamo,
    su duracion en meses y la tasa de interes, retornando el monto de la cuota a pagar.
    Aplicar el metodo de amortizacion frances.

*/

CREATE OR REPLACE FUNCTION amortizacion_francesa(monto float, duracion float, tasa_interes float) returns float language plpgsql as $$
DECLARE
    interes float;
BEGIN
    interes := tasa_interes / 100 / 12;
    RETURN (monto*interes)/(1-(1+interes)^(-duracion));
END;
$$;

SELECT amortizacion_francesa(100000, 12, 10);
