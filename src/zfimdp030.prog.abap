*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Modulpool         ZFIMDP001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
PROGRAM  zfimdp030 MESSAGE-ID z001.
TABLES: zpayr, bkpf, payr, tbtco, zjdatos_edocheq, reguh,regup.
RANGES: t_cta FOR bseg-hkont.
TYPE-POOLS: slis.
FIELD-SYMBOLS: <f>, <f1>.
DATA jobcount LIKE tbtcjob-jobcount.
DATA: messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA: return LIKE   bapiret2 OCCURS 0 WITH HEADER LINE.
DATA: t_rpt(1) TYPE c.
DATA: fechacontab LIKE sy-datum.

data bukrs_aux like bkpf-bukrs.
data HKONT_aux like bseg-HKONT.

DATA : BEGIN OF tab OCCURS 0,
         fcode LIKE rsmpe-func,
       END OF tab.

DATA: g_repid LIKE sy-repid,
gs_print            TYPE slis_print_alv,
gt_list_top_of_page TYPE slis_t_listheader,
gt_events           TYPE slis_t_event,
gt_sort             TYPE slis_t_sortinfo_alv,
gs_layout           TYPE slis_layout_alv,
gt_fieldcat         TYPE slis_t_fieldcat_alv,
gt_filter           TYPE slis_t_filter_alv,
ls_filter           TYPE slis_filter_alv,
fieldcat_ln LIKE LINE OF gt_fieldcat,
col_pos TYPE i,
SW_BI(01) type c.

DATA: itfilter  TYPE slis_t_filter_alv WITH HEADER LINE.

DATA ls_toolbar TYPE stb_button.
DATA g_little(40)   TYPE c.
DATA: v_xblnr LIKE bkpf-xblnr.

DATA: BEGIN OF itab,
  field1(5) TYPE c,
  field2(5) TYPE c,
  field3(5) TYPE p DECIMALS 2,
END OF itab.

DATA: BEGIN OF itab1 OCCURS 0.
        INCLUDE STRUCTURE itab.
DATA: END OF itab1.

DATA: BEGIN OF itab_fieldcat OCCURS 0.
        INCLUDE STRUCTURE itab.
DATA: END OF itab_fieldcat.

DATA: BEGIN OF t_control OCCURS 0,
    juego LIKE tbtco-jobname,
    chect LIKE payr-chect,
     END OF t_control.

DATA  slis_t_filter_alv.
SELECTION-SCREEN BEGIN OF SCREEN 0101 AS SUBSCREEN.
SELECT-OPTIONS: psel FOR zpayr-chect,
                pfepag FOR payr-zaldt.
SELECTION-SCREEN END OF SCREEN 0101.

DATA: BEGIN OF t_ok OCCURS 0,
  box(1),
  bukrs LIKE  bseg-bukrs,
  belnr LIKE  bseg-belnr,
  buzei LIKE  bseg-buzei,
  gjahr LIKE  bseg-gjahr,
  hkont LIKE  bseg-hkont,
  status LIKE icon-id,
  chek1(1) TYPE c,
  wrbtr LIKE bseg-wrbtr,
  waers LIKE bkpf-waers,
  chect LIKE  payr-chect,
  hkontd LIKE  bseg-hkont, " se deja cuenta de destino.
  sgtxt  LIKE  bseg-sgtxt, " TEXTO
  datev  TYPE i,
  estado(51) TYPE c,
  vblnr  LIKE  payr-vblnr,
  bldat  LIKE  bkpf-bldat,
  lifnr  LIKE  payr-lifnr,
  budat  LIKE  bkpf-budat,
  zaldt  LIKE  payr-zaldt,
  znme1  LIKE  payr-znme1,
  zmote  LIKE  bseg-zzmot_emis,
  sortl  LIKE  lfa1-sortl,
  jdatos(16) TYPE c,
  nro(6) TYPE n,
* FCV - 29.07.2010  - Incluir agencia en la revalidación
  zagencia LIKE bseg-zz_agencia,
  zzdescr LIKE zagencia-zzdescr,
* fin FCV - 29.07.2010
  secuencia(6) TYPE n,
