/*
  Nombre:       RESUMEN.
  Autor:        Luis Merida
  Fecha:        10/01/2013
  Package:      PKG_REPORTES
  Descripción:  Este procedimiento devuelve los datos para el resumen del
                reporte, estado de cuenta alumnos.
                El procedimiento es utilizado por EDOCTA.rdl.
  Modificacion: AALVARADO - 16/04/2013- Se divide para identificar los de 
  actual e historico
  
  Modificacion: KHERRERA - 19/12/2014 - Se filtra por carrera_sede y si no
                se encuentran por carrera.
  */

PROCEDURE RESUMEN
  (  
    RETVAL           OUT SYS_REFCURSOR,  
    PCARRERA         IN  DBAFISICC.CACARRERASTB.CARRERA%TYPE DEFAULT NULL,  
    PCARNET          IN  DBAFISICC.CAALUMCARRSTB.CARNET%TYPE DEFAULT NULL,
    PSTATUS          IN  DBAFISICC.GNSTATALUMSTB.STATALUM%TYPE DEFAULT NULL,
    PFECHAIMP        IN  VARCHAR2 DEFAULT NULL
  )
  IS
  BEGIN
  /* AALVARADO - 16/04/2013 - Se divide para identificar los de actual e historico*/
    IF PFECHAIMP != '0' THEN 
    /*AALVARADO - 16/04/2013*/
        OPEN RETVAL FOR
            SELECT LLAVE, TO_CHAR(SUM(SALDO),'999,999.99')  SALDO
                FROM (SELECT A.CARNET||A.CARRERA LLAVE, CORRELATIVO, 
                DECODE (CARGO_ABONO, 'C', A.MONTO,-A.MONTO) SALDO
                        FROM DBAFISICC.CCHEDOCTATB A
                        WHERE 
                        CARNET IN (SELECT CARNET 
                                   FROM DBAFISICC.CAALUMCARRSTB
                                   WHERE (CARNET = PCARNET OR PCARNET IS NULL)
                                   AND (NVL(CARRERA_SEDE,CARRERA) 
                                        IN(SELECT * 
                                             FROM TABLE
                                             (SPLIT_VARCHAR(PCARRERA,','))) 
                                             OR PCARRERA IS NULL)
                                   AND (INSCRITO = PSTATUS OR PSTATUS IS NULL)) 
                        AND (NVL(A.CENTRO, A.CARRERA) 
                             IN (SELECT * 
                                  FROM TABLE 
                                   (SPLIT_VARCHAR(PCARRERA,','))) 
                                   OR PCARRERA IS NULL)
                        AND TO_CHAR(A.FECHAIMP,'mm/yyyy')=PFECHAIMP)
              GROUP BY LLAVE;
    ELSE 
        OPEN RETVAL FOR 
          SELECT LLAVE, TO_CHAR(SUM(SALDO),'999,999.99')  SALDO
                FROM (SELECT A.CARNET||A.CARRERA LLAVE , CORRELATIVO, 
                        DECODE (CARGO_ABONO, 'C', A.MONTO,-A.MONTO) SALDO
                        FROM DBAFISICC.CCEDOCTATB A
              WHERE 
              CARNET IN (SELECT CARNET 
                                 FROM DBAFISICC.CAALUMCARRSTB
                                 WHERE (CARNET = PCARNET OR PCARNET IS NULL)
                                 AND (NVL(CARRERA_SEDE, CARRERA) 
                                     IN(SELECT * 
                                         FROM TABLE 
                                         (SPLIT_VARCHAR(PCARRERA,','))) 
                                         OR PCARRERA IS NULL)
                                 AND (INSCRITO = PSTATUS OR PSTATUS IS NULL))
              AND (NVL(CENTRO, CARRERA) IN (SELECT * 
                                              FROM TABLE 
                                              (SPLIT_VARCHAR(PCARRERA,','))) 
                                              OR PCARRERA IS NULL)
              AND PFECHAIMP='0')
          GROUP BY LLAVE;
    END IF;
END RESUMEN;