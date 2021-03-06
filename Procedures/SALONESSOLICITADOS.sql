 /*
autor: Kevin Herrera
FECHA: 28/08/2014
Descripcion: Procedimiento que devuelve los salones solicitados.              
*/

 PROCEDURE SALONESOLICITADOS
 (
   PTORRE  IN DBAFISICC.CAHORARIOSTMP.TORRE%TYPE,
   PNIVEL  IN DBAFISICC.CAHORARIOSTMP.SALON%TYPE,
   PFECHA  IN DBAFISICC.CAMAINHORARIOSTMP.FECHAINI%TYPE,
   PDIA    IN DBAFISICC.CAHORARIOSTMP.DIA%TYPE,
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 

        SELECT DISTINCT A.HORARIO, (A.SALON), TO_CHAR(A.HORAINI,'HH24:MI') 
        AS HORAINI, TO_CHAR(A.HORAFIN,'HH24:MI')AS HORAFIN
        
            FROM DBAFISICC.CAHORARIOSTMP A, DBAFISICC.CAMAINHORARIOSTMP B
            WHERE A.TORRE= PTORRE 
            AND A.SALON LIKE PNIVEL || '%'
            AND TRUNC(PFECHA) BETWEEN TRUNC(B.FECHAINI) AND TRUNC(B.FECHAFIN) 
            AND A.DIA = PDIA
            AND B.HORARIO=A.HORARIO;
 
 END SALONESOLICITADOS; 