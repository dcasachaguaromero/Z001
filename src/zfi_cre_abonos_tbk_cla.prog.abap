*&---------------------------------------------------------------------*
*&  Include           ZFI_CRE_ABONOS_TBK_CLA
*&---------------------------------------------------------------------*

CLASS lcl_app DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF gty_bsis,
             bukrs TYPE bukrs,
             hkont TYPE hkont,
             gjahr TYPE gjahr,
             belnr TYPE belnr_d,
             wrbtr TYPE wrbtr,
             waers TYPE waers,
             sgtxt TYPE sgtxt,
             budat TYPE budat,
           END OF gty_bsis,

           BEGIN OF gty_data,
             bukrs TYPE bukrs,
             hkont TYPE hkont,
             budat TYPE budat,
             sgtxt TYPE sgtxt,
             belnr TYPE belnr_d,
           END OF gty_data.

    TYPES: gtt_bsis TYPE STANDARD TABLE OF gty_bsis,
           gtt_data TYPE STANDARD TABLE OF gty_data.

    DATA: gt_bsis   TYPE gtt_bsis,
          gt_data   TYPE gtt_data,
          gt_return TYPE bapiret2_t.

    DATA: gv_cuenta TYPE hkont.

    METHODS:
      get_data,

      det_repe,

      do_conta,

      show_log.

ENDCLASS.


CLASS lcl_app IMPLEMENTATION.

  METHOD get_data.

    DATA: lr_hkont TYPE RANGE OF hkont.

    LOOP AT gt_t012k ASSIGNING FIELD-SYMBOL(<ls_t012k>).
      APPEND INITIAL LINE TO lr_hkont ASSIGNING FIELD-SYMBOL(<fs_hkont>).
      <fs_hkont>-sign   = 'I'.
      <fs_hkont>-option = 'EQ'.
      <fs_hkont>-low    = <ls_t012k>-hkont + 1.
    ENDLOOP.

    CLEAR: gt_bsis.

    SELECT FROM bsis FIELDS bukrs, hkont, gjahr, belnr, wrbtr, waers, sgtxt, budat
      WHERE bukrs  = @p_bukrs
        AND hkont IN @lr_hkont
        AND budat IN @s_fecco
        AND blart  = 'ZR'     "13.02.2025
        AND bschl  = '50'     "13.02.2025
      INTO TABLE @gt_bsis.

  ENDMETHOD.

  METHOD det_repe.

    TYPES: BEGIN OF lty_doc,
             bukrs TYPE bukrs,
             hkont TYPE hkont,
             budat TYPE budat,   "27.01.2025
             sgtxt TYPE sgtxt,
             times TYPE i,
           END OF lty_doc,

           ltt_doc TYPE STANDARD TABLE OF lty_doc.

    DATA: lt_doc TYPE ltt_doc.

*-> BEGIN
    SORT gt_bsis BY bukrs hkont budat sgtxt.  "27.01.2025

    LOOP AT gt_bsis INTO DATA(ls_bsis).
      READ TABLE lt_doc ASSIGNING FIELD-SYMBOL(<fs_doc>)
        WITH KEY bukrs = ls_bsis-bukrs
                 hkont = ls_bsis-hkont
                 budat = ls_bsis-budat        "27.01.2025
                 sgtxt = ls_bsis-sgtxt.
      IF sy-subrc = 0.
        <fs_doc>-times =  <fs_doc>-times + 1.
      ELSE.
        APPEND INITIAL LINE TO lt_doc ASSIGNING <fs_doc>.
        <fs_doc>-bukrs = ls_bsis-bukrs.
        <fs_doc>-hkont = ls_bsis-hkont.
        <fs_doc>-budat = ls_bsis-budat.       "27.01.2025
        <fs_doc>-sgtxt = ls_bsis-sgtxt.
        <fs_doc>-times = 1.
      ENDIF.
    ENDLOOP.

    CLEAR: gt_data.

    LOOP AT lt_doc ASSIGNING <fs_doc> WHERE times > 0.
      LOOP AT gt_bsis INTO ls_bsis WHERE bukrs = <fs_doc>-bukrs
                                     AND hkont = <fs_doc>-hkont
                                     AND budat = <fs_doc>-budat   "27.01.2025
                                     AND sgtxt = <fs_doc>-sgtxt.
        APPEND INITIAL LINE TO gt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
        <fs_data>-bukrs = ls_bsis-bukrs.
        <fs_data>-hkont = ls_bsis-hkont.
        <fs_data>-budat = ls_bsis-budat.      "27.01.2025
        <fs_data>-sgtxt = ls_bsis-sgtxt.
        <fs_data>-belnr = ls_bsis-belnr.
      ENDLOOP.
    ENDLOOP.

    SORT gt_data BY bukrs budat belnr.
