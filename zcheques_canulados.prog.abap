*&---------------------------------------------------------------------*
*& Report  ZADDPAGOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCHEQUES_CANULADOS.

type-pools: slis.
tables : payr, bsas, bsak.

*Tipos
types: begin of sp_insert,
          empresa             type  string  ,
          numero              type  p ,
          vtipo                type  string  ,
          cuenta          type  string  ,
          vrol_beneficiario   type  string  ,
          vbeneficiario   type  string  ,
          vvalor  type  p ,
          vfec_emision  type  string  ,
          fec_anula    like sy-datum  ,
          fec_cobro     like sy-datum  ,
          vnom_retira   type  string  ,
          nro_reemplazo  type  string ,
          vmotivo   type  string  ,
          vlugar_pago         type  string  ,
          vcheda_nproceso type  i ,
          vcheda_narea  type  string  ,
          vcheda_nmotivo    type  string  ,
          cta_bancaria    type  string ,
          vcheda_cagencia type  i ,
          docto_pago  type  i ,
          vcheda_ftraspaso  like sy-datum  ,
          vcheda_cusuario type  string  ,
          vfec_propuesta_sap type string,
          vid_propuesta_sap type  string,
          fec_calc_venc like sy-datum,
          nro_asignacion type string,
          ref_doc type string,
          fec_referencia like sy-datum,
       end of sp_insert.
data: it_spins type sp_insert,
      t_spins type STANDARD TABLE OF sp_insert.
data: wa_reguh type reguh,
      str type string,
      w_budat like bsak-budat,
      w_fecha type string,
      w_iter type i,
      w_monto like payr-rwbtr,
      status type statusflag1,
      w_name1 like payr-znme1,
      w_name2 like payr-znme2,
      w_bankn like t012k-bankn.
data: amount_display like wmto_s-amount,
      amount_sap like wmto_s-amount,
      l_oref TYPE REF TO cx_root.
data: it_reguh type standard table of reguh.

SELECT-OPTIONS: s_zbukr FOR payr-ZBUKR,
                 s_LAUFD for payr-LAUFD.

PARAMETERS: p_voidd like payr-voidd.

START-OF-SELECTION.
  IF status = 'X'.
    exit.
  ENDIF.

  w_iter = 0.
  status = 'X'.

exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

EXEC SQL.
   EXECUTE PROCEDURE aux_sap_cheques.SP_DELETE_TES_NULOS ( IN :status )
ENDEXEC.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * from payr
*  where zbukr in s_zbukr
*        and  VOIDR ne 0
*        and RWBTR ne 0
*        and laufd in s_laufd
*        and chect < 9000000000000
*        and voidd >= p_voidd.
*
* NEW CODE
SELECT *
 from payr
  where zbukr in s_zbukr
        and  VOIDR ne 0
        and RWBTR ne 0
        and laufd in s_laufd
        and chect < 9000000000000
        and voidd >= p_voidd ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  CLEAR it_spins.
  it_spins-vtipo = 'C'.
  it_spins-vfec_emision = payr-ZALDT.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single stcd1
*      into (it_spins-vrol_beneficiario)
*      from lfa1
*      where lifnr = payr-lifnr.
*
* NEW CODE
  SELECT stcd1
  UP TO 1 ROWS 
      into (it_spins-vrol_beneficiario)
      from lfa1
      where lifnr = payr-lifnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  CONCATENATE payr-znme1 payr-znme2 into it_spins-vbeneficiario.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select SINGLE BUDAT
*    into (it_spins-vcheda_ftraspaso)
*    from bkpf
*    where bukrs = payr-zbukr
*      and belnr = payr-vblnr
*      and gjahr = payr-gjahr.
*
* NEW CODE
  SELECT BUDAT
  UP TO 1 ROWS 
    into (it_spins-vcheda_ftraspaso)
    from bkpf
    where bukrs = payr-zbukr
      and belnr = payr-vblnr
      and gjahr = payr-gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  it_spins-docto_pago = payr-vblnr.
