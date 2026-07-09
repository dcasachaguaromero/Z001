*&---------------------------------------------------------------------*
*& Report  ZSD_UPD_FACT_3
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zsd_upd_fact_3.

CONSTANTS: gc_va01    TYPE sytcode VALUE 'VA01',
           gc_vf01    TYPE sytcode VALUE 'VF01'.

DATA: BEGIN OF gs_reco,
        vbeln     TYPE vbeln_vf,
        bstkd     TYPE vbkd-bstkd,
        bstdk(10) TYPE c,
        motivo    TYPE c,
        kvgr1     TYPE vbak-kvgr1,
        kvgr2     TYPE vbak-kvgr2,
        kvgr5     TYPE vbak-kvgr5,
        nusol     TYPE vbak-vbeln,
        nufac     TYPE vbrk-vbeln,
        error(1)  TYPE c,
      END OF gs_reco.

DATA: gs_vbrk  TYPE vbrk.
DATA: gt_reco  LIKE TABLE OF gs_reco.

DATA: BEGIN OF gt_bdcdata OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF gt_bdcdata.

DATA: gs_messtab   TYPE bdcmsgcoll.
DATA: BEGIN OF gt_messtab OCCURS 10.
        INCLUDE STRUCTURE bdcmsgcoll.
DATA END OF gt_messtab.

DATA: gv_mode(1)    TYPE c VALUE 'N',
      gv_cfecha(10) TYPE c.

*----------------------------------------------------------------------
*                      SELECTION-SCREEN
*----------------------------------------------------------------------
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
PARAMETERS: p_fkdat   TYPE fkdat OBLIGATORY DEFAULT '20190801',
            pp_fkart  type FKART OBLIGATORY.
SELECTION-SCREEN SKIP.
PARAMETERS: p_file    TYPE string OBLIGATORY LOWER CASE,
            p_cab     AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN: END OF BLOCK b1.


*--------------------------------------------------------------------*
*                    AT SELECTION-SCREEN
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  PERFORM buscar_archivo USING p_file.


*----------------------------------------------------------------------
*                 START-OF-SELECTION
*----------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM leer_archivo  TABLES gt_reco
                        USING p_file.

* Generar pedido de Nota de Crédito
  LOOP AT gt_reco INTO gs_reco.
    CLEAR: gt_bdcdata, gt_messtab.
    REFRESH: gt_bdcdata, gt_messtab.
    PERFORM bdc_dynpro USING 'SAPMV45A'      '0101'.
    PERFORM bdc_field  USING 'VBAK-AUART'    'ZNC'.
    PERFORM bdc_field  USING 'VBAK-VKORG'    ''.
    PERFORM bdc_field  USING 'VBAK-VTWEG'    ''.
    PERFORM bdc_field  USING 'VBAK-SPART'    ''.
    PERFORM bdc_field  USING 'BDC_OKCODE'    '=COPY'.
*
    PERFORM bdc_dynpro USING 'SAPLV45C'      '0100'.
    PERFORM bdc_field  USING 'VBRK-VBELN'    gs_reco-vbeln.
    PERFORM bdc_field  USING 'BDC_OKCODE'    '=UEBR'.
*
    PERFORM bdc_dynpro USING 'SAPMV45A'     '4001'.
    PERFORM bdc_field  USING 'VBAK-FAKSK'    ''.
    PERFORM bdc_field  USING 'BDC_OKCODE'    '=T\01'.
*
    PERFORM bdc_dynpro USING 'SAPMV45A'     '4001'.
    PERFORM bdc_field  USING 'VBAK-AUGRU'   '101'.
    PERFORM bdc_field  USING 'BDC_OKCODE'    '=HEAD'.
*
    PERFORM bdc_dynpro USING 'SAPMV45A'     '4002'.
    PERFORM bdc_field  USING 'BDC_OKCODE'   '=T\11'.
