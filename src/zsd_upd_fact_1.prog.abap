*&---------------------------------------------------------------------*
*& Report  ZSD_UPD_FACT_1
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zsd_upd_fact_1.

DATA: BEGIN OF gs_reco,
        vbeln   TYPE vbeln_vf,
      END OF gs_reco.
DATA: gs_vbrk  TYPE vbrk.
DATA: gt_reco  LIKE TABLE OF gs_reco.


*----------------------------------------------------------------------
*                      SELECTION-SCREEN
*----------------------------------------------------------------------
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
PARAMETERS: p_vkorg  TYPE vkorg OBLIGATORY.
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

  LOOP AT gt_reco INTO gs_reco.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO gs_vbrk
*      FROM vbrk
*      WHERE vbeln = gs_reco-vbeln.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO gs_vbrk
      FROM vbrk
      WHERE vbeln = gs_reco-vbeln ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0 AND gs_vbrk-vkorg = p_vkorg.
      CLEAR: gs_vbrk-znum_doc_core.
      MODIFY vbrk FROM gs_vbrk.
    ENDIF.
  ENDLOOP.
  IF sy-subrc = 0.
    MESSAGE i899(m3) WITH text-i01.
  ENDIF.

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
          vbeln   TYPE vbeln_vf,
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

    ls_reg-vbeln = ls_aux-lin.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = ls_reg-vbeln
      IMPORTING
        output = ls_reco-vbeln.

    APPEND ls_reco TO ot_reco.
  ENDLOOP.

ENDFORM.                    "leer_archivo
