*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------&*
*& REPORT ZMM_CM_SALIDAMERC.                                           &*
*&---------------------------------------------------------------------&*
*& Cliente            : Banmedica                                      &*
*& Consultora         : Seidor Crystalis                               &*
*& Desarrollador ABAP : Felipe Garcia Trujillo                         &*
*& Funcional          : Cristian Navarro                               &*
*& Fecha              : 27/03/2015                                     &*
*& Transporte         :                                                &*
*& Objetivo           : Impresión Guías de desapcho                    &*
*&----------------------------------------------------------------------&*
*&
*&---------------------------------------------------------------------*

REPORT  zmm_reimp_guiadespacho.

*--------------------------------------------------------------------*
* TYPES
*--------------------------------------------------------------------*
TYPE-POOLS: slis.
TYPE-POOLS vrm.

TYPES: BEGIN OF ty_alv ,
         check            TYPE c,
         mblnr            TYPE mseg-mblnr,
         mjahr            TYPE mseg-mjahr,
         zeile            TYPE mseg-zeile,
         werks             TYPE mseg-werks, " CENTRO
         kostl            TYPE mseg-kostl, "  Centro de costo
         zzunid_pro       TYPE mseg-zzunid_pro, "producto contable
         matnr             TYPE mseg-matnr,
         menge             TYPE mseg-menge,
         meins            TYPE mseg-meins,
         dmbtr             TYPE mseg-dmbtr,
         descrip_material TYPE makt-maktg,
         bwart            TYPE mseg-bwart,
         smbln            TYPE mseg-smbln,
         sjahr            TYPE mseg-sjahr,
         smblp            TYPE mseg-smblp,
       END OF ty_alv.
*--------------------------------------------------------------------*
* DATA
*--------------------------------------------------------------------*
DATA: gt_mkpf      TYPE STANDARD TABLE OF mkpf,
      gt_alv       TYPE STANDARD TABLE OF ty_alv,
      gs_alv       TYPE ty_alv,
      gt_registros TYPE STANDARD TABLE OF ty_alv,
      gt_detalle   TYPE STANDARD TABLE OF zmm_detalle_ins,
      gs_detalle   TYPE zmm_detalle_ins,
      x_folio      TYPE mseg-zznfolio.

DATA: cia           TYPE mseg-bukrs,
      lv_bukrs_name TYPE t880-name1,
      lv_rut        TYPE t001z-paval,
      lv_nombre     TYPE csks-name1,
      lv_calle      TYPE csks-stras,
      lv_ciudad     TYPE csks-ort01,
      lv_dia(2),
      lv_mes(10),
              n(3)          TYPE n,
      n1(3)         TYPE n,
      n2(3)         TYPE n,
      n3(3)         TYPE n,
      n4(3)         TYPE n,
      nocentro(1)   TYPE c,
      valor         TYPE vrm_value,
      lv_anio(4).

DATA lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE.

DATA: name  TYPE vrm_id,
      list  TYPE vrm_values,
      value LIKE LINE OF list.

TABLES: zmm_bitacora_gd, csks,
        zdireccguia.

" Variables ALV
*"Catalogo de campos

*DATA: l_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE,
*      l_layout TYPE slis_layout_alv,


DATA: l_fieldcat TYPE lvc_t_fcat,
      l_layout   TYPE lvc_s_layo,
      l_repid    LIKE sy-repid.

DATA:  wa_fieldcat TYPE lvc_s_fcat.
*CLEAR l_fieldcat.

DATA: p_num          TYPE mseg-zznfolio,
      okcode         TYPE okcode,
      gv_mensaje(80).

DATA: BEGIN OF t_dir OCCURS 0,
        sec    LIKE zdireccguia-correl,
        calle  LIKE csks-stras,
        ciudad LIKE csks-ort01,
      END OF t_dir.


*--------------------------------------------------------------------*
* SELECTION-SCREEN
*--------------------------------------------------------------------*
*SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-001.
PARAMETERS: lv_bukrs    LIKE bkpf-bukrs OBLIGATORY .  " Sociedad
PARAMETERS: p_coste TYPE mseg-kostl     OBLIGATORY.               " Centro de coste
PARAMETERS: p_folio TYPE mseg-zznfolio  OBLIGATORY.               " Folio

