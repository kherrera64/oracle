/*AUTOR: KEVIN HERRERA
  FECHA: 16/01/2014
  DESCRIPCION: PROCEDIMIENTO QUE DEVUELVE LOS DOCENTES ACTIVOS,
  ESTOS PUEDEN SER FILTRADOS POR CARRERA Y PUESTO*/

CREATE OR REPLACE PROCEDURE DOCENTES
  (
    PCARRERA IN DBAFISICC.CACARRERASTB.CARRERA%TYPE,
    PPUESTO IN DBAFISICC.RHDOCENTESTB.CODPUESTO%TYPE,
    RETVAL    OUT sys_refcursor
  ) AS 
  BEGIN
    OPEN RETVAL FOR

SELECT DISTINCT 
A.CODPERS, A.APELLIDO1, A.APELLIDO2, A.NOMBRE1, A.NOMBRE2, 
A.APELLIDO1 || ' ' || A.APELLIDO2 || ' ' || A.DECASADA || ', ' || 
A.NOMBRE1||' '||A.NOMBRE2 AS NOMBRE,B.CODPUESTO,G.DESPUESTO
     
 FROM DBAFISICC.NOPERSONALTB A, DBAFISICC.RHDOCENTESTB B,
 DBAFISICC.CACURSHORATB E, DBAFISICC.CACARRERASTB F, DBAFISICC.NOPUESTOSTB G
 
        WHERE A.CODPERS = B.CODPERS
        AND B.HORARIO = E.HORARIO
        AND E.CARRERA = F.CARRERA
        AND B.CODPUESTO = G.CODPUESTO
        AND (F.CARRERA = PCARRERA  OR PCARRERA IS NULL)     
        AND (B.CODPUESTO = PPUESTO OR PPUESTO IS NULL)
        ORDER BY NOMBRE;
        
END DOCENTES;    