 /*
autor: Kevin Herrera
FECHA: 02/04/2014
Descripcion: Procedimiento que devuelve los datos por evento.               
*/

 PROCEDURE INFOEVENTO
 (
   PHORARIO  IN DBAFISICC.CARESERVHORATMP.CODIGO%TYPE,
   RETVAL    OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 
  
         SELECT A.CODIGO, TO_CHAR(A.FECHASOLIC, 'dd/MM/yyyy') FECHASOLIC, 
         A.DESCRIPCION, A.USUARIO || ' - ' || A.SOLICITANTE SOLICITANTE, A.CUPO,
         A.EMAIL, B.DESCRIPCION TIPO, C.SOLICITUD
                
                 FROM DBAFISICC.CARESERVHORATMP A, DBAFISICC.CAUSOSALONTB B, 
                  DBAFISICC.SOSOLINFOTRAMITETB C
                 WHERE A.CODIGO = PHORARIO
                 AND C.CAMPOC = A.CODIGO
                 AND B.USO = A.USO;
                 
  END INFOEVENTO;
