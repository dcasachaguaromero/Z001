*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFITR020_T01
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso: Actualiza tabla mantenedora de documentos
*--------------------------------------------------------------------*
REPORT  ZFITR020_T01.

TABLES:  sscrfields, bsad.

TYPES: BEGIN OF ty_salida.
        include structure ZFITR020_T01.
TYPES: END OF ty_salida.

data: ti_salida  TYPE TABLE OF ty_salida WITH HEADER LINE.
data: ti_salida2 TYPE TABLE OF ty_salida WITH HEADER LINE.
data: ti_salida3 TYPE TABLE OF ty_salida WITH HEADER LINE.

data: ti_tempo TYPE TABLE OF ty_salida WITH HEADER LINE.

data: rango_fecha TYPE RANGE OF bsak-augdt WITH HEADER LINE.

* Declaration of sel screen buttons
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON (20) w_button USER-COMMAND BUT1.
SELECTION-SCREEN END OF LINE.

SELECT-OPTIONS   :   p_belnr   FOR  BSAD-BELNR no INTERVALS MODIF ID two .
SELECT-OPTIONS   :   p_gjahr   for  bsad-GJAHR NO INTERVALS MODIF ID two .

INITIALIZATION.
* Add displayed text string to buttons
  w_button = 'Aceptar'.

AT SELECTION-SCREEN OUTPUT.
  "si el flag esta marcado quita los select-options
  data: lv_existe like ZFITR020_T04-valor.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single valor into lv_existe
*    from ZFITR020_T04
*    where nombre = 'P_BELNR'.
*
* NEW CODE
  SELECT valor
  UP TO 1 ROWS  into lv_existe
    from ZFITR020_T04
    where nombre = 'P_BELNR' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  if lv_existe eq ' '.
    LOOP AT SCREEN.
      IF SCREEN-GROUP1 = 'TWO'.
        screen-input = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  endif.

AT SELECTION-SCREEN.
  if sscrfields-ucomm eq 'BUT1'.
    do 5 TIMES.
      PERFORM subrutina.
    ENDDO.
  ENDIF.

START-OF-SELECTION.
  "si viene por fondo
  if sy-batch eq 'X'.
    do 5 TIMES.
      PERFORM subrutina.
    ENDDO.
  endif.

*&---------------------------------------------------------------------*
*&      Form  SUBRUTINA
*&---------------------------------------------------------------------*
*     Realica el proceso de actualizar los campos llave y llave posicion
*     ademas de los documentos de compensacion
*----------------------------------------------------------------------*
FORM SUBRUTINA .
  refresh ti_salida.
**********************************************************************
*   Primer proceso de actualizacion: datos adicionales
**********************************************************************
  "rescatamos los documentos a los cuales les falta ser procesados
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE ti_salida
*      from ZFITR020_T01
*    where VBLNR_PAGO = ' '
*      and belnr in p_belnr
*      and GJAHR in p_gjahr.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_salida
      from ZFITR020_T01
    where VBLNR_PAGO = ' '
      and belnr in p_belnr
      and GJAHR in p_gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  loop at ti_salida into ti_salida.

    refresh rango_fecha.
    CLEAR rango_fecha.
    rango_fecha-sign = 'I'.
    rango_fecha-option = 'BT'.
    CONCATENATE  ti_salida-gjahr '01' '01' into rango_fecha-low.
    CONCATENATE  ti_salida-gjahr '12' '31' into rango_fecha-high.
    append rango_fecha.

    "Cambio de Estado:
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT single CAMBIO_ESTADO into ti_salida-CAMBIO_ESTADO
*     from ZFITR020_T03
*     where CLASE_DOC = ti_salida-BLART.
*
* NEW CODE
    SELECT CAMBIO_ESTADO
    UP TO 1 ROWS  into ti_salida-CAMBIO_ESTADO
     from ZFITR020_T03
     where CLASE_DOC = ti_salida-BLART ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    "N° docum cpompen: si el documento compensado es vacio se
    "busca los campos a actualizar.
    if ti_salida-VBLNR_PAGO is INITIAL or ti_salida-GJAHR_PAGO is INITIAL .

      perform busca_doc_com_normal.
