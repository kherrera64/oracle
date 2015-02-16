/*
  Autor: Andrea Alvarado 
  Fecha: 06/01/2014
  Descripcion: Devuelve un cursor con las carreras por nomina. 
  Modificacion> AALVARADO - 11/01/2014 - Se agrego que tenga funcionalidad 
  para el reporte de nomina temporal
  AALVARADO - 14/01/2014 - Se agrego la solicitud como parametro. 
  AALVARADO - 14/01/2014 - Se agrego el horario como parametro al igual que fecha
  AALVARADO - 27/01/2014 - Se cambiaron los parametros para que tengan valor por
  defecto. 
  AALVARADO - 28/01/2014 - Se cambio la mascara de la fecha a impartir.
  Modificacion: KHERRERA - 08/07/2014 - Se agrega el puesto 000085.
*/


PROCEDURE CARRERASXNOMINA
(
  PCARRERA VARCHAR2 DEFAULT NULL,
  PSECCION2 DBAFISICC.CACURSHORATB.SECCION%TYPE DEFAULT  NULL,
  PSECCION  DBAFISICC.CACURSHORATB.SECCION%TYPE DEFAULT  NULL,
  PPUESTO DBAFISICC.NOPUESTOSTB.CODPUESTO%TYPE DEFAULT  NULL,
  PTIPO  DBAFISICC.CATIPOASIGTB.TIPOASIG%TYPE DEFAULT  NULL,  
  PUSUARIO DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
  PTEMPORAL NUMBER DEFAULT 0,
  PSOLICITUD  DBAFISICC.SOSOLTRAMITETB.SOLICITUD%TYPE DEFAULT NULL,
  PFECHAIMP  DBAFISICC.CAHCURSHORATB.FECHAIMP%TYPE DEFAULT NULL,
  PHORARIO   DBAFISICC.CAHCURSHORATB.HORARIO%TYPE DEFAULT NULL,
  RETVAL OUT SYS_REFCURSOR
)IS 

BEGIN   
  IF PHORARIO IS NOT NULL THEN 
     OPEN RETVAL FOR 
		 SELECT DISTINCT CACU.CARRERA, 
                DBAFISICC.PKG_CARRERA.NOMBRE(CACU.CARRERA,NULL,1) NOMBRE,
                CAR.PAGODOCENTES
           FROM DBAFISICC.CAMAINHORARIOSTB CA,DBAFISICC.RHDOCENTESTB RH, 
                DBAFISICC.CACURSHORATB CACU,
                DBAFISICC.NODOCXHORARIOTB NOMBRADOS, 
                DBAFISICC.CACARRERASTB CAR
           WHERE  CA.HORARIO = RH.HORARIO 
           AND CA.HORARIO = CACU.HORARIO 
           AND RH.HORARIO = NOMBRADOS.HORARIO(+) 
           AND RH.CODPUESTO = NOMBRADOS.CODPUESTO(+)
           AND RH.CODPERS = NOMBRADOS.CODPERS(+)
           AND CAR.CARRERA = CACU.CARRERA
           AND CAR.FACULTAD = '002'
           AND CA.STATUS='A'
           AND NVL(NOMBRADOS.STATUS,'P') = 'P'
           AND CA.HORARIO = PHORARIO
		 UNION 
		 SELECT DISTINCT CACU.CARRERA, 
                DBAFISICC.PKG_CARRERA.NOMBRE(CACU.CARRERA,NULL,1) NOMBRE,
                CAR.PAGODOCENTES
           FROM DBAFISICC.CAHMAINHORARIOSTB CA,DBAFISICC.RHHDOCENTESTB RH, 
                DBAFISICC.CAHCURSHORATB CACU,
                DBAFISICC.NOHDOCXHORARIOTB NOMBRADOS, 
                DBAFISICC.CACARRERASTB CAR
           WHERE  CA.HORARIO = RH.HORARIO 
           AND CA.FECHAIMP = RH.FECHAIMP
           AND CA.HORARIO = CACU.HORARIO 
           AND CA.FECHAIMP = CACU.FECHAIMP
           AND RH.HORARIO = NOMBRADOS.HORARIO(+)
           AND RH.FECHAIMP = NOMBRADOS.FECHAIMP(+) 
           AND RH.CODPUESTO = NOMBRADOS.CODPUESTO(+)
           AND RH.CODPERS = NOMBRADOS.CODPERS(+)
           AND CAR.CARRERA = CACU.CARRERA
           AND CAR.FACULTAD = '002'
           AND CA.STATUS='A'
           AND NVL(NOMBRADOS.STATUS,'P') = 'P'
           AND CA.HORARIO = PHORARIO
           AND TRUNC(CA.FECHAIMP) = TRUNC(PFECHAIMP);	
