*----------------------------------------------------------------------*
***INCLUDE LZFI_OB52F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  LEER_DATOS_BD
*&---------------------------------------------------------------------*
FORM leer_datos_bd.
  DATA : lt_datos TYPE TABLE OF zfi_ob52_t001b.
* prepara los datos para verificar como se mostraran los datos.
  PERFORM vim_fill_wheretab.
  REFRESH total.
  CLEAR   total.
  CLEAR   gv_save.
* lee los datod de la tabla copia, para ver si tiene datos para ser
* aprobados por el proceso correspondiente.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO TABLE lt_datos
*     FROM zfi_ob52_t001b WHERE  rrcty   EQ '0' AND
*                                aprobar EQ 'X' AND
*                               (vim_wheretab) .
*
* NEW CODE
  SELECT *
 INTO TABLE lt_datos
     FROM zfi_ob52_t001b WHERE  rrcty   EQ '0' AND
                                aprobar EQ 'X' AND
                               (vim_wheretab)  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
* obtiene los datos de la tabla estandar para mostrar
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM t001b WHERE
*     rrcty EQ '0' AND
*     ( mkoar EQ '+' OR
*     mkoar EQ 'A' OR
*     mkoar EQ 'D' OR
*     mkoar EQ 'K' OR
*     mkoar EQ 'M' OR
*     mkoar EQ 'S' OR
*     mkoar EQ 'V' OR
*     mkoar EQ ' ' ) AND
* (vim_wheretab) .
*
* NEW CODE
  SELECT *
 FROM t001b WHERE
     rrcty EQ '0' AND
     ( mkoar EQ '+' OR
     mkoar EQ 'A' OR
     mkoar EQ 'D' OR
     mkoar EQ 'K' OR
     mkoar EQ 'M' OR
     mkoar EQ 'S' OR
     mkoar EQ 'V' OR
     mkoar EQ ' ' ) AND
 (vim_wheretab)  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    CLEAR zvfi_ob52_t001b .
* verifica si el dato de la tabla estandar se encuentra en la tabla
* de copia, para ser aprobado y lo actualiza en la tabla de salida,
* los que no cumplen con la validación los mueve a la tabla de copia
* y los actualiza.
    DATA(lv_lines) = line_index( lt_datos[ rrcty = t001b-rrcty
                                           bukrs = t001b-bukrs
                                           mkoar = t001b-mkoar
                                           bkont = t001b-bkont ] ).
    IF lv_lines GT 0.
      DATA(lw_datos) = lt_datos[ lv_lines ].
      MOVE-CORRESPONDING lw_datos TO zvfi_ob52_t001b.
    ELSE.
      MOVE-CORRESPONDING t001b    TO zvfi_ob52_t001b.
      MOVE-CORRESPONDING t001b    TO zfi_ob52_t001b.
      MODIFY zfi_ob52_t001b.
    ENDIF.
*
    <vim_total_struc> = zvfi_ob52_t001b.
    APPEND total.
  ENDSELECT.
  COMMIT WORK AND WAIT.
*
  SORT total BY <vim_xtotal_key>.
  <status>-alr_sorted = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF x_header-selection NE space.
    PERFORM check_dynamic_select_options.
  ELSEIF x_header-delmdtflag NE space.
    PERFORM build_mainkey_tab.
  ENDIF.
  REFRESH extract.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  REVISAR_ANTES_GRABAR
*&---------------------------------------------------------------------*
FORM revisar_antes_grabar.
  DATA : lv_flag        TYPE xflag,
         lv_txt_ajuste1 TYPE text50,
         lv_txt_ajuste2 TYPE text50.
* lee los datos de la tabla estandar para verificar el cambio.
  SELECT * INTO TABLE @DATA(lt_t001b)
           FROM t001b WHERE rrcty   EQ @zvfi_ob52_t001b-rrcty AND
                            bukrs   EQ @zvfi_ob52_t001b-bukrs  AND
                           ( mkoar EQ '+' OR
                             mkoar EQ 'A' OR
                             mkoar EQ 'D' OR
                             mkoar EQ 'K' OR
                             mkoar EQ 'M' OR
                             mkoar EQ 'S' OR
                             mkoar EQ 'V' OR
                             mkoar EQ ' ' ).
* recorre la tabla interna con los campos que fueron actualizados
  LOOP AT zvfi_ob52_t001b_total ASSIGNING FIELD-SYMBOL(<lw_datos>)
                                WHERE action IS NOT INITIAL.

    DATA(lv_index) = line_index( lt_t001b[ mkoar = <lw_datos>-mkoar
                                           bkont = <lw_datos>-bkont ] ).
    CHECK lv_index GT 0.
    DATA(lw_t001b) = lt_t001b[ lv_index ].