*SELECTION-SCREEN END OF BLOCK b01.

*--------------------------------------------------------------------*
* Pàrametro de direccion
*--------------------------------------------------------------------*
PARAMETERS: p_list TYPE num03   AS LISTBOX VISIBLE LENGTH 60.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

AT SELECTION-SCREEN ON lv_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD lv_bukrs.
  IF sy-subrc <> 0.
    MESSAGE e526(icc_tr) WITH lv_bukrs.
  ENDIF.

AT SELECTION-SCREEN ON p_coste.
  REFRESH lt_dynpfields.
  lt_dynpfields-fieldname = 'LV_BUKRS'.
  APPEND lt_dynpfields.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = 'ZMM_REIMP_GUIADESPACHO'
      dynumb             = '1000'
      translate_to_upper = 'X'
    TABLES
      dynpfields         = lt_dynpfields.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
  SORT lt_dynpfields .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
  READ TABLE lt_dynpfields INDEX 1.
  lv_bukrs = lt_dynpfields-fieldvalue .
  TRANSLATE lv_bukrs TO UPPER CASE.
  REFRESH lt_dynpfields.

  lt_dynpfields-fieldname = 'P_COSTE'.
  APPEND lt_dynpfields.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = 'ZMM_REIMP_GUIADESPACHO'
      dynumb             = '1000'
      translate_to_upper = 'X'
    TABLES
      dynpfields         = lt_dynpfields.

*ReSQ: No Need Of Change Internal Table LT_DYNPFIELDS Already Sorted
  READ TABLE lt_dynpfields INDEX 1.
  p_coste = lt_dynpfields-fieldvalue .
  TRANSLATE p_coste TO UPPER CASE.
  REFRESH lt_dynpfields.

  name     = 'P_LIST'.
  n        = 0.
  n1       = 0.
  n2       = 0.
  n3       = 0.
  n4       = 0.
  CLEAR p_list.
  REFRESH list.

  nocentro = 'S'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*    FROM csks
*    WHERE kostl EQ p_coste.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
    FROM csks
    WHERE kostl EQ p_coste ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
    CONCATENATE csks-stras '---' csks-ort01 INTO value-text.
*    value-text = '---'.                   " para probar
    IF value-text <> '---'.
      value-key = '000'.
      n4       = 1.
      APPEND value TO list.
    ENDIF.
  ELSE.
    nocentro = 'N'.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zdireccguia
*    WHERE bukrs = lv_bukrs
*      AND kostl = p_coste.
*
* NEW CODE
  SELECT *
 FROM zdireccguia
    WHERE bukrs = lv_bukrs
      AND kostl = p_coste ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    n3 = n3 + 1.
    CONCATENATE zdireccguia-stras '---' zdireccguia-ort01 INTO value-text.
    IF n3 = 1 AND n4 = 0.
      n2 = zdireccguia-correl.
    ENDIF.

    value-key = zdireccguia-correl.
    APPEND value TO list.
  ENDSELECT.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_LIST'
      values          = list
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

* INITIALIZATION.
  IF n4 = 1.
    p_list = '000'.
  ELSE.
    p_list = n2.
  ENDIF.

START-OF-SELECTION.

  IF nocentro = 'N'.
    MESSAGE i016(z1) WITH 'Error Centro Costo no existe'.
  ELSE.
    IF lv_bukrs <> csks-bukrs.
      MESSAGE i016(z1) WITH 'Centro es de otra sociedad'.
    ELSE.
      IF p_list = '0' AND NOT  csks-stras IS INITIAL.
        lv_calle  = csks-stras.
        lv_ciudad = csks-ort01.
      ELSE.

        n1 = p_list.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT  SINGLE * FROM zdireccguia
*          WHERE bukrs = lv_bukrs
*          AND kostl = p_coste
*          AND correl = n1.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM zdireccguia
          WHERE bukrs = lv_bukrs
          AND kostl = p_coste
          AND correl = n1 ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc = 0.
          lv_calle  = zdireccguia-stras.
          lv_ciudad = zdireccguia-ort01.
        ENDIF.
      ENDIF.
      IF lv_calle = ' '.
        MESSAGE i016(z1) WITH 'DEBE SELECCIONAR UNA DIRECCION'.
      ELSE.
