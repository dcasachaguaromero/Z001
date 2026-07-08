*&---------------------------------------------------------------------*
*& Report  ZFI_INR_01
*&---------------------------------------------------------------------*
*& ISAP --> M. Encina V.
*& Cálculo Iva proporcional C9
*&---------------------------------------------------------------------*
REPORT  zfi_inr_01_v2 NO STANDARD PAGE HEADING.

INCLUDE: zfi_inr_01_inc_v2,
         zfi_inc_bi_v2.

TABLES: bkpf,
        bseg,
        mseg,
        rbkp,
        rseg,
        mara,
        zfiivaprp.

DATA: it_rbkp LIKE rbkp OCCURS 0 WITH HEADER LINE,
      it_rseg LIKE rseg OCCURS 0 WITH HEADER LINE,
      it_mara LIKE mara OCCURS 0 WITH HEADER LINE,
      it_mseg LIKE mseg OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF it_bkpf OCCURS 0.
        INCLUDE STRUCTURE bkpf.
DATA: mblnr LIKE mkpf-mblnr,
      mjahr LIKE mkpf-mjahr,
      lfbnr LIKE rseg-lfbnr.
DATA: END OF it_bkpf.

DATA: BEGIN OF it_log OCCURS 0,
       belnr LIKE bkpf-belnr,
       sgtxt LIKE bseg-sgtxt,
      END OF it_log.

DATA: g_bdcop     LIKE ctu_params,
      g_fecha(10) TYPE c,
      g_bktxt(25) TYPE c,
      g_sgtxt(30) TYPE c,
      g_monto(10) TYPE c,
      g_hkont(10) TYPE c VALUE '1013310004',
      g_porc      TYPE p DECIMALS 3,
      g_awkey     LIKE bkpf-awkey.

DATA: rg_blart TYPE RANGE OF bkpf-blart.

FIELD-SYMBOLS: <fs_blart> LIKE LINE OF rg_blart.

* CONSTANTES
************
TYPE-POOLS: slis.

CONSTANTS: c_pf_status_set    TYPE slis_formname VALUE 'PF_STATUS_SET',
           formname_t_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'  ,
           c_user_command     TYPE slis_formname VALUE 'USER_COMMAND' .

DATA: t_layout            TYPE slis_layout_alv       ,
      t_fieldcat          TYPE slis_t_fieldcat_alv   ,
      t_events            TYPE slis_t_event          ,
      t_variant           LIKE disvariant            ,
      gt_sp_group         TYPE slis_t_sp_group_alv   ,
      gs_print            TYPE slis_print_alv        ,
      gt_list_top_of_page TYPE slis_t_listheader     ,
      g_repname           LIKE sy-repid              ,
      t_fieldtab          TYPE slis_t_fieldcat_alv   ,
      t_sortinfo          TYPE slis_t_sortinfo_alv   ,
      t_heading           TYPE slis_t_listheader     ,
      g_alv_variant       TYPE disvariant            ,
      g_f2code            LIKE sy-ucomm VALUE '&ETA' ,
      g_short             LIKE hrp1000-short         .

************************************************************************
************************************************************************
************************ PANTALLA DE SELECCION  ************************
************************************************************************
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK seleccion WITH FRAME TITLE text-bl1.
SELECTION-SCREEN SKIP.
PARAMETERS:     p_bukrs LIKE bkpf-bukrs OBLIGATORY.
SELECT-OPTIONS  s_budat FOR  bkpf-budat OBLIGATORY.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK seleccion.

************************************************************************
************************************************************************
************************************************************************
**********************  PROGRAMA  PRINCIPAL ****************************
************************************************************************
************************************************************************
START-OF-SELECTION.

  IF p_bukrs = 'CL12' OR
     p_bukrs = 'CL16' OR
     p_bukrs = 'CL65'.
  ELSE.
    MESSAGE 'Sociedades permitidas son: CL12, CL16 y CL65' TYPE 'E'.
  ENDIF.

  PERFORM lee_datos  .

  PERFORM muestra_alv.

  PERFORM muestra_log.


