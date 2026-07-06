*&---------------------------------------------------------------------*
*&  Include           ZFITR040_038_CLI
*&---------------------------------------------------------------------*

CLASS lcl_director IMPLEMENTATION.

  METHOD get_filenames.
*-> iv_bukrs   TYPE bukrs
*-> iv_path    TYPE ztxtmami64
*<- et_tabla   TYPE gtt_tabla
*<- ev_rc      TYPE sy-subrc
*<- ev_message TYPE bapi_msg

    DATA: lt_file_table TYPE STANDARD TABLE OF sdokpath,
          lt_dir_table  TYPE STANDARD TABLE OF sdokpath.

    DATA: lv_fname     TYPE localfile.
    DATA: lv_file_size TYPE  i.

    CLEAR: ev_rc.

*   Lectura de archivos
    CALL FUNCTION 'TMP_GUI_DIRECTORY_LIST_FILES'
      EXPORTING
        directory  = iv_path
        filter     = '*.txt'
      TABLES
        file_table = lt_file_table
        dir_table  = lt_dir_table.

    IF lt_file_table[] IS INITIAL.
      ev_rc = 8.
      ev_message = TEXT-e01.
      RETURN.
    ENDIF.

    CLEAR: et_tabla.

    LOOP AT lt_file_table ASSIGNING FIELD-SYMBOL(<ls_file_table>).
      CONCATENATE iv_path
                  <ls_file_table>-pathname
        INTO lv_fname.

      CALL FUNCTION 'GUI_GET_FILE_INFO'
        EXPORTING
          fname     = lv_fname
        IMPORTING
          file_size = lv_file_size.

      IF <ls_file_table>-pathname+3(2) <> 'RE'.
        APPEND INITIAL LINE TO et_tabla ASSIGNING FIELD-SYMBOL(<ls_tabla>).
        <ls_tabla>-archivo = <ls_file_table>-pathname.
        <ls_tabla>-corre   = <ls_file_table>-pathname+16(20).
        <ls_tabla>-fecha   = <ls_file_table>-pathname+36(8).
        <ls_tabla>-tamano  = lv_file_size.
        <ls_tabla>-sel     = abap_true.
      ENDIF.
    ENDLOOP.

    SORT et_tabla BY fecha corre ASCENDING.

  ENDMETHOD.

  METHOD show_alv.
*<-> CHANGING ct_tabla TYPE gtt_tabla

    set_layout( IMPORTING es_layout        = gs_layout
                          es_grid_settings = gs_grid_settings
    ).

    set_fieldcat( CHANGING ct_fieldcat = gt_fieldcat ).

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = gv_repid
        i_callback_user_command  = 'USER_COMMAND'
        i_callback_pf_status_set = 'PF_STATUS'
        it_fieldcat              = gt_fieldcat
        is_layout                = gs_layout
*       i_save                   = gv_save
        is_variant               = gs_variant
        i_grid_settings          = gs_grid_settings
      TABLES
        t_outtab                 = ct_tabla
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

  METHOD set_layout.
*<-> es_layout TYPE slis_layout_alv.
*<-> es_grid_settings TYPE lvc_s_glay
    CLEAR: es_layout, es_grid_settings.

    es_layout-zebra              = abap_true.
    es_layout-colwidth_optimize  = abap_false.
    es_layout-f2code             = 'DOBCLICK'.  " Activa doble click
    es_layout-box_fieldname      = 'SEL'.

*   Traspasar edición de ALV a tabla interna
    es_grid_settings-edt_cll_cb  = 'X'.
    es_grid_settings-coll_top_p  = 'X'.
    es_grid_settings-coll_end_l  = 'X'.

  ENDMETHOD.

  METHOD set_fieldcat.
