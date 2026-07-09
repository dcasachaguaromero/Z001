*&---------------------------------------------------------------------*
*& Report  ZMOVTOSCONTABLES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE ZMOVTOSCONTABLES_TOP                           .    " global Data


INITIALIZATION.

  PERFORM init_global_values.

START-OF-SELECTION.

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

  PERFORM show_alv.

INCLUDE ZMOVTOSCONTABLES_O01.
*  INCLUDE zfilb002_o01                            .  " PBO-Modules
INCLUDE ZMOVTOSCONTABLES_I01.
*  INCLUDE zfilb002_i01                            .  " PAI-Modules
INCLUDE ZMOVTOSCONTABLES_F01.
*  INCLUDE zfilb002_f01                            .  " FORM-Routines
