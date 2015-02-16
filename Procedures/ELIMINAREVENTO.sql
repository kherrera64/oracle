/* 
Autor:        Kevin Herrera
Fecha:        28/08/2014
Descripcion:  Elimina el evento de Temporal y Produccion.
*/ 
PROCEDURE ELIMINAREVENTO 
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
          
        
        DELETE DBAFISICC.CAHORARIOSTMP 
        WHERE HORARIO = VHORARIO;  
        
        DELETE DBAFISICC.CAMAINHORARIOSTMP
        WHERE HORARIO = VHORARIO;
        
        DELETE DBAFISICC.CAHORARIOSTB
        WHERE HORARIO = VHORARIO;
        
        DELETE DBAFISICC.CAMAINHORARIOSTB
        WHERE HORARIO = VHORARIO;
              
        VCONTEO:= VCONTEO - 1;
        i:= i + 1;    
            
      
    END LOOP;     
    
    
       PSQLCODE := SQLCODE;  
            
            EXCEPTION  
              WHEN OTHERS  THEN  
                  PSQLCODE := SQLCODE;
     
END ELIMINAREVENTO;