/*
autor: Luis Mérida
Fecha: 26/09/2012
Descripcion: Devuelve el listado de CARRERAS a las que el 
usuario tiene acceso en base a una entidad ,director, sede y grado enviado
Excluye Facultad de idea y para señalar TODOS manda un 0 como dato.
*/

  PROCEDURE CICLOS_PENSUM
  (
    PPENSUM  DBAFISICC.CACATPENSATB.PENSUM%TYPE DEFAULT NULL,
    PCARRERA  DBAFISICC.CACATPENSATB.CARRERA%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
  ) AS 
  BEGIN
    OPEN RETVAL FOR
    
    SELECT DISTINCT CICLO 
      FROM CACATPENSATB
      WHERE PENSUM = PPENSUM 
      AND CARRERA = PCARRERA
    ORDER BY CICLO;
               
  END CICLOS_PENSUM;