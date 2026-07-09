*----------------------------------------------------------------------*
***INCLUDE ZRFFOUS_C_F_FOR_CARATULA .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_for_caratula
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_for_caratula .

  IF flg_kein_druck EQ 0.

    PERFORM einzelpostenfelder_fuellen.

*       Ausgabe der Einzelposten, falls kein Avishinweis erforderl. war
*       single item information if no advice note
    IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
      regud-txthr = regup-sgtxt.
*          PERFORM scheckavis_zeile.
*------------------------------------------ Rutina para impresion Comprobante

      REFRESH t_bseg.
      SELECT belnr koart hkont dmbtr shkzg zfbdt
      FROM bseg INTO CORRESPONDING FIELDS OF TABLE t_bseg
         WHERE bukrs = reguh-zbukr AND
               belnr = reguh-vblnr
**ins ini
         ORDER BY bukrs belnr gjahr buzei.
**ins fin
      DESCRIBE TABLE t_bseg.
      IF sy-tfill <> 0.

******************************************************************
*ARVM           01012008 02112008
*Eliminamos un registro de Banco para cuadrar el Asiento Contable.
******************************************************************
*            DATA: V_CONT TYPE I.

        v_cont = v_cont + 1.

* Controlamos las cuentas dif T/C.

        LOOP AT t_bseg.
*              DATA A TYPE I.

*              WHILE A <> 9.
*                A = A.
*              ENDWHILE.

          IF t_bseg-hkont(1) = '4'.
            DELETE t_bseg INDEX sy-tabix.
*           EXIT.
          ENDIF.
        ENDLOOP.

*            READ TABLE T_BSEG INDEX V_CONT.
*            IF SY-SUBRC = 0.
*              READ TABLE T_BSEG WITH KEY SHKZG = 'S'.
*              IF SY-SUBRC = 0.
*                IF T_BSEG-HKONT(1) = '4'.
*                  DELETE T_BSEG INDEX SY-TABIX.
*                ENDIF.
*              ENDIF.

        IF v_cont > 1.
*            Controlamos la cuenta Banco.
          READ TABLE t_bseg WITH KEY shkzg = 'H'.
          IF sy-subrc = 0.
            DELETE t_bseg INDEX sy-tabix.
          ENDIF.
        ENDIF.
*            ENDIF.

        LOOP AT t_bseg.
          IF t_bseg-shkzg = 'S'.
            WRITE t_bseg-dmbtr TO t_bseg-debe CURRENCY reguh-waers.
            ADD   t_bseg-dmbtr TO wa_debe.

*                DATA: V_HKONT L IKE REGUP-HKONT.
*                DATA: V_DMBTR LIKE REGUP-DMBTR.
*                DATA: V_WRBTR LIKE REGUP-WRBTR.

*                SELECT SINGLE HKONT DMBTR WRBTR
*                INTO (V_HKONT, V_DMBTR, V_WRBTR)
*                FROM REGUP
*                WHERE HKONT = T_BSEG-HKONT.
*
*                IF SY-SUBRC = 0.
**                READ TABLE REGUP WITH KEY HKONT = T_BSEG-HKONT.
**                IF SY-SUBRC = 0.
*                  REGUP-WRBTR = SPACE.
*                ENDIF.

            regud-dmbtr = regup-dmbtr.
*                CLEAR: REGUD-WRBTR, Z_INDHAB.
            CLEAR: reguh-rbetr, z_indhab.

          ELSE.
            WRITE t_bseg-dmbtr TO t_bseg-haber CURRENCY reguh-waers.
            ADD   t_bseg-dmbtr TO wa_haber.
***********************************
*                aca podria controlar el banco para un solo recorrido.
            z_indhab = 'X'.