* FCV - 26.08.2010 - Incluir lote
  lote(16) TYPE c,
* fin FCV - 26.08.2010
END OF t_ok.

CONSTANTS: cntl_true TYPE i VALUE 1,
cntl_false TYPE i VALUE 0.
DATA:
h_picture TYPE REF TO cl_gui_picture,
h_pic_container TYPE REF TO cl_gui_custom_container,
g_datum LIKE sy-datum,
v_primera(1),
v_correlativo(4) TYPE n.

DATA: graphic_url(255),
graphic_refresh(1),
g_result LIKE cntl_true.

DATA: BEGIN OF graphic_table OCCURS 0,
line(255) TYPE x,
END OF graphic_table.

DATA: graphic_size TYPE i.
DATA: t_radio_01(1) TYPE c,
      t_radio_02(1) TYPE c.

DATA: user_command LIKE sy-ucomm,
      save_code    LIKE sy-ucomm.
DATA  hbkid        TYPE hbkid.
DATA  bukrs        TYPE bukrs.
DATA  hktid        TYPE hktid.
DATA  chect        TYPE chect.
DATA  des_cta(51)  TYPE c.
DATA  g_exis(1)    TYPE c.
DATA  errorfechacontab(1).
data agencia_aux(4) TYPE n.
data ZZMOT_EMIS_aux like bseg-ZZMOT_EMIS.
CONSTANTS g_desf(51) TYPE c VALUE 'Fecha Emisión de Cheque Posterior a Fecha Ejecución'.
DATA: g_valid_cta  TYPE i.

*- Tabla de parámetros pa' "submitir" el RSBDCSUB. -*
DATA: BEGIN OF i_tablsubm OCCURS 0.
        INCLUDE STRUCTURE rsparams.
DATA: END OF i_tablsubm.

DATA : group(30) TYPE c,
       lote(12),
       grupo LIKE apqi-groupid.
DATA : g_voidr TYPE payr-voidr.
DATA : g_bldat TYPE bldat.
DATA : g_newbs TYPE bbseg-newbs.
DATA : p_zmot_emis TYPE bseg-zzmot_emis,
       motemi TYPE bseg-zzmot_emis,
       juegodatos LIKE zjdatos_edocheq-jdatos.

DATA : g_v_fec_cont TYPE i.
DATA : p_message(50) TYPE c.
DATA: it_reversa LIKE zreversacheque OCCURS 0 WITH HEADER LINE.
DATA: p_ctareversa TYPE  bseg-hkont.
DATA: p_belnrant   TYPE  zreversacheque-belnr.
DATA: it_rf05r_acct LIKE rf05r_acct OCCURS 0 WITH HEADER LINE.

DATA: v_bschl LIKE bseg-bschl,
      aux(1).

*DATA: BEGIN OF T_CTAPRE OCCURS 0,
*        CTA LIKE  ZCTA_PRESCRIP-CUENTA_P,
*      END OF T_CTAPRE.

DATA : ti_zctap LIKE zcta_prescrip OCCURS 0 WITH HEADER LINE.

