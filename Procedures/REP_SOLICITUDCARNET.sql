/*
autor: Jorge Velásquez
Fecha: 21/06/2012
Descripcion: Procedimiento que devuelve el cursor con los datos necesarios para
  llenar el reporte RepSolicitudCarne.
  Recibe los parámetros PCENTRO, PFECHAINIC, PFECHAFIN,PSOLICITADOS
Modificaciones: 06/08/2012 - Jorge Velásquez. Se cambió el procedimiento para
  que devolviera FECHASOLIC especificando la hora.
Modificaciones: 06/08/2012 - Jorge Velásquez. Se cambió el procedimiento para
  que devolviera el campo FECHA_BANCO.
autor       : Xiomara Velasquez
Fecha       : 28/08/2013
Modificacion: Se quitan los parametros de PFECHAINIC, PFECHAFIN,PSOLICITADOS 
debido que se esta automatizando el proceso de busqueda de solicitud de carne
para el personal de registro.
autor       : Xiomara Velasquez
Fecha       : 04/04/2014
Modificacion: Se agrega el tramite 70 que ahora tambien se solicitan carne
              por ese medio

autor       : Kevin Herrera
Fecha       : 26/05/2014
Modificacion: Se agrega los parametros PINICIO, PFIN, PSTATUS y PSTATUS2.              

*/

PROCEDURE REP_SOLICITUDCARNET
  (
    PUSUARIO         IN DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
    PCENTRO          IN  dbafisicc.cacarnetbitb.iduniv%type default null,
    PINICIO          IN  dbafisicc.SOSOLTRAMITETB.FECHASOLIC%type default null,
    PFIN             IN  dbafisicc.SOSOLTRAMITETB.FECHASOLIC%type default null,
    PSTATUS          IN  dbafisicc.SOSOLTRAMITETB.PASO%type default null,
    PSTATUS2         IN  dbafisicc.SOSOLTRAMITETB.PASO%type default null,
    PCARNET          IN  dbafisicc.SOSOLTRAMITETB.CARNET%type default null,
    retval           out sys_refcursor
  )
  IS 
  BEGIN
    OPEN RETVAL FOR

     SELECT A.FECHASOLIC, DBAFISICC.PKG_ALUMNO.NOMBRE(B.CARNET,3) NOMBRES,
            DBAFISICC.PKG_ALUMNO.NOMBRE(B.CARNET,4) APELLIDOS,
            B.CARNET, A.SOLICITUD, A.STATUS, trunc(B.FECHA_BANCO) fecha_banco, 
            B.FECHA_HORA,b.iduniv, C.NOMBRE DEPARTAMENTO,B.FECHA_REGISTRO,
            A.PASO, a.USUARIO
          
              FROM DBAFISICC.SOSOLTRAMITETB A, DBAFISICC.CACARNETBITB B, 
                   DBAFISICC.SODEPTOSTB C
              WHERE A.CARNET  = B.CARNET
              AND A.TRAMITE   IN (68,70)
              AND (A.FECHASOLIC BETWEEN PINICIO AND PFIN OR PINICIO IS NULL)
              AND C.DEPTO(+) = DBAFISICC.PKG_SOLTRAMITE.DEPTOACTUAL
                                                 (A.TRAMITE,A.PASO)
              AND (A.USUARIO = PUSUARIO OR PUSUARIO is null)
              AND (A.PASO  = PSTATUS OR PSTATUS IS NULL)
              AND (A.PASO  != '0' OR PSTATUS2 IS NULL)
              AND (B.IDUNIV  = PCENTRO OR PCENTRO IS NULL)
              AND (A.CARNET IN (SELECT * FROM TABLE(
                                                   SPLIT_VARCHAR(PCARNET,',')))
                                                            OR PCARNET is null)
      ORDER BY B.IDUNIV;
      
END REP_SOLICITUDCARNET;