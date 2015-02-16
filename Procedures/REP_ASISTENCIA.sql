/*
Nombre: REP_ASISTENCIA
Autor: Andrea Alvarado
Fecha:  24/07/2013
Package: PKG_REPORTES
Descripcion: Devuelve el listado de asistencias conforme a los parametros
se usa en asistencia. 

Modificacion: AALVARADO - 26/07/2013 - Cambio para que reciba mas de un horario. 
Miguel Barillas - 12/12/2013 - Se agrego la opcion de poder utilizar los
parametros PHORAINI  y PHORAFIN como null

Modificacion: KHERRERA - 26/06/2014 - Se agrega al procedimiento el puesto 
                                      000085.
*/
PROCEDURE REP_ASISTENCIA
(
    PHORARIO  VARCHAR2 DEFAULT NULL,
    PFECHA    DBAFISICC.CAHORARIOSTB.HORAINI%TYPE,
    PHORAINI  VARCHAR2 DEFAULT NULL,
    PHORAFIN  VARCHAR2 DEFAULT NULL,
    PDIA      DBAFISICC.CAHORARIOSTB.DIA%TYPE,
    PUSUARIO  DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
    RETVAL    OUT SYS_REFCURSOR
)
IS
BEGIN
OPEN RETVAL FOR
      select PUSUARIO Usuario, a.horario, to_char(min(a.HoraIni),'HH24:MI') orden,
             dbafisicc.pkg_portal.nombre(a.horario,null) descripcion, 
              to_char(min(a.HoraIni),'HH12:MI AM')||' a '||
              to_char(max(a.HoraFin),'HH12:MI AM') Hora,c.carnet, c.carrera, 
              dbafisicc.pkg_alumno.nombre(c.carnet,1) alumno, d.codpers,
              dbafisicc.pkg_personal.nombre(d.codpers,2) catedratico, a.torre, 
              a.salon,TRUNC(PFECHA) Fecha,'______________________' Firma,
              (nvl(s.MORAS30,0) + nvl(s.VMORAS30,0) + nvl(s.MORAS60,0) + 
              nvl(s.VMORAS60,0) + nvl(s.MORAS90,0) + nvl(s.VMORAS90,0) + 
              nvl(s.MORAS91,0) + nvl(s.VMORAS91,0)) AS SALDO, a.dia
         from dbafisicc.cahorariostb a, dbafisicc.cacurshoratb b, 
              dbafisicc.caasignacionestb c, dbafisicc.rhdocentestb d,
              dbafisicc.cctemprepdeudas15tb s, dbafisicc.camainhorariostb e
         where a.dia = PDIA
         and  a.horario = b.horario
         and  c.codstatus in ('S1','S4')
         and  b.curso = c.curso(+)
         and  b.tipoasig = c.tipoasig(+)
         and  b.seccion = c.seccion(+)
         and  b.carrera = c.carrera(+)
         and  NVL(d.status,'P') not in ('I')
         and  NVL(d.codpuesto,'000010') in ('000010','000081','000080', '000085')
         and  a.horario = d.horario(+)
         and  nvl(a.codpers,nvl(d.codpers,' ')) = nvl(d.codpers,' ')
         and  c.carnet = s.carnet(+)
         and  c.carrera = s.carrera(+)
         and  e.horario = a.horario
         and  trunc(PFECHA) between e.FechaIni and e.FechaFin
         and  ((TO_CHAR(horaini, 'HH24:MI') BETWEEN PHORAINI AND PHORAFIN )
         OR (PHORAINI IS NULL AND PHORAFIN IS NULL))
         AND  (A.HORARIO IN (SELECT * FROM TABLE(SPLIT_VARCHAR(PHORARIO,',')))
			         or PHORARIO is null)
         group by a.horario, c.carnet,c.carrera, d.codpers, a.torre, a.salon,
                  s.MORAS30, s.VMORAS30, s.MORAS60, s.VMORAS60, s.MORAS90, 
                  s.VMORAS90, s.MORAS91, s.VMORAS91,a.dia
         order by orden,descripcion,catedratico,alumno;

END REP_ASISTENCIA;