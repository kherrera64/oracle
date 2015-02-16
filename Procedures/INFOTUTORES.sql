 /*
autor: Kevin Herrera
FECHA: 30/07/2014
Descripcion: Procedimiento que devuelve los datos de tutor.               
*/

 PROCEDURE INFOTUTORES  
 (
    PCORRELATIVO IN DBAFISICC.NOPERSONALTB.CORRELATIVO%TYPE, 
    PTIPO        IN DBAFISICC.CACARNETUSUARIOTB.TIPO%TYPE,
    RETVAL       OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 
  
        SELECT A.TIPO, B.CODPERS, B.CORRELATIVO, B.TUTOR, 
              ( SELECT COUNT(*)
                    FROM DBAFISICC.LOGSESIONESTB C
                    WHERE C.TIPO IN (2,3)
                    AND C.USUARIO= A.USUARIO) INGRESOS  
               
               FROM DBAFISICC.CACARNETUSUARIOTB A, DBAFISICC.NOPERSONALTB B
               WHERE (A.TIPO=3 OR B.TUTOR IS NOT NULL)
               AND A.CORRELATIVO = B.CORRELATIVO
               AND B.CORRELATIVO = PCORRELATIVO
               AND A.TIPO = PTIPO;
               
 END INFOTUTORES;