*    DELETE ADJACENT DUPLICATES FROM gt_data COMPARING bukrs budat belnr.

  ENDMETHOD.

  METHOD do_conta.

    CONSTANTS: lc_trx TYPE sytcode VALUE 'F-03'.

    DATA: ls_data   TYPE gty_data,
          _ls_data  TYPE gty_data,
          ls_bsis   TYPE gty_bsis,
          ls_return TYPE bapiret2,
          ls_params TYPE ctu_params.

    DATA: lv_cfecha TYPE c LENGTH 10,
          lv_sel    TYPE n LENGTH 2,
          lv_field  TYPE fnam_____4,
          lv_msgid  TYPE bdc_mid,
          lv_msgnr  TYPE bdc_mnr,
          lv_rc     TYPE sysubrc.

    WRITE: sy-datum TO lv_cfecha.

    READ TABLE gt_bsis INTO ls_bsis INDEX 1.

    SORT gt_data BY bukrs hkont budat sgtxt.
***
    LOOP AT gt_data INTO ls_data.
      _ls_data = ls_data.
      AT NEW sgtxt.
        CLEAR lv_sel.

        PERFORM new_data.
        PERFORM add_dynpro USING 'SAPMF05A'         '0131'.
        PERFORM add_field  USING 'RF05A-AGKON'      ls_data-hkont.
** V1 RVY 30.10.2025
        lv_cfecha+0(2) = ls_data-budat+6(2).
        lv_cfecha+3(2) = ls_data-budat+4(2).
        lv_cfecha+6(4) = ls_data-budat+0(4).
** V1 RVY 30.10.2025
        PERFORM add_field  USING 'BKPF-BUDAT'       lv_cfecha.
        PERFORM add_field  USING 'BKPF-BUKRS'       ls_data-bukrs.
        PERFORM add_field  USING 'BKPF-WAERS'       ls_bsis-waers.
        PERFORM add_field  USING 'RF05A-XPOS1(01)'  ' '.
        PERFORM add_field  USING 'RF05A-XPOS1(04)'  'X'.
        PERFORM add_field  USING 'BDC_OKCODE'       '=PA'.

        PERFORM add_dynpro USING 'SAPMF05A'     '0731'.
      ENDAT.

      lv_sel = lv_sel + 1.

      IF lv_sel > 10.
        PERFORM add_field  USING 'BDC_OKCODE'  '=SL2'.

        PERFORM add_dynpro USING 'SAPMF05A'         '0608'.
        PERFORM add_field  USING 'RF05A-XPOS1(01)'  ' '.
        PERFORM add_field  USING 'RF05A-XPOS1(03)'  'X'.
        PERFORM add_field  USING 'BDC_OKCODE'       '=ENTR'.

        PERFORM add_dynpro USING 'SAPMF05A'     '0731'.
        lv_sel = 1.
      ENDIF.

      lv_field = |RF05A-SEL01({ lv_sel })|.
      PERFORM add_field  USING lv_field       ls_data-belnr.

      AT END OF sgtxt.
        PERFORM add_field  USING 'BDC_OKCODE'   '=PA'.

        PERFORM add_dynpro USING 'SAPDF05X'      '3100'.
        PERFORM add_field  USING 'RF05A-ABPOS'   '1'.
        PERFORM add_field  USING 'BDC_OKCODE'    '=AB'.

        PERFORM add_dynpro USING 'SAPMF05A'      '0700'.
        PERFORM add_field  USING 'RF05A-NEWBS'   '50'.
        PERFORM add_field  USING 'RF05A-NEWKO'   '1011930003'.
        PERFORM add_field  USING 'BDC_OKCODE'    '/00'.

        PERFORM add_dynpro USING 'SAPMF05A'      '0300'.
        PERFORM add_field  USING 'BSEG-WRBTR'    '*'.
        PERFORM add_field  USING 'BSEG-SGTXT'    ls_data-sgtxt.
        PERFORM add_field  USING 'DKACB-FMORE'   'X'.
        PERFORM add_field  USING 'BDC_OKCODE'    '=BU'.

        PERFORM add_dynpro USING 'SAPLKACB'      '0002'.
        PERFORM add_field  USING 'BDC_OKCODE'    '=ENTE'.

        PERFORM add_dynpro USING 'SAPMF05A'      '0330'.
        PERFORM add_field  USING 'BDC_OKCODE'    '/00'.

        PERFORM add_dynpro USING 'SAPMF05A'      '0330'.
        PERFORM add_field  USING 'BDC_OKCODE'    '=BU'.

        CLEAR: ls_return, ls_params, lv_rc.
        ls_params-dismode = 'N'.
        ls_params-updmode = 'S'.
        ls_params-defsize = 'X'.

        lv_msgid  = 'F5'.
        lv_msgnr  = '312'.

        PERFORM call_trx USING lc_trx ls_params lv_msgid lv_msgnr
                               ls_return
                               lv_rc.
        APPEND ls_return TO gt_return.
      ENDAT.
    ENDLOOP.
***

  ENDMETHOD.

  METHOD show_log.

    WRITE: /01 'Programa: ', sy-repid,
           /01 'Fecha   : ', sy-datum, ' Hora: ', sy-uzeit,
           /01 'Usuario : ', sy-uname.
    SKIP 2.

    LOOP AT gt_return ASSIGNING FIELD-SYMBOL(<ls_return>).
      WRITE: /02 <ls_return>-message.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
