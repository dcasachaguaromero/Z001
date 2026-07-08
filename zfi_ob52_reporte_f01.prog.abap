*&---------------------------------------------------------------------*
*&  Include           ZFI_OB52_REPORTE_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  AUTORIZACION
*&---------------------------------------------------------------------*
FORM autorizacion .
  AUTHORITY-CHECK OBJECT 'S_TCODE'
    ID 'TCD' FIELD sy-tcode.
  IF sy-subrc <> 0.
    MESSAGE e899(fi) WITH TEXT-e01.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA: lt_datos TYPE TABLE OF zfi_ob52_repor,
        lr_aprob TYPE RANGE OF zfi_ob52_repor-aprobar.
*
  CLEAR : gt_datos[], gt_datos_aud[].
  UNASSIGN <tables>.
*
  SELECT SINGLE reporte INTO @DATA(lv_reporte)
         FROM zfi_ob52_user WHERE bukrs IN @s_bukrs
                            AND   bname EQ @sy-uname.
  IF sy-subrc EQ 0 AND lv_reporte EQ gc_x.
    IF p_aprob IS NOT INITIAL.
      lr_aprob = VALUE #(  sign = 'I' option = 'EQ'
                          ( low  = p_aprob ) ).
    ENDIF.
*
    CASE sy-tcode.
      WHEN 'Z_A_OB52'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * INTO TABLE gt_tob52
*               FROM zfi_ob52_repor WHERE bukrs   IN s_bukrs AND
*                                         datum   IN s_datum AND
*                                         bname   IN s_bname AND
*                                         aprobar IN lr_aprob.
*
* NEW CODE
        SELECT *
 INTO TABLE gt_tob52
               FROM zfi_ob52_repor WHERE bukrs   IN s_bukrs AND
                                         datum   IN s_datum AND
                                         bname   IN s_bname AND
                                         aprobar IN lr_aprob ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        CHECK sy-subrc EQ 0.
        SORT gt_tob52 BY rrcty bukrs mkoar bkont datum uzeit.
        LOOP AT gt_tob52 INTO DATA(lw_datos).
          MOVE-CORRESPONDING lw_datos TO wa_datos.
          APPEND wa_datos TO gt_datos.
        ENDLOOP.
        SORT gt_datos BY rrcty bukrs bname datum uzeit.
        DELETE ADJACENT DUPLICATES FROM gt_datos
                   COMPARING rrcty bukrs bname datum uzeit.
        ASSIGN TABLE FIELD gt_datos TO <tables>.
      WHEN OTHERS.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * INTO TABLE gt_tob52
*               FROM zfi_ob52_repor WHERE bukrs       IN s_bukrs AND
*                                         datum_mod   IN s_datum AND
*                                         uname_mod   IN s_bname AND
*                                         aprobar     IN lr_aprob.
*
* NEW CODE
        SELECT *
 INTO TABLE gt_tob52
               FROM zfi_ob52_repor WHERE bukrs       IN s_bukrs AND
                                         datum_mod   IN s_datum AND
                                         uname_mod   IN s_bname AND
                                         aprobar     IN lr_aprob ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
        CHECK sy-subrc EQ 0.
        SORT gt_tob52 BY rrcty bukrs mkoar vkont bkont datum uzeit.
        LOOP AT gt_tob52 INTO lw_datos.
          MOVE-CORRESPONDING lw_datos TO wa_datos_aud.
          APPEND wa_datos_aud TO gt_datos_aud.
        ENDLOOP.
        ASSIGN TABLE FIELD gt_datos_aud TO <tables>.
    ENDCASE.
  ELSE.
    MESSAGE i899(fi) WITH 'Sin autorización a ver reporte'.
  ENDIF.
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_sort       TYPE lvc_t_sort,
        lt_fieldcat   TYPE lvc_t_fcat,
        wa_layout     TYPE lvc_s_layo,
        wa_variant    TYPE disvariant,
        lv_grid_title TYPE  lvc_title.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM fieldcat_init   USING lt_fieldcat[].
  PERFORM sort            USING lt_sort[].
