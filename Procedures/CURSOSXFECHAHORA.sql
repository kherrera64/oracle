/*
Autor: Luis Mérida
Fecha: 10/06/2013
Descripcion: Este procedimiento devuelve los datos necesarios para llenar
listado de cursos por fecha y hora de la pagina asistencia/Default.aspx.

Modificacion: Miguel Barillas - 15/06/2013 - Se modifico el procedimiento para 
que devuelva si se ha marcado la asistencia de alumos.
            
Modificacion: Miguel Barillas - 26/06/2013 - Se valido que la hora fin estuviese 
dentro del rango establecido         

Modificacion: Miguel Barillas - 08/07/2013-  Se elimino el parametro que 
validaba torre porque ya no es utilizado.

Modificacion: Miguel Barillas - 25/07/2013-  Se cambio la forma de traer el
nombre del docente, se ordena por hora.

AALVARADO - 27/07/2013 - Se quita la validacion de hora de finalizacion. 

Modificacion: KHERRERA - 26/06/2014 - Se agrega al procedimiento el puesto 
                                      000085.
*/
PROCEDURE CURSOSXFECHAHORA
(
    PUSUARIO       in  DBAFISICC.GNUSUARIOSTB.USUARIO%type default null,
    PFACULTAD      in  DBAFISICC.GNENTIDADESTB.ENTIDAD%type default null,
    PCARRERA       IN  DBAFISICC.CACARRERASTB.CARRERA%TYPE DEFAULT NULL,
    PCICLO         in  DBAFISICC.CACURSOSIMPTB.CICLO%type default null,
    PSECCION       IN  DBAFISICC.CACURSOSIMPTB.SECCION%TYPE DEFAULT NULL,
    PHORARIO       IN  DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE DEFAULT NULL,
    PCATEDRATICO   IN  DBAFISICC.RHDOCENTESTB.CODPERS%TYPE DEFAULT NULL,
    PFECHA         IN  DBAFISICC.RHASISTENCIATB.FECHA%TYPE DEFAULT NULL,
    PHORAINI       IN  DBAFISICC.CAHORARIOSTB.HORAINI%TYPE DEFAULT NULL,
    PHORAFIN       IN  DBAFISICC.CAHORARIOSTB.HORAFIN%TYPE DEFAULT NULL,
    PDIA           IN  DBAFISICC.CAHORARIOSTB.DIA%TYPE,
    RETVAL         OUT SYS_REFCURSOR
)
AS 
BEGIN
  OPEN RETVAL FOR
        Select salon, MIN (horaini) horaini, MAX (horafin) horafin, a.horario,
			   descripcion, 
               dbafisicc.pkg_personal.nombre(d.codpers,2) NOMBRE, d.codpers,
               (SELECT COUNT(HORARIO) FROM dbafisicc.RHASISTENCIATB i
                   WHERE i.HORARIO = a.horario
                   AND trunc(i.FECHA)  = trunc(PFECHA)
                   AND i.CODPERS = d.codpers) asistencia,  
				   (SELECT COUNT(HORARIO) FROM dbafisicc.RHALUMASISTETB J
                   WHERE J.HORARIO = a.horario
                   AND trunc(J.FECHA)  = trunc(PFECHA)
                   ) ASISTENCIAALUM
           FROM DBAFISICC.CAMAINHORARIOSTB A, DBAFISICC.CACURSHORATB B,
				        dbafisicc.CaHorariosTB c, 
                DBAFISICC.RHDOCENTESTB D, DBAFISICC.NOPERSONALTB E, 
				         dbafisicc.CACarrerasTB f, 
                dbafisicc.cacursosimptb g, dbafisicc.causuarioscarrerastb h
           where a.horario=b.horario
           and a.horario=c.horario
           and a.horario=d.horario
           and b.carrera=h.carrera
           AND B.CARRERA=F.CARRERA
           and d.CodPuesto IN ('000010', '000081', '000085')
           and d.CodPers=e.CodPers
           and b.curso = g.curso
           and (h.usuario=PUSUARIO OR PUSUARIO IS NULL)
           and (f.Entidad =PFACULTAD OR PFACULTAD IS NULL)
           AND (b.Carrera = PCARRERA OR PCARRERA IS NULL)
           and (g.ciclo =PCICLO OR PCICLO IS NULL)
           AND (b.seccion =PSECCION OR PSECCION IS NULL)
           AND (a.horario = PHORARIO or PHORARIO IS NULL)
           and (d.CodPers = PCATEDRATICO OR PCATEDRATICO IS NULL) 
           and trunc(PFECHA) BETWEEN trunc(a.fechaini) AND trunc(a.fechafin)
           AND TO_CHAR(C.HORAINI, 'HH24:MI') BETWEEN 
               TO_CHAR(PHORAINI, 'HH24:MI') AND TO_CHAR(PHORAFIN, 'HH24:MI')
           AND dia = PDIA
           and h.asistencia =1
        GROUP BY SALON, A.HORARIO, DESCRIPCION, NOMBRE1, NOMBRE2, APELLIDO1, 
               	 apellido2, d.codpers
        ORDER BY horaini, Descripcion, NOMBRE;

END CURSOSXFECHAHORA;