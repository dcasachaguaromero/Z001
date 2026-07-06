FUNCTION ZINSERT_CHEQUE.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(ZBUKR) TYPE  DZBUKR
*"     REFERENCE(HBKID) TYPE  HBKID
*"     REFERENCE(HKTID) TYPE  HKTID
*"     REFERENCE(RZAWE) TYPE  DZLSCH
*"     REFERENCE(CHECT) TYPE  CHECT
*"  EXPORTING
*"     REFERENCE(STATUS) TYPE  FLAG
*"----------------------------------------------------------------------
TYPE-POOLS: SLIS.
*tables :
*  reguh,   "  Datos de pago del programa de pagos              02
*         regup,
*         bseg,    "  Segmento de documento de Contabilidad            02
*         lfa1,    "  Maestro de proveedores (parte general)           02
*         lfb1,
*         t001,
*         bnka,    "  Maestro de banco                                 02
*         bsak,    "  índice secundario para acreedores (part.comp.)   02
*         bkpf.    "  Cabecera de documento para Contabilidad          02

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
          vnom_retira   type  string  ,
          vnum_opago  type  i ,
          vmotivo   type  string  ,
          vlugar_pago         type  string  ,
          vcheda_nproceso type  i ,
          vcheda_narea  type  string  ,
          vcheda_nmotivo    type  string  ,
          vcheda_nctacbo    type  p ,
          vcheda_cagencia type  i ,
          vcheda_ntraspaso  type  i ,
          vcheda_ftraspaso  type  string  ,
          vcheda_cusuario type  string  ,
          vfec_propuesta_sap type string,
          vid_propuesta_sap type  string,
          vfecha_contable type string,
          vnumero_asignacion type string,
          vreferencia_docto type string,
          VFEC_ANULA TYPE string,
       end of sp_insert.
data: it_spins type standard table of sp_insert with header line.
data: wa_payr type payr,
      it_payr type payr,
*      wa_reguh type reguh,
      str type string,
      w_budat like bsak-budat,
      w_fecha type string,
      w_bankl like t012-bankl,
      w_bankn like t012k-bankn.
*data: it_reguh type standard table of reguh.

*w_fecha = V_FECHA.
*concatenate w_fecha+6(2) '.' w_fecha+4(2) '.' w_fecha+0(4) into w_fecha.

CLEAR it_spins.
refresh it_spins.

*obtener numero de cheque
  if rzawe eq 'C'.
    select single *
      from payr into wa_payr
      where zbukr = ZBUKR
        and hbkid = HBKID
        and hktid = HKTID
        and rzawe = RZAWE
        and chect = CHECT.
    if sy-subrc eq 0.
      it_spins-vempresa  	=	wa_payr-zbukr.
      it_spins-vnumero   	=	wa_payr-chect.
      it_spins-vtipo      = wa_payr-rzawe.
*      IT_SPINS-vCTACTE_SAP  = WA_REGUH-UBKNT.
*      IT_SPINS-vCTACTE_SAP  = WA_REGUH-HKONT.
*      it_spins-vctacte_sap  = wa_reguh-ubhkt.
      CLEAR w_bankn.
      select single BANKN into w_bankn        from t012k
        where BUKRS = wa_payr-zbukr
              and HBKID = wa_payr-hbkid
              and HKTID = wa_payr-hktid.

      it_spins-vctacte_sap = w_bankn.
      CONDENSE it_spins-vctacte_sap NO-GAPS.

      select single stcd1 name1
        into (it_spins-vrol_beneficiario, it_spins-vbeneficiario)
        from lfa1
      where LIFNR = wa_payr-lifnr.


      str = wa_payr-RWBTR.
      replace all occurrences of '.' in str with ''.
      it_spins-vvalor   = str.
      it_spins-vfec_emision   = wa_payr-zaldt.
*      IT_SPINS-vFEC_VENCIMIENTO   	=	WA_REGUH-.
*      IT_SPINS-vFEC_RETIRA   = WA_REGUH-.
      it_spins-vnom_retira 	=	it_spins-vbeneficiario.
*      IT_SPINS-vNUM_OPAGO 	=	WA_REGUH-.
*      IT_SPINS-vMOTIVO   = WA_REGUH-.
      select single zz_agencia ZFBDT ZUONR XBLNR from bsak
        into (it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto)
        where bukrs = wa_payr-zbukr
              and lifnr = wa_payr-lifnr
              and augdt = wa_payr-zaldt
              and augbl = wa_payr-vblnr
              and gjahr = wa_payr-gjahr
              and belnr ne wa_payr-vblnr
              and XZAHL ne 'X'.
*      IT_SPINS-vCHEDA_NPROCESO	=	WA_REGUH-.
*      it_spins-vcheda_narea   = wa_reguh-dorigin.
*      IT_SPINS-vCHEDA_NMOTIVO    = WA_REGUH-.
      it_spins-vfecha_contable = w_budat.
      CLEAR it_spins-vcheda_nctacbo.
      SELECT SINGLE bankl into w_bankl
        from t012
        where BUKRS = wa_payr-zbukr
              and HBKID = wa_payr-hbkid.
      it_spins-vcheda_nctacbo = w_bankl.
*      it_spins-vcheda_nctacbo    = wa_reguh-ubnkl.
*      IT_SPINS-vCHEDA_CAGENCIA  = it_spins-vlugar_pago.
      IT_SPINS-vCHEDA_CAGENCIA  = 0.
      it_spins-vcheda_ntraspaso   = wa_payr-vblnr.
      it_spins-vcheda_ftraspaso	=	wa_payr-laufd.
      it_spins-vcheda_cusuario  = wa_payr-prius.
      it_spins-vfec_propuesta_sap = wa_payr-laufd.
      concatenate it_spins-vfec_propuesta_sap+6(2) '.' it_spins-vfec_propuesta_sap+4(2) '.' it_spins-vfec_propuesta_sap+0(4)   into it_spins-vfec_propuesta_sap.
      it_spins-vid_propuesta_sap = wa_payr-laufi.
      it_spins-VFEC_ANULA = wa_payr-VOIDD.
      IT_SPINS-vFEC_RETIRA = wa_payr-VOIDD.
      append it_spins.
    endif.
  endif.

*BREAK-POINT.
exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.
*         execute procedure pkg_sap_cargas.sap_carga_detalle_gasto ( IN :hkont )

try.
  loop at it_spins.
    EXEC SQL.
      EXECUTE PROCEDURE csc_sap_cheques.SP_INSERT_TES_DOCPAGO_SAP(
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
                                                                    IN :IT_spins-vNOM_RETIRA ,
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
    status = 'X'.
  endloop.
catch cx_sy_native_sql_error.
  status = ' '.
*  message text-001 type 'I'.
*  message `Error in Native SQL.` type 'I'.
endtry.

exec sql.
  SET CONNECTION DEFAULT
endexec.



ENDFUNCTION.