*
  CASE sy-tcode.
    WHEN 'Z_A_OB52'.
      SET TITLEBAR '0100' WITH 'Aprobar o Rechazar el proceso de Var. Periodo Contable'.
    WHEN OTHERS.
      SET TITLEBAR '0100' WITH 'Reporte de Auditoria del proceso de Var. Periodo Contable'.
  ENDCASE.
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_grid_title             = lv_grid_title
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      is_variant               = wa_variant
      it_sort_lvc              = lt_sort
      i_save                   = 'A'
    TABLES
      t_outtab                 = <tables>
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm    LIKE sy-ucomm            "#EC NEEDED
                        rs_selfield TYPE slis_selfield.     "#EC CALLED

  CASE rs_selfield-fieldname.
    WHEN 'SEMAFORO'.
      CHECK sy-tcode EQ 'Z_A_OB52'.
      READ TABLE gt_datos INTO wa_datos INDEX rs_selfield-tabindex.
      IF sy-subrc EQ 0 AND wa_datos-semaforo EQ icon_yellow_light.
        PERFORM muestra_aprobar USING wa_datos.
        rs_selfield-refresh = gc_x.
      ELSE.
        MESSAGE w899(fi) WITH 'Dato no es seleccionable'.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE,
        l_procesado      TYPE char50.
*
  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE lvc_s_layo.
  CLEAR rs_layout.
*  rs_layout-f2code               = 'DISPLAY'.
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
  DATA : lv_tabla TYPE char30.
*
  CASE sy-tcode.
    WHEN 'Z_A_OB52'.  MOVE gc_tabla     TO lv_tabla.
    WHEN OTHERS.      MOVE gc_tabla_aud TO lv_tabla.
  ENDCASE.
*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = lv_tabla
    CHANGING
      ct_fieldcat            = p_gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*
  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<datos>).
*
    CASE <datos>-fieldname.
      WHEN 'RRCTY'.
        <datos>-tech      = gc_x.
      WHEN 'BUKRS' OR 'MKOAR' OR 'VKONT' or 'BKONT' .
        <datos>-key       = gc_x.
      WHEN 'BNAME'.
        IF sy-tcode EQ 'Z_A_OB52'.
          <datos>-scrtext_m = 'Usuario'.
        ELSE.
          <datos>-scrtext_m = 'Usuario Solicitud'.
        ENDIF.
      WHEN 'MOTIVO_TXT'.
        IF sy-tcode EQ 'Z_A_OB52'.
          <datos>-scrtext_m = 'Motivo'.
        ELSE.
          <datos>-tech      = gc_x.
        ENDIF.
      WHEN 'SEMAFORO'.
        <datos>-icon      = gc_x.
        IF sy-tcode EQ 'Z_A_OB52'.
          <datos>-scrtext_m = 'Aprobar'.
          <datos>-hotspot   = gc_x.
        ELSE.
          <datos>-scrtext_m = 'Status'.
        ENDIF.
      WHEN 'APROBAR'.
        <datos>-tech      = gc_x.
      WHEN 'TEXTO_AJUSTE1'.
        <datos>-scrtext_m = 'Periodo 1'.
      WHEN 'TEXTO_AJUSTE2'.
        <datos>-scrtext_m = 'Periodo 2'.
      WHEN 'MENSAJE'.
        <datos>-scrtext_m = 'Mensaje Ajuste'.
      WHEN 'MAIL_ENVIADO'.
        <datos>-scrtext_m = 'Mail Enviado'.
      WHEN 'MONAT_GJAHR1'     OR 'MONAT_GJAHR2' OR
           'MONAT_GJAHR1_ORI' OR 'MONAT_GJAHR2_ORI'.
        <datos>-tech      = gc_x.
      WHEN 'DATUM_MOD'.
        <datos>-scrtext_m = 'Fecha Mod.'.
      WHEN 'UZEIT_MOD'.
        <datos>-scrtext_m = 'Hora Mod.'.
      WHEN 'UNAME_MOD'.
        <datos>-scrtext_m = 'Usuario Mod.'.
    ENDCASE.
    <datos>-colddictxt = 'M'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SORT
*&---------------------------------------------------------------------*
FORM sort  USING    p_lt_sort TYPE lvc_t_sort.
  DATA lw_sort TYPE lvc_s_sort.
*
  CLEAR p_lt_sort[].
  lw_sort-fieldname = 'BUKRS'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.

  lw_sort-fieldname = 'BNAME'.
  APPEND lw_sort TO p_lt_sort.

  lw_sort-fieldname = 'DATUM'.
  APPEND lw_sort TO p_lt_sort.

  lw_sort-fieldname = 'UZEIT'.
  APPEND lw_sort TO p_lt_sort.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_APROBAR