* AÑO Y MES TABLA DE TRABAJO
    DATA(lv_zval1)  = <lw_datos>-frye1 && <lw_datos>-frpe1.
    DATA(lv_zval2)  = <lw_datos>-frye2 && <lw_datos>-frpe2.
* AÑO Y MES TABLA ESTANDAR
    DATA(lv_tval1)  = lw_t001b-frye1 && lw_t001b-frpe1.
    DATA(lv_tval2)  = lw_t001b-frye2 && lw_t001b-frpe2.
* si la fecha ajustada es menor que la fecha del estandar, marca para
* que el proceso sea aprobado.
    CLEAR : <lw_datos>-texto_ajuste1, <lw_datos>-texto_ajuste2.
    IF lv_zval1 NE lv_tval1.
      lv_txt_ajuste1 = |{ lw_t001b-frpe1   ALPHA = OUT }| && '/' && lw_t001b-frye1.
      lv_txt_ajuste2 = |{ <lw_datos>-frpe1 ALPHA = OUT }| && '/' && <lw_datos>-frye1.
      CONDENSE lv_txt_ajuste1 NO-GAPS.
      CONDENSE lv_txt_ajuste2 NO-GAPS.
      lv_txt_ajuste1 = TEXT-pe1 && | | && lv_txt_ajuste1.
      lv_txt_ajuste2 = TEXT-pnv && | | && lv_txt_ajuste2.
      <lw_datos>-texto_ajuste1 = lv_txt_ajuste1 && | - | && lv_txt_ajuste2.
    ENDIF.
    IF lv_zval2 NE lv_tval2.
      lv_txt_ajuste1 = |{ lw_t001b-frpe2   ALPHA = OUT }| && '/' && lw_t001b-frye2.
      lv_txt_ajuste2 = |{ <lw_datos>-frpe2 ALPHA = OUT }| && '/' && <lw_datos>-frye2.
      CONDENSE lv_txt_ajuste1 NO-GAPS.
      CONDENSE lv_txt_ajuste2 NO-GAPS.
      lv_txt_ajuste1 = TEXT-pe2 && | | && lv_txt_ajuste1.
      lv_txt_ajuste2 = TEXT-pnv && | | && lv_txt_ajuste2.
      <lw_datos>-texto_ajuste2 = lv_txt_ajuste1 && | - | && lv_txt_ajuste2.
    ENDIF.
    IF lv_zval1 LT lv_tval1 OR lv_zval2 LT lv_tval2.
      <lw_datos>-aprobar = 'X'.
      lv_flag            = 'X'.
    ELSE.
      <lw_datos>-aprobar = 'Z'.
    ENDIF.
  ENDLOOP.

  IF lv_flag IS INITIAL.
    CALL FUNCTION 'FAGL_R_WRITE_PERIOD_TRACK'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZAR_T001B
*&---------------------------------------------------------------------*
FORM actualizar_t001b.
  DATA : wa_ob52_repor TYPE zfi_ob52_repor,
         lt_ob52_mail  TYPE TABLE OF zfi_ob52_repor.

* LEE LOS DATOS DE MEMORIA PARA TABLA DE REPORTE
  IMPORT wa_ob52_repor FROM SHARED BUFFER indx(st) ID 'V1_OB52'.
  DELETE FROM SHARED BUFFER indx(st) ID 'V1_OB52'.
*
* SOLO SI NO SE REQUIERE APROBACION ACTUALIZA LA TABLA DE LA OB52
  SELECT * INTO TABLE @DATA(lt_t001b)
           FROM t001b WHERE rrcty   EQ @zvfi_ob52_t001b-rrcty AND
                            bukrs   EQ @zvfi_ob52_t001b-bukrs  AND
                           ( mkoar EQ '+' OR
                             mkoar EQ 'A' OR
                             mkoar EQ 'D' OR
                             mkoar EQ 'K' OR
                             mkoar EQ 'M' OR
                             mkoar EQ 'S' OR
                             mkoar EQ 'V' OR
                             mkoar EQ ' ' ).
*
  LOOP AT zvfi_ob52_t001b_total WHERE aprobar IS NOT INITIAL.
*
    DATA(lv_index) = line_index( lt_t001b[ mkoar = zvfi_ob52_t001b_total-mkoar
                                           bkont = zvfi_ob52_t001b_total-bkont ] ).
    IF lv_index GT 0.
      DATA(lw_t001b) = lt_t001b[ lv_index ].
    ENDIF.
