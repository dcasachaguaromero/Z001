"Name: \PR:RAGITT_ALV01\FO:FILL_OUTTAB_LINE\SE:BEGIN\EI
ENHANCEMENT 0 ZRAGITT_ALV01.
* V1-CNN ECDK924990 21.03.2024: Corrige valor de los campos ANLUE y IZWEK para que cuando
* el activo fijo no tenga proveedor (LIFNR) tome estos datos de la ANLA

* INI - WALDO ALARCON - VISIONONE - 28-05-2021
  IF t086-srtvar EQ 'ZBAN'
* INI - PABLO GILBERT - VISIONONE - 13-06-2024
* PERMITE CLAVE CLASIF. CON DATOS DE REVALORIZACIÓN
  OR t086-srtvar EQ 'ZCRV'.
* FIN - PABLO GILBERT - VISIONONE - 13-06-2024
   DATA : lv_days  TYPE i,
          lv_month TYPE i,
          lv_year  TYPE i,
          lv_vumes TYPE zz_vumes,
          lv_vucon TYPE zz_vucon,
          lw_datos TYPE ci_repragitt,
          BEGIN OF lw_lfa1,
            lifnr TYPE lfa1-lifnr,
            name1 TYPE lfa1-name1,
            stcd1 TYPE lfa1-stcd1,
*
            anlue TYPE anla-anlue,
            izwek TYPE anla-izwek,
          END OF lw_lfa1.
