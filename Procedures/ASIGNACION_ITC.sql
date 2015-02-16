/*
  AUTOR: Andrea Alvarado
  Fecha: 14/11/2013 
  Descripcion: Realiza la asignacion de un interciclo si es necesario devuelve 
               mensaje de error. 
               
  AUTOR: Kevin Herrera
  Fecha: 15/11/2013 
  Descripcion: Se agrega periodo. 
*/
FUNCTION ASIGNACION_ITC(
     PCARNET      DBAFISICC.CAALUMCARRSTB.CARNET%TYPE,
     PCARRERA     DBAFISICC.CAALUMCARRSTB.CARRERA%TYPE,
     PCORRELATIVO DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE,
     PSOLICITUD   DBAFISICC.SOSOLTRAMITETB.SOLICITUD%TYPE,
     PCURSO       DBAFISICC.CAITCCURSOSDETALLETB.CURSO%TYPE,
     PSECCION     DBAFISICC.CAITCCURSOSDETALLETB.SECCION%TYPE,
     PPENSUMALUM  DBAFISICC.CAALUMCARRSTB.PENSUM%TYPE,
     PPENSUMCURSO DBAFISICC.CAITCCURSOSDETALLETB.PENSUM%TYPE,
     PDIRECCION   DBAFISICC.CAITCCURSOSDETALLETB.DIRECCION%TYPE,
     PCARGO       DBAFISICC.CCEDOCTATB.MONTO%TYPE,
     PUSUARIO      DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
     PPERIODO      DBAFISICC.CAASIGNACIONESTB.PERIODO%TYPE,
     PMENSAJE     OUT VARCHAR2
) RETURN NUMBER IS

  VMAXALUM DBAFISICC.CAITCCURSOSIMPTB.MAXALUM%TYPE;
  VNUMALUM DBAFISICC.CAITCCURSOSIMPTB.NUMALUM%TYPE;
  ESPENSUMNUEVO  NUMBER(2);
  VCORPENALUM    NUMBER(4);
  VCORPENCUR     NUMBER(4);  
  ESACTIVO       NUMBER(2); --Guarda si el alumno esta activo.
  VCARGOMTI      NUMBER(2); --Cuenta si hay cargos de Matricula
  VCARGOMTHIST   NUMBER(2); --cuenta si hay cargos en historico de matricula
  VCOBROMT       DBAFISICC.CACARRERASTB.COBROINS%TYPE;
  VALIDAPENSUM   NUMBER(1);
  VASIGNACIONANTERIOR NUMBER(2);
  VASIGNACIONESALUMNO NUMBER(2);
  EXISTESOLICITUD  NUMBER(2);
  VREASIGNACION    NUMBER(2);
  VPERIODO       DBAFISICC.CACARRERASVW.PERIODO%TYPE;