*&---------------------------------------------------------------------*
*&      Form  lee_datos
*&---------------------------------------------------------------------*
FORM lee_datos.

  CLEAR:   it_bkpf,
           it_rbkp,
           it_rseg,
           it_mara,
           it_mseg.

  REFRESH: it_bkpf,
           it_rbkp,
           it_rseg,
           it_mara,
           it_mseg.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT sign opti low FROM tvarvc INTO TABLE rg_blart WHERE name EQ 'BLART001'.
*
* NEW CODE
  SELECT sign opti low
 FROM tvarvc INTO TABLE rg_blart WHERE name EQ 'BLART001' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  LOOP AT rg_blart ASSIGNING <fs_blart> WHERE option IS INITIAL.
    <fs_blart>-option = 'EQ'.
  ENDLOOP.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*  INTO TABLE it_bkpf
*  FROM bkpf
*  WHERE bukrs    EQ p_bukrs AND
*        budat    IN s_budat AND
*        blart    IN rg_blart AND
*        xref1_hd EQ space.
*
* NEW CODE
  SELECT *

  INTO TABLE it_bkpf
  FROM bkpf
  WHERE bukrs    EQ p_bukrs AND
        budat    IN s_budat AND
        blart    IN rg_blart AND
        xref1_hd EQ space ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  IF sy-subrc = 0.

    LOOP AT it_bkpf.
      MOVE: it_bkpf-awkey+00(10) TO it_bkpf-mblnr,
            it_bkpf-awkey+10(04) TO it_bkpf-mjahr.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE lfbnr INTO it_bkpf-lfbnr FROM rseg WHERE belnr = it_bkpf-mblnr
*                                                         AND gjahr = it_bkpf-mjahr.
*
* NEW CODE
      SELECT lfbnr
      UP TO 1 ROWS  INTO it_bkpf-lfbnr FROM rseg WHERE belnr = it_bkpf-mblnr
                                                         AND gjahr = it_bkpf-mjahr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE mblnr INTO it_bkpf-mblnr FROM mseg WHERE lfbnr = it_bkpf-lfbnr
*                                                         AND gjahr = it_bkpf-mjahr.
*
* NEW CODE
      SELECT mblnr
      UP TO 1 ROWS  INTO it_bkpf-mblnr FROM mseg WHERE lfbnr = it_bkpf-lfbnr
                                                         AND gjahr = it_bkpf-mjahr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      MODIFY it_bkpf.
    ENDLOOP.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*    INTO TABLE it_rseg
*    FROM rseg
*    FOR ALL ENTRIES IN it_bkpf
*    WHERE bukrs EQ it_bkpf-bukrs AND
*          lfbnr EQ it_bkpf-lfbnr AND " JP 20.12.2017
*          mwskz EQ 'C9'.
*
* NEW CODE
    SELECT *

    INTO TABLE it_rseg
    FROM rseg
    FOR ALL ENTRIES IN it_bkpf
    WHERE bukrs EQ it_bkpf-bukrs AND
          lfbnr EQ it_bkpf-lfbnr AND " JP 20.12.2017
          mwskz EQ 'C9' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*Inicio 27.10.2015
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*    INTO TABLE it_rbkp
*    FROM rbkp
*    FOR ALL ENTRIES IN it_rseg
*    WHERE bukrs EQ it_rseg-bukrs AND
*          belnr EQ it_rseg-belnr.
*
* NEW CODE
    SELECT *

    INTO TABLE it_rbkp
    FROM rbkp
    FOR ALL ENTRIES IN it_rseg
    WHERE bukrs EQ it_rseg-bukrs AND
          belnr EQ it_rseg-belnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    LOOP AT it_rseg.
      READ TABLE it_rbkp WITH KEY bukrs = it_rseg-bukrs
                                  belnr = it_rseg-belnr.
      IF it_rbkp-stblg NE space.
        DELETE it_rseg.
      ENDIF.
    ENDLOOP.
*Fin 27.10.2015

* Datos MM
*    SELECT *
*    INTO TABLE it_mseg
*    FROM mseg
*    FOR ALL ENTRIES IN it_rseg
*    WHERE mblnr EQ it_rseg-lfbnr AND
*          mjahr EQ it_rseg-gjahr .
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*    INTO TABLE it_mseg
*    FROM mseg
*    FOR ALL ENTRIES IN it_bkpf
*    WHERE mblnr EQ it_bkpf-mblnr AND
*          mjahr EQ it_bkpf-gjahr .
*
* NEW CODE
    SELECT *

    INTO TABLE it_mseg
    FROM mseg
    FOR ALL ENTRIES IN it_bkpf
    WHERE mblnr EQ it_bkpf-mblnr AND
          mjahr EQ it_bkpf-gjahr  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *
*    INTO TABLE it_mara
*    FROM mara
*    FOR ALL ENTRIES IN it_rseg
*    WHERE matnr EQ it_rseg-matnr AND
*          mtart EQ 'ZSSV'.
*
* NEW CODE
    SELECT *

    INTO TABLE it_mara
    FROM mara
    FOR ALL ENTRIES IN it_rseg
    WHERE matnr EQ it_rseg-matnr AND
          mtart EQ 'ZSSV' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    LOOP AT it_bkpf.
      LOOP AT it_rseg WHERE bukrs = it_bkpf-bukrs AND
                            lfbnr = it_bkpf-lfbnr AND " it_bkpf-mblnr AND " MOD.JP.20.12.2017
                            gjahr = it_bkpf-gjahr.

        MOVE-CORRESPONDING it_bkpf TO t_alv.

        MOVE: it_rseg-wrbtr TO t_alv-dmbtr,
              it_rseg-shkzg TO t_alv-shkzg,
              it_bkpf-xblnr TO t_alv-referencia. "Nuevo campo referencia GCR

        READ TABLE it_mseg WITH KEY lfbnr = it_bkpf-lfbnr " mblnr = it_bkpf-mblnr
                                    mjahr = it_bkpf-mjahr.
        IF sy-subrc = 0.
          MOVE: it_mseg-sakto      TO t_alv-sakto      ,
                it_mseg-kostl      TO t_alv-kostl      ,
                it_mseg-zzunid_pro TO t_alv-zzunid_pro ,
                it_mseg-zzrut_terc TO t_alv-rut_terc   . "nuevo campo de despligue gcr
        ENDIF.

* Inicio Agrega nuevos campos
        CLEAR g_awkey.

        CONCATENATE it_rseg-belnr
                    it_rseg-gjahr INTO g_awkey.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE *
*        FROM bkpf
*        WHERE awkey = g_awkey.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
        FROM bkpf
        WHERE awkey = g_awkey ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
          MOVE: bkpf-belnr TO t_alv-doc_fac,
                bkpf-blart TO t_alv-tip_fac,
                bkpf-budat TO t_alv-budat  .
        ENDIF.
* Fin Agrega nuevos campos

        APPEND t_alv.

      ENDLOOP.
    ENDLOOP.
  ELSE.
    MESSAGE 'No existen datos, verifique parámetros' TYPE 'E'.
  ENDIF.

  LOOP AT t_alv.

    t_alv-iva =  t_alv-dmbtr * '0.19'.

    CLEAR g_porc.


*--------------------------------------------------------------------*
** Rellena fecha hasta gcr

    IF s_budat-high IS INITIAL.
      s_budat-high = s_budat-low.
    ENDIF.
*--------------------------------------------------------------------*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM zfiivaprp
*    WHERE bukrs     EQ p_bukrs     AND
*          fec_inico <= s_budat-low AND
*          fec_fin   >= s_budat-high.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM zfiivaprp
    WHERE bukrs     EQ p_bukrs     AND
          fec_inico <= s_budat-low AND
          fec_fin   >= s_budat-high ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc  = 0.
      g_porc = zfiivaprp-iva_prop / 100.
      t_alv-iva_nr = g_porc * t_alv-iva.
    ENDIF.

    MODIFY t_alv.

  ENDLOOP.

ENDFORM.                    "lee_datos

*&---------------------------------------------------------------------*
*&      Form  muestra_alv
*&---------------------------------------------------------------------*
FORM muestra_alv.


* ALV FUNCTIONS
***************
  PERFORM eventos  .
  PERFORM initialize_fieldcat USING t_fieldtab[]. " LOGICA de Botones
  PERFORM layout   .
  PERFORM build_comment       USING t_heading[] .
  PERFORM build_eventtab      USING t_events[]  .


  gs_print-no_print_listinfos = 'X'.
  gs_print-no_print_selinfos  = ''.

  CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
    EXPORTING
      i_save        = 'A'
    CHANGING
      cs_variant    = g_alv_variant
    EXCEPTIONS
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      OTHERS        = 4.

