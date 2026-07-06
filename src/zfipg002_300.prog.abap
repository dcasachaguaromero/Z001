*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_300
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_200
*&---------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  DATA: BEGIN OF lt_acc OCCURS 0.
          INCLUDE STRUCTURE zfitr009.
        DATA: END OF lt_acc.

  DATA: s_fecha TYPE RANGE OF budat,
        g_fecha LIKE LINE OF s_fecha.
*
  REFRESH tab.
  REFRESH tab.
  MOVE 'PROP' TO tab-fcode.
  APPEND tab.
  MOVE 'REFR' TO tab-fcode.
  APPEND tab.
  MOVE 'PAGO' TO tab-fcode.
  APPEND tab.
  MOVE 'MOD' TO tab-fcode.
  APPEND tab.
*
  CLEAR lt_acc. REFRESH lt_acc.
  SELECT * INTO TABLE lt_acc
     FROM zfitr009
      WHERE usnam = sy-uname.

  IF sy-subrc = 0.
    SORT lt_acc DESCENDING BY datum uzeit.
    READ TABLE lt_acc INDEX 1.
    REFRESH s_fecha. CLEAR s_fecha.
    g_fecha-sign   = 'I'.
    g_fecha-option = 'BT'.
    g_fecha-low    = lt_acc-datab.
    g_fecha-high   = lt_acc-datbi.
    APPEND g_fecha TO s_fecha.

    IF NOT sy-datum IN s_fecha.
      MOVE 'MODREF' TO tab-fcode.
      APPEND tab.
    ENDIF.
  ELSE.
    MOVE 'MODREF' TO tab-fcode.
    APPEND tab.
  ENDIF.

* ini - 04-06-2020 - Waldo alarcon - Visionone.
  READ TABLE int_tabla3 WITH KEY bvtyp = ''.
  IF sy-subrc NE 0.
    MOVE 'BCOINT' TO tab-fcode.
    APPEND tab.
  ENDIF.
* fin - 04-06-2020 - Waldo alarcon - Visionone.

  SET  PF-STATUS 'ZFIPG003' EXCLUDING tab.
  SET  TITLEBAR 'T01'.


ENDMODULE.                             " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  DATA linmod(5) TYPE n.

  CASE sy-ucomm.

    WHEN 'SELALL'.
      CLEAR sy-ucomm.
      PERFORM marco_todo_300.
    WHEN 'DESALL'.
      CLEAR sy-ucomm.
      PERFORM desmarco_todo_300.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'RW'.
      LEAVE TO SCREEN 0.
    WHEN 'SEL'.
      GET CURSOR FIELD cursorfield.
      GET CURSOR LINE xlinea.
      IF xlinea > 0 AND xlinea <= tabla3-lines.
        xlinea = xlinea + tabla3-top_line - 1.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
*SORT INT_TABLA3 . "JOROZCO 24.01.2020
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
        READ TABLE int_tabla3 INDEX xlinea.
        PERFORM detalle_doc.
      ENDIF.

    WHEN 'MODMASS'.
      linmod = 0.
      LOOP AT int_tabla3 WHERE sel = 'X'.
        linmod = linmod + 1.

      ENDLOOP .
      IF linmod > 0.
        CLEAR *bseg.
        CALL SCREEN 800 STARTING AT 10 05 ENDING AT 80 20.
      ELSE .
        MESSAGE e004(zfi) WITH 'Debe seleccionar a lo menos una linea.'.
      ENDIF.

    WHEN 'MODREF'.
      linmod = 0.
      LOOP AT int_tabla3 WHERE sel = 'X'.
        linmod = linmod + 1.

      ENDLOOP .
      IF linmod > 0.
        CLEAR *bseg.
        CALL SCREEN 900 STARTING AT 10 05 ENDING AT 80 20.
      ELSE .
        MESSAGE e004(zfi) WITH 'Debe seleccionar a lo menos una linea.'.
      ENDIF.



    WHEN 'EXCEL'.
      REFRESH texcel.
      LOOP AT int_tabla3.

        IF sy-tabix = 1.

          texcel-zzmot_emis = 'Mot. Emisión'.
          texcel-blart = 'C.Docto.'.
          texcel-gjahr = 'Año'.
          texcel-belnr = 'Documento FI'.
          texcel-buzei = 'Lin.'.
          texcel-zfbdt = 'Fecha base'.
          texcel-hbkid = 'Banco propio'.
          texcel-zlsch = 'Vía Pago'.
          texcel-wrbtr = 'Monto'.
          texcel-shkzg = 'D/H'.
          texcel-lifnr = 'Acreedor'.
          texcel-zuonr = 'Docto.Pago'.
          texcel-zz_agencia = 'Agencia'.
          texcel-msg = 'Mensaje'.

          APPEND texcel.

        ENDIF.
        MOVE-CORRESPONDING int_tabla3 TO texcel.
