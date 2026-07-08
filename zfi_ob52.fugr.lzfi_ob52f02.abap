*----------------------------------------------------------------------*
***INCLUDE LZFI_OB52F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ENVIO_MAIL
*&---------------------------------------------------------------------*
FORM envio_mail  TABLES  p_lt_ob52_mail STRUCTURE zfi_ob52_repor.
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
*
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
  lw_message = '<b>Detalle Solicitud</b>'.
  APPEND lw_message TO lt_page_body.
  lw_message = '<P> </P>'.
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
                          USING  lw_ob52.
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
                                 AND  mkoar EQ lw_ob52-mkoar
                                 AND  bkont EQ lw_ob52-bkont
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
ENDFORM.                    " ENCABEZADOS
*&---------------------------------------------------------------------*
*&      Form  DETALLE
*&---------------------------------------------------------------------*
FORM detalle  TABLES   lt_page         TYPE soli_tab
                       p_lt_ob52_repor STRUCTURE zfi_ob52_repor
              USING    p_lw_ob52       STRUCTURE zfi_ob52_repor.
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
    CONDENSE lv_cell_value NO-GAPS.
    PERFORM add_item_cell TABLES lt_page
                          USING lv_cell_value lv_cell_color.
*
    lv_cell_value = lw_ob52-motivo_txt.
    PERFORM add_item_cell TABLES lt_page
                          USING lv_cell_value lv_cell_color.
*
    IF lw_ob52-aprobar EQ 'X'.
      DATA(lv_index) = line_index( lt_aprob[ bukrs   = lw_ob52-bukrs
                                             aprobar = 'X' ] ).
      IF lv_index GT 0.
        lv_cell_value = 'Pendiente'.
      ELSE.
        lv_cell_value = 'Sin usuario Aprobador'.
      ENDIF.
    ELSE.
      lv_cell_value = 'Cerrado'.
    ENDIF.
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