*
    PERFORM bdc_dynpro USING 'SAPMV45A'     '4002'.
    PERFORM bdc_field  USING 'VBKD-BSTKD'   gs_reco-bstkd.
    PERFORM bdc_field  USING 'VBKD-BSTDK'   gs_reco-bstdk.
    PERFORM bdc_field  USING 'VBKD-BSARK'   gs_reco-motivo.
    PERFORM bdc_field  USING 'BDC_OKCODE'   '=T\13'.
*
    PERFORM bdc_dynpro USING 'SAPMV45A'     '4002'.
    PERFORM bdc_field  USING 'VBAK-KVGR1'   gs_reco-kvgr1.
    PERFORM bdc_field  USING 'VBAK-KVGR2'   gs_reco-kvgr2.
    PERFORM bdc_field  USING 'VBAK-KVGR5'   gs_reco-kvgr5.
    PERFORM bdc_field  USING 'BDC_OKCODE'   '/EBACK'.
*
    PERFORM bdc_dynpro USING 'SAPMV45A'     '4001'.
    PERFORM bdc_field  USING 'BDC_OKCODE'   '=SICH'.

    PERFORM bdc_transaction USING gc_va01 gv_mode.

    READ TABLE gt_messtab INTO gs_messtab WITH KEY msgtyp = 'S'
                                                   msgid  = 'V1'
                                                   msgnr  = '311'.
    IF sy-subrc = 0.
      gs_reco-nusol = gs_messtab-msgv2.
      MODIFY gt_reco FROM gs_reco TRANSPORTING nusol.
    ELSE.
      gs_reco-error = '1'.
      MODIFY gt_reco FROM gs_reco TRANSPORTING error.
    ENDIF.
  ENDLOOP.

* Generar Nota de Crédito
  LOOP AT gt_reco INTO gs_reco WHERE NOT nusol IS INITIAL.
    CLEAR: gt_bdcdata, gt_messtab.
    REFRESH: gt_bdcdata, gt_messtab.
    PERFORM bdc_dynpro USING 'SAPMV60A'     '0102'.
    WRITE p_fkdat TO gv_cfecha.
    PERFORM bdc_field  USING 'RV60A-FKDAT'      gv_cfecha.
    PERFORM bdc_field  USING 'KOMFK-VBELN(01)'  gs_reco-nusol.
    PERFORM bdc_field  USING 'BDC_OKCODE'       '/00'.
*
    PERFORM bdc_dynpro USING 'SAPMV60A'     '0104'.
    PERFORM bdc_field  USING 'BDC_OKCODE'   '=SICH'.

    PERFORM bdc_transaction USING gc_vf01 gv_mode.
    READ TABLE gt_messtab INTO gs_messtab WITH KEY msgtyp = 'S'
                                                   msgid  = 'VF'
                                                   msgnr  = '311'.
    IF sy-subrc = 0.
      gs_reco-nufac = gs_messtab-msgv1.
      MODIFY gt_reco FROM gs_reco TRANSPORTING nufac.
    ELSE.
      gs_reco-error = '2'.
      MODIFY gt_reco FROM gs_reco TRANSPORTING error.
    ENDIF.
  ENDLOOP.

* Foliar el documento en la txn IDCP
  LOOP AT gt_reco INTO gs_reco WHERE NOT nufac IS INITIAL.
    PERFORM pre_idcp USING gs_reco.
  ENDLOOP.

  MESSAGE i899(m3) WITH text-i01.


*&----------------------------------------------------------------------
*&      Form BUSCAR_ARCHIVO
*&----------------------------------------------------------------------
FORM buscar_archivo CHANGING io_file.

  DATA: lv_file1 LIKE dynpread-fieldname,
        lv_file2 LIKE ibipparms-path.

  lv_file1 = io_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = lv_file1
    IMPORTING
      file_name  = lv_file2.

  io_file = lv_file2.

ENDFORM.                    "BUSCAR_ARCHIVO


