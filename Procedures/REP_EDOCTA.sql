/*
  Nombre:       REP_EDOCTA.
  Autor:        Luis Mérida
  Fecha:        10/01/2013
  Package:      PKG_REPORTES
  Descripción:  Este procedimiento devuelve los datos necesario para el reporte,
                estado de cuenta de los alumnos.
                El procedimiento es utilizado por EDOCTA.rdl.
  Modificación: AALVARADO - 16/04/2013 
               Se separo el actual con historico. 
               AALVARADO - 10/12/2013 - Quite el detalle de este reporte. 
               
  Modificacion: KHERRERA - 19/12/2014 - Se filtra por carrera_sede y si no
                se encuentran por carrera.
*/
 PROCEDURE REP_EDOCTA
  (  
    RETVAL           OUT SYS_REFCURSOR,  
    PCARRERA         IN  DBAFISICC.CACARRERASTB.CARRERA%TYPE DEFAULT NULL,  
    PCARNET          IN  DBAFISICC.CAALUMCARRSTB.CARNET%TYPE DEFAULT NULL,
    PSTATUS          IN  DBAFISICC.GNSTATALUMSTB.STATALUM%TYPE DEFAULT NULL,
    PFECHAIMP        IN  VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
    IF PFECHAIMP = '0' THEN 
    
        OPEN RETVAL FOR
            SELECT E.CARNET||E.CODCARRERA LLAVE, E.CARRERA, E.CODCARRERA,
                   E.CARNET, E.ALUMNO, E.CICLO, E.STATALUM, E.JORNADA, 
                   'ACTUAL' FECHAIMP, E.BECATI, E.PORCENTAJEMT,E.PORCENTAJECT,
                   TO_CHAR(E.CANTIDADFIJAMT,'999,999.99') CANTIDADFIJAMT,  
                   TO_CHAR(E.CANTIDADFIJA,'999,999.99') CANTIDADFIJA, 
                   R.MOVIMIENTO RMOVIMIENTO, R.CURSO RCURSO, 
                   TO_CHAR(R.CARGO,'999,999.99') RCARGO, 
                   TO_CHAR(R.PAGO,'999,999.99')  RPAGO, 
                   TO_CHAR(R.ABONO,'999,999.99') RABONO, 
                   TO_CHAR(R.SALDO,'999,999.99') RSALDO,C.CARRERA CCARRERA,
                   C.CICLO CCICLO, C.UMAS, C.CURSO CCURSO, C.NOMBRE CNOMBRE, 
                   C.TIPOASIG, C.SECCION, C.CODSTATUS, C.STATUSCURSO
               FROM (SELECT A.CARNET, NVL(A.CARRERA_SEDE,A.CARRERA) CODCARRERA, 
                      A.CICLO, D.NOMBRE STATALUM, A.JORNADA,
                      A.CARNET||' - '||DBAFISICC.PKG_ALUMNO.NOMBRE(A.CARNET, 1) 
                      ALUMNO, DBAFISICC.PKG_CARRERA.NOMBRE(
                      NVL(A.CARRERA_SEDE,A.CARRERA),NULL,4) CARRERA , 
                      NVL(E.DESCRIPCION,'NO TIENE BECA') BECATI, A.PORCENTAJEMT, 
                      A.PORCENTAJECT, A.CANTIDADFIJA, A.CANTIDADFIJAMT
                        
                        FROM DBAFISICC.CAALUMCARRSTB A,
                             DBAFISICC.GNSTATALUMSTB D, 
                             DBAFISICC.CABECASTB E
                        WHERE A.STATALUM=D.STATALUM
                        AND E.TIPOBECA(+)=A.TIPOBECA) E,
                    (SELECT A.CARNET, NVL(A.CENTRO, A.CARRERA) CARRERA, 
                    (CASE WHEN (CODMOVTO IN ('CT','CR','BC','AS','RT')) THEN 'CT' 
                          WHEN (CODMOVTO IN ('MT','MTB')) THEN 'MT'
                          ELSE CODMOVTO END) MOVIMIENTO, 
                     CASE WHEN (CODMOVTO IN ('AS','MU')) THEN '' 
                           ELSE CURSO END CURSO, 
                     SUM(DECODE (CARGO_ABONO, 'C', A.MONTO,0)) CARGO, 
                     SUM(CASE WHEN CARGO_ABONO='A' 
                     AND EXISTS(SELECT 1 
                                  FROM DBAFISICC.CCRECIBOSTB
                                  WHERE RECIBO=OPERACION) 
                               THEN A.MONTO ELSE 0 END) PAGO, 
                    SUM(CASE WHEN CARGO_ABONO='A' 
                    AND NOT EXISTS(SELECT 1 
                                    FROM DBAFISICC.CCRECIBOSTB 
                                      WHERE RECIBO=OPERACION) 
                                     THEN A.MONTO ELSE 0 END) ABONO, 
                    SUM(DECODE (CARGO_ABONO, 'C', A.MONTO,-A.MONTO)) SALDO
                        FROM DBAFISICC.CCEDOCTATB A
                        WHERE A.CARNET||'-'||A.CARRERA 
                              IN (SELECT CARNET||'-'||CARRERA
                                     FROM DBAFISICC.CAALUMCARRSTB
                                     WHERE (CARNET = PCARNET OR PCARNET IS NULL)
                                     AND (NVL(CARRERA_SEDE, CARRERA) 
                                         IN(SELECT * 
                                            FROM TABLE
                                            (SPLIT_VARCHAR(PCARRERA,','))) 
                                            OR PCARRERA IS NULL)
                                     AND (INSCRITO = PSTATUS OR PSTATUS IS NULL))
                        GROUP BY A.CARNET, NVL(A.CENTRO, A.CARRERA), 
                                 CASE WHEN (CODMOVTO IN ('CT','CR','BC','AS',
                                            'RT')) THEN 'CT' 
                                       WHEN (CODMOVTO IN ('MT','MTB'))
                                       THEN 'MT' ELSE CODMOVTO END,
                                 CASE WHEN (CODMOVTO  IN ('AS','MU')) 
                                 THEN '' ELSE CURSO END 
                     ORDER BY MOVIMIENTO) R, 
                    (SELECT A.CARNET,A.CARRERA, B.CICLO, B.UMAS, A.CURSO,
                    DBAFISICC.PKG_CURSO.NOMBRE(A.CURSO,A.CARRERA,B.PENSUM,1) 
                    NOMBRE, A.TIPOASIG, A.SECCION, A.CODSTATUS, D.STATUSCURSO 
                        FROM DBAFISICC.CAASIGNACIONESTB A,
                             DBAFISICC.CACURSOSIMPTB B, 
                             DBAFISICC.CASTATCURSTB D
                        WHERE A.CODSTATUS=D.CODSTATUS
                        AND A.CURSO=B.CURSO
                        AND A.CARRERA=B.CARRERA
                        AND A.SECCION=B.SECCION
                        AND A.TIPOASIG=B.TIPOASIG
                        AND A.CARNET IN (SELECT CARNET
                                     FROM DBAFISICC.CAALUMCARRSTB
                                     WHERE (CARNET = PCARNET OR PCARNET IS NULL)
                                     AND (NVL(CARRERA_SEDE,CARRERA)
                                         IN(SELECT *
                                            FROM TABLE 
                                            (SPLIT_VARCHAR(PCARRERA,','))) 
                                            OR PCARRERA IS NULL)
                                     AND (INSCRITO = PSTATUS 
                                          OR PSTATUS IS NULL))) C
               WHERE E.CARNET=R.CARNET(+)
               AND E.CODCARRERA=R.CARRERA(+)
               AND E.CARNET=C.CARNET(+) 
               AND E.CODCARRERA=C.CARRERA(+)
               AND E.CARNET IN (SELECT CARNET 
                                   FROM DBAFISICC.CAALUMCARRSTB
                                   WHERE (CARNET = PCARNET OR PCARNET IS NULL)
                                   AND (NVL(CARRERA_SEDE, CARRERA)
                                       IN(SELECT * 
                                          FROM TABLE 
                                          (SPLIT_VARCHAR(PCARRERA,','))) 
                                          OR PCARRERA IS NULL)
                                   AND (INSCRITO = PSTATUS OR PSTATUS IS NULL))
               AND (E.CODCARRERA IN(SELECT * 
                                     FROM TABLE 
                                     (SPLIT_VARCHAR(PCARRERA,','))) 
                                     OR PCARRERA IS NULL);
    ELSE
        OPEN RETVAL FOR
              SELECT E.CARNET||E.CODCARRERA LLAVE, E.CARRERA, E.CODCARRERA,
                     E.CARNET, E.ALUMNO, E.CICLO, E.STATALUM, E.JORNADA,
                     TO_CHAR(E.FECHAIMP,'mm/yyyy') FECHAIMP, E.BECATI, 
                     E.PORCENTAJEMT, TO_CHAR(E.CANTIDADFIJAMT,'999,999.99')
                     CANTIDADFIJAMT, E.PORCENTAJECT, 
                     TO_CHAR(E.CANTIDADFIJA,'999,999.99') CANTIDADFIJA, 
                     R.MOVIMIENTO RMOVIMIENTO, R.CURSO RCURSO, 
                     TO_CHAR(R.CARGO,'999,999.99')  RCARGO, 
                     TO_CHAR(R.PAGO,'999,999.99')  RPAGO, 
                     TO_CHAR(R.ABONO,'999,999.99') RABONO, 
                     TO_CHAR(R.SALDO,'999,999.99') RSALDO, C.CARRERA CCARRERA, 
                     C.CICLO CCICLO, C.UMAS, C.CURSO CCURSO, C.NOMBRE CNOMBRE,
                     C.TIPOASIG, C.SECCION, C.CODSTATUS, C.STATUSCURSO
                 FROM (SELECT G.CARNET, NVL(G.CARRERA_SEDE, G.CARRERA) 
                              CODCARRERA, G.CICLO, D.NOMBRE STATALUM, G.JORNADA, 
                              G.CARNET||' - '||
                              DBAFISICC.PKG_ALUMNO.NOMBRE(G.CARNET,1) ALUMNO, 
                              DBAFISICC.PKG_CARRERA.NOMBRE(NVL(
                              G.CARRERA_SEDE,G.CARRERA),NULL,4) CARRERA, 
                              NVL(E.DESCRIPCION,'NO TIENE BECA') BECATI, 
                              F.PORCENTAJEMT, F.PORCENTAJECT, F.CANTIDADFIJA, 
                              F.CANTIDADFIJAMT, G.FECHAINSCRITO FECHAIMP
                          FROM DBAFISICC.GNSTATALUMSTB D, DBAFISICC.CABECASTB E, 
                               DBAFISICC.CAHBECASTB F, 
                               DBAFISICC.CAHINSCRITOSTB G
                          WHERE G.STATALUM=D.STATALUM
                          AND E.TIPOBECA(+)=F.TIPOBECA
                          AND F.CARNET(+)=G.CARNET
                          AND NVL(F.CARRERA_SEDE, F.CARRERA(+))
                              = NVL(G.CARRERA_SEDE,G.CARRERA)
                          AND F.FECHAIMP(+)=G.FECHAINSCRITO
                       ORDER BY G.FECHAINSCRITO) E, 
                      (SELECT A.CARNET, NVL(A.CENTRO,A.CARRERA) CARRERA, 
                              (CASE WHEN (CODMOVTO IN ('CT','CR','BC','AS',
                                                       'RT')) THEN 'CT' 
                                    WHEN (CODMOVTO IN ('MT','MTB')) THEN 'MT'
                                    ELSE CODMOVTO END) MOVIMIENTO, 
                               CASE WHEN (CODMOVTO IN ('AS','MU')) THEN '' 
                                    ELSE CURSO END CURSO, 
                              SUM(DECODE (CARGO_ABONO, 'C', A.MONTO,0)) CARGO, 
                              SUM(CASE WHEN CARGO_ABONO='A' 
                              AND EXISTS(SELECT 1 
                                            FROM DBAFISICC.CCRECIBOSTB 
                                            WHERE RECIBO=OPERACION) 
                                  THEN A.MONTO 
                                  ELSE 0 END) PAGO, 
                                  SUM(CASE WHEN CARGO_ABONO='A' 
                                      AND NOT EXISTS(SELECT 1 
                                                     FROM DBAFISICC.CCRECIBOSTB 
                                                     WHERE RECIBO=OPERACION)
                                      THEN A.MONTO ELSE 0 END) ABONO,
                              SUM(DECODE(CARGO_ABONO, 'C', A.MONTO,-A.MONTO)) 
                              SALDO, A.FECHAIMP
                          FROM DBAFISICC.CCHEDOCTATB A
                          WHERE A.CARNET||'-'||NVL(A.CENTRO,A.CARRERA) 
                                IN (SELECT CARNET||'-'||NVL(CARRERA_SEDE, CARRERA)
                                     FROM DBAFISICC.CAALUMCARRSTB
                                     WHERE (CARNET = PCARNET OR PCARNET IS NULL)
                                     AND (NVL(CARRERA_SEDE, CARRERA) 
                                         IN(SELECT * 
                                            FROM TABLE 
                                            (SPLIT_VARCHAR(PCARRERA,','))) 
                                            OR PCARRERA IS NULL)
                                     AND(INSCRITO = PSTATUS OR PSTATUS IS NULL))
                         AND    TO_CHAR(A.FECHAIMP,'mm/yyyy') = PFECHAIMP
                      GROUP BY A.CARNET, NVL(A.CENTRO, A.CARRERA), 
                      CASE WHEN (CODMOVTO IN ('CT','CR','BC','AS','RT')) 
                           THEN 'CT' 
                       WHEN (CODMOVTO IN ('MT','MTB')) 
                           THEN 'MT'
                           ELSE CODMOVTO END, 
                      CASE WHEN (CODMOVTO  IN ('AS','MU')) THEN '' 
                      ELSE CURSO END, A.FECHAIMP 
                      ORDER BY FECHAIMP, MOVIMIENTO) R, 
                      (SELECT A.CARNET,A.CARRERA, B.CICLO, B.UMAS,  A.CURSO, 
                       DBAFISICC.PKG_CURSO.NOMBRE(A.CURSO,A.CARRERA,B.PENSUM,1) 
                       NOMBRE, A.TIPOASIG, A.SECCION, A.CODSTATUS, 
                       D.STATUSCURSO, A.FECHAIMP
                          FROM DBAFISICC.CAHASIGNASTB A, 
                          DBAFISICC.CAHCURSOSIMPTB B, 
                          DBAFISICC.CASTATCURSTB D
                          WHERE A.CODSTATUS=D.CODSTATUS
                          AND A.CURSO=B.CURSO
                          AND A.CARRERA=B.CARRERA
                          AND A.SECCION=B.SECCION
                          AND A.TIPOASIG=B.TIPOASIG
                          AND A.FECHAIMP=B.FECHAIMP
                          AND A.CARNET 
                              IN (SELECT CARNET
                                    FROM DBAFISICC.CAALUMCARRSTB
                                    WHERE (CARNET = PCARNET OR PCARNET IS NULL)
                                    AND (NVL(CARRERA_SEDE, CARRERA) 
                                          IN(SELECT *
                                             FROM TABLE 
                                             (SPLIT_VARCHAR(PCARRERA,','))) 
                                             OR PCARRERA IS NULL)
                                    AND (INSCRITO = PSTATUS OR PSTATUS IS NULL))
                         AND    TO_CHAR(A.FECHAIMP,'mm/yyyy') = PFECHAIMP
                       ORDER BY A.FECHAIMP, A.CURSO) C
                 WHERE  E.CARNET=R.CARNET(+)
                 AND E.CODCARRERA=R.CARRERA(+)
                 AND E.CARNET=C.CARNET(+)
                 AND E.CODCARRERA=C.CARRERA(+)
                 AND E.FECHAIMP=R.FECHAIMP
                 AND R.FECHAIMP=C.FECHAIMP
                 AND E.CARNET IN (SELECT CARNET 
                                    FROM DBAFISICC.CAALUMCARRSTB
                                    WHERE (CARNET = PCARNET OR PCARNET IS NULL)
                                    AND (NVL(CARRERA_SEDE,CARRERA) 
                                         IN(SELECT * 
                                             FROM TABLE 
                                             (SPLIT_VARCHAR(PCARRERA,','))) 
                                             OR PCARRERA IS NULL)
                                    AND (INSCRITO = PSTATUS OR PSTATUS IS NULL))
                 AND (E.CODCARRERA IN(SELECT * 
                                       FROM TABLE (SPLIT_VARCHAR(PCARRERA,',')))
                                       OR PCARRERA IS NULL)
                 AND TO_CHAR(E.FECHAIMP,'mm/yyyy') = PFECHAIMP;
  END IF; 
EXCEPTION  
   WHEN NO_DATA_FOUND THEN
      OPEN RETVAL FOR
          SELECT 'NO SE ENCONTRO DATOS' LLAVE, NULL CARRERA, NULL CODCARRERA,
                 NULL CARNET, NULL ALUMNO, NULL CICLO, NULL STATALUM, NULL
                 JORNADA, NULL FECHAIMP, NULL BECATI, NULL PORCENTAJEMT, NULL 
                 CANTIDADFIJAMT, NULL PORCENTAJECT, NULL CANTIDADFIJA, NULL 
                 FECHA, NULL DOCUMENTO, NULL FRACCION, NULL CODMOVTO, NULL 
                 MOVIMIENTO, NULL CARGO, NULL ABONO, NULL SALDO, NULL CURSO, 
                 NULL RMOVIMIENTO, NULL RCURSO, NULL RCARGO, NULL RPAGO, 
                 NULL RABONO, NULL RSALDO, NULL CCARRERA, NULL CCICLO, 
                 NULL UMAS, NULL CCURSO, NULL CNOMBRE, NULL TIPOASIG,
                 NULL SECCION, NULL CODSTATUS, NULL STATUSCURSO
             FROM DUAL;
END REP_EDOCTA;