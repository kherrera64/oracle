/*
autor: Luis Mérida
Fecha: 28/11/2011
Descripcion: Procedimiento que devuelve el cursor con los datos necesarios para 
             impresion de reporte de ingresos por facultad, recibe los parametros:
             Usuario, Entidad, Director, Sede, Grado, Carrera, Concepto, Fecha 
             Inicio, Fecha Fin.
Modificacion: AALVARADO - 05/06/2013- Cambio de NDA a resta con el recibo
y en todos los tipos de pago. 
AALVARADO - 04/03/2014 - Se cambio la forma de comparar los parametros null.
AALVARADO - 10/04/2014 - Se agregaron las funciones para resumen de ingresos
por BI y GYT
Modificacion: LMERIDA - 08/05/2014 - Se agrego la nueva funcion 
dbafisicc.RINGRESOSTIPOPAGO() que va a traer lo montos de la tabla
DYNAMICS.HINGRESOS_PASO
Modificacion: LMERIDA - 15/05/2014 - se modifico el parametro CHEQUE
por el parametro CHEQUES que es lo correcto en la funcion RINGRESOSTIPOPAGO
Modificacion: AJMARTINEZ - 20/05/2014 - se agregaron la funciones que devuelven
los ingresos por GYT de agencia e internet (funcion RINGRESOSTIPOPAGO)
Modificacion: LMERIDA - 24/05/2014 - se agregó un delete y un insert de la tabla 
DBAFISICC.TEMP_RINGRESOSXFACULTAD, se agregó NVL() si la carrera viene vacia
que le agregue 'VT', se comentó el NDA, DI, NDR, NCR.
Modificacion: LMERIDA - 03/06/2014 - se modifico el tipo del parametro PCARRERA
de varchar2 a clob debido a que el varchar2 era limitado al momento de enviar
todas las carreras activas he inactivas.
Modificacion: KHERRERA - 01/09/2014 - se utiliza el campo centro de cctransacctb
en lugar de carrera.
*/
PROCEDURE REP_INGRESOSXFACULTAD
(
  PUSUARIO         IN  dbafisicc.gnusuariostb.usuario%type default null,
  PENTIDAD         IN  dbafisicc.gnentidadestb.entidad%type default null,
  PENCARGADO       IN  dbafisicc.cacarrerastb.encargado%type default null,
  PSEDE            IN  dbafisicc.cacarrerastb.comentarios%type default null,
  PGRADO           IN  dbafisicc.cacarrerastb.grado%type default null,
  PCARRERA         IN  clob default null,
  PCONCEPTO        IN  dbafisicc.ccdetranstb.codmovto%type default null,
  PDESDE           IN  dbafisicc.cctransacctb.fecha%type default null,
  PHASTA           IN  dbafisicc.cctransacctb.fecha%type default null
)
  IS 
  BEGIN
  delete from DBAFISICC.TEMP_RINGRESOSXFACULTAD
           where usuario = PUSUARIO;

     insert into DBAFISICC.TEMP_RINGRESOSXFACULTAD (CARRERA, ENCARGADO, NOMBRE, COMENTARIOS, 
                 CODMOVTO, FACULTAD, FACNAME, CARNAME, DESMOVTO, R, NDT, NCT, 
                 REFECTIVO, RCHEQUESBI, RCHEQUESOT, RTARJETAS, RMQSERIESAGBI, 
                 RMQSERIESINBI, RMQSERIESAGGYT, RMQSERIESINGYT, USUARIO)

        select NVL(a.centro, a.carrera) CARRERA, d.encargado,
        e.nombre1||' '||e.nombre2||' '||e.apellido1||' '||e.apellido2 nombre,
        d.comentarios, b.codmovto, c.entidad facultad, c.nombre_corto facname,
        d.nombre_corto carname, (select movimiento
                                   from dbafisicc.cctipomovtotb
                                   where codmovto = b.codmovto) desmovto,
    --obtengo los ingresos desglosados que corresponden a recibos emitidos
            (select nvl(sum(decode(ab.tipo,'NDA',bb.monto*-1,bb.monto)),0) monto
            FROM DBAFISICC.CCTRANSACCTB AB,DBAFISICC.CCDETRANSTB BB
            where NVL(ab.centro, ab.carrera)= NVL(a.centro, a.carrera)
            and   ab.fecha                = bb.fecha
            and   ab.tipo                 = bb.tipo
            and   ab.numero               = bb.numero
            and   ab.tipo                 in ('R'/*,'NDA'*/)
            and   nvl(ab.flagoperado,'O') != 'A'
            and   bb.codmovto             = b.codmovto
            and   ab.fecha between (PDESDE) and (PHASTA)) r,
     --obtengo los ingresos desglosados que corresponden a los debitos
        (select nvl(sum(bc.monto)*-1,0)
           from dbafisicc.cctransacctb ac,dbafisicc.ccdetranstb bc
           where NVL(ac.centro, ac.carrera)  = NVL(a.centro, a.carrera)
           and   ac.fecha                = bc.fecha
           and   ac.tipo                 = bc.tipo
           and   ac.numero               = bc.numero
           and   ac.tipo                 in ('NDT'/*,'DI','NDR'*/)
           and   nvl(ac.flagoperado,'O') != 'A'
           and   bc.codmovto             = b.codmovto
           and   ac.fecha between (PDESDE) and (PHASTA)) ndt,
      --obtengo los ingresos desglosados que corresponden a los creditos
        (select nvl(sum(bd.monto),0)
           from dbafisicc.cctransacctb ad,dbafisicc.ccdetranstb bd
           where NVL(ad.centro, ad.carrera)  = NVL(a.centro, a.carrera)
           and   ad.fecha                = bd.fecha
           and   ad.tipo                 = bd.tipo
           and   ad.numero               = bd.numero
           and   ad.tipo                 in ('NCT'/*,'NCR'*/)
           and   nvl(ad.flagoperado,'O') != 'A'
           and   bd.codmovto             = b.codmovto
           and   ad.fecha between (PDESDE) and (PHASTA)) nct,
         --obtengo el total de ingresos por efectivo
           nvl(dbafisicc.EDOCTA.RINGRESOSTIPOPAGO(PDESDE,PHASTA,'R', 'EFECTIVO',
           NULL, NVL(a.centro, a.carrera)),0) refectivo,
           --obtengo el total de ingresos por cheques del banco industrial 
           --detallado por recibos, debitos y creditos
           nvl(dbafisicc.EDOCTA.RINGRESOSTIPOPAGO(PDESDE,PHASTA,'R', 'CHEQUES', 
           'BI', NVL(A.CENTRO, A.CARRERA)),0) RCHEQUESBI,
           --obtengo el total de ingresos por cheques de otro banco detallado 
           --por recibos, debitos y creditos
           nvl(dbafisicc.EDOCTA.RINGRESOSTIPOPAGO(PDESDE,PHASTA,'R', 'CHEQUES', 
           'OTROS', NVL(a.centro, a.carrera)),0) RChequesOT,
           --obtengo el total de ingresos por tarjeta de credito detallado por 
           --recibos, debitos y creditos
           nvl(dbafisicc.EDOCTA.RINGRESOSTIPOPAGO(PDESDE,PHASTA,'R', 'TARJETA', 
           NULL, NVL(a.centro, a.carrera)),0) RTarjetas,
           --obtengo el total de ingresos por recibo de mqseries agencia 
           --detallado por recibos, debitos y creditos
           NVL(DBAFISICC.EDOCTA.RINGRESOSTIPOPAGO(PDESDE,PHASTA,'R', 'BIENLINEA'
           , 712, NVL(a.centro, a.carrera)),0) RMQSeriesAgBI,
           nvl(dbafisicc.EDOCTA.RINGRESOSTIPOPAGO(PDESDE,PHASTA,'R', 'BIENLINEA'
           , 718, NVL(a.centro, a.carrera)),0) RMQSeriesInBI,
           --obtengo el total de ingresos por recibo de mqseries GYT agencia e 
           --internet detallado por recibos, debitos y creditos
           NVL(DBAFISICC.EDOCTA.RINGRESOSTIPOPAGO(PDESDE,PHASTA,'R', 'GYTENLINEA'
           , 712, NVL(a.centro, a.carrera)),0) RMQSeriesAgGYT,
           nvl(dbafisicc.EDOCTA.RINGRESOSTIPOPAGO(PDESDE,PHASTA,'R', 'GYTENLINEA'
           , 718, NVL(a.centro, a.carrera)),0) RMQSeriesInGYT,
           PUSUARIO as USUARIO
        
               from dbafisicc.cctransacctb a,dbafisicc.ccdetranstb b, 
               dbafisicc.gnentidadestb c, DBAFISICC.CACARRERASTB D, 
               DBAFISICC.NOPERSONALTB E
               where c.entidad = d.entidad
               and d.carrera = NVL(a.centro, a.carrera)
               and NVL(a.centro, a.carrera) in (select carrera 
                                                from dbafisicc.causuarioscarrerastb
                                                where usuario = USUARIO)
               AND  D.ENTIDAD LIKE PENTIDAD||'%'
               AND  (d.CARRERA IN ( SELECT * 
                                    FROM TABLE(Split_varchar(PCARRERA,','))) OR 
                     PCARRERA IS NULL)
               and   a.fecha = b.fecha
               and   a.tipo = b.tipo
               and   nvl(a.flagoperado,'O') != 'A'
               and   d.facultad = '002'
               and   c.facultad = '002'
               and   a.numero = b.numero
               and   a.tipo in ('NDT','R','NCT','NDA','DI','NDR','NCR')
               and   (b.codmovto = PCONCEPTO OR PCONCEPTO IS NULL)
               and   TRUNC(a.fecha) between (PDESDE) and (PHASTA)
               and   d.encargado = e.codpers
               and   (d.encargado = PENCARGADO OR PENCARGADO IS NULL)
               and   (d.comentarios = PSEDE OR PSEDE IS NULL) 
               and   (d.grado = PGRADO OR PGRADO IS NULL)
            
             group by NVL(a.centro, a.carrera), d.encargado, e.nombre1||' '||
             e.nombre2 ||' '||e.apellido1||' '||e.apellido2,d.comentarios,
             b.codmovto, C.ENTIDAD, C.NOMBRE_CORTO, D.NOMBRE_CORTO;
             
END  REP_INGRESOSXFACULTAD;