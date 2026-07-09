*&---------------------------------------------------------------------*
*& Report  ZTR_INS_TRANSFER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZTR_INS_TRANSFER.

PARAMETERS: BUKRS TYPE  DZBUKR,
            V_FECHA type laufd ,
            V_NOMINA  TYPE  LAUFI.


types: begin of sp_insert,
          vempresa    type  string  ,
          vnumero     type  string ,
          vtipo               type  string  ,
          vctacte_sap type  string  ,
          vrol_beneficiario   type  string  ,
          vbeneficiario   type  string  ,
          vvalor  type  string ,
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
          vcheda_nctacbo    type  i ,
          vcheda_cagencia type  i ,
          vcheda_ntraspaso  type  i ,
          vcheda_ftraspaso  type  string  ,
          vcheda_cusuario type  string  ,
          vfec_propuesta_sap type string,
          vid_propuesta_sap type  string,
          vfecha_contable type string,
          vnumero_asignacion type string,
          vreferencia_docto type string,
          fm_status type string,
          file_nbr type string,
          identif_pago type string,
          fecha_envio type string,
          usuario_envio type string,
          ind_pago type string,
          fecha_pago like sy-datum,
          ind_devuelto type string,
          fecha_devuelto type string,
          belnr_dev_ type string,
          gjahr_dev_ type string,
       end of sp_insert.
data: it_spins type standard table of sp_insert with header line.
data:
      it_payr type payr,
      wa_reguh type reguh,
      str type string,
      w_budat like bsak-budat,
      w_fecha type string,
      w_venc like bsak-zfbdt.
data: it_reguh type standard table of reguh.
data: w_bukrs like  bseg-bukrs,
      w_belnr like bseg-belnr,
      w_gjahr like bseg-gjahr,
      w_buzei like bseg-buzei,
      w_blart like bsak-blart .

data: oref   type ref to cx_root,
           texto   type string,
           STATUS  TYPE  FLAG,
           w_rzawe type rzawe value 'V'.

START-OF-SELECTION.

w_fecha = v_fecha.
*CONCATENATE w_fecha+6(4) w_fecha+3(2) w_fecha+0(2) into v_fecha.
concatenate w_fecha+6(2) '.' w_fecha+4(2) '.' w_fecha+0(4) into w_fecha.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select
*        *
*  from reguh into corresponding fields of table it_reguh
*  where laufd = v_fecha
*    and laufi = v_nomina
*    and zbukr = bukrs
*    and xvorl ne 'X'.
*
* NEW CODE
SELECT *

  from reguh into corresponding fields of table it_reguh
  where laufd = v_fecha
    and laufi = v_nomina
    and zbukr = bukrs
    and xvorl ne 'X' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

write: 'Fecha:', v_fecha, /,
       'Nomina:', v_nomina, /,
       'Sociedad:', bukrs, /,
       'Cantidad de registros:', sy-dbcnt.
*obtener numero de cheque
loop at it_reguh into wa_reguh.
  move-corresponding wa_reguh to it_spins.
  clear it_spins.

  if wa_reguh-rzawe eq w_rzawe.
    clear w_gjahr.
    call function 'GET_CURRENT_YEAR'
     exporting
       bukrs         = wa_reguh-zbukr
       date          = wa_reguh-zaldt
     importing
*       CURRM         =
       curry         = w_gjahr
*       PREVM         =
*       PREVY         =
              .

*        check wa_payr-voidr eq 0.
        it_spins-vempresa  	=	wa_reguh-zbukr.
*        it_spins-vnumero     = wa_payr-chect.
*        it_spins-vtipo      = wa_reguh-rzawe.

*        IF wa_payr-checv = '*'.
*          select single chect into it_spins-vcheque_sus
*            from payr CLIENT SPECIFIED
*            where mandt = sy-mandt
*                and ZBUKR = wa_payr-zbukr
*                and HBKID = wa_payr-hbkid
*                and HKTID = wa_payr-hktid
*                and CHECV = wa_payr-chect
*                .
*        else.
*          it_spins-vcheque_sus   = wa_payr-checv.
*        ENDIF.

*        IT_SPINS-vCTACTE_SAP  = WA_REGUH-HKONT.
*        it_spins-vctacte_sap  = wa_reguh-ubhkt.
        it_spins-vctacte_sap  = wa_reguh-ubknt.
        it_spins-vrol_beneficiario 	=	wa_reguh-stcd1.
        concatenate wa_reguh-name1 wa_reguh-name2 into it_spins-vbeneficiario.

        str = wa_reguh-rwbtr.
        replace all occurrences of '.' in str with ''.
        replace all occurrences of ',' in str with ''.
        it_spins-vvalor   = str.
        it_spins-vfec_emision   = wa_reguh-zaldt.
*        IT_SPINS-vFEC_RETIRA   = WA_REGUH-.
*        IT_SPINS-vNUM_OPAGO 	=	WA_REGUH-.
*        IT_SPINS-vMOTIVO   = WA_REGUH-.
        clear w_venc.
        clear:  w_bukrs	,
                w_belnr	,
                w_gjahr	,
                w_buzei	,
                w_blart.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single bukrs belnr gjahr buzei zz_agencia zfbdt zuonr xblnr xref1 zfbdt blart from bsak
