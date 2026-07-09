*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zinserta_transfer.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(BUKRS) TYPE  DZBUKR
*"     REFERENCE(V_FECHA) TYPE  LAUFD
*"     REFERENCE(V_NOMINA) TYPE  LAUFI
*"  EXPORTING
*"     REFERENCE(STATUS) TYPE  FLAG
*"----------------------------------------------------------------------
  TYPE-POOLS: slis.
*tables : reguh,   "  Datos de pago del programa de pagos              02
*         regup,
*         bseg,    "  Segmento de documento de Contabilidad            02
*         lfa1,    "  Maestro de proveedores (parte general)           02
*         lfb1,
*         t001,
*         bnka,    "  Maestro de banco                                 02
*         bsak,    "  índice secundario para acreedores (part.comp.)   02
*         bkpf.    "  Cabecera de documento para Contabilidad          02


  TYPES: BEGIN OF sp_insert,
            vempresa    TYPE  string  ,
            vnumero     TYPE  string ,
            vtipo               TYPE  string  ,
            vctacte_sap TYPE  string  ,
            vrol_beneficiario   TYPE  string  ,
            vbeneficiario   TYPE  string  ,
            vvalor  TYPE  string ,
            vfec_emision  TYPE  string  ,
            vfec_vencimiento    TYPE  string  ,
            vfec_retira   TYPE  string  ,
            vcheque_sus   TYPE  string  ,
            vnum_opago  TYPE  i ,
            vmotivo   TYPE  string  ,
            vlugar_pago         TYPE  string  ,
            vcheda_nproceso TYPE  i ,
            vcheda_narea  TYPE  string  ,
            vcheda_nmotivo    TYPE  string  ,
            vcheda_nctacbo    TYPE  i ,
            vcheda_cagencia TYPE  i ,
            vcheda_ntraspaso  TYPE  i ,
            vcheda_ftraspaso  TYPE  string  ,
            vcheda_cusuario TYPE  string  ,
            vfec_propuesta_sap TYPE string,
            vid_propuesta_sap TYPE  string,
            vfecha_contable TYPE string,
            vnumero_asignacion TYPE string,
            vreferencia_docto TYPE string,
            fm_status TYPE string,
            file_nbr TYPE string,
            identif_pago TYPE string,
            fecha_envio TYPE string,
            usuario_envio TYPE string,
            ind_pago TYPE string,
            fecha_pago LIKE sy-datum,
            ind_devuelto TYPE string,
            fecha_devuelto TYPE string,
            belnr_dev_ TYPE string,
            gjahr_dev_ TYPE string,
            codigo_banco_dep TYPE string,
            codigo_cta_dep TYPE string,
            xref2  TYPE string,
         END OF sp_insert.
  DATA: it_spins TYPE STANDARD TABLE OF sp_insert WITH HEADER LINE.
  DATA:
        it_payr TYPE payr,
        wa_reguh TYPE reguh,
        str TYPE string,
        w_budat LIKE bsak-budat,
        w_fecha TYPE string,
        w_venc LIKE bsak-zfbdt.
  DATA: it_reguh TYPE STANDARD TABLE OF reguh.
  DATA: w_bukrs LIKE  bseg-bukrs,
        w_belnr LIKE bseg-belnr,
        w_gjahr LIKE bseg-gjahr,
        w_buzei LIKE bseg-buzei,
        w_blart LIKE bsak-blart .

  DATA: oref   TYPE REF TO cx_root,
             text   TYPE string.

  w_fecha = v_fecha.
  CONCATENATE w_fecha+6(2) '.' w_fecha+4(2) '.' w_fecha+0(4) INTO w_fecha.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT
*          *
*    FROM reguh INTO CORRESPONDING FIELDS OF TABLE it_reguh
*    WHERE laufd = v_fecha
*      AND laufi = v_nomina
*      AND zbukr = bukrs
*      AND xvorl NE 'X'.
*
* NEW CODE
  SELECT *

    FROM reguh INTO CORRESPONDING FIELDS OF TABLE it_reguh
    WHERE laufd = v_fecha
      AND laufi = v_nomina
      AND zbukr = bukrs
      AND xvorl NE 'X' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*obtener numero de cheque
  LOOP AT it_reguh INTO wa_reguh.
    MOVE-CORRESPONDING wa_reguh TO it_spins.
    CLEAR it_spins.



    IF wa_reguh-rzawe EQ 'V' OR wa_reguh-rzawe EQ 'T'.
      CLEAR w_gjahr.
      CALL FUNCTION 'GET_CURRENT_YEAR'
       EXPORTING
         bukrs         = wa_reguh-zbukr
         date          = wa_reguh-zaldt
       IMPORTING
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
      CONCATENATE wa_reguh-name1 wa_reguh-name2 INTO it_spins-vbeneficiario.

      str = wa_reguh-rwbtr.
      REPLACE ALL OCCURRENCES OF '.' IN str WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN str WITH ''.
      it_spins-vvalor   = str.
      it_spins-vfec_emision   = wa_reguh-zaldt.
*        IT_SPINS-vFEC_RETIRA   = WA_REGUH-.
*        IT_SPINS-vNUM_OPAGO 	=	WA_REGUH-.
*        IT_SPINS-vMOTIVO   = WA_REGUH-.
      CLEAR w_venc.
      CLEAR:  w_bukrs	,
              w_belnr	,
              w_gjahr	,
              w_buzei	,
              w_blart.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE bukrs belnr gjahr buzei zz_agencia zfbdt zuonr xblnr xref1 zfbdt blart FROM bsak
*        INTO (w_bukrs, w_belnr, w_gjahr, w_buzei,it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, it_spins-vcheda_narea, w_venc, w_blart )
*        WHERE bukrs = wa_reguh-zbukr
*              AND lifnr = wa_reguh-lifnr
**                and augdt = wa_payr-zaldt
*              AND augbl = wa_reguh-vblnr
**               and gjahr = wa_payr-gjahr
*              AND belnr NE wa_reguh-vblnr
*              AND xzahl NE 'X'.
*
* NEW CODE
      SELECT bukrs belnr gjahr buzei zz_agencia zfbdt zuonr xblnr xref1 zfbdt blart
      UP TO 1 ROWS  FROM bsak
        INTO (w_bukrs, w_belnr, w_gjahr, w_buzei,it_spins-vlugar_pago, w_budat, it_spins-vnumero_asignacion, it_spins-vreferencia_docto, it_spins-vcheda_narea, w_venc, w_blart )
        WHERE bukrs = wa_reguh-zbukr
              AND lifnr = wa_reguh-lifnr
*                and augdt = wa_payr-zaldt
              AND augbl = wa_reguh-vblnr
*               and gjahr = wa_payr-gjahr
              AND belnr NE wa_reguh-vblnr
              AND xzahl NE 'X' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE zzdesc_est zzmot_emis xref1
*               INTO (it_spins-vmotivo, it_spins-vcheda_nmotivo, it_spins-file_nbr)
*          FROM bseg
*          WHERE bukrs = w_bukrs
*                AND belnr = w_belnr
*                AND gjahr = w_gjahr
*                AND buzei = w_buzei.
*
* NEW CODE
      SELECT zzdesc_est zzmot_emis xref1
      UP TO 1 ROWS 
               INTO (it_spins-vmotivo, it_spins-vcheda_nmotivo, it_spins-file_nbr)
          FROM bseg
          WHERE bukrs = w_bukrs
                AND belnr = w_belnr
                AND gjahr = w_gjahr
                AND buzei = w_buzei ORDER BY PRIMARY KEY.

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
      CONCATENATE it_spins-vfec_propuesta_sap+6(2) '.' it_spins-vfec_propuesta_sap+4(2) '.' it_spins-vfec_propuesta_sap+0(4)   INTO it_spins-vfec_propuesta_sap.
      it_spins-vid_propuesta_sap = wa_reguh-laufi.