INCLUDE zbdcrecxy.
INCLUDE ZFIMDP030_2.
*INCLUDE zfimdp002.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  REFRESH tab.

  AUTHORITY-CHECK OBJECT 'Z_FITR007'
           ID 'TCODE' FIELD 'ZFITR007'
           ID 'ACTVT' FIELD 'Z1'.
  IF sy-subrc NE 0.
    MOVE 'PRO_01' TO tab-fcode.
    APPEND tab.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'Z_FITR007'
           ID 'TCODE' FIELD 'ZFITR007'
           ID 'ACTVT' FIELD 'Z2'.
  IF sy-subrc NE 0.
    MOVE 'PRO_02' TO tab-fcode.
    APPEND tab.
    MOVE 'PRO_03' TO tab-fcode.
    APPEND tab.
    MOVE 'PRO_04' TO tab-fcode.
    APPEND tab.
    MOVE 'PRO_05' TO tab-fcode.
    APPEND tab.
    MOVE 'PRO_06' TO tab-fcode.
    APPEND tab.
  ENDIF.


  AUTHORITY-CHECK OBJECT 'Z_FITR007'
         ID 'TCODE' FIELD 'ZFITR007'
         ID 'ACTVT' FIELD 'Z3'.
  IF sy-subrc NE 0.
    MOVE 'PRO_99' TO tab-fcode.
    APPEND tab.
  ENDIF.

  SET PF-STATUS 'ZZFIMDP001' EXCLUDING tab.
  SET TITLEBAR  'ZZFIMDP001'.

  PERFORM pantalla_sel.
  PERFORM load_image.
ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  LOAD_IMAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM load_image .
  DATA: l_graphic_xstr TYPE xstring,
 l_graphic_conv TYPE i,
 l_graphic_offs TYPE i.

  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object  = 'GRAPHICS'
      p_name    = 'CHEQUES' "Nombre de la imagen subida en sap SE78
      p_id      = 'BMAP'
      p_btype   = 'BCOL' "(BMON = Blanco y negro, BCOL = si es a color)
    RECEIVING
      p_bmp     = l_graphic_xstr
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.

* IF sy-subrc = 1.
* MESSAGE e287 WITH g_stxbitmaps-tdname.
* ELSEIF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
* WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
* EXIT.
* ENDIF.

  graphic_size = XSTRLEN( l_graphic_xstr ).
  CHECK graphic_size > 0.

  l_graphic_conv = graphic_size.
  l_graphic_offs = 0.

  WHILE l_graphic_conv > 255.
    graphic_table-line = l_graphic_xstr+l_graphic_offs(255).
    APPEND graphic_table.
    l_graphic_offs = l_graphic_offs + 255.
    l_graphic_conv = l_graphic_conv - 255.
  ENDWHILE.

  graphic_table-line = l_graphic_xstr+l_graphic_offs(l_graphic_conv).
  APPEND graphic_table.

  CALL FUNCTION 'DP_CREATE_URL'
  EXPORTING
  type = 'image'                                            "#EC NOTEXT
  subtype = cndp_sap_tab_unknown " 'X-UNKNOWN'
  size = graphic_size
  lifetime = cndp_lifetime_transaction "'T'
  TABLES
  data = graphic_table
  CHANGING
  url = graphic_url
  EXCEPTIONS
* dp_invalid_parameter = 1
* dp_error_put_table = 2
* dp_error_general = 3
  OTHERS = 4 .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  CREATE OBJECT h_pic_container
    EXPORTING
      container_name = 'T_IMAGEN_01'.
  CREATE OBJECT h_picture
    EXPORTING
      parent = h_pic_container.

  CALL METHOD h_picture->load_picture_from_url
    EXPORTING
      url    = graphic_url
    IMPORTING
      RESULT = g_result.
ENDFORM.                    " LOAD_IMAGE
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  save_code = user_command.

********************************************************************************************
* FCV - 08.08.2010
* Se revisa si ya existe algún usuario utilizando la transacción para el mismo banco y cuenta
********************************************************************************************
*  IF NOT save_code IS INITIAL.
*    IF v_empezando IS INITIAL.
*      SELECT SINGLE * INTO wa_bloqueo
*        FROM zbloqueo_estados
*        WHERE hbkid = hbkid     " Banco propio
*          AND hktid = hktid.    " Banco / Cuenta
*
*      IF sy-subrc EQ 0.
*        IF wa_bloqueo-uname <> sy-uname.
*          CONCATENATE 'Usuario:' wa_bloqueo-uname 'ya está usando aplicación, revisar.'
*              INTO wa_texto SEPARATED BY space.
*          MESSAGE wa_texto TYPE 'I'.
*          LEAVE TO SCREEN 0.
*        ENDIF.
*      ELSE.
** Se inserta registro en la tabla de control de bloqueo
*        wa_bloqueo-hbkid = hbkid.
*        wa_bloqueo-hktid = hktid.
*        wa_bloqueo-uname = sy-uname.
*        wa_bloqueo-fecha = sy-datum.
*        wa_bloqueo-hora = sy-timlo.
*        INSERT zbloqueo_estados FROM wa_bloqueo.
*        COMMIT WORK AND WAIT.
*      ENDIF.
*      v_empezando = 'X'.
*    ELSE.
*      IF save_code = 'CANCEL' OR save_code = 'BACK' OR save_code = 'EXIT'.
*        DELETE FROM zbloqueo_estados
*        WHERE hbkid = hbkid
*          AND hktid = hktid.
*        COMMIT WORK AND WAIT.
*      ENDIF.
*    ENDIF.
*  ENDIF.
********************************************************************************************
* fin FCV - 08.08.2010
********************************************************************************************

  SET PARAMETER ID 'FC' FIELD bkpf-budat.     " Se setea la fecha de contabilización

  CLEAR user_command.
  CASE save_code.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'GRUP_O1'.
      PERFORM pantalla_sel.
    WHEN 'PRO_01'.
      t_rpt = 'C'.
      g_newbs = '50'.

      IF bkpf-budat > sy-datum.
        MESSAGE 'Fecha de Contabilización no puede ser mayor a fecha de Hoy' TYPE 'E'.
      ENDIF.
