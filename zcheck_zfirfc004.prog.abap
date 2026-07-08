*&---------------------------------------------------------------------*
*& Report ZCHECK_ZFIRFC004
*&---------------------------------------------------------------------*
*& Prueba función ZFIRFC004
*&---------------------------------------------------------------------*
REPORT zcheck_zfirfc004 LINE-SIZE 1000.

DATA ti_cabecera TYPE  zcabecera_me OCCURS 100  WITH HEADER LINE.
DATA ti_detalle LIKE  zdetalle_me_ct OCCURS 1000 WITH HEADER LINE.
DATA: BEGIN OF ti_cabecera_in OCCURS 0,
        dumyy1(10),
        zkey(6),
        username       TYPE usnam,
        header_txt     TYPE bktxt,
        comp_code      TYPE bukrs,
        doc_date       TYPE bldat,
        pstng_date     TYPE budat,
        fisc_year      TYPE gjahr,
        fis_period     TYPE monat,
        doc_type       TYPE blart,
        ref_doc_no     TYPE xblnr,
        area_contab(4),
      END OF ti_cabecera_in.


PARAMETERS p_fnhead TYPE rlgrap-filename OBLIGATORY DEFAULT 'C:/BANMEDICA/Cabecera.txt'.
PARAMETERS p_fndet TYPE rlgrap-filename OBLIGATORY DEFAULT 'C:/BANMEDICA/Detalle.csv'.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fnhead.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_fnhead
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Cabecera'
    IMPORTING
      filename         = p_fnhead
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fndet.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_fndet
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Detalle'
    IMPORTING
      filename         = p_fndet
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.




START-OF-SELECTION.

  PERFORM read_header.
  PERFORM read_detalle.

  PERFORM process_data.

*&---------------------------------------------------------------------*
*&      Form  READ_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_header .
  DATA lv_fname TYPE string.
  lv_fname = p_fnhead.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_fname
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = ti_cabecera_in
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  IF sy-subrc <> 0.
    MESSAGE e000(fb) WITH 'Error al leer archivo' lv_fname.
  ENDIF.

  LOOP AT ti_cabecera_in.
    MOVE-CORRESPONDING ti_cabecera_in TO ti_cabecera.
    APPEND ti_cabecera.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  READ_DETALLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_detalle .
  DATA lv_fname TYPE string.
  DATA ti_lines(200) OCCURS 0 WITH HEADER LINE.
  DATA lv_amt_doccur(20).
  DATA lv_amt_base(20).
  DATA lv_amt_doccur_me(20).
  DATA lv_amt_base_me(20).

  lv_fname = p_fndet.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_fname
      filetype                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = ti_lines
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  LOOP AT ti_lines.
    CLEAR ti_detalle.

    SPLIT ti_lines AT ';' INTO
       ti_detalle-zkey
       ti_detalle-itemno_acc
       ti_detalle-vendor_no
       ti_detalle-customer
       ti_detalle-hkont
       ti_detalle-sgtxt
       ti_detalle-tax_code
       ti_detalle-costcenter
       ti_detalle-profit_ctr
       ti_detalle-pmnttrms
       ti_detalle-bline_date
       ti_detalle-pymt_meth
       ti_detalle-pmnt_block
       ti_detalle-alloc_nmbr
       ti_detalle-wt_type
       ti_detalle-wt_code
       ti_detalle-ref_key_1
       ti_detalle-ref_key_2
       ti_detalle-zz_agencia
       ti_detalle-currency
       lv_amt_doccur
       lv_amt_base
       lv_amt_doccur_me
       ti_detalle-currency_me
       ti_detalle-zzprestac
       ti_detalle-zzunid_pro
       ti_detalle-zzdesc_est
       ti_detalle-zzmot_emis
       ti_detalle-zzrut_terc
       ti_detalle-fdlev
       ti_detalle-atributo_8
       ti_detalle-alt_payee
       ti_detalle-iva
       ti_detalle-bank_id
       ti_detalle-hktid
       ti_detalle-aufnr
       ti_detalle-anbwa
       ti_detalle-bschl.

    REPLACE FIRST OCCURRENCE OF ','  IN lv_amt_doccur WITH '.'.
    MOVE lv_amt_doccur TO ti_detalle-amt_doccur.
    REPLACE FIRST OCCURRENCE OF ','  IN lv_amt_doccur_me WITH '.'.
    MOVE lv_amt_doccur_me TO ti_detalle-amt_doccur_me.
    REPLACE FIRST OCCURRENCE OF ','  IN lv_amt_doccur_me WITH '.'.
    MOVE lv_amt_doccur_me TO  ti_detalle-amt_doccur_me.

    APPEND ti_detalle.

  ENDLOOP.


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data .
  DATA ti_tlogcaberr LIKE  ztlogcaberr OCCURS 0 WITH HEADER LINE.
  DATA ti_tlogdeterr LIKE  ztlogdeterr OCCURS 0 WITH HEADER LINE.
  DATA ti_resumen    LIKE  zresumen OCCURS 0 WITH HEADER LINE.
  DATA ti_return     LIKE  bapiret2 OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'ZFIRFC004'
    TABLES
      ti_cabecera   = ti_cabecera
      ti_detalle    = ti_detalle
      ti_tlogcaberr = ti_tlogcaberr
      ti_tlogdeterr = ti_tlogdeterr
      ti_resumen    = ti_resumen
      return        = ti_return.

  LOOP AT ti_resumen.
    WRITE:/' ', 'Comprobante', ti_resumen-key, ti_resumen-ref, ti_resumen-con_pos, ti_resumen-estado, ti_resumen-n_sap.
  ENDLOOP.

  LOOP AT ti_tlogcaberr.
    WRITE:/' ', 'Comprobante', ti_tlogcaberr-key, ti_tlogcaberr-cod_err, ti_tlogcaberr-descripcion.
  ENDLOOP.

  LOOP AT ti_tlogdeterr.
    WRITE:/' ', '     ', ti_tlogdeterr-posic, ti_tlogdeterr-cod_err, ti_tlogdeterr-descripcion.
  ENDLOOP.

ENDFORM.