*&---------------------------------------------------------------------*
FORM muestra_aprobar USING lw_datos TYPE zefi_ob52_repor. "zfi_ob52_repor.

  IF wa_datos-semaforo NE icon_yellow_light.
    CLEAR gv_aprobar.
  ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE aprobar INTO gv_aprobar
*          FROM zfi_ob52_user WHERE bukrs EQ lw_datos-bukrs
*                              AND  bname EQ sy-uname.
*
* NEW CODE
    SELECT aprobar
    UP TO 1 ROWS  INTO gv_aprobar
          FROM zfi_ob52_user WHERE bukrs EQ lw_datos-bukrs
                              AND  bname EQ sy-uname ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

  SELECT * INTO TABLE gt_t001b
         FROM t001b WHERE rrcty EQ '0'
                      AND bukrs EQ lw_datos-bukrs
                      ORDER BY PRIMARY KEY.
*
  SELECT * INTO TABLE gt_zt001b
         FROM zfi_ob52_t001b WHERE rrcty EQ '0'
                               AND bukrs EQ lw_datos-bukrs
                               ORDER BY PRIMARY KEY.
*
  CALL SCREEN 100.
*
  LOOP AT gt_datos ASSIGNING FIELD-SYMBOL(<wa_datos>)
                                 WHERE rrcty EQ lw_datos-rrcty
                                   AND bukrs EQ lw_datos-bukrs
                                   AND bname EQ lw_datos-bname
                                   AND datum EQ lw_datos-datum
                                   AND uzeit EQ lw_datos-uzeit.
    <wa_datos>-aprobar  = wa_datos-aprobar.
    <wa_datos>-semaforo = wa_datos-semaforo.
    <wa_datos>-mensaje  = wa_datos-mensaje .
*
    <wa_datos>-datum_mod = sy-datum.
    <wa_datos>-uzeit_mod = sy-uzeit.
    <wa_datos>-uname_mod = sy-uname.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  APROBAR
*&---------------------------------------------------------------------*
FORM aprobar .
  DATA : lt_ob52_mail TYPE TABLE OF zfi_ob52_repor,
         lw_ob52_mail TYPE zfi_ob52_repor.
* RFOB5200
  CALL FUNCTION 'VIEW_WRITE_CHANGELOG_HEADER'
    EXPORTING
      viewname = 'V_T001B'
      bastab   = space
      begin    = 'X'
      clidep   = 'X'.

  LOOP AT gt_zt001b INTO wa_zt001b WHERE bukrs   EQ wa_datos-bukrs.
* actualiza la tabla del reporte.
    wa_datos-aprobar  = ''.
    wa_datos-semaforo = icon_green_light.
    wa_datos-mensaje  = 'Valor ajustado por el Aprobador' && | | && sy-uname.
*
    IF wa_zt001b-aprobar EQ gc_x.
* actualiza la tabla estandar.
      UPDATE t001b SET : frpe1 = wa_zt001b-frpe1
                         frye1 = wa_zt001b-frye1
                         frpe2 = wa_zt001b-frpe2
                         frye2 = wa_zt001b-frye2
                   WHERE rrcty   EQ wa_zt001b-rrcty AND
                         bukrs   EQ wa_zt001b-bukrs AND
                         mkoar   EQ wa_zt001b-mkoar AND
                         bkont   EQ wa_zt001b-bkont.
*
      MOVE-CORRESPONDING wa_datos TO lw_ob52_mail.
      MOVE : wa_zt001b-bkont TO lw_ob52_mail-bkont.
      APPEND lw_ob52_mail  TO lt_ob52_mail.
    ENDIF.

* atualiza la tabla de respado
    UPDATE zfi_ob52_t001b SET aprobar = ''
                 WHERE rrcty   EQ wa_zt001b-rrcty AND
                       bukrs   EQ wa_zt001b-bukrs AND
                       mkoar   EQ wa_zt001b-mkoar AND
                       bkont   EQ wa_zt001b-bkont.
