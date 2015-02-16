 /*
autor: Kevin Herrera
FECHA: 02/04/2014
Descripcion: Procedimiento que devuelve los datos de salon.               
*/

 PROCEDURE INFOSALON
 (
   PHORARIO  IN DBAFISICC.CARESERVHORATMP.CODIGO%TYPE,
   PTORRE  IN DBAFISICC.CASALONESTB.TORRE%TYPE,
   PSALON  IN DBAFISICC.CASALONESTB.SALON%TYPE,
   RETVAL    OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 
  
        SELECT A.HORARIO, A.DESCRIPCION, TO_CHAR(A.FECHAINI, 'dd/MM/yyyy') 
        FECHAINI, to_char(A.FECHAFIN, 'dd/MM/yyyy') FECHAFIN, A.CARHORA CARRERA, 
        B.INTERNET, B.PROYECTOR
              
              FROM DBAFISICC.CAMAINHORARIOSTB A, DBAFISICC.CASALONESTB B 
              WHERE A.HORARIO = PHORARIO
              AND B.TORRE = PTORRE
              AND B.SALON LIKE  '%' || PSALON || '%';
                 
  END INFOSALON;