BEGIN
  
    --maximo de alumnos aceptados y asignados en el portal
    SELECT NVL(A.MAXALUM,0), NVL(A.NUMALUM,0) 
        INTO VMAXALUM,VNUMALUM 
        FROM DBAFISICC.CAITCCURSOSIMPTB A 
        WHERE A.CORRELATIVO = PCORRELATIVO;
        
    --Valida el numero de alumnos.   
    
    IF ((VMAXALUM > 0) AND (VMAXALUM <= VNUMALUM)) THEN 
       PMENSAJE := 'El cupo del interciclo esta lleno: Maximo: '|| VMAXALUM || 
       ' Asignados: '|| VNUMALUM;
       RETURN 0;
    END IF; 
    
    --Valida direccion y pensum 
    SELECT COUNT(*)
      INTO ESPENSUMNUEVO
      FROM DUAL
      WHERE PPENSUMALUM LIKE '%'||PCARRERA||'%';
    
    --Si es pensum antiguo el pensum del alumno debe ser el pensum del curso. 
    IF ((ESPENSUMNUEVO = 0) AND (PPENSUMALUM != PPENSUMCURSO))  THEN 
       PMENSAJE := 'El curso no se puede asignar por que el alumno tiene pensum 
       menor a 2000 y estos deben ser asignados con curso especifico.';
       RETURN 0;
    END IF; 
    
    --Si es pensum nuevo entonces debe hacer esta conversion de otra forma 
    --Solo debe tomar los cuatro primeros digitos del pensum. 
    IF ESPENSUMNUEVO != 0 THEN 
     
     VCORPENALUM := TO_NUMBER(SUBSTR(PPENSUMALUM,LENGTH(PCARRERA)+1,2)); 
     VCORPENCUR := TO_NUMBER(SUBSTR(PPENSUMCURSO,LENGTH(PCARRERA)+1,2));
      
    ELSE
      VCORPENALUM := TO_NUMBER(SUBSTR(PPENSUMALUM,0,4)); 
      VCORPENCUR := TO_NUMBER(SUBSTR(PPENSUMCURSO,0,4));
    END IF; 
    
    CASE PDIRECCION 
      WHEN -1 THEN 
        IF VCORPENALUM <= VCORPENCUR THEN 
            VALIDAPENSUM := 1;
        ELSE
           VALIDAPENSUM := 0;
        END IF; 
      WHEN 0 THEN 
         IF VCORPENALUM = VCORPENCUR THEN 
            VALIDAPENSUM := 1;
         ELSE 
            VALIDAPENSUM := 0;
        END IF;
      WHEN 1 THEN 
          IF VCORPENALUM >= VCORPENCUR THEN 
            VALIDAPENSUM := 1;
         ELSE 
            VALIDAPENSUM := 0;
        END IF;
      ELSE