* ACTUALIZA SOLO LOS REGISTROS MODIFICADOS QUE NO NECESITAN APROBACION
    IF zvfi_ob52_t001b_total-aprobar EQ 'Z'.
      IF lv_index GT 0.
        UPDATE t001b SET : frpe1 = zvfi_ob52_t001b_total-frpe1
                           frye1 = zvfi_ob52_t001b_total-frye1
                           frpe2 = zvfi_ob52_t001b_total-frpe2
                           frye2 = zvfi_ob52_t001b_total-frye2
                     WHERE rrcty   EQ zvfi_ob52_t001b_total-rrcty AND
                           bukrs   EQ zvfi_ob52_t001b_total-bukrs AND
                           mkoar   EQ zvfi_ob52_t001b_total-mkoar AND
                           bkont   EQ zvfi_ob52_t001b_total-bkont.
      ENDIF.
    ENDIF.
*
* ACTUALIZA LA TABLA PARA EL REPORTE, solo si se modifican datos no registrados
*
    wa_ob52_repor-monat_gjahr1  = zvfi_ob52_t001b_total-frpe1 && '/' && zvfi_ob52_t001b_total-frye1.
    wa_ob52_repor-monat_gjahr2  = zvfi_ob52_t001b_total-frpe2 && '/' && zvfi_ob52_t001b_total-frye2.
    IF lw_t001b IS NOT INITIAL.
      wa_ob52_repor-monat_gjahr1_ori  = lw_t001b-frpe1 && '/' && lw_t001b-frye1  .
      wa_ob52_repor-monat_gjahr2_ori  = lw_t001b-frpe2 && '/' && lw_t001b-frye2  .
    ENDIF.
*
    wa_ob52_repor-rrcty         = zvfi_ob52_t001b_total-rrcty.
    wa_ob52_repor-mkoar         = zvfi_ob52_t001b_total-mkoar.
    wa_ob52_repor-vkont         = zvfi_ob52_t001b_total-vkont.
    wa_ob52_repor-bkont         = zvfi_ob52_t001b_total-bkont.
    wa_ob52_repor-texto_ajuste1 = zvfi_ob52_t001b_total-texto_ajuste1.
    wa_ob52_repor-texto_ajuste2 = zvfi_ob52_t001b_total-texto_ajuste2.
    IF zvfi_ob52_t001b_total-aprobar EQ 'X'.
      wa_ob52_repor-aprobar  = 'X'.
      wa_ob52_repor-semaforo = icon_yellow_light. "icon_red_light.
      wa_ob52_repor-mensaje = 'Requiere Aprobación'.
    ELSE.
      wa_ob52_repor-semaforo = icon_green_light.
      wa_ob52_repor-aprobar  = ''.
      IF wa_ob52_repor-texto_ajuste1 IS NOT INITIAL OR
         wa_ob52_repor-texto_ajuste2 IS NOT INITIAL.
        wa_ob52_repor-datum_mod = sy-datum.
        wa_ob52_repor-uzeit_mod = sy-uzeit.
        wa_ob52_repor-uname_mod = sy-uname.
        wa_ob52_repor-mensaje   = 'Valor ajustado directamente'.
      ENDIF.
    ENDIF.
*
    IF wa_ob52_repor-texto_ajuste1 IS INITIAL AND
       wa_ob52_repor-texto_ajuste2 IS INITIAL.
      wa_ob52_repor-mensaje = 'Valores ajustados al Estandar mes' && | | &&  wa_ob52_repor-monat_gjahr1_ori.
    ENDIF.
*
    MODIFY zfi_ob52_repor FROM wa_ob52_repor.

    APPEND wa_ob52_repor  TO lt_ob52_mail.
  ENDLOOP.
*
  IF lt_ob52_mail[] IS NOT INITIAL.
    PERFORM envio_mail TABLES lt_ob52_mail.
    MOVE 'X' TO gv_save.
    MESSAGE i899(fi) WITH 'Los datos fueron grabados,'
                          ' se ha enviado correo'.
  ENDIF.
ENDFORM.
FORM finalizar.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXIT_T001B
*&---------------------------------------------------------------------*
FORM exit_t001b USING id_cofi TYPE c                        "1993365
                CHANGING cs_t001b TYPE t001b.
  PERFORM jahr_konvertieren CHANGING cs_t001b-frye1.
  PERFORM jahr_konvertieren CHANGING cs_t001b-toye1.
  PERFORM jahr_konvertieren CHANGING cs_t001b-frye2.
  PERFORM jahr_konvertieren CHANGING cs_t001b-toye2.
  PERFORM jahr_konvertieren CHANGING cs_t001b-frye3.
  PERFORM jahr_konvertieren CHANGING cs_t001b-toye3.
  CHECK status-action CA 'ACU'.


* ------ Bei maskierter Kontoart keine Kontonummereingabe --------------
  IF cs_t001b-mkoar = '+'.
    IF cs_t001b-bkont CN ' 0'
    OR cs_t001b-vkont CN ' 0'.
      MESSAGE e012(fc).
    ENDIF.
  ENDIF.

