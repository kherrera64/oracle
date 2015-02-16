/*
autor: Andrea Alvarado
Fecha: 02/11/2011
Descripcion: Devuelve el cursor con el expediente del alumno por pensum para
reportes academicos, recibiendo el carnet y el codigo de la carrera
Publicar: 26/01/2012
Modificacion: 06/07/2012 - AALVARADO - Agrupacion de cursos para que no se
dupliquen por diferentes creditos academicos, toma el de menor valor.
24/09/2012 - AALVARADO - Agrupacion de pensum, se quita el pensum como campo de
agrupacion. Para evitar la duplicacion de cursos.
25/09/2012 - AALVARADO - Se elimino la siguiente linea cuando es una carrera sin
unificaciones.  and   a.statalum         <> '4'
25/10/2012 - AALVARADO - Se agrego a la linea and   a.statalum <> '4' en
unificaciones que si es de la carrera que se esta solicitando que si la
tome en cuenta.

 AALVARADO - 22/07/2013 - SE AGREGO LA VALIDACION SI ES TIPOASIG = TE
                       QUE TAMBIEN VALIDE QUE NO SEA ANULADO.
29/07/2013 - AALVARADO - Agregar la condicion para que las equivalencias
que se obtienen en las subcarreras no se tomen en cuenta solo si es de la
carrera que genera el expendiente.
08/08/2013 - AALVARADO - Quitar Condicion de Equivalencias.
3/12/2013 - AALVARADO - Agregue los creditos por pensum tomando como creditos
los aprobados tanto por notas como por equivalencia.
11/12/2013 - AALVARADO - Cambie la condicion para tomar los creditos academicos
antes estaba que si la nota era vacia no tomara creditos academicos ahora es si
el tipo de asignacion esta vacio.
Tambien agregue el parametro de usuario.
16/12/2013 - AALVARADO - Se cambio la fuente de creditos academicos en lugar de
alumnosnotas en cursosimp
30/12/2013 - AALVARADO - Se cambio que el procedimiento tome los creditos
academicos de notas y si este es vacio que lo tome de cursos impartidos.
07/02/2014 - AALVARADO - Se agrego la validacion de equivalencias.
14/02/2014 - AALVARADO - Se quito la validacion de las equivalencias.
27/08/2014 - AJMARTINEZ - Se agrego validacion de caalumcarr_unirtb .
20/01/2015 - KHERRERA - Se aplica la sustitucion de cursos para IDEA.
23/01/2015 - KHERRERA - Se corrigen los cursos duplicados y la suma de CAS.
28/01/2015 - KHERRERA - Se valida el tipo de asignacion en el pensum para 
                        todos los seminarios sin importar la carrera.
30/01/2015 - KHERRERA - Se corrige la suma de creditos para que sea unicamente
                        los del pensum.
*/
PROCEDURE EXPEDIENTEXALUMNO
(
   RETVAL     OUT SYS_REFCURSOR,
   PCARNET    DBAFISICC.CAALUMNOSTB.CARNET%TYPE,
   PCARRERA   DBAFISICC.CACARRERASTB.CARRERA%TYPE,
   PUSUARIO   DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE DEFAULT NULL
)
IS
   VPENSUM         DBAFISICC.CAPENSATB.PENSUM%TYPE;
   TIENESUBCARRERA NUMBER;
   EXISTEUNIRTB    NUMBER;
   VPENSUM2    NUMBER DEFAULT 0;
