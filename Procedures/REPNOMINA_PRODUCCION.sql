/*   
  autor: Andrea Alvarado   
  Fecha: 18/05/2012   
  Descripcion: Procedimiento para devolver la nomina docente temporal, este    
              genera un correlativo que identifica la nomina a desplegar para el    
              reporte.    
  Parametros: el reporte solicita los parametros    
    usuario, para identificar quien realiza la nomina.   
    seccion, donde los valores esperados son IZ - Incluye Z, NZ-No se incluye Z   
    SZ - solo la seccion Z.   
    Seccion 2 - Para especificar una seccion especifica si se desean todas las 
    secciones  se deja null este campo.    
    Carrera   - recibe un listado de carreras a incluir.    
    puesto    - solo tiene dos opciones Catedratico - 000010 o    
    Auxiliares - 0   
    devuelve el cursor con los parametros determinados y los calculos de salario 
    y semanas de clase.    
    
  Modificacion: AALVARADO - 24/04/2013 - AGREGUE NULL EN FECHAIMP PARA ENVIAR A 
  SP_NOMINADOCENTE. 
  
  Modificacion: KHERRERA - 08/07/2014 - Se agrega el puesto 000085.
*/   
PROCEDURE REPNOMINA_PRODUCCION   
(   
    PUSUARIO   DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,   
    PSECCION   DBAFISICC.CATIPOSECTB.SECCION%TYPE,   
    PSECCION2  VARCHAR DEFAULT NULL,   
    PCARRERA   VARCHAR,   
    PPUESTO    DBAFISICC.NOPUESTOSTB.CODPUESTO%TYPE DEFAULT NULL,    
    PTIPO      DBAFISICC.CATIPOASIGTB.TIPOASIG%TYPE,   
    CURTABLA   OUT T_CURSOR   
)   
IS    
    --CURSOR PRINCIPAL agrupa todos la informacion que se genera de las tablas 
    --(sin calculos)   
