*&---------------------------------------------------------------------*
*&  Include           ZFITR040_038_CLD
*&---------------------------------------------------------------------*
CLASS lcl_director DEFINITION.

  PUBLIC SECTION.

    DATA: gs_layout        TYPE slis_layout_alv,
          gs_grid_settings TYPE lvc_s_glay.

    DATA: gt_fieldcat TYPE slis_t_fieldcat_alv.

    METHODS:
      get_filenames IMPORTING iv_bukrs   TYPE bukrs
                              iv_path    TYPE ztxtmami64
                    EXPORTING et_tabla   TYPE gtt_tabla
                              ev_rc      TYPE sy-subrc
                              ev_message TYPE bapi_msg,

      show_alv      CHANGING ct_tabla    TYPE gtt_tabla,

      process_documents IMPORTING it_tabla TYPE gtt_tabla
                                  iv_block TYPE i
                                  is_direc TYPE gty_ztparamftp
                        EXPORTING et_log   TYPE gtt_log,

      show_log IMPORTING it_log TYPE gtt_log,

      down_log IMPORTING it_log TYPE gtt_log.


  PRIVATE SECTION.

    METHODS:
      set_layout EXPORTING es_layout        TYPE slis_layout_alv
                           es_grid_settings TYPE lvc_s_glay,

      set_fieldcat CHANGING ct_fieldcat TYPE slis_t_fieldcat_alv.

ENDCLASS.

CLASS lcl_ejecutor DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF gty_data,
             todo TYPE c LENGTH 581,
           END OF gty_data,

           gtt_data TYPE STANDARD TABLE OF gty_data.

    METHODS:
      cargar_novedades IMPORTING it_tabla TYPE gtt_tabla
                                 is_direc TYPE gty_ztparamftp
                                 iv_fecha TYPE budat
                       CHANGING  ct_log   TYPE gtt_log,

      ren_procesado IMPORTING is_direc   TYPE gty_ztparamftp
                              it_data    TYPE gtt_data
                              iv_archivo TYPE auszf,

      upload_from_gui IMPORTING iv_filename TYPE string
                      EXPORTING et_data     TYPE gtt_data.

ENDCLASS.