**  OBTIENE DATOS DEL ACREEDOR
*   SELECT SINGLE lfa1~lifnr lfa1~name1 lfa1~stcd1 anlue izwek
*          INTO lw_lfa1
*          FROM anla INNER JOIN lfa1
*                    ON anla~lifnr EQ lfa1~lifnr
*                    WHERE bukrs EQ anlav-bukrs
*                     AND  anln1 EQ anlav-anln1
*                     AND  anln2 EQ anlav-anln1.
*
*   IF sy-subrc = 0.                     "V1-CNN ECDK924990 21.03.2024
*    SELECT SINGLE ord41 ord42 ord43 ord44 gdlgrp sernr INTO
*            (anlav-ord41, anlav-ord42, anlav-ord43, anlav-ord44, anlav-gdlgrp,
*             anlav-sernr )
*            FROM anla WHERE bukrs EQ anlav-bukrs
*                       AND  anln1 EQ anlav-anln1
*                       AND  anln2 EQ anlav-anln1.
**-> BEG INS V1-CNN ECDK924990 21.03.2024
*   ELSE.
*     SELECT SINGLE ord41 ord42 ord43 ord44 gdlgrp sernr anlue izwek INTO
*            (anlav-ord41, anlav-ord42, anlav-ord43, anlav-ord44, anlav-gdlgrp,
*             anlav-sernr, anlav-anlue, anlav-izwek )
*            FROM anla WHERE bukrs EQ anlav-bukrs
*                       AND  anln1 EQ anlav-anln1
*                       AND  anln2 EQ anlav-anln1.
*   ENDIF.
**-> END INS V1-CNN ECDK924990 21.03.2024
*
**--------- MUEVE DATOS DE LA ANLAV Y ANLB --------------------------
** denominacion activo fijo
*   ASSIGN COMPONENT 'ZZ_TXA50'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlav-txa50.
** descripcion activo fijo
*   ASSIGN COMPONENT 'ZZ_ANLHTXT'  OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlav-anlhtxt.
** Área de valoración real o derivada
*   ASSIGN COMPONENT 'ZZ_AFABER'   OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlb-afabe.
** Denominación del área de valoración
*   ASSIGN COMPONENT 'ZZ_AFBTXT'   OF STRUCTURE <itab_line> TO <field>.
*   <field> = t093t-afbtxt.
** Torre
*   ASSIGN COMPONENT 'ZZ_ORD41'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlav-ord41.
** Zona
*   ASSIGN COMPONENT 'ZZ_ORD42'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlav-ord42.
** Piso
*   ASSIGN COMPONENT 'ZZ_ORD43'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlav-ord43.
** Leasing
*   ASSIGN COMPONENT 'ZZ_ORD44'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlav-ord44.
** Número de serie
*   ASSIGN COMPONENT 'ZZ_SERNR'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlav-sernr.
**  Supranúmero de activo fijo
*   ASSIGN COMPONENT 'ZZ_ANLUE'    OF STRUCTURE <itab_line> TO <field>.
*
**-> BEG MOD V1-CNN ECDK924990 21.03.2024
*   IF NOT lw_lfa1-anlue IS INITIAL.
*     <field> = lw_lfa1-anlue. "ANLAV-ANLUE.
*   ELSE.
*     <field> = anlav-anlue.
*   ENDIF.
**  Destino de la inversión
*   ASSIGN COMPONENT 'ZZ_IZWEK'    OF STRUCTURE <itab_line> TO <field>.
*   IF NOT lw_lfa1-izwek IS INITIAL.
*     <field> = lw_lfa1-izwek. "ANLAV-IZWEK.
*   ELSE.
*     <field> = anlav-izwek.
*   ENDIF.
**-> END MOD V1-CNN ECDK924990 21.03.2024
*
**  ZPRODUCTO (Vida Integra)
*   ASSIGN COMPONENT 'ZZ_GDLGRP'   OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlav-gdlgrp.
** Fecha de inicio del cálculo de la amortización
*   ASSIGN COMPONENT 'ZZ_AFABG'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlb-afabg.
** Vida útil prevista en años
*   ASSIGN COMPONENT 'ZZ_NDJAR'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlb-ndjar.
** Valor residual del activo fijo
*   ASSIGN COMPONENT 'ZZ_SCHRW'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = anlb-schrw.
**----------------- MUEVE DATOS DE LECTURAS --------------------------
** Vida Util Meses
*   ASSIGN COMPONENT 'ZZ_VUMES'    OF STRUCTURE <itab_line> TO <field>.
*   <field>  = anlb-ndper + anlb-ndjar * 12.
*   lv_vumes = <field>.
** Vida útil Transcurridos Meses
*   ASSIGN COMPONENT 'ZZ_VUCON'    OF STRUCTURE <itab_line> TO <field>.
*   IF anlb-afabg IS INITIAL.
*     anlb-afabg = berdatum.
*   ENDIF.
*   IF anlb-afabg GT berdatum.
*     <field> = 0.
*   ELSE.
*     CALL FUNCTION 'FI_PSO_DAYS_MONTHS_YEARS_GET'
*       EXPORTING
*         i_date_from = anlb-afabg
*         i_date_to   = berdatum
*       IMPORTING
*         e_days      = lv_days
*         e_months    = lv_month
*         e_years     = lv_year.
*     <field> = lv_month.
*   ENDIF.
*   lv_vucon = <field>.
** Vida útil Restante Meses
*   ASSIGN COMPONENT 'ZZ_VURES'    OF STRUCTURE <itab_line> TO <field>.
*   IF lv_vumes GT lv_vucon.
*     <field> = lv_vumes - lv_vucon.
*   ELSE.
*     <field> = 0.
*   ENDIF.
** Descripción Clase
*   ASSIGN COMPONENT 'ZZ_TXK50'    OF STRUCTURE <itab_line> TO <field>.
*   SELECT SINGLE txk50 INTO <field>
*          FROM ankt WHERE spras EQ sy-langu
*                      AND anlkl EQ anlav-anlkl.
** Clave de moneda
*   ASSIGN COMPONENT 'ZZ_WAERS'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = t093b-waers.
** Número de identificación fiscal 1
*   ASSIGN COMPONENT 'ZZ_STCD1'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = lw_lfa1-stcd1.
** Razón Social Proveedor
*   ASSIGN COMPONENT 'ZZ_NAME1'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = lw_lfa1-name1.
** Informacion contable
*   CALL FUNCTION 'ZAF_RAGITT_ALV01_CONTABLE'
*     EXPORTING
*       i_anlav    = anlav
*       i_berdatum = berdatum
*     IMPORTING
*       zz_bldat   = lw_datos-zz_bldat
*       zz_budat   = lw_datos-zz_budat
*       zz_belnr   = lw_datos-zz_belnr
*       zz_gjahr   = lw_datos-zz_gjahr
*       zz_xblnr   = lw_datos-zz_xblnr.
** Fecha de documento en documento
*   ASSIGN COMPONENT 'ZZ_BLDAT'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = lw_datos-zz_bldat.
** Número de Factura
*   ASSIGN COMPONENT 'ZZ_XBLNR'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = lw_datos-zz_xblnr.
** Número de un documento contable
*   ASSIGN COMPONENT 'ZZ_BELNR'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = lw_datos-zz_belnr.
** Ejercicio
*   ASSIGN COMPONENT 'ZZ_GJAHR'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = lw_datos-zz_gjahr.
** Fecha de contabilización en el documento
*   ASSIGN COMPONENT 'ZZ_BUDAT'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = lw_datos-zz_budat.
**
*   CALL FUNCTION 'ZAF_RAGITT_ALV01_DEP_MES'
*     EXPORTING
*       i_anlcv    = anlcv
*       i_anlav    = anlav
*       i_anlb     = anlb
*       i_berdatum = berdatum
*     IMPORTING
*       zz_nafaz   = lw_datos-zz_nafaz.
*   ASSIGN COMPONENT 'ZZ_NAFAZ'    OF STRUCTURE <itab_line> TO <field>.
*   <field> = lw_datos-zz_nafaz.
*
*-------------------------------------------
   lw_datos-ZZ_TXA50    = anlav-txa50.
   lw_datos-ZZ_ANLHTXT  = anlav-anlhtxt.
   lw_datos-ZZ_AFABER   = anlb-afabe.
   lw_datos-ZZ_AFBTXT   = t093t-afbtxt.
   lw_datos-ZZ_SERNR    = anlav-sernr.
   lw_datos-ZZ_AFABG    = anlb-afabg.
   lw_datos-ZZ_NDJAR    = anlb-ndjar.
   lw_datos-ZZ_SCHRW    = anlb-schrw.
   lw_datos-ZZ_VUMES    = anlb-ndper + anlb-ndjar * 12.
   lv_vumes             = lw_datos-ZZ_VUMES.
   lw_datos-ZZ_WAERS    = t093b-waers.
