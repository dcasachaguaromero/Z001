*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZADDPAGOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCHEQUES_ESTADO2_OLD.

type-pools: slis.
tables : payr, bsas, bsis, lfa1, T012K.

*Tipos
types: begin of sp_insert,
          ptipo_pago      type string,
          pfec_emision    like sy-datum,
          prut            type string,
          pnombre         type string,
          pfec_anula      like sy-datum,
          pfec_doc        like sy-datum,
          pfec_cont       like sy-datum,
          pcta_ctble      type string,
          pcta_cte        type string,
          pmonto          type p,
          pnro_cheque     type p,
          pempresa        type string,
          pmotivo         type string,
          pfec_cobro      like sy-datum,
          pind_cobro      type string,
          pagencia        type string,
          pestado         type string,
          pind_proceso    type string,
          p_nroasig       type string,
          p_referencia    type string,
          pnro_doc         type string,
          pejercicio       type string,
       end of sp_insert.
data: it_spins type sp_insert,
      t_spins type STANDARD TABLE OF sp_insert.
data: wa_payr type payr,
      wa_reguh type reguh,
      str type string,
      w_budat like bsak-budat,
      w_fecha type string,
      w_iter type i,
      w_chect like payr-chect,
      W_AUX TYPE I,
      w_monto like payr-rwbtr,
      w_belnr like bkpf-belnr,
      w_gjahr like bkpf-gjahr,
      w_stgrd like bkpf-stgrd,
      status type statusflag1,
      w_bankn like t012k-bankn,
      w_stcd1 like lfa1-stcd1,
      w_lifnr like lfa1-lifnr,
      w_hkont like bsis-hkont.
data: amount_display like wmto_s-amount,
      amount_sap like wmto_s-amount.
data: it_reguh type standard table of reguh.

SELECT-OPTIONS: s_bukrs FOR payr-ZBUKR,
                s_hkont FOR bsas-hkont,
                s_zuonr FOR bsas-zuonr.

PARAMETERS: p_budat like bsas-budat.

START-OF-SELECTION.
  IF status = 'X'.
    exit.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM BSIS
*  where bukrs in s_bukrs
*        and hkont in s_hkont
*        and zuonr in s_zuonr.
*
* NEW CODE
SELECT *
 FROM BSIS
  where bukrs in s_bukrs
        and hkont in s_hkont
        and zuonr in s_zuonr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  CLEAR it_spins.
  it_spins-ptipo_pago = 'C'.
*  it_spins-pfec_emision = payr-ZALDT.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select SINGLE BLDAT BUDAT STBLG STJAH stgrd
*    into (it_spins-pfec_doc, it_spins-pfec_cont, w_belnr, w_gjahr, w_stgrd)
*    from bkpf
*    where bukrs = bsis-bukrs
*      and belnr = bsis-belnr
*      and gjahr = bsis-gjahr.
*
* NEW CODE
  SELECT BLDAT BUDAT STBLG STJAH stgrd
  UP TO 1 ROWS 
    into (it_spins-pfec_doc, it_spins-pfec_cont, w_belnr, w_gjahr, w_stgrd)
    from bkpf
    where bukrs = bsis-bukrs
      and belnr = bsis-belnr
      and gjahr = bsis-gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    CHECK w_stgrd eq 0.
    it_spins-pnro_doc = bsis-belnr.
    it_spins-pejercicio = bsis-gjahr.
*    it_spins-pfec_anula = payr-voidd. "
    it_spins-pcta_ctble = bsis-hkont.
*    it_spins-pcta_cte = w_bankn.
    amount_sap = bsis-dmbtr.
    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
      EXPORTING
        CURRENCY              = bsis-waers
        AMOUNT_INTERNAL       = amount_sap
     IMPORTING
       AMOUNT_DISPLAY        = amount_display
*     EXCEPTIONS
*       INTERNAL_ERROR        = 1
*       OTHERS                = 2
              .
    IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    it_spins-pmonto = amount_display.
    w_aux = strlen( bsis-zuonr ).
    IF w_aux = 13.
      IF bsis-zuonr co '0123456789 '.
        it_spins-pnro_cheque = bsis-zuonr.
      ENDIF.
    ENDIF.

    it_spins-pempresa = bsis-bukrs.
    IF it_spins-pcta_ctble+9(1) = '6'.
      it_spins-pestado = 'CADUCADO FISICO'.
    ELSEIF it_spins-pcta_ctble+9(1) = '7'.
      it_spins-pestado = 'CADUCADO ELECTRONICO'.
    ELSEIF it_spins-pcta_ctble+9(1) = '9'.
      it_spins-pestado = 'REVALIDADO'.
    ELSEIF it_spins-pcta_ctble+9(1) = '8'.
      it_spins-pestado = 'CADUCADO FISCAL'.
    ENDIF.

    w_hkont = bsis-hkont.
    w_hkont+9(1) = '0'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single *