*
    UPDATE zfi_ob52_repor SET : aprobar   = wa_datos-aprobar
                                semaforo  = wa_datos-semaforo
                                mensaje   = wa_datos-mensaje
                                datum_mod = sy-datum
                                uzeit_mod = sy-uzeit
                                uname_mod = sy-uname
                 WHERE rrcty   EQ wa_zt001b-rrcty AND
                       bukrs   EQ wa_zt001b-bukrs AND
                       mkoar   EQ wa_zt001b-mkoar AND
                       bkont   EQ wa_zt001b-bkont AND
                       bname   EQ wa_datos-bname  AND
                       datum   EQ wa_datos-datum  AND
                       uzeit   EQ wa_datos-uzeit.

    COMMIT WORK AND WAIT.
  ENDLOOP.

  CALL FUNCTION 'FAGL_R_WRITE_PERIOD_TRACK'.
  CALL FUNCTION 'VIEW_WRITE_CHANGELOG_HEADER'
    EXPORTING
      viewname = 'V_T001B'
      bastab   = space
      begin    = space
      clidep   = 'X'.
*
  PERFORM envio_mail TABLES lt_ob52_mail
                     USING  TEXT-apr ''.
*
  MESSAGE i899(fi) WITH 'Proceso actualizado'.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  RECHAZAR
*&---------------------------------------------------------------------*
FORM rechazar .
  DATA : lt_ob52_mail TYPE TABLE OF zfi_ob52_repor,
         lw_ob52_mail TYPE zfi_ob52_repor.
*
  LOOP AT gt_zt001b INTO wa_zt001b WHERE bukrs    EQ wa_datos-bukrs.
* actualiza la tabla del reporte.
    wa_datos-aprobar  = ''.
    wa_datos-semaforo = icon_red_light.
    wa_datos-mensaje  = 'Valor Rechazado por el Aprobador' && | | && sy-uname.

    IF wa_zt001b-aprobar EQ gc_x.
      MOVE-CORRESPONDING wa_datos TO lw_ob52_mail.
      MOVE : wa_zt001b-bkont TO lw_ob52_mail-bkont.
      APPEND lw_ob52_mail  TO lt_ob52_mail.
    ENDIF.
* atualiza la tabla de respado
    UPDATE zfi_ob52_t001b SET aprobar = ''
                 WHERE rrcty   EQ wa_zt001b-rrcty AND
                       bukrs   EQ wa_zt001b-bukrs AND
                       mkoar   EQ wa_zt001b-mkoar AND
                       bkont   EQ wa_zt001b-bkont.

    UPDATE zfi_ob52_repor SET : aprobar   = wa_datos-aprobar
                                semaforo  = wa_datos-semaforo
                                mensaje   = wa_datos-mensaje
                                datum_mod = sy-datum
                                uzeit_mod = sy-uzeit
                                uname_mod = sy-uname
                 WHERE rrcty   EQ wa_zt001b-rrcty AND
                       bukrs   EQ wa_zt001b-bukrs AND
                       mkoar   EQ wa_zt001b-mkoar AND
                       bkont   EQ wa_zt001b-bkont AND
                       bname   EQ wa_datos-bname  AND
                       datum   EQ wa_datos-datum  AND
                       uzeit   EQ wa_datos-uzeit.

    COMMIT WORK AND WAIT.
  ENDLOOP.
*
  PERFORM envio_mail TABLES lt_ob52_mail
                     USING  TEXT-rec gc_x.
*
  MESSAGE i899(fi) WITH 'Proceso actualizado'.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ENVIO_MAIL
*&---------------------------------------------------------------------*
FORM envio_mail  TABLES  p_lt_ob52_mail STRUCTURE zfi_ob52_repor
                 USING   p_msj
                         p_opcion.
  DATA: lt_addr        TYPE bcsy_smtpa,
        lt_addr_copia  TYPE bcsy_smtpa,
        lt_emails      TYPE TABLE OF zfi_ob52_mail,
        lcl_send_email TYPE REF TO cl_bcs,
        lv_subject     TYPE so_obj_des,
        lcl_document   TYPE REF TO cl_document_bcs,
        lcl_recipient  TYPE REF TO if_recipient_bcs,
        lv_sent_to_all TYPE os_boolean,
        lcl_sender     TYPE REF TO cl_cam_address_bcs,
        lv_address     TYPE adr6-smtp_addr,