*<-> ct_fieldcat TYPE slis_t_fieldcat_alv
    DATA: ls_structure_name TYPE tabname.
    DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
          ls_fieldcat TYPE LINE OF slis_t_fieldcat_alv.


    ls_structure_name = 'ZFITR040_EST'.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = ls_structure_name
      CHANGING
        ct_fieldcat      = lt_fieldcat.

    LOOP AT lt_fieldcat INTO ls_fieldcat.
      IF ls_fieldcat-fieldname = 'ARCHIVO'.
        ls_fieldcat-outputlen = '40'.
        ls_fieldcat-seltext_l = TEXT-a01.
        ls_fieldcat-seltext_m = TEXT-a01.
        MODIFY lt_fieldcat FROM ls_fieldcat.
      ENDIF.

      IF ls_fieldcat-fieldname = 'SEL'.
        ls_fieldcat-no_out = abap_true.
        MODIFY lt_fieldcat FROM ls_fieldcat.
      ENDIF.

      IF ls_fieldcat-fieldname = 'CORRE'.
        ls_fieldcat-seltext_l = TEXT-a02.
        ls_fieldcat-seltext_m = TEXT-a02.
        MODIFY lt_fieldcat FROM ls_fieldcat.
      ENDIF.

      IF ls_fieldcat-fieldname = 'TAMANO'.
        ls_fieldcat-seltext_l = TEXT-a03.
        ls_fieldcat-seltext_m = TEXT-a03.
        MODIFY lt_fieldcat FROM ls_fieldcat.
      ENDIF.

    ENDLOOP.

    ct_fieldcat[] = lt_fieldcat[].

  ENDMETHOD.

  METHOD process_documents.
*-> it_tabla TYPE gtt_tabla.
*-> iv_block TYPE i
*-> is_direc TYPE gty_ztparamftp
*<- et_log   TYPE gtt_log
    DATA: lt_tabla       TYPE gtt_tabla,
          lt_tabla_block TYPE gtt_tabla.

    DATA: lo_ejecutor TYPE REF TO lcl_ejecutor.

    DATA: lv_first_index TYPE i,
          lv_last_index  TYPE i,
          lv_total_lines TYPE c LENGTH 5.

    LOOP AT it_tabla ASSIGNING FIELD-SYMBOL(<ls_tabla>) WHERE sel = 'X'.
      APPEND INITIAL LINE TO lt_tabla ASSIGNING FIELD-SYMBOL(<ls_tabla_f>).
      <ls_tabla_f> = <ls_tabla>.
    ENDLOOP.

    IF lt_tabla IS INITIAL.
*     Debe seleccionar los documentos a tratar
      MESSAGE i018(z1).
      RETURN.
    ENDIF.

    DATA(lv_lines) = lines( lt_tabla ).
    WRITE lv_lines TO lv_total_lines LEFT-JUSTIFIED.

    APPEND INITIAL LINE TO et_log ASSIGNING FIELD-SYMBOL(<ls_log>).
    "Cantidad de archivos seleccionados
    CONCATENATE TEXT-l01 lv_total_lines
      INTO <ls_log>-texto SEPARATED BY space.

    DO.
      IF sy-tabix = 1.
        lv_first_index = 1.
        lv_last_index  = iv_block.
      ELSE.
        lv_first_index = lv_last_index + 1.
        lv_last_index  = lv_last_index + p_block.
      ENDIF.

      CLEAR: lt_tabla_block.
      APPEND LINES OF lt_tabla FROM lv_first_index TO lv_last_index TO lt_tabla_block.

      IF NOT lt_tabla_block IS INITIAL.
*       Se envía a procesar el bloque de documentos
        CREATE OBJECT lo_ejecutor.
        lo_ejecutor->cargar_novedades( EXPORTING it_tabla = lt_tabla_block
                                                 is_direc = is_direc
                                                 iv_fecha = p_budat
                                       CHANGING  ct_log   = et_log
                                      ).
        CLEAR lo_ejecutor.

        COMMIT WORK AND WAIT.
      ENDIF.

      IF lv_last_index >= lv_total_lines OR lt_tabla_block IS INITIAL.
        EXIT.
      ENDIF.

    ENDDO.

  ENDMETHOD.

  METHOD show_log.
*-> it_log TYPE gtt_log
    DATA(lt_log) = it_log.

    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_alv)
                                CHANGING  t_table      = lt_log
        ).

        lo_alv->display( ).

      CATCH cx_salv_msg INTO DATA(lx_salv).
        WRITE lx_salv->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD down_log.
