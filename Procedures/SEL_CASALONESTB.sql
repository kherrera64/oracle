/* 
Nombre: SEL_CASALONESTB 
Autor: Roberto Castro 
Fecha:  31/07/2012 
Package: PKG_DIGITALIZACION 
Descripcion: Devuelve los salones usados en la digitalizacion 

Modificacion: Autor: Kevin Herrera.
Fecha: 03/04/2014 
Descripcion: Se agregaron los campos Abreviatura y Nombre a la tabla 
             CASALONESTB por lo que se agregan tambien al select.

*/           
PROCEDURE SEL_CASALONESTB 
( 
     CurTabla   OUT T_CURSOR, 
     PSQLCODE   out number 
) 
IS 
BEGIN 
    OPEN CURTABLA FOR 
    
      SELECT S.TORRE, T.NOMBRETORRE, S.SALON, S.NOMBRE, S.ABREVIATURA, 
      S.CUPO, S.INTERNET, S.TIPOSALON, TS.DESCRIPCION, S.AREA, S.CORR_AUDIV, 
      S.MOD_CAN, S.PANTALLA, S.BOX_CABLES, S.BOX_CONTROLS, S.PROYECTOR, 
      S.MESAS_CANT, S.MESAS_DESC, S.SILLAS_CANT, S.SILLAS_DESC, S.PUPITRES_CANT, 
      S.PUPITRES_DESC, S.BANCOS_CANT, S.BANCOS_DESC, S.MESADIBUJO_CANT, 
      S.MESADIBUJO_DESC 
        
        FROM DBAFISICC.CASALONESTB S, DBAFISICC.CATIPOSALONTB TS, 
        DBAFISICC.CATORRESTB T 
        WHERE S.TIPOSALON = TS.TIPOSALON 
        AND  s.torre = t.codigotorre       
      ORDER BY S.TORRE, S.SALON; 
                      
      EXCEPTION 
           when others then 
           PSQLCODE   :=   SQLCODE;      
            OPEN CURTABLA FOR 
             SELECT * 
              FROM DUAL 
              WHERE 1 = 2; 
      
END SEL_CASALONESTB; 