*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE bukrs INTO cia
*        FROM mseg   WHERE zznfolio EQ p_folio
*        AND  kostl  EQ p_coste.
*
* NEW CODE
        SELECT bukrs
        UP TO 1 ROWS  INTO cia
        FROM mseg   WHERE zznfolio EQ p_folio
        AND  kostl  EQ p_coste ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE zznfolio INTO x_folio
*        FROM mseg
*        WHERE zznfolio EQ p_folio AND bukrs = cia.
*
* NEW CODE
        SELECT zznfolio
        UP TO 1 ROWS  INTO x_folio
        FROM mseg
        WHERE zznfolio EQ p_folio AND bukrs = cia ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF x_folio IS  INITIAL. " si existe.
          CLEAR: x_folio.
          MESSAGE i016(z1) WITH 'El numero de folio ingresado no existe'.
        ELSE.
          PERFORM seleccion_datos.
          IF gt_alv[] IS NOT INITIAL.
            PERFORM mostrar_alv.
          ELSE.
            MESSAGE i016(z1) WITH 'No existen datos para los parametros seleccionados'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  seleccion_datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM seleccion_datos.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT mblnr mjahr zeile werks kostl zzunid_pro matnr menge meins dmbtr bwart smbln sjahr smblp INTO CORRESPONDING FIELDS OF TABLE gt_alv
*  FROM mseg   WHERE zznfolio EQ p_folio
*  AND  kostl  EQ p_coste.
*
* NEW CODE
  SELECT mblnr mjahr zeile werks kostl zzunid_pro matnr menge meins dmbtr bwart smbln sjahr smblp
 INTO CORRESPONDING FIELDS OF TABLE gt_alv
  FROM mseg   WHERE zznfolio EQ p_folio
  AND  kostl  EQ p_coste ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  LOOP AT gt_alv INTO gs_alv.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE maktg INTO gs_alv-descrip_material
*    FROM makt
*    WHERE matnr EQ gs_alv-matnr.
*
* NEW CODE
    SELECT maktg
    UP TO 1 ROWS  INTO gs_alv-descrip_material
    FROM makt
    WHERE matnr EQ gs_alv-matnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    MODIFY gt_alv FROM gs_alv INDEX  sy-tabix.

  ENDLOOP.

ENDFORM.                    "seleccion_datos


*&---------------------------------------------------------------------*
*&      Form  build_cat
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM build_cat.
  "flag
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'CHECK'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-checkbox = 'X'.
  wa_fieldcat-edit     = 'X'.
*  wa_fieldcat-input    = 'X'.
  wa_fieldcat-no_out   = 'X'.
* l_fieldcat-outputlen  = 2.
  APPEND wa_fieldcat TO l_fieldcat.

  "Doc. material
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'MBLNR'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-coltext  = 'Doc.Material'.
  APPEND wa_fieldcat TO l_fieldcat.

  "Centro coste
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'WERKS'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-coltext  = 'Centro'.
  APPEND wa_fieldcat TO l_fieldcat.
*
*  Producto contable
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'ZZUNID_PRO'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-coltext  = 'Producto Contable'.
  wa_fieldcat-no_zero = 'X'.
  wa_fieldcat-just    = 'R'.
  APPEND wa_fieldcat TO l_fieldcat.

  "material
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'MATNR'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-coltext  = 'Material'.
  wa_fieldcat-no_zero = 'X'.
  APPEND wa_fieldcat TO l_fieldcat.

  "descripo material
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'DESCRIP_MATERIAL'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-coltext  = 'Descripción'.
  wa_fieldcat-no_zero = 'X'.
  APPEND wa_fieldcat TO l_fieldcat.

  "Cantidad
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'MENGE'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-coltext  = 'Cantidad'.
  wa_fieldcat-decimals = 0.
  APPEND wa_fieldcat TO l_fieldcat.
*
*  unidad de medida
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'MEINS'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-coltext  = 'Unidad de medida'.
  wa_fieldcat-just    = 'R'.
  wa_fieldcat-convexit = 'CUNIT'.
  APPEND wa_fieldcat TO l_fieldcat.

