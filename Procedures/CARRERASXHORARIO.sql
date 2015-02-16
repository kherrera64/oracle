/*
Nombre:       DBAFISICC.PKG_PORTAL.CARRERASXHORARIO 
Autor:        Luis Mérida 
Fecha:        2013-01-25 
Package:      PKG_Portal 
Descripcion:  Llena grid GVCarrera de portales/Alumno.aspx
              con datos de carrera recibe los parametros:
              PHORARIO  ->  horario del curso que se esta impartiendo
              PFECHA    ->  fecha de impartido
              POPCION   ->  bandera para indicar si es actual o historico
                            1 - Actual (predeterminado)
                            0 - Historico
Modificacion: AALVARADO - 17/04/2013- Cambio del formato de fecha.

Modificacion: MBARILLAS - 2013-11-12
Descripcion:  se agrego al select el campo pensum

Modificacion: JGARCIA - 19/02/2014 - Se agregaron los campos FECHAINI y
                                     FECHAFIN de la tabla camainhorariostb al
                                     select de actual.
                                     
Modificacion: KHERRERA - 21/04/2014 - Se agrego el parametro PCORRELATIVO y
              los campos DIA, HORAINI, HORAFIN, CORRELATIVO de la tabla 
              CAHORARIOSTB.   

Modificacion: KHERRERA - 30/04/2014 - Se agrego la opcion 0 que sirve para las 
                                      carreras asociadas en portales.                 

*/ 
CREATE OR REPLACE PROCEDURE CARRERASXHORARIO
(
   PHORARIO      IN DBAFISICC.RHDOCENTESTB.HORARIO%TYPE DEFAULT NULL,
   PFECHA        IN DBAFISICC.RHHDOCENTESTB.FECHAIMP%TYPE DEFAULT NULL,
   PCORRELATIVO  IN DBAFISICC.CAHORARIOSTB.CORRELATIVO%TYPE DEFAULT NULL,
   POPCION       IN NUMBER DEFAULT 1,
   RETVAL        OUT sys_refcursor
) AS
BEGIN
   IF POPCION = 1  THEN     
   OPEN RETVAL FOR
            SELECT CURSO,NOMBRE ,CARRERA, NOMBRECARRERA, SECCION, TIPOASIG , 
                   HORARIO, FECHA, CICLO, UMAS, PENSUM, FECHAINI, FECHAFIN, 
                   DIA, HORAINI, HORAFIN, CORRELATIVO
               from (select a.CURSO, dbafisicc.pkg_curso.nombre(a.curso,
                            a.carrera,d.pensum,1) NOMBRE,
                            a.CARRERA, c.Nombre NombreCarrera,a.SECCION, 
                            A.TIPOASIG,A.HORARIO, '01/01/3000' FECHA, D.CICLO, 
                            d.UMAS, d.pensum,
                            TO_CHAR(E.FECHAINI, 'DD/MM/YYYY') FECHAINI,
                            TO_CHAR(E.FECHAFIN, 'DD/MM/YYYY') FECHAFIN, F.DIA, 
                            TO_NUMBER(TO_CHAR(F.HORAINI,'hh24'))*100 + 
                            TO_NUMBER(TO_CHAR(F.HORAINI,'mi')) AS HORAINI, 
                            TO_NUMBER(TO_CHAR(F.HORAFIN,'hh24'))*100 + 
                            TO_NUMBER(TO_CHAR(F.HORAFIN,'mi')) AS HORAFIN, 
                            F.CORRELATIVO
                            
                        FROM DBAFISICC.CACURSHORATB A,DBAFISICC.CACARRERASTB C, 
                        DBAFISICC.CACURSOSIMPTB D, DBAFISICC.CAMAINHORARIOSTB E,
                        DBAFISICC.CAHORARIOSTB F
                        WHERE A.CARRERA=C.CARRERA
                        AND A.HORARIO=PHORARIO
                        and e.horario = a.horario
                        and a.carrera=d.carrera 
                        and a.curso=d.curso 
                        and a.seccion=d.seccion 
                        AND A.TIPOASIG=D.TIPOASIG
                        AND F.HORARIO=A.HORARIO
                        AND (F.CORRELATIVO=PCORRELATIVO 
                               or PCORRELATIVO is null)) 
            GROUP BY CARRERA, CURSO, NOMBRE, NOMBRECARRERA, SECCION, TIPOASIG,
                     HORARIO, FECHA, CICLO, UMAS,PENSUM, DIA, FECHAINI, 
                     FECHAFIN, HORAINI, HORAFIN, CORRELATIVO;
                     
   ELSIF POPCION = '0' THEN
   OPEN RETVAL FOR            
   
            SELECT CURSO, NOMBRE ,CARRERA, NOMBRECARRERA, SECCION, TIPOASIG , 
                   HORARIO, FECHA, CICLO, UMAS, PENSUM
               from (select a.CURSO, dbafisicc.pkg_curso.nombre(a.curso,
                            a.carrera,d.pensum,1) NOMBRE,
                            a.CARRERA, c.Nombre NombreCarrera,a.SECCION, 
                            A.TIPOASIG,A.HORARIO, '01/01/3000' FECHA, D.CICLO, 
                            d.UMAS, d.pensum
                            
                        FROM DBAFISICC.CACURSHORATB A,DBAFISICC.CACARRERASTB C, 
                        DBAFISICC.CACURSOSIMPTB D, DBAFISICC.CAMAINHORARIOSTB E
                        WHERE A.CARRERA=C.CARRERA
                        AND A.HORARIO=PHORARIO
                        and e.horario = a.horario
                        and a.carrera=d.carrera 
                        and a.curso=d.curso 
                        and a.seccion=d.seccion 
                        AND A.TIPOASIG=D.TIPOASIG)
                      
            GROUP BY CARRERA, CURSO, NOMBRE, NOMBRECARRERA, SECCION, TIPOASIG,
                     HORARIO, FECHA, CICLO, UMAS,PENSUM;
                     
   ELSE
   OPEN RETVAL FOR
      
           Select a.CURSO,dbafisicc.pkg_curso.nombre(a.curso,a.carrera,
                  d.pensum,1) NOMBRE,  a.CARRERA, c.Nombre NombreCarrera, 
                  a.SECCION, a.TIPOASIG, a.HORARIO, TO_CHAR(a.FechaImp,
                  'dd/mm/yyyy') Fecha, d.ciclo, d.umas, d.pensum
                    from DBAFISICC.cahcurshoratb a, DBAFISICC.cacarrerastb c, 
                    DBAFISICC.cahcursosimptb d 
                    where a.carrera=c.carrera 
                    and a.curso=d.curso 
                    and a.carrera=d.carrera 
                    and a.seccion=d.seccion 
                    and a.tipoasig=d.tipoasig 
                    and a.fechaimp=d.fechaimp 
                    and horario=PHORARIO 
                    and a.fechaimp=PFECHA;
   End If;
END CARRERASXHORARIO;