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

REPORT  ZINSERT_ANULADOS.

type-pools: slis.
tables :
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         payr,
         t001,
         bnka,    "  Maestro de banco                                 02
         bsak,    "  índice secundario para acreedores (part.comp.)   02
         bkpf.    "  Cabecera de documento para Contabilidad          02

types: begin of sp_insert,
          vempresa    type  string  ,
          vnumero     type  p ,
          vtipo               type  string  ,
          vctacte_sap type  string  ,
          vrol_beneficiario   type  string  ,
          vbeneficiario   type  string  ,
          vvalor  type  p ,
          vfec_emision  type  string  ,
          vfec_vencimiento    type  string  ,
          vfec_retira   type  string  ,
          vcheque_sus   type  string  ,
          vnum_opago  type  i ,
          vmotivo   type  string  ,
          vlugar_pago         type  string  ,
          vcheda_nproceso type  i ,
          vcheda_narea  type  string  ,
          vcheda_nmotivo    type  string  ,
          vcheda_nctacbo    type  string ,
          vcheda_cagencia type  i ,
          vcheda_ntraspaso  type  i ,
          vcheda_ftraspaso  type  string  ,
          vcheda_cusuario type  string  ,
          vfec_propuesta_sap type string,
          vid_propuesta_sap type  string,
          vfecha_contable type string,
          vnumero_asignacion type string,
          vreferencia_docto type string,
       end of sp_insert.
data: it_spins type standard table of sp_insert with header line.
data: wa_payr type payr,
      it_payr type payr,
      str type string,
      w_budat like bsak-budat,
      w_bankn type bankn,
      w_bankl type BANKK,
      w_venc like bsak-zfbdt.
data: it_reguh type standard table of reguh.
data: w_bukrs like  bseg-bukrs,
      w_belnr like bseg-belnr,
      w_gjahr like bseg-gjahr,
      w_buzei like bseg-buzei.
SELECT-OPTIONS: s_zbukr FOR payr-ZBUKR,
                 s_LAUFD for payr-LAUFD,
                 s_voidr for payr-voidr.
*PARAMETERS: p_xzahl like bsak-xzahl.


START-OF-SELECTION.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select * into wa_payr
*      from payr client specified
*      where mandt = sy-mandt
*        and zbukr in s_zbukr
*        and chect < 9000000000000
**        and laufd = wa_reguh-laufd
**        and laufi = wa_reguh-laufi
**        and gjahr = w_gjahr
*        and voidr in s_voidr
*      .
*
* NEW CODE
    SELECT *
 into wa_payr
      from payr client specified
      where mandt = sy-mandt
        and zbukr in s_zbukr
        and chect < 9000000000000
*        and laufd = wa_reguh-laufd
*        and laufi = wa_reguh-laufi
*        and gjahr = w_gjahr
        and voidr in s_voidr
       ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

        clear it_spins.
        clear w_gjahr.
        w_gjahr = wa_payr-gjahr.


*        check wa_payr-voidr eq 0.
        it_spins-vempresa  	=	wa_payr-zbukr.
        it_spins-vnumero   	=	wa_payr-chect.
        it_spins-vtipo      = wa_payr-rzawe.

        if wa_payr-checv = '*'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          select single chect into it_spins-vcheque_sus
*            from payr client specified
*            where mandt = sy-mandt
*                and zbukr = wa_payr-zbukr
*                and hbkid = wa_payr-hbkid
*                and hktid = wa_payr-hktid
*                and checv = wa_payr-chect
*                .
*
* NEW CODE
          SELECT chect
          UP TO 1 ROWS  into it_spins-vcheque_sus
            from payr client specified
            where mandt = sy-mandt
                and zbukr = wa_payr-zbukr
                and hbkid = wa_payr-hbkid
                and hktid = wa_payr-hktid
                and checv = wa_payr-chect
                 ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        else.
          it_spins-vcheque_sus 	=	wa_payr-checv.
        endif.

