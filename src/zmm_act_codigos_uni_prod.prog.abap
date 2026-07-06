*&---------------------------------------------------------------------*
*& Report ZMM_ACT_CODIGOS_UNI_PROD
*&---------------------------------------------------------------------*
*& Compañía   : BANMEDICA
*& Autor      : Vision One # CNN
*& Fecha      : 11.09.2024
*& Objetivo   : Actualziación de tabla ZUNID_PROD
*&              Transacción ZFIMANT_002
*&---------------------------------------------------------------------
*&                       MODIFICACIONES
*&---------------------------------------------------------------------
*& Modificó   :
*& Fecha      :
*& Solicitó   :
*& Transporte :
*& Objetivo   :
*&---------------------------------------------------------------------
*&
*&---------------------------------------------------------------------
REPORT zmm_act_codigos_uni_prod.

CONSTANTS: gc_tcode TYPE tcode VALUE 'ZFIMANT_002'.

DATA: gt_vimsellist TYPE geft_vimsellist.

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b1.

*--------------------------------------------------------------------*
* INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
            ID 'TCD' FIELD gc_tcode.

  IF sy-subrc <> 0.
*   Falta autorización para transacción &
    MESSAGE e077(s#) WITH gc_tcode.
  ENDIF.

*----------------------------------------------------------------------
* AT SELECTION-SCREEN
*----------------------------------------------------------------------
AT SELECTION-SCREEN ON p_bukrs.

  SELECT SINGLE FROM t001 FIELDS @abap_true
    WHERE bukrs = @p_bukrs
    INTO @DATA(lv_result).
  IF sy-subrc <> 0.
*   La sociedad & no está prevista
    MESSAGE e165(f5) WITH p_bukrs.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs
           ID 'ACTVT' FIELD '03'.

  IF sy-subrc <> 0.
*   Ud. carece de autorización para la sociedad &.
    MESSAGE e460(f5) WITH p_bukrs.
  ENDIF.

*--------------------------------------------------------------------*
*                     BEGIN
*--------------------------------------------------------------------*
START-OF-SELECTION.

  APPEND INITIAL LINE TO gt_vimsellist ASSIGNING FIELD-SYMBOL(<fs_vimsellist>).
  <fs_vimsellist>-viewfield = 'BUKRS'.
  <fs_vimsellist>-operator  = 'EQ'.
  <fs_vimsellist>-value     = p_bukrs.

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      action                       = 'U'
      view_name                    = 'ZUNID_PROD'
*     VARIANT_FOR_SELECTION        = ' '
*     COMPLEX_SELCONDS_USED        = ' '
    TABLES
      dba_sellist                  = gt_vimsellist
*     EXCL_CUA_FUNCT               =
    EXCEPTIONS
      client_reference             = 1
      foreign_lock                 = 2
      invalid_action               = 3
      no_clientindependent_auth    = 4
      no_database_function         = 5
      no_editor_function           = 6
      no_show_auth                 = 7
      no_tvdir_entry               = 8
      no_upd_auth                  = 9
      only_show_allowed            = 10
      system_failure               = 11
      unknown_field_in_dba_sellist = 12
      view_not_found               = 13
      maintenance_prohibited       = 14
      OTHERS                       = 15.

  IF sy-subrc <> 0.
*   Error &1 en vista de actualización de la tabla &2
  ENDIF.
