/*
autor: Kevin Herrera
FECHA: 04/04/2014
Descripcion: Procedimiento que devuelve los cursos impartidos por fecha y
             carrera.

*/

PROCEDURE CURSOSIMPARTIDOSXFECHA  
 (
   PCARRERA DBAFISICC.CAALUMNOSNOTASTB.CARRERA%TYPE DEFAULT NULL,
   PFECHAIMP varchar2,
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 
  
   SELECT DISTINCT A.CURSO, DBAFISICC.PKG_CURSO.NOMBRE(A.CURSO, A.CARRERA, 
                   B.PENSUM, 1) AS NOMBRE
                   
     FROM DBAFISICC.CAALUMNOSNOTASTB A,DBAFISICC.CAHCURSOSIMPTB B
     WHERE A.CURSO=B.CURSO 
     AND A.CODSTATUS = 'S7'
     AND A.TIPOASIG='AS' 
     AND A.CARRERA=PCARRERA
     AND TO_CHAR(A.FECHAIMP,'MM/yyyy')=PFECHAIMP
     AND B.CURSO = A.CURSO
     AND B.CARRERA = A.CARRERA
     AND B.SECCION = A.SECCION
     AND B.TIPOASIG = A.TIPOASIG
     AND B.FECHAIMP = A.FECHAIMP
   order by a.curso;

END CURSOSIMPARTIDOSXFECHA;