* IMPORTE
  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname  = 'DMBTR'.
  wa_fieldcat-tabname  = 'GT_ALV'.
  wa_fieldcat-coltext  = 'Importe'.
  wa_fieldcat-currency = 'CLP'.
  APPEND wa_fieldcat TO l_fieldcat.


ENDFORM.                    "BUILD_CAT
*&---------------------------------------------------------------------*
*&      Form  layout_cat
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*

FORM layout_cat.
  " Mediante esta estructura podemos definir el formato de salida

  l_layout-box_fname = 'CHECK'.
*  l_layout-box_tabname   = 'GT_ALV'.
  l_layout-cwidth_opt  = 'X'.
  l_layout-zebra = 'X'.
*

ENDFORM.                    "LAYOUT_CAT

*&---------------------------------------------------------------------*
*&      Form  dislplay_cat
*&---------------------------------------------------------------------*  "-------------------------------------------------------------------------
FORM display_cat.

  DATA: i_grid_settings TYPE lvc_s_glay.
  i_grid_settings-edt_cll_cb = 'X'.         "Para editar la tabla

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_interface_check        = 'X'
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_grid_title             = ''
      is_layout_lvc            = l_layout
      it_fieldcat_lvc          = l_fieldcat
      i_grid_settings          = i_grid_settings
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "DISPLAY_CAT


*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE  sy-ucomm
                        rs_selfield TYPE  slis_selfield.

  DATA: lv_reg TYPE i.

*   rs_selfield-refresh = 'X'.
  CASE sy-ucomm.
*   Imprimir
    WHEN '&IMPRIMIR'.
      CLEAR: gs_alv, gt_registros, lv_reg.

      LOOP AT gt_alv INTO gs_alv .
        APPEND  gs_alv TO gt_registros.
      ENDLOOP.

      DESCRIBE TABLE gt_registros LINES lv_reg.

      IF gs_alv IS INITIAL.
        MESSAGE 'Sin informacion para re-imprimir' TYPE 'E'.
      ELSEIF  lv_reg GT 24.
        MESSAGE 'Puede seleccionar hasta 24 registros por instruccion de despacho' TYPE 'E'.
      ENDIF.

      CALL SELECTION-SCREEN 1002 STARTING AT 20 5.
  ENDCASE.

  rs_selfield-refresh = 'X'.

ENDFORM.                    " USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  STATUS_1100
*&---------------------------------------------------------------------*

FORM set_status USING rt_extab TYPE slis_t_extab.
*--------------------------------------------------------------------- *
  SET PF-STATUS 'STANDARD'  EXCLUDING rt_extab.

ENDFORM.                    "BOTONES

*&---------------------------------------------------------------------*
*&      Form  datos_impresion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM datos_impresion.

  " CABECERA

  " FECHA
  lv_dia = sy-datum+6(2).
  lv_mes = sy-datum+4(2).
  lv_anio = sy-datum+0(4).

  CASE lv_dia.
    WHEN '01'.
      lv_dia = '1'.
    WHEN '02'.
      lv_dia = '2'.
    WHEN '03'.
      lv_dia = '3'.
    WHEN '04'.
      lv_dia = '4'.
    WHEN '05'.
      lv_dia = '5'.
    WHEN '06'.
      lv_dia = '6'.
    WHEN '07'.
      lv_dia = '7'.
    WHEN '08'.
      lv_dia = '8'.
    WHEN '09'.
      lv_dia = '9'.
  ENDCASE.

  CASE lv_mes.
    WHEN '01'.
      lv_mes = 'Enero'.
    WHEN '02'.
      lv_mes = 'Febrero'.
    WHEN '03'.
      lv_mes = 'Marzo'.
    WHEN '04'.
      lv_mes = 'Abril'.
    WHEN '05'.
      lv_mes = 'Mayo'.
    WHEN '06'.
      lv_mes = 'Junio'.
    WHEN '07'.
      lv_mes = 'Julio'.
    WHEN '08'.
      lv_mes = 'Agosto'.
    WHEN '09'.
      lv_mes = 'Septiembre'.
    WHEN '10'.
      lv_mes = 'Octubre'.
    WHEN '11'.
      lv_mes = 'Noviembre'.
    WHEN '12'.
      lv_mes = 'Diciembre'.

  ENDCASE.