*      if ti_salida-bvorg is INITIAL.
*
*      else.
*          PERFORM busca_doc_com_multi_soc.
*      endif.

      if ti_salida-BLART_PAGO  eq 'AU'.
        "entra el 81
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single * into CORRESPONDING FIELDS OF ti_salida2
*          from ZFITR020_T01
*          where VBLNR_PAGO = ti_salida-BELNR "81
*            and GJAHR_PAGO = ti_salida-GJAHR
*            and BLART_PAGO = ti_salida-blart.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  into CORRESPONDING FIELDS OF ti_salida2
          from ZFITR020_T01
          where VBLNR_PAGO = ti_salida-BELNR "81
            and GJAHR_PAGO = ti_salida-GJAHR
            and BLART_PAGO = ti_salida-blart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
                                                            "sale el 20
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single * into CORRESPONDING FIELDS OF ti_salida3
*          from ZFITR020_T01
*          where VBLNR_PAGO = ti_salida2-BELNR "
*            and GJAHR_PAGO = ti_salida2-GJAHR
*            and BLART_PAGO = ti_salida2-blart.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  into CORRESPONDING FIELDS OF ti_salida3
          from ZFITR020_T01
          where VBLNR_PAGO = ti_salida2-BELNR "
            and GJAHR_PAGO = ti_salida2-GJAHR
            and BLART_PAGO = ti_salida2-blart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        clear ti_salida2-VBLNR_PAGO.
        clear ti_salida2-GJAHR_PAGO.
        clear ti_salida2-BLART_PAGO.
        clear ti_salida2-BLDAT_PAGO.
        clear ti_salida2-budat_pago.

        UPDATE ZFITR020_T01 from ti_salida2 .

        CONCATENATE ti_salida-BELNR ti_salida-GJAHR INTO ti_salida-llave.
        ti_salida-llave_pos = 1.

      endif.

      if ti_salida-BLART eq 'AU'.
        ti_salida-VBLNR_PAGO = ti_salida-BELNR.
        ti_salida-GJAHR_PAGO = ti_salida-GJAHR.
        ti_salida-BLART_PAGO = ti_salida-BLART.
        ti_salida-BLDAT_PAGO = ti_salida-bldat.
        ti_salida-budat_pago = ti_salida-budat.
      endif.


      if ti_salida-VBLNR_PAGO is not INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single CAMBIO_ESTADO into ti_salida-PROCESO_COMPEN
*          from ZFITR020_T03
*          where CLASE_DOC = ti_salida-BLART_PAGO.
*
* NEW CODE
        SELECT CAMBIO_ESTADO
        UP TO 1 ROWS  into ti_salida-PROCESO_COMPEN
          from ZFITR020_T03
          where CLASE_DOC = ti_salida-BLART_PAGO ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        if sy-subrc <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT single valor into ti_salida-PROCESO_COMPEN
*            from ZFITR020_T04
*            where nombre = ti_salida-BLART_PAGO.
*
* NEW CODE
          SELECT valor
          UP TO 1 ROWS  into ti_salida-PROCESO_COMPEN
            from ZFITR020_T04
            where nombre = ti_salida-BLART_PAGO ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          if sy-subrc <> 0.
            ti_salida-PROCESO_COMPEN = 'DOC. COMPENSACION'.
          endif.
        endif.

        if ti_salida-BLART_PAGO eq 'ZP'.
          ti_salida-PROCESO_COMPEN = 'EMISION NUEVO PAGO'.
        endif.

      endif.
    endif.


    if ti_salida-blart eq 'ZP'.
      if ti_salida-hkonth+9(1) eq '2'.

        ti_salida-MODALIDAD_PAGO = 'C'.
        "Consulta de cheques y datos adicionales.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single chect laufd laufi
*          into (ti_salida-CHECT, ti_salida-ZALDT, ti_salida-ID_PROP_PAGO )
*         from payr
*          where zbukr = ti_salida-bukrs
*            and vblnr = ti_salida-belnr
*            and gjahr = ti_salida-gjahr
*            and rzawe = ti_salida-MODALIDAD_PAGO.
*
* NEW CODE
        SELECT chect laufd laufi
        UP TO 1 ROWS 
          into (ti_salida-CHECT, ti_salida-ZALDT, ti_salida-ID_PROP_PAGO )
         from payr
          where zbukr = ti_salida-bukrs
            and vblnr = ti_salida-belnr
            and gjahr = ti_salida-gjahr
            and rzawe = ti_salida-MODALIDAD_PAGO ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


      ELSEIF ti_salida-hkonth+9(1) eq '5'.
        "consulta de pago a los diferentes a cheques.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single rzawe into ti_salida-MODALIDAD_PAGO