*        IT_spins-FM_STATUS  = wa_reguh-FM_STATUS  . se cambia por la siguiente linea HCD 20130724
      it_spins-fm_status  = wa_reguh-rzawe .
*        IT_spins-FILE_NBR  = wa_reguh-FILE_NBR . se cambia por campo de BSEG linea HCD 20130724
      it_spins-identif_pago	=	wa_reguh-identif_pago	.
      it_spins-fecha_envio  = wa_reguh-fecha_envio  .
      it_spins-usuario_envio  = wa_reguh-usuario_envio  .
      it_spins-ind_pago	=	wa_reguh-ind_pago	.
      it_spins-fecha_pago	=	wa_reguh-fecha_pago	.
      it_spins-ind_devuelto	=	wa_reguh-ind_devuelto	.
      it_spins-fecha_devuelto	=	wa_reguh-fecha_devuelto	.
      it_spins-belnr_dev_ = wa_reguh-belnr_dev  .
      it_spins-gjahr_dev_ = wa_reguh-gjahr_dev  .
      it_spins-codigo_banco_dep = wa_reguh-zbnkl.
      it_spins-codigo_cta_dep = wa_reguh-zbnkn.
      it_spins-xref2 = ''.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE xref2 INTO it_spins-xref2 FROM  regup
*                    WHERE laufd = wa_reguh-laufd
*                    AND   laufi = wa_reguh-laufi
*                    AND   xvorl = wa_reguh-xvorl
*                    AND   zbukr = wa_reguh-zbukr
*                    AND   lifnr = wa_reguh-lifnr
*                    AND   kunnr = wa_reguh-kunnr
*                    AND   empfg = wa_reguh-empfg
*                    AND   vblnr = wa_reguh-vblnr.
*
* NEW CODE
      SELECT xref2
      UP TO 1 ROWS  INTO it_spins-xref2 FROM  regup
                    WHERE laufd = wa_reguh-laufd
                    AND   laufi = wa_reguh-laufi
                    AND   xvorl = wa_reguh-xvorl
                    AND   zbukr = wa_reguh-zbukr
                    AND   lifnr = wa_reguh-lifnr
                    AND   kunnr = wa_reguh-kunnr
                    AND   empfg = wa_reguh-empfg
                    AND   vblnr = wa_reguh-vblnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc <> 0.
        it_spins-xref2 = ''.
      ENDIF.

      APPEND it_spins.
    ENDIF.
  ENDLOOP.

  EXEC SQL.
    connect to 'SAPCSC' as 'con'
  ENDEXEC.

  EXEC SQL.
    set connection 'con'
  ENDEXEC.
*         execute procedure pkg_sap_cargas.sap_carga_detalle_gasto ( IN :hkont )
  TRY.
      EXEC SQL.
        EXECUTE PROCEDURE csc_sap_transfer.sptr_delete_tes_docpago_sap(
                                                                    IN :BUKRS  ,
                                                                    IN :w_fecha  ,
                                                                    IN :V_NOMINA,
                                                                    IN :SY-UNAME
                                                                    )
      ENDEXEC.
*       EXECUTE PROCEDURE csc_sap_transfer.SPTR_INSERT_TES_DOCPAGO_SAP
      LOOP AT it_spins.
        EXEC SQL.
          EXECUTE PROCEDURE csc_sap_transfer.sptr_insert_tes_docpago_sap_v2(
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
                                                               IN :IT_spins-GJAHR_DEV_,
                                                               IN :IT_spins-codigo_banco_dep,
                                                               IN :IT_spins-codigo_cta_dep,
                                                               IN :IT_spins-xref2
                                                               )

        ENDEXEC.
        status = 'X'.
      ENDLOOP.
    CATCH cx_sy_native_sql_error INTO oref.
      text = oref->get_text( ).

      status = ' '.
*  message text-001 type 'I'.
*  message `Error in Native SQL.` type 'I'.
  ENDTRY.

  EXEC SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.



ENDFUNCTION.
