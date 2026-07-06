REPORT rfob5210.
*&---------------------------------------------------------------------*
*& Report: ZFI_OB52_RFOB5210                                           *
*& Author: WALDO ALARCON   (VISIONONE)                                 *
*& Description: COPIA DE PROGRAMA ESTANDAR RFOB5210, PARA EL MANEJO DE *
*&              VARIANTES DE PERIODO CONTABLE                          *
*& Date: 22-03-2022                                                    *
*& MODIFICACIONES:                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*
DATA: gt_texts      TYPE TABLE OF rsmpe_txt,
      gs_texts      TYPE rsmpe_txt,
      gt_title      TYPE TABLE OF rsmpe_titt,
      gs_title      TYPE rsmpe_titt,
      gs_dd04v      TYPE dd04v,
      gt_fields     TYPE sval OCCURS 1 WITH HEADER LINE,
      gd_bukrs      LIKE t001b-bukrs,
      gt_sellist    TYPE vimsellist OCCURS 1 WITH HEADER LINE,
      gd_return     TYPE c,
      gd_icon1      LIKE icon-name,
      gd_view       LIKE dd02v-tabname,
      gb_newgl      TYPE boole_d,
      wa_ob52_repor TYPE zfi_ob52_repor,
      gt_txwnote    TYPE TABLE OF txw_note.
*
INITIALIZATION.
  SELECT SINGLE bukrs, modificar INTO @DATA(lw_user)
         FROM zfi_ob52_user WHERE bname     EQ @sy-uname
                             AND  modificar EQ 'X'.
  IF sy-subrc NE 0.
    MESSAGE e899(fi) WITH TEXT-m03
                          TEXT-m04
                          TEXT-m02.
  ENDIF.

START-OF-SELECTION.

  CALL FUNCTION 'RS_CUA_GET_TEXTS'
    EXPORTING
      language  = sy-langu
      name      = 'SAPLSVIX'
    TABLES
      gui_texts = gt_texts.
  READ TABLE gt_texts INTO gs_texts WITH KEY obj_code = 'OKAY'.
  CALL FUNCTION 'RS_CUA_TITLES'
    EXPORTING
      language  = sy-langu
      program   = 'SAPLSVIX'
      titlecode = '100'
    TABLES
      titles    = gt_title.
  READ TABLE gt_title INTO gs_title INDEX 1.
  CALL FUNCTION 'DDIF_DTEL_GET'
    EXPORTING
      name     = 'OPVAR'
      langu    = sy-langu
    IMPORTING
      dd04v_wa = gs_dd04v.
  gt_fields-tabname   = 'ZFI_OB52_REPOR'. "'V_T001B'.
  gt_fields-fieldname = 'BUKRS'.
  gt_fields-fieldtext = gs_dd04v-scrtext_l.
  gt_fields-field_obl = 'X'.
  APPEND gt_fields.

  gt_fields-tabname   = 'ZFI_OB52_REPOR'. "'V_T001B'.
  gt_fields-fieldname = 'MOTIVO_TXT'.
  gt_fields-fieldtext = 'Motivo apertura Var.'.
  gt_fields-field_obl = 'X'.
  APPEND gt_fields.

  gd_icon1 = icon_okay.
  CALL FUNCTION 'POPUP_GET_VALUES_USER_BUTTONS'
    EXPORTING
      formname          = 'ACTION'
      programname       = 'ZFI_OB52_RFOB5210' "'RFOB5210'
      popup_title       = gs_title-text
      ok_pushbuttontext = space
      icon_ok_push      = gd_icon1
      quickinfo_ok_push = gs_texts-text
*     first_pushbutton  = TEXT-001
*     quickinfo_button_1 = TEXT-001
    IMPORTING
      returncode        = gd_return
    TABLES
      fields            = gt_fields.
  IF gd_return = 'A'.
    EXIT.
  ENDIF.
*
  LOOP AT gt_fields WHERE fieldname EQ 'BUKRS' AND
                          value     IS NOT INITIAL.
    gd_bukrs = gt_fields-value.
    EXIT.
  ENDLOOP.
*
  SELECT SINGLE bukrs INTO @DATA(lv_bukrs)
         FROM zfi_ob52 WHERE bukrs EQ @gd_bukrs.
  IF sy-subrc EQ 0.
    SELECT SINGLE modificar INTO @DATA(lv_modificar)
           FROM zfi_ob52_user WHERE bukrs EQ @gd_bukrs AND
                                    bname EQ @sy-uname.
    IF sy-subrc EQ 0 AND lv_modificar EQ 'X'.
      CALL FUNCTION 'FAGL_CHECK_GLFLEX_ACTIVE'
        IMPORTING
          e_glflex_active = gb_newgl.
*
      IF  abap_true = cl_fagl_switch_check=>fagl_fin_gl_2_rs( ) AND
          abap_true = gb_newgl.
*        gd_view = 'V_T001B_COFIB'.
        MESSAGE e899(fi) WITH TEXT-m06.
      ELSE.
*
* ALMACENA LOS DATOS N MEMORIA PARA PODER GRABARLOS POSTERIORMENTE.
        DELETE FROM SHARED BUFFER indx(st) ID 'V1_OB52'.
        LOOP AT gt_fields.
          CASE gt_fields-fieldname.
            WHEN 'BUKRS'.
              wa_ob52_repor-bukrs      = gt_fields-value.
            WHEN 'MOTIVO_TXT'.
              wa_ob52_repor-motivo_txt = gt_fields-value.
          ENDCASE.
        ENDLOOP.
        wa_ob52_repor-datum = sy-datum.
        wa_ob52_repor-uzeit = sy-uzeit.
        wa_ob52_repor-bname = sy-uname.
        EXPORT wa_ob52_repor TO SHARED BUFFER indx(st) ID 'V1_OB52'.

