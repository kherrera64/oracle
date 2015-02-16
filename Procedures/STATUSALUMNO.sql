/*
autor: Kevin Herrera
FECHA: 02/05/2014
Descripcion: Procedimiento que devuelve los datos de la tabla GNSTATALUMSTB.
*/

PROCEDURE STATUSALUMNO  
 (
   RETVAL  OUT SYS_REFCURSOR
 ) 
  AS BEGIN
  OPEN RETVAL FOR   
  
  SELECT STATALUM, NOMBRE 
  
    FROM DBAFISICC.GNSTATALUMSTB;

END STATUSALUMNO;  