***********************************************************************************
      PERFORM valid_fec_cont USING bukrs bkpf-budat
                             CHANGING g_v_fec_cont p_message.

      IF g_v_fec_cont EQ 1.
        MESSAGE p_message TYPE 'E'.
      ENDIF.

      IF g_v_fec_cont EQ 2.
        EXIT.
      ENDIF.
***************************************************************************************
      IF t_radio_02 EQ 'X'.
        REFRESH: t_ok.
        t_rpt = 'C'.
*        IF psel[] IS INITIAL.
*          MESSAGE 'Debe Ingresar Número de Cheque' TYPE 'E'.
*        ENDIF.
        PERFORM caduca_elec_indiv     TABLES psel
                                             t_ok
                                      USING bukrs hbkid hktid bkpf-budat.

        PERFORM reporte.

      ELSE.
        t_rpt = 'C'.
        PERFORM caduca_elec_masiv     TABLES psel
                                             t_ok
                                      USING bukrs hbkid hktid bkpf-budat.
*       PERFORM REPORTE.
        PERFORM ejec_mas.
*        PERFORM EJEC_SUBMIT .
      ENDIF.
    WHEN 'PRO_02'. " caduca fisico
      g_newbs = '50'.
      t_rpt = 'C'.
      IF bkpf-budat > sy-datum.
        MESSAGE 'Fecha de Contabilización no puede ser mayor a fecha de Hoy' TYPE 'E'.
      ENDIF.
***********************************************************************************
      PERFORM valid_fec_cont USING bukrs bkpf-budat
                             CHANGING g_v_fec_cont p_message.

      IF g_v_fec_cont EQ 1.
        MESSAGE p_message TYPE 'E'.
      ENDIF.

      IF g_v_fec_cont EQ 2.
        EXIT.
      ENDIF.

***************************************************************************************
      IF t_radio_02 EQ 'X'.
*        IF psel[] IS INITIAL.
*          MESSAGE 'Debe Ingresar Número de Cheque' TYPE 'E'.
*        ENDIF.
        REFRESH: t_ok.
        PERFORM caduca_fisic_indiv     TABLES psel
                                             t_ok
                                        USING bukrs hbkid hktid bkpf-budat.
        PERFORM reporte.
      ELSE.
*       Mensaje
        MESSAGE 'Opción no Valida para Caducado Físico' TYPE 'I'.
      ENDIF.
    WHEN 'PRO_03'. " Anulacion
      IF bkpf-budat > sy-datum.
        MESSAGE 'Fecha de Contabilización no puede ser mayor a fecha de Hoy' TYPE 'E'.
      ENDIF.
***********************************************************************************
      PERFORM valid_fec_cont USING bukrs bkpf-budat
                             CHANGING g_v_fec_cont p_message.

      IF g_v_fec_cont EQ 1.
        MESSAGE p_message TYPE 'E'.
      ENDIF.

      IF g_v_fec_cont EQ 2.
        EXIT.
      ENDIF.

***************************************************************************************
      IF t_radio_02 EQ 'X'.
        t_rpt = 'A'.