* Imprime el reporte
********************
  PERFORM write_output.


ENDFORM.                    "muestra_alv

*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.

  DATA fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE.

  CLEAR: fcode_attrib_tab  ,
         fcode_attrib_tab[].

* Genera un boton en el menu ALV
  fcode_attrib_tab-text      = text-x00.
  fcode_attrib_tab-icon_id   = '@2L@'  .
  fcode_attrib_tab-icon_text = text-x00.
  fcode_attrib_tab-quickinfo = text-x01.
  fcode_attrib_tab-path      = space   .
  APPEND fcode_attrib_tab.

  PERFORM dynamic_report_fcodes(rhteiln0)
  TABLES fcode_attrib_tab
  USING  ce_func_exclude ' ' ' '.

  SET PF-STATUS 'ALVLIST'
*  EXCLUDING ce_func_exclude
  OF PROGRAM 'RHTEILN0'.

ENDFORM.                    "PF_STATUS

*---------------------------------------------------------------------*
*       FORM top_of_page                                              *
*---------------------------------------------------------------------*
FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_heading.

ENDFORM.                    "top_of_page


*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&---------------------------------------------------------------------*
FORM user_command USING ucomm       LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  DATA: gd_repid LIKE        sy-repid,
        ref_grid TYPE REF TO cl_gui_alv_grid.

  IF ref_grid IS INITIAL.
    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
      IMPORTING
        e_grid = ref_grid.
  ENDIF.

  IF NOT ref_grid IS INITIAL.
    CALL METHOD ref_grid->check_changed_data .
  ENDIF.

  CASE ucomm.

* Contabiliza
**************
    WHEN 'FC01'.

      PERFORM call_transaction.

  ENDCASE.
ENDFORM.                    "user_command

*&---------------------------------------------------------------------*
*&      Form  eventos
*&---------------------------------------------------------------------*
FORM eventos.

  DATA: ls_event TYPE slis_alv_event.

  REFRESH t_events.
  ls_event-name = 'TOP_OF_PAGE'.
  ls_event-form = 'ALV_TOP_OF_PAGE'.
  APPEND ls_event TO t_events.

ENDFORM.                    " eventos

*&---------------------------------------------------------------------*
*&      Form  initialize_fieldcat
*&---------------------------------------------------------------------*
FORM initialize_fieldcat USING p_fieldtab TYPE slis_t_fieldcat_alv.

  DATA: l_fieldcat TYPE slis_fieldcat_alv,
        l_index    LIKE sy-index VALUE '1'.

  g_repname = sy-repid.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name     = g_repname
      i_internal_tabname = 'T_ALV'
      i_inclname         = 'ZFI_INR_01_INC'
    CHANGING
      ct_fieldcat        = p_fieldtab.

  READ TABLE t_alv INDEX 1.

  LOOP AT p_fieldtab INTO l_fieldcat.
    CASE l_fieldcat-fieldname.
      WHEN 'DMBTR'.
        l_fieldcat-currency     = 'CLP'.
      WHEN 'IVA'.
        l_fieldcat-seltext_l    = 'Iva'.
        l_fieldcat-seltext_m    = l_fieldcat-seltext_l.
        l_fieldcat-seltext_s    = l_fieldcat-seltext_l.
        l_fieldcat-currency     = 'CLP'.
      WHEN 'IVA_NR'.
        l_fieldcat-seltext_l    = 'Iva NO Recuperable'.
        l_fieldcat-seltext_m    = l_fieldcat-seltext_l.
        l_fieldcat-seltext_s    = l_fieldcat-seltext_l.
        l_fieldcat-currency     = 'CLP'.
      WHEN 'DOC_FAC'.
        l_fieldcat-seltext_l    = 'Nro. Docto FI'.
        l_fieldcat-seltext_m    = l_fieldcat-seltext_l.
        l_fieldcat-seltext_s    = l_fieldcat-seltext_l.
      WHEN 'TIP_FAC'.
        l_fieldcat-seltext_l    = 'Cl. Docto FI'.
        l_fieldcat-seltext_m    = l_fieldcat-seltext_l.
        l_fieldcat-seltext_s    = l_fieldcat-seltext_l.
      WHEN 'BUDAT'.
        l_fieldcat-seltext_l    = 'Fec. Docto FI'.
        l_fieldcat-seltext_m    = l_fieldcat-seltext_l.
        l_fieldcat-seltext_s    = l_fieldcat-seltext_l.

    ENDCASE.

    MODIFY p_fieldtab FROM l_fieldcat.

  ENDLOOP.

