*&---------------------------------------------------------------------*
*& Report  ZFILB002
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

INCLUDE zfilb002_top                            .    " global Data


INITIALIZATION.

  PERFORM init_global_values.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  PERFORM value_request_path_down CHANGING  p_path.
*selection-screen begin of screen 0500. ZICLOS Abril 2011
  AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_plce.
  PERFORM value_request_path_down CHANGING  p_plce.

*selection-screen end of screen 0500.


START-OF-SELECTION.
*ziclos abril 2011
  perform cargar_tabla_doc_sii.
* ziclos fin 2011
* ziclos mayo 2011
* buscamos el porcentaje de IVA proporcional 100 - valor de la tabla ZFIIVAPRP
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * from ZFIIVAPRP into table ta_ZFIIVAPRP where
*                                      bukrs = p_bukrs .
*
* NEW CODE
  SELECT *
 from ZFIIVAPRP into table ta_ZFIIVAPRP where
                                      bukrs = p_bukrs  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


* ziclos fin 2011 mayo
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

  INCLUDE zfilb002_o01                            .  " PBO-Modules
  INCLUDE zfilb002_i01                            .  " PAI-Modules
  INCLUDE zfilb002_f01                            .  " FORM-Routines