*  it_spins-pejercicio = payr-gjahr.

  CLEAR w_bankn.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single bankn into w_bankn
*        from t012k
*        where bukrs = payr-zbukr
*              and hbkid = payr-hbkid
*              and hktid = payr-hktid.
*
* NEW CODE
  SELECT bankn
  UP TO 1 ROWS  into w_bankn
        from t012k
        where bukrs = payr-zbukr
              and hbkid = payr-hbkid
              and hktid = payr-hktid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  it_spins-cuenta = payr-ubhkt.
  it_spins-cta_bancaria = w_bankn.
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

  it_spins-vvalor = amount_display.
  it_spins-numero = payr-chect.
  it_spins-empresa = payr-zbukr.
  CLEAR w_budat.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT single *
*    from bsas
*    where bukrs = payr-zbukr
*              and belnr = payr-vblnr
*              and gjahr = payr-gjahr
*              and augbl <> payr-vblnr
*              and hkont = payr-ubhkt.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
    from bsas
    where bukrs = payr-zbukr
              and belnr = payr-vblnr
              and gjahr = payr-gjahr
              and augbl <> payr-vblnr
              and hkont = payr-ubhkt ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc eq 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single zfbdt zuonr xblnr budat
*        into (w_budat, it_spins-nro_asignacion, it_spins-ref_doc, it_spins-fec_referencia)
*        from bsas
*        where bukrs = bsas-bukrs
*              and belnr = bsas-augbl
*              and gjahr = bsas-gjahr
*              and hkont = payr-ubhkt
*              and augbl = bsas-augbl
*              .
*
* NEW CODE
      SELECT zfbdt zuonr xblnr budat
      UP TO 1 ROWS 
        into (w_budat, it_spins-nro_asignacion, it_spins-ref_doc, it_spins-fec_referencia)
        from bsas
        where bukrs = bsas-bukrs
              and belnr = bsas-augbl
              and gjahr = bsas-gjahr
              and hkont = payr-ubhkt
              and augbl = bsas-augbl
               ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.

  it_spins-fec_calc_venc = w_budat.
  it_spins-fec_cobro = PAYR-BANCD.
  it_spins-fec_anula = payr-voidd.
  it_spins-vmotivo = payr-voidr.
  IT_spins-vCHEDA_NMOTIVO = payr-voidr.
  it_spins-vFEC_PROPUESTA_SAP = payr-laufd.
  IT_spins-vID_PROPUESTA_SAP = payr-laufi.
  it_spins-NRO_REEMPLAZO = payr-checv.

  IF payr-PRIUS ne ' '.
    IT_spins-vCHEDA_CUSUARIO = payr-PRIUS.
  ELSE.
    IT_spins-vCHEDA_CUSUARIO = sy-UNAME.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * from bsak CLIENT SPECIFIED
*    where mandt = sy-mandt
*          and bukrs = payr-zbukr
*          and lifnr = payr-lifnr
*          and zuonr = payr-chect
*          and augbl <> payr-vblnr
*          and belnr <> payr-vblnr.
*
* NEW CODE
  SELECT *
 from bsak CLIENT SPECIFIED
    where mandt = sy-mandt
          and bukrs = payr-zbukr
          and lifnr = payr-lifnr
          and zuonr = payr-chect
          and augbl <> payr-vblnr
          and belnr <> payr-vblnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
            CHECK bsak-augbl ne bsak-belnr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE * FROM PAYR CLIENT SPECIFIED
*              WHERE MANDT = SY-MANDT
*                    AND ZBUKR = BSAK-BUKRS
*                    AND VBLNR = BSAK-AUGBL
*                    AND GJAHR = BSAK-GJAHR.
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS  FROM PAYR CLIENT SPECIFIED
              WHERE MANDT = SY-MANDT
                    AND ZBUKR = BSAK-BUKRS
                    AND VBLNR = BSAK-AUGBL
                    AND GJAHR = BSAK-GJAHR ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF SY-SUBRC EQ 0.
                it_spins-NRO_REEMPLAZO = payr-chect.
              ENDIF.
  ENDSELECT.