*        IF psel[] IS INITIAL.
*          MESSAGE 'Debe Ingresar Número de Cheque' TYPE 'E'.
*        ENDIF.
        REFRESH: t_ok.
        PERFORM anulacion_indiv     TABLES psel
                                           t_ok
                                        USING bukrs hbkid hktid bkpf-budat.
        PERFORM reporte.

      ELSE.
*       Mensaje
        MESSAGE 'Opción no Valida para Anulación' TYPE 'I'.
      ENDIF.

    WHEN 'PRO_04'. " preescribir
      t_rpt = 'C'.
*      g_newbs = '40'.
      g_newbs = '50'.
      IF bkpf-budat > sy-datum.
        MESSAGE 'Fecha de Contabilización no puede ser mayor a fecha de Hoy' TYPE 'E'.
      ENDIF.
***********************************************************************************
      PERFORM valid_fec_cont USING bukrs bkpf-budat
                             CHANGING g_v_fec_cont p_message.

      IF g_v_fec_cont EQ 1.
        MESSAGE p_message TYPE 'E'.
      ENDIF.

      IF g_v_fec_cont EQ 2.
        EXIT.
      ENDIF.

***************************************************************************************
* FCV - 22.04.2010 - Se permite que el proceso sea masivo o individual,
*                    mostrando la grilla siempre.
*      IF t_radio_02 EQ 'X'.
**             Mensaje
*        MESSAGE 'Opción no Valida para Prescripción' TYPE 'I'.
*
*
*      ELSE. " masivo
* fin FCV - 22.04.2010
      t_rpt = 'C'.
      REFRESH: t_ok.
      PERFORM prescripcion     TABLES psel
                                            t_ok
                                       USING bukrs hbkid hktid bkpf-budat.
* FCV - 22.04.2010
      PERFORM reporte.
*      PERFORM ejec_mas.
* fin FCV - 22.04.2010

*      ENDIF.

    WHEN 'PRO_05'. " revalidar
      t_rpt = 'C'.
      g_newbs = '50'.
      IF bkpf-budat > sy-datum.
        MESSAGE 'Fecha de Contabilización no puede ser mayor a fecha de Hoy' TYPE 'E'.
      ENDIF.
***********************************************************************************
      PERFORM valid_fec_cont USING bukrs bkpf-budat
                             CHANGING g_v_fec_cont p_message.

      IF g_v_fec_cont EQ 1.
        MESSAGE p_message TYPE 'E'.
      ENDIF.

      IF g_v_fec_cont EQ 2.
        EXIT.
      ENDIF.

***************************************************************************************
      IF t_radio_02 EQ 'X'.
        t_rpt = 'C'.
*        IF psel[] IS INITIAL.
*          MESSAGE 'Debe Ingresar Número de Cheque' TYPE 'E'.
*        ENDIF.
        REFRESH: t_ok.
        PERFORM revalidar     TABLES psel
                                             t_ok
                                        USING bukrs hbkid hktid bkpf-budat.
        PERFORM reporte.
      ELSE.
*       Mensaje
        MESSAGE 'Opción no Valida para Revalidar' TYPE 'I'.
      ENDIF.
      bkpf-budat = sy-datum.
    WHEN 'PRO_06'. " revalidar c/cheque nuevo
      IF bkpf-budat > sy-datum.
        MESSAGE 'Fecha de Contabilización no puede ser mayor a fecha de Hoy' TYPE 'E'.
      ENDIF.
***********************************************************************************
      PERFORM valid_fec_cont USING bukrs bkpf-budat
                             CHANGING g_v_fec_cont p_message.

      IF g_v_fec_cont EQ 1.
        MESSAGE p_message TYPE 'E'.
      ENDIF.

      IF g_v_fec_cont EQ 2.
        EXIT.
      ENDIF.

***************************************************************************************
      IF t_radio_02 EQ 'X'.
        t_rpt = 'A'.
*        IF psel[] IS INITIAL.
*          MESSAGE 'Debe Ingresar Número de Cheque' TYPE 'E'.
*        ENDIF.
        REFRESH: t_ok.
        PERFORM revalidarchnew     TABLES psel
                                           t_ok
                                        USING bukrs hbkid hktid bkpf-budat.
        PERFORM reporte.

      ELSE.
