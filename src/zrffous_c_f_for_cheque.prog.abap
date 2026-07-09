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
FORM f_for_cheque.

  IF flg_kein_druck EQ 0.

    PERFORM einzelpostenfelder_fuellen.

*       Ausgabe der Einzelposten, falls kein Avishinweis erforderl. war
*       single item information if no advice note
    IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
      regud-txthr = regup-sgtxt.

* Control de Posiciones por Página.
      v_cont = v_cont + 1.

*      WHILE a <> 9.
*        a = a.
*      ENDWHILE.

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
*----------------------------------------------------------------------------
    ENDIF.

    PERFORM summenfelder_fuellen.

    WRITE reguh-rwbtr TO v_totalchq CURRENCY reguh-waers.
    reguh-name4 = v_nomban.

* Modificación 23.02.2010
* Se deje en comentario asignación de variable REGUD-SWNES, ya que el monto
* viene bien, manejando asteriscos a la izquierda en forma automática.
*    CONCATENATE '*' v_totalchq '*' INTO regud-swnes.
* Fin Modificación 23.02.2010

    CONDENSE regud-swnes NO-GAPS.
    CONCATENATE regud-swnes '*' INTO regud-swnes.

    IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.

*ARVM Control de despliegue de cuenta banco.  Que solo sea impresa una sola vez.

      DATA: v_flag2(1).
*******************************************************************
*******************************************************************
*Cargamos Cabecera del Formulario.
*Comprobante Egreso
      MOVE reguh-vblnr TO ti_aviso-vblnr.
      MOVE reguh-lifnr  TO ti_aviso-zaldt.
**Ventana ADRESS
      MOVE reguh-lifnr TO ti_aviso-lifnr.
      MOVE reguh-znme1 TO ti_aviso-znme1.
      MOVE reguh-znme2 TO ti_aviso-znme2.
      MOVE regud-chect TO ti_aviso-chect.
      MOVE reguh-zaldt TO ti_aviso-zaldt.
**Ventana INFO
      MOVE regup-hkont TO ti_aviso-hkontcab.
      MOVE reguh-ubknt TO ti_aviso-ubknt.
      MOVE regud-ubnka TO ti_aviso-ubnka.

*Impresión de Cuenta Banco.
      v_xblnr = regup-xblnr.
      IF v_banco <> 'X'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE txt20 INTO t_bseg-sgtxt
*               FROM skat WHERE spras = sy-langu AND
*                               ktopl = 'CL01' AND
*                               saknr = reguh-ubhkt.
*
* NEW CODE
        SELECT txt20
        UP TO 1 ROWS  INTO t_bseg-sgtxt
               FROM skat WHERE spras = sy-langu AND
                               ktopl = 'CL01' AND
                               saknr = reguh-ubhkt ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        CLEAR regup-xblnr.
        t_bseg-hkont = reguh-ubhkt.
        CLEAR: regud-dmbtr, t_bseg-debe.
        t_bseg-zfbdt = regup-zfbdt.

        ti_aviso-hkontdet = t_bseg-hkont.
        ti_aviso-xblnr    = regup-xblnr.
        ti_aviso-zfbdt    = regup-zfbdt.
        ti_aviso-sgtxt    = t_bseg-sgtxt.
        ti_aviso-rbetrhab = reguh-rwbtr.
        ti_aviso-rwbtr    = reguh-rwbtr.
        ti_aviso-ubknt    = reguh-ubhkt.
        APPEND ti_aviso.
        CLEAR  ti_aviso.

*        CALL FUNCTION 'WRITE_FORM'
*          EXPORTING
*            element  = '525'
*            function = 'APPEND'
*          EXCEPTIONS
*            window   = 1
*            element  = 2.
        v_banco = 'X'.
      ENDIF.

*******************************************************************
*******************************************************************
*DETALLE
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE txt20 INTO t_bseg-sgtxt
*               FROM skat WHERE spras = sy-langu AND
*                               ktopl = 'CL01' AND
*                               saknr = regup-hkont.
*
* NEW CODE
      SELECT txt20
      UP TO 1 ROWS  INTO t_bseg-sgtxt
               FROM skat WHERE spras = sy-langu AND
                               ktopl = 'CL01' AND
                               saknr = regup-hkont ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*Movemos el signo negativo hacia la Izquierda.
      IF regup-shkzg = 'S'.
        MOVE regup-dmbtr TO v_negativo.
        CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
          CHANGING
            value = v_negativo.
        CONDENSE v_negativo NO-GAPS.
        MOVE v_negativo(20) TO v_dmbtr.
        WRITE v_dmbtr TO t_bseg-debe  CURRENCY reguh-waers.
        CONCATENATE '-' t_bseg-debe INTO t_bseg-debe.
        CONDENSE  t_bseg-debe NO-GAPS.
      ELSE.
        WRITE regup-dmbtr TO t_bseg-debe  CURRENCY reguh-waers.
        CONDENSE t_bseg-debe.
      ENDIF.
*----------------------------------------------------------
*Impresión del Detalle
      t_bseg-hkont = regup-hkont.
      t_bseg-stcd1 = reguh-zstc1.
      CLEAR reguh-rbetr.
      t_bseg-zfbdt = regup-zfbdt.


      ti_aviso-hkontdet = t_bseg-hkont.
      ti_aviso-stcd1det = reguh-zstc1.
      ti_aviso-xblnr    = v_xblnr.
      ti_aviso-zfbdt    = regup-zfbdt.
      ti_aviso-sgtxt    = t_bseg-sgtxt.
      ti_aviso-dmbtrdeb = t_bseg-debe.
      ti_aviso-rwbtr    = reguh-rwbtr.
      APPEND ti_aviso.
      CLEAR  ti_aviso.


*      CALL FUNCTION 'WRITE_FORM'
*        EXPORTING
*          element  = hlp_ep_element
*          function = 'APPEND'
*        EXCEPTIONS
*          window   = 1
*          element  = 2.
*
*      CALL FUNCTION 'WRITE_FORM'
*        EXPORTING
*          element  = '525-TX'
*          function = 'APPEND'
*        EXCEPTIONS
*          window   = 1
*          element  = 2.
    ENDIF.
  ENDIF.






*Angabentabelle für die OeNB-Meldung (Österreich)
  IF t042e-xausl = 'X'.            "nur Auslandsscheck
    CLEAR up_oenb_angaben.
    up_oenb_angaben-diekz = regup-diekz.
    up_oenb_angaben-lzbkz = regup-lzbkz.
    up_oenb_angaben-summe = regud-netto.
    COLLECT up_oenb_angaben.
  ENDIF.


  v_aviso = 'X'.

ENDFORM.                    " f_for_voucher
