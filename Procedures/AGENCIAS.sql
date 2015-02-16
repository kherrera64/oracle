 /*
autor: Kevin Herrera
FECHA: 22/03/2014
Descripcion: Procedimiento que devuelve las agencias bancarias segun el 
            codigo de agencia.
*/

PROCEDURE AGENCIAS
(
  PAGENCIA DBAFISICC.MQAGENCIASTB.AGENCIA%TYPE DEFAULT NULL,
  RETVAL    OUT SYS_REFCURSOR
)
  IS
  BEGIN
  OPEN RETVAL FOR

    SELECT AGENCIA, NOMBRE
        FROM DBAFISICC.MQAGENCIASTB
        WHERE (AGENCIA = PAGENCIA OR PAGENCIA IS NULL)
    ORDER BY nombre;

END AGENCIAS;