*&---------------------------------------------------------------------
*&      Form LEER_ARCHIVO
*&---------------------------------------------------------------------
FORM leer_archivo TABLES ot_reco  STRUCTURE gs_reco
                  USING  i_file   TYPE string.

  DATA: ls_reco    LIKE gs_reco.

  DATA: BEGIN OF ls_reg,
          vbeln     TYPE vbeln_vf,
          bstkd     TYPE vbkd-bstkd,
          bstdk(10) TYPE c,
          motivo    TYPE c,
          kvgr1     TYPE vbak-kvgr1,
          kvgr2     TYPE vbak-kvgr2,
          kvgr5     TYPE vbak-kvgr5,
        END OF ls_reg.

  DATA: BEGIN OF ls_aux,
          lin   TYPE string,
        END OF ls_aux.

  DATA: lt_aux       LIKE TABLE OF ls_aux.
  DATA: lv_filename  TYPE string.

  lv_filename = i_file.

  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = 'ASC'
    CHANGING
      data_tab                = lt_aux
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
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.

  IF sy-subrc <> 0.
*     Error & de apertura de archivo
    MESSAGE e899(m3) WITH text-e01.
    EXIT.
  ENDIF.

* Extraer datos
  LOOP AT lt_aux INTO ls_aux.
    IF sy-tabix = 1 AND p_cab = 'X'.
      CONTINUE.   "Descarta cabecera
    ENDIF.
    CLEAR: ls_reg, ls_reco.

    SPLIT ls_aux-lin AT ';' INTO ls_reg-vbeln
                                 ls_reg-bstkd
                                 ls_reg-bstdk
                                 ls_reg-motivo
                                 ls_reg-kvgr1
                                 ls_reg-kvgr2
                                 ls_reg-kvgr5.

    ls_reco  = ls_reg.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_reg-vbeln
      IMPORTING
        output = ls_reco-vbeln.

    APPEND ls_reco TO ot_reco.
  ENDLOOP.

ENDFORM.                    "leer_archivo


*---------------------------------------------------------------------*
* Form  BDC_DYNPRO
*---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.

  DATA: ls_bdcdata   TYPE bdcdata.

  CLEAR ls_bdcdata.
  ls_bdcdata-program  = program.
  ls_bdcdata-dynpro   = dynpro.
  ls_bdcdata-dynbegin = 'X'.
  APPEND ls_bdcdata TO gt_bdcdata.

ENDFORM.                    "bdc_dynpro


*---------------------------------------------------------------------*
* Form  BDC_FIELD
*---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.

  DATA: ls_bdcdata   TYPE bdcdata.

  CLEAR ls_bdcdata.
  ls_bdcdata-fnam = fnam.
  ls_bdcdata-fval = fval.
  APPEND ls_bdcdata TO gt_bdcdata.

ENDFORM. " FIN BDC_FIELD


*---------------------------------------------------------------------*
* Form  BDC_TRANSACTION
*---------------------------------------------------------------------*
FORM bdc_transaction USING i_tcode i_modo.

  CLEAR: gt_messtab[].

  CALL TRANSACTION i_tcode
    USING gt_bdcdata
    MODE i_modo
    UPDATE 'S'
    MESSAGES INTO gt_messtab.

  CLEAR: gt_bdcdata.

ENDFORM.                    "bdc_transaction


*&---------------------------------------------------------------------*
*&      Form  CALL_IDCP
*&---------------------------------------------------------------------*
FORM pre_idcp  USING  ls_reco  STRUCTURE gs_reco.

  DATA: lt_libro TYPE TABLE OF idcn_boma,
        ls_libro TYPE idcn_boma.

  DATA: lv_lotno  TYPE idcn_boma-lotno,
        lv_lineas TYPE sytabix.

  CLEAR: lv_lotno.

  IF ls_reco-kvgr1 = '02' AND ls_reco-kvgr2 = '01'.
    lv_lotno = 'J1'.
  ENDIF.
  IF ls_reco-kvgr1 = '02' AND ls_reco-kvgr2 = '02'.
    lv_lotno = 'J2'.
  ENDIF.
  IF ls_reco-kvgr1 = '01' AND ls_reco-kvgr2 = '01'.
    lv_lotno = 'J3'.
  ENDIF.
  IF ls_reco-kvgr1 = '01' AND ls_reco-kvgr2 = '02'.
    lv_lotno = 'J4'.
  ENDIF.

  CLEAR: lt_libro[].
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO TABLE lt_libro
*    FROM idcn_boma
*    WHERE bukrs = 'CL51'
*      AND lotno = lv_lotno.
*
* NEW CODE
  SELECT *
 INTO TABLE lt_libro
    FROM idcn_boma
    WHERE bukrs = 'CL51'
      AND lotno = lv_lotno ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  IF sy-subrc = 0.
    DESCRIBE TABLE lt_libro LINES lv_lineas.
    READ TABLE lt_libro INTO ls_libro INDEX lv_lineas.
    IF sy-subrc = 0.