ENDFORM.                    "initialize_fieldcat

*&---------------------------------------------------------------------*
*&      Form  layout
*&---------------------------------------------------------------------*
FORM layout .
  t_layout-f2code            = 'DISPLAY'.
  t_layout-zebra             = 'X'.
  t_layout-colwidth_optimize = 'X'. " Esto ajusta las columnas
ENDFORM.                    " layout


*---------------------------------------------------------------------*
*       FORM build_comment                                            *
*---------------------------------------------------------------------*
FORM build_comment USING p_heading TYPE slis_t_listheader.

  DATA: hline     TYPE slis_listheader,
        text(255) TYPE c,
        text2(80) TYPE c,
        text1(80) TYPE c.

  DATA: ff(10).

  CLEAR: hline    ,
         text     ,
         text1    ,
         p_heading.

  REFRESH p_heading.

*Cabecera
  hline-typ = 'H'.
  hline-info = text-t01.
  APPEND hline TO p_heading.
  CLEAR hline.

  hline-typ = 'S'.
  WRITE sy-datum TO text.
  CONCATENATE 'Fecha de Ejecución: ' text INTO text SEPARATED BY space.
  hline-info = text.
  APPEND hline TO p_heading.

  hline-typ = 'S'.
  WRITE sy-uname TO text.
  CONCATENATE 'Usr. de Ejecución: ' text INTO text SEPARATED BY space.
  hline-info = text.
  APPEND hline TO p_heading.

ENDFORM.                               " BUILD_COMMENT

*---------------------------------------------------------------------*
*       FORM build_eventtab                                           *
*---------------------------------------------------------------------*
FORM build_eventtab USING p_events TYPE slis_t_event.

  DATA: ls_event TYPE slis_alv_event.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = p_events.

  READ TABLE p_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.

  IF sy-subrc = 0.
    MOVE formname_t_of_page TO ls_event-form.
    APPEND ls_event TO p_events.
  ENDIF.

ENDFORM.                               " BUILD_EVENTTAB

*---------------------------------------------------------------------*
*       FORM write_output                                             *
*---------------------------------------------------------------------*
FORM write_output.

  g_repname = sy-repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active          = ' '
      i_callback_program       = g_repname
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      i_background_id          = 'SDN'
      i_callback_user_command  = 'USER_COMMAND'
      i_structure_name         = 'T_ALV'
      is_layout                = t_layout
      it_fieldcat              = t_fieldtab
      i_bypassing_buffer       = 'X'
      i_save                   = 'A'
      it_sort                  = t_sortinfo
      it_events                = t_events[]
      is_variant               = g_alv_variant
    TABLES
      t_outtab                 = t_alv
    EXCEPTIONS
      program_error            = 1.

  IF sy-subrc <> 0.
    WRITE: 'SY-SUBRC: ', sy-subrc, 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

ENDFORM.                               " WRITE_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  call_transaction
*&---------------------------------------------------------------------*
FORM call_transaction.

*Parametros de ejecución de CALL TRANSACTION
  g_bdcop-dismode  = 'N'.
  g_bdcop-updmode  = 'S'.
  g_bdcop-racommit = 'X'.

  LOOP AT t_alv.

    IF t_alv-shkzg = 'S'.

      PERFORM crea_factura.

    ELSE.

      PERFORM crea_nota_cr.

    ENDIF.

  ENDLOOP.

  PERFORM genera_marca.

ENDFORM.                    "call_transaction


