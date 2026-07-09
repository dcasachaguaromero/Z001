*&---------------------------------------------------------------------*
*& Report  ZADDPAGOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCHEQUES_SEMITIDOS.

type-pools: slis.
tables : payr.

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
          pnro_doc        type string,
          pejercicio      type string,
       end of sp_insert.
data: it_spins type sp_insert,
      t_spins type STANDARD TABLE OF sp_insert.
data: wa_payr type payr,
      wa_reguh type reguh,
      str type string,
      w_budat like bsak-budat,
      w_fecha type string,
      w_iter type i,
      w_monto like payr-rwbtr,
      status type statusflag1,
      w_bankn like t012k-bankn.
data: amount_display like wmto_s-amount,
      amount_sap like wmto_s-amount.
data: it_reguh type standard table of reguh.

SELECT-OPTIONS: s_zbukr FOR payr-ZBUKR.

START-OF-SELECTION.
  IF status = 'X'.
    exit.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * from payr
*  where zbukr in s_zbukr.
*
* NEW CODE
SELECT *
 from payr
  where zbukr in s_zbukr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  it_spins-ptipo_pago = 'C'.
  it_spins-pfec_emision = payr-ZALDT.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single stcd1 name1
*        into (it_spins-prut, it_spins-pnombre)
*        from lfa1
*      where lifnr = payr-lifnr.
*
* NEW CODE
  SELECT stcd1 name1
  UP TO 1 ROWS 
        into (it_spins-prut, it_spins-pnombre)
        from lfa1
      where lifnr = payr-lifnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*  it_spins-pfec_anula
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select SINGLE BLDAT BUDAT
*    into (it_spins-pfec_doc, it_spins-pfec_cont)
*    from bkpf
*    where bukrs = payr-zbukr
*      and belnr = payr-vblnr
*      and gjahr = payr-gjahr.
*
* NEW CODE
  SELECT BLDAT BUDAT
  UP TO 1 ROWS 
    into (it_spins-pfec_doc, it_spins-pfec_cont)
    from bkpf
    where bukrs = payr-zbukr
      and belnr = payr-vblnr
      and gjahr = payr-gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  it_spins-pnro_doc = payr-vblnr.
  it_spins-pejercicio = payr-gjahr.

  CLEAR w_bankn.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single bankn into w_bankn        from t012k
*        where bukrs = payr-zbukr
*              and hbkid = payr-hbkid
*              and hktid = payr-hktid.
*
* NEW CODE
  SELECT bankn
  UP TO 1 ROWS  into w_bankn        from t012k
        where bukrs = payr-zbukr
              and hbkid = payr-hbkid
              and hktid = payr-hktid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  it_spins-pcta_ctble = payr-ubhkt.
  it_spins-pcta_cte = w_bankn.
  amount_sap = payr-rwbtr.
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      CURRENCY              = payr-waers
      AMOUNT_INTERNAL       = amount_sap
   IMPORTING
     AMOUNT_DISPLAY        = amount_display
*   EXCEPTIONS
*     INTERNAL_ERROR        = 1
*     OTHERS                = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  it_spins-pmonto = amount_display.
  it_spins-pnro_cheque = payr-chect.
  it_spins-pempresa = payr-zbukr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single zz_agencia zfbdt zuonr xblnr ZZMOT_EMIS from bsak
*        into (it_spins-pagencia, w_budat, it_spins-p_nroasig, it_spins-p_referencia,it_spins-pmotivo)
*        where bukrs = wa_payr-zbukr
*              and lifnr = payr-lifnr
*              and augdt = payr-zaldt
*              and augbl = payr-vblnr
*              and gjahr = payr-gjahr
*              and belnr ne payr-vblnr
*              and xzahl ne 'X'.
*
* NEW CODE
  SELECT zz_agencia zfbdt zuonr xblnr ZZMOT_EMIS
  UP TO 1 ROWS  from bsak
        into (it_spins-pagencia, w_budat, it_spins-p_nroasig, it_spins-p_referencia,it_spins-pmotivo)
        where bukrs = wa_payr-zbukr
              and lifnr = payr-lifnr
              and augdt = payr-zaldt
              and augbl = payr-vblnr
              and gjahr = payr-gjahr
              and belnr ne payr-vblnr
              and xzahl ne 'X' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*  it_spins-pfec_cobro = PAYR-
*  it_spins-pind_cobro
  it_spins-pestado = 'EMITIDO'.
*  it_spins-pind_proceso
APPEND IT_spins to t_spins.
ENDSELECT.

exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.
*         execute procedure pkg_sap_cargas.sap_carga_detalle_gasto ( IN :hkont )

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
        EXECUTE PROCEDURE csc_sap_auxiliares.sp_insert_emitidos(
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