* SELECT SINGLE bukrs name1 stras ort01 INTO (lv_bukrs, lv_nombre, lv_calle, lv_ciudad)
*  FROM csks
*  WHERE kostl EQ p_coste.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE bukrs name1 INTO (lv_bukrs, lv_nombre)
*  FROM csks
*  WHERE kostl EQ p_coste.
*
* NEW CODE
  SELECT bukrs name1
  UP TO 1 ROWS  INTO (lv_bukrs, lv_nombre)
  FROM csks
  WHERE kostl EQ p_coste ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*&---------------------------------------------------------------------*

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE name1 INTO lv_bukrs_name
*   FROM t880
*    WHERE rcomp EQ lv_bukrs.
*
* NEW CODE
  SELECT name1
  UP TO 1 ROWS  INTO lv_bukrs_name
   FROM t880
    WHERE rcomp EQ lv_bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE paval INTO lv_rut
*   FROM t001z
*   WHERE bukrs EQ lv_bukrs.
*
* NEW CODE
  SELECT paval
  UP TO 1 ROWS  INTO lv_rut
   FROM t001z
   WHERE bukrs EQ lv_bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  " DETALLE

  LOOP AT gt_alv INTO gs_alv.

    " CANTIDAD
    gs_detalle-zcantidad = gs_alv-menge.
*      CONCEPTO
*        SELECT SINGLE maktg INTO gs_detalle-zconcepto1
*         FROM makt
*         WHERE matnr EQ gs_Alv-matnr.
    gs_detalle-zconcepto1 = gs_alv-descrip_material.

    CONDENSE gs_detalle-zconcepto1.

    gs_detalle-zconcepto2 = gs_alv-zzunid_pro.
    gs_detalle-zprecio_un = gs_alv-dmbtr / gs_alv-menge.

    APPEND gs_detalle TO gt_detalle.
    CLEAR gs_detalle.

  ENDLOOP.

ENDFORM.                    "datos_impresion

*&---------------------------------------------------------------------*
*&      Form  impresion_smartforms
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM impresion_smartforms.

  DATA: gv_num_spool    TYPE tsp01-rqident,
        gv_char_num(12).

  DATA: l_funcion TYPE rs38l_fnam.
  DATA: ls_control_param    TYPE ssfctrlop.
  DATA: ls_composer_param   TYPE ssfcompop.
  DATA: lf_fm_name          TYPE rs38l_fnam.

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = 'ZMM_IMP_GDESPACHO'  "Nombre del formulario
    IMPORTING
      fm_name            = l_funcion "Modulo funcion que ejecutra el smartforms
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*  ASIGNA PARAMETROS DE CONTROL
*    ls_control_param-device     = 'ZLMT'.
*    ls_control_param-no_dialog  = ' '. "'X'.
  ls_control_param-langu      = sy-langu.
  ls_composer_param-tdcopies  = 001.
*    ls_composer_param-tddest    = ls_zmii_ip_maquina-padest.  "'DEVO'. "'ZLMT'.
*    ls_composer_param-tdprinter = ls_zmii_ip_maquina-tidisp.  "'SAPWIN'.
  ls_composer_param-tdsenddate = sy-datum.
  ls_composer_param-tdsendtime = sy-uzeit.
  ls_composer_param-tdnewid    = 'X'.
  "ls_composer_param-tdimmed   = 'X'.

  CONDENSE lv_mes.
