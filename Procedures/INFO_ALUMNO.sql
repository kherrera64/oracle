/*
Autor: Jorge Velasquez
Fecha: 11/02/2013
Descripcion: Devuelve la informacion de contacto del alumno especifico.

Autor: Kevin Herrera
Fecha: 26/06/2014
Descripcion: Ahora se utilizara el campo EMAIL de la tabla CAALUMNOSTB.
*/
   PROCEDURE INFO_ALUMNO
 (
   PCARNET  IN DBAFISICC.CADIRECCIOSTB.CARNET%TYPE,
   RETVAL   OUT SYS_REFCURSOR
 ) 
   AS BEGIN
   OPEN RETVAL FOR 
  
      SELECT A.PAIS, A.DEPTO, A.MUNICIP, NVL(A.DIRECCION,'') DIRECCION,
      NVL(A.TELEFONO,'') TELEFONO, NVL(A.ZONA,'') ZONA, 
      NVL(A.COLONIA,'') COLONIA, NVL(A.CELULAR,'') CELULAR, NVL(A.APTO,'') APTO, 
      NVL(A.CASA,'') CASA, NVL(B.EMAIL,'') EMAIL, 
      ROUND(MONTHS_BETWEEN(SYSDATE, B.FECHANAC)/12, 2) EDAD
         
         FROM DBAFISICC.CADIRECCIOSTB A, DBAFISICC.CAALUMNOSTB B
         WHERE A.TIPODIRECCION(+) = 'C'
         AND A.CARNET(+) = B.CARNET
         AND B.CARNET = PCARNET;
 
 END INFO_ALUMNO;