*          from reguh
*          where vblnr = ti_salida-belnr
*            and zbukr = ti_salida-bukrs
*            and zaldt = ti_salida-budat.
*
* NEW CODE
        SELECT rzawe
        UP TO 1 ROWS  into ti_salida-MODALIDAD_PAGO
          from reguh
          where vblnr = ti_salida-belnr
            and zbukr = ti_salida-bukrs
            and zaldt = ti_salida-budat ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        "llena datos adicionales
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single laufi into ti_salida-ID_PROP_PAGO
*              from reguh
*              where vblnr = ti_salida-belnr
*                and zbukr = ti_salida-bukrs
*                and zaldt = ti_salida-budat
*                and rzawe = ti_salida-MODALIDAD_PAGO.
*
* NEW CODE
        SELECT laufi
        UP TO 1 ROWS  into ti_salida-ID_PROP_PAGO
              from reguh
              where vblnr = ti_salida-belnr
                and zbukr = ti_salida-bukrs
                and zaldt = ti_salida-budat
                and rzawe = ti_salida-MODALIDAD_PAGO ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      endif.

      "busca el banco con cuenta al haber
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single hbkid hktid into (ti_salida-hbkid, ti_salida-hktid )
*        from t042I
*        where zbukr = ti_salida-bukrs
*          and ukont = ti_salida-hkonth
*          and zlsch = ti_salida-MODALIDAD_PAGO.
*
* NEW CODE
      SELECT hbkid hktid
      UP TO 1 ROWS  into (ti_salida-hbkid, ti_salida-hktid )
        from t042I
        where zbukr = ti_salida-bukrs
          and ukont = ti_salida-hkonth
          and zlsch = ti_salida-MODALIDAD_PAGO ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      if ti_salida-bvorg is INITIAL.
        PERFORM busca_motemi_agen_normal.
      else.
        PERFORM BUSCA_MOTEMI_AGEN_multi_soc.
      endif.
      if ti_salida-chect is NOT INITIAL and ti_salida-VBLNR_PAGO is not  INITIAL.
        data: l_kukey TYPE febko-kukey.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT single azdat aznum kukey into (ti_salida-azdat, ti_salida-aznum, l_kukey)
*          from febko
*          where azdat = ti_salida-budat_pago
*            and bukrs = ti_salida-bukrs
*            and hbkid = ti_salida-hbkid
*            and hktid = ti_salida-hktid.
*
* NEW CODE
        SELECT azdat aznum kukey
        UP TO 1 ROWS  into (ti_salida-azdat, ti_salida-aznum, l_kukey)
          from febko
          where azdat = ti_salida-budat_pago
            and bukrs = ti_salida-bukrs
            and hbkid = ti_salida-hbkid
            and hktid = ti_salida-hktid ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE kukey INTO l_kukey
*          from febep
*          where kukey = l_kukey
*            and chect = ti_salida-chect.
*
* NEW CODE
        SELECT kukey
        UP TO 1 ROWS  INTO l_kukey
          from febep
          where kukey = l_kukey
            and chect = ti_salida-chect ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        if SY-subrc <> 0.
          CLEAR ti_salida-azdat .
          CLEAR ti_salida-aznum .
        endif.
      endif.
      "cuando sea zp asignar a la cuenta del banco la del haber
      ti_salida-hkontb = ti_salida-hkonth.

    else.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single zzmot_emis into ti_salida-MOTIVO_EMISION
*        from bseg
*        where bukrs = ti_salida-bukrs
*          and gjahr = ti_salida-gjahr
*          and belnr = ti_salida-belnr.
*
* NEW CODE
      SELECT zzmot_emis
      UP TO 1 ROWS  into ti_salida-MOTIVO_EMISION
        from bseg
        where bukrs = ti_salida-bukrs
          and gjahr = ti_salida-gjahr
          and belnr = ti_salida-belnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    ENDIF.

    ti_salida-FECHA_ACTUAL = sy-datum.

    "actualizo la tabla ZFITR020_T01
    UPDATE ZFITR020_T01 from ti_salida .

    append ti_salida to ti_tempo.
    clear ti_salida.
  ENDLOOP.

**********************************************************************
*  Segundo proceso de actualizacion: llave y llave_pos
**********************************************************************
  refresh ti_salida.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE ti_salida
