/*
  Nombre: SEL_CURSOSXALUMNO
  Autor: Luis Merida
  Fecha: 17/07/2014
  Paquete: PKG_REPORTES
  Descripcion: El procedimiento devuelve los cursos por docente
  segun el parametro carnet, carrera, dia y rango de hora.
    
  Autor: Kevin Herrera
  Fecha: 18/11/2014
  Modificacion: Se agrega el parametro periodo.
*/
PROCEDURE SEL_CURSOSXALUMNO(
  PDIA        IN DBAFISICC.cahorariostb.dia%TYPE,
  PHORA       VARCHAR2,
  PCARNET     IN DBAFISICC.caasignacionestb.CARNET%TYPE,
  PCARRERA    IN DBAFISICC.caasignacionestb.CARRERA%TYPE,
  PPERIODO    IN DBAFISICC.CAASIGNACIONESTB.PERIODO%TYPE default null,
  RETVAL      OUT SYS_REFCURSOR
)
IS BEGIN
  OPEN RETVAL FOR  
  
   SELECT b.descripcion CURSO_NOMBRE, e.nombretorre TORRE, a.salon, c.carrera,
          d.periodo
      FROM dbafisicc.cahorariostb a, dbafisicc.camainhorariostb b, 
           dbafisicc.cacurshoratb c, dbafisicc.caasignacionestb d, 
           dbafisicc.CATORRESTB e 
      WHERE a.horario = b.horario
      and b.horario = c.horario
      and c.curso = d.curso
      and c.carrera = d.carrera
      and c.seccion = d.seccion
      and c.tipoasig = d.tipoasig
      AND b.status = 'A'
      and a.torre = e.codigotorre
      AND d.codstatus IN('S1','S4' )
      AND a.dia = PDIA
      AND TO_CHAR(a.horaini,'HH24:Mi')||' A '||
          TO_CHAR(a.horafin,'HH24:Mi') = PHORA
      and d.carnet = PCARNET 
      AND (d.carrera = PCARRERA or PCARRERA IS NULL)
      AND (d.periodo = PPERIODO or PPERIODO IS NULL);
      
END SEL_CURSOSXALUMNO;