*  it_spins-pind_cobro
*  it_spins-pestado = 'EMITIDO'.
*  it_spins-pind_proceso
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
        EXECUTE PROCEDURE aux_sap_cheques.SP_INSERT_NULOS_SAP (
                                                                    IN :IT_spins-EMPRESA  ,
                                                                    IN :IT_spins-NUMERO   ,
                                                                    IN :IT_spins-vTipo             ,
                                                                    IN :IT_spins-cuenta,
                                                                    IN :IT_spins-vROL_BENEFICIARIO ,
                                                                    IN :IT_spins-vBENEFICIARIO ,
                                                                    IN :IT_spins-vVALOR ,
                                                                    IN :IT_spins-vFEC_EMISION ,
                                                                    IN :IT_spins-fec_anula   ,
                                                                    IN :IT_spins-FEC_COBRO ,
                                                                    IN :IT_spins-vnom_retira ,
                                                                    IN :IT_spins-NRO_REEMPLAZO ,
                                                                    IN :IT_spins-vMOTIVO ,
                                                                    IN :IT_spins-vLUGAR_PAGO       ,
                                                                    IN :IT_spins-vCHEDA_NPROCESO,
                                                                    IN :IT_spins-vCHEDA_NAREA ,
                                                                    IN :IT_spins-vCHEDA_NMOTIVO  ,
                                                                    IN :IT_spins-cta_bancaria  ,
                                                                    IN :IT_spins-vCHEDA_CAGENCIA,
                                                                    IN :IT_spins-docto_pago ,
                                                                    IN :IT_spins-vCHEDA_FTRASPASO,
                                                                    IN :IT_spins-vCHEDA_CUSUARIO,
                                                                    IN :IT_spins-vFEC_PROPUESTA_SAP,
                                                                    IN :IT_spins-vID_PROPUESTA_SAP,
                                                                    IN :IT_spins-fec_calc_venc,
                                                                    IN :IT_spins-nro_asignacion,
                                                                    IN :IT_spins-ref_doc,
                                                                    IN :IT_spins-fec_referencia
                                                               )

      ENDEXEC.
    catch cx_sy_native_sql_error into l_oref.
      status = ' '.
      write 'problema al insertar el cheque'.
      write:    /,
                IT_spins-EMPRESA  ,
                IT_spins-NUMERO   ,
                IT_spins-vTipo             ,
                IT_spins-cuenta,
                IT_spins-vROL_BENEFICIARIO ,
                IT_spins-vBENEFICIARIO ,
                IT_spins-vVALOR ,
                IT_spins-vFEC_EMISION ,
                IT_spins-fec_anula   ,
                IT_spins-FEC_COBRO ,
                it_spins-vnom_retira,
                IT_spins-NRO_REEMPLAZO ,
                IT_spins-vMOTIVO ,
                IT_spins-vLUGAR_PAGO       ,
                IT_spins-vCHEDA_NPROCESO,
                IT_spins-vCHEDA_NAREA ,
                IT_spins-vCHEDA_NMOTIVO  ,
                IT_spins-cta_bancaria  ,
                IT_spins-vCHEDA_CAGENCIA,
                IT_spins-docto_pago ,
                IT_spins-vCHEDA_FTRASPASO,
                IT_spins-vCHEDA_CUSUARIO,
                IT_spins-vFEC_PROPUESTA_SAP,
                IT_spins-vID_PROPUESTA_SAP,
                IT_spins-fec_calc_venc,
                IT_spins-nro_asignacion,
                IT_spins-ref_doc,
                IT_spins-fec_referencia,
                /.
*      message text-001 type 'I'.
*      message `Error in Native SQL.` type 'I'.
    endtry.
ENDSELECT.

exec sql.
  SET CONNECTION DEFAULT
endexec.

if status = 'X'.
    write: /,
          'El proceso ha terminado correctamente y sin errores'.
endif.