CURSOR NOMINA_CURSOR IS   
    SELECT DISTINCT CA.HORARIO, CA.DESCRIPCION,TRUNC(CA.FECHAINI) FECHAINI_CURSO,   
           TRUNC(CA.FECHAFIN) FECHAFIN_CURSO, RH.CODPERS,    
           TRUNC(RH.FECHAINI) FECHAINI_DOC, TRUNC(RH.FECHAFIN) FECHAFIN_DOC,   
           RH.CODPUESTO,NOPERS.TIPOPAGO || ' '|| NOPERS.NO_PROVE PAGO,RH.STATUS,    
           RH.SOLICITUD HORA,   
           CASE WHEN NOMBRADOS.FECHANOMB IS NULL    
                AND (RH.STATUS <> 'B' OR RH.STATUS <>'I')    
                AND RH.SOLICITUD IS NULL THEN ' NO SOLICITADOS'    
           ELSE    
               CASE WHEN NOMBRADOS.FECHANOMB IS NULL    
                    AND (RH.STATUS <> 'B' OR RH.STATUS <>'I')    
                    AND RH.SOLICITUD IS NOT NULL THEN ' SOLICITADOS'    
               ELSE    
                   CASE WHEN (RH.STATUS = 'B' OR RH.STATUS = 'I')    
                        AND RH.SOLICITUD IS NULL THEN 'BAJAS NO SOLICITADAS'    
                   ELSE    
                        CASE WHEN (RH.STATUS = 'B' OR RH.STATUS = 'I')    
                             AND RH.SOLICITUD IS NOT NULL    
                             AND NOMBRADOS.FECHANOMB IS NULL 
                             THEN 'BAJAS SOLICITADAS'    
                        ELSE    
                             CASE WHEN (RH.STATUS = 'B' OR RH.STATUS = 'I')    
                                  AND NOMBRADOS.FECHANOMB IS NOT NULL    
                                  THEN 'BAJA APROBADA'    
                             ELSE    
                                  CASE WHEN NOMBRADOS.FECHANOMB IS NOT NULL    
                                       AND (RH.STATUS <> 'B' OR RH.STATUS <>'I')    
                                       AND RH.SOLICITUD IS NOT NULL    
                                       THEN 'APROBADOS'     
                              END    
                          END    
                      END    
                  END    
              END    
        END TIPO    
        
        FROM DBAFISICC.CAMAINHORARIOSTB CA, DBAFISICC.RHDOCENTESTB RH,    
             DBAFISICC.NOPERSONALTB NOPERS, DBAFISICC.CACURSHORATB CACU,   
            DBAFISICC.NODOCXHORARIOTB NOMBRADOS    
        WHERE CA.STATUS = 'A'    
        AND CA.HORARIO = RH.HORARIO    
        AND RH.CODPERS = NOPERS.CODPERS   
        AND CA.HORARIO = CACU.HORARIO   
        AND RH.HORARIO = NOMBRADOS.HORARIO(+)    
        AND RH.CODPUESTO = NOMBRADOS.CODPUESTO(+)   
        AND RH.CODPERS = NOMBRADOS.CODPERS(+)   
        AND NVL(NOMBRADOS.STATUS,'P') = 'P'   
        AND (CACU.TIPOASIG = PTIPO OR (PTIPO <> 'ITC' AND CACU.TIPOASIG ='AS'))   
        AND ((PPUESTO='000010' AND RH.CODPUESTO 
            IN ('000010','000030','000073','000040','000080','000081'))    
            OR (PPUESTO ='0'  AND RH.CODPUESTO NOT 
            IN ('000010','000030','000073','000040','000080','000081'))   
            OR (PPUESTO = '000085') OR PPUESTO IS NULL)   
        AND CACU.CARRERA IN (SELECT * FROM TABLE(SPLIT_VARCHAR(PCARRERA,',')))   
        AND  ((PSECCION2 IS NOT NULL    
               AND PSECCION = 'IZ'    
               AND CACU.SECCION IN ('AN','Z',PSECCION2))    
               OR (PSECCION2 IS NOT NULL     
               AND PSECCION = 'NZ'   
               AND CACU.SECCION =PSECCION2)   
               OR (PSECCION2 IS NOT NULL     
               AND PSECCION = 'SZ'   
               AND CACU.SECCION IN ('AN','Z'))   
               OR (PSECCION2 IS NULL   
               AND PSECCION = 'SZ'   
               AND CACU.SECCION IN ('AN','Z'))   
               OR (PSECCION2 IS NULL    
               AND PSECCION = 'NZ'   
               AND CACU.SECCION NOT IN ('AN','Z'))   
               OR (PSECCION2 IS NULL   
               AND PSECCION = 'IZ'))   
  ORDER BY CA.HORARIO;   
           
  --Cursor para recorrer el horario de los cursos envio horario.    
  CURSOR HORARIO_CURSOR(PHORARIO DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE) IS   
      SELECT HORARIO DHHORARIO, CORRELATIVO DHCOR, DIA DHDIA,   
             TO_CHAR(HORAINI,'hh24:mi')||'-'||TO_CHAR(HORAFIN,'hh24:mi') DHHORA,   
             SALON DHSALON, TORRE DHTORRE, CODPERS DHCODPERS,HORAINI DHINI,    
             HORAFIN DHFIN   
        FROM  DBAFISICC.CAHORARIOSTB   
        WHERE HORARIO=PHORARIO   
        ORDER BY DIA,HORAINI;   
--Los registros que se utilizan en el procedimiento.   
   NOMINA_FILA   NOMINA_CURSOR%ROWTYPE;   
   NOMINA_TEMPORAL DBAFISICC.RHNOMINATB%ROWTYPE;   
   HORARIO_FILA  HORARIO_CURSOR%ROWTYPE;   
      
   --variables que obtienen valores de horas en numeros para enviarlos a difhora   
  VCHORAINI         NUMBER;   
  VCHORAFIN         NUMBER;   
  --Guarda el conteo de las horas por semana   
  VHORAS            NUMBER;   
  --Guarda el valor del salario por curso que devuelve el procedimiento.   
  VSALARIO      NUMBER(13,2);   
  --Guarda el tiempo del curso   
  VTIEMPO       NUMBER:= 0;   
  --determina que tipo de nomina regresa   
  VNOMINA       NUMBER(1);   
  --Guarda una secuencia de nomina que utiliza para identificar el reporte   
   VSOLICITUD    NUMBER(10);   
   --Guarda las fechas de inicio de pago e inicio de poliza en varchar que es    
   -- como regresa el procedimiento   
   VINICIO_PAGO  VARCHAR(10);   
   VINICIO_POLIZA VARCHAR(10);   
BEGIN    
-- Genera el correlativo para identificar la solicitud   
    SELECT SEQREPNOMINA.NEXTVAL    
      INTO VSOLICITUD   
      FROM DUAL;   
