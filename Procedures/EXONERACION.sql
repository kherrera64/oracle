/*
AUTOR:  AMILCAR MARTINEZ 
FECHA:  24/07/2014
PAQUETE: PKG_
DESCRIPCION: REALIZA LAS EXONERACIONES DE PAGOS POR ALUMNO. 
DEVUELVE:    0 si no hay error
*/

FUNCTION EXONERACION (
PUSUARIO                DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE, 
PCARNET                 DBAFISICC.CAALUMCARRSTB.CARNET%TYPE,
PCARRERA                DBAFISICC.CAALUMCARRSTB.CARRERA%TYPE,
PPENSUM                 DBAFISICC.CAALUMCARRSTB.PENSUM%TYPE,
PCODMOVTO               DBAFISICC.CCTIPOMOVTOTB.CODMOVTO%TYPE,
PCURSO                  DBAFISICC.CACURSOSTB.CURSO%TYPE,
PMONTO                  DBAFISICC.CCEDOCTATB.MONTO%TYPE,
PSOLICITUD              DBAFISICC.CCEDOCTATB.OPERACION%TYPE,
PCENTRO                 DBAFISICC.CCEDOCTATB.CENTRO%TYPE,
POBSERVACIONES          DBAFISICC.CCEDOCTATB.OBSERVACIONES%TYPE
)
RETURN VARCHAR2
IS
   RET_VALUE                       VARCHAR2(3);
   VINVERSO                        CCTIPOMOVTOTB.INVERSO%TYPE;
   ALERT_ID                        NUMBER;
   ABONOS_MOVTO                    CCEDOCTATB.MONTO%TYPE;
   VMONTO                          CCEDOCTATB.MONTO%TYPE := 0;
   VNUMCTA                         CCEDOCTATB.NUMCTA%TYPE;
   VCORRELATIVO                    CCEDOCTATB.CORRELATIVO%TYPE;
   EXISTE_HC                       NUMBER(1);
   MONTO_EXONERAR                  CCEDOCTATB.MONTO%TYPE := 0;
   PUEDE_EXONERAR                  CCEDOCTATB.MONTO%TYPE := 0;

BEGIN     
   SELECT COUNT(A.CARNET) INTO EXISTE_HC
      FROM DBAFISICC.CCEDOCTATB A
      WHERE A.CARNET = PCARNET
      AND A.CARRERA = PCARRERA
      AND A.CODMOVTO = PCODMOVTO
      AND NVL(A.CURSO,'0') = NVL(PCURSO,'0')
      AND NVL(A.OPERACION,0) = PSOLICITUD
      AND A.CARGO_ABONO = 'A';
        
   IF EXISTE_HC > 0
   THEN
      RETURN('Esta hoja de cambio ya esta ingresada');
   END IF;
         
   SELECT MAX(NVL(A.CORRELATIVO,0)) INTO VCORRELATIVO
       FROM DBAFISICC.CCEDOCTATB A
       WHERE A.CARNET = PCARNET
       AND   A.CARRERA = PCARRERA;
      
   VCORRELATIVO := VCORRELATIVO + 1;

      SELECT A.PERIODO INTO VNUMCTA
        FROM DBAFISICC.CACARRERASTB A
        WHERE A.CARRERA = PCARRERA;
    
            
      INSERT INTO CCEDOCTATB(PENSUM,CARRERA,CARNET,CORRELATIVO,NUMCTA,CODMOVTO,
                             FECHA,MONTO,CARGO_ABONO,CURSO,OBSERVACIONES,
                             OPERACION,FRACCION,INI_FRAC,CENTRO)
      VALUES(PPENSUM,PCARRERA,PCARNET,VCORRELATIVO,VNUMCTA,PCODMOVTO,
             TRUNC(SYSDATE),PMONTO,'A',PCURSO,PUSUARIO||' - '||POBSERVACIONES,
             PSOLICITUD,NULL,NULL,PCENTRO);
             
      RETURN('0');

END EXONERACION;