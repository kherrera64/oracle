 /*
autor: Kevin Herrera
FECHA: 24/04/2014
Descripcion: Procedimiento que devuelve los datos de la tabla GNHOSPITALESTB.
*/

PROCEDURE HOSPITALES  
 (
   RETVAL  OUT SYS_REFCURSOR
 ) 
  AS BEGIN
  OPEN RETVAL FOR   
  
   SELECT HOSPITAL, DESCRIPCION
       
       FROM DBAFISICC.GNHOSPITALESTB
   ORDER BY HOSPITAL;

END HOSPITALES;    