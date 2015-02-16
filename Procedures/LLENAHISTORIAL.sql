 /*
     esanabria 30/06/2014 solo se modifico porque daba error ya que necesita
               centro en el insert a cchedoctadetalletb.
     esanabria 27/08/2014 se inserta ahora tirmestre ya que es llave en
               cchedoctadetalletb
     esanabria 28//10/2014 se corrigio la comparacion del trimestre con numcta
     
     Modificacion: KHERRERA - 19/12/2014 - Se filtra por carrera_sede y si no
                se encuentran por carrera.
   */
   FUNCTION LLENAHISTORIAL(PCARNET      CAALUMCARRSTB.CARNET%TYPE, 
                           PCARRERA     CAALUMCARRSTB.CARRERA%TYPE DEFAULT NULL, 
                           PCENTRO      CCHEDOCTATB.CENTRO%TYPE DEFAULT NULL,
                           PFECHAIMP    DATE) 
       RETURN NUMBER IS                         
       

      CURSOR DETALLE IS SELECT *  
         FROM CCHEDOCTATB 
         WHERE CARNET = PCARNET  
         AND  (CARRERA = PCARRERA OR PCARRERA IS NULL) 
         AND  (NVL(CENTRO, CARRERA) = PCENTRO OR PCENTRO IS NULL)
         AND   NVL(FECHAIMP,SYSDATE) = PFECHAIMP 
         ORDER BY FECHA; 
           
      B                              DETALLE%ROWTYPE; 
      VMOVIMIENTO                    CCHEDOCTADETALLETB.CODMOVTO%TYPE; 
      VCUOTA                         CCHEDOCTADETALLETB.CUOTA%TYPE; 
      VFR                            CCHEDOCTADETALLETB.FR%TYPE; 
      VINIFRAC                       CCHEDOCTADETALLETB.INIFRAC%TYPE; 
      VCARGOS                        CCHEDOCTADETALLETB.CARGOS%TYPE; 
      VPAGOS                         CCHEDOCTADETALLETB.PAGOS%TYPE; 
      VABONOS                        CCHEDOCTADETALLETB.ABONOS%TYPE; 
      VMORA                          CCHEDOCTADETALLETB.MORA%TYPE; 
      VADELANTO                      CCHEDOCTADETALLETB.ADELANTO%TYPE; 
      VCURSNAME                      CCHEDOCTADETALLETB.CURSO%TYPE; 
      VOBLIGATORIO                   CCHEDOCTADETALLETB.OBLIGATORIO%TYPE; 
       
      VCODMOVTO                      CCTIPOMOVTOTB.CODMOVTO%TYPE; 
      VCURSO                         CACURSOSTB.CURSO%TYPE; 
       
      INSCRITO                       NUMBER(1); 
      ERECIBO                        NUMBER(1); 
      ENCONTRE                       BOOLEAN; 
      I  NUMBER := 0; 
 
   BEGIN 
          /********                                                  *******/ 
          /********  Historial Estado de Cuenta corriente del alumno *******/ 
         /********                                                  *******/ 
 
 
 
      SELECT COUNT(*) INTO INSCRITO 
         FROM CAHINSCRITOSTB 
         WHERE CARNET = PCARNET 
         AND  (CARRERA = PCARRERA OR PCARRERA IS NULL) 
         AND (NVL(CARRERA_SEDE, CARRERA) = PCENTRO OR PCENTRO IS NULL)
         AND FECHAINSCRITO = PFECHAIMP; 
 
 
      IF INSCRITO = 0 
      THEN RETURN(1); 
      END IF; 
      DELETE FROM CCHEDOCTADETALLETB 
         WHERE CARNET = PCARNET 
         AND (CARRERA = PCARRERA OR PCARRERA IS NULL)
         AND (NVL(CENTRO, CARRERA) = PCENTRO OR PCENTRO IS NULL); 
      OPEN DETALLE; 
      LOOP 
      	 VCARGOS := 0; 
      	 VPAGOS := 0; 
      	 VABONOS := 0; 
      	 ERECIBO := 0; 
      	 VCURSNAME := NULL; 
         FETCH DETALLE INTO B; 
         EXIT WHEN DETALLE%NOTFOUND; 
         IF B.CODMOVTO IN ('AS','VI','CR','BC','RT','DT') 
         THEN 
            VCODMOVTO := 'CT'; 
            VCURSO := NULL; 
         ELSIF B.CODMOVTO IN ('MTB') 
         THEN 
            VCODMOVTO := 'MT'; 
            VCURSO := NULL; 
         ELSIF B.CODMOVTO IN ('MU') 
         THEN 
            VCODMOVTO := 'MU'; 
            VCURSO := NULL; 
         ELSE 
            VCODMOVTO := B.CODMOVTO;   
            VCURSO := B.CURSO;       
         END IF; 
         SELECT MOVIMIENTO,OBLIGATORIO INTO VMOVIMIENTO,VOBLIGATORIO
            FROM CCTIPOMOVTOTB 
            WHERE CODMOVTO = VCODMOVTO; 
         IF VCURSO IS NOT NULL 
         THEN 
            SELECT NOMBRE INTO VCURSNAME 
               FROM CACURSOSTB 
               WHERE CURSO = VCURSO; 
         END IF; 
         IF B.CARGO_ABONO = 'C' 
         THEN 
            VCARGOS := B.MONTO; 
            VABONOS := 0; 
            VPAGOS := 0; 
         ELSE 
         	 IF B.OPERACION IS NOT NULL 
         	 THEN 
         	    SELECT COUNT(RECIBO) INTO ERECIBO 
         	       FROM CCRECIBOSTB 
         	       WHERE RECIBO = B.OPERACION; 
         	    IF ERECIBO > 0 
         	    THEN 
         	       VPAGOS := B.MONTO; 
                 VCARGOS := 0; 
                 VABONOS := 0; 
         	    ELSE  
         	    	 VABONOS := B.MONTO; 
                 VCARGOS := 0; 
                 VPAGOS := 0; 
         	    END IF; 
         	 ELSE 
         	    VABONOS := B.MONTO; 
              VCARGOS := 0; 
              VPAGOS := 0; 
         	 END IF; 
         END IF; 
         BEGIN 
         
      
          INSERT INTO CCHEDOCTADETALLETB(CARNET,CARRERA,CODMOVTO,CUOTA,FR,
                            INIFRAC,CARGOS,PAGOS,ABONOS,
                            MORA,ADELANTO,CURSO,FECHAIMP,
                            TIPOCUENTA,CONCEPTO,CODCURSO,OBLIGATORIO,CENTRO,
                            TRIMESTRE)
            VALUES(PCARNET,B.CARRERA,VMOVIMIENTO,VCUOTA,VFR,VINIFRAC,
                      NVL(VCARGOS,0),NVL(VPAGOS,0),NVL(VABONOS,0), 
                      VMORA,VADELANTO,NVL(VCURSNAME,' '),PFECHAIMP,NULL,
                      VCODMOVTO,VCURSO,VOBLIGATORIO,NVL(B.CENTRO,B.CARRERA),
                      TO_CHAR(B.FECHAIMP,'YYYYmm')); 
                             
         EXCEPTION 
         WHEN DUP_VAL_ON_INDEX 
         THEN 
         	  UPDATE CCHEDOCTADETALLETB 
         	     SET CARGOS = NVL(CARGOS,0) + NVL(VCARGOS,0),  
         	         PAGOS  = NVL(PAGOS,0)  + NVL(VPAGOS,0), 
         	         ABONOS = NVL(ABONOS,0) + NVL(VABONOS,0) 
         	     WHERE CARNET = PCARNET 
               AND  (CARRERA = PCARRERA OR PCARRERA IS NULL) 
               AND (NVL(CENTRO,CARRERA)= PCENTRO OR PCENTRO IS NULL)
               AND TRIMESTRE=TO_CHAR(B.FECHAIMP,'YYYYmm')
         	     AND CODMOVTO = VMOVIMIENTO 
         	     AND CURSO = NVL(VCURSNAME,' '); 
         END; 
      END LOOP;    
      CLOSE DETALLE;   
      STANDARD.COMMIT; 	   
      RETURN(0); 
   END;