/*
Autor: Kevin Herrera
FECHA: 30/07/2014
Descripcion: Procedimiento que devuelve los usuarios de tutores IDEA. 

autor: Kevin Herrera
FECHA: 07/08/2014
Modificacion: Se descartan los usuarios con tipo 4 en la consulta.   
*/

 PROCEDURE TUTORESIDEA  
 (
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 
  
            SELECT UPPER(A.USUARIO) USUARIO, A.TIPO, 
            NVL(A.GMAIL, B.EMAIL) CORREO,
            B.CORRELATIVO, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' ||  B.APELLIDO1 
            || ' ' || B.APELLIDO2 NOMBRE, B.TUTOR, B.CODPERS, A.TIPO
               
               FROM CACARNETUSUARIOTB A, NOPERSONALTB B
               WHERE (A.TIPO in (2, 3) OR B.TUTOR IS NOT NULL)
               AND A.CORRELATIVO = B.CORRELATIVO
               AND A.TIPO NOT IN(1,4);
               
 END TUTORESIDEA;