*-> it_log TYPE gtt_log
    DATA: lv_path  TYPE string,
          lv_file  TYPE string,
          lv_datum TYPE c LENGTH 8,
          lv_uzeit TYPE c LENGTH 8.

    lv_path = '/tmp/NovPagSant_'.
    lv_datum = sy-datum.
    lv_uzeit = sy-uzeit.

    lv_path = |{ lv_path }{ lv_datum }_{ lv_uzeit }.log|.

    OPEN DATASET lv_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

    LOOP AT it_log ASSIGNING FIELD-SYMBOL(<ls_log>).
      TRANSFER <ls_log>-texto TO lv_path.
    ENDLOOP.

    CLOSE DATASET lv_path.

  ENDMETHOD.

ENDCLASS.


CLASS lcl_ejecutor IMPLEMENTATION.

  METHOD cargar_novedades.
*->  it_tabla TYPE gtt_tabla
*->  is_direc TYPE gty_ztparamftp
*->  iv_fecha TYPE budat
*<-> ct_log   TYPE gtt_log

    DATA: ls_zfitr040_log TYPE zfitr040_log.

    DATA: lt_data TYPE gtt_data.

    DATA: lv_fecha    TYPE sydatum,
          lv_filename TYPE string,
          lv_nomina   TYPE num15,
          lv_fname    TYPE c LENGTH 12,
          lv_men      TYPE c LENGTH 30,
          lv_cta      TYPE numc15,
          lv_nuevos   TYPE n LENGTH 6,
          lv_estado8  TYPE n LENGTH 6,
          lv_idpagoe  TYPE n LENGTH 6,
          lv_rechazo  TYPE n LENGTH 6,
          lv_errtra   TYPE n LENGTH 6,
          lv_errvvi   TYPE n LENGTH 6,
          lv_suma     TYPE n LENGTH 15,
          lv_sumar    TYPE n LENGTH 15.

    lv_fecha = iv_fecha.
***
    LOOP AT it_tabla ASSIGNING FIELD-SYMBOL(<ls_tabla>).

      CONCATENATE is_direc-zruta <ls_tabla>-archivo
        INTO lv_filename.

      me->upload_from_gui( EXPORTING iv_filename = lv_filename
                           IMPORTING et_data     = lt_data
                          ).

      READ TABLE lt_data ASSIGNING FIELD-SYMBOL(<ls_data>) INDEX 3.

      DATA(lv_bukrs) = <ls_data>+143(4).

      CONCATENATE '0' sy-datum+0(8) sy-uzeit
        INTO lv_nomina.

      CONCATENATE 'ZFITR040' '037B'   "Se mantiene el nombre del programa original
        INTO lv_fname.

      CALL FUNCTION lv_fname
        EXPORTING
          soc     = lv_bukrs
          banco   = '037'
          nom     = lv_nomina
          p_fecha = lv_fecha
        IMPORTING
          men     = lv_men
          cta     = lv_cta
          nuevos  = lv_nuevos
          estado8 = lv_estado8
          idpagoe = lv_idpagoe
          rechazo = lv_rechazo
          errtra  = lv_errtra
          errvvi  = lv_errvvi
          suma    = lv_suma
          sumar   = lv_sumar
        TABLES
          t_exc   = lt_data.

      APPEND INITIAL LINE TO ct_log ASSIGNING FIELD-SYMBOL(<ls_log>). "Línea vacía

      APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
      WRITE: 'Archivo : ',  <ls_tabla>-archivo TO <ls_log>-texto.

      IF lv_men <> ' '.
        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = '---------------------------------------------------------------------'.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Parametro Sociedad: { lv_bukrs }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = 'Parametro Banco: 037'.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Parametro Nómina: { lv_nomina }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = '---------------------------------------------------------------------'.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = 'Existen diferencias entre datos de banco y sociedad y datos de archivo.'.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Error: { lv_men }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = 'Archivo no Procesado'.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = '---------------------------------------------------------------------'.