PMENSAJE := 'La direccion del curso no es valida, verifique que este correcta.';
        RETURN 0;
    END CASE; 
    
    IF VALIDAPENSUM = 0 THEN 
      PMENSAJE := 'Este interciclo no se imparte para el pensum del alumno.';
      RETURN 0;
    END IF; 
    
    --Valido status del alumno para saber si cargo o no matricula.
    SELECT COUNT(*)
      INTO ESACTIVO
      FROM DBAFISICC.CAALUMCARRSTB
      WHERE CARNET = PCARNET
      AND CARRERA = PCARRERA
      AND STATALUM = 'A';
    
    IF ESACTIVO = 0 THEN 
       --Verifica que no se haya cargado la matricula de interciclo ya.
       SELECT COUNT(*) 
          INTO VCARGOMTI
          FROM DBAFISICC.CCEDOCTATB A
          WHERE A.CARNET = PCARNET 
          AND A.CARRERA = PCARRERA
          AND A.CODMOVTO = 'MTI'
          AND A.CARGO_ABONO = 'C';
          
      SELECT COUNT(*) 
        INTO VCARGOMTHIST
        FROM DBAFISICC.CCHEDOCTATB A
        WHERE A.CARNET = PCARNET 
        AND A.CARRERA = PCARRERA 
        AND A.CODMOVTO = 'MT' 
        AND A.CARGO_ABONO = 'C' 
        AND A.FECHAIMP = ( SELECT MAX(FECHAIMP)
                            FROM DBAFISICC.CACARCICLOSTB B
                            WHERE A.CARRERA = PCARRERA 
                            AND FECHAIMP IS NOT NULL );
      
      IF (VCARGOMTI = 0 AND VCARGOMTHIST = 0) THEN 
         
         SELECT COBROINS 
            INTO VCOBROMT
            FROM DBAFISICC.CACARRERASTB 
            WHERE CARRERA = PCARRERA;
      ELSE 
        VCOBROMT := 0;
      END IF;
     
    END IF; 
    
    
    SELECT COUNT(*)
      INTO VASIGNACIONANTERIOR
      FROM DBAFISICC.CAASIGNACIONESTB A
      WHERE A.CARNET = PCARNET 
      AND A.CARRERA = PCARRERA 
      AND A.CURSO = PCURSO
      AND A.TIPOASIG = 'ITC' 
      AND A.SECCION = PSECCION 
      AND A.CODSTATUS IN ('S1','S4');
    
    IF VASIGNACIONANTERIOR != 0 THEN 
       PMENSAJE := 'El interciclo ya fue asignado anteriormente';
       RETURN 0;
    END IF; 
    
    SELECT COUNT(*) 
        INTO VASIGNACIONESALUMNO  
        FROM DBAFISICC.CAASIGNACIONESTB 
        WHERE CARNET = PCARNET 
        AND   CARRERA = PCARRERA
        AND   TIPOASIG = 'ITC' 
        AND   CODSTATUS IN ('S1','S4');
   
    IF ((VASIGNACIONESALUMNO >= 2) OR (VMAXALUM = 0)) THEN 
       IF (NVL(PSOLICITUD,0) = 0) THEN 
          PMENSAJE := 'Ingrese solicitud de Trámite para un Tercer Curso o 
                       para Cursos con Excepción ';
          RETURN 0;
       ELSE 
          SELECT COUNT(*)
            INTO EXISTESOLICITUD
            FROM DBAFISICC.SOSOLTRAMITETB A
            WHERE A.CARNET = PCARNET
            AND A.CARRERA = PCARRERA 
            AND A.SOLICITUD = PSOLICITUD
            AND A.TRAMITE = 32
            AND A.STATUS='A'
            AND NVL(A.OPERADO,0) <>1;
            
          IF EXISTESOLICITUD = 0 THEN 
             PMENSAJE := 'El numero de Solicitud Ingresado no es Valido o ya 
                          fue Operado, Verifique';
             RETURN 0;
          END IF;
          
          SELECT COUNT(*)
            INTO VREASIGNACION
            FROM DBAFISICC.CAASIGNACIONESTB 
            WHERE CARNET = PCARNET 
            AND CARRERA = PCARRERA 
            AND CURSO = PCURSO 
            AND TIPOASIG = 'ITC' 
            AND SECCION = PSECCION 
            AND CODSTATUS IN ('S3','S5');
          
          
          IF VREASIGNACION != 0 THEN 
             UPDATE DBAFISICC.CAASIGNACIONESTB
                SET CODSTATUS='S4',
                    FECHAASIG = SYSDATE, 
                    HOJACAMBIO = PSOLICITUD
                WHERE CARNET = PCARNET
                AND CURSO = PCURSO
                AND CARRERA = PCARRERA
                AND SECCION = PSECCION
                AND TIPOASIG = 'ITC';
          ELSE 
             INSERT INTO DBAFISICC.CAASIGNACIONESTB (CARNET, CURSO, CARRERA, 
                        SECCION, TIPOASIG, CODSTATUS, FECHAASIG, HOJACAMBIO,
                        PERIODO) 
                    VALUES (PCARNET,PCURSO,PCARRERA,PSECCION,'ITC','S1',SYSDATE,
                            PSOLICITUD, PPERIODO);
                                
          END IF ; 
          --Realiza cargo 
          INSERT INTO DBAFISICC.CCEDOCTATB (PENSUM,CARRERA,CARNET,OPERACION,
                      NUMCTA,CODMOVTO,FECHA,MONTO,CARGO_ABONO,CURSO,
                      OBSERVACIONES,CORRELATIVO, PERIODO)
                VALUES (TO_CHAR(SYSDATE,'yyyy'),PCARRERA, PCARNET,PSOLICITUD,
                       PPERIODO,'ITC',SYSDATE,PCARGO,'C',
                        PCURSO,PUSUARIO||' '||TRUNC(SYSDATE) ,
                        (SELECT NVL(MAX(CORRELATIVO) + 1,1) 
                            FROM DBAFISICC.CCEDOCTATB 
                            WHERE CARNET = PCARNET 
                            AND CARRERA = PCARRERA), PPERIODO);
          
          IF VCOBROMT != 0 THEN
             INSERT INTO DBAFISICC.CCEDOCTATB(PENSUM,CARRERA,CARNET,CORRELATIVO,
                         NUMCTA,CODMOVTO,FECHA,MONTO,CARGO_ABONO,OBSERVACIONES,
                         OPERACION,FRACCION,INI_FRAC, PERIODO)
                   VALUES (TO_CHAR(SYSDATE,'yyyy') ,PCARRERA,PCARNET, 
                          (SELECT NVL(MAX(CORRELATIVO)+1,1) 
                              FROM DBAFISICC.CCEDOCTATB 
                              WHERE CARRERA = PCARRERA 
                              AND CARNET = PCARNET),
                          PPERIODO,'MTI',SYSDATE,VCOBROMT,
                             'C',PUSUARIO ||' '|| SYSDATE,PSOLICITUD,
                             NULL,NULL, PPERIODO);
          END IF; 
          
          -- Actualizo el numero de alumnos asignados. 
          UPDATE DBAFISICC.CAITCCURSOSIMPTB 
            SET NUMALUM = VNUMALUM+1
            WHERE CORRELATIVO = PCORRELATIVO;
            
          UPDATE SOSOLTRAMITETB 
            SET OPERADO=1 
            WHERE SOLICITUD= PSOLICITUD;
       END IF; 
    ELSIF ((VASIGNACIONESALUMNO < 2) AND (VMAXALUM > 0)) THEN 
        
        SELECT COUNT(*) 
          INTO VREASIGNACION
          FROM DBAFISICC.CAASIGNACIONESTB A
          WHERE A.CARNET = PCARNET 
          AND A.CARRERA =  PCARRERA 
          AND A.CURSO = PCURSO
          AND A.TIPOASIG = 'ITC' 
          AND A.SECCION = PSECCION 
          AND A.CODSTATUS IN ('S3','S5');
        
        IF VREASIGNACION != 0 THEN 
             UPDATE DBAFISICC.CAASIGNACIONESTB
                SET CODSTATUS='S4',
                    FECHAASIG = SYSDATE
                WHERE CARNET = PCARNET
                AND CURSO = PCURSO
                AND CARRERA = PCARRERA
                AND SECCION = PSECCION
                AND TIPOASIG = 'ITC';
        ELSE 
             INSERT INTO DBAFISICC.CAASIGNACIONESTB (CARNET, CURSO, CARRERA, 
                        SECCION, TIPOASIG, CODSTATUS, FECHAASIG, PERIODO) 
                  VALUES (PCARNET,PCURSO,PCARRERA,PSECCION,'ITC','S1',
                          SYSDATE, PPERIODO);
                                
        END IF ; 
        
        --Realiza cargo 
        INSERT INTO DBAFISICC.CCEDOCTATB (PENSUM,CARRERA,CARNET,NUMCTA,CODMOVTO,
                      FECHA,MONTO,CARGO_ABONO,CURSO,OBSERVACIONES,CORRELATIVO,
                      PERIODO)
                VALUES (TO_CHAR(SYSDATE,'yyyy'),PCARRERA, PCARNET,
                        PPERIODO,'ITC',SYSDATE,PCARGO,'C',
                        PCURSO,PUSUARIO||' '||TRUNC(SYSDATE) ,
                        (SELECT NVL(MAX(CORRELATIVO) + 1,1) 
                            FROM DBAFISICC.CCEDOCTATB 
                            WHERE CARNET = PCARNET 
                            AND CARRERA = PCARRERA), PPERIODO);
          
          -- Actualizo el numero de alumnos asignados. 
          UPDATE DBAFISICC.CAITCCURSOSIMPTB 
            SET NUMALUM = VNUMALUM+1
            WHERE CORRELATIVO = PCORRELATIVO;
           
          IF VCOBROMT != 0 THEN
             INSERT INTO DBAFISICC.CCEDOCTATB(PENSUM,CARRERA,CARNET,CORRELATIVO,
                         NUMCTA,CODMOVTO,FECHA,MONTO,CARGO_ABONO,OBSERVACIONES,
                         PERIODO)
                   VALUES (TO_CHAR(SYSDATE,'yyyy') ,PCARRERA,PCARNET, 
                          (SELECT NVL(MAX(CORRELATIVO)+1,1) 
                              FROM DBAFISICC.CCEDOCTATB 
                              WHERE CARRERA = PCARRERA 
                              AND CARNET = PCARNET),
                          PPERIODO,'MTI',SYSDATE,VCOBROMT,
                             'C',PUSUARIO ||' '|| SYSDATE, PPERIODO);
          END IF; 
          
    END IF;
    RETURN 1;
    
END ASIGNACION_ITC;
