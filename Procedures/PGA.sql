/*
Autor: Andrea Alvarado
Fecha: 02/11/2011
Descripcion: Devuelve el cursor con los promedios acumulados por ciclo de alumno
por pensum para reportes academicos, recibiendo el carnet y el codigo de carrera
Modificacion: 06/07/2012 - AALVARADO - Agrupacion de cursos para que no se
dupliquen por diferentes creditos academicos, toma el de menor valor.

10/06/2013 - AALVARADO - Se quito la condicion de equivalencias.
AALVARADO - 22/07/2013 - SE AGREGO LA VALIDACION SI ES TIPOASIG = TE
                         QUE TAMBIEN VALIDE QUE NO SEA ANULADO.
AALVARADO - 26/07/2013- Se quito la carrera de pensum para que saque el mismo
promedio tanto en aprobados como por pensum.
 08/08/2013 - AALVARADO - Quitar la condicion de que si las equivalencias no
son en la carrera que se recibe para generar expendiente entonces que no las
tome en cuenta.
26/11/2013 - AALVARADO - Se cambio para el ciclo que se tome de cursos impartido y
no de alumnos notas.
Utilizado: Reportes academicos de certificado y expediente del alumno.

02/12/2013 - AALVARADO - Se agrego el calculo de promedio por ciclo.
16/12/2013 - AALVARADO - Se cambio la tabla para obtener los creditos academicos
ya no es alumnosnotas sino cursosimpartidos.
30/12/2013 - AALVARADO - Se cambio que el procedimiento tome los creditos academicos
de notas y si este es vacio que lo tome de cursos impartidos.
24/01/2014 - AALVARADO - Se cambio la referencia de ciclo.
20/01/2015 - KHERRERA - Se aplica la sustitucion de cursos para IDEA.
23/01/2015 - KHERRERA - Se corrigen los cursos duplicados y la suma de CAS.
28/01/2015 - KHERRERA - Se valida el tipo de asignacion en el pensum para 
                        todos los seminarios sin importar la carrera.
30/01/2015 - KHERRERA - Se corrige la suma de creditos para que sea unicamente
                        los del pensum.
*/
PROCEDURE PGA
(
  RETVAL    OUT SYS_REFCURSOR,
  PCARNET  DBAFISICC.CAALUMNOSTB.CARNET%TYPE,
  PCARRERA DBAFISICC.CACARRERASTB.CARRERA%TYPE
) IS

--Definicion de variables
VPENSUM         DBAFISICC.CAPENSATB.PENSUM%TYPE;
TIENESUBCARRERA NUMBER;
VPROMEDIO NUMBER DEFAULT 0;
VPENSUM2        NUMBER DEFAULT 0;
EXISTEUNIRTB    NUMBER;

BEGIN
--Obtengo el pensum del alumno segun carnet y carrera
   BEGIN
      SELECT PENSUM
        INTO VPENSUM
        FROM DBAFISICC.CAALUMCARRSTB
        WHERE CARNET  = PCARNET
        AND   CARRERA = PCARRERA;
   EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        OPEN RETVAL FOR
          SELECT 'NO EXISTE PENSUM' CICLO, NULL PROMEDIO
             FROM DUAL;
   END;
--obtengo si tiene carreras asociadas, como parte del pensum
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
      OPEN RETVAL FOR

 SELECT A.CARNET, A.CARRERA, A.CICLO, A.PROMEDIO, A.CAS, A.PROMEDIO 
        PROMEDIOXCICLO, A.PROMEDIO2
   
  FROM (SELECT PROMEDIO.CARNET, PROMEDIO.CARRERA, PROMEDIO.CICLO, 
               TRUNC(SUM(PROMEDIO.NOTA * PROMEDIO.CA_PENSUM) / 
                     SUM(PROMEDIO.CA_PENSUM), 0) PROMEDIO,
               TRUNC(SUM(PROMEDIO.NOTA * PROMEDIO.CA_PENSUM) / 
                     SUM(PROMEDIO.CA_PENSUM), 2) PROMEDIO2, 
               SUM(PROMEDIO.CA_PENSUM) CAS
   
    FROM(  SELECT DISTINCT PENSUM.CARNET, NOTAS.CARRERA,PENSUM.CURSO,
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
              ORDER BY PENSUM.CICLO ASC) PROMEDIO
              WHERE TO_CHAR(PROMEDIO.NOTA) != 'A'
              AND PROMEDIO.TIPOASIG != 'EQ' 
              
              GROUP BY PROMEDIO.CARNET, PROMEDIO.CARRERA, PROMEDIO.CICLO
              ORDER BY PROMEDIO.CICLO ASC) A;

   ELSE
      OPEN RETVAL FOR
         
                 
 SELECT A.CARNET, A.CARRERA, A.CICLO, A.PROMEDIO, A.CAS, A.PROMEDIO 
        PROMEDIOXCICLO, A.PROMEDIO2
   
  FROM (SELECT PROMEDIO.CARNET, PROMEDIO.CARRERA, PROMEDIO.CICLO, 
               TRUNC(SUM(PROMEDIO.NOTA * PROMEDIO.CA_PENSUM) / 
                     SUM(PROMEDIO.CA_PENSUM), 0) PROMEDIO, 
               TRUNC(SUM(PROMEDIO.NOTA * PROMEDIO.CA_PENSUM) / 
                     SUM(PROMEDIO.CA_PENSUM), 2) PROMEDIO2, 
                     SUM(PROMEDIO.CA_PENSUM) CAS
   
    FROM(   SELECT DISTINCT PENSUM.CARNET, NOTAS.CARRERA,PENSUM.CURSO,
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
              ORDER BY PENSUM.CICLO ASC) PROMEDIO
              WHERE TO_CHAR(PROMEDIO.NOTA) != 'A'
              AND PROMEDIO.TIPOASIG != 'EQ' 
              
              GROUP BY PROMEDIO.CARNET, PROMEDIO.CARRERA, PROMEDIO.CICLO
              ORDER BY PROMEDIO.CICLO ASC) A;

	END IF;
END PGA;