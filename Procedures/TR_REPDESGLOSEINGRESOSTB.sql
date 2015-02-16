/*
Nombre: TR_REPDESGLOSEINGRESOSTB
Autor: Edy Cocon
Fecha: 21/05/2014
Descripcion: Se utiliza para generar el reporte de ingresos desglosados, 
             hace un insert a la tabla de repdesgloseingresostb.
- Modificacion -  Edy Cocon - 09/06/2014 -
  Descripcion: Se agrego a que puedan enviar varias facultades, directores, 
               grados, sedes y carreras y se agrega tipo clob para los 
               parametros.
- Modificacion -  Kevin Herrera - 02/09/2014 -
  Descripcion: Se utiliza el campo centro de la tabla CCTRANSACCTB en lugar de 
               carrera.
- Modificacion -  Kevin Herrera - 03/11/2014 -
  Descripcion: Si no tiene centro el recibo se envia a la carrera VT(GENERALES).
- Modificacion - Javier Garcia - 19/11/2014 -
  Descripcion: Se agrega el parametro PCENTRO.
- Modificacion - Kevin Herrera - 25/11/2014 -
  Descripcion: Se remplaza cacarrerastb por cacarrerasvw y se utiliza carrera
               si el centro es null.
*/
PROCEDURE TR_REPDESGLOSEINGRESOSTB(
    PUSUARIO        IN   DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
    PENTIDAD        IN  CLOB  DEFAULT NULL,  
    PDIRECTOR       IN  CLOB  DEFAULT NULL,  
    PSEDE           IN  CLOB  DEFAULT NULL,  
    PGRADO          IN  CLOB  DEFAULT NULL,  
    PCARRERA        IN  CLOB  DEFAULT NULL,  
    PCENTRO         IN  CLOB  DEFAULT NULL,
    PCONCEPTO       IN  DBAFISICC.CCDETRANSTB.CODMOVTO%TYPE DEFAULT NULL,
    PTIPO           IN  DBAFISICC.CCTRANSACCTB.TIPO%TYPE DEFAULT NULL,
    PFECHAINI       IN  DBAFISICC.CCTRANSACCTB.FECHA%TYPE DEFAULT NULL,
    PFECHAFIN       IN  DBAFISICC.CCTRANSACCTB.FECHA%TYPE DEFAULT NULL,
    PRECIBO         IN  DBAFISICC.CCTRANSACCTB.NUMERO%TYPE DEFAULT NULL,
    PRECIBOFIN      IN  DBAFISICC.CCTRANSACCTB.NUMERO%TYPE DEFAULT NULL,
    PMA             IN  NUMBER DEFAULT 1,
    PACCION         VARCHAR2,
    PSQLCODE   OUT NUMBER
)IS BEGIN
IF PACCION = 'I'
THEN
INSERT INTO DBAFISICC.REPDESGLOSEINGRESOSTB(
        USUARIO,
        CODIGO_FACULTAD,
        FACULTAD,
        DIRECTOR,
        SEDE,
        CODIGO_CARRERA,
        CARRERA,
        FECHA,
        RECIBO,
        CODIGO_MOVIMIENTO,
        MOVIMIENTO,
        CARNET,
        DTRMONTO,
        RECIBOS,
        NOTA_DEBITO_INTERNA,
        NOTA_CREDITO_INTERNA,
        NOTA_DEBITO_ANULACION,
        NOTA_DEBITO_DEVOLUCION,
        NOTA_DEBITO_CHEQUERECHAZADO,
        NOTA_CREDITO_CHEQUERECHAZADO,
        SALDO,
        DTRTIPO,
        FECHAORDEN,
        PERIODOAP
)SELECT PUSUARIO USUARIO, A.ENTIDAD CODIGO_FACULTAD, B.NOMBRE FACULTAD, 
               GRACAD||' '||S.NOMBRE1 ||  ' ' || S.NOMBRE2 ||' '||
                APELLIDO1 ||' '|| S.APELLIDO2 DIRECTOR,
              A.COMENTARIOS SEDE, NVL(D.CENTRO, NVL(D.CARRERA,'VT')) CODIGO_CARRERA,
              NVL(A.NOMBRE, 'GENERALES') CARRERA,
              E.FECHA FECHA, E.NUMERO RECIBO,
              E.CODMOVTO CODIGO_MOVIMIENTO, G.MOVIMIENTO, 
              DECODE(D.CARNET,NULL,
                     (SELECT NOMBRE 
                        FROM DBAFISICC.CCINGRESOSVARIOSTB X
                        WHERE RECIBO = E.NUMERO),
                        D.CARNET||' '|| (SELECT F.NOMBRE1 || ' ' || F.NOMBRE2 
                          ||' '|| F.APELLIDO1 ||' '|| F.APELLIDO2
                                      FROM DBAFISICC.CAALUMNOSTB F
                                        WHERE F.CARNET = D.CARNET))
                    CARNET, E.MONTO DTRMONTO,
				/*ECOCON - 09/05/2014 - Se eliminaron los case*/
          DECODE(E.TIPO, 'R', E.MONTO, 0) RECIBOS,
          DECODE(E.TIPO, 'NDT', E.MONTO*(-1), 0) NOTA_DEBITO_INTERNA,
          DECODE(E.TIPO, 'NCT', E.MONTO, 0) NOTA_CREDITO_INTERNA,  
          DECODE(E.TIPO, 'NDA', E.MONTO*(-1),0) NOTA_DEBITO_ANULACION,
          DECODE(E.TIPO, 'DI', E.MONTO*(-1),0) NOTA_DEBITO_DEVOLUCION,
          DECODE(E.TIPO, 'NDR', E.MONTO*(-1),0) NOTA_DEBITO_CHEQUERECHAZADO,
          DECODE(E.TIPO, 'NCR', E.MONTO,0) NOTA_CREDITO_CHEQUERECHAZADO,
          (DECODE(E.TIPO, 'R', E.MONTO, 0) +
            DECODE(E.TIPO, 'NDT', E.MONTO*(-1), 0) + 
            DECODE(E.TIPO, 'NCT', E.MONTO, 0) +
            DECODE(E.TIPO, 'NDA', E.MONTO*(-1), 0) +
            DECODE(E.TIPO, 'DI', E.MONTO*(-1), 0) +
            DECODE(E.TIPO, 'NDR', E.MONTO*(-1),0) +
            DECODE(E.TIPO, 'NCR', E.MONTO,0) ) SALDO,
          E.TIPO DTRTIPO, E.FECHA FECHAORDEN, 
          DBAFISICC.EDOCTA.PERIODO(E.NUMERO) PERIODOAP
        FROM DBAFISICC.CACARRERASVW A, DBAFISICC.GNENTIDADESTB B,
             DBAFISICC.CCTRANSACCTB D, DBAFISICC.CCDETRANSTB E, 
             DBAFISICC.CCTIPOMOVTOTB G, DBAFISICC.NOPERSONALTB S
          WHERE (A.ENTIDAD     IN(SELECT * 
                          FROM TABLE (SPLIT_VARCHAR(PENTIDAD,','))) 
                              OR PENTIDAD IS NULL)
          AND S.CODPERS = A.ENCARGADO
          
          AND NVL(D.CENTRO, NVL(D.CARRERA,'VT')) IN (SELECT M.CARRERA
                                          FROM DBAFISICC.CAUSUARIOSCARRERASTB M
                               WHERE (M.USUARIO = PUSUARIO OR PUSUARIO IS NULL))
          AND B.FACULTAD = A.FACULTAD
          AND B.ENTIDAD = A.ENTIDAD
          AND (A.COMENTARIOS IN(SELECT * 
                                    FROM TABLE (SPLIT_VARCHAR(PSEDE,',')))
                                          OR PSEDE IS NULL)
          AND (A.CENTRO IN(SELECT * 
                                    FROM TABLE (SPLIT_VARCHAR(PCENTRO,',')))
                                          OR PCENTRO IS NULL)
          AND (NVL(D.CENTRO,'VT') IN(SELECT * 
                                      FROM TABLE (SPLIT_VARCHAR(PCARRERA,','))) 
                                          OR PCARRERA IS NULL)
          AND NVL(D.CENTRO, NVL(D.CARRERA,'VT')) = A.CARRERA
          AND (D.TIPO =PTIPO OR PTIPO IS NULL)
          AND (E.CODMOVTO = PCONCEPTO OR PCONCEPTO IS NULL)
          AND  (A.ENCARGADO   IN(SELECT * 
                                  FROM TABLE (SPLIT_VARCHAR(PDIRECTOR,','))) 
                                    OR PDIRECTOR IS NULL)
          AND (A.GRADO       IN(SELECT * 
                                  FROM TABLE (SPLIT_VARCHAR(PGRADO,','))) 
                                        OR PGRADO IS NULL)
          AND (E.NUMERO IN (SELECT Z.NUMERO
                               FROM DBAFISICC.CCTRANSACCTB Z
                               WHERE Z.NUMERO = E.NUMERO
                               AND Z.TIPO = 'R'
                      AND Z.FECHA BETWEEN PFECHAINI AND PFECHAFIN) OR PMA = 1)
          AND NVL(D.FLAGOPERADO,'O') != 'A'
          AND TRUNC(D.FECHA) BETWEEN (PFECHAINI) AND (PFECHAFIN)
          AND E.FECHA = D.FECHA
          AND E.TIPO = D.TIPO
          AND E.NUMERO = D.NUMERO
          AND ((D.NUMERO BETWEEN PRECIBO AND PRECIBOFIN) 
          OR (PRECIBO IS NULL AND PRECIBOFIN IS NULL))
          AND G.CODMOVTO = E.CODMOVTO
       ORDER BY A.FACULTAD,A.ENCARGADO,A.COMENTARIOS,A.CARRERA,E.FECHA,
                E.NUMERO, E.TIPO DESC;
ELSIF PACCION = 'D'
THEN 
  DELETE FROM DBAFISICC.REPDESGLOSEINGRESOSTB A
    WHERE A.USUARIO = PUSUARIO;
END IF;

   PSQLCODE := SQLCODE;       
  EXCEPTION  
    WHEN OTHERS  
    THEN
        PSQLCODE := SQLCODE; 

END TR_REPDESGLOSEINGRESOSTB;