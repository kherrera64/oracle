/* 
Autor:        Kevin Herrera
Fecha:        28/08/2014
Descripcion:  Traslada el evento a produccion.
*/ 
PROCEDURE TRASLADAREVENTO 
( 
   PSOLICITUD    IN DBAFISICC.SOSOLTRAMITETB.SOLICITUD%TYPE,
   PCOMENTARIO   IN DBAFISICC.SOSOLTRAMITETB.COMENTARIOS%TYPE,
   PUSUARIO      IN DBAFISICC.SOSOLTRAMITETB.USUARIO%TYPE,
   PSQLCODE     OUT NUMBER
) 
AS 
   
   --datos a recuperar de la tabla sosolinfotramitetb
   
   VHORARIO      DBAFISICC.CAHORARIOSTMP.HORARIO%TYPE;
   VCONTEO       NUMBER;
   i             number;
 BEGIN 
    
    SELECT COUNT(CAMPOC)
    into VCONTEO
         FROM SOSOLINFOTRAMITETB
    WHERE SOLICITUD = PSOLICITUD;
    
    i:=1;
    
    WHILE VCONTEO > 0
    LOOP
    
    
       SELECT CAMPOC
       INTO VHORARIO
          FROM SOSOLINFOTRAMITETB
          WHERE SOLICITUD = PSOLICITUD
          AND CODINFO = I;
        
        
        INSERT INTO DBAFISICC.CAMAINHORARIOSTB(HORARIO, DESCRIPCION, FECHAINI, 
        FECHAFIN, STATUS, CARHORA, COLOR, GES_PK, COMENTARIOS)
        
        SELECT A.HORARIO, A.DESCRIPCION, A.FECHAINI, A.FECHAFIN, A.STATUS, 
        A.CARHORA, A.COLOR, A.GES_PK, A.COMENTARIOS
        
                FROM DBAFISICC.CAMAINHORARIOSTMP A
                WHERE A.HORARIO = VHORARIO;
          
       
        INSERT INTO DBAFISICC.CAHORARIOSTB(HORARIO, DIA, HORAINI, HORAFIN, 
        SALON, TORRE, CORRELATIVO, CODPERS)
        
        SELECT A.HORARIO, A.DIA, A.HORAINI, A.HORAFIN, A.SALON, A.TORRE,
        A.CORRELATIVO, A.CODPERS 
                
                FROM DBAFISICC.CAHORARIOSTMP A
                WHERE A.HORARIO = VHORARIO;
                
        VCONTEO:= VCONTEO - 1;
        i:= i + 1;    
            
      
    END LOOP;     
    
    
       PSQLCODE := SQLCODE;  
            
            EXCEPTION  
              WHEN OTHERS  THEN  
                  PSQLCODE := SQLCODE;
     
END TRASLADAREVENTO;