* ini - 28-04-2022 - Waldo alarcon - Visionone.
*        WRITE int_tabla3-wrbtr   TO texcel-wrbtr CURRENCY t001-waers.
        WRITE int_tabla3-wrbtr   TO texcel-wrbtr CURRENCY int_tabla3-waers.
* fin - 28-04-2022 - Waldo alarcon - Visionone.
        WRITE int_tabla3-zfbdt   TO texcel-zfbdt DD/MM/YYYY .

        APPEND texcel.

      ENDLOOP.

      CALL FUNCTION 'WS_EXCEL'
        TABLES
          data          = texcel
        EXCEPTIONS
          unknown_error = 1
          OTHERS        = 2.

* ini - 04-06-2020 - Waldo alarcon - Visionone.
    WHEN 'BCOINT'.
      PERFORM verifica_isapre.
* fin - 04-06-2020 - Waldo alarcon - Visionone.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

**&---------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL  OUTPUT
**&---------------------------------------------------------------------
**   Lleno grilla con valores desde tabla
**----------------------------------------------------------------------
*&      Module  FILL_TABLE_CONTROL_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fill_table_control_0300 OUTPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA3 Already Sorted
  READ TABLE int_tabla3 INTO zfipg002_b_est INDEX tabla3-current_line.

* ini - 28-04-2022 - Waldo alarcon - Visionone.
  IF zfipg002_b_est-blart IS NOT INITIAL.
    gv_waers = t001-waers.
  ENDIF.
* fin - 28-04-2022 - Waldo alarcon - Visionone.
ENDMODULE.                 " FILL_TABLE_CONTROL_0100  OUTPUT


*----------------------------------------------------------------------*
*  MODULE valida-grilla_0300 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE valida-grilla_0300 INPUT.

*ReSQ: No Need Of Change Internal Table INT_TABLA3 Already Sorted
  MODIFY int_tabla3 FROM zfipg002_b_est INDEX tabla3-current_line
     TRANSPORTING sel.

ENDMODULE.                 " VALIDA-GRILLA_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  DETALLE_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM detalle_doc .
  SET PARAMETER ID 'BLN' FIELD int_tabla3-belnr.
  SET PARAMETER ID 'BUK' FIELD bukrs.
  SET PARAMETER ID 'GJR' FIELD int_tabla3-gjahr.
  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.


ENDFORM.                    " DETALLE_DOC

*&---------------------------------------------------------------------*
*&      Form  marco_todo_800
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM marco_todo_300.

  LOOP AT int_tabla3.
    int_tabla3-sel = 'X'.
    MODIFY int_tabla3.
  ENDLOOP.

ENDFORM.                    " MARCO_TODO

*&---------------------------------------------------------------------*
*&      Form  DESMARCO_TODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM desmarco_todo_300.

  LOOP AT int_tabla3.
    int_tabla3-sel = ''.
    MODIFY int_tabla3.
  ENDLOOP.

ENDFORM.                    " DESMARCO_TODO
*&---------------------------------------------------------------------*
*&      Form  VERIFICA_ISAPRE
*&---------------------------------------------------------------------*
FORM verifica_isapre .
  TYPES: BEGIN OF ty_stcd1,
           numero TYPE char10,
           dv     TYPE char1,
         END OF ty_stcd1.
  DATA : lv_puerto TYPE char060,
         lv_tabix  TYPE sytabix,
         lv_proxy  TYPE REF TO zco_icuentas_bancarias_isapre,
         lv_output TYPE zcuentas_bancarias_response,
         lv_input  TYPE zcuentas_bancarias_request,
         oref      TYPE REF TO cx_root,
         lv_name   TYPE lfa1-name1,
         l_stcd1   TYPE stcd1,
         lv_stcd1  TYPE ty_stcd1,
         l_text    TYPE string.
*
  SELECT SINGLE puerto INTO lv_puerto
         FROM zws_puerto WHERE sociedad EQ bukrs
                           AND programa EQ 'ZFIPG002'
                           AND estado   EQ 'H'.
  IF sy-subrc <> 0.
    MESSAGE i016(z1) WITH TEXT-e01 sy-repid bukrs.
  ELSE.
    TRY.
        CREATE OBJECT lv_proxy
          EXPORTING
            logical_port_name = lv_puerto.
*
        LOOP AT int_tabla3 WHERE bvtyp IS INITIAL.
          MOVE sy-tabix TO lv_tabix.
*
          TRY.
