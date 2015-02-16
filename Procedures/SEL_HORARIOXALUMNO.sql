 /*
  Nombre: SEL_HORARIOXALUMNO
  Autor: Luis Merida
  Fecha: 17/07/2014
  Paquete: PKG_REPORTES
  Descripcion: El procedimiento devuelve los horarios por alumno
  segun los parametros carnet y carrera.
  
  Autor: Kevin Herrera
  Fecha: 18/11/2014
  Modificacion: Se agrega el parametro periodo.
*/
PROCEDURE SEL_HORARIOXALUMNO(
  PCARNET     IN DBAFISICC.caasignacionestb.CARNET%TYPE,
  PCARRERA    IN DBAFISICC.caasignacionestb.CARRERA%TYPE,
  PPERIODO    IN DBAFISICC.CAASIGNACIONESTB.PERIODO%TYPE default null,
  RETVAL      OUT SYS_REFCURSOR
)
IS BEGIN
OPEN RETVAL FOR
  
  SELECT DISTINCT
  (TO_CHAR(a.horaini,'hh24:mi')||' A '||TO_CHAR(a.horafin,'hh24:mi'))rangohora,
   TO_CHAR(a.horaini,'HH24:Mi') horaini, TO_CHAR(a.horafin,'HH24:Mi') horafin
    
     FROM  dbafisicc.cahorariostb a, dbafisicc.camainhorariostb b, 
           dbafisicc.cacurshoratb c, dbafisicc.caasignacionestb d
     WHERE  a.horario = b.horario
     and b.horario = c.horario
     and c.curso = d.curso
     and c.carrera = d.carrera
     and c.seccion = d.seccion
     and c.tipoasig = d.tipoasig
     AND b.status = 'A'
     AND d.codstatus IN('S1','S4' )
     and d.carnet = PCARNET 
     AND (d.carrera = PCARRERA or PCARRERA IS NULL)
     AND (d.periodo = PPERIODO or PPERIODO IS NULL)
   ORDER BY rangohora;
   
END SEL_HORARIOXALUMNO;