*
        bcs_exception  TYPE REF TO cx_bcs,
        lv_error_msg   TYPE string,
        lt_page        TYPE soli_tab,
        lt_page_body   TYPE TABLE OF soli,
        lw_message     TYPE soli,
        lv_page_header TYPE soli-line,
        lv_font_size   TYPE numc4,
        lv_font_type   TYPE char20,
        lv_font_color  TYPE soli-line,
        lv_border      TYPE numc4,
        lv_cellpadding TYPE numc4,
        lv_caption     TYPE string,
        lv_date        TYPE char10.
  CONSTANTS : lc_x TYPE c LENGTH 01 VALUE 'X'.

  DATA(lw_ob52) = p_lt_ob52_mail[ 1 ].

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO TABLE lt_emails
*         FROM zfi_ob52_mail WHERE bukrs EQ lw_ob52-bukrs
*                             AND  bname EQ lw_ob52-bname.
*
* NEW CODE
  SELECT *
 INTO TABLE lt_emails
         FROM zfi_ob52_mail WHERE bukrs EQ lw_ob52-bukrs
                             AND  bname EQ lw_ob52-bname ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  CHECK sy-subrc EQ 0.

* Recoge los emails y los añade a la tabla de destinatario
  LOOP AT lt_emails[] ASSIGNING FIELD-SYMBOL(<fs_mail>).
    IF <fs_mail>-smtp_addr1 IS NOT INITIAL.
      APPEND <fs_mail>-smtp_addr1 TO lt_addr.
    ENDIF.
    IF <fs_mail>-smtp_addr2 IS NOT INITIAL.
      APPEND <fs_mail>-smtp_addr2 TO lt_addr.
    ENDIF.
    IF <fs_mail>-smtp_addr3 IS NOT INITIAL.
      PERFORM prepara_correos TABLES lt_addr_copia
                              USING <fs_mail>-smtp_addr3.
    ENDIF.
  ENDLOOP.

* Cuerpo del email
  lw_message-line = '<b>Detalle Solicitud</b>' && | | && p_msj.
  APPEND lw_message TO lt_page_body.
  lw_message-line = '<P> </P>'.
  APPEND lw_message TO lt_page_body.
*
  PERFORM add_page_header TABLES lt_page
                                 lt_page_body
                          USING  lv_page_header
                                 lv_font_size
                                 lv_font_type
                                 lv_font_color.
  lv_border  = 1.    "create border width for table
  PERFORM start_table TABLES lt_page
                      USING  lv_border
                             lv_cellpadding
                             lv_caption.
*
  PERFORM start_row       TABLES lt_page.
  PERFORM encabezados     TABLES lt_page.
  PERFORM end_row         TABLES lt_page.
  PERFORM detalle         TABLES lt_page
                                 p_lt_ob52_mail
                          USING  lw_ob52 p_opcion.
  PERFORM end_table       TABLES lt_page.
  PERFORM add_page_footer TABLES lt_page.
*
  TRY.
*     ### create persistent send request ########
      lcl_send_email = cl_bcs=>create_persistent( ).
* Crear documento
      CONDENSE lw_ob52-monat_gjahr1.
      lv_subject   = 'Reapertura Periodo Contable de ' && | | && lw_ob52-bukrs && | de | && lw_ob52-monat_gjahr1.
*
      lcl_document = cl_document_bcs=>create_document(
                      i_type    = 'HTM'
                      i_text    = lt_page
                      i_subject = lv_subject ).
*     add document to send request
      CALL METHOD lcl_send_email->set_document( lcl_document ).

* Añadir remitente
      lv_address  = 'servicio.sap@cscbanmedica.cl'.
      lcl_sender = cl_cam_address_bcs=>create_internet_address( lv_address  ).
      lcl_send_email->set_sender( i_sender = lcl_sender ).

* Añadir destinatarios al email
      LOOP AT lt_addr ASSIGNING FIELD-SYMBOL(<fs_addr>).
        lcl_recipient  = cl_cam_address_bcs=>create_internet_address( <fs_addr> ).
        lcl_send_email->add_recipient( i_recipient = lcl_recipient ).
      ENDLOOP.
* Añadir destinatarios al email copia
      LOOP AT lt_addr_copia ASSIGNING <fs_addr>.
        lcl_recipient  = cl_cam_address_bcs=>create_internet_address( <fs_addr> ).
        lcl_send_email->add_recipient( i_recipient = lcl_recipient i_copy = abap_true ).
      ENDLOOP.

* Enviar email
*     envio
      lv_sent_to_all = lcl_send_email->send( i_with_error_screen = 'X' ).
      IF lv_sent_to_all EQ 'X'.