*        IT_SPINS-vCTACTE_SAP  = WA_REGUH-HKONT.
*        it_spins-vctacte_sap  = wa_reguh-ubhkt.
*        it_spins-vctacte_sap  = wa_payr-UBHKT.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single stcd1 into it_spins-vrol_beneficiario
*          from lfa1
*          where lifnr = wa_payr-lifnr.
*
* NEW CODE
        SELECT stcd1
        UP TO 1 ROWS  into it_spins-vrol_beneficiario
          from lfa1
          where lifnr = wa_payr-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        concatenate wa_payr-znme1 wa_payr-znme2 into it_spins-vbeneficiario.

        str = wa_payr-RWBTR.
        replace all occurrences of '.' in str with ''.
        it_spins-vvalor   = str.
        it_spins-vfec_emision   = wa_payr-zaldt.
*        IT_SPINS-vFEC_RETIRA   = WA_REGUH-.
*        IT_SPINS-vNUM_OPAGO 	=	WA_REGUH-.
*        IT_SPINS-vMOTIVO   = WA_REGUH-.
        clear w_venc.
        clear:  w_bukrs	,
                w_belnr	,
                w_gjahr	,
                w_buzei	.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single bukrs belnr gjahr buzei zz_agencia zfbdt zuonr xblnr zz_agencia zfbdt from bsak
*          into (w_bukrs, w_belnr, w_gjahr, w_buzei,it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, it_spins-vcheda_narea, w_venc)
*          where bukrs = wa_payr-zbukr
*                and belnr ne wa_payr-vblnr
*                and lifnr = wa_payr-lifnr
*                and gjahr = wa_payr-gjahr
**                and augdt = wa_payr-zaldt
*                and augbl = wa_payr-vblnr
*                and xzahl ne 'X'.
*
* NEW CODE
        SELECT bukrs belnr gjahr buzei zz_agencia zfbdt zuonr xblnr zz_agencia zfbdt
        UP TO 1 ROWS  from bsak
          into (w_bukrs, w_belnr, w_gjahr, w_buzei,it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, it_spins-vcheda_narea, w_venc)
          where bukrs = wa_payr-zbukr
                and belnr ne wa_payr-vblnr
                and lifnr = wa_payr-lifnr
                and gjahr = wa_payr-gjahr
*                and augdt = wa_payr-zaldt
                and augbl = wa_payr-vblnr
                and xzahl ne 'X' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single zzdesc_est zzmot_emis
*                 into (it_spins-vmotivo, it_spins-vcheda_nmotivo)
*            from bseg
*            where bukrs = w_bukrs
*                  and belnr = w_belnr
*                  and gjahr = w_gjahr
*                  and buzei = w_buzei.
*
* NEW CODE
        SELECT zzdesc_est zzmot_emis
        UP TO 1 ROWS 
                 into (it_spins-vmotivo, it_spins-vcheda_nmotivo)
            from bseg
            where bukrs = w_bukrs
                  and belnr = w_belnr
                  and gjahr = w_gjahr
                  and buzei = w_buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        it_spins-vfec_vencimiento     = w_venc.
*        IT_SPINS-vCHEDA_NPROCESO	=	WA_REGUH-.
*        it_spins-vcheda_narea   = wa_reguh-dorigin.
*        IT_SPINS-vCHEDA_NMOTIVO    = WA_REGUH-.
        it_spins-vfecha_contable = w_budat.

        CLEAR w_bankn.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single bankn into w_bankn
*          from t012k
*          where
*                BUKRS = wa_payr-zbukr
*                and HBKID = wa_payr-hbkid
*                and HKTID = wa_payr-hktid.
*
* NEW CODE
        SELECT bankn
        UP TO 1 ROWS  into w_bankn
          from t012k
          where
                BUKRS = wa_payr-zbukr
                and HBKID = wa_payr-hbkid
                and HKTID = wa_payr-hktid ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        it_spins-vctacte_sap = w_bankn.

        CLEAR w_bankl.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single bankl into w_bankl
