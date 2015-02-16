/*
  Nombre:       REPAPROBACIONNOMINAIDEA
  Autor:        Kevin Herrera
  Fecha:        06/10/2014
  Package:      PKG_REPORTES
  Descripcion:  Devuelve la descripcion de nomina tipo contraro para IDEA.
*/

PROCEDURE REPAPROBACIONNOMINAIDEA
  (
    PFECHAINI  IN  DBAFISICC.NODOCXCONTRATOTB.INICIO_PAGO%TYPE DEFAULT NULL,
    PFECHAFIN  IN  DBAFISICC.NODOCXCONTRATOTB.INICIO_PAGO%TYPE DEFAULT NULL,
    PTIPO      IN  DBAFISICC.NODOCXCONTRATOTB.TIPO%TYPE DEFAULT NULL,
    PUSUARIO   IN  DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE DEFAULT NULL,
    PCODPERS   IN  DBAFISICC.NODOCEDOCTATB.CODPERS%TYPE DEFAULT NULL,
    RETVAL     OUT SYS_REFCURSOR
  )
  IS  BEGIN
  OPEN RETVAL FOR
    
    
   SELECT A.CODPERS, A.NOMBRE, A. CODPUESTO, A.CORRELATIVO, A. SALARIO, 
          A.NOPAGOS, A.SOLICITUD, A.TIPO, A.CARRERA, A.DESCRIP, A.INICIO_PAGO
              
     FROM(SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || APELLIDO1 
                 || ' ' || APELLIDO2 AS NOMBRE, A.CODPUESTO, A.CORRELATIVO, 
                 A.SALARIO SALARIO, A.NOPAGOS, A.SOLICITUD,  A.TIPO, 
                 C.CARRERA, A.DESCRIP, A.INICIO_PAGO
       
           FROM DBAFISICC.NODOCXCONTRATOTB A, DBAFISICC.NOPERSONALTB B,
                DBAFISICC.NODOCXCONTRATOCCTB C
           WHERE TRUNC(A.INICIO_PAGO) BETWEEN TRUNC(PFECHAINI) 
           AND TRUNC(PFECHAFIN)
           AND A.TIPO IN(6,7)
           AND B.CODPERS = A.CODPERS
           AND C.CORRELATIVO = A.CORRELATIVO
           AND C.CODPUESTO = A.CODPUESTO
           AND C.CODPERS = A.CODPERS
           AND C.CARRERA = 'LITA'
           AND A.SOLICITUD is not null
        
         UNION SELECT D.CODPERS, E.NOMBRE1||' '||E.NOMBRE2 || ' '|| E.APELLIDO1 
                      ||' '||E.APELLIDO2 AS NOMBRE, D.CODPUESTO, 
                      ROWNUM CORRELATIVO, D.SALDO SALARIO, D.NOPAGOS, 
                      TO_NUMBER(D.SOLICITUD) SOLICITUD, 8 TIPO, D.CARRERA,  
                      NVL((SELECT DESCRIPCION
                            FROM DBAFISICC.CAMAINHORARIOSTB
                            WHERE HORARIO = D.HORARIO), 
                          (SELECT DESCRIPCION
                            FROM DBAFISICC.CAHMAINHORARIOSTB
                            WHERE HORARIO = D.HORARIO))DESCRIP, 
                            (select INICIO_PAGO 
                              from DBAFISICC.nodocxhorariotb
                              where horario = d.horario
                              and codpers = d.codpers
                              and resolucion = d.solicitud)INICIO_PAGO
          
          FROM (SELECT A.CODPERS, A.CODPUESTO, A.SOLICITUD, A.HORARIO, 
                       B.CARRERA, COUNT(A.CODPERS) NOPAGOS, SUM(A.MONTO) SALDO
                  FROM DBAFISICC.NODOCEDOCTATB A, DBAFISICC.NODOCEDOCTACCTB B,
                       DBAFISICC.CACARRERASVW  C
                  WHERE A.NOMINA = B.NOMINA
                  AND A.CORRELATIVO = B.CORRELATIVO
                  AND A.CONTRATO = 8
                  AND B.CARRERA = C.CARRERA
                  AND C.MAINCAR = 'LITA'
                  AND TRUNC(FECHA) BETWEEN TRUNC(PFECHAINI) 
                  AND TRUNC(PFECHAFIN)
                  AND A.SOLICITUD is not null
                GROUP BY A.CODPERS, A.CODPUESTO, A.SOLICITUD, A.HORARIO, 
                         B.CARRERA) D, DBAFISICC.NOPERSONALTB E
          WHERE D.CODPERS = E.CODPERS) A
      WHERE (A.TIPO = PTIPO OR PTIPO IS NULL)
      AND (A.CODPERS = PCODPERS OR PCODPERS IS NULL)
    ORDER BY A.TIPO, A.NOMBRE, A.CODPUESTO;
        

 END REPAPROBACIONNOMINAIDEA;