*     Llamamos a la IDCP
      PERFORM call_idcp USING 'CL51'
                              ls_reco-nufac
                              lv_lotno
                              ls_libro-bokno.

      COMMIT WORK AND WAIT.
    ENDIF.
  ELSE.
    gs_reco-error = '3'.
    MODIFY gt_reco FROM gs_reco TRANSPORTING error.
  ENDIF.

ENDFORM.                    " PRE_IDCP


*&---------------------------------------------------------------------*
*&      Form  CALL_IDCP
*&---------------------------------------------------------------------*
FORM call_idcp  USING    p_vkorg
                         p_vbeln
                         p_fkart
                         p_bokno.

  DATA: c_mode   TYPE c VALUE 'N',
        c_update TYPE c VALUE 'S', "L
        l_fkart  TYPE fkart,
        l_kschl  TYPE kschl,
        l_vbeln  TYPE vbrk-vbeln.

** BUSCA EL TIPO DE MENSAJE ASOCIADO A LA FACTURA
*  SELECT SINGLE fkart INTO l_fkart
*         FROM vbrk WHERE vbeln EQ p_vbeln.
*
*  CASE l_fkart.
*    WHEN 'ZBOL'.
*      l_kschl = 'ZBOE'.
*
**    when 'ZNC'.
**      l_kschl = ''. " ???
*
*    WHEN OTHERS.
*      l_kschl = 'ZFAE'.
*  ENDCASE.

  case pp_fkart.
    WHEN 'ZBOL'.
      l_kschl = 'ZBOE'.

*    when 'ZNC'.
*      l_kschl = ''. " ???

    WHEN OTHERS.
      l_kschl = 'ZFAE'.
  endcase.



  REFRESH gt_bdcdata.
  PERFORM bdc_dynpro      USING 'IDPRCNINVOICE' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ONLI'.
  PERFORM bdc_field       USING 'CHK_BILL'
                                'X'.
  PERFORM bdc_field       USING 'VKORG'
                                 p_vkorg.
  PERFORM bdc_field       USING 'LOTNO'
                                 p_fkart.
  PERFORM bdc_field       USING 'BOKNO'
                                 p_bokno.                   "'02'.
  PERFORM bdc_field       USING 'CHK_PRI'
                                'X'.
  PERFORM bdc_dynpro      USING 'IDPRCNINVOICE' '0111'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RFBSK_C'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CRET'.
  PERFORM bdc_field       USING 'PR_NUM'
                                'Local Printer'.
  PERFORM bdc_field       USING 'VBELN-LOW'
                                 p_vbeln.

  PERFORM bdc_field       USING 'MSG_TYPE' l_kschl.
  PERFORM bdc_field       USING 'RFBSK_AB'
                                ''.
  PERFORM bdc_field       USING 'RFBSK_C'
                                'X'.
  PERFORM bdc_field       USING 'NO_RPRT'
                                'X'.

  PERFORM bdc_dynpro      USING 'SAPMSSY0' '0120'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=&ALL'.

  PERFORM bdc_dynpro      USING 'SAPMSSY0' '0120'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BTCI'.

  CALL TRANSACTION 'IDCP' USING gt_bdcdata
                          MESSAGES INTO gt_messtab
                          MODE gv_mode
                          UPDATE c_update.

ENDFORM.                    " CALL_IDCP
