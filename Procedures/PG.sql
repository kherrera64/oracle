/*
Autor: Andrea Alvarado
Fecha: 29/11/2013
Descripcion: Devuelve el promedio general alumno por pensum para reportes
academicos, recibiendo el carnet y el codigo de carrera

Utilizado: Reportes academicos de certificado y expediente del alumno.
Modificacion: AALVARADO - 17/12/2013 - Se quita los creditos academicos.
30/12/2013 - AALVARADO - Se cambio que el procedimiento tome los creditos
academicos de notas y si este es vacio que lo tome de cursos impartidos.

20/01/2015 - KHERRERA - Se aplica la sustitucion de cursos para IDEA.
23/01/2015 - KHERRERA - Se corrigen los cursos duplicados y la suma de CAS.
28/01/2015 - KHERRERA - Se valida el tipo de asignacion en el pensum para 
                        todos los seminarios sin importar la carrera.
30/01/2015 - KHERRERA - Se corrige la suma de creditos para que sea unicamente
                        los del pensum.
*/
FUNCTION PG
(
  PCARNET  DBAFISICC.CAALUMNOSTB.CARNET%TYPE,
  PCARRERA DBAFISICC.CACARRERASTB.CARRERA%TYPE
) RETURN NUMBER
IS

--Definicion de variables
VPENSUM         CAPENSATB.PENSUM%TYPE;
TIENESUBCARRERA NUMBER;
PROMEDIO        NUMBER;
VPENSUM2        NUMBER DEFAULT 0;
EXISTEUNIRTB    NUMBER;

BEGIN
--Obtengo el pensum del alumno segun carnet y carrera
   BEGIN
      SELECT PENSUM
        INTO VPENSUM
        FROM CAALUMCARRSTB
        WHERE CARNET  = PCARNET
        AND   CARRERA = PCARRERA;
   EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        RETURN -1;
   END;

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
   
    IF PCARRERA = 'LITA' THEN
   
    BEGIN
     
      SELECT 1 INTO VPENSUM2
       FROM (SELECT A.PENSUM 
              FROM ( SELECT TO_NUMBER(SUBSTR(TO_CHAR(PENSUM),6,4)) YEAR2, PENSUM  
                        FROM CAPENSATB
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
   
   
--Si no tiene carreras asociadas puedo devolver la tabla de ciclos y
--promedio por ciclo
   IF (TIENESUBCARRERA < 1 ) THEN
              SELECT DISTINCT TO_NUMBER(TRUNC(DECODE(SUM(DECODE(TOTAL.NOTA,NULL,0,
             TOTAL.CA_PENSUM)),0,0,SUM(DECODE(TOTAL.NOTA,NULL,0,
             TOTAL.CA_PENSUM*TOTAL.NOTA))/SUM(DECODE(TOTAL.NOTA,NULL,0,TOTAL.CA_PENSUM)
             )),0))
        INTO PROMEDIO FROM 
              (   SELECT DISTINCT PENSUM.CARNET, NOTAS.CARRERA,PENSUM.CURSO,
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
              WHERE PENSUM.CURSO=NOTAS.CURSO
              AND NOTAS.TIPOASIG != 'EQ'
              ORDER BY PENSUM.CICLO ASC) TOTAL
              WHERE TO_CHAR(TOTAL.NOTA) != 'A';

-- Si tiene subcarreras tengo que sacar primero el pensum completo del alumno
--luego completarlo con las  notas y por ultimo por ciclo saco los promedio de
--acuerdo a ese pensum.
   ELSE
                 
             SELECT DISTINCT TO_NUMBER(TRUNC(DECODE(SUM(DECODE(TOTAL.NOTA,NULL,0,
             TOTAL.CA_PENSUM)),0,0,SUM(DECODE(TOTAL.NOTA,NULL,0,
             TOTAL.CA_PENSUM*TOTAL.NOTA))/SUM(DECODE(TOTAL.NOTA,NULL,0,TOTAL.CA_PENSUM)
             )),0))
        INTO PROMEDIO FROM 
              (    SELECT DISTINCT PENSUM.CARNET, NOTAS.CARRERA,PENSUM.CURSO,
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
              WHERE PENSUM.CURSO=NOTAS.CURSO
              AND NOTAS.TIPOASIG != 'EQ'
              ORDER BY PENSUM.CICLO ASC) TOTAL
              WHERE TO_CHAR(TOTAL.NOTA) != 'A';
	END IF;
  RETURN PROMEDIO;
END PG;