* ------ Bei Kontoart 'V' keine Kontonummereingabe ---------------------
  IF cs_t001b-mkoar = 'V'.
    IF cs_t001b-bkont CN ' 0'
    OR cs_t001b-vkont CN ' 0'.
      MESSAGE e450(fc).
    ENDIF.
  ENDIF.

* ------ "Von Konto" grösser als "Bis Konto" --------------------------
  IF cs_t001b-vkont > cs_t001b-bkont.
    MESSAGE e137(fc).
  ENDIF.

*------ Bei nicht mask. Kontoart Kontonummerneingabe bei 'Bis Konto' ---
  IF status-action CA 'AC'.
    IF  cs_t001b-mkoar <> '+'
    AND cs_t001b-mkoar <> 'V'
    AND cs_t001b-bkont CO ' 0'.
      MESSAGE e043(fc).
    ENDIF.
  ENDIF.

*------ 'Von Periode' kleiner oder gleich 'Bis Periode' (Zeitraum 1) ---
  IF cs_t001b-frye1 NE space
  OR cs_t001b-frpe1 NE space
  OR cs_t001b-toye1 NE space
  OR cs_t001b-tope1 NE space.
    PERFORM pruefen_600
    USING cs_t001b-frye1 cs_t001b-frpe1
          cs_t001b-toye1 cs_t001b-tope1.
  ENDIF.
*------- 'Von Periode' kleiner oder gleich 'Bis Periode' (Zeitraum 2) --
  IF cs_t001b-frye2 NE space
  OR cs_t001b-frpe2 NE space
  OR cs_t001b-toye2 NE space
  OR cs_t001b-tope2 NE space.
    PERFORM pruefen_600
    USING cs_t001b-frye2 cs_t001b-frpe2
          cs_t001b-toye2 cs_t001b-tope2.
  ENDIF.
*------- 'Von Periode' kleiner oder gleich 'Bis Periode' (Zeitraum 2) --
  IF id_cofi = '3'.
    IF cs_t001b-frye3 NE space
    OR cs_t001b-frpe3 NE space
    OR cs_t001b-toye3 NE space
    OR cs_t001b-tope3 NE space.
      PERFORM pruefen_600
      USING cs_t001b-frye3 cs_t001b-frpe3
            cs_t001b-toye3 cs_t001b-tope3.
    ENDIF.
  ENDIF.
  CALL FUNCTION 'OB52_EURO_UMSETZUNG'
    EXPORTING
      id_opvar = cs_t001b-bukrs
      id_frye1 = cs_t001b-frye1
      id_frye2 = cs_t001b-frye2.
  PERFORM check_koart USING cs_t001b-mkoar
                            cs_t001b-frye3.
  CALL FUNCTION 'FAGL_REORG_CHECK_COFI'
    EXPORTING
      is_t001b            = cs_t001b
    EXCEPTIONS
      no_rest_changeable  = 1
      no_posting_allowed  = 2
      prev_period_is_open = 3
      internal_error      = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  JAHR_KONVERTIEREN
*&---------------------------------------------------------------------*
FORM jahr_konvertieren CHANGING jahr LIKE t001b-frye1.      "1993365
  DATA: jahraus(4) TYPE c,
        jahrein(4) TYPE c.

  CHECK NOT jahr IS INITIAL
  AND   jahr < '0100'.

  CLEAR jahraus.
  jahrein = jahr.
  IF jahrein <= '0050'.
    jahraus(2) = '20'.
  ELSE.
    jahraus(2) = '19'.
  ENDIF.
  jahraus+2(2) = jahrein+2(2).
  jahr = jahraus.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PRUEFEN_600
*&---------------------------------------------------------------------*
FORM pruefen_600 USING fromyear   LIKE t001b-frye1          "1993365
                       fromperiod LIKE t001b-frpe1
                       toyear     LIKE t001b-toye1
                       toperiod   LIKE t001b-tope1.

  CHECK status-action CA 'ACU'.

* Intervall komplett angegeben?
  IF fromyear   = space
  OR fromperiod = space
  OR toyear     = space
  OR toperiod   = space.
    MESSAGE e008(fc).
  ENDIF.

* Daten aufsteigend?
  IF fromyear > toyear.
    MESSAGE e009(fc).
  ENDIF.
  IF fromyear = toyear.
    IF fromperiod > toperiod.
      MESSAGE e009(fc).
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CHECK_KOART
*&---------------------------------------------------------------------*
FORM check_koart USING u_t001b_cofi_mkoar                   "1993365
                       u_t001b_cofi_frye3.

  CHECK NOT u_t001b_cofi_frye3 IS INITIAL.

  IF u_t001b_cofi_mkoar <> '+'.
    MESSAGE e360(fc).
  ENDIF.

ENDFORM.
