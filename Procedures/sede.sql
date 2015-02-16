/*
autor: Andrea Alvarado
Fecha: 22/08/2012
Descripcion: Devuelve el listado de SEDES  de las carreras a las que el 
usuario tiene acceso en base a una entidad enviada y un director.
Excluye facultad de idea y para senalar todos manda un 0 como dato
Modificacion: AALVARADO - 26/09/2012 - agregar la funcionalidad para que tome 
              las entidades sin usuario.
              27/09/2012 - LMERIDA - se agrego la funcionalidad para que pueda
              recibir varias entidades y directores.
              03/10/2012 - JVELASQUEZ - Agregue parametros para filtrar sedes.
              PACTIVAS - Que define si regresa solo sedes de carreras activas 
                1- Solo Activas (predeterminado)
                0 - Todas
              PINCLUYE_IDEA -Determina si vamos a mostrar sedes de facultad IDEA
                1 - Incluye Idea
                0 - No incluye. (predeterminado)
              18/10/2012 - JVELASQUEZ - Agregue parametros para filtrar sedes
              por carrera principal y grado.
              07/01/2012 - JVELASQUEZ - Se agrego el parametro PUNIVERSIDAD.
              11/01/2013 - JVELASQUEZ - Se modifico el procedimiento para
              mostrar las sedes de IDEA segun los títulos y no los centros de
              costos.
              02/09/2013 - ESANABRIA - Se modifico el orden para que muestre
              todos de primero
              20/02/2014 - KHERRERA - Se modifico el manejo de null en sede.
              06/08/2014 - Edy Cocon - Se agrego el campo centro.
              29-08-2014 - JFerrer - Se modifico para que incluya a IDEA por
              defecto. 
              09/10/2014 - Kevin Herrera - Se concatena el centro al campo sede.
*/
PROCEDURE SEDE
(
    PUSUARIO      DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE DEFAULT NULL,
    PUNIVERSIDAD  DBAFISICC.CAALUMCARRSTB.UNIVERSIDAD%TYPE DEFAULT '002',
    PENTIDAD   IN VARCHAR2 DEFAULT NULL,
    PDIRECTOR  IN VARCHAR2 DEFAULT NULL,
    PGRADO     IN VARCHAR2 DEFAULT NULL,
    PMAINCAR   IN VARCHAR2 DEFAULT NULL,
    PACTIVAS      DBAFISICC.CACARRERASTB.STATUC%TYPE DEFAULT 1,
    PINCLUYE_IDEA DBAFISICC.CACARRERASTB.ENTIDAD%TYPE DEFAULT 0,
    RETVAL        OUT SYS_REFCURSOR
) 
AS
BEGIN

  OPEN RETVAL FOR
    SELECT '0' COMENTARIOS, ' TODAS' DETALLE, ' TODAS' DETALLE2 , -1 CENTRO
      FROM DUAL
      
    UNION
    
      SELECT DISTINCT NVL(B.CENTRONOMBRE,'0') COMENTARIOS, 
                      NVL(B.CENTRO || ' - ' || B.CENTRONOMBRE || ' - ' ||
					  B.COMENTARIOS,' TODAS') DETALLE, 
                      NVL(B.CENTRONOMBRE,' TODAS') DETALLE2, B.CENTRO

        FROM DBAFISICC.CACARRERASVW B, DBAFISICC.CAUSUARIOSCARRERASTB A 
        WHERE A.CARRERA     = B.CARRERA 
        AND (A.USUARIO    = PUSUARIO  OR PUSUARIO      IS NULL)
        AND (B.STATUC     = 'A'       OR PACTIVAS      = 0)
        AND 
        (
          B.ENTIDAD    IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PENTIDAD,',')))  
          OR PENTIDAD  IS NULL
        )
        AND
        (
          B.ENCARGADO  IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PDIRECTOR,','))) 
          OR PDIRECTOR IS NULL
        )
        AND 
        (
          B.GRADO      IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PGRADO,',')))    
          OR PGRADO    IS NULL
        )
        AND 
        (
          B.MAINCAR IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PMAINCAR,',')))  
          OR PMAINCAR  IS NULL
          OR
          (
            '02' IN (
                    SELECT B.ENTIDAD
                      FROM DBAFISICC.CATITULOSCARTB A
                      WHERE A.TITULO IN
                      (
                        SELECT * 
                          FROM TABLE (SPLIT_VARCHAR(PMAINCAR,','))
                      )
                      AND A.CARRERA = B.CARRERA
                  )
                  AND B.MAINCAR IN
                  (
                    SELECT MAINCAR 
                      FROM DBAFISICC.CACARRERASTB
                      WHERE ENTIDAD = '02'
                  )
          )
        )
        AND (PUNIVERSIDAD = '002' OR EXISTS
        (
          SELECT NULL
            FROM DBAFISICC.CAALUMCARRSTB D
            WHERE PUNIVERSIDAD = D.UNIVERSIDAD
            AND B.CARRERA = D.CARRERA)
        )
    ORDER BY DETALLE2;
    
END SEDE;