*&---------------------------------------------------------------------*
*&      Form  crea_factura
*&---------------------------------------------------------------------*
FORM crea_factura.

  CONCATENATE sy-datum+06(02) '.'
              sy-datum+04(02) '.'
              sy-datum+00(04) INTO g_fecha.

  CONCATENATE 'INR-C9'           g_fecha INTO g_bktxt SEPARATED BY space.
  CONCATENATE 'REVERSA INR C9 -' g_fecha INTO g_sgtxt SEPARATED BY space.

  CLEAR   : it_messtab, it_bdc_tab, g_monto.
  REFRESH : it_messtab, it_bdc_tab.

  WRITE t_alv-iva_nr TO g_monto CURRENCY 'CLP'.

  PERFORM dynpro USING:
    'X' 'SAPMF05A'     '0100'         ,
    ' ' 'BDC_OKCODE'   '/00'          ,
    ' ' 'BKPF-BLDAT'   g_fecha        ,
    ' ' 'BKPF-BLART'   'SA'           ,
    ' ' 'BKPF-BUKRS'   p_bukrs        ,
    ' ' 'BKPF-BUDAT'   g_fecha        ,
    ' ' 'BKPF-MONAT'   sy-datum+04(02),
    ' ' 'BKPF-WAERS'   'CLP'          ,
    ' ' 'BKPF-XBLNR'   t_alv-referencia ,
    ' ' 'BKPF-BKTXT'   g_bktxt        ,
    ' ' 'RF05A-NEWBS'  '50'           ,
    ' ' 'RF05A-NEWKO'  g_hkont        .

  PERFORM dynpro USING:
    'X' 'SAPMF05A'     '0300'         ,
    ' ' 'BDC_OKCODE'   '/00'          ,
    ' ' 'BSEG-WRBTR'   g_monto        ,
    ' ' 'BSEG-ZUONR'   '20171220'     , " 21.12.2017
    ' ' 'BSEG-SGTXT'   g_sgtxt        , " 21.12.2017
    ' ' 'RF05A-NEWBS'  '40'           ,
    ' ' 'RF05A-NEWKO'  t_alv-sakto    ,
    ' ' 'DKACB-FMORE'  'X'            .

  PERFORM dynpro USING:
    'X' 'SAPLKACB'     '0002'         ,
    ' ' 'BDC_OKCODE'   '=ENTE'        .

  PERFORM dynpro USING:
    'X' 'SAPMF05A'     '0300'         ,
    ' ' 'BSEG-WRBTR'   g_monto        ,
    ' ' 'BSEG-SGTXT'   g_sgtxt        , " 21.12.2017
    ' ' 'BSEG-ZUONR'   '20171220'     , " 21.12.2017
    ' ' 'BDC_OKCODE'   '=BU'          .

  PERFORM dynpro USING:
    'X' 'SAPLKACB'     '0002'         ,
    ' ' 'BDC_OKCODE'   '=ENTE'        ,
    ' ' 'COBL-KOSTL'   t_alv-kostl    ,
    ' ' 'COBL-ZZUNID_PRO'   t_alv-zzunid_pro  ,
    ' ' 'COBL-ZZRUT_TERC'   t_alv-rut_terc    .

  CALL TRANSACTION 'FB41'
  USING it_bdc_tab
  OPTIONS FROM g_bdcop
  MESSAGES INTO it_messtab.

  READ TABLE it_messtab WITH KEY msgtyp = 'S'
                                 msgnr  = '312'.
  IF sy-subrc = 0.
    MOVE: it_messtab-msgv1  TO it_log-belnr,
          'Documento creado'TO it_log-sgtxt.
    APPEND it_log.
  ENDIF.
  READ TABLE it_messtab WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.
    MOVE: t_alv-belnr                         TO it_log-belnr,
          'Para Documento Error en creación ' TO it_log-sgtxt.
    APPEND it_log.
  ENDIF.

  CLEAR   : it_messtab, g_monto.
  REFRESH : it_messtab.

ENDFORM.                    "crea_factura


