 /*
autor: Kevin Herrera
FECHA: 28/08/2014
Descripcion: Procedimiento que devuelve los alumnos por horario.               
*/

 PROCEDURE ALUMNOSXSALON
 (
   PHORARIO  IN DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE,
   RETVAL  OUT SYS_REFCURSOR
 ) 
  AS BEGIN    
  OPEN RETVAL FOR 
  
       SELECT E.HORARIO,E.DESCRIPCION, COUNT(D.CARNET) as total
              
              FROM DBAFISICC.CACURSHORATB B, DBAFISICC.CACURSOSIMPTB C,
              DBAFISICC.CAASIGNACIONESTB D, DBAFISICC.CAMAINHORARIOSTB E
              WHERE e.HORARIO = PHORARIO
              AND B.HORARIO = E.HORARIO
              AND C.CARRERA = B.CARRERA
              AND C.CURSO = B.CURSO
              AND C.TIPOASIG = B.TIPOASIG
              AND C.SECCION = B.SECCION 
              AND D.CARRERA = C.CARRERA
              AND D.CURSO = C.CURSO
              AND D.TIPOASIG = C.TIPOASIG 
              AND D.SECCION = C.SECCION
              AND D.CODSTATUS IN ('S1','S4')
          
          GROUP BY E.HORARIO,E.DESCRIPCION;
          
 END ALUMNOSXSALON;