*          from t012k
*          where bukrs = bsis-bukrs
*                and hkont = w_hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
          from t012k
          where bukrs = bsis-bukrs
                and hkont = w_hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc eq 0.
      w_chect = bsis-zuonr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single * from payr
*        where zbukr = t012k-bukrs
*              and hbkid = t012k-hbkid
*              and hktid = t012k-hktid
*              and chect = w_chect.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  from payr
        where zbukr = t012k-bukrs
              and hbkid = t012k-hbkid
              and hktid = t012k-hktid
              and chect = w_chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc eq 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT single stcd1 from lfa1
*            into w_stcd1
*            WHERE lifnr = payr-lifnr.
*
* NEW CODE
          SELECT stcd1
          UP TO 1 ROWS  from lfa1
            into w_stcd1
            WHERE lifnr = payr-lifnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

            it_spins-prut = w_stcd1.
        ENDIF.
    ENDIF.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single projn ZZ_AGENCIA into (it_spins-pind_proceso, it_spins-pagencia) from bseg
*      where bukrs = bsis-bukrs
*            and belnr = bsis-belnr
*            and gjahr = bsis-gjahr
*            and buzei = bsis-buzei
*            and hkont = bsis-hkont.
*
* NEW CODE
    SELECT projn ZZ_AGENCIA
    UP TO 1 ROWS  into (it_spins-pind_proceso, it_spins-pagencia) from bseg
      where bukrs = bsis-bukrs
            and belnr = bsis-belnr
            and gjahr = bsis-gjahr
            and buzei = bsis-buzei
            and hkont = bsis-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    APPEND IT_spins to t_spins.
ENDSELECT.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM BSAS
*  where bukrs in s_bukrs
*        and hkont in s_hkont
*        and XRAGL <> 'X'
*        and SHKZG = 'H'
*        and budat >= p_budat
*        and zuonr in s_zuonr.
*
* NEW CODE
SELECT *
 FROM BSAS
  where bukrs in s_bukrs
        and hkont in s_hkont
        and XRAGL <> 'X'
        and SHKZG = 'H'
        and budat >= p_budat
        and zuonr in s_zuonr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  CLEAR it_spins.
  it_spins-ptipo_pago = 'C'.
*  it_spins-pfec_emision = payr-ZALDT.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select SINGLE BLDAT BUDAT STBLG STJAH stgrd
*    into (it_spins-pfec_doc, it_spins-pfec_cont, w_belnr, w_gjahr, w_stgrd)
*    from bkpf
*    where bukrs = bsas-bukrs
*      and belnr = bsas-belnr
*      and gjahr = bsas-gjahr.
*
* NEW CODE
  SELECT BLDAT BUDAT STBLG STJAH stgrd
  UP TO 1 ROWS 
    into (it_spins-pfec_doc, it_spins-pfec_cont, w_belnr, w_gjahr, w_stgrd)
    from bkpf
    where bukrs = bsas-bukrs
      and belnr = bsas-belnr
      and gjahr = bsas-gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    CHECK w_stgrd eq 0.
    it_spins-pnro_doc = bsas-belnr.
    it_spins-pejercicio = bsas-gjahr.
*    it_spins-pfec_anula = payr-voidd. "
    it_spins-pcta_ctble = bsas-hkont.
*    it_spins-pcta_cte = w_bankn.
    amount_sap = bsas-dmbtr.
    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
      EXPORTING
        CURRENCY              = bsas-waers
        AMOUNT_INTERNAL       = amount_sap
     IMPORTING
       AMOUNT_DISPLAY        = amount_display
*     EXCEPTIONS
*       INTERNAL_ERROR        = 1
*       OTHERS                = 2
              .
    IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    it_spins-pmonto = amount_display.
    w_aux = strlen( bsas-zuonr ).
    IF w_aux = 13.
      IF bsas-zuonr co '0123456789 '.
        it_spins-pnro_cheque = bsas-zuonr.
      ENDIF.
    ENDIF.

    it_spins-pempresa = bsas-bukrs.
    IF it_spins-pcta_ctble+9(1) = '6'.
      it_spins-pestado = 'CADUCADO FISICO'.
    ELSEIF it_spins-pcta_ctble+9(1) = '7'.
      it_spins-pestado = 'CADUCADO ELECTRONICO'.
    ELSEIF it_spins-pcta_ctble+9(1) = '9'.
      it_spins-pestado = 'REVALIDADO'.
    ELSEIF it_spins-pcta_ctble+9(1) = '8'.
      it_spins-pestado = 'CADUCADO FISCAL'.
    ENDIF.

    w_hkont = bsas-hkont.
    w_hkont+9(1) = '0'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single *