*&---------------------------------------------------------------------*
*&      Form  crea_nota_cr
*&---------------------------------------------------------------------*
FORM crea_nota_cr.

  CONCATENATE sy-datum+06(02) '.'
              sy-datum+04(02) '.'
              sy-datum+00(04) INTO g_fecha.

  CONCATENATE 'INR-C9'           g_fecha INTO g_bktxt SEPARATED BY space.
  CONCATENATE 'REVERSA INR C9 -' g_fecha INTO g_sgtxt SEPARATED BY space.

  CLEAR   : it_messtab, it_bdc_tab, g_monto.
  REFRESH : it_messtab, it_bdc_tab.

  WRITE t_alv-iva_nr TO g_monto CURRENCY 'CLP'.

  PERFORM dynpro USING:
    'X' 'SAPMF05A'     '0100'         ,
    ' ' 'BDC_OKCODE'   '/00'          ,
    ' ' 'BKPF-BLDAT'   g_fecha        ,
    ' ' 'BKPF-BLART'   'SA'           ,
    ' ' 'BKPF-BUKRS'   p_bukrs        ,
    ' ' 'BKPF-BUDAT'   g_fecha        ,
    ' ' 'BKPF-MONAT'   sy-datum+04(02),
    ' ' 'BKPF-WAERS'   'CLP'          ,
    ' ' 'BKPF-XBLNR'   t_alv-referencia ,
    ' ' 'BKPF-BKTXT'   g_bktxt        ,
    ' ' 'RF05A-NEWBS'  '40'           ,
    ' ' 'RF05A-NEWKO'  g_hkont        .

  PERFORM dynpro USING:
    'X' 'SAPMF05A'     '0300'         ,
    ' ' 'BDC_OKCODE'   '/00'          ,
    ' ' 'BSEG-WRBTR'   g_monto        ,
    ' ' 'BSEG-SGTXT'   g_sgtxt        ,
    ' ' 'RF05A-NEWBS'  '50'           ,
    ' ' 'RF05A-NEWKO'  t_alv-sakto    ,
    ' ' 'DKACB-FMORE'  'X'            .

  PERFORM dynpro USING:
    'X' 'SAPLKACB'     '0002'         ,
    ' ' 'BDC_OKCODE'   '=ENTE'        .

  PERFORM dynpro USING:
    'X' 'SAPMF05A'     '0300'         ,
    ' ' 'BDC_OKCODE'   '=BU'          .

  PERFORM dynpro USING:
    'X' 'SAPLKACB'     '0002'         ,
    ' ' 'BDC_OKCODE'   '=ENTE'        ,
    ' ' 'COBL-KOSTL'   t_alv-kostl    ,
    ' ' 'COBL-ZZUNID_PRO'   t_alv-zzunid_pro  ,
    ' ' 'COBL-ZZRUT_TERC'   t_alv-rut_terc    .

  CALL TRANSACTION 'FB41'
  USING it_bdc_tab
  OPTIONS FROM g_bdcop
  MESSAGES INTO it_messtab.

  READ TABLE it_messtab WITH KEY msgtyp = 'S'
                                 msgnr  = '312'.
  IF sy-subrc = 0.
    MOVE: it_messtab-msgv1  TO it_log-belnr,
          'Documento creado'TO it_log-sgtxt.
    APPEND it_log.
  ENDIF.
  READ TABLE it_messtab WITH KEY msgtyp = 'E'.
  IF sy-subrc = 0.
    MOVE: t_alv-belnr                         TO it_log-belnr,
          'Para Documento Error en creación ' TO it_log-sgtxt.
    APPEND it_log.
  ENDIF.

  CLEAR   : it_messtab, g_monto.
  REFRESH : it_messtab.

ENDFORM.                    "crea_nota_cr

*&---------------------------------------------------------------------*
*&      Form  genera_marca
*&---------------------------------------------------------------------*
FORM genera_marca.

  LOOP AT it_bkpf.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*    FROM bkpf
*    WHERE bukrs = it_bkpf-bukrs AND
*          gjahr = it_bkpf-gjahr AND
*          belnr = it_bkpf-belnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
    FROM bkpf
    WHERE bukrs = it_bkpf-bukrs AND
          gjahr = it_bkpf-gjahr AND
          belnr = it_bkpf-belnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
      MOVE 'X' TO bkpf-xref1_hd.
      MODIFY bkpf.
    ENDIF.

  ENDLOOP.

ENDFORM.                    "genra_marca


*&---------------------------------------------------------------------*
*&      Form  muestra_log
*&---------------------------------------------------------------------*
FORM muestra_log.

  WRITE:/040 'LOG DE PROCESO'.
  WRITE:/040 '=============='.

  LOOP AT it_log.
    WRITE:/05 it_log-belnr,
           20 it_log-sgtxt.
  ENDLOOP.

ENDFORM.                    "muestra_log