BEGIN
    --traer el pensum y si no hay datos devuelve no existe pensum
    BEGIN
      SELECT PENSUM
         INTO VPENSUM
         FROM DBAFISICC.CAALUMCARRSTB
         WHERE  CARNET  = PCARNET
         AND    CARRERA = PCARRERA;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        OPEN RETVAL FOR
          SELECT 'NO EXISTE PENSUM' CARNET, NULL CARRERA,NULL NOM_CARRERA,
                 NULL PENSUM, NULL CURSO,NULL NOMCURSOE,NULL NOMCURSOI,
                 NULL CICLO, NULL CA_PENSUM, NULL CA_CURSO, NULL NOTA,
                 NULL FECHAIMP, NULL CODSTATUS,NULL TIPOASIG
            FROM DUAL;
    END;
   
   IF PCARRERA = 'LITA' THEN
   
    BEGIN
     
      SELECT 1 INTO VPENSUM2
       FROM (SELECT A.PENSUM 
              FROM ( SELECT TO_NUMBER(SUBSTR(TO_CHAR(PENSUM),6,4)) YEAR2, PENSUM  
                        FROM DBAFISICC.CAPENSATB
                        WHERE CARRERA = 'LITA') A
                WHERE A.YEAR2 >= 2011 
                ORDER BY A.YEAR2 ASC)
                                         
        WHERE PENSUM = VPENSUM;
                                      
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         VPENSUM2 := 0;
    END;
    
    END IF;

    --***
    --revisa si existe en dbafisicc.caalumcarr_unirtb
    BEGIN
    SELECT COUNT(*)
        INTO EXISTEUNIRTB
        FROM DBAFISICC.CAALUMCARR_UNIRTB
        WHERE CARNET = PCARNET
        AND   CARRERA = PCARRERA;
    EXCEPTION
      WHEN OTHERS
      THEN
          EXISTEUNIRTB:=0;
    END;
    --***



    --cuenta cuantas subcarreras tiene asociada la carrera del alumno
    BEGIN
        SELECT COUNT(*)
           INTO TIENESUBCARRERA
           FROM DBAFISICC.CASUBCARRERASTB
           WHERE CARRERA = PCARRERA
           AND   STATUS  = 'A';
    EXCEPTION
      WHEN OTHERS
      THEN
          TIENESUBCARRERA:=0;
    END;
    --si no tiene subcarreras devuelve el cursor con toda la informacion del
    --expediente del alumno
    IF (TIENESUBCARRERA < 1 )
    THEN
        OPEN RETVAL FOR
             SELECT DISTINCT PENSUM.CARNET, NOTAS.CARRERA,PENSUM.CURSO,
			       PENSUM.NOMCURSOE,PENSUM.NOMCURSOI,PENSUM.CICLO,
                   PENSUM.UMAS CA_PENSUM, NOTAS.UMAS CA_CURSO, 
                   (CASE WHEN PCARRERA = 'LITA'
                           AND (PENSUM.CURSO = 'IDE11AP06' 
                               OR PENSUM.CURSO = 'IDE06AOF04' 
                               OR PENSUM.CURSO = 'IDE02A301')                          
                     THEN (CASE WHEN
                      TO_CHAR(TO_DATE(NOTAS.FECHAIMP), 'DD/MM/YYYY') <= 
                      TO_CHAR(TO_DATE('01/09/2014','DD/MM/YYYY'), 'DD/MM/YYYY')
                           THEN (CASE WHEN NOTAS.NOTA IS NOT NULL THEN 'A' END) 
                           ELSE (CASE WHEN PENSUM.TIPOASIG = 'SEM'
                           THEN (CASE WHEN NOTAS.NOTA IS NOT NULL THEN 'A' END) 
                                      ELSE TO_CHAR(NOTAS.NOTA) END) END)
                      ELSE (CASE WHEN PENSUM.TIPOASIG = 'SEM' 
                                 THEN (CASE WHEN NOTAS.NOTA IS NOT NULL 
                                            THEN 'A' END) 
                                 ELSE (CASE WHEN NOTAS.NOTA IS NOT NULL 
                                   THEN TO_CHAR(NOTAS.NOTA) END) END) END) NOTA,
                   NOTAS.FECHAIMP, NOTAS.CODSTATUS, NOTAS.TIPOASIG,
                   DECODE(NOTAS.TIPOASIG,'EQ', PENSUM.UMAS, 0) CA_EQ,
                   DECODE(NOTAS.TIPOASIG, NULL, 0, PENSUM.UMAS) CAS           
                   
                   
      FROM (SELECT A.CARNET, A.PENSUM, C.CICLO, C.CURSO, C.TIPOASIG,
                 PKG_CURSO.NOMBRE(C.CURSO,C.CARRERA,C.PENSUM,1) NOMCURSOE,
                 PKG_CURSO.NOMBRE(C.CURSO,C.CARRERA,C.PENSUM,2) NOMCURSOI,
                            C.HISTORIAL, MIN(C.UMAS) UMAS
						FROM DBAFISICC.CAALUMCARRSTB A, DBAFISICC.CACATPENSATB C
            WHERE A.CARRERA          = C.CARRERA
						AND   A.PENSUM           = C.PENSUM
						AND   A.CARNET           = PCARNET
						AND   (A.STATALUM <> '4' OR A.CARRERA = PCARRERA)
            AND   NVL(C.HISTORIAL,0) = 1
            AND   A.CARRERA in (SELECT CARRERA 
                                  FROM DBAFISICC.CACARRERASVW 
                                  WHERE MAINCAR = PCARRERA 
                                  AND EXISTEUNIRTB = 0
                               UNION
                               SELECT CARRERA_UNIR
                                  FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                  WHERE CARNET = PCARNET
                                  AND CARRERA = PCARRERA
                                  AND EXISTEUNIRTB > 0
                               UNION 
                               SELECT PCARRERA 
                               FROM DUAL)                         
						GROUP BY A.CARNET,A.PENSUM, C.CICLO,C.CURSO,C.TIPOASIG,C.HISTORIAL,
								 PKG_CURSO.NOMBRE(C.CURSO,C.CARRERA,C.PENSUM,1),
                                 PKG_CURSO.NOMBRE(C.CURSO,C.CARRERA,C.PENSUM,2)
                        ORDER BY CICLO) PENSUM,
                        
        ( SELECT SUSTITUTO.EQCURSO CURSO, N.NOTA, N.FECHAIMP, N.CODSTATUS,
               N.TIPOASIG, N.UMAS, N.CARRERA
                 
        FROM ( SELECT CARRERA, CURSO, EQCARRERA, EQCURSO
                   FROM DBAFISICC.CACURSOSEQTB
                   WHERE CARRERA = PCARRERA
                   AND EQCARRERA = PCARRERA
                   AND CURSO NOT IN( SELECT A.CURSO
                                           FROM DBAFISICC.CAALUMNOSNOTASTB A,
                                                DBAFISICC.CACATPENSATB B
                                           WHERE A.CARNET = PCARNET
                                           AND A.CARRERA 
                                            IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)   
                                           AND (A.CODSTATUS='S6' 
                                                OR (A.TIPOASIG='TE' 
                                                AND A.CODSTATUS != 'S0'))
                                           AND B.CARRERA 
                                               IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)  
                                           AND B.PENSUM IN (SELECT PENSUM 
                                                   FROM DBAFISICC.CAALUMCARRSTB
                                                   WHERE CARNET = PCARNET
                                                   AND CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL))
                                           AND B.CURSO = A.CURSO)
                   AND EQCURSO IN( SELECT A.CURSO
                                    FROM DBAFISICC.CACATPENSATB A
                                    WHERE A.CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)
                                    AND A.PENSUM IN (SELECT PENSUM 
                                                   FROM DBAFISICC.CAALUMCARRSTB
                                                   WHERE CARNET = PCARNET
                                            AND CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)))) SUSTITUTO,  
                 
             (SELECT F.CURSO, F.NOTA, F.FECHAIMP,F.CODSTATUS,F.TIPOASIG,
                             NVL(F.UMAS,G.UMAS) UMAS, F.CARRERA
                        FROM DBAFISICC.CAALUMNOSNOTASTB F,
                             DBAFISICC.CAHCURSOSIMPTB G
                        WHERE F.CARNET = PCARNET
                        AND F.CARRERA = G.CARRERA
                        AND F.CURSO = G.CURSO
                        AND F.TIPOASIG = G.TIPOASIG
                        AND F.FECHAIMP = G.FECHAIMP
                        AND F.SECCION = G.SECCION
                        AND   F.CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)
                        AND (CODSTATUS='S6' OR (F.TIPOASIG='TE'
						                        AND CODSTATUS != 'S0'))) N
              WHERE SUSTITUTO.CURSO = N.CURSO
              
              
                UNION SELECT F.CURSO, F.NOTA, F.FECHAIMP,F.CODSTATUS,F.TIPOASIG,
                             NVL(F.UMAS,G.UMAS) UMAS, F.CARRERA
                        FROM DBAFISICC.CAALUMNOSNOTASTB F,
                             DBAFISICC.CAHCURSOSIMPTB G
                        WHERE F.CARNET = PCARNET
                        AND F.CARRERA = G.CARRERA
                        AND F.CURSO = G.CURSO
                        AND F.TIPOASIG = G.TIPOASIG
                        AND F.FECHAIMP = G.FECHAIMP
                        AND F.SECCION = G.SECCION
                        AND F.CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)
                        AND (CODSTATUS='S6' 
                            OR (F.TIPOASIG='TE' AND CODSTATUS != 'S0')) 
                        AND F.CURSO NOT IN(  SELECT SUSTITUTO.CURSO 
                 
        FROM ( SELECT CARRERA, CURSO, EQCARRERA, EQCURSO
                   FROM DBAFISICC.CACURSOSEQTB
                   WHERE CARRERA = PCARRERA
                   AND EQCARRERA = PCARRERA
                   AND CURSO NOT IN( SELECT A.CURSO
                                      FROM DBAFISICC.CAALUMNOSNOTASTB A, 
                                           DBAFISICC.CACATPENSATB B
                                       WHERE A.CARNET = PCARNET
                                       AND A.CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)
                                       AND (A.CODSTATUS='S6' OR (A.TIPOASIG='TE'
						                                    AND A.CODSTATUS != 'S0'))
                                           AND B.CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)
                                       AND B.PENSUM IN (SELECT PENSUM 
                                                   FROM DBAFISICC.CAALUMCARRSTB
                                                   WHERE CARNET = PCARNET
                                                   AND CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL))
                                       AND B.CURSO = A.CURSO)
                   AND EQCURSO IN( SELECT A.CURSO
                                    FROM DBAFISICC.CACATPENSATB A
                                    WHERE A.CARRERA   IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)
                                    AND A.PENSUM IN (SELECT PENSUM 
                                                    FROM DBAFISICC.CAALUMCARRSTB
                                                    WHERE CARNET = PCARNET
                                            AND CARRERA   IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)))) SUSTITUTO,  
                 
             (SELECT F.CURSO, F.NOTA, F.FECHAIMP,F.CODSTATUS,F.TIPOASIG,
                             NVL(F.UMAS,G.UMAS) UMAS, F.CARRERA
                        FROM DBAFISICC.CAALUMNOSNOTASTB F,
                             DBAFISICC.CAHCURSOSIMPTB G
                        WHERE F.CARNET = PCARNET
                        AND F.CARRERA = G.CARRERA
                        AND F.CURSO = G.CURSO
                        AND F.TIPOASIG = G.TIPOASIG
                        AND F.FECHAIMP = G.FECHAIMP
                        AND F.SECCION = G.SECCION
                        AND F.CARRERA IN (SELECT CARRERA 
                                                FROM DBAFISICC.CACARRERASVW 
                                                WHERE MAINCAR = PCARRERA 
                                             UNION
                                             SELECT CARRERA_UNIR
                                                FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                                WHERE CARNET = PCARNET
                                                AND CARRERA = PCARRERA
                                                AND EXISTEUNIRTB > 0
                                             UNION 
                                             SELECT PCARRERA 
                                             FROM DUAL)                                       
                        AND (CODSTATUS='S6' OR (F.TIPOASIG='TE'
						                        AND CODSTATUS != 'S0'))) N
              WHERE SUSTITUTO.CURSO = N.CURSO)) NOTAS
              WHERE PENSUM.CURSO=NOTAS.CURSO(+)
              ORDER BY PENSUM.CICLO ASC;
              
    ELSE
    
        OPEN RETVAL FOR
            
            SELECT DISTINCT PENSUM.CARNET, NOTAS.CARRERA,PENSUM.CURSO,
			       PENSUM.NOMCURSOE,PENSUM.NOMCURSOI,PENSUM.CICLO,
                   PENSUM.UMAS CA_PENSUM, NOTAS.UMAS CA_CURSO, 
                   (CASE WHEN PCARRERA = 'LITA'
                           AND (PENSUM.CURSO = 'IDE11AP06' 
                               OR PENSUM.CURSO = 'IDE06AOF04' 
                               OR PENSUM.CURSO = 'IDE02A301')                          
                     THEN (CASE WHEN
                      TO_CHAR(TO_DATE(NOTAS.FECHAIMP), 'DD/MM/YYYY') <= 
                      TO_CHAR(TO_DATE('01/09/2014','DD/MM/YYYY'), 'DD/MM/YYYY')
                           THEN (CASE WHEN NOTAS.NOTA IS NOT NULL THEN 'A' END) 
                           ELSE (CASE WHEN PENSUM.TIPOASIG = 'SEM'
                           THEN (CASE WHEN NOTAS.NOTA IS NOT NULL THEN 'A' END) 
                                      ELSE TO_CHAR(NOTAS.NOTA) END) END)
                      ELSE (CASE WHEN PENSUM.TIPOASIG = 'SEM' 
                                 THEN (CASE WHEN NOTAS.NOTA IS NOT NULL 
                                            THEN 'A' END) 
                                 ELSE (CASE WHEN NOTAS.NOTA IS NOT NULL 
                                   THEN TO_CHAR(NOTAS.NOTA) END) END) END) NOTA,
                   NOTAS.FECHAIMP, NOTAS.CODSTATUS, NOTAS.TIPOASIG,
                   DECODE(NOTAS.TIPOASIG,'EQ', PENSUM.UMAS, 0) CA_EQ,
                   DECODE(NOTAS.TIPOASIG, NULL, 0, PENSUM.UMAS) CAS                                    
                   
                   
      FROM (SELECT A.CARNET, A.PENSUM, C.CICLO,C.CURSO, C.TIPOASIG,
                 PKG_CURSO.NOMBRE(C.CURSO,C.CARRERA,C.PENSUM,1) NOMCURSOE,
                 PKG_CURSO.NOMBRE(C.CURSO,C.CARRERA,C.PENSUM,2) NOMCURSOI,
                            C.HISTORIAL, MIN(C.UMAS) UMAS
						FROM DBAFISICC.CAALUMCARRSTB A, DBAFISICC.CACATPENSATB C
            WHERE A.CARRERA          = C.CARRERA
						AND   A.PENSUM           = C.PENSUM
						AND   A.CARNET           = PCARNET
						AND   (A.STATALUM <> '4' OR A.CARRERA = PCARRERA)
            AND   NVL(C.HISTORIAL,0) = 1
             AND   A.CARRERA in (SELECT CODIGO 
                                  FROM DBAFISICC.CASUBCARRERASTB 
                                  WHERE CARRERA = PCARRERA 
                                  AND  STATUS  = 'A'
                                  AND  VALIDA_PENSUM IN('S', '1')
                                  AND EXISTEUNIRTB = 0
                               UNION
                               SELECT CARRERA_UNIR
                                  FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                  WHERE CARNET = PCARNET
                                  AND CARRERA = PCARRERA
                                  AND EXISTEUNIRTB > 0
                               UNION 
                               SELECT PCARRERA 
                               FROM DUAL)    
						GROUP BY A.CARNET,A.PENSUM, C.CICLO,C.CURSO, C.TIPOASIG, C.HISTORIAL,
								 PKG_CURSO.NOMBRE(C.CURSO,C.CARRERA,C.PENSUM,1),
                                 PKG_CURSO.NOMBRE(C.CURSO,C.CARRERA,C.PENSUM,2)
                        ORDER BY CICLO) PENSUM,
                        
        ( SELECT SUSTITUTO.EQCURSO CURSO, N.NOTA, N.FECHAIMP, N.CODSTATUS,
               N.TIPOASIG, N.UMAS, N.CARRERA
                 
        FROM ( SELECT CARRERA, CURSO, EQCARRERA, EQCURSO
                   FROM DBAFISICC.CACURSOSEQTB
                   WHERE CARRERA = PCARRERA
                   AND EQCARRERA = PCARRERA
                   AND CURSO NOT IN( SELECT A.CURSO
                                      FROM DBAFISICC.CAALUMNOSNOTASTB A, 
                                           DBAFISICC.CACATPENSATB B
                                      WHERE A.CARNET = PCARNET
                                      AND A.CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 
                                      AND (A.CODSTATUS='S6' OR (A.TIPOASIG='TE'
						                                    AND A.CODSTATUS != 'S0'))
                                      AND B.CARRERA IN
                                         (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 
                                      AND B.PENSUM in (SELECT PENSUM 
                                                    FROM DBAFISICC.CAALUMCARRSTB
                                                    WHERE CARNET = PCARNET
                                                    AND CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) )
                                      AND B.CURSO = A.CURSO)
                   AND EQCURSO IN( SELECT A.CURSO
                                    FROM  DBAFISICC.CACATPENSATB A
                                    WHERE A.CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 
                                    AND A.PENSUM in (SELECT PENSUM 
                                                   FROM DBAFISICC.CAALUMCARRSTB
                                                   WHERE CARNET = PCARNET
                                            AND CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) ))) SUSTITUTO,  
                 
             (SELECT F.CURSO, F.NOTA, F.FECHAIMP,F.CODSTATUS,F.TIPOASIG,
                             NVL(F.UMAS,G.UMAS) UMAS, F.CARRERA
                        FROM DBAFISICC.CAALUMNOSNOTASTB F,
                             DBAFISICC.CAHCURSOSIMPTB G
                        WHERE F.CARNET = PCARNET
                        AND F.CARRERA = G.CARRERA
                        AND F.CURSO = G.CURSO
                        AND F.TIPOASIG = G.TIPOASIG
                        AND F.FECHAIMP = G.FECHAIMP
                        AND F.SECCION = G.SECCION
                        AND   F.CARRERA IN (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 

                        AND (CODSTATUS='S6' OR (F.TIPOASIG='TE'
						                        AND CODSTATUS != 'S0'))) N
              WHERE SUSTITUTO.CURSO = N.CURSO
              
              
                UNION SELECT F.CURSO, F.NOTA, F.FECHAIMP,F.CODSTATUS,F.TIPOASIG,
                             NVL(F.UMAS,G.UMAS) UMAS, F.CARRERA
                        FROM DBAFISICC.CAALUMNOSNOTASTB F,
                             DBAFISICC.CAHCURSOSIMPTB G
                        WHERE F.CARNET = PCARNET
                        AND F.CARRERA = G.CARRERA
                        AND F.CURSO = G.CURSO
                        AND F.TIPOASIG = G.TIPOASIG
                        AND F.FECHAIMP = G.FECHAIMP
                        AND F.SECCION = G.SECCION
                        AND   F.CARRERA IN (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 
                        AND (CODSTATUS='S6' 
                            OR (F.TIPOASIG='TE' AND CODSTATUS != 'S0')) 
                        AND F.CURSO NOT IN(  SELECT SUSTITUTO.CURSO 
                 
        FROM ( SELECT CARRERA, CURSO, EQCARRERA, EQCURSO
                   FROM DBAFISICC.CACURSOSEQTB
                   WHERE CARRERA = PCARRERA
                   AND EQCARRERA = PCARRERA
                   AND CURSO NOT IN( SELECT A.CURSO
                                      FROM DBAFISICC.CAALUMNOSNOTASTB A, 
                                           DBAFISICC.CACATPENSATB B
                                      WHERE A.CARNET = PCARNET
                                      AND A.CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 
                                      AND (A.CODSTATUS='S6' OR (A.TIPOASIG='TE'
						                                    AND A.CODSTATUS != 'S0'))
                                      AND B.CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 
                                      AND B.PENSUM in (SELECT PENSUM 
                                                   FROM DBAFISICC.CAALUMCARRSTB
                                                   WHERE CARNET = PCARNET
                                                   AND CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) )
                                      AND B.CURSO = A.CURSO)
                   AND EQCURSO IN( SELECT A.CURSO
                                    FROM CACATPENSATB A
                                    WHERE A.CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 
                                    AND A.PENSUM in (SELECT PENSUM 
                                            FROM DBAFISICC.CAALUMCARRSTB
                                            WHERE CARNET = PCARNETi
                                            AND CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL)))) SUSTITUTO,  
                 
             (SELECT F.CURSO, F.NOTA, F.FECHAIMP,F.CODSTATUS,F.TIPOASIG,
                             NVL(F.UMAS,G.UMAS) UMAS, F.CARRERA
                        FROM DBAFISICC.CAALUMNOSNOTASTB F,
                             DBAFISICC.CAHCURSOSIMPTB G
                        WHERE F.CARNET = PCARNET
                        AND F.CARRERA = G.CARRERA
                        AND F.CURSO = G.CURSO
                        AND F.TIPOASIG = G.TIPOASIG
                        AND F.FECHAIMP = G.FECHAIMP
                        AND F.SECCION = G.SECCION
                        AND F.CARRERA in (SELECT CODIGO 
                                              FROM DBAFISICC.CASUBCARRERASTB 
                                              WHERE CARRERA = PCARRERA 
                                           UNION
                                           SELECT CARRERA_UNIR
                                              FROM DBAFISICC.CAALUMCARR_UNIRTB 
                                              WHERE CARNET = PCARNET
                                              AND CARRERA = PCARRERA
                                              AND EXISTEUNIRTB > 0
                                           UNION 
                                           SELECT PCARRERA 
                                           FROM DUAL) 

                        AND (CODSTATUS='S6' OR (F.TIPOASIG='TE'
						                        AND CODSTATUS != 'S0'))) N
              WHERE SUSTITUTO.CURSO = N.CURSO)) NOTAS
              WHERE PENSUM.CURSO=NOTAS.CURSO(+)
              ORDER BY PENSUM.CICLO ASC;
            
    END IF;
    
END EXPEDIENTEXALUMNO;
