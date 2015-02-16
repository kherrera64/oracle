 /*
autor: Kevin Herrera
FECHA: 05/05/2014
Descripcion: Procedimiento que devuelve los datos de la tabla GNTIPOINSTSTB.
*/

  PROCEDURE TIPOINSTITUCIONES  
 (
   RETVAL  OUT SYS_REFCURSOR
 ) 
  AS BEGIN
  OPEN RETVAL FOR   
  
     SELECT TIPOINST, NOMBRE 
      
       FROM DBAFISICC.GNTIPOINSTSTB
     ORDER BY TIPOINST; 

END TIPOINSTITUCIONES;  