*   Enviado Correctamente
        LOOP AT p_lt_ob52_mail INTO lw_ob52.
          UPDATE zfi_ob52_repor SET mail_enviado = lc_x
                                WHERE rrcty EQ lw_ob52-rrcty
                                 AND  bukrs EQ lw_ob52-bukrs
                                 AND  bname EQ lw_ob52-bname
                                 AND  datum EQ lw_ob52-datum
                                 AND  uzeit EQ lw_ob52-uzeit.
        ENDLOOP.
      ELSE.
*   Error al enviar
      ENDIF.
      COMMIT WORK.

    CATCH cx_bcs INTO bcs_exception.
      lv_error_msg = bcs_exception->get_text( ).
      CONCATENATE 'Error en envio de correo:'(e01) lv_error_msg
                                    INTO lv_error_msg  SEPARATED BY space.
      EXIT.
  ENDTRY.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_PAGE_HEADER
*&---------------------------------------------------------------------*
FORM add_page_header  TABLES   lt_page          TYPE soli_tab
                               lt_page_body     TYPE soli_tab
                      USING    p_lv_page_header TYPE soli-line
                               p_lv_font_size   TYPE numc4
                               p_lv_font_type   TYPE char20
                               p_lv_font_color  TYPE soli-line.
  DATA: lw_page_line TYPE LINE OF soli_tab.
*
  MOVE '<html>' TO lw_page_line.         APPEND lw_page_line TO lt_page.
  MOVE '<head>' TO lw_page_line.         APPEND lw_page_line TO lt_page.
  LOOP AT lt_page_body INTO p_lv_page_header.
    MOVE p_lv_page_header TO lw_page_line. APPEND lw_page_line TO lt_page.
  ENDLOOP.
  MOVE '</head>' TO lw_page_line.        APPEND lw_page_line TO lt_page.
  MOVE '<body>'  TO lw_page_line.        APPEND lw_page_line TO lt_page.
*
  IF p_lv_font_size IS NOT INITIAL  OR p_lv_font_type IS NOT INITIAL OR
     p_lv_font_color IS NOT INITIAL.
    MOVE '<font' TO lw_page_line.
    IF p_lv_font_size IS NOT INITIAL.
      CONCATENATE lw_page_line ' size="'  p_lv_font_size '"' INTO lw_page_line.
    ENDIF.
*
    IF p_lv_font_type IS NOT INITIAL.
      CONCATENATE lw_page_line ' face="'  p_lv_font_type '"' INTO lw_page_line.
    ENDIF.

    IF p_lv_font_color IS NOT INITIAL.
      CONCATENATE lw_page_line ' color="' p_lv_font_color '"' INTO lw_page_line.
    ENDIF.

    CONCATENATE lw_page_line '>' INTO lw_page_line SEPARATED BY space.
    APPEND lw_page_line TO lt_page.
  ENDIF.
ENDFORM.                    " ADD_PAGE_HEADER
*&---------------------------------------------------------------------*
*&      Form  START_TABLE
*&---------------------------------------------------------------------*
FORM start_table  TABLES   lt_page          TYPE soli_tab
                  USING    p_lv_border      TYPE numc4
                           p_lv_cellpadding TYPE numc4
                           p_lv_caption     TYPE string.
  DATA: lw_page_line TYPE soli.
*
  IF p_lv_border  IS NOT INITIAL  OR p_lv_cellpadding IS NOT INITIAL.
*    MOVE '<table cellspacing="10"' TO lw_page_line.
    MOVE '<table ' TO lw_page_line.
    IF p_lv_border IS NOT INITIAL.
      CONCATENATE lw_page_line ' border="' p_lv_border '"'
                                           INTO lw_page_line.
    ENDIF.

    IF p_lv_cellpadding IS NOT INITIAL.
      CONCATENATE lw_page_line ' cellpadding="' p_lv_cellpadding '"'
                                           INTO lw_page_line.
    ENDIF.
    CONCATENATE lw_page_line ' >' INTO lw_page_line.
  ELSE.
    MOVE '<table cellspacing="10">' TO lw_page_line.
  ENDIF.
  APPEND lw_page_line TO lt_page.

*  IF p_lv_caption IS NOT INITIAL.
  CONCATENATE '<font face="verdana" color="#CC0066"><h2>'
              p_lv_caption
              ' </h2></font>'             INTO lw_page_line.
  APPEND lw_page_line TO lt_page.

  MOVE '<tr> </tr>' TO lw_page_line.
  APPEND lw_page_line TO lt_page.
