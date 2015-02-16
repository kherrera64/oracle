   /*
autor: Kevin Herrera
FECHA: 22/03/2014
Descripcion: Procedimiento que devuelve listado de alumnos por graduar que 
             tienen pendientes de 1 a 8 cursos.
*/

create or replace PROCEDURE ALUMNOSXGRADUAR
(
  PCARRERA DBAFISICC.caalumcarrstb.carrera%TYPE DEFAULT NULL,
  RETVAL    OUT SYS_REFCURSOR
)
  IS
  BEGIN
  OPEN RETVAL FOR
  
  SELECT A.universidad,A.carrera,A.pensum,A.carnet, c.nombre1 ||' '|| c.nombre2 
  ||' '|| c.apellido1 ||' '|| c.apellido2 AS nombre, b.direccion, b.email,
  b.telefono, A.cantxcarr-A.cantxalum pendientes , A.cantxcarr cuenta1,
  A.cantxalum cuenta2
   
   
 
   FROM ( SELECT A.carnet,A.carrera,A.pensum,count(*) cantxalum,cantxcarr, 
          d.nombre universidad
            FROM DBAFISICC.caalumcarrstb A, DBAFISICC.caalumnosnotastb b,
            DBAFISICC.gnfacultadestb d, ( SELECT A.pensum,A.carrera,
                                          count(*) cantxcarr 
                                             
                                             FROM DBAFISICC.capensatb A, 
                                             DBAFISICC.cacatpensatb b
                                             where a.carrera = b.carrera 
                                             and a.pensum = b.pensum
                                             AND b.HISTORIAL=1
                                             AND b.carrera = PCARRERA
                                             GROUP BY A.pensum,A.carrera ) c
                                         
            WHERE  A.carnet=b.carnet
            AND A.carrera=b.carrera
            AND A.pensum=c.pensum
            AND A.carrera=c.carrera
            AND A.carrera=PCARRERA
            AND b.codstatus='S6'
            AND A.statalum NOT IN ('G','TU','2','3','D')
            AND A.universidad = d.facultad
            GROUP BY A.carnet,A.carrera,A.pensum,cantxcarr, d.nombre
          ) A, DBAFISICC.cadirecciostb b, DBAFISICC.caalumnostb c
          
    where a.carnet=b.carnet
    AND A.carnet = c.carnet
    AND b.tipodireccion='C' 
    AND cantxcarr-cantxalum <='8' 
    AND cantxcarr-cantxalum >'0'
  ORDER BY c.nombre1 ||' '|| c.nombre2 ||' '|| c.apellido1 ||' '|| c.apellido2;
  
 END ALUMNOSXGRADUAR; 