 /*
autor: Kevin Herrera
FECHA: 02/04/2014
Descripcion: Procedimiento que devuelve los datos de CATORRESTB.

Modificacion: Autor: Kevin Herrera 
Fecha: 03/04/2014
Descripcion: A la tabla CATORRESTB fue agregado el campo DIRECCION por lo que 
             se agrega al select.
             
Modificacion: Autor: Kevin Herrera 
Fecha: 04/04/2014
Descripcion: A la tabla CATORRESTB fue agregado el campos PAIS, DEPTO y
             MUNICIP por lo que se agregaron al procedimiento.             
              
*/

 PROCEDURE TORRES  
 (
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  open RETVAL for 
  
    SELECT A.CODIGOTORRE, A.NOMBRETORRE, A.DIRECCION, A.PAIS, A.DEPTO, 
           A.MUNICIP, B.NOMBRE NOMBREPAIS, C.NOMBRE NOMBREDEPTO,
           d.NOMBRE NOMBREMUNICIP
               
             FROM DBAFISICC.CATORRESTB A, DBAFISICC.GNPAISESTB B,
                  DBAFISICC.GNDEPTOSTB C, DBAFISICC.GNMUNICIPSTB D
             WHERE A.PAIS = B.PAIS(+)
             AND   A.PAIS = C.PAIS(+)
             AND   A.DEPTO = C.DEPTO(+)
             AND   A.PAIS = D.PAIS(+)
             AND   A.DEPTO = D.DEPTO(+)
             AND   A.MUNICIP = D.MUNICIP(+)
          
    ORDER BY a.NOMBRETORRE;
 END TORRES;
    