***********************************
*                READ TABLE REGUP WITH KEY HKONT = T_BSEG-HKONT.
*                IF SY-SUBRC = 0.
*                    REGUP-DMBTR = SPACE.
*                  MODIFY REGUP INDEX SY-TABIX.
*                ENDIF.
*                SELECT SINGLE HKONT DMBTR WRBTR
*                INTO (V_HKONT, V_DMBTR, V_WRBTR)
*                FROM REGUP
*                WHERE HKONT = T_BSEG-HKONT.

*                IF SY-SUBRC = 0.
*                READ TABLE REGUP WITH KEY HKONT = T_BSEG-HKONT.
*                IF SY-SUBRC = 0.
*                  REGUP-DMBTR = SPACE.
*                ENDIF.

*                REGUD-WRBTR = REGUP-WRBTR.

            reguh-rbetr = regup-wrbtr.
            CLEAR: regud-dmbtr.

          ENDIF.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE txt20 INTO t_bseg-sgtxt
*           FROM skat WHERE spras = sy-langu AND
*                           ktopl = 'CL01' AND
*                           saknr = t_bseg-hkont.
*
* NEW CODE
          SELECT txt20
          UP TO 1 ROWS  INTO t_bseg-sgtxt
           FROM skat WHERE spras = sy-langu AND
                           ktopl = 'CL01' AND
                           saknr = t_bseg-hkont ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*Se controla impresión de la cuenta banco.

*              IF Z_INDHAB <> 'X'..
*                READ TABLE T_BSEG WITH KEY SHKZG = 'H'.
*                IF SY-SUBRC = 0.
*                  DELETE T_BSEG INDEX SY-TABIX.
*                ENDIF.

*                IF T_BSEG-KOART = 'K'.
*                  MOVE REGUH-STCD1 TO T_BSEG-STCD1.
*                ENDIF.
*
*                CALL FUNCTION 'WRITE_FORM'
*                  EXPORTING
*                    ELEMENT  = HLP_EP_ELEMENT
*                    FUNCTION = 'APPEND'
*                  EXCEPTIONS
*                    WINDOW   = 1
*                    ELEMENT  = 2.

*              ELSE.

          IF t_bseg-koart = 'K'.
            MOVE reguh-stcd1 TO t_bseg-stcd1.
          ENDIF.

          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element  = hlp_ep_element
              function = 'APPEND'
            EXCEPTIONS
              window   = 1
              element  = 2.
*              ENDIF.

          AT LAST.
            CLEAR t_bseg.
            WRITE wa_debe   TO t_bseg-debe  CURRENCY reguh-waers.
            WRITE wa_haber  TO t_bseg-haber CURRENCY reguh-waers.

***********************************************************************
*Control de Despliegue de Valores.
*Valores se recuperan desde Formulario Cheques con Voucher.
*ARVM 31102008.

            DATA: v_flag(1), p_debe LIKE t_bseg-debe, p_haber LIKE t_bseg-haber.
            DATA: v_debe(20).
            DATA: v_haber(20).

*                IF T_BSEG-SHKZG = 'H'.
*                  WA_HABER = REGUP-DMBTR.
*                  CLEAR WA_DEBE.
*                ELSE.
*                  WA_DEBE = REGUP-DMBTR.
*                  CLEAR WA_HABER.
*                ENDIF.

            WRITE reguh-rwbtr TO v_totalchq CURRENCY reguh-waers.
            reguh-name4 = v_nomban.

            IF v_flag <> 'X'.
              v_flag   = 'X'.
              v_debe     = t_bseg-debe.
              v_haber    = t_bseg-haber.
*                  WRITE REGUH-RWBTR TO V_TOTALCHQ CURRENCY REGUH-WAERS.
*                  V_TOTALCHQ = REGUH-RWBTR.
*                  MODIFY T_BSEG INDEX SY-TABIX.
*                  EXPORT V_DEBE  TO MEMORY ID P_DEBE.
*                  EXPORT V_HABER TO MEMORY ID P_HABER.
            ENDIF.
