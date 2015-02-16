/*
autor: KEVIN HERRERA
Fecha: 08/05/2014
Descripcion: Funcion que devuleve el total de un recibo por tipo de 
             transaccion y emisor.
*/
 FUNCTION RINGRESOSTIPOPAGO2
(
  PFECHAINI    DBAFISICC.CCTRANSACCTB.FECHA%type,
  PFECHAFIN    DBAFISICC.CCTRANSACCTB.FECHA%type,
  ptipo        dbafisicc.CCTRANSACCTB.tipo%type,
  ptipopago    varchar2,
  PEMISOR      varchar2,
  PCARRERA     DBAFISICC.CCTRANSACCTB.CARRERA%type
) 
   return number is
     VMONTO number(15,2); 
   BEGIN
 
   	select SUM(a.MONTO) into VMONTO
      
      from dynamics.HINGRESOS_PAGO a, dbafisicc.cctransacctb b
      where b.fecha between pfechaini and pfechafin
      and nvl(b.carrera,'IV') = pcarrera
      and to_char(b.numero) = a.recibo
      and (b.tipo = ptipo)
      and a.TIPOPAGO = PTIPOPAGO
      and (DECODE(a.EMISOR, 'INDUSTRIAL', 'BI', '712', 712, '718', 718 , null)= 
           pemisor OR pemisor is null)
      and nvl(b.flagoperado,'O') != 'A'
      and a.RECIBO not in (select RECIBO 
                                from DBAFISICC.CCRECIBOSTB 
                                where nvl(flagoperado,'O') = 'A');
         
    return(VMONTO);  
    
    END RINGRESOSTIPOPAGO2;