*    from ZFITR020_T01
*    where llave = ' '
*      and belnr in p_belnr.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_salida
    from ZFITR020_T01
    where llave = ' '
      and belnr in p_belnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  "se construye la llave.
  loop at ti_salida into ti_salida.
    "recordatorio se excluyen los anulados
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT single llave llave_pos into (ti_salida-llave, ti_salida-llave_pos)
*     from ZFITR020_T01
*     where bukrs      = ti_salida-bukrs
*       and VBLNR_PAGO = ti_salida-belnr
*       and GJAHR_PAGO = ti_salida-gjahr
*       and BLART_PAGO = ti_salida-blart
*       and blart <> 'AU'
*       .
*
* NEW CODE
    SELECT llave llave_pos
    UP TO 1 ROWS  into (ti_salida-llave, ti_salida-llave_pos)
     from ZFITR020_T01
     where bukrs      = ti_salida-bukrs
       and VBLNR_PAGO = ti_salida-belnr
       and GJAHR_PAGO = ti_salida-gjahr
       and BLART_PAGO = ti_salida-blart
       and blart <> 'AU'
        ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    "se copia la llave si es exitoso o se crea 1
    "si cumple las condiciones
    if SY-subrc <> 0 and ( ti_salida-blart eq 'ZP' ).
      "se vuelve a verificar puesto que en algunos casos
      "despues de actualizar la tabla al ir a buscar el dato
      "en la bd este no esta guardado***
      READ TABLE ti_tempo with key bukrs = ti_salida-bukrs
                                   VBLNR_PAGO = ti_salida-BELNR
                                   GJAHR_PAGO = ti_salida-GJAHR
                                   BLART_PAGO = ti_salida-blart.

      if sy-subrc <> 0.
        CONCATENATE ti_salida-belnr ti_salida-gjahr into  ti_salida-llave .
        ti_salida-llave_pos = 1.
      else.
        ti_salida-llave = ti_tempo-llave.
        add 1 to ti_salida-llave_pos.
      endif.
    else.
      add 1 to ti_salida-llave_pos.
    endif.

    "actualizo la tabla
    UPDATE ZFITR020_T01 from ti_salida.

  ENDLOOP.

**********************************************************************
*   Llena datos adicionales
**********************************************************************
  refresh ti_salida.
  "con cualquiera de los datos adicionales se llenan los vacios
  "se usa chect sin ningun motivo en especial
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * into CORRESPONDING FIELDS OF TABLE ti_salida
*    from ZFITR020_T01
*    where chect = ' '
*     and  belnr in p_belnr.
*
* NEW CODE
  SELECT *
 into CORRESPONDING FIELDS OF TABLE ti_salida
    from ZFITR020_T01
    where chect = ' '
     and  belnr in p_belnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  loop at ti_salida into ti_salida.
    CLEAR ti_salida2.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT single * into CORRESPONDING FIELDS OF ti_salida2
*       from ZFITR020_T01
*        where VBLNR_PAGO = ti_salida-belnr
*          and GJAHR_PAGO = ti_salida-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  into CORRESPONDING FIELDS OF ti_salida2
       from ZFITR020_T01
        where VBLNR_PAGO = ti_salida-belnr
          and GJAHR_PAGO = ti_salida-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    if sy-subrc = 0.
      ti_salida-lifnr          = ti_salida2-lifnr.
      ti_salida-MODALIDAD_PAGO = ti_salida2-MODALIDAD_PAGO.
      ti_salida-CHECT          = ti_salida2-CHECT.
      ti_salida-hbkid          = ti_salida2-hbkid.
      ti_salida-hktid          = ti_salida2-hktid.
      ti_salida-stcd1          = ti_salida2-stcd1.
      ti_salida-name1          = ti_salida2-name1.
      ti_salida-ZALDT          = ti_salida2-ZALDT.
      ti_salida-ID_PROP_PAGO   = ti_salida2-ID_PROP_PAGO.
      ti_salida-NUM_AGENCIA    = ti_salida2-NUM_AGENCIA.
    endif.

    "actualizo la tabla ZFITR020_T01
    UPDATE ZFITR020_T01 from ti_salida.

  ENDLOOP.

  MESSAGE 'Proceso finalizado' TYPE 'S'.