*       Mensaje
        MESSAGE 'Opción no Valida para Revalidación con Cheque Nuevo' TYPE 'I'.
      ENDIF.
* FCV - 21.04.2010
* Se deja inactiva la opción hasta que se pueda revisar la funcionalidad
* incorporada
*    WHEN 'PRO_07'. " Archivos masivos
*      PERFORM archivos_masivo.
* fin FCV - 21.04.2010
    WHEN 'PRO_08'. " Reverso de cheques.

      PERFORM valid_fec_cont USING bukrs bkpf-budat
                             CHANGING g_v_fec_cont p_message.

      IF g_v_fec_cont EQ 1.
        MESSAGE p_message TYPE 'E'.
      ENDIF.

      IF g_v_fec_cont EQ 2.
        EXIT.
      ENDIF.

      IF t_radio_02 EQ 'X'.
        t_rpt = 'R'.
*        IF psel[] IS INITIAL.
*          MESSAGE 'Debe Ingresar Número de Cheque' TYPE 'E'.
*        ENDIF.
        CLEAR t_ok.
        REFRESH: t_ok.
        PERFORM  zreverso_ch  TABLES psel
                                           t_ok
                                        USING bukrs hbkid hktid bkpf-budat.
        PERFORM reporte.
      ELSE.
*       Mensaje
        MESSAGE 'Opción no Valida para Revalidación con Cheque Nuevo' TYPE 'I'.
      ENDIF.

    WHEN 'PRO_99'. " Mantención tabla de motivos de prescripción
      CALL TRANSACTION 'ZRANGOS_PRESCRIBE'.

  ENDCASE.


ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  PANTALLA_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pantalla_sel.

* FCV - 21.04.2010
*  IF T_RADIO_01 EQ SPACE AND T_RADIO_02 EQ SPACE.
*    T_RADIO_01 = 'X'.
*  ENDIF.
*
*  LOOP AT SCREEN.
*    IF T_RADIO_01 EQ 'X'.
*      IF SCREEN-NAME EQ 'T_TEXT_05' OR SCREEN-NAME EQ 'CHECT'.
*        SCREEN-ACTIVE = 0.
*      ENDIF.
*    ELSE.
*      IF T_RADIO_02 EQ 'X'.
*        IF SCREEN-NAME EQ 'T_TEXT_05' OR SCREEN-NAME EQ 'CHECT'.
*          SCREEN-ACTIVE = 1.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.
  t_radio_02 = 'X'.
* fin FCV - 21.04.2010

  IF v_comienzo IS INITIAL.
    IF bkpf-budat EQ '00000000'.
      bkpf-budat = sy-datum.
    ENDIF.
    v_comienzo = 'X'.
  ELSE.
    IF p_budat <> '00000000'.
      bkpf-budat = p_budat.
      CLEAR p_budat.
    ENDIF.
  ENDIF.

