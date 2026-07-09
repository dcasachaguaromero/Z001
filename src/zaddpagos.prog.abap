*&---------------------------------------------------------------------*
*& Report  ZADDPAGOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZADDPAGOS.

type-pools: slis.
tables : reguh,   "  Datos de pago del programa de pagos              02
         regup,
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
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
          vnom_retira   type  string  ,
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
       end of sp_insert.
data: it_spins type standard table of sp_insert with header line.
data: wa_payr type payr,
      it_payr type STANDARD TABLE OF payr,
      wa_reguh type reguh,
      str type string,
      w_budat like bsak-budat,
      w_fecha type string,
      w_iter type i,
      status type statusflag1.
data: it_reguh type standard table of reguh.

SELECT-OPTIONS: s_bukrs FOR reguh-zbukr,
                s_rzawe for reguh-RZAWE.

START-OF-SELECTION.
*w_fecha = v_fecha.
*concatenate w_fecha+6(2) '.' w_fecha+4(2) '.' w_fecha+0(4) into w_fecha.
  IF status = 'X'.
    exit.
  ENDIF.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select
*        laufd
*        laufi
*        xvorl
*        zbukr
*        lifnr
*        kunnr
*        empfg
*        vblnr
*        avisg
*        waers
*        srtgb
*        anred
*        name1
*        name4
*        ort01
*        stras
*        stcd1
*        zspra
*        zaldt
*        rzawe
*        hktid
*        hbkid
*        ubknt
*        ubnks
*        ubnkl
*        ubhkt
*        valut
*        rbetr
*        abwae
*        paygr
*        zbnky
*        ubnky
*  from reguh into corresponding fields of table it_reguh
*  where zbukr in s_bukrs
*        and rzawe in s_rzawe
*        and xvorl ne 'X'.
*
* NEW CODE
SELECT laufd
        laufi
        xvorl
        zbukr
        lifnr
        kunnr
        empfg
        vblnr
        avisg
        waers
        srtgb
        anred
        name1
        name4
        ort01
        stras
        stcd1
        zspra
        zaldt
        rzawe
        hktid
        hbkid
        ubknt
        ubnks
        ubnkl
        ubhkt
        valut
        rbetr
        abwae
        paygr
        zbnky
        ubnky

  from reguh into corresponding fields of table it_reguh
  where zbukr in s_bukrs
        and rzawe in s_rzawe
        and xvorl ne 'X' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*obtener numero de cheque
loop at it_reguh into wa_reguh.
  if wa_reguh-rzawe eq 'C'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select *
*      from payr into TABLE it_payr
*      where zbukr = wa_reguh-zbukr
*        and hbkid = wa_reguh-hbkid
*        and hktid = wa_reguh-hktid
*        and laufd = wa_reguh-laufd
*        and laufi = wa_reguh-laufi
*        and vblnr = wa_reguh-vblnr.
*
* NEW CODE
    SELECT *

      from payr into TABLE it_payr
      where zbukr = wa_reguh-zbukr
        and hbkid = wa_reguh-hbkid
        and hktid = wa_reguh-hktid
        and laufd = wa_reguh-laufd
        and laufi = wa_reguh-laufi
        and vblnr = wa_reguh-vblnr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*        and voidr = 0.
    LOOP AT it_payr into wa_payr.
      CLEAR it_spins.
      it_spins-vempresa  	=	wa_reguh-zbukr.
      it_spins-vnumero   	=	wa_payr-chect.
      it_spins-vtipo      = wa_payr-rzawe.
*      IT_SPINS-vCTACTE_SAP  = WA_REGUH-UBKNT.
*      IT_SPINS-vCTACTE_SAP  = WA_REGUH-HKONT.
*      it_spins-vctacte_sap  = wa_reguh-ubhkt.
      it_spins-vctacte_sap  = wa_reguh-ubknt.
      it_spins-vrol_beneficiario 	=	wa_reguh-stcd1.
      it_spins-vbeneficiario 	=	wa_reguh-name1.

      str = wa_reguh-rbetr.
      replace all occurrences of '.' in str with ''.
      it_spins-vvalor   = str.
      it_spins-vfec_emision   = wa_payr-zaldt.
      IT_SPINS-vFEC_VENCIMIENTO     = WA_payr-voidd.
      IT_SPINS-vFEC_RETIRA   = WA_payr-BANCD.
      it_spins-vnom_retira 	=	wa_reguh-znme1.
*      IT_SPINS-vNUM_OPAGO 	=	WA_REGUH-.
*      IT_SPINS-vMOTIVO   = WA_REGUH-.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select single zz_agencia zfbdt zuonr xblnr ZZMOT_EMIS from bsak
*        into (it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, IT_SPINS-vMOTIVO)
*        where bukrs = wa_payr-zbukr
*              and lifnr = wa_payr-lifnr
*              and augdt = wa_payr-zaldt
*              and augbl = wa_payr-vblnr
*              and gjahr = wa_payr-gjahr
*              and belnr ne wa_payr-vblnr
*              and xzahl ne 'X'.
*
* NEW CODE
      SELECT zz_agencia zfbdt zuonr xblnr ZZMOT_EMIS
      UP TO 1 ROWS  from bsak
        into (it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, IT_SPINS-vMOTIVO)
        where bukrs = wa_payr-zbukr
              and lifnr = wa_payr-lifnr
              and augdt = wa_payr-zaldt
              and augbl = wa_payr-vblnr
              and gjahr = wa_payr-gjahr
              and belnr ne wa_payr-vblnr
              and xzahl ne 'X' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*      IT_SPINS-vCHEDA_NPROCESO	=	WA_REGUH-.
      it_spins-vcheda_narea   = wa_PAYR-XBANC.