*
              SELECT SINGLE stcd1 name1 INTO (l_stcd1, lv_name )
                     FROM lfa1 WHERE lifnr EQ int_tabla3-lifnr.
              SPLIT l_stcd1 AT '-' INTO lv_stcd1-numero
                                        lv_stcd1-dv.
              lv_input-rut         = lv_stcd1-numero.
              lv_input-motivo_pago = int_tabla3-zzmot_emis.
              lv_input-isapre      = bukrs.
*
              CALL METHOD lv_proxy->cuentas_bancarias
                EXPORTING
                  input  = lv_input
                IMPORTING
                  output = lv_output.
*
              IF lv_output-error_codigo EQ '0'.
                PERFORM valida_bvtyp  USING    lv_output-numero_cuenta
                                               lv_output-tipo_cuenta
                                               lv_output-banco_cuenta
                                               int_tabla3
                                               lv_name
                                      CHANGING int_tabla3-bvtyp.
              ELSE.
                int_tabla3-msg = lv_output-glosa_error.
              ENDIF.
* actualiza tabla del subscreen
              MODIFY int_tabla3 INDEX lv_tabix.
* actualiza tabla de proceso
              READ TABLE tpago WITH KEY zzmot_emis = int_tabla3-zzmot_emis
                                        zfbdt      = int_tabla3-zfbdt
                                        zlsch      = int_tabla3-zlsch
                                        belnr      = int_tabla3-belnr
                                        gjahr      = int_tabla3-gjahr
                                        buzei      = int_tabla3-buzei.
              IF sy-subrc EQ 0.
                tpago-bvtyp = int_tabla3-bvtyp.
                MODIFY tpago INDEX sy-tabix.
              ENDIF.
*
            CATCH cx_ai_system_fault INTO oref.
              l_text = oref->get_text( ).
            CATCH cx_ai_application_fault INTO oref.
              l_text = oref->get_text( ).
          ENDTRY.
        ENDLOOP.
*
        READ TABLE int_tabla3 WITH KEY bvtyp = ''.
        IF sy-subrc NE 0.
          LOOP AT int_tabla3.
            LOOP AT tpago WHERE zzmot_emis EQ int_tabla3-zzmot_emis AND
                                zfbdt      EQ int_tabla3-zfbdt      AND
                                zlsch      EQ int_tabla3-zlsch      AND
                                bvtyp      EQ space.
            ENDLOOP.
            IF sy-subrc NE 0.
              READ TABLE int_tabla WITH KEY zzmot_emis = int_tabla3-zzmot_emis
                                            zlsch      = int_tabla3-zlsch
                                            fecha_v    = int_tabla3-zfbdt.
              IF sy-subrc EQ 0.
                int_tabla-bvtyp_existe = ''.
                MODIFY int_tabla INDEX sy-tabix.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
*
      CATCH cx_ai_system_fault INTO oref.
        l_text = oref->get_text( ).
*        MESSAGE i016(z1) WITH TEXT-e02 lv_puerto.
    ENDTRY.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  VALIDA_BVTYP
*&---------------------------------------------------------------------*
FORM valida_bvtyp  USING    p_numero_cuenta
                            p_tipo_cuenta
                            p_banco_cuenta
                            p_intabla3    TYPE zfipg002_b_est
                            p_name
                   CHANGING p_bvtyp.
  TYPES: BEGIN OF ty_bvtyp,
           carcater TYPE char01,
           numero   TYPE numc3,
         END OF ty_bvtyp.
  DATA : lv_lifnr    TYPE lifnr,
         lv_bkont    TYPE bkont, "Clave de control de bancos
         lv_bankl    TYPE char03, "Clave de banco
         lv_subrc    TYPE sysubrc,
         lt_lfbk     TYPE TABLE OF lfbk,
         lt_message  TYPE TABLE OF ebpp_messages,
         lw_lfbk     TYPE lfbk,
         lw_lfbk_old TYPE lfbk,
         lw_bvtyp    TYPE ty_bvtyp.
*
  CASE p_tipo_cuenta.
    WHEN 'CC'. lv_bkont = '01'.
    WHEN 'CH'. lv_bkont = '02'.
    WHEN OTHERS.
      lv_bkont = '03'.
  ENDCASE.
*
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_banco_cuenta
    IMPORTING
      output = lv_bankl.
*
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_intabla3-lifnr
    IMPORTING
      output = lv_lifnr.
*
* LEE LAS CUENTAS INGRESADAS
  CALL FUNCTION 'FIN_AP_AR_GET_BANK'
    EXPORTING
      i_koart      = 'K'
      i_account    = lv_lifnr
    IMPORTING
      e_returncode = lv_subrc
    TABLES
      e_bankdata   = lt_lfbk
      t_messages   = lt_message.
  IF sy-subrc EQ 0 AND lt_lfbk[] IS NOT INITIAL.
    READ TABLE lt_lfbk INTO lw_lfbk WITH KEY lifnr = lv_lifnr
                                             banks = 'CL'
                                             bankl = lv_bankl
                                             bankn = p_numero_cuenta.
    MOVE sy-subrc TO lv_subrc.
    IF lv_subrc NE 0.
      SORT lt_lfbk BY bvtyp DESCENDING.
      READ TABLE lt_lfbk INTO lw_lfbk INDEX 1.