*  ENDIF.
ENDFORM.                    " START_TABLE
*&---------------------------------------------------------------------*
*&      Form  ENCABEZADOS
*&---------------------------------------------------------------------*
FORM encabezados  TABLES lt_page   TYPE soli_tab.
  DATA : lv_cell_value TYPE string,
         lv_width      TYPE char20.
*
  lv_cell_value = 'Cuenta'(h03).
  PERFORM add_header_cell TABLES lt_page
                          USING  lv_cell_value lv_width.
*
  lv_cell_value = 'Solicitante'(h04).
  PERFORM add_header_cell TABLES lt_page
                          USING  lv_cell_value lv_width.
*
  lv_cell_value = 'Motivo'(h05).
  PERFORM add_header_cell TABLES lt_page
                          USING  lv_cell_value lv_width.
*
  lv_cell_value = 'Estado solicitud'(h08).
  PERFORM add_header_cell TABLES lt_page
                          USING  lv_cell_value lv_width.
*
  lv_cell_value = 'Ajuste  periodo 1'(h06).
  PERFORM add_header_cell TABLES lt_page
                          USING  lv_cell_value lv_width.
*
  lv_cell_value = 'Ajuste  periodo 2'(h07).
  PERFORM add_header_cell TABLES lt_page
                          USING  lv_cell_value lv_width.
*
*  lv_cell_value = 'Mensaje Proceso'(h09).
*  PERFORM add_header_cell TABLES lt_page
*                          USING  lv_cell_value lv_width.
ENDFORM.                    " ENCABEZADOS
*&---------------------------------------------------------------------*
*&      Form  DETALLE
*&---------------------------------------------------------------------*
FORM detalle  TABLES   lt_page         TYPE soli_tab
                       p_lt_ob52_repor STRUCTURE zfi_ob52_repor
              USING    p_lw_ob52       STRUCTURE zfi_ob52_repor
                       p_opcion.
  DATA : lw_ob52       TYPE zfi_ob52_repor,
         lv_cell_color TYPE char20,
         lv_cell_value TYPE string.
*
  SELECT bukrs, bname, aprobar INTO TABLE @DATA(lt_aprob)
        FROM zfi_ob52_user WHERE bukrs EQ @p_lw_ob52-bukrs.

  LOOP AT p_lt_ob52_repor INTO lw_ob52.
    PERFORM start_row     TABLES lt_page.
**
    lv_cell_value = lw_ob52-bkont.
    PERFORM add_item_cell TABLES lt_page
                          USING lv_cell_value lv_cell_color.
*
    lv_cell_value = lw_ob52-bname.
    PERFORM add_item_cell TABLES lt_page
                          USING lv_cell_value lv_cell_color.
*
    lv_cell_value = lw_ob52-motivo_txt.
    PERFORM add_item_cell TABLES lt_page
                          USING lv_cell_value lv_cell_color.
*
    DATA(lv_index) = line_index( lt_aprob[ bukrs   = lw_ob52-bukrs
                                           aprobar = 'X' ] ).
    IF lv_index GT 0.
      CASE gc_x.
        WHEN p_opcion. lv_cell_value = 'Rechazado'.
        WHEN OTHERS.   lv_cell_value = 'Aprobado'.
      ENDCASE.
    ELSE.
      lv_cell_value = 'Sin usuario Aprobador'.
    ENDIF.
*
    PERFORM add_item_cell TABLES lt_page
                          USING lv_cell_value lv_cell_color.
*
    lv_cell_value = lw_ob52-texto_ajuste1.
    PERFORM add_item_cell TABLES lt_page
                          USING lv_cell_value lv_cell_color.
*
    lv_cell_value = lw_ob52-texto_ajuste2.
    PERFORM add_item_cell TABLES lt_page
                          USING lv_cell_value lv_cell_color.
*
*    lv_cell_value = lw_ob52-mensaje.
*    PERFORM add_item_cell TABLES lt_page
*                          USING lv_cell_value lv_cell_color.
*
    PERFORM end_row       TABLES lt_page.
    CLEAR lv_cell_value .
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ADD_HEADER_CELL
*&---------------------------------------------------------------------*
FORM add_header_cell  TABLES   lt_page         TYPE soli_tab
                      USING    p_lv_cell_value TYPE string
                               p_lv_width      TYPE char20.
  DATA: lw_page_line TYPE soli.
