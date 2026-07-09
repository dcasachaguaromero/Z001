*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZRFFOUS_C_F_FOR_VOUCHERF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_for_voucher
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_for_voucher .

  IF flg_kein_druck EQ 0.

    PERFORM einzelpostenfelder_fuellen.

*       Ausgabe der Einzelposten, falls kein Avishinweis erforderl. war
*       single item information if no advice note
    IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
      regud-txthr = regup-sgtxt.

* Control de Posiciones por Página.
      v_cont = v_cont + 1.

*----------------------------------------------------------------------------
*Rut Sociedad.
      DATA: v_paval LIKE t001z-paval.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE paval
*      INTO v_paval
*      FROM t001z
*      WHERE bukrs = reguh-zbukr
*      AND   party = 'TAXNR'.
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
*        reguh-stcd1 = v_paval.
      ENDIF.
    ENDIF.
*----------------------------------------------------------------------------

    PERFORM summenfelder_fuellen.

    WRITE reguh-rwbtr TO v_totalchq CURRENCY reguh-waers.
    reguh-name4 = v_nomban.

* Modificación 23.02.2010
* Se deje en comentario asignación de variable REGUD-SWNES, ya que el monto
* viene bien, manejando asteriscos a la izquierda en forma automática.
*   CONCATENATE '*' v_totalchq '*' INTO regud-swnes.
* Fin Modificación 23.02.2010
    CONDENSE regud-swnes NO-GAPS.
    CONCATENATE regud-swnes '*' INTO regud-swnes.

    IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.

*ARVM Control de despliegue de cuenta banco.  Que solo sea impresa una sola vez.

      DATA: v_flag2(1).
*******************************************************************
*******************************************************************
*Impresión de Cuenta Banco.
      v_xblnr = regup-xblnr.
      IF v_banco <> 'X'.

*        SELECT SINGLE txt20 INTO t_bseg-sgtxt
*               FROM skat WHERE spras = sy-langu AND
*                               ktopl = 'CL01' AND
*                                saknr = reguh-ubhkt.
*        CLEAR regup-xblnr.
*        t_bseg-hkont = reguh-ubhkt.
*        CLEAR: regud-dmbtr, t_bseg-debe.
*        regup-xblnr  = regup-xblnr.
*        t_bseg-zfbdt = regup-zfbdt.
*
*        CALL FUNCTION 'WRITE_FORM'
*          EXPORTING
*            element  = '525'
*            function = 'APPEND'
*          EXCEPTIONS
*            window   = 1
*            element  = 2.

***************************************************

        v_banco = 'X'.
      ENDIF.

*******************************************************************
*******************************************************************
*DETALLE
*      SELECT SINGLE txt20 INTO t_bseg-sgtxt
*               FROM skat WHERE spras = sy-langu AND
*                               ktopl = 'CL01' AND
*                               saknr = regup-hkont.




*Movemos el signo negativo hacia la Izquierda.
      IF regup-shkzg = 'S'.
        IF regup-dmbtr IS INITIAL.
          MOVE regup-wrbtr TO v_negativo.
        ELSE.
          MOVE regup-dmbtr TO v_negativo.
        ENDIF.
        CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
          CHANGING
            value = v_negativo.
        CONDENSE v_negativo NO-GAPS.
        MOVE v_negativo(20) TO v_dmbtr.
        WRITE v_dmbtr TO t_bseg-debe  CURRENCY reguh-waers.
        CONCATENATE '-' t_bseg-debe INTO t_bseg-debe.
        CONDENSE  t_bseg-debe NO-GAPS.
        CLEAR reguh-rbetr.
      ELSE.
        IF regup-dmbtr IS INITIAL.
          WRITE regup-wrbtr TO t_bseg-debe  CURRENCY reguh-waers.
          CONDENSE t_bseg-debe.
          CLEAR reguh-rbetr.
        ELSE.
          WRITE regup-dmbtr TO t_bseg-debe  CURRENCY reguh-waers.
          CONDENSE t_bseg-debe.
          CLEAR reguh-rbetr.
        ENDIF.
      ENDIF.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE LTEXT
*        FROM T003T
*        INTO REGUP-XREF3
*      WHERE SPRAS EQ sy-langu
*        and BLART EQ REGUP-BLART.
*
* NEW CODE
      SELECT LTEXT
      UP TO 1 ROWS 
        FROM T003T
        INTO REGUP-XREF3
      WHERE SPRAS EQ sy-langu
        and BLART EQ REGUP-BLART ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


*----------------------------------------------------------------
*Control de lineas por pagina.  Máximo 15.

      IF v_cont <= v_max.
*----------------------------------------------------------------
*Impresión del Detalle
*      t_bseg-xblnr = v_xblnr.
        regup-xblnr = v_xblnr.
        t_bseg-hkont = regup-hkont.
        t_bseg-stcd1 = reguh-zstc1.
        CLEAR reguh-rbetr.
        t_bseg-zfbdt = regup-zfbdt.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element  = hlp_ep_element
            function = 'APPEND'
          EXCEPTIONS
            window   = 1
            element  = 2.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element  = '525-TX'
            function = 'APPEND'
          EXCEPTIONS
            window   = 1
            element  = 2.
      ELSE.
*Acumulamos las ultimas posiciones que no caben impresas.
        ADD       regup-dmbtr TO v_totlin.
        WRITE     v_totlin TO t_bseg-debe  CURRENCY reguh-waers.
        CONDENSE  t_bseg-debe.
        CLEAR     reguh-rbetr.
        v_acumula = 'X'.
*Concatenamos Documentos no impresos.
        CONCATENATE regup-ZUONR v_doctos INTO v_doctos SEPARATED BY '-'.
        v_group = 'X'.
      ENDIF.
    ENDIF.

  ENDIF.

*Angabentabelle fÃ¼r die OeNB-Meldung (Ã–sterreich)
  IF t042e-xausl = 'X'.            "nur Auslandsscheck
    CLEAR up_oenb_angaben.
    up_oenb_angaben-diekz = regup-diekz.
    up_oenb_angaben-lzbkz = regup-lzbkz.
    up_oenb_angaben-summe = regud-netto.
    COLLECT up_oenb_angaben.
  ENDIF.




ENDFORM.                    " f_for_voucher
