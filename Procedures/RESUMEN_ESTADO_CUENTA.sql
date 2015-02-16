/*
Nombre: RESUMEN_ESTADO_CUENTA
Autor: Edy Cocon
Fecha:  20/12/2013
Descripion: Procedimiento que devuelve el resumen del estado de cuenta de un 
            alumno de acuerdo a los parametros PCARNET Y PCARRERA.
 - Modificacion - 11/01/2013 -
 Descripcion: Ahora los campos saldo, cargos son devueltos como tipo de dato
              caracter.
- Modificacion - 02/06/2014 - Edy Cocon -
  Descripcion: Se agrego a que devuelva el campo trimestre.
- Modificacion - 08/06/2014 - Edy Cocon -
  Descripcion: Se elimino el campo curso y se agrego Decode para devolver
			   el codmovto.
- Modificacion - 08/06/2014 - Edy Cocon -
  Descripcion: Se cambio el order by de concepto ahora es CODMOVTO.
  - Modificacion - 12/06/2014 - Edy Cocon -
  Descripcion: Se agrego el campo centro y si no tiene centro se muestra la 
               carrera.
 - Modificacion - 03/09/2014  - Edy Cocon -
  Descripcion: Se agregaron a que devuelva el nombre del curso y su codigo.
- Modificacion - 06/11/2014  - Edy Cocon -
  Descripcion: Se agrega el parametro PPERIODO para filtrar por trimestre 
               en cchedoctadetalletb, para todos se deja default null.
               
  Modificacion: KHERRERA - 19/12/2014 - Se filtra por carrera_sede y si no
                se encuentran por carrera.
*/
PROCEDURE RESUMEN_ESTADO_CUENTA(
  PCARNET       DBAFISICC.CCHEDOCTADETALLETB.CARNET%TYPE,
  PCARRERA      DBAFISICC.CCHEDOCTADETALLETB.CARRERA%TYPE DEFAULT NULL,
  PCENTRO       DBAFISICC.CCHEDOCTADETALLETB.CENTRO%TYPE DEFAULT NULL,
  PUSUARIO      DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
  PPERIODO      DBAFISICC.CCHEDOCTADETALLETB.TRIMESTRE%TYPE DEFAULT NULL,
  RETVAL   OUT  SYS_REFCURSOR
) 
IS BEGIN
  OPEN RETVAL FOR
    SELECT TO_CHAR(SUM(CARGOS)- SUM(PAGOS)- SUM(ABONOS), '999,999.00') SALDO,
           A.CARNET,A.CARRERA,A.CONCEPTO, A.TRIMESTRE, 
           DECODE(SUM(A.CUOTA),'0','',TO_CHAR(SUM(A.CUOTA),'999,999.00')) CUOTA,
           FR,INIFRAC, TO_CHAR(SUM(A.CARGOS),'999,999.00') CARGOS, 
           DECODE(SUM(A.PAGOS),'0','',TO_CHAR(SUM(A.PAGOS),'999,999.00')) PAGOS,
           DECODE(SUM(A.ABONOS),'0','',
           TO_CHAR(SUM(A.ABONOS),'999,999.00')) ABONOS,
           DECODE(SUM(A.MORA),'0','',TO_CHAR(SUM(A.MORA),'999,999.00')) MORA,
           DECODE(SUM(A.ADELANTO),'0','',
            TO_CHAR(SUM(A.ADELANTO),'999,999.00')) ADELANTO,
           DECODE(B.CODMQ,1,UPPER(B.DESCRIPCIONMQ),4,UPPER(B.DESCRIPCIONMQ),
            A.CODMOVTO) CODMOVTO, NVL(A.CENTRO, A.CARRERA) CENTRO, A.CURSO, 
            A.CODCURSO
        FROM DBAFISICC.CCHEDOCTADETALLETB A, DBAFISICC.CCTIPOMOVTOTB B
            WHERE A.CONCEPTO = B.CODMOVTO
              AND A.CARNET = PCARNET
              AND (A.CARRERA = PCARRERA OR PCARRERA IS NULL)
              AND (NVL(A.CENTRO, A.CARRERA) = PCENTRO OR PCENTRO IS NULL)
              AND (A.TRIMESTRE = PPERIODO OR PPERIODO IS NULL)
              AND EXISTS(SELECT 1
                          FROM DBAFISICC.GNUSUARIOSTB B
                              WHERE B.USUARIO = PUSUARIO)
 GROUP BY A.CONCEPTO,  A.CARNET,A.CARRERA,  A.TRIMESTRE, FR,INIFRAC,
          DECODE(B.CODMQ,1,UPPER(B.DESCRIPCIONMQ),4,
          UPPER(B.DESCRIPCIONMQ),A.CODMOVTO), NVL(A.CENTRO, A.CARRERA), A.CURSO,
          A.CODCURSO
ORDER BY CODMOVTO ASC;
END RESUMEN_ESTADO_CUENTA;