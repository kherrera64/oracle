/*
Nombre: RESUMEN_HESTADO_CUENTA
Autor: Luis Merida
Fecha: 22/01/2014
Descripcion: Devuelve el resumen de estado de cuenta historico segun 
             los parametros PCARNET, PCARRERA, PFECHAIMP.
Modificacion - 22/07/2014 - Luis Merida -
Descripcion: Se agrego DECODE para devolver el codmovto, tambien
             se agrego el campo centro y si no tiene centro se muestra la 
             carrera.
             
 Modificacion: KHERRERA - 19/12/2014 - Se filtra por carrera_sede y si no
                se encuentran por carrera.
*/
PROCEDURE RESUMEN_HESTADO_CUENTA(
    PCARNET     DBAFISICC.CCHEDOCTADETALLETB.CARNET%TYPE,
    PCARRERA    DBAFISICC.CCHEDOCTADETALLETB.CARRERA%TYPE DEFAULT NULL,
    PCENTRO     DBAFISICC.CCHEDOCTADETALLETB.CENTRO%TYPE DEFAULT NULL,
    PFECHAIMP   DBAFISICC.CCHEDOCTADETALLETB.FECHAIMP%TYPE,
    RETVAL  OUT SYS_REFCURSOR
)
IS BEGIN
  OPEN RETVAL FOR  
  
     SELECT TO_CHAR(A.CARGOS-A.PAGOS-A.ABONOS, '999,999.00') SALDO,A.CARNET, 
            A.CARRERA, A.CONCEPTO, A.CUOTA, A.FR, A.INIFRAC, 
            TO_CHAR(A.CARGOS, '999,999.00') CARGOS, 
            TO_CHAR(A.PAGOS, '999,999.00') PAGOS, 
            TO_CHAR(A.ABONOS, '999,999.00') ABONOS,
            A.MORA, A.ADELANTO, A.CURSO, A.FECHAIMP,
            DECODE(B.CODMQ,1,UPPER(B.DESCRIPCIONMQ),4,UPPER(B.DESCRIPCIONMQ),
        A.CODMOVTO) CODMOVTO, NVL(A.CENTRO, A.CARRERA) CENTRO
        FROM DBAFISICC.CCHEDOCTADETALLETB A, DBAFISICC.CCTIPOMOVTOTB B
        WHERE A.CARNET=PCARNET
        AND A.CONCEPTO = B.CODMOVTO
        AND (A.CARRERA=PCARRERA OR PCARRERA IS NULL)
        AND (A.CENTRO = PCENTRO OR PCENTRO IS NULL)
        AND TRUNC(A.FECHAIMP)=TRUNC(PFECHAIMP);
        
END RESUMEN_HESTADO_CUENTA;