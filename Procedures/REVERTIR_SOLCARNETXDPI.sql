/*
Nombre:       REVERTIR_SOLCARNETXDPI
Autor:        Kevin Herrera
Fecha:        02/06/2014
Package:      PKG_SOLICITUDES_SP 
Descripcion:  Se ejecuta en el trámite de Solicitud de carnet por DPI si 
              seleccionan revertir cuando el carnet tiene problemas. 
*/ 

PROCEDURE  REVERTIR_SOLCARNETXDPI 
( 
   PSOLICITUD    IN DBAFISICC.SOSOLTRAMITETB.SOLICITUD%TYPE,
   PCOMENTARIO   IN DBAFISICC.SOSOLTRAMITETB.COMENTARIOS%TYPE,
   PUSUARIO      IN DBAFISICC.SOSOLTRAMITETB.USUARIO%TYPE,
   PSQLCODE     OUT NUMBER 
) 
AS 
   --datos a recuperar de la tabla sosolinfotramitetb
   VCARNET      DBAFISICC.CAALUMNOSTB.CARNET%TYPE;

BEGIN 

     --TRAER LA CARNET DEL ALUMNO
     SELECT A.CARNET 
        INTO VCARNET
        FROM DBAFISICC.SOSOLTRAMITETB A
        WHERE A.SOLICITUD=PSOLICITUD;
    
     
     --Si ocurrio un error se actualiza FECHA_HORA a null en CACARNETBITB
      
      UPDATE DBAFISICC.CACARNETBITB A
         SET FECHA_HORA = NULL
          WHERE A.CARNET = VCARNET;
          
          PSQLCODE := SQLCODE;

EXCEPTION 
  WHEN OTHERS THEN 
    PSQLCODE:= SQLCODE; 
  
END REVERTIR_SOLCARNETXDPI;