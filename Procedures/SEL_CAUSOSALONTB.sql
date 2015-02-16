 /*
autor: Kevin Herrera
FECHA: 28/08/2014
Descripcion: Procedimiento que devuelve los datos de CAUSOSALONTB.               
*/

 PROCEDURE SEL_CAUSOSALONTB  
 (
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  open RETVAL for 
  
   SELECT USO, DESCRIPCION, AUTORIZA 
      FROM DBAFISICC.CAUSOSALONTB;
    
 END SEL_CAUSOSALONTB;