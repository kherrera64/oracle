   /*
autor: Kevin Herrera
FECHA: 28/03/2014
Descripcion: Procedimiento que devuelve listado de alumnos por carrera 
             con promedio y detalle de cursos.
*/
PROCEDURE RENDIMIENTOXFECHA
(
  PCARRERA DBAFISICC.cahinscritostb.carrera%TYPE DEFAULT NULL,
  PCARNET DBAFISICC.cahasignastb.carnet%TYPE DEFAULT NULL,
  PFECHAIMP VARCHAR2, 
  PACCION varchar2,
  RETVAL    OUT SYS_REFCURSOR
)
  IS
  BEGIN
  
  if PACCION = '0' then
   OPEN RETVAL FOR 
  
    SELECT A.carrera,A.carnet,A.statalum,f.nombre status, 
    dbafisicc.pkg_alumno.nombre(a.carnet,2) alumno ,count(c.curso) 
    asignados, count(d.curso) ganados, count(e.curso) perdidos, 
    to_char((sum(nvl(e.umas * e.nota,0)) + sum(nvl(d.umas * d.nota,0))) / 
    CASE WHEN (sum(nvl(e.umas,0)) + sum(nvl(d.umas,0))) = 0 THEN 1 
    else  (sum(nvl(e.umas,0)) + sum(nvl(d.umas,0))) end,'999.99') promedio

     FROM DBAFISICC.cahinscritostb A, DBAFISICC.caalumnostb b, 
     DBAFISICC.cahasignastb c, DBAFISICC.caalumnosnotastb d, 
     DBAFISICC.caalumnosnotastb e, DBAFISICC.gnstatalumstb f
     WHERE A.carrera = PCARRERA
     and TO_CHAR(a.fechainscrito,'MM/yyyy') = PFECHAIMP
     AND f.statalum = A.statalum
     AND b.carnet = A.carnet
     AND c.carrera(+) = A.carrera
     AND c.carnet(+) = A.carnet
     AND c.fechaimp(+) = A.fechainscrito
     AND d.carrera(+) = c.carrera
     and d.fechaimp(+) = c.fechaimp
     AND d.curso(+) = c.curso
     and d.carnet(+) = c.carnet
     AND d.tipoasig(+) = c.tipoasig
     and d.seccion(+) = c.seccion
     AND d.codstatus(+) = 'S6'
     AND e.carrera(+) = c.carrera
     AND e.fechaimp(+) = c.fechaimp
     and e.curso(+) = c.curso
     AND e.carnet(+) = c.carnet
     and e.tipoasig(+) = c.tipoasig
     AND e.seccion(+) = c.seccion
     AND e.codstatus(+) = 'S7'
     GROUP BY A.carrera,A.carnet,A.statalum,f.nombre,
     b.apellido1||' '||b.apellido2||' '||b.nombre1||' '||b.nombre2;
   
  ELSIF PACCION = '1' THEN 
   OPEN RETVAL FOR
   
     SELECT A.carnet,A.carrera, A.curso, 
     dbafisicc.pkg_curso.nombre(A.curso,A.carrera,d.pensum, 1) AS nombre, 
     A.codstatus, to_char(A.fechaasig,'dd/MM/yyyy') fechaasig, 
     to_char(A.fechaimp,'dd/MM/yyyy') fechaimp, b.nota
      
      FROM DBAFISICC.cahasignastb A, DBAFISICC.caalumnosnotastb b, 
      DBAFISICC.cahcursosimptb d
      WHERE a.carnet = b.carnet(+)
      AND A.curso = b.curso(+)
      and a.carrera = b.carrera(+)
      AND A.seccion = b.seccion(+)
      AND A.tipoasig = b.tipoasig(+)     
      and a.fechaimp = b.fechaimp(+)
      AND A.carrera=d.carrera
      AND A.curso=d.curso
      AND A.seccion=d.seccion
      AND A.tipoasig=d.tipoasig
      AND A.fechaimp=d.fechaimp
      and TO_CHAR(a.fechaimp,'MM/yyyy') = PFECHAIMP
      and a.carnet = PCARNET;

  END IF;
END RENDIMIENTOXFECHA;