/*
autor: Kevin Herrera
FECHA: 02/04/2014
Descripcion: Procedimiento que inserta y elimina y actualiza las torres
             en la tabla CATORRESTB.
             
Modificacion: Autor: Kevin Herrera 
Fecha: 03/04/2014
Descripcion: A la tabla CATORRESTB fue agregado el campo DIRECCION el parametro
             PDIRECCION y tambien se agrega a las distintas acciones.

Modificacion: Autor: Kevin Herrera 
Fecha: 04/04/2014
Descripcion: A la tabla CATORRESTB fue agregado el campos PAIS, DEPTO y
             MUNICIP por lo que se agregaron a las distintas acciones.   
*/

 PROCEDURE TR_TORRES  
  (    
    PCODIGO DBAFISICC.CATORRESTB.CODIGOTORRE%TYPE DEFAULT NULL,
    PNOMBRE DBAFISICC.CATORRESTB.NOMBRETORRE%TYPE DEFAULT NULL,
    PDIRECCION DBAFISICC.CATORRESTB.DIRECCION%TYPE DEFAULT NULL,
    PPAIS DBAFISICC.CATORRESTB.PAIS%TYPE DEFAULT NULL,
    PDEPTO DBAFISICC.CATORRESTB.DEPTO%TYPE DEFAULT NULL,
    PMUNICIP DBAFISICC.CATORRESTB.MUNICIP%type default null,
    PACCION varchar2
  ) 
  is
  BEGIN 
  
  IF PACCION = 'I' THEN
  
    INSERT INTO DBAFISICC.CATORRESTB(CODIGOTORRE, NOMBRETORRE, DIRECCION, 
                                    PAIS, DEPTO, MUNICIP)
  
    VALUES(PCODIGO, PNOMBRE, PDIRECCION, PPAIS, PDEPTO, PMUNICIP);
   
  ELSIF PACCION = 'U' THEN
  
    UPDATE DBAFISICC.CATORRESTB 
    SET CODIGOTORRE = PCODIGO, NOMBRETORRE = PNOMBRE, DIRECCION = PDIRECCION,
       PAIS = PPAIS, DEPTO = PDEPTO, MUNICIP = PMUNICIP 
    WHERE CODIGOTORRE = PCODIGO; 
  
  ELSIF PACCION = 'D' THEN
   
    DELETE FROM DBAFISICC.CATORRESTB 
    WHERE CODIGOTORRE = PCODIGO;
    
  END IF;

END TR_TORRES;