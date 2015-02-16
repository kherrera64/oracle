/*
autor: Andrea Alvarado
Fecha: 23/07/2012
Descripcion: Devuelve el cursor con el expediente por cursos aprobados del alumno
para reportes academicos, recibiendo el carnet y el codigo de la carrera
Modificacion: AALVARADO- 16/11/2012- Se agrego la operacion de min() para los
creditos academicos que se traen de pensum por que si hay un curso que tiene mas
de un registro en pensum, pues da error entonces tiene que mostrar el minimo de
los creditos.
AALVARADO - 22/07/2013 - SE AGREGO LA VALIDACION SI ES TIPOASIG = TE
                                        QUE TAMBIEN VALIDE QUE NO SEA ANULADO.
AALVARADO - 26/11/2013 - Se cambio la forma de obtener el ciclo del curso
que sea de cursos impartidos y no de notas.
AALVARADO - 3/12/2013 - Se cambio el nombre del campo que regresa los creditos
por pensum.
AALVARADO - 17/12/2013 - Se cambia la fuente de los creditos academicos en lugar
de alumnosnotas es cursosimpartidos.
30/12/2013 - AALVARADO - Se cambio que el procedimiento tome los creditos
academicos de notas y si este es vacio que lo tome de cursos impartidos.
14/01/2014 - AALVARADO - Se cambio el procedimiento que tome el ciclo de
notas y si esta vacio lo tome de cursos impartidos.
*/

PROCEDURE EXPEDIENTE_CA
(
   retval      out sys_refcursor,
   pcarnet    dbafisicc.caalumnostb.carnet%type,
   pcarrera   dbafisicc.cacarrerastb.carrera%type
)
IS
   vpensum         capensatb.pensum%type;
   tieneSubCarrera number;
BEGIN
    --traer el pensum y si no hay datos como es expediente por cursos aprobados
    --toma el pensum vigente.
    begin
      select pensum
         into vpensum
         from DBAFISICC.caalumcarrstb
         where  carnet  = PCARNET
         and    carrera = PCARRERA;
    exception
      when no_data_found
      then
        SELECT PENSUM_VIGENTE
          INTO VPENSUM
          FROM DBAFISICC.CACARRERASTB
          WHERE CARRERA = PCARRERA;
    end;
    --cuenta cuantas subcarreras tiene asociada la carrera del alumno
    begin
        select count(*)
           into tieneSubcarrera
           from casubcarrerastb
           where carrera = pcarrera
           and   status  = 'A';
    exception
      when others
      then
          tieneSubcarrera:=0;
    end;
    --si no tiene subcarreras devuelve el cursor con toda la informacion del
    --expediente del alumno
    if (tieneSubcarrera < 1 )
    then
        open retval for
            select distinct notas.carnet, alCar.carrera, notas.curso,
                   pkg_carrera.nombre(alCar.carrera, alCar.pensum,1) nomCarrera,
            pkg_curso.nombre(notas.curso,alCar.carrera,alCar.pensum,1) nomcursoe,
            pkg_curso.nombre(notas.curso,alCar.carrera,alCar.pensum,2) nomcursoi,
            nvl(notas.ciclo,cur.ciclo) ciclo, nvl(notas.umas,cur.UMAS) ca_curso,
                   (select min(umas)
                        from dbafisicc.cacatpensatb d
                        where d.carrera = notas.carrera
                        and d.pensum = alCar.pensum
                        and d.curso = notas.curso) ca_pensum,
           decode(notas.tipoasig,'EQ',null,'PRY',null,'SEM',null,notas.nota) nota,
                    cur.fechaimp, codstatus,
                    cur.tipoasig,decode(cur.tipoasig,'EQ',notas.umas,0) CA_EQ
                from dbafisicc.CAALUMNOSNOTASTB notas,
                     DBAFISICC.caalumcarrstb alCar, dbafisicc.cahcursosimptb cur
                where notas.carnet = alCar.carnet
                and alCar.carrera = notas.carrera
                and notas.carrera = cur.carrera
                and notas.curso = cur.curso
                and notas.tipoasig = cur.tipoasig
                and notas.fechaimp = cur.fechaimp
                and notas.seccion = cur.seccion
                and alCar.carnet = PCARNET
                and alCar.carrera = PCARRERA
                and (notas.codstatus = 'S6' or (notas.tipoasig = 'TE'
											    and notas.codstatus != 'S0'))
                and alCar.universidad = (select universidad
                                            from caalumcarrstb
                                            where carnet=PCARNET
                                            and carrera=PCARRERA)
                AND notas.CURSO NOT IN (SELECT CURSO
                                            FROM CACATPENSATB
                                            WHERE CARRERA = PCARRERA
                                            AND PENSUM  = VPENSUM
                                            AND HISTORIAL=0)
                order by nvl(notas.ciclo,cur.ciclo),cur.fechaimp, notas.curso;
    else
       open retval for
            select a.carnet,c.carrera,
                   pkg_carrera.nombre(c.carrera,c.pensum,1) nomCarrera, a.CURSO,
                   pkg_curso.nombre(a.curso,c.carrera,c.pensum,1) nomcursoe,
                   pkg_curso.nombre(a.curso,c.carrera,c.pensum,2) nomcursoi,
                   nvl(a.ciclo,d.ciclo) ciclo, nvl(a.umas,d.UMAS) ca_curso,
                   decode(a.tipoasig,'EQ',null,'PRY',null,'SEM',null,nota) nota,
                    a.fechaimp, codstatus, a.tipoasig,
                   decode(a.tipoasig,'EQ',a.umas,0) CA_EQ,
                   (select min(umas)
                      from dbafisicc.cacatpensatb d
                      where d.carrera = a.carrera
                      and d.pensum = c.pensum
                      and d.curso = a.curso) ca_pensum
              from dbafisicc.CAALUMNOSNOTASTB a, DBAFISICC.caalumcarrstb c,
                   dbafisicc.cahcursosimptb d
              WHERE A.CARNET = PCARNET
                and a.carrera in (select codigo
                                    from DBAFISICC.casubcarrerastb
                                    where carrera = PCARRERA
                                    union
                                    select PCARRERA
                                      from DUAL)
               and a.carrera = c.carrera
               and a.carnet=c.carnet
               and a.carrera = d.carrera
               and a.curso = d.curso
               and a.tipoasig = d.tipoasig
               and a.fechaimp = d.fechaimp
               and a.seccion = d.seccion
               and c.universidad=(select universidad
                                    from caalumcarrstb where carnet=a.carnet
									and carrera=PCARRERA)
               AND A.CURSO NOT IN (SELECT CURSO
                                    FROM CACATPENSATB
                                    WHERE CARRERA = c.carrera
                                      AND PENSUM  = c.pensum
                                      AND HISTORIAL=0)
/* AALVARADO - 22/07/2013 - SE AGREGO LA VALIDACION SI ES TIPOASIG = TE
                                    QUE TAMBIEN VALIDE QUE NO SEA ANULADO.*/
                AND (CODSTATUS='S6' OR (a.TIPOASIG='TE' and a.codstatus != 'S0'))
                order by nvl(a.ciclo,d.ciclo),a.fechaimp,A.curso;
    END IF;
End EXPEDIENTE_CA;