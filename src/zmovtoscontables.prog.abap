*&---------------------------------------------------------------------*
*& Report  ZMOVTOSCONTABLES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zmovtoscontables_top                           .    " global Data

INITIALIZATION.

  PERFORM init_global_values.

START-OF-SELECTION.

*  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
*    ID 'BUKRS' FIELD p_bukrs .
*  IF sy-subrc <> 0.
*    MESSAGE e083(f5) WITH p_bukrs .
*  ENDIF.

  PERFORM get_description_bukrs.
*              USING
*                 p_bukrs
*              CHANGING
*                 g_butxt.

  PERFORM layout_init
              USING
                 gs_layout.

  PERFORM get_documents.

  PERFORM fieldcat_init
              USING
                  gt_fieldcat
                  gt_fieldcat_100.

  IF x_ser = 'X'.
    PERFORM genera_txt.
  ELSE.
    PERFORM show_alv.
  ENDIF.

  INCLUDE zmovtoscontables_o01.
*  INCLUDE zfilb002_o01                            .  " PBO-Modules
  INCLUDE zmovtoscontables_i01.
*  INCLUDE zfilb002_i01                            .  " PAI-Modules
  INCLUDE zmovtoscontables_f01.
*  INCLUDE zfilb002_f01                            .  " FORM-Routines