*      IT_SPINS-vCHEDA_NMOTIVO    = WA_REGUH-.
      it_spins-vfecha_contable = w_budat.
      it_spins-vcheda_nctacbo  	=	wa_reguh-ubnkl.
*      IT_SPINS-vCHEDA_CAGENCIA  = it_spins-vlugar_pago.
*      it_spins-vcheda_cagencia  = 0.
      it_spins-vcheda_ntraspaso   = wa_reguh-vblnr.
      it_spins-vcheda_ftraspaso	=	wa_reguh-laufd.
      it_spins-vcheda_cusuario  = wa_payr-prius.
      it_spins-vfec_propuesta_sap = wa_reguh-laufd.
      concatenate it_spins-vfec_propuesta_sap+6(2) '.' it_spins-vfec_propuesta_sap+4(2) '.' it_spins-vfec_propuesta_sap+0(4)   into it_spins-vfec_propuesta_sap.
      it_spins-vid_propuesta_sap = wa_reguh-laufi.
      append it_spins.
    ENDLOOP.
  ELSE.
    CLEAR it_spins.
    it_spins-vempresa  	=	wa_reguh-zbukr.
*      it_spins-vnumero     = wa_payr-chect.
      it_spins-vtipo      = wa_reguh-rzawe.
*      IT_SPINS-vCTACTE_SAP  = WA_REGUH-UBKNT.
*      IT_SPINS-vCTACTE_SAP  = WA_REGUH-HKONT.
*      it_spins-vctacte_sap  = wa_reguh-ubhkt.
      it_spins-vctacte_sap  = wa_reguh-ubknt.
      it_spins-vrol_beneficiario 	=	wa_reguh-stcd1.
      CONCATENATE wa_reguh-name1 wa_reguh-name2 into it_spins-vbeneficiario.

      str = wa_reguh-rbetr.
      replace all occurrences of '.' in str with ''.
      it_spins-vvalor   = str.
      it_spins-vfec_emision   = wa_reguh-VALUT.
*      IT_SPINS-vFEC_VENCIMIENTO     = WA_payr-voidd.
*      IT_SPINS-vFEC_RETIRA   = WA_REGUH-.
      it_spins-vnom_retira 	=	wa_reguh-znme1.
*      IT_SPINS-vNUM_OPAGO 	=	WA_REGUH-.
*      IT_SPINS-vMOTIVO   = WA_REGUH-.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single zz_agencia zfbdt zuonr xblnr ZZMOT_EMIS  from bsak
*        into (it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, IT_SPINS-vMOTIVO)
*        where bukrs = wa_payr-zbukr
*              and lifnr = wa_reguh-lifnr
*              and augdt = wa_reguh-zaldt
*              and augbl = wa_reguh-vblnr
*              and gjahr = wa_reguh-zaldt+0(4)
*              and belnr ne wa_reguh-vblnr
*              and xzahl ne 'X'.
*
* NEW CODE
        SELECT zz_agencia zfbdt zuonr xblnr ZZMOT_EMIS
        UP TO 1 ROWS   from bsak
        into (it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, IT_SPINS-vMOTIVO)
        where bukrs = wa_payr-zbukr
              and lifnr = wa_reguh-lifnr
              and augdt = wa_reguh-zaldt
              and augbl = wa_reguh-vblnr
              and gjahr = wa_reguh-zaldt+0(4)
              and belnr ne wa_reguh-vblnr
              and xzahl ne 'X' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*             where zbukr = wa_reguh-zbukr
*        and hbkid = wa_reguh-hbkid
*        and hktid = wa_reguh-hktid
*        and laufd = wa_reguh-laufd
*        and laufi = wa_reguh-laufi
*        and vblnr = wa_reguh-vblnr.
*      IT_SPINS-vCHEDA_NPROCESO	=	WA_REGUH-.
*      it_spins-vcheda_narea   = wa_reguh-dorigin.
*      IT_SPINS-vCHEDA_NMOTIVO    = WA_REGUH-.
      it_spins-vfecha_contable = w_budat.
      it_spins-vcheda_nctacbo  	=	wa_reguh-ubnkl.
*      IT_SPINS-vCHEDA_CAGENCIA  = it_spins-vlugar_pago.
*      it_spins-vcheda_cagencia  = 0.
      it_spins-vcheda_ntraspaso   = wa_reguh-vblnr.
      it_spins-vcheda_ftraspaso	=	wa_reguh-laufd.
      it_spins-vcheda_cusuario  = wa_payr-prius.
      it_spins-vfec_propuesta_sap = wa_reguh-laufd.
      concatenate it_spins-vfec_propuesta_sap+6(2) '.' it_spins-vfec_propuesta_sap+4(2) '.' it_spins-vfec_propuesta_sap+0(4)   into it_spins-vfec_propuesta_sap.
      it_spins-vid_propuesta_sap = wa_reguh-laufi.
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
  w_iter = 0.
  loop at it_spins.
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
      EXECUTE PROCEDURE csc_sap_auxiliares.sp_insert_pago(
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
*    status = 'X'.
  endloop.
catch cx_sy_native_sql_error.
  status = ' '.
*  message text-001 type 'I'.
*  message `Error in Native SQL.` type 'I'.
endtry.

exec sql.
  SET CONNECTION DEFAULT
endexec.
