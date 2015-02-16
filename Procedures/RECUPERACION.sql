 /*
autor: Kevin Herrera
FECHA: 04/04/2014
Descripcion: Procedimiento que devuelve los datos de alumnos con cursos
             reprobados.
*/

PROCEDURE RECUPERACION  
 (
   PCARRERA DBAFISICC.CAALUMNOSNOTASTB.CARRERA%TYPE DEFAULT NULL,
   PCURSO DBAFISICC.CAALUMNOSNOTASTB.CURSO%TYPE DEFAULT NULL,
   PFECHAIMP varchar2,
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR    
   
       SELECT A.CURSO, DBAFISICC.PKG_CURSO.NOMBRE(A.CURSO, A.CARRERA, 
       B.PENSUM, 1) AS NOMCURSO, A.SECCION,A.CARNET, 
       C.APELLIDO1|| ' '|| C.APELLIDO2|| ' '|| C.NOMBRE1|| ' '|| 
       C.nombre2 AS nombre,A.NOTA
        
         FROM DBAFISICC.CAALUMNOSNOTASTB A, DBAFISICC.CAHCURSOSIMPTB B, 
         DBAFISICC.CAALUMNOSTB C
         WHERE A.CARNET=C.CARNET 
         AND A.CODSTATUS = 'S7' 
         AND A.TIPOASIG='AS' 
         AND A.FECHAIMP = B.FECHAIMP
         AND A.CARRERA=PCARRERA
         AND TO_CHAR(A.FECHAIMP,'MM/yyyy')=PFECHAIMP
         AND B.Curso = A.Curso
         AND B.CARRERA = A.CARRERA
         AND B.SECCION = A.SECCION
         AND B.TIPOASIG = A.TIPOASIG
         AND (A.CURSO=PCURSO OR PCURSO IS NULL)
       ORDER BY NOMCURSO, A.SECCION;

END RECUPERACION;      