ENDFORM.                    " SUBRUTINA
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DOC_COM_NORMAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUSCA_DOC_COM_NORMAL .
  data: lv_augdt like bsas-augdt.

*{   REPLACE        ECDK910635                                        1
*\  SELECT single augbl gjahr into (ti_salida-VBLNR_PAGO, lv_augdt ) "ti_salida-GJAHR_PAGO)
  SELECT single augbl augdt into (ti_salida-VBLNR_PAGO, lv_augdt ) "ti_salida-GJAHR_PAGO)
*}   REPLACE
    from bsas
    where bukrs = ti_salida-bukrs
      and augbl NE ti_salida-belnr "que documento esta compensando el belnr
      and belnr = ti_salida-belnr
      and budat = ti_salida-budat.

    ti_salida-GJAHR_PAGO = lv_augdt(4).
  "vamos a verificar la fecha del documento y que no este anulado
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT single blart BLDAT budat
*    into (ti_salida-BLART_PAGO, ti_salida-BLDAT_PAGO, ti_salida-budat_pago )
*    from bkpf
*    where bukrs = ti_salida-bukrs
*      and belnr = ti_salida-VBLNR_PAGO
*      and gjahr = ti_salida-GJAHR_PAGO
*      .
*
* NEW CODE
  SELECT blart BLDAT budat
  UP TO 1 ROWS 
    into (ti_salida-BLART_PAGO, ti_salida-BLDAT_PAGO, ti_salida-budat_pago )
    from bkpf
    where bukrs = ti_salida-bukrs
      and belnr = ti_salida-VBLNR_PAGO
      and gjahr = ti_salida-GJAHR_PAGO
       ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
ENDFORM.                    " BUSCA_DOC_COM_NORMAL
*&---------------------------------------------------------------------*
*&      Form  BUSCA_DOC_COM_MULTI_SOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM BUSCA_DOC_COM_MULTI_SOC .
  data: lv_gjahr like ZFITR020_T01-GJAHR.
  data: lv_bukrs like ZFITR020_T01-bukrs.
  data: lv_belnr like ZFITR020_T01-belnr.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single bukrs GJAHR belnr into (lv_bukrs, lv_gjahr, lv_belnr)
*    from bvor
*    where bvorg = ti_salida-belnr
*      and bukrs <> ti_salida-bukrs
*      and GJAHR = ti_salida-GJAHR
*      .
*
* NEW CODE
  SELECT bukrs GJAHR belnr
  UP TO 1 ROWS  into (lv_bukrs, lv_gjahr, lv_belnr)
    from bvor
    where bvorg = ti_salida-belnr
      and bukrs <> ti_salida-bukrs
      and GJAHR = ti_salida-GJAHR
       ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  data: lv_gjahr_orig like ZFITR020_T01-GJAHR.
  data: lv_bukrs_orig like ZFITR020_T01-bukrs.
  data: lv_belnr_orig like ZFITR020_T01-belnr.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single belnr bukrs GJAHR into (lv_belnr_orig, lv_bukrs_orig, lv_gjahr_orig)
*    from bse_clr
*   where belnr = lv_belnr
*     and bukrs = lv_bukrs
*     and GJAHR = lv_gjahr.
*
* NEW CODE
  SELECT belnr bukrs GJAHR
  UP TO 1 ROWS  into (lv_belnr_orig, lv_bukrs_orig, lv_gjahr_orig)
    from bse_clr
   where belnr = lv_belnr
     and bukrs = lv_bukrs
     and GJAHR = lv_gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01



ENDFORM.                    " BUSCA_DOC_COM_MULTI_SOC
*&---------------------------------------------------------------------*
*&      Form  BUSCA_MOTEMI_AGEN_NORMAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUSCA_MOTEMI_AGEN_NORMAL .
  "busca los datos del acreedor
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT single stcd1 name1 into (ti_salida-stcd1, ti_salida-name1)
*    from lfa1
*    where lifnr = ti_salida-lifnr.
*
* NEW CODE
  SELECT stcd1 name1
  UP TO 1 ROWS  into (ti_salida-stcd1, ti_salida-name1)
    from lfa1
    where lifnr = ti_salida-lifnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT single zzmot_emis ZZ_AGENCIA into (ti_salida-MOTIVO_EMISION, ti_salida-num_agencia)