*
  MOVE '<th tabindex="0" scope="col" bgcolor=orange title='
                                      TO lw_page_line.
  CONCATENATE lw_page_line
              '"Columna '
              p_lv_cell_value
               '" >'               INTO lw_page_line SEPARATED BY space.
  CONCATENATE lw_page_line
              '<font color=black >'
              p_lv_cell_value
              '</font></th>'       INTO lw_page_line.

  APPEND lw_page_line TO lt_page.
ENDFORM.                    " ADD_HEADER_CELL
*&---------------------------------------------------------------------*
*&      Form  ADD_ITEM_CELL
*&---------------------------------------------------------------------*
FORM add_item_cell  TABLES   lt_page         TYPE soli_tab
                    USING    p_lv_cell_value TYPE string
                             p_lv_cell_color TYPE char20.
  DATA: lw_page_line TYPE soli.
*
  CONCATENATE '<td tabindex="0" align=right >'
              '<font color=black size=3 >'
               p_lv_cell_value
              '</font></td>'           INTO lw_page_line.

  APPEND lw_page_line TO lt_page.
ENDFORM.                    " ADD_ITEM_CELL
*&---------------------------------------------------------------------*
*&      Form  START_ROW
*&---------------------------------------------------------------------*
FORM start_row TABLES   lt_page   TYPE soli_tab.
  DATA: lw_page_line TYPE soli.
*
  MOVE '<tr>'         TO lw_page_line.
  APPEND lw_page_line TO lt_page.
ENDFORM.                    " START_ROW
*&---------------------------------------------------------------------*
*&      Form  END_ROW
*&---------------------------------------------------------------------*
FORM end_row  TABLES   lt_page         TYPE soli_tab.
  DATA: lw_page_line TYPE soli.
*
  MOVE '</tr>'        TO lw_page_line.
  APPEND lw_page_line TO lt_page.
ENDFORM.                    " END_ROW
*&---------------------------------------------------------------------*
*&      Form  END_TABLE
*&---------------------------------------------------------------------*
FORM end_table  TABLES   lt_page         TYPE soli_tab.
  DATA: lw_page_line TYPE soli.
*
  MOVE '</table>'     TO lw_page_line.
  APPEND lw_page_line TO lt_page.
*
* Pie de pagina
* espacio
  CONCATENATE '<font face="verdana" color="#CC0066"><h2>'
             ' '
              ' </h2></font>'             INTO lw_page_line.
  APPEND lw_page_line TO lt_page.
*  valor
  MOVE '<head>' TO lw_page_line.
  APPEND lw_page_line TO lt_page.
  DO 3 TIMES.
    lw_page_line = '<P> </P>'.
    APPEND lw_page_line TO lt_page.
  ENDDO.
*
  MOVE '<font color=black size=3 >' TO lw_page_line .
  CONCATENATE lw_page_line 'No responder correo </font>' INTO lw_page_line.
  APPEND lw_page_line TO lt_page.
*
  MOVE '</head>' TO lw_page_line.
  APPEND lw_page_line TO lt_page.
ENDFORM.                    " END_TABLE
*&---------------------------------------------------------------------*
*&      Form  ADD_PAGE_FOOTER
*&---------------------------------------------------------------------*
FORM add_page_footer  TABLES   lt_page         TYPE soli_tab.
  DATA: lw_page_line TYPE LINE OF soli_tab.
*
  MOVE '</font>' TO lw_page_line. APPEND lw_page_line TO lt_page.
  MOVE '</body>' TO lw_page_line. APPEND lw_page_line TO lt_page.
  MOVE '</html>' TO lw_page_line. APPEND lw_page_line TO lt_page.
ENDFORM.                    " ADD_PAGE_FOOTER
*&---------------------------------------------------------------------*
*&      Form  PREPARA_CORREOS
*&---------------------------------------------------------------------*
FORM prepara_correos  TABLES   p_lt_addr  TYPE bcsy_smtpa
                      USING    p_smtp_addr.

  SPLIT p_smtp_addr AT ';' INTO TABLE DATA(lt_itab).
  LOOP AT lt_itab INTO DATA(lw_itab).
    APPEND lw_itab TO p_lt_addr.
  ENDLOOP.
ENDFORM.