*          into (w_bukrs, w_belnr, w_gjahr, w_buzei,it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, it_spins-vcheda_narea, w_venc, w_blart )
*          where bukrs = wa_reguh-zbukr
*                and lifnr = wa_reguh-lifnr
**                and augdt = wa_payr-zaldt
*                and augbl = wa_reguh-vblnr
**               and gjahr = wa_payr-gjahr
*                and belnr ne wa_reguh-vblnr
*                and xzahl ne 'X'.
*
* NEW CODE
        SELECT bukrs belnr gjahr buzei zz_agencia zfbdt zuonr xblnr xref1 zfbdt blart
        UP TO 1 ROWS  from bsak
          into (w_bukrs, w_belnr, w_gjahr, w_buzei,it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, it_spins-vcheda_narea, w_venc, w_blart )
          where bukrs = wa_reguh-zbukr
                and lifnr = wa_reguh-lifnr
*                and augdt = wa_payr-zaldt
                and augbl = wa_reguh-vblnr
*               and gjahr = wa_payr-gjahr
                and belnr ne wa_reguh-vblnr
                and xzahl ne 'X' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
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
        it_spins-vtipo      = w_blart.
*        IT_SPINS-vCHEDA_NPROCESO	=	WA_REGUH-.
*        IT_SPINS-vCHEDA_NMOTIVO    = WA_REGUH-.
        it_spins-vfecha_contable = w_budat.
        it_spins-vcheda_nctacbo  	=	wa_reguh-ubnkl.
*        IT_SPINS-vCHEDA_CAGENCIA  = it_spins-vlugar_pago.
        it_spins-vcheda_cagencia  = 0.
        it_spins-vcheda_ntraspaso   = wa_reguh-vblnr.
        it_spins-vcheda_ftraspaso	=	wa_reguh-laufd.
*        it_spins-vcheda_cusuario  = wa_payr-prius.
        it_spins-vfec_propuesta_sap = wa_reguh-laufd.
        concatenate it_spins-vfec_propuesta_sap+6(2) '.' it_spins-vfec_propuesta_sap+4(2) '.' it_spins-vfec_propuesta_sap+0(4)   into it_spins-vfec_propuesta_sap.
        it_spins-vid_propuesta_sap = wa_reguh-laufi.
        it_spins-fm_status  = wa_reguh-fm_status  .
        it_spins-file_nbr	=	wa_reguh-file_nbr	.
        it_spins-identif_pago	=	wa_reguh-identif_pago	.
        it_spins-fecha_envio  = wa_reguh-fecha_envio  .
        it_spins-usuario_envio  = wa_reguh-usuario_envio  .
        it_spins-ind_pago	=	wa_reguh-ind_pago	.
        it_spins-fecha_pago	=	wa_reguh-fecha_pago	.
        it_spins-ind_devuelto	=	wa_reguh-ind_devuelto	.
        it_spins-fecha_devuelto	=	wa_reguh-fecha_devuelto	.
        it_spins-belnr_dev_ = wa_reguh-belnr_dev  .
        it_spins-gjahr_dev_ = wa_reguh-gjahr_dev  .
        append it_spins.
    endif.
endloop.

exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.
*         execute procedure pkg_sap_cargas.sap_carga_detalle_gasto ( IN :hkont )
try.
  EXEC SQL.
      EXECUTE PROCEDURE csc_sap_transfer.sptr_delete_tes_docpago_sap(
                                                                  IN :BUKRS  ,
                                                                  IN :w_fecha  ,
                                                                  IN :V_NOMINA,
                                                                  IN :SY-UNAME
                                                                  )
    ENDEXEC.
  loop at it_spins.
    EXEC SQL.
      EXECUTE PROCEDURE csc_sap_transfer.SPTR_INSERT_TES_DOCPAGO_SAP(
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
                                                                    IN :IT_spins-vreferencia_docto,
                                                                    IN :IT_spins-FM_STATUS,
                                                                    IN :IT_spins-FILE_NBR,
                                                                    IN :IT_spins-IDENTIF_PAGO,
                                                                    IN :IT_spins-FECHA_ENVIO,
                                                                    IN :IT_spins-USUARIO_ENVIO,
                                                                    IN :IT_spins-IND_PAGO,
                                                                    IN :IT_spins-FECHA_PAGO,
                                                                    IN :IT_spins-IND_DEVUELTO,
                                                                    IN :IT_spins-FECHA_DEVUELTO,
                                                                    IN :IT_spins-BELNR_DEV_,
                                                                    IN :IT_spins-GJAHR_DEV_
                                                                    )

    ENDEXEC.
    status = 'X'.
  endloop.
catch cx_sy_native_sql_error into oref.
    texto = oref->get_text( ).

  status = ' '.
*  message text-001 type 'I'.
*  message `Error in Native SQL.` type 'I'.
endtry.

exec sql.
  SET CONNECTION DEFAULT
endexec.