ENDFORM.                    " PANTALLA_SEL
*&---------------------------------------------------------------------*
*&      Module  MODULE_MATCH2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE module_match2 INPUT.
  DATA:  dyfields2 LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA : BEGIN OF list_of_fields2 OCCURS 10,
  fieldname LIKE dd03l-fieldname,
  END OF list_of_fields2.


  DATA : indice2 LIKE sy-tabix,
  fieldname2 LIKE dd03l-fieldname,
  fields2 LIKE help_value OCCURS 10 WITH HEADER LINE,
  shrinkfields2 LIKE dynpread OCCURS 0 WITH HEADER LINE,
  dynpfields2 LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF ti_cheque OCCURS 0,
  zbukr LIKE payr-zbukr,
  hbkid LIKE payr-hbkid,
  hktid LIKE payr-hktid,
  chect LIKE payr-chect,
  END OF ti_cheque.

  REFRESH: dyfields2, list_of_fields2,fields2, shrinkfields2,dynpfields2.

  dyfields2-fieldname = 'BUKRS'.
  APPEND dyfields2.
  dyfields2-fieldname = 'HBKID'.
  APPEND dyfields2.
  dyfields2-fieldname = 'HKTID'.
  APPEND dyfields2.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = dyfields2.

  IF sy-subrc = 0.
    READ TABLE dyfields2 WITH KEY fieldname = 'BUKRS'.
    IF sy-subrc EQ 0.
      bukrs = dyfields2-fieldvalue.
    ENDIF.
    READ TABLE dyfields2 WITH KEY fieldname = 'HBKID'.
    IF sy-subrc EQ 0.
      hbkid = dyfields2-fieldvalue.
    ENDIF.
    READ TABLE dyfields2 WITH KEY fieldname = 'HKTID'.
    IF sy-subrc EQ 0.
      hktid = dyfields2-fieldvalue.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dyfields2
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
  IF sy-subrc <> 0.

  ENDIF.

  SELECT zbukr hbkid hktid chect
  INTO CORRESPONDING FIELDS OF TABLE ti_cheque
  FROM payr
  WHERE zbukr EQ bukrs
    AND hbkid EQ hbkid
    AND hktid EQ hktid.

  list_of_fields2-fieldname = 'T012K-BUKRS'.
  APPEND list_of_fields2.
  list_of_fields2-fieldname = 'T012K-HBKID'.
  APPEND list_of_fields2.
  list_of_fields2-fieldname = 'T012K-HKTID'.
  APPEND list_of_fields2.
  list_of_fields2-fieldname = 'PAYR-CHECT'.
  APPEND list_of_fields2.



  fieldname2 = 'CHECT'.
  CALL FUNCTION 'TRANSFER_NAMES_TO_FIELDS'
    EXPORTING
      selectfield        = fieldname2
    TABLES
      fields             = fields2
      namelist           = list_of_fields2
    EXCEPTIONS
      wrong_format_given = 01.


  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = fieldname2
      titel                        = 'Cuenta Corriente'
      use_user_selections          = 'S'
    IMPORTING
      ind                          = indice2
    TABLES
      fields                       = fields2
      full_table                   = ti_cheque
      user_sel_fields              = shrinkfields2
    EXCEPTIONS
      full_table_empty             = 01
      no_tablestructure_given      = 02
      no_tablefields_in_dictionary = 03
      more_than_one_selectfield    = 04
      no_electfield                = 05.
  IF sy-subrc = 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT TI_CHEQUE .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
    READ TABLE ti_cheque INDEX indice2.
    MOVE ti_cheque-chect TO chect.
  ENDIF.




ENDMODULE.                 " MODULE_MATCH  INPUT
*&---------------------------------------------------------------------*
*&      Module  MODULE_MATCH1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE module_match1 INPUT.
  DATA:  dyfields LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF list_of_fields1 OCCURS 10,
  fieldname LIKE dd03l-fieldname,
  END OF list_of_fields1.

  DATA : indice1 LIKE sy-tabix,
  fieldname1 LIKE dd03l-fieldname,
  fields1 LIKE help_value OCCURS 10 WITH HEADER LINE,
  shrinkfields1 LIKE dynpread OCCURS 0 WITH HEADER LINE,
  dynpfields1 LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF ti_cta_cte OCCURS 0,
  bukrs LIKE t012k-bukrs,
  hbkid LIKE t012k-hbkid,
  hktid LIKE t012k-hktid,
  END OF ti_cta_cte.

  REFRESH: dyfields, list_of_fields1,fields1, shrinkfields1,dynpfields1.

  dyfields-fieldname = 'BUKRS'.
  APPEND dyfields.
  dyfields-fieldname = 'HBKID'.
  APPEND dyfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = dyfields.

  IF sy-subrc = 0.
    READ TABLE dyfields WITH KEY fieldname = 'BUKRS'.
    IF sy-subrc EQ 0.
      bukrs = dyfields-fieldvalue.
    ENDIF.
    READ TABLE dyfields WITH KEY fieldname = 'HBKID'.
    IF sy-subrc EQ 0.
      hbkid = dyfields-fieldvalue.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dyfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
  IF sy-subrc <> 0.
  ENDIF.

