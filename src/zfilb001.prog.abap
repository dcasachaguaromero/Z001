*&---------------------------------------------------------------------*
*& Report  ZFILB002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zfilb001_top                            .    " global Data


INITIALIZATION.

  PERFORM init_global_values.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  PERFORM value_request_path_down CHANGING  p_path.

START-OF-SELECTION.

  PERFORM get_description_bukrs
              USING
                 p_bukrs
              CHANGING
                 g_butxt.

  PERFORM fill_blart.

  PERFORM layout_init
              USING
                 gs_layout.

  PERFORM get_documents.

  PERFORM fieldcat_init
              USING
                  gt_fieldcat
                  gt_fieldcat_100.

  PERFORM show_alv.

  INCLUDE zfilb001_o01                            .  " PBO-Modules
  INCLUDE zfilb001_i01                            .  " PAI-Modules
  INCLUDE zfilb001_f01                            .  " FORM-Routines