*
   IF anlb-afabg IS INITIAL.
     anlb-afabg = berdatum.
   ENDIF.
   IF anlb-afabg GT berdatum.
     lw_datos-ZZ_VUCON = 0.
   ELSE.
     CALL FUNCTION 'FI_PSO_DAYS_MONTHS_YEARS_GET'
       EXPORTING
         i_date_from = anlb-afabg
         i_date_to   = berdatum
       IMPORTING
         e_days      = lv_days
         e_months    = lv_month
         e_years     = lv_year.
     lw_datos-ZZ_VUCON = lv_month.
   ENDIF.
   lv_vucon   = lw_datos-ZZ_VUCON.
* Vida útil Restante Meses
   IF lv_vumes GT lv_vucon.
     lw_datos-ZZ_VURES = lv_vumes - lv_vucon.
   ELSE.
     lw_datos-ZZ_VURES = 0.
   ENDIF.
   MOVE-CORRESPONDING lw_datos to <itab_line>.
*
   clear wa_zz_alv01.
   move :  ANLAV-BUKRS   to wa_zz_alv01-BUKRS,
           ANLAV-ANLN1   to wa_zz_alv01-ANLN1,
           ANLAV-ANLN2   to wa_zz_alv01-ANLN2,
           ANLAV-ANLKL   to wa_zz_alv01-ANLKL,
           BERDATUM      to wa_zz_alv01-BERDATUM,
           ANLB-AFABG    to wa_zz_alv01-AFABG,
           ANLCV-GJAHR   to wa_zz_alv01-GJAHR,
           ANLCV-AFABE   to wa_zz_alv01-AFABE,
           ANLCV-ZUJHR   to wa_zz_alv01-ZUJHR,
           ANLCV-ZUCOD   to wa_zz_alv01-ZUCOD,
           BERDATUM+4(2) TO wa_zz_alv01-PERAF.
   APPEND wa_zz_alv01 TO gt_zz_alv01.

 ENDIF.
*
* FIN - WALDO ALARCON - VISIONONE - 28-05-2021
ENDENHANCEMENT.
