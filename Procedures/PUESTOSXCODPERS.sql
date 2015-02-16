 /* 
   Autor: Kevin Herrera
   Fecha: 12/11/2014
   Descripcion: Devuelve los puestos en los que impartio cursos un docente.
 */
 
 PROCEDURE PUESTOSXCODPERS
 (
    PCODPERS  DBAFISICC.RHHDOCENTESTB.CODPERS%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
 )  
  AS BEGIN
   OPEN RETVAL FOR
    
     SELECT B.CODPUESTO, B.DESPUESTO
     
       FROM (SELECT DISTINCT A.CODPUESTO
                FROM DBAFISICC.RHHDOCENTESTB A, DBAFISICC.CAHCURSHORATB B, 
                     DBAFISICC.CAHMAINHORARIOSTB C, DBAFISICC.NOPUESTOSTB D
                WHERE A.HORARIO = B.HORARIO
                AND A.FECHAIMP = B.FECHAIMP
                AND A.HORARIO = C.HORARIO
                AND A.FECHAIMP = C.FECHAIMP
                AND A.CODPUESTO = D.CODPUESTO
                AND A.STATUS IN ('A','P')
                AND B.TIPOASIG IN('AS','DT','SEM')
                AND A.CODPERS = PCODPERS
                AND EXISTS (SELECT 1 
                              FROM DBAFISICC.NOHDOCXHORARIOTB 
                              WHERE HORARIO = A.HORARIO)) A, 
             DBAFISICC.NOPUESTOSTB B
        WHERE A.CODPUESTO = B.CODPUESTO
      
      ORDER BY B.DESPUESTO;
  
 END PUESTOSXCODPERS;
    
      