*  *se ejecuta la funcion para llamar el smartforms.
  CALL FUNCTION l_funcion
    EXPORTING    " Se detallan los campos que se quieren enviar al smartforms
      control_parameters = ls_control_param
      output_options     = ls_composer_param
      user_settings      = space
      p_rut              = lv_rut
      p_nombre           = lv_nombre
      p_calle            = lv_calle
      p_ciudad           = lv_ciudad
      p_num              = p_num
      p_bukrs_name       = lv_bukrs_name
      p_dia              = lv_dia
      p_mes              = lv_mes
      p_anio             = lv_anio
    TABLES      " la tabla interna definida
      gt_detalle         = gt_detalle
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

  IF sy-subrc EQ 0.

    LOOP AT gt_alv INTO gs_alv .

      UPDATE mseg SET zznfolio = p_num
         WHERE mblnr EQ  gs_alv-mblnr
           AND mjahr EQ  gs_alv-mjahr
           AND zeile EQ  gs_alv-zeile
           AND bukrs EQ  cia.

      IF sy-subrc EQ 0. " lo borro de mi alv

        DELETE gt_alv  WHERE mblnr EQ gs_alv-mblnr
                         AND mjahr EQ gs_alv-mjahr
                         AND zeile EQ gs_alv-zeile.
      ENDIF.

    ENDLOOP.

    COMMIT WORK.

*       SELECT SINGLE RQIDENT INTO gv_num_spool
*       FROM TSP01
*       WHERE RQCLIENT EQ  sy-mandt
**        AND RQ0NAME   EQ 'SMART'
*        AND RQ1NAME   EQ sy-uname.
**        AND RQCRETIME EQ SY-TSTUT.

    "  gv_char_num = gv_num_spool.
    "'N° SPOOL:' gv_char_num

    zmm_bitacora_gd-bukrs         = cia.
    zmm_bitacora_gd-folio_ant     = p_folio.
    zmm_bitacora_gd-folio_nue     = p_num.
    zmm_bitacora_gd-fecha_proceso = sy-datum.
    zmm_bitacora_gd-hora_proceso  = sy-uzeit.
    zmm_bitacora_gd-usuario       = sy-uname.
    INSERT zmm_bitacora_gd.

    CONCATENATE 'Se ha generado la impresion con N°FOLIO:' p_num INTO gv_mensaje SEPARATED BY space.
    CLEAR: lv_rut, lv_nombre, lv_calle, lv_ciudad, lv_bukrs_name, lv_dia,  lv_mes, lv_anio, gt_detalle[].

    MESSAGE gv_mensaje  TYPE 'S'.

  ELSE.
    MESSAGE 'Error al generar la impresion.' TYPE 'E'.
  ENDIF.

ENDFORM.                    "impresion_smartforms

*&---------------------------------------------------------------------*
*&      Form  mostrar_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM mostrar_alv.
  PERFORM build_cat.
  PERFORM layout_cat.
  PERFORM display_cat.
ENDFORM.                    "mostrar_log_alv
*&---------------------------------------------------------------------*
*&      Module  VALIDACION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validacion INPUT.

  DATA: lv_folio TYPE mseg-zznfolio.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE zznfolio INTO lv_folio
*    FROM mseg
*    WHERE zznfolio EQ p_num AND bukrs = cia.
*
* NEW CODE
  SELECT zznfolio
  UP TO 1 ROWS  INTO lv_folio
    FROM mseg
    WHERE zznfolio EQ p_num AND bukrs = cia ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF lv_folio IS NOT INITIAL. " si existe.
    CLEAR: lv_folio.
    MESSAGE 'El numero de folio ingresado ya existe.' TYPE 'E'.

  ENDIF.

ENDMODULE.                 " VALIDACION  INPUT
*&---------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  %_PF_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pf_status OUTPUT.

  SET PF-STATUS 'ZPOP_UP'.

ENDMODULE.                 " %_PF_STATUS  OUTPUT

*----------------------------------------------------------------------*
*  MODULE BOTON INPUT
*----------------------------------------------------------------------*

MODULE boton INPUT.

  CASE okcode.

    WHEN '&OK' OR ''.

      PERFORM datos_impresion.
      PERFORM impresion_smartforms.

    WHEN '&NO'.

      p_num = 0.

  ENDCASE.

ENDMODULE.                    "BOTON INPUT

*----------------------------------------------------------------------*
*  MODULE BUSCA_FOLIO OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE busca_folio OUTPUT.

  DATA: lv_prefolio TYPE mseg-zznfolio.

  SELECT SINGLE MAX( zznfolio ) INTO lv_prefolio
    FROM mseg WHERE bukrs = cia.

  p_num = lv_prefolio + 1.

ENDMODULE.                 " BUSCA_FOLIO  OUTPUT