--Abre el cursor para recorrer la nomina y hacer los calculos correspondientes   
   OPEN NOMINA_CURSOR;    
   LOOP    
   FETCH  NOMINA_CURSOR INTO NOMINA_FILA;   
     EXIT WHEN NOMINA_CURSOR%NOTFOUND;   
     --Guarda los datos en el registro que se guardan al final.    
          NOMINA_TEMPORAL.HORARIO := NOMINA_FILA.HORARIO;   
          NOMINA_TEMPORAL.DESCRIPCION := NOMINA_FILA.DESCRIPCION;   
          NOMINA_TEMPORAL.FECHAINI_CURSO := NOMINA_FILA.FECHAINI_CURSO;   
          NOMINA_TEMPORAL.FECHAFIN_CURSO := NOMINA_FILA.FECHAFIN_CURSO;   
          NOMINA_TEMPORAL.CODPERS := NOMINA_FILA.CODPERS;   
          NOMINA_TEMPORAL.FECHAINI_DOC := NOMINA_FILA.FECHAINI_DOC;   
          NOMINA_TEMPORAL.FECHAFIN_DOC := NOMINA_FILA.FECHAFIN_DOC;   
          NOMINA_TEMPORAL.CODPUESTO := NOMINA_FILA.CODPUESTO;   
          NOMINA_TEMPORAL.PAGO := NOMINA_FILA.PAGO;   
          NOMINA_TEMPORAL.USUARIO := PUSUARIO;   
          NOMINA_TEMPORAL.STATUS := NOMINA_FILA.STATUS;   
          NOMINA_TEMPORAL.TIPO := NOMINA_FILA.TIPO;   
          NOMINA_TEMPORAL.SOLICITUD := NOMINA_FILA.HORA;   
          VNOMINA := '1'; --POR QUE ES Produccion   
             
          --Hace los calculos correspondientes para ir guardando los valores que   
          --hacen falta para llenar el registro de la nomina.   
          DBAFISICC.SP_NOMINADOCENTE (NOMINA_TEMPORAL.HORARIO,   
                      NOMINA_TEMPORAL.CODPERS,NOMINA_TEMPORAL.CODPUESTO,VNOMINA, 
					/*24/04/2013 - AALVARADO - AGREGADO PARA COMPATIBILIDAD*/
                      NULL,
					/* 24/04/2013 - AALVARADO */
                      NOMINA_TEMPORAL.NUMEROPAGOS,VINICIO_PAGO,   
                      NOMINA_TEMPORAL.PERIODICIDAD,VINICIO_POLIZA,   
                      NOMINA_TEMPORAL.PAGOSPOLIZA,NOMINA_TEMPORAL.TIEMPOCURSO,   
                      VSALARIO,VTIEMPO,NOMINA_TEMPORAL.NOMINAPAGOS);       
          --Convierte los datos de caracter a fecha   
         NOMINA_TEMPORAL.INICIO_PAGO := TO_DATE(VINICIO_PAGO,'dd/mm/yyyy');   
         NOMINA_TEMPORAL.INICIO_POLIZA := TO_DATE(VINICIO_POLIZA,'dd/mm/yyyy');   
             
          --Valida los campos de inicio_pago, inicio_poliza   
          IF NOMINA_TEMPORAL.INICIO_PAGO IS NULL   
          THEN    
            NOMINA_TEMPORAL.INICIO_PAGO := TO_DATE('01/01/1000','dd/mm/yyyy');   
          END IF;   
          IF NOMINA_TEMPORAL.INICIO_POLIZA  IS NULL   
          THEN    
            NOMINA_TEMPORAL.INICIO_POLIZA := TO_DATE('01/01/1000','dd/mm/yyyy');   
          END IF;   
          --Verifica que el salario sea positivo para nombramiento y negativo para   
          --bajas o inactivacion de catedraticos.   
          IF ((NOMINA_TEMPORAL.STATUS = 'B')OR(NOMINA_TEMPORAL.STATUS = 'I'))   
          THEN    
              VSALARIO :=VSALARIO * -1;   
              NOMINA_TEMPORAL.SALARIOCURSO := VSALARIO;   
          ELSE    
              NOMINA_TEMPORAL.SALARIOCURSO := VSALARIO;   
         END IF;   
         --Se calcula el salario mensual en base al numero de pagos y el salario   
        -- por cursosi el numero de pagos es    
        -- si el numero de pagos es null simplemente el salario mensual es 0   
         IF NVL(NOMINA_TEMPORAL.NUMEROPAGOS,0)=0    
         THEN    
              NOMINA_TEMPORAL.SALARIOMENSUAL := 0;   
         ELSE   
              NOMINA_TEMPORAL.SALARIOMENSUAL := 
              NOMINA_TEMPORAL.SALARIOCURSO/NOMINA_TEMPORAL.NUMEROPAGOS;   
         END IF;   
         --Reset el numero de horas para conteo.   
         VHORAS := 0;   
          OPEN HORARIO_CURSOR(NOMINA_TEMPORAL.HORARIO);   
          LOOP   
          FETCH  HORARIO_CURSOR INTO HORARIO_FILA;   
          EXIT WHEN HORARIO_CURSOR%NOTFOUND;   
                 VCHORAINI  := TO_NUMBER(TO_CHAR(HORARIO_FILA.DHINI ,'hh24mi'));   
                 VCHORAFIN  := TO_NUMBER(TO_CHAR(HORARIO_FILA.DHFIN,'hh24mi'));   
                 VHORAS := VHORAS + NOMINADOCENTE.DIFHORAS(VCHORAINI,VCHORAFIN);   
          END LOOP;   
          CLOSE HORARIO_CURSOR;   
          --Graba el numero de horas por semana   
          NOMINA_TEMPORAL.DIFHORA := VHORAS;   
          --inserta en nomina el registro completo ya con los calculos.    
              INSERT INTO DBAFISICC.RHNOMINATB (CODIGO,HORARIO,DESCRIPCION, 
              FECHAINI_CURSO, FECHAFIN_CURSO,CODPERS,FECHAINI_DOC,FECHAFIN_DOC,
              CODPUESTO, PAGO,USUARIO,STATUS,NUMEROPAGOS,INICIO_PAGO,
              PERIODICIDAD, INICIO_POLIZA,PAGOSPOLIZA,SALARIOCURSO,
              SALARIOMENSUAL, TIEMPOCURSO,NOMINAPAGOS,DIFHORA,SOLICITUD,TIPO)   
              
              VALUES (VSOLICITUD,NOMINA_TEMPORAL.HORARIO,
              NOMINA_TEMPORAL.DESCRIPCION, NOMINA_TEMPORAL.FECHAINI_CURSO,
              NOMINA_TEMPORAL.FECHAFIN_CURSO, NOMINA_TEMPORAL.CODPERS,
              NOMINA_TEMPORAL.FECHAINI_DOC, NOMINA_TEMPORAL.FECHAFIN_DOC,
              NOMINA_TEMPORAL.CODPUESTO, NOMINA_TEMPORAL.PAGO,
              NOMINA_TEMPORAL.USUARIO, NOMINA_TEMPORAL.STATUS,
              NOMINA_TEMPORAL.NUMEROPAGOS, NOMINA_TEMPORAL.INICIO_PAGO,
              NOMINA_TEMPORAL.PERIODICIDAD, NOMINA_TEMPORAL.INICIO_POLIZA,
              NOMINA_TEMPORAL.PAGOSPOLIZA, NOMINA_TEMPORAL.SALARIOCURSO,
              NOMINA_TEMPORAL.SALARIOMENSUAL, NOMINA_TEMPORAL.TIEMPOCURSO,
              NOMINA_TEMPORAL.NOMINAPAGOS, NOMINA_TEMPORAL.DIFHORA,
              NOMINA_TEMPORAL.SOLICITUD, NOMINA_TEMPORAL.TIPO);   
   END LOOP;   
   CLOSE NOMINA_CURSOR;   
   OPEN CURTABLA FOR    
   --Devuelve la tabla de nomina con anexos de nopersonaltb y de puesto.    
        SELECT A.*,B.GRACAD||' '||B.NOMBRE1||' '||B.NOMBRE2||' '||B.APELLIDO1||   
              ' '||B.APELLIDO2 NOM_CATEDRATICO, B.ORDEN||' '||B.CEDULA NOCEDULA,    
              C.DESPUESTO PUESTO   
            
            FROM DBAFISICC.RHNOMINATB A, DBAFISICC.NOPERSONALTB B, 
            DBAFISICC.NOPUESTOSTB C   
            WHERE A.CODIGO = VSOLICITUD   
            AND A.CODPERS = B.CODPERS   
            AND A.CODPUESTO = C.CODPUESTO; 
            
END REPNOMINA_PRODUCCION;