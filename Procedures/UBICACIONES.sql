/*
autor: Kevin Herrera
FECHA: 27/05/2014
Descripcion: Procedimiento que devuelve los datos de la tabla GNUBICACIONESTB.
*/

PROCEDURE UBICACIONES
(
  RETVAL    OUT SYS_REFCURSOR
)
  IS
  BEGIN
  OPEN RETVAL FOR
  
    SELECT CODIGO, DESCRIPCION 
    
        FROM DBAFISICC.GNUBICACIONESTB
    ORDER BY to_number(CODIGO);
     
 END UBICACIONES;