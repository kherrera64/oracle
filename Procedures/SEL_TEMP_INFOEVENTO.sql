 PROCEDURE SEL_TEMP_INFOEVENTO  
 (
   PUSUARIO  DBAFISICC.AUDRHALUMASISTEUSRTB.USUARIO%TYPE DEFAULT NULL,
   RETVAL    OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 
  
            SELECT TORRE, NIVEL, SALON, TO_CHAR(FECHA, 'dd/MM/yyyy') FECHA, 
            INICIO, FIN
       
         FROM TEMP_INFOEVENTO
        WHERE USUARIO = PUSUARIO
       ORDER BY FECHA ASC, TORRE, NIVEL, SALON, INICIO;

END SEL_TEMP_INFOEVENTO; 