* FCV - 21.04.2010
  TRANSLATE bukrs TO UPPER CASE.
  TRANSLATE hbkid TO UPPER CASE.
* fin FCV - 21.04.2010
  SELECT bukrs hbkid hktid
    INTO CORRESPONDING FIELDS OF TABLE ti_cta_cte
    FROM t012k
    WHERE bukrs EQ bukrs
      AND hbkid EQ hbkid.

  list_of_fields1-fieldname = 'T012K-BUKRS'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'T012K-HBKID'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'T012K-HKTID'.
  APPEND list_of_fields1.

  fieldname1 = 'HKTID'.

  CALL FUNCTION 'TRANSFER_NAMES_TO_FIELDS'
    EXPORTING
      selectfield        = fieldname1
    TABLES
      fields             = fields1
      namelist           = list_of_fields1
    EXCEPTIONS
      wrong_format_given = 01.


  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = fieldname1
      titel                        = 'Cuenta Corriente'
      use_user_selections          = 'S'
    IMPORTING
      ind                          = indice1
    TABLES
      fields                       = fields1
      full_table                   = ti_cta_cte
      user_sel_fields              = shrinkfields1
    EXCEPTIONS
      full_table_empty             = 01
      no_tablestructure_given      = 02
      no_tablefields_in_dictionary = 03
      more_than_one_selectfield    = 04
      no_electfield                = 05.
  IF sy-subrc = 0.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT TI_CTA_CTE .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
    READ TABLE ti_cta_cte INDEX indice1.
    MOVE ti_cta_cte-hktid TO hktid.

    SET PARAMETER ID '01' FIELD  ti_cta_cte-bukrs.
    SET PARAMETER ID '02' FIELD  ti_cta_cte-hbkid.
    SET PARAMETER ID '03' FIELD  ti_cta_cte-hktid.
  ENDIF.
ENDMODULE. " MODULE_MATCH1  INPUT
*&---------------------------------------------------------------------*
*&      Module  TCC_MODIFY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tcc_modify_bukrs INPUT.
  DATA: e_record  LIKE  t001,
   e_valid(1) TYPE c.
  IF bukrs NE space.
    CALL FUNCTION 'VALIDATE_COMPANY_CODE'
      EXPORTING
        i_company  = bukrs
      IMPORTING
        e_record   = e_record
        e_valid    = e_valid
      EXCEPTIONS
        incomplete = 1
        OTHERS     = 2.
    IF e_valid = 0.
* error sociedad no existe.
      MESSAGE e001 WITH bukrs.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TCC_MODIFY  INPUT

INCLUDE ZFIMDP030_4.
*INCLUDE zfimdp004.
*&---------------------------------------------------------------------*
*&      Module  TCC_MODIFY_HBKID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tcc_modify_hbkid INPUT.
  DATA: gt_t012k TYPE STANDARD TABLE OF t012k.
  IF hbkid NE space AND bukrs NE space.
    SELECT * FROM t012k INTO TABLE gt_t012k
            WHERE bukrs = bukrs
            AND   hbkid = hbkid.
    IF sy-subrc NE 0.
      MESSAGE e002 WITH hbkid bukrs.
* error HBKID no es valido para la Sociedad.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TCC_MODIFY_HBKID  INPUT
*&---------------------------------------------------------------------*
*&      Module  TCC_MODIFY_HBTID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE tcc_modify_hktid INPUT.
  DATA: gt_t012k2 TYPE STANDARD TABLE OF t012k.
  IF hbkid NE space AND  hktid NE space AND bukrs NE space.
    SELECT * FROM t012k INTO TABLE gt_t012k
           WHERE bukrs = bukrs
           AND   hbkid = hbkid
           AND   hktid = hktid.
    IF sy-subrc NE 0.
      MESSAGE e003 WITH bukrs hbkid hktid.
* error HKTID no es valido para la Sociedad.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TCC_MODIFY_HBTID  INPUT

INCLUDE ZFIMDP030_5_INC.

INCLUDE ZFIMDP030_4_NEW.

INCLUDE ZFIMDP030_5_INC_NEW.
