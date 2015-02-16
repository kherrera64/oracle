 /* 
   Autor: Kevin Herrera
   Fecha: 15/11/2014
   Modificacion: Se valida el ingreso a la asignacion de interciclo.
 */

FUNCTION VALIDAINTERCICLO (

  PCARNET   DBAFISICC.CAINSCRITOSTB.CARNET%TYPE DEFAULT NULL,
  PCARRERA  DBAFISICC.CAINSCRITOSTB.CARRERA%TYPE DEFAULT NULL,
  PUSUARIO  DBAFISICC.CAUSUARIOSCARRERASTB.USUARIO%TYPE DEFAULT NULL,
  PMENSAJE  OUT VARCHAR2
) RETURN NUMBER IS
   
    VCARRERA  DBAFISICC.CACARGOSXCARRERATB.CARRERA%TYPE DEFAULT NULL;
    VINSCRITO DBAFISICC.CAINSCRITOSTB.INSCRITO%TYPE DEFAULT NULL;
    VSALDO    DBAFISICC.CCEDOCTATB.MONTO%TYPE DEFAULT NULL;
    VCA       DBAFISICC.CAUSUARIOSCARRERASTB.CONTROLACADEMICO%TYPE DEFAULT NULL;
    VSECRETARIA DBAFISICC.CAUSUARIOSCARRERASTB.SECRETARIA%TYPE DEFAULT NULL;

   BEGIN  
    
     BEGIN 
     
     SELECT NVL(CONTROLACADEMICO,0) INTO VCA           
        FROM DBAFISICC.CAUSUARIOSCARRERASTB 
        WHERE USUARIO = PUSUARIO 
        AND CARRERA = PCARRERA; 
        
       EXCEPTION WHEN NO_DATA_FOUND THEN
          VCA := 0;   
      END;
     
      BEGIN      
      
      SELECT NVL(SECRETARIA,0) INTO VSECRETARIA            
        FROM DBAFISICC.CAUSUARIOSCARRERASTB 
        WHERE USUARIO = PUSUARIO 
        AND CARRERA = PCARRERA;  
        
       EXCEPTION WHEN NO_DATA_FOUND THEN
          VSECRETARIA := 0;   
      END;
     
     IF (VCA != 1 AND VSECRETARIA != 1)  THEN 
         PMENSAJE := 'No tiene Permisos para ver esta pantalla';
         RETURN 1;
     END IF; 
    
      --Validar Que la carrera permita interciclo 
    
     BEGIN 
     
     SELECT CARRERA INTO VCARRERA
         FROM DBAFISICC.CACARGOSXCARRERATB 
         WHERE CODMOVTO = 'ITC' 
         AND STATUS ='A' 
         AND CARRERA = PCARRERA;
     
      EXCEPTION WHEN NO_DATA_FOUND THEN
          VCARRERA := NULL;   
      END;  
       
     IF (VCARRERA IS NULL)  THEN 
         PMENSAJE := 'La Carrera no tiene Autorizado el Cargo Interciclo (ITC)';
         RETURN 1;
     END IF; 
       
        VINSCRITO := NULL;   
       
     --Valida NO INSCRITO
     BEGIN 
     
     SELECT 1 into VINSCRITO
       FROM DBAFISICC.CAALUMCARRSTB 
       WHERE CARNET = PCARNET
       AND CARRERA = PCARRERA
       and statalum in('I', 'A');
     
     EXCEPTION WHEN NO_DATA_FOUND THEN
          VINSCRITO := null;   
      END;
      
     IF (VINSCRITO is null)  THEN 
         PMENSAJE := 'Solo Alumnos NO INSCRITOS se pueden asignar Interciclo';
         RETURN 1;
     END IF; 
     
       --Validar Saldo para asignar interciclo
     
       
      SELECT C.MONTO_C - A.MONTO_A INTO VSALDO 
         FROM (SELECT NVL(SUM(MONTO),0)  MONTO_C 
                 FROM DBAFISICC.CCEDOCTATB 
                 WHERE CARNET = PCARNET
                 AND CODMOVTO NOT IN ('ITC','MTI') 
                 AND CARGO_ABONO = 'C') C, (SELECT NVL(SUM(MONTO),0) MONTO_A 
                                              FROM DBAFISICC.CCEDOCTATB 
                                              WHERE CARNET = PCARNET
                                              AND CODMOVTO NOT IN ('ITC','MTI') 
                                              AND CARGO_ABONO = 'A') A;
      
     IF (VSALDO IS NULL)  THEN 
         PMENSAJE := 'No se puede asignar Interciclo si tiene Saldo Pendiente';
         RETURN 1;
     END IF;                                      
     
     PMENSAJE := NULL;                                         
     RETURN 0;                                         
       
  END VALIDAINTERCICLO;