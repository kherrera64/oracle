/*  
Nombre:       DBAFISICC.PKG_INSCRIPCION.INSCRITOS_MT
Autor:        Luis Mérida  
Fecha:        2013-12-02  
Package:      PKG_INSCRIPCION  
Descripcion:  Procedimiento que devuelve los datos de los alumnos que 
              no han cancelado el total de su MT. 

Modificacion:
Autor:        Miguel Barillas 
Fecha:        21-03-2013  
Package:      PKG_INSCRIPCION  
Descripcion:  Toma en cuenta los conceptos MT, MA y  filtra por ellos

Modificacion:
Autor:        Miguel Barillas 
Fecha:        09-04-2013  
Descripcion:  Toma en cuenta el status del alumno y filtra por los status: 
              1, IP, PR, T
              
Modificacion:
Autor:        Kevin Herrera
Fecha:        11-03-2014  
Descripcion:  Se agregaron los parametros de carnet y usuario para que se 
              pueda filtrar por ellos.
Modificacion:
Autor:        Kevin Herrera
Fecha:        18-03-2014  
Descripcion:  se permite la consulta si en parametro PUSUARIO es null.

Modificacion:
Autor:        Kevin Herrera
Fecha:        19-03-2014  
Descripcion:  Si PUSUARIO es null no se realiza la consulta a la tabla
              CAUSUARIOSCARRERASTB.
*/ 
PROCEDURE INSCRITOS_MT
(
    PENTIDAD DBAFISICC.CACARRERASTB.ENTIDAD%TYPE DEFAULT NULL,
    PENCARGADO DBAFISICC.CACARRERASTB.ENCARGADO%TYPE DEFAULT NULL,
    PSEDE DBAFISICC.CACARRERASTB.COMENTARIOS%TYPE DEFAULT NULL,
    PGRADO DBAFISICC.CACARRERASTB.GRADO%TYPE DEFAULT NULL,
    PCARRERA DBAFISICC.CACARRERASTB.CARRERA%TYPE DEFAULT NULL,
    PCODMOVTO DBAFISICC.CCEDOCTATB.CODMOVTO%TYPE DEFAULT NULL,
    PUSUARIO DBAFISICC.CAUSUARIOSCARRERASTB.USUARIO%TYPE DEFAULT NULL,
    PCARNET   IN VARCHAR2 DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
)
IS
BEGIN
 OPEN RETVAL FOR 
 
   SELECT F.CARRERA, F.CARNET, F.NOMBRE, F.INSCRITO, F.FECHA, F.TIPOBECA, 
          F.STATALUM, F.CODMOVTO, F.TOTAL_MT, F.PMT, F.MTREAL, F.SOLTRAMITE, 
          F.PAGOS, DECODE(G.CARNET,NULL,0,1) EXCEPCION
         FROM 
             (SELECT A.CARRERA, A.CARNET, 
                     DBAFISICC.PKG_ALUMNO.NOMBRE(A.CARNET, 2) NOMBRE, 
                     A.INSCRITO, MIN(DECODE(B.CARGO_ABONO,'C',B.FECHA)) FECHA,
                     A.TIPOBECA,A.STATALUM,  
                     DECODE (B.CODMOVTO,'MTB','MT',B.CODMOVTO) CODMOVTO,
                     SUM(DECODE(B.CARGO_ABONO,'C',1,-1)*B.MONTO) TOTAL_MT, 
                     A.PORCENTAJEMT  PMT, 
                     C.COBROINS*(1-NVL(A.PORCENTAJEMT/100,0)) MTREAL,
                     MIN(DECODE(B.CARGO_ABONO,'C',B.OPERACION)) SOLTRAMITE,
                     NVL((SELECT SUM(MONTO)
                             FROM DBAFISICC.CCEDOCTATB D
                             WHERE A.CARNET = D.CARNET
                             AND A.CARRERA = D.CARRERA
                             AND EXISTS (SELECT 1 
                                            FROM DBAFISICC.CCRECIBOSTB E 
                                            WHERE E.RECIBO= D.OPERACION)),0) 
                                            PAGOS
              FROM DBAFISICC.CAALUMCARRSTB A, DBAFISICC.CCEDOCTATB B, 
                   DBAFISICC.CACARRERASTB C
              WHERE A.CARNET = B.CARNET
              AND A.STATALUM IN ('1', 'IP', 'PR', 'T')
              AND A.CARRERA = B.CARRERA
              AND A.CARRERA = C.CARRERA
              AND A.INSCRITO = 1
              AND B.CODMOVTO IN('MT','MTB', 'MA')
              AND (A.CARRERA = PCARRERA OR PCARRERA IS NULL)
              AND (A.CARRERA IN (SELECT CARRERA 
                                  FROM DBAFISICC.CAUSUARIOSCARRERASTB 
                                  WHERE (USUARIO = PUSUARIO)) 
                   or PUSUARIO is null)
              AND (C.ENTIDAD = PENTIDAD OR PENTIDAD IS NULL)
              AND (C.ENCARGADO = PENCARGADO OR PENCARGADO IS NULL)
              AND (C.COMENTARIOS = PSEDE OR PSEDE IS NULL)
              AND (C.GRADO = PGRADO OR PGRADO IS NULL) 
             
              
              GROUP BY  A.CARRERA, A.CARNET, 
                        DBAFISICC.PKG_ALUMNO.NOMBRE(A.CARNET, 1),
                        A.INSCRITO,A.TIPOBECA,A.STATALUM, 
                        DECODE (B.CODMOVTO,'MTB','MT',B.CODMOVTO),
                        A.PORCENTAJEMT, C.COBROINS*(1-NVL(A.PORCENTAJEMT/100,0))
              HAVING SUM(DECODE(B.CARGO_ABONO,'C',1,-1)*B.MONTO) > 0)F,  
                         DBAFISICC.CAMTEXCEPCIONESTB G
         WHERE F.CARNET = G.CARNET(+)
         AND F.CARRERA=  G.CARRERA(+)
         AND NVL(TRUNC(G.FECHAINSCRITO),TRUNC(F.FECHA)) = TRUNC(F.FECHA)
         AND F.TOTAL_MT = G.SALDO(+)
         AND (F.CODMOVTO = PCODMOVTO OR PCODMOVTO IS NULL)
         AND F.STATALUM = G.STATALUM(+)
         AND (F.CARNET = PCARNET OR PCARNET IS NULL)
         AND F.FECHA < SYSDATE -1;
 END INSCRITOS_MT;