************************************************************************
*                ADD WA_DEBE   TO T_BSEG-DEBE.  "CURRENCY REGUH-WAERS.
*                ADD WA_HABER  TO T_BSEG-HABER. "CURRENCY REGUH-WAERS.
*                CALL FUNCTION 'WRITE_FORM'
*                  EXPORTING
*                    element = '555'
*                  EXCEPTIONS
*                    window  = 1
*                    element = 2.
          ENDAT.
        ENDLOOP.

****************************
*Rut Sociedad.
        DATA: v_paval LIKE t001z-paval.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE paval
*        INTO v_paval
*        FROM t001z
*        WHERE bukrs = reguh-zbukr
*        AND   party = 'TAXNR'.
*
* NEW CODE
        SELECT paval
        UP TO 1 ROWS 
        INTO v_paval
        FROM t001z
        WHERE bukrs = reguh-zbukr
        AND   party = 'TAXNR' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc = 0.
*              REGUH-STCD1 = V_PAVAL.
        ENDIF.

*            CALL FUNCTION 'WRITE_FORM'
*              EXPORTING
*                ELEMENT = '555'
*              EXCEPTIONS
*                WINDOW  = 1
*                ELEMENT = 2.
      ENDIF.
*----------------------------------------------------------------------------
    ENDIF.

    PERFORM summenfelder_fuellen.

* Modificación 23.02.2010
* Se deje en comentario asignación de variable REGUD-SWNES, ya que el monto
* viene bien, manejando asteriscos a la izquierda en forma automática.
*        CONCATENATE '*' V_TOTALCHQ '*' INTO REGUD-SWNES.
* Fin Modificación 23.02.2010
    CONDENSE regud-swnes NO-GAPS.
    CONCATENATE regud-swnes '*' INTO regud-swnes.


**Monto en Texto.. Control de Despliegue para pagos Masivos.
*        DATA V_AMOUNT.
*
**V_AMOUNT = REGUH-RWBTR.
*
*        CALL FUNCTION 'SPELL_AMOUNT'
*         EXPORTING
*           AMOUNT          = REGUH-RWBTR
*           CURRENCY        = 'CLP'
**   FILLER          = ' '
*           LANGUAGE        = SY-LANGU
*         IMPORTING
*           IN_WORDS        = SPELL
*         EXCEPTIONS
*           NOT_FOUND       = 1
*           TOO_LARGE       = 2
*           OTHERS          = 3.
*
*
*
*        TRANSLATE SPELL-WORD TO UPPER CASE.

*        REGUD-SWNES = V_TOTALCHQ.

    IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.

*ARVM Control de despliegue de cuenta banco.  Que solo sea impresa una sola vez.

      DATA: v_flag2(1).

*          WA_DEBE = WA_DEBE2.
*          WA_HABER = WA_HABER2.


      IF v_flag2 <> 'X'.
        v_flag2 = 'X'.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element  = '525-TX'
            function = 'APPEND'
          EXCEPTIONS
            window   = 1
            element  = 2.
      ELSE.
*            READ TABLE T_BSEG WITH KEY SHKZG = 'H'.
*            IF SY-SUBRC = 0.
*              DELETE T_BSEG INDEX SY-TABIX.
*            ENDIF.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element  = '525-TX'
            function = 'APPEND'
          EXCEPTIONS
            window   = 1
            element  = 2.
      ENDIF.
    ENDIF.
  ENDIF.

*     Angabentabelle für die OeNB-Meldung (Österreich)
  IF t042e-xausl = 'X'.            "nur Auslandsscheck
    CLEAR up_oenb_angaben.
    up_oenb_angaben-diekz = regup-diekz.
    up_oenb_angaben-lzbkz = regup-lzbkz.
    up_oenb_angaben-summe = regud-netto.
    COLLECT up_oenb_angaben.
  ENDIF.
ENDFORM.                    " f_for_caratula
