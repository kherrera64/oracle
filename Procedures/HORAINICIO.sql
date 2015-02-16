/*
Autor: Kevin Herrera.
Fecha: 25/06/2014
Descripcion: Procedimiento creado para obtener las horas en las que inician
             los cursos por fecha en el modulo de asistencia.
*/

 PROCEDURE HORAINICIO
  (
    PFECHA     IN  DBAFISICC.CAMAINHORARIOSTB.FECHAINI%type default null,
    retval     out sys_refcursor
  )
  IS  BEGIN
  OPEN RETVAL FOR   
      
     SELECT 'TODAS' HORA
         from dual
     UNION SELECT DISTINCT(TO_CHAR(A.HORAINI,'hh24:mi')) HORA
              
          FROM DBAFISICC.CAHORARIOSTB A, DBAFISICC.CAMAINHORARIOSTB B 
          WHERE TRUNC(PFECHA)  BETWEEN TRUNC(B.FECHAINI) AND TRUNC(B.FECHAFIN)
          AND B.HORARIO=A.HORARIO 
     
      ORDER BY HORA;

 END HORAINICIO;