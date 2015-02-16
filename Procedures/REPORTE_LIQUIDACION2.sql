/*
autor: Kevin Herrera
Fecha: 18/05/2014
Descripcion: El Procedimiento devuelve los datos necesarios para la impresion 
			 del reporte de Liquidacion por Centros Externos. 
*/
PROCEDURE REPORTE_LIQUIDACION2 
(
   PUSUARIO  DBAFISICC.TEMP_RINGRESOSTIPOPAGO.USUARIO%TYPE default null,
   RETVAL    OUT   SYS_REFCURSOR
) IS
BEGIN 
    open RETVAL for
              
       select CARRERA, ENCARGADO, NOMBRE, COMENTARIOS, 
              CODMOVTO, FACULTAD, FACNAME, PCT, CARNAME, DESMOVTO, R, NDT, NCT, 
              REFECTIVO, RCHEQUESBI, RCHEQUESOT, RTARJETAS, RMQSERIESAG, 
              RMQSERIESIN
          
          from DBAFISICC.TEMP_RINGRESOSTIPOPAGO
          where usuario = pusuario;
              
END REPORTE_LIQUIDACION2;