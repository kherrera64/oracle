/*
Autor: Kevin Herrera.
Fecha: 25/06/2014
Descripcion: Procedimiento creado para obtener las fechas de impartido en el 
             modulo de asistencia.
*/

 PROCEDURE ASISTENCIA_FECHAIMP
  (
    retval     out sys_refcursor
  )
  IS  BEGIN
  OPEN RETVAL FOR   
      
      SELECT '0' FECHAIMP, ' TODAS' FECHAIMP2 
            from dual
      UNION SELECT DISTINCT TO_CHAR(FECHAIMP, 'MM/yyyy') AS FECHAIMP,  
      TO_CHAR(FECHAIMP, 'dd/MM/yyyy') AS FECHAIMP2   
      
             FROM DBAFISICC.CAHASIGNASTB 
      ORDER BY FECHAIMP DESC;

 END ASISTENCIA_FECHAIMP;