*          from t012k
*          where bukrs = bsas-bukrs
*                and hkont = w_hkont.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
          from t012k
          where bukrs = bsas-bukrs
                and hkont = w_hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc eq 0.
      w_chect = bsas-zuonr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single * from payr
*        where zbukr = t012k-bukrs
*              and hbkid = t012k-hbkid
*              and hktid = t012k-hktid
*              and chect = w_chect.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  from payr
        where zbukr = t012k-bukrs
              and hbkid = t012k-hbkid
              and hktid = t012k-hktid
              and chect = w_chect ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc eq 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT single stcd1 from lfa1
*            into w_stcd1
*            WHERE lifnr = payr-lifnr.
*
* NEW CODE
          SELECT stcd1
          UP TO 1 ROWS  from lfa1
            into w_stcd1
            WHERE lifnr = payr-lifnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

            it_spins-prut = w_stcd1.
        ENDIF.
    ENDIF.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single projn ZZ_AGENCIA into (it_spins-pind_proceso, it_spins-pagencia) from bseg
*      where bukrs = bsas-bukrs
*            and belnr = bsas-belnr
*            and gjahr = bsas-gjahr
*            and buzei = bsas-buzei
*            and hkont = bsas-hkont.
*
* NEW CODE
    SELECT projn ZZ_AGENCIA
    UP TO 1 ROWS  into (it_spins-pind_proceso, it_spins-pagencia) from bseg
      where bukrs = bsas-bukrs
            and belnr = bsas-belnr
            and gjahr = bsas-gjahr
            and buzei = bsas-buzei
            and hkont = bsas-hkont ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    APPEND IT_spins to t_spins.
ENDSELECT.

exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

exec sql.
  EXECUTE PROCEDURE csc_sap_auxiliares.sp_delete_cheques_aux_sap(
                                                                  IN :status
                                                                )
endexec.

  w_iter = 0.
  status = 'X'.
  loop at t_spins INTO it_spins.
    try.
      add 1 to w_iter.
      if w_iter > 1000.
        w_iter = 0.
        exec sql.
          SET CONNECTION DEFAULT
        endexec.
        exec sql.
            set connection 'con'
        endexec.
      endif.
      EXEC SQL.
        EXECUTE PROCEDURE csc_sap_auxiliares.sp_insert_estados(
                                                                      IN :it_spins-ptipo_pago     ,
                                                                      IN :it_spins-pfec_emision   ,
                                                                      IN :it_spins-prut           ,
                                                                      IN :it_spins-pnombre        ,
                                                                      IN :it_spins-pfec_anula     ,
                                                                      IN :it_spins-pfec_doc       ,
                                                                      IN :it_spins-pfec_cont      ,
                                                                      IN :it_spins-pcta_ctble     ,
                                                                      IN :it_spins-pcta_cte       ,
                                                                      IN :it_spins-pmonto         ,
                                                                      IN :it_spins-pnro_cheque    ,
                                                                      IN :it_spins-pempresa       ,
                                                                      IN :it_spins-pmotivo        ,
                                                                      IN :it_spins-pfec_cobro     ,
                                                                      IN :it_spins-pind_cobro     ,
                                                                      IN :it_spins-pagencia       ,
                                                                      IN :it_spins-pestado        ,
                                                                      IN :it_spins-pind_proceso   ,
                                                                      IN :it_spins-pnro_doc       ,
                                                                      IN :it_spins-pejercicio
                                                                      )

      ENDEXEC.
    catch cx_sy_native_sql_error.
      status = ' '.
      write 'problema al insertar el cheque'.
      write:    /,
                it_spins-ptipo_pago     ,
                it_spins-pfec_emision   ,
                it_spins-prut           ,
                it_spins-pnombre        ,
                it_spins-pfec_anula     ,
                it_spins-pfec_doc       ,
                it_spins-pfec_cont      ,
                it_spins-pcta_ctble     ,
                it_spins-pcta_cte       ,
                it_spins-pmonto         ,
                it_spins-pnro_cheque    ,
                it_spins-pempresa       ,
                it_spins-pmotivo        ,
                it_spins-pfec_cobro     ,
                it_spins-pind_cobro     ,
                it_spins-pagencia       ,
                it_spins-pestado        ,
                it_spins-pind_proceso   ,
                it_spins-pnro_doc       ,
                it_spins-pejercicio     ,
                /.
*      message text-001 type 'I'.
*      message `Error in Native SQL.` type 'I'.
    endtry.
*    status = 'X'.
  endloop.


exec sql.
  SET CONNECTION DEFAULT
endexec.

if status = 'X'.
    write: /,
          'El proceso ha terminado correctamente y sin errores'.
endif.