* LLAMA A LA TABLA CON LA VARIANTE SOCIEDAD
        gd_view              = 'ZVFI_OB52_T001B'.  "'V_T001BB'.
        gt_sellist-viewfield = 'BUKRS'.
        gt_sellist-operator  = 'EQ'.
        gt_sellist-value     = gd_bukrs.
        APPEND gt_sellist.
*
        CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
          EXPORTING
            action            = 'U'
            view_name         = gd_view
            suppress_wa_popup = 'X'
          TABLES
            dba_sellist       = gt_sellist.
      ENDIF.
    ELSE.
      IF sy-subrc NE 0.
        MESSAGE e899(fi) WITH TEXT-m01
                              TEXT-m02.
      ELSE.
        MESSAGE e899(fi) WITH TEXT-m03
                              TEXT-m04
                              TEXT-m02.
      ENDIF.
    ENDIF.
  ELSE.
    MESSAGE e899(fi) WITH TEXT-m05
                          TEXT-m02.
  ENDIF.

***********************************************************************
*-----------------------------------------------------------------------
FORM action TABLES it_fields STRUCTURE sval
            USING id_okcode TYPE char4
            CHANGING cs_error STRUCTURE svale               "2635046
                     cb_show_popup TYPE c.

  DATA: ld_opvar LIKE t010o-opvar.                          "2635046

  CASE id_okcode.
    WHEN 'COD1'.
      LOOP AT it_fields.
        CLEAR it_fields-value.
        MODIFY it_fields.
      ENDLOOP.
    WHEN OTHERS.                                            "2635046
      LOOP AT it_fields WHERE fieldname EQ 'BUKRS' AND
                              value     IS NOT INITIAL.
        SELECT SINGLE opvar FROM t010o INTO ld_opvar        "2635046
        WHERE opvar = it_fields-value.                      "2635046
        IF sy-subrc NE 0.                                   "2635046
          cs_error-msgid = '00'.                            "2635046
          cs_error-msgty = 'E'.                             "2635046
          cs_error-msgno = '058'.                           "2635046
          cs_error-msgv1 = it_fields-value.                 "2635046
          cs_error-msgv4 = 'T010O'.                         "2635046
          cb_show_popup = 'X'.                              "2635046
        ELSE.                                               "2635046
* Verifica que no exista un proceso pendiente por hacer
          SELECT SINGLE semaforo INTO @DATA(lv_semaforo)
                 FROM zfi_ob52_repor  WHERE bukrs    EQ @ld_opvar
                                       AND  semaforo EQ @icon_yellow_light.
          IF sy-subrc EQ 0.
            cs_error-msgid = 'FI'.
            cs_error-msgty = 'E'.
            cs_error-msgno = '899'.
            cs_error-msgv1 = TEXT-m09.
            cs_error-msgv2 = ld_opvar.
            cs_error-msgv3 = TEXT-m10.
            cb_show_popup = 'X'.
          ELSE.
* Verifica que puede modificar Periodo Contable.
            SELECT SINGLE bukrs, modificar INTO @DATA(lw_user)
                   FROM zfi_ob52_user WHERE bukrs     EQ @ld_opvar
                                       AND  bname     EQ @sy-uname
                                       AND  modificar EQ 'X'.
            IF sy-subrc NE 0.
              cs_error-msgid = 'FI'.
              cs_error-msgty = 'E'.
              cs_error-msgno = '899'.
              cs_error-msgv1 = TEXT-m01.
              cs_error-msgv2 = ld_opvar.
              cs_error-msgv3 = TEXT-m02.
              cb_show_popup = 'X'.
            ELSE.
* Verifica que exista Aprobador
              SELECT SINGLE aprobar INTO @DATA(lv_aprobar)
                     FROM zfi_ob52_user WHERE bukrs   EQ @ld_opvar
                                         AND  aprobar EQ 'X'.
              IF sy-subrc NE 0.
                cs_error-msgid = 'FI'.
                cs_error-msgty = 'E'.
                cs_error-msgno = '899'.
                cs_error-msgv1 = TEXT-e01.
                cs_error-msgv2 = ld_opvar.
                cs_error-msgv3 = TEXT-m02.
                cb_show_popup = 'X'.
              ELSE.
* Verifica que exista Correo asociado al usuario
                SELECT SINGLE smtp_addr1, smtp_addr2, smtp_addr3
                       INTO @DATA(lw_mail)
                       FROM zfi_ob52_mail WHERE bukrs   EQ @ld_opvar
                                           AND  bname   EQ @sy-uname.
                IF sy-subrc NE 0 OR
                  ( lw_mail-smtp_addr1 IS INITIAL AND
                    lw_mail-smtp_addr2 IS INITIAL AND
                    lw_mail-smtp_addr3 IS INITIAL ).
                  cs_error-msgid = 'FI'.
                  cs_error-msgty = 'E'.
                  cs_error-msgno = '899'.
                  cs_error-msgv1 = TEXT-e02.
                  cs_error-msgv2 = sy-uname.
                  cs_error-msgv3 = TEXT-m02..
                  cb_show_popup = 'X'.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.