*    from bsak
*    where bukrs = ti_salida-bukrs
*      and lifnr = ti_salida-lifnr
*      and augdt IN rango_fecha "rango segun gjahr 01.01.2013 a 31.12.2013
*      and augbl = ti_salida-belnr
*      and belnr NE ti_salida-belnr.
*
* NEW CODE
  SELECT zzmot_emis ZZ_AGENCIA
  UP TO 1 ROWS  into (ti_salida-MOTIVO_EMISION, ti_salida-num_agencia)
    from bsak
    where bukrs = ti_salida-bukrs
      and lifnr = ti_salida-lifnr
      and augdt IN rango_fecha "rango segun gjahr 01.01.2013 a 31.12.2013
      and augbl = ti_salida-belnr
      and belnr NE ti_salida-belnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
ENDFORM.                    " BUSCA_MOTEMI_AGEN_NORMAL
*&---------------------------------------------------------------------*
*&      Form  BUSCA_MOTEMI_AGEN_MULTI_SOC
*&---------------------------------------------------------------------*
*       Va a entrar en la subrutina solo si es multisociedad.
*----------------------------------------------------------------------*
FORM BUSCA_MOTEMI_AGEN_MULTI_SOC .
  data: lv_gjahr like ZFITR020_T01-GJAHR.
  data: lv_bukrs like ZFITR020_T01-bukrs.
  data: lv_belnr like ZFITR020_T01-belnr.

  "aca buscamos el documento multisociedad en la otra sociedad
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single bukrs GJAHR belnr
*      into (lv_bukrs, lv_gjahr, lv_belnr)
*    from bvor
*    where bvorg = ti_salida-bvorg
*      and bukrs <> ti_salida-bukrs
*      and GJAHR = ti_salida-GJAHR
*      .
*
* NEW CODE
  SELECT bukrs GJAHR belnr
  UP TO 1 ROWS 
      into (lv_bukrs, lv_gjahr, lv_belnr)
    from bvor
    where bvorg = ti_salida-bvorg
      and bukrs <> ti_salida-bukrs
      and GJAHR = ti_salida-GJAHR
       ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  data: lv_gjahr_orig like ZFITR020_T01-GJAHR.
  data: lv_bukrs_orig like ZFITR020_T01-bukrs.
  data: lv_belnr_orig like ZFITR020_T01-belnr.

  "con el documento obtenido buscamos el documento pagado
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single belnr bukrs GJAHR
*      into (lv_belnr_orig, lv_bukrs_orig, lv_gjahr_orig)
*    from bse_clr
*   where belnr_clr = lv_belnr
*     and bukrs_clr = lv_bukrs
*     and GJAHR_clr = lv_gjahr.
*
* NEW CODE
  SELECT belnr bukrs GJAHR
  UP TO 1 ROWS 
      into (lv_belnr_orig, lv_bukrs_orig, lv_gjahr_orig)
    from bse_clr
   where belnr_clr = lv_belnr
     and bukrs_clr = lv_bukrs
     and GJAHR_clr = lv_gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  "se rescatan los datos del documento pagado
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT single lifnr zzmot_emis ZZ_AGENCIA
*      into (ti_salida-lifnr, ti_salida-MOTIVO_EMISION, ti_salida-num_agencia)
*    from bsak
*    where bukrs = lv_bukrs_orig
*      and belnr = lv_belnr_orig
*      and GJAHR = lv_gjahr_orig.
*
* NEW CODE
  SELECT lifnr zzmot_emis ZZ_AGENCIA
  UP TO 1 ROWS 
      into (ti_salida-lifnr, ti_salida-MOTIVO_EMISION, ti_salida-num_agencia)
    from bsak
    where bukrs = lv_bukrs_orig
      and belnr = lv_belnr_orig
      and GJAHR = lv_gjahr_orig ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  "busca los datos del acreedor
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT single stcd1 name1 into (ti_salida-stcd1, ti_salida-name1)
*    from lfa1
*    where lifnr = ti_salida-lifnr.
*
* NEW CODE
  SELECT stcd1 name1
  UP TO 1 ROWS  into (ti_salida-stcd1, ti_salida-name1)
    from lfa1
    where lifnr = ti_salida-lifnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  ti_salida-BELNR_BVORG = lv_belnr_orig.
  ti_salida-BUKRS_BVORG = lv_bukrs_orig.
  ti_salida-GJAHR_BVORG = lv_gjahr_orig.

ENDFORM.                    " BUSCA_MOTEMI_AGEN_MULTI_SOC