*
      MOVE lw_lfbk-bvtyp TO lw_bvtyp.
      MOVE 'C' TO lw_bvtyp-carcater.
      ADD 1    TO lw_bvtyp-numero.
*
      lw_lfbk-bvtyp = lw_bvtyp.
      lw_lfbk-bankl = lv_bankl.
      lw_lfbk-bankn = p_numero_cuenta.
      lw_lfbk-bkont = lv_bkont.
* AGREGA LA NUEVA CUENTA
      CALL FUNCTION 'FIN_AP_AR_ADD_BANK'
        EXPORTING
          i_koart           = 'K'
          i_bankdata        = lw_lfbk
          i_confirm_changes = 'X'
        IMPORTING
          e_returncode      = lv_subrc
        TABLES
          t_messages        = lt_message.
*
    ELSEIF lw_lfbk-bvtyp IS INITIAL.
* MODIFICA BVTYP
      MOVE-CORRESPONDING lw_lfbk TO lw_lfbk_old.
*
      SORT lt_lfbk BY bvtyp DESCENDING.
      READ TABLE lt_lfbk INTO lw_lfbk INDEX 1.
*
      MOVE lw_lfbk-bvtyp TO lw_bvtyp.
      MOVE 'C' TO lw_bvtyp-carcater.
      ADD 1    TO lw_bvtyp-numero.
      lw_lfbk-bvtyp = lw_bvtyp.
*
      CALL FUNCTION 'FIN_AP_AR_CHANGE_BANK'
        EXPORTING
          i_koart           = 'K'
          i_bankdata_new    = lw_lfbk
          i_bankdata_old    = lw_lfbk_old
          i_confirm_changes = 'X'
        IMPORTING
          e_returncode      = lv_subrc
        TABLES
          t_messages        = lt_message.
    ENDIF.
  ELSE.
    lw_lfbk-lifnr = lv_lifnr.
    lw_lfbk-banks = 'CL'.
    lw_lfbk-bankl = lv_bankl.
    lw_lfbk-bankn = p_numero_cuenta.
    lw_lfbk-bkont = lv_bkont.
    lw_lfbk-bvtyp = 'C001'.
    lw_lfbk-koinh = p_name.
* AGREGA LA NUEVA CUENTA
    CALL FUNCTION 'FIN_AP_AR_ADD_BANK'
      EXPORTING
        i_koart           = 'K'
        i_bankdata        = lw_lfbk
        i_confirm_changes = 'X'
      IMPORTING
        e_returncode      = lv_subrc
      TABLES
        t_messages        = lt_message.
  ENDIF.
*
  IF lv_subrc EQ 0.
    MOVE lw_lfbk-bvtyp TO p_bvtyp.
*
    PERFORM actualiza_fb02 USING p_intabla3
                                 p_bvtyp.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_FB02
*&---------------------------------------------------------------------*
FORM actualiza_fb02  USING    p_intabla3  TYPE zfipg002_b_est
                              p_bvtyp.
  DATA : lt_buztab TYPE tpit_t_buztab,
         lt_fldtab TYPE tpit_t_fname,
         lt_errtab TYPE tpit_t_errdoc,
         ls_fldtab TYPE tpit_fname,
         es_bseg   TYPE bseg.
*
  SELECT bukrs belnr gjahr buzei koart bschl
    INTO CORRESPONDING FIELDS OF TABLE lt_buztab
         FROM bseg WHERE bukrs = bukrs
                     AND belnr = p_intabla3-belnr
                     AND gjahr = p_intabla3-gjahr
                     AND buzei = p_intabla3-buzei.
*
  LOOP AT lt_buztab INTO DATA(ls_bseg_new).
    ls_fldtab-aenkz = abap_true.
    ls_fldtab-fname = 'BVTYP'.
    APPEND ls_fldtab TO lt_fldtab.
*
    es_bseg-bvtyp = p_bvtyp.
*
    CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
      EXPORTING
        s_bseg     = es_bseg
      IMPORTING
        errtab     = lt_errtab
      TABLES
        it_buztab  = lt_buztab
        it_fldtab  = lt_fldtab
      EXCEPTIONS
        bdc_errors = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ELSE.
      COMMIT WORK.
    ENDIF.
    FREE lt_fldtab.
  ENDLOOP.
ENDFORM.
