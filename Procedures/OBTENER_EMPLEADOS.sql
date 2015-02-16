/*
Nombre: OBTENER_EMPLEADOS
Autor: MIGUEL BARILLAS
Fecha:  04/04/2013
Package: DYNAMICS
Descripcion: Devuelve los empleados filtrando por los parametros
PCODIGO, PNOMBRE, PCODDEP, PEXTENSION  
Modificacion.
Autor: Kevin Herrera.
Descripcion: se agrego la funcion TRANSLATE() para poder comparar contra los
datos que poseen tildes.
*/
PROCEDURE OBTENER_EMPLEADOS
(
  PCODIGO     NVARCHAR2,
  PNOMBRE     NVARCHAR2,
  PCODDEP     NVARCHAR2,
  PEXTENSION  NVARCHAR2,
  RETVAL      OUT SYS_REFCURSOR
)
IS
BEGIN
 OPEN RETVAL FOR
SELECT et.EMPLID codigo, dpt.NAME Nombre, 'ADMINISTRATIVO' tipo,
       ET.TOWER TORRE, ET.OFFICE OFICINA, ET.EXTENSION EXTENSION, 
       ET.PICTUREID FOTOD, 
       DECODE(DPIOT.ORGANIZATIONUNITID,NULL,'PENDIENTE ASIGNAR',
       dpiot.ORGANIZATIONUNITID) CodDepa,
       DECODE(DPIOT.DESCRIPTION,NULL,'PENDIENTE ASIGNAR',DPIOT.DESCRIPTION) 
       DEPARTAMENTO, 'readimageDynamics.aspx?id='|| ET.PICTUREID FOTO
       
       FROM  dynamics.EMPLTABLE et, dynamics.DIRPARTYTABLE dpt,
             dynamics.HRPPARTYPOSITIONTABLERELAT2226 hpptr, 
             dynamics.DIRPARTYINTERNALORGANIZATI2216 dpiot,
             dynamics.PAYROLLEMPLPERPAYROLL prepp
             WHERE
                   ROWNUM <= 20    
               AND et.PARTYID = dpt.PARTYID
               AND hpptr.REFERENCE (+)= (et.EMPLID)
               AND hpptr.DATAAREAID (+)= 'ug'
               AND trunc(hpptr.VALIDFROMDATETIME (+))<= trunc (SYSDATE)
               AND trunc(hpptr.VALIDTODATETIME (+)) >= trunc (SYSDATE)
               AND dpiot.ORGANIZATIONUNITID (+)= hpptr.ORGANIZATIONUNITID
               AND dpiot.DATAAREAID (+)= 'ug'
               AND trunc (dpiot.VALIDFROMDATETIME (+))<= trunc (SYSDATE)
               AND trunc (dpiot.VALIDTODATETIME (+))>= trunc (SYSDATE)
               AND prepp.EMPLID (+)= et.EMPLID
               AND prepp.DATAAREAID (+)= 'ug'
               AND et.DATAAREAID = 'ug'	
               AND dpt.DATAAREAID = 'ug'
               AND ((PCODIGO is null) or  (et.EMPLID =PCODIGO))
               AND ((PNOMBRE IS NULL) OR (TRANSLATE(UPPER(DPT.NAME), 
                    '¡…Õ”⁄¿»Ã“ŸƒÀœ÷‹¬ Œ‘€', 'AEIOUAEIOUAEIOUAEIOU')
               LIKE TRANSLATE(UPPER('%' || PNOMBRE || '%'), 
                     '¡…Õ”⁄¿»Ã“ŸƒÀœ÷‹¬ Œ‘€', 'AEIOUAEIOUAEIOUAEIOU')))
               AND ((PCODDEP IS NULL) OR  
                    (dpiot.ORGANIZATIONUNITID like '%' || PCODDEP || '%'  ))
               AND ((PEXTENSION is null) or  (et.EXTENSION = PEXTENSION))	
               AND prepp.PAYROLLID in ('04','01','03')		--[Codigo de NÛmina]
               AND et.STATUS = 1
group by et.EMPLID,et.BIRTHDATE,et.PICTUREID,dpt.NAME,dpiot.DESCRIPTION, 
         dpiot.DESCRIPTION, et.TOWER, et.OFFICE, et.EXTENSION, 
         DPIOT.ORGANIZATIONUNITID;
End Obtener_Empleados;