ELSE
  IF PSOLICITUD IS NULL THEN 
      IF PTEMPORAL = 0 THEN 
          OPEN RETVAL FOR 
            SELECT DISTINCT CACU.CARRERA, 
                   DBAFISICC.PKG_CARRERA.NOMBRE(CACU.CARRERA,NULL,1) NOMBRE,
                  CAR.PAGODOCENTES
              FROM DBAFISICC.CAMAINHORARIOSTB CA,DBAFISICC.RHDOCENTESTB RH, 
                   DBAFISICC.CACURSHORATB CACU,
                   DBAFISICC.NODOCXHORARIOTB NOMBRADOS, 
                   DBAFISICC.CACARRERASTB CAR
              WHERE  CA.HORARIO = RH.HORARIO 
              AND CA.HORARIO = CACU.HORARIO 
              AND RH.HORARIO = NOMBRADOS.HORARIO(+) 
              AND RH.CODPUESTO = NOMBRADOS.CODPUESTO(+)
              AND RH.CODPERS = NOMBRADOS.CODPERS(+)
              AND CAR.CARRERA = CACU.CARRERA
              AND CAR.FACULTAD = '002'
              AND CA.STATUS='A'
              AND NVL(NOMBRADOS.STATUS,'P') = 'P'
              AND (CACU.TIPOASIG = NVL(PTIPO,'AS') OR (PTIPO <> 'ITC' 
                                                      AND CACU.TIPOASIG ='AS'))
              AND ((PPUESTO = '000010'  AND RH.CODPUESTO IN (PPUESTO,'000030',
                                                            '000073','000040',
                                                            '000080','000081'))
                  OR (PPUESTO = '0'AND RH.CODPUESTO NOT IN ('000010','000030',
                                                            '000073','000040',
                                                            '000080','000081'))
                  OR (PPUESTO = '000085')                                          
                  OR PPUESTO IS NULL)
              AND EXISTS
                 (SELECT 1
                    FROM DBAFISICC.CACURSHORATB CACUH
                    WHERE CACU.HORARIO = CACUH.HORARIO
                    AND CACUH.CARRERA IN (SELECT * FROM TABLE(
                    DBAFISICC.SPLIT_VARCHAR(PCARRERA,','))))
                    AND ((PSECCION2 IS NOT NULL AND PSECCION = 'IZ' 
                          AND CACU.SECCION IN ('AN','Z',PSECCION2))
                      OR (PSECCION2 IS NOT NULL AND PSECCION = 'NZ'
                          AND CACU.SECCION = PSECCION2)
                      OR (PSECCION2 IS NOT NULL AND PSECCION = 'SZ'
                          AND CACU.SECCION IN ('AN','Z'))
                      OR (PSECCION2 IS NULL AND PSECCION = 'SZ'
                          AND CACU.SECCION IN ('AN','Z'))
                      OR (PSECCION2 IS NULL AND PSECCION = 'NZ'
                          AND CACU.SECCION NOT IN ('AN','Z'))
                       OR (PSECCION2 IS NULL AND PSECCION = 'IZ'));
      ELSE 
        OPEN RETVAL FOR 
            SELECT DISTINCT CACU.CARRERA, 
                   DBAFISICC.PKG_CARRERA.NOMBRE(CACU.CARRERA,NULL,1) NOMBRE,
                   CAR.PAGODOCENTES
              FROM DBAFISICC.CAMAINHORARIOSTMP CA,DBAFISICC.RHDOCENTESTMP RH, 
                   DBAFISICC.CACURSHORATMP CACU,
                   DBAFISICC.NODOCXHORARIOTB NOMBRADOS,
                   DBAFISICC.CACARRERASTB CAR
              WHERE  CA.HORARIO = RH.HORARIO 
              AND CA.HORARIO = CACU.HORARIO 
              AND RH.HORARIO = NOMBRADOS.HORARIO(+) 
              AND RH.CODPUESTO = NOMBRADOS.CODPUESTO(+)
              AND RH.CODPERS = NOMBRADOS.CODPERS(+)
              AND CAR.CARRERA = CACU.CARRERA
              AND CAR.FACULTAD = '002'
              AND CA.STATUS='A'
              AND NVL(NOMBRADOS.STATUS,'P') = 'P'
              AND (CACU.TIPOASIG = NVL(PTIPO,'AS') OR (PTIPO <> 'ITC' 
                                                      AND CACU.TIPOASIG ='AS'))
              AND ((PPUESTO = '000010'  AND RH.CODPUESTO IN (PPUESTO,'000030',
                                                            '000073','000040',
                                                            '000080','000081'))
                  OR (PPUESTO = '0'AND RH.CODPUESTO NOT IN ('000010','000030',
                                                            '000073','000040',
                                                            '000080','000081'))
                  OR (PPUESTO = '000085')                                          
                  OR PPUESTO IS NULL)
              AND EXISTS
                 (SELECT 1
                    FROM DBAFISICC.CACURSHORATMP CACUH
                    WHERE CACU.HORARIO = CACUH.HORARIO
                    AND CACUH.CARRERA IN (SELECT * FROM TABLE(
                    DBAFISICC.SPLIT_VARCHAR(PCARRERA,','))))
                    AND ((PSECCION2 IS NOT NULL AND PSECCION = 'IZ' 
                          AND CACU.SECCION IN ('AN','Z',PSECCION2))
                      OR (PSECCION2 IS NOT NULL AND PSECCION = 'NZ'
                          AND CACU.SECCION = PSECCION2)
                      OR (PSECCION2 IS NOT NULL AND PSECCION = 'SZ'
                          AND CACU.SECCION IN ('AN','Z'))
                      OR (PSECCION2 IS NULL AND PSECCION = 'SZ'
                          AND CACU.SECCION IN ('AN','Z'))
                      OR (PSECCION2 IS NULL AND PSECCION = 'NZ'
                          AND CACU.SECCION NOT IN ('AN','Z'))
                       OR (PSECCION2 IS NULL AND PSECCION = 'IZ'));
      END IF; 
  ELSE 
    OPEN RETVAL FOR 
        SELECT DISTINCT CACU.CARRERA, 
               DBAFISICC.PKG_CARRERA.NOMBRE(CACU.CARRERA,NULL,1) NOMBRE,
               CAR.PAGODOCENTES
          FROM DBAFISICC.CAMAINHORARIOSTB CA,DBAFISICC.RHDOCENTESTB RH, 
               DBAFISICC.CACURSHORATB CACU,DBAFISICC.NODOCXHORARIOTB NOMBRADOS, 
               DBAFISICC.CACARRERASTB CAR
          WHERE  CA.HORARIO = RH.HORARIO 
          AND CA.HORARIO = CACU.HORARIO 
          AND RH.HORARIO = NOMBRADOS.HORARIO(+) 
          AND RH.CODPUESTO = NOMBRADOS.CODPUESTO(+)
          AND RH.CODPERS = NOMBRADOS.CODPERS(+)
          AND CAR.CARRERA = CACU.CARRERA
          AND CAR.FACULTAD = '002'
          AND CA.STATUS='A'
          AND NVL(NOMBRADOS.STATUS,'P') = 'P'
          AND RH.SOLICITUD = PSOLICITUD;
  END IF; 
END IF;
END CARRERASXNOMINA;