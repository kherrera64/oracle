/*
  Nombre:       REP_CIERREPENSUMXCARRERA.
  Autor:        Jorge Velásquez
  Fecha:        01/10/2012
  Package:      PKG_REPORTES
  Descripción:  Devuelve los datos de todos los alumnos con pensum
                cerrado en determinada carrera.
                El procedimiento es utilizado por cierrepensum.rdl.
  Modificación: jvelasquez - 15/10/2012: se optimizó el SP y se utilizan nombres
  estandares para carrera y alumno.
  
  AALVARADO - 28/01/2014 - Se cambio el parametro de carrera a una o varias
  AALVARADO - 11/03/2014 - Se cambio el procedimiento para que pueda tomar las
                           subcarreras. 
  AALVARADO - 26/03/2014 - Se cambia para que solo valide los cursos de la 
                           licenciatura
  AALVARADO - 28/03/2014 - Se cambio el nombre del status. 
  KHERRERA - 05/06/2014 - se modificó el tipo del parametro PCARRERA de 
                          varchar2 a clob debido a que el varchar2 era limitado 
                          al momento de enviar todas las carreras activas he 
                          inactivas.
*/

 PROCEDURE REP_CIERREPENSUMXCARRERA
 (
    RETVAL OUT SYS_REFCURSOR,
    PCARRERA IN CLOB DEFAULT NULL
 )
 AS 
  begin
  OPEN RETVAL FOR
  
        SELECT DBAFISICC.PKG_ALUMNO.NOMBRE(B.CARNET, 1) NOMBRES, B.PENSUM,
        B.CARRERA, B.CARNET, B.STATALUM, SUM(NVL(E.UMAS,0)) CREDITOS, 
        DBAFISICC.PKG_ALUMNO.EMAIL(B.CARNET) EMAIL,  
        DBAFISICC.PKG_ALUMNO.TELEFONOS(B.CARNET) TELEFONO, H.NOMBRE STATNOMBRE 
          
           FROM (SELECT A.CARNET, A.PENSUM, A.STATALUM, A.CARRERA
                    
                  FROM DBAFISICC.CAALUMCARRSTB A
                  WHERE A.CARRERA IN(SELECT * 
                                        FROM TABLE(SPLIT_VARCHAR(PCARRERA,',')))
                                        AND INSCRITO=0
                                        AND STATALUM <> 'G') B, 
           DBAFISICC.CAALUMNOSNOTASTB C, DBAFISICC.CACATPENSATB E, 
           DBAFISICC.GNSTATALUMSTB H
           WHERE B.STATALUM = H.STATALUM
           AND B.CARNET = C.CARNET
           AND C.CARRERA IN (SELECT D.CODIGO
                                FROM DBAFISICC.CASUBCARRERASTB D
                                WHERE D.CARRERA = B.CARRERA
                                AND D.STATUS = 'A'
                             
                             UNION SELECT B.CARRERA
                                          FROM DUAL)
          and e.pensum = b.pensum (+)
          AND E.CARRERA = B.CARRERA(+)
          AND E.CURSO = C.CURSO(+)
          AND C.CODSTATUS = 'S6'
        
        GROUP BY B.PENSUM,B.CARRERA, B.CARNET, B.STATALUM, H.NOMBRE
        
        HAVING SUM(E.UMAS) >= (SELECT SUM(G.UMAS)
                                FROM DBAFISICC.CACATPENSATB G
                                WHERE G.CARRERA IN(SELECT D.CODIGO
                                                    FROM 
                                                    DBAFISICC.CASUBCARRERASTB D
                                                    WHERE D.CARRERA = B.CARRERA
                                                    and d.status = 'A'
                                        
                                                    UNION SELECT B.CARRERA
                                                                  FROM DUAL)
                                                    AND G.PENSUM = B.PENSUM
                                                    AND (G.HISTORIAL=1 OR 
                                                    G.HISTORIAL IS NULL));
 END REP_CIERREPENSUMXCARRERA;