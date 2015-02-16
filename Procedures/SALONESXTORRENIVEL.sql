 /*
autor: Kevin Herrera
FECHA: 28/08/2014
Descripcion: Procedimiento que devuelve los salones por torre y nivel.               
*/

 PROCEDURE SALONESXTORRENIVEL  
 (
   PTORRE  IN DBAFISICC.CASALONESTB.TORRE%TYPE,
   PNIVEL  IN DBAFISICC.CASALONESTB.SALON%TYPE,
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  open RETVAL for 
  
      SELECT SALON,CUPO
          FROM DBAFISICC.CASALONESTB
          WHERE TORRE= PTORRE
          AND SALON LIKE PNIVEL || '%'
      order by salon;
    
 END SALONESXTORRENIVEL; 