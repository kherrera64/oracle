 /*
autor: Kevin Herrera
FECHA: 05/05/2014
Descripcion: Procedimiento que devuelve los datos de la tabla GNTIPODOCTOSTB.
*/

PROCEDURE TIPODOCUMENTOS  
 (
   RETVAL  OUT SYS_REFCURSOR
 ) 
  AS BEGIN
  OPEN RETVAL FOR   
  
     SELECT TIPODOCTO, NOMBRE 
        
        FROM DBAFISICC.GNTIPODOCTOSTB 
     ORDER BY TIPODOCTO;

END TIPODOCUMENTOS;  