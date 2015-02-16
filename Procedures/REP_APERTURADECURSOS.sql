/*
Autor: Edy Cocon (Chiquitin)
Fecha: 07/08/2014
Descripcion: devuelve los cursos de temporal o produccion dependiendo de los 
             parametros PCARRERA, PENTIDAD, PDIRECTOR, PSEDE, PGRADO, PCICLO,
             PSECCION, PPENSUM.
             POPCION = 1 = PRODUCCION
             POPCION = 2 = TEMPORAL 
             
Autor: Kevin Herrera
Fecha: 16/09/2014
Descripcion: Se agrega el periodo y salon al procedimiento.
*/
PROCEDURE REP_APERTURADECURSOS(
    PUSUARIO    DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
    PCARRERA    DBAFISICC.CACARRERASVW.CARRERA%TYPE,
    PENTIDAD    DBAFISICC.CACARRERASVW.ENTIDAD%TYPE,
    PDIRECTOR   DBAFISICC.CACARRERASVW.ENCARGADO%TYPE,
    PSEDE       DBAFISICC.CACARRERASVW.CENTRONOMBRE%TYPE,
    PGRADO      DBAFISICC.CACARRERASVW.GRADO%TYPE,
    PCICLO      DBAFISICC.CACURSOSIMPTB.CICLO%TYPE, 
    PSECCION    DBAFISICC.CACURSOSIMPTB.SECCION%TYPE,
    PPENSUM     DBAFISICC.CACURSOSIMPTB.PENSUM%TYPE,
    POPCION     NUMBER,
    RETVAL OUT SYS_REFCURSOR
)
IS BEGIN
IF POPCION = 1
THEN 
OPEN RETVAL FOR
SELECT a.ciclo,a.curso,b.nombre DESCRIPCION,a.carrera,a.tipoasig, d.dia,
        to_char(d.horaini,'HH24:MI')||' a '||to_char(d.horafin,'HH24:MI') HORA,
        a.seccion,a.jornada,null virtual, '' tutor, a.status,a.pensum, 
        '' codpers, '' docente, 
        DECODE(d.DIA,1,'DOMINGO',2,'LUNES',3,'MARTES',4,'MIERCOLES',5,'JUEVES',
                6,'VIERNES',7,'SABADO') NOMBREDIA, f.nombre nombreJornada,
        DBAFISICC.PKG_PORTAL.ALUMNOS_ASIGNADOS(C.HORARIO, NULL) AS NO_ALUMNOS,
        A.maxalumnos cupo, c.horario,e.centronombre SEDE,d.horaini,
        e.carrera|| ' - ' ||e.nombre nombrecarrera, e.ENTIDAD || ' - ' ||
    DBAFISICC.PKG_ENTIDAD.NOMBRE('002',E.ENTIDAD,0,PUSUARIO,A.CARRERA) ENTIDAD,
    D.SALON, (SELECT MAX(TO_NUMBER(G.PERIODO)) PERIODO 
                  from dbafisicc.cacarciclostb g
                  where g.carrera = a.carrera)PERIODO
       from dbafisicc.cacursosimptb a, dbafisicc.cacursostb b,
            dbafisicc.cacurshoratb c,dbafisicc.cahorariostb d, 
            DBAFISICC.CACARRERASVW e, dbafisicc.gnjornadastb f
                    WHERE C.curso = A.curso(+)
                      AND c.carrera = A.carrera(+)
                      AND c.seccion = A.seccion(+)
                      AND C.TIPOASIG = A.TIPOASIG(+)
                      AND C.HORARIO = d.HORARIO(+)
                      AND C.CURSO = B.CURSO
                      AND NOT EXISTS (SELECT 1
                                        FROM DBAFISICC.RHDOCENTESTB G
                                          WHERE G.HORARIO = C.HORARIO)
                      AND C.CARRERA = e.CARRERA
                      and f.jornada = nvl(a.jornada, f.jornada)
                      AND e.CARRERA = PCARRERA
                      and (e.carrera = PCARRERA  OR PCARRERA IS NULL)
                      and (e.ENTIDAD = PENTIDAD  OR PENTIDAD IS NULL)
                      and (e.encargado = PDIRECTOR OR PDIRECTOR IS NULL)
                      and (e.grado   = PGRADO    OR PGRADO IS NULL)
                      and (e.CENTRONOMBRE  = PSEDE     OR PSEDE IS NULL)
                      and (a.ciclo   = PCICLO    OR PCICLO IS NULL)
                      and (a.seccion = PSECCION  OR PSECCION IS NULL)
                      and (a.pensum  = PPENSUM   OR PPENSUM IS NULL)