*          from t012
*          where
*                BUKRS = wa_payr-zbukr
*                and HBKID = wa_payr-hbkid.
*
* NEW CODE
        SELECT bankl
        UP TO 1 ROWS  into w_bankl
          from t012
          where
                BUKRS = wa_payr-zbukr
                and HBKID = wa_payr-hbkid ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        it_spins-vcheda_nctacbo  	=	w_bankl.
*        IT_SPINS-vCHEDA_CAGENCIA  = it_spins-vlugar_pago.
        it_spins-vcheda_cagencia  = 0.
        it_spins-vcheda_ntraspaso   = wa_payr-vblnr.
        it_spins-vcheda_ftraspaso	=	wa_payr-laufd.
        it_spins-vcheda_cusuario  = wa_payr-prius.
        it_spins-vfec_propuesta_sap = wa_payr-laufd.
        concatenate it_spins-vfec_propuesta_sap+6(2) '.' it_spins-vfec_propuesta_sap+4(2) '.' it_spins-vfec_propuesta_sap+0(4)   into it_spins-vfec_propuesta_sap.
        it_spins-vid_propuesta_sap = wa_payr-laufi.
        append it_spins.
    ENDSELECT.
exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.
*         execute procedure pkg_sap_cargas.sap_carga_detalle_gasto ( IN :hkont )
try.
  EXEC SQL.
      EXECUTE PROCEDURE csc_sap_cheques.sp_delete_tes_docpago_anu(
                                                                  IN :IT_spins-vEMPRESA
                                                                  )
    ENDEXEC.
  loop at it_spins.
    EXEC SQL.
      EXECUTE PROCEDURE csc_sap_cheques.sp_insert_tes_docpago_anu(
                                                                    IN :IT_spins-vEMPRESA  ,
                                                                    IN :IT_spins-vNUMERO   ,
                                                                    IN :IT_spins-vTipo             ,
                                                                    IN :IT_spins-vCTACTE_SAP,
                                                                    IN :IT_spins-vROL_BENEFICIARIO ,
                                                                    IN :IT_spins-vBENEFICIARIO ,
                                                                    IN :IT_spins-vVALOR ,
                                                                    IN :IT_spins-vFEC_EMISION ,
                                                                    IN :IT_spins-vFEC_VENCIMIENTO   ,
                                                                    IN :IT_spins-vFEC_RETIRA ,
                                                                    IN :IT_spins-vcheque_sus ,
                                                                    IN :IT_spins-vNUM_OPAGO ,
                                                                    IN :IT_spins-vMOTIVO ,
                                                                    IN :IT_spins-vLUGAR_PAGO       ,
                                                                    IN :IT_spins-vCHEDA_NPROCESO,
                                                                    IN :IT_spins-vCHEDA_NAREA ,
                                                                    IN :IT_spins-vCHEDA_NMOTIVO  ,
                                                                    IN :IT_spins-vCHEDA_NCTACBO  ,
                                                                    IN :IT_spins-vCHEDA_CAGENCIA,
                                                                    IN :IT_spins-vCHEDA_NTRASPASO ,
                                                                    IN :IT_spins-vCHEDA_FTRASPASO,
                                                                    IN :IT_spins-vCHEDA_CUSUARIO,
                                                                    IN :IT_spins-vFEC_PROPUESTA_SAP,
                                                                    IN :IT_spins-vID_PROPUESTA_SAP,
                                                                    IN :IT_spins-vfecha_contable,
                                                                    IN :IT_spins-vnumero_asignacion,
                                                                    IN :IT_spins-vreferencia_docto
                                                                  )

    ENDEXEC.
*    status = 'X'.
  endloop.
catch cx_sy_native_sql_error.
write: 'error'.
endtry.

exec sql.
  SET CONNECTION DEFAULT
endexec.
