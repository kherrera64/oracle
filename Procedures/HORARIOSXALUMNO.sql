/*KHERRERA - 13/01/2014 - procedimiento que devuelve los datos para horarios por alumno. 
*/
PROCEDURE HORARIOSXALUMNO
  (
    PCARNET  IN DBAFISICC.caasignacionestb.CARNET%TYPE,
    PCARRERA IN DBAFISICC.caasignacionestb.CARRERA%TYPE,
    RETVAL    OUT sys_refcursor
  ) AS 
  BEGIN
    OPEN RETVAL FOR
SELECT a.nombre, b.dia, decode(b.dia, 1, 'DOMINGO', 2, 'LUNES',3, 'MARTES', 4, 'MIERCOLES', 5, 'JUEVES', 6, 'VIERNES',7,'SABADO') dia2,
       a.torre, a.nomtorre, a.salon, a.rangohora 
   FROM   (SELECT dbafisicc.camainhorariostb.descripcion                AS nombre, 
                  dbafisicc.cahorariostb.dia                            AS dia, 
                  dbafisicc.cahorariostb.torre                          AS torre,
                  dbafisicc.catorrestb.nombretorre                      as nomtorre,
                  dbafisicc.cahorariostb.salon                          AS salon, 
                  To_char(dbafisicc.cahorariostb.horaini, 'hh24:mi') 
                  || ' A ' 
                  || To_char(dbafisicc.cahorariostb.horafin, 'hh24:mi') AS rangohora 
                FROM   dbafisicc.camainhorariostb, 
                       dbafisicc.cahorariostb,
                       dbafisicc.CATORRESTB
                WHERE  dbafisicc.cahorariostb.horario = dbafisicc.camainhorariostb.horario 
                AND dbafisicc.camainhorariostb.status = 'A'
                and dbafisicc.cahorariostb.torre = dbafisicc.catorrestb.codigotorre
                AND dbafisicc.camainhorariostb.horario IN (SELECT horario 
                                                              FROM   cacurshoratb 
                                                              WHERE  ( curso, carrera, seccion, tipoasig ) IN 
                                                                    (SELECT curso, carrera, seccion, tipoasig 
                                                                        FROM   dbafisicc.caasignacionestb 
                                                                        WHERE  carnet = PCARNET 
                                                                        AND    carrera = PCARRERA
                                                                        AND codstatus IN('S1','S4' ))
                                                          ) 
              -- AND SYSDATE BETWEEN dbafisicc.camainhorariostb.fechaini AND 
              --                     dbafisicc.camainhorariostb.fechafin
            )a, 
          (SELECT DISTINCT( dia ) 
              FROM   dbafisicc.cahorariostb 
           ORDER  BY dia) b 
    WHERE  a.dia(+) = b.dia;
END HORARIOSXALUMNO;