*       Actualiza tabla de logs
        CLEAR ls_zfitr040_log.
        ls_zfitr040_log-zbukr    = lv_bukrs.
        ls_zfitr040_log-programa = 'ZFITR040_038'.
        MOVE sy-datum    TO ls_zfitr040_log-fecha.
        MOVE sy-uzeit    TO ls_zfitr040_log-hora.
        MOVE lv_filename TO ls_zfitr040_log-arch.
        MOVE lv_nomina   TO ls_zfitr040_log-nomina.
        CONCATENATE 'Archivo no Procesado' lv_men
          INTO ls_zfitr040_log-men SEPARATED BY space.

        INSERT zfitr040_log FROM ls_zfitr040_log.

      ELSE.
        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Registros procesados: { lv_cta }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Registros nuevos: { lv_nuevos }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Registros ID pago erroneo { lv_idpagoe }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Registros rechazados { lv_rechazo }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Estado erroneo  Transfers { lv_errtra }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Estado erroneo  Vale Vista { lv_errvvi }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Suma de Montos grabados { lv_suma } |.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        <ls_log>-texto = |Suma de Montos Rechazados { lv_sumar }|.

        APPEND INITIAL LINE TO ct_log ASSIGNING <ls_log>.
        IF lv_sumar IS INITIAL.
          <ls_log>-texto = 'Archivo procesado sin errores'.
        ELSE.
          <ls_log>-texto = 'Archivo procesado con errores'.
        ENDIF.

*       Actualiza tabla de logs
        CLEAR ls_zfitr040_log.
        ls_zfitr040_log-zbukr    = lv_bukrs.
        ls_zfitr040_log-programa = 'ZFITR040_038'.
        MOVE sy-datum    TO ls_zfitr040_log-fecha.
        MOVE sy-uzeit    TO ls_zfitr040_log-hora.
        MOVE lv_filename TO ls_zfitr040_log-arch.
        MOVE lv_nomina   TO ls_zfitr040_log-nomina.
        MOVE lv_cta      TO ls_zfitr040_log-proces.
        MOVE lv_nuevos   TO ls_zfitr040_log-nuevos.
        MOVE lv_estado8  TO ls_zfitr040_log-nulos.
        MOVE lv_idpagoe  TO ls_zfitr040_log-iderr.
        MOVE lv_rechazo  TO ls_zfitr040_log-rechaz.
        MOVE lv_errtra   TO ls_zfitr040_log-trerr.
        MOVE lv_errvvi   TO ls_zfitr040_log-vverr.
        MOVE lv_suma     TO ls_zfitr040_log-mongr.
        MOVE lv_sumar    TO ls_zfitr040_log-monrec.

        IF lv_sumar IS INITIAL.
          MOVE 'Archivo procesado sin errores' TO  ls_zfitr040_log-men.
        ELSE.
          MOVE 'Archivo procesado con errores' TO  ls_zfitr040_log-men.
        ENDIF.
        INSERT zfitr040_log FROM ls_zfitr040_log.

        ren_procesado( EXPORTING is_direc   = is_direc
                                 it_data    = lt_data
                                 iv_archivo = <ls_tabla>-archivo
                     ).
      ENDIF.

    ENDLOOP.
***

  ENDMETHOD.

  METHOD ren_procesado.
*-> is_direc   TYPE gty_ztparamftp
*-> it_data    TYPE gtt_data
*-> iv_archivo TYPE AUSZF

    DATA: lv_nomfile     TYPE string,
          lv_nomfile_del TYPE c LENGTH 128.

    CONCATENATE is_direc-zruta_respaldo iv_archivo INTO lv_nomfile.

*   Deja archivo de respaldo
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename = lv_nomfile
        filetype = 'DAT'
      TABLES
        data_tab = it_data.

    IF sy-subrc <> 0.

    ENDIF.

* Se borra el archivo original
    CONCATENATE is_direc-zruta iv_archivo INTO lv_nomfile_del.

    CALL FUNCTION 'TMP_GUI_DELETE_FILE'
      EXPORTING
        file_name = lv_nomfile_del.

    IF sy-subrc <> 0.

    ENDIF.

  ENDMETHOD.

  METHOD upload_from_gui.

    CLEAR: et_data.

    CALL FUNCTION 'GUI_UPLOAD'
      EXPORTING
        filename = iv_filename
        filetype = 'DAT'
      TABLES
        data_tab = et_data.

    WAIT UP TO 1 SECONDS.

  ENDMETHOD.

ENDCLASS.
