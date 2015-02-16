/*
autor: Luis Mérida
Fecha: 26/09/2012
Descripcion: Devuelve el listado de CARRERAS a las que el 
usuario tiene acceso en base a una entidad ,director, sede y grado enviado
Excluye Facultad de idea y para señalar TODOS manda un 0 como dato.
*/

  PROCEDURE CICLOS_VIGENTES
  (
    PCARRERA  DBAFISICC.CACICLOSVIGENTESTMP.CARRERA%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
  ) AS 
  BEGIN
    OPEN RETVAL FOR
    
      SELECT pensum, ciclo
            FROM DBAFISICC.CACICLOSVIGENTESTMP
            WHERE CARRERA = PCARRERA
      ORDER BY pensum DESC, ciclo;
               
  END CICLOS_VIGENTES;