union
 SELECT a.ciclo,a.curso,b.nombre DESCRIPCION,a.carrera,a.tipoasig,f.dia, 
        to_char(f.horaini,'HH24:MI')||' a '||to_char(f.horafin,'HH24:MI') HORA,
        a.seccion,a.jornada,a.virtual,e.tutor,a.status,a.pensum, d.codpers,
        e.apellido1||' '||e.apellido2||','||e.nombre1||' '||e.nombre2 DOCENTE,
        DECODE(f.DIA,1,'DOMINGO',2,'LUNES',3,'MARTES',4,'MIERCOLES',5,'JUEVES',
                6,'VIERNES',7,'SABADO') NOMBREDIA, h.nombre nombreJornada,
        DBAFISICC.PKG_PORTAL.ALUMNOS_ASIGNADOS(C.HORARIO, NULL) AS NO_ALUMNOS,
        A.maxalumnos cupo, c.horario,g.centronombre SEDE,f.horaini,
        g.carrera|| ' - ' ||g.nombre nombrecarrera, G.ENTIDAD || ' - ' ||
    DBAFISICC.PKG_ENTIDAD.NOMBRE('002',g.entidad,0,PUSUARIO,a.carrera) entidad,
    f.salon, (SELECT MAX(TO_NUMBER(I.PERIODO)) PERIODO 
                  from dbafisicc.cacarciclostb i
                  where i.carrera = a.carrera)PERIODO
            from dbafisicc.cacursosimptb a, dbafisicc.cacursostb b,
                 dbafisicc.cacurshoratb c, dbafisicc.rhdocentestb d,
                 dbafisicc.nopersonaltb e, dbafisicc.cahorariostb f, 
                 dbafisicc.cacarrerasvw g, dbafisicc.gnjornadastb h
                     WHERE C.curso = A.curso(+)
                      AND c.carrera = A.carrera(+)
                      AND c.seccion = A.seccion(+)
                      AND C.TIPOASIG = A.TIPOASIG(+)
                      AND C.HORARIO = D.HORARIO
                      AND C.HORARIO = F.HORARIO(+)
                      AND C.CURSO = B.CURSO
                      AND C.CARRERA = G.CARRERA
                      AND D.CODPERS = E.CODPERS
                      and h.jornada = nvl(a.jornada, h.jornada)
                      and d.codpuesto IN ('000010', '000085')
                      and (g.carrera = PCARRERA  OR PCARRERA IS NULL)
                      and (g.ENTIDAD = PENTIDAD  OR PENTIDAD IS NULL)
                      and (g.ENCARGADO = PDIRECTOR OR PDIRECTOR IS NULL)
                      and (g.grado   = PGRADO    OR PGRADO IS NULL)
                      and (g.CENTRONOMBRE  = PSEDE     OR PSEDE IS NULL)
                      and (a.ciclo   = PCICLO    OR PCICLO IS NULL)
                      and (a.seccion = PSECCION  OR PSECCION IS NULL)
                      and (a.pensum  = PPENSUM   OR PPENSUM IS NULL)
ORDER BY CICLO, HORARIO, dia, horaini;
ELSIF POPCION = 2
THEN 
OPEN RETVAL FOR
SELECT a.ciclo,a.curso,b.nombre DESCRIPCION,a.carrera,a.tipoasig, d.dia,
        to_char(d.horaini,'HH24:MI')||' a '||to_char(d.horafin,'HH24:MI') HORA,
        a.seccion,a.jornada,'' tutor, a.status,a.pensum, '' codpers, '' docente, 
        DECODE(d.DIA,1,'DOMINGO',2,'LUNES',3,'MARTES',4,'MIERCOLES',5,'JUEVES',
                6,'VIERNES',7,'SABADO') NOMBREDIA, f.nombre nombreJornada,
        A.maxalumnos cupo, c.horario,e.centronombre SEDE, D.HORAINI,
        e.carrera|| ' - ' ||e.nombre nombrecarrera, e.ENTIDAD || ' - ' ||
    DBAFISICC.PKG_ENTIDAD.NOMBRE('002',e.entidad,0,PUSUARIO,a.carrera) entidad,
    d.salon, (SELECT MAX(TO_NUMBER(g.PERIODO)) PERIODO 
                  FROM DBAFISICC.CACARCICLOSTB g
                  where g.carrera = a.carrera)PERIODO
       from dbafisicc.cacursosimptmp a, dbafisicc.cacursostb b,
            dbafisicc.cacurshoratmp c,dbafisicc.cahorariostmp d, 
            DBAFISICC.CACARRERASVW e, dbafisicc.gnjornadastb f
                WHERE C.curso = A.curso(+)
                      AND c.carrera = A.carrera(+)
                      AND c.seccion = A.seccion(+)
                      AND C.TIPOASIG = A.TIPOASIG(+)
                      AND C.HORARIO = d.HORARIO(+)
                      AND C.CURSO = B.CURSO
                      AND C.CARRERA = e.CARRERA
                      and f.jornada = nvl(a.jornada, f.jornada)
                      AND e.CARRERA = PCARRERA
                      and (e.carrera = PCARRERA  OR PCARRERA IS NULL)
                      and (e.ENTIDAD = PENTIDAD  OR PENTIDAD IS NULL)
                      and (e.encargado = PDIRECTOR OR PDIRECTOR IS NULL)
                      and (e.grado   = PGRADO    OR PGRADO IS NULL)
                      and (e.CENTRONOMBRE  = PSEDE     OR PSEDE IS NULL)
                      and (a.ciclo   = PCICLO    OR PCICLO IS NULL)
                      and (a.seccion = PSECCION  OR PSECCION IS NULL)
                      and (a.pensum  = PPENSUM   OR PPENSUM IS NULL)
union 
SELECT a.ciclo,a.curso,b.nombre DESCRIPCION,a.carrera,a.tipoasig,f.dia,
        to_char(f.horaini,'HH24:MI')||' a '||to_char(f.horafin,'HH24:MI') HORA,
        a.seccion,a.jornada,e.tutor,a.status,a.pensum, d.codpers,
        e.apellido1||' '||e.apellido2||','||e.nombre1||' '||e.nombre2 DOCENTE,
        DECODE(f.DIA,1,'DOMINGO',2,'LUNES',3,'MARTES',4,'MIERCOLES',5,'JUEVES',
                6,'VIERNES',7,'SABADO') NOMBREDIA, h.nombre nombreJornada,
        A.maxalumnos cupo, c.horario,g.centronombre SEDE, F.HORAINI,
        g.carrera|| ' - ' ||g.nombre nombrecarrera, G.ENTIDAD || ' - ' ||
    DBAFISICC.PKG_ENTIDAD.NOMBRE('002',G.ENTIDAD,0,PUSUARIO,A.CARRERA) ENTIDAD,
    f.salon, (SELECT MAX(TO_NUMBER(I.PERIODO)) PERIODO 
                  from dbafisicc.cacarciclostmp i
                  where i.carrera = a.carrera)PERIODO
       from dbafisicc.cacursosimptmp a, dbafisicc.cacursostb b,
            dbafisicc.cacurshoratmp c, dbafisicc.rhdocentestmp d,
            dbafisicc.nopersonaltb e, dbafisicc.cahorariostmp f, 
            DBAFISICC.CACARRERASVW g, dbafisicc.gnjornadastb h
                WHERE C.curso = A.curso(+)
                      AND c.carrera = A.carrera(+)
                      AND c.seccion = A.seccion(+)
                      AND C.TIPOASIG = A.TIPOASIG(+)
                      AND C.HORARIO = D.HORARIO
                      AND C.HORARIO = F.HORARIO(+)
                      AND C.CURSO = B.CURSO
                      AND C.CARRERA = G.CARRERA
                      AND D.CODPERS = E.CODPERS
                      AND NOT EXISTS (SELECT 1
                                        FROM DBAFISICC.RHDOCENTESTMP G
                                          WHERE G.HORARIO = C.HORARIO)
                      and h.jornada = nvl(a.jornada, h.jornada)
                      and d.codpuesto IN ('000010', '000085')
                      and (g.carrera = PCARRERA  OR PCARRERA IS NULL)
                      and (g.ENTIDAD = PENTIDAD  OR PENTIDAD IS NULL)
                      and (g.encargado = PDIRECTOR OR PDIRECTOR IS NULL)
                      and (g.grado   = PGRADO    OR PGRADO IS NULL)
                      and (g.CENTRONOMBRE  = PSEDE     OR PSEDE IS NULL)
                      and (a.ciclo   = PCICLO    OR PCICLO IS NULL)
                      and (a.seccion = PSECCION  OR PSECCION IS NULL)
                      and (a.pensum  = PPENSUM   OR PPENSUM IS NULL)
ORDER BY CICLO, HORARIO, dia, horaini;
END IF;
END REP_APERTURADECURSOS;