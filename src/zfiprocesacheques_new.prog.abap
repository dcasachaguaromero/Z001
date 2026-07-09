*&---------------------------------------------------------------------*
*& Report  ZFIPROCESACHEQUES_NEW
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFIPROCESACHEQUES_NEW.

tables : reguh,   "  Datos de pago del programa de pagos              02
         regup,
         bseg,    "  Segmento de documento de Contabilidad            02
         lfa1,    "  Maestro de proveedores (parte general)           02
         lfb1,
         t001,
         bnka,    "  Maestro de banco                                 02
         bsak,    "  índice secundario para acreedores (part.comp.)   02
         bkpf.    "  Cabecera de documento para Contabilidad          02

parameter :  bukrs    like t001-bukrs obligatory.

parameter :  v_fecha  like reguh-laufd obligatory,
             v_nomina like f110v-laufi obligatory.

data lt_dynpfields like dynpread occurs 1 with header line.
data lv_dynpro_prog like d020s-prog.
data: it_reguh TYPE STANDARD TABLE OF reguh.

data:    begin of tlaufk occurs 1.
            include structure ilaufk.
data:    end of tlaufk.

TYPES: BEGIN OF sp_insert,
          vEMPRESA    TYPE  string  ,
          vNUMERO     TYPE  i ,
          vTipo               TYPE  string  ,
          vCTACTE_SAP TYPE  string  ,
          vROL_BENEFICIARIO   TYPE  string  ,
          vBENEFICIARIO   TYPE  string  ,
          vVALOR  TYPE  P ,
          vFEC_EMISION  TYPE  string  ,
          vFEC_VENCIMIENTO    TYPE  string  ,
          vFEC_RETIRA   TYPE  string  ,
          vNOM_RETIRA   TYPE  string  ,
          vNUM_OPAGO  TYPE  i ,
          vMOTIVO   TYPE  string  ,
          vLUGAR_PAGO         TYPE  string  ,
          vCHEDA_NPROCESO TYPE  i ,
          vCHEDA_NAREA  TYPE  string  ,
          vCHEDA_NMOTIVO    TYPE  string  ,
          vCHEDA_NCTACBO    TYPE  i ,
          vCHEDA_CAGENCIA TYPE  i ,
          vCHEDA_NTRASPASO  TYPE  i ,
          vCHEDA_FTRASPASO  TYPE  string  ,
          vCHEDA_CUSUARIO TYPE  string  ,
          vFEC_PROPUESTA_SAP TYPE string,
          vID_PROPUESTA_SAP TYPE  string,
       END OF sp_insert.

data: IT_spins type STANDARD TABLE OF sp_insert WITH HEADER LINE.
DATA: WA_PAYR TYPE PAYR,
      IT_PAYR TYPE PAYR,
      WA_REGUH TYPE REGUH,
      str type string.

at selection-screen on bukrs.

  authority-check object 'F_BKPF_BUK'
     id 'BUKRS' field bukrs.

  if sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    message e526(icc_tr) with bukrs.
  endif.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single * from t001 where bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  from t001 where bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

START-OF-SELECTION.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT
*        LAUFD
*        LAUFI
*        XVORL
*        ZBUKR
*        LIFNR
*        KUNNR
*        EMPFG
*        VBLNR
*        AVISG
*        WAERS
*        SRTGB
*        ANRED
*        NAME1
*        NAME4
*        ORT01
*        STRAS
*        STCD1
*        ZSPRA
*        ZALDT
*        RZAWE
*        HKTID
*        HBKID
*        UBKNT
*        UBNKS
*        UBNKL
*        UBHKT
*        VALUT
*        RBETR
*        ABWAE
*        PAYGR
*        ZBNKY
*        UBNKY
*  FROM REGUH INTO CORRESPONDING FIELDS OF TABLE it_reguh
*  where laufd = v_fecha
*    and laufi = v_nomina
*    and zbukr = bukrs.
*
* NEW CODE
SELECT LAUFD
        LAUFI
        XVORL
        ZBUKR
        LIFNR
        KUNNR
        EMPFG
        VBLNR
        AVISG
        WAERS
        SRTGB
        ANRED
        NAME1
        NAME4
        ORT01
        STRAS
        STCD1
        ZSPRA
        ZALDT
        RZAWE
        HKTID
        HBKID
        UBKNT
        UBNKS
        UBNKL
        UBHKT
        VALUT
        RBETR
        ABWAE
        PAYGR
        ZBNKY
        UBNKY

  FROM REGUH INTO CORRESPONDING FIELDS OF TABLE it_reguh
  where laufd = v_fecha
    and laufi = v_nomina
    and zbukr = bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*obtener numero de cheque
LOOP AT it_reguh INTO WA_REGUH.
  IF WA_REGUH-RZAWE EQ 'C'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *
*      FROM PAYR INTO WA_PAYR
*      WHERE ZBUKR = WA_REGUH-ZBUKR
*        AND HBKID = WA_REGUH-HBKID
*        AND HKTID = WA_REGUH-HKTID
*        AND LAUFD = WA_REGUH-LAUFD
*        AND LAUFI = WA_REGUH-LAUFI
*        AND VBLNR = WA_REGUH-VBLNR.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS 
      FROM PAYR INTO WA_PAYR
      WHERE ZBUKR = WA_REGUH-ZBUKR
        AND HBKID = WA_REGUH-HBKID
        AND HKTID = WA_REGUH-HKTID
        AND LAUFD = WA_REGUH-LAUFD
        AND LAUFI = WA_REGUH-LAUFI
        AND VBLNR = WA_REGUH-VBLNR ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC EQ 0.
      IT_SPINS-vEMPRESA  	=	WA_REGUH-ZBUKR.
      IT_SPINS-vNUMERO   	=	WA_PAYR-CHECT.
      IT_SPINS-vTipo             	=	WA_REGUH-RZAWE.
*      IT_SPINS-vCTACTE_SAP  = WA_REGUH-UBKNT.
*      IT_SPINS-vCTACTE_SAP  = WA_REGUH-HKONT.
      IT_SPINS-vCTACTE_SAP  = WA_REGUH-UBHKT.
      IT_SPINS-vROL_BENEFICIARIO 	=	WA_REGUH-STCD1.
      IT_SPINS-vBENEFICIARIO 	=	WA_REGUH-NAME1.

      str = WA_REGUH-RBETR.
      REPLACE all OCCURRENCES OF '.' in str with ''.
      IT_SPINS-vVALOR   = str.
      IT_SPINS-vFEC_EMISION   = WA_PAYR-ZALDT.
*      IT_SPINS-vFEC_VENCIMIENTO   	=	WA_REGUH-.
*      IT_SPINS-vFEC_RETIRA   = WA_REGUH-.
      IT_SPINS-vNOM_RETIRA 	=	WA_REGUH-ZNME1.
*      IT_SPINS-vNUM_OPAGO 	=	WA_REGUH-.
*      IT_SPINS-vMOTIVO   = WA_REGUH-.
      IT_SPINS-vLUGAR_PAGO       	=	WA_REGUH-NAME4.
*      IT_SPINS-vCHEDA_NPROCESO	=	WA_REGUH-.
      IT_SPINS-vCHEDA_NAREA   = WA_REGUH-DORIGIN.
*      IT_SPINS-vCHEDA_NMOTIVO    = WA_REGUH-.
      IT_SPINS-vCHEDA_NCTACBO  	=	WA_REGUH-UBNKL.
*      IT_SPINS-vCHEDA_CAGENCIA	=	WA_REGUH-.
      IT_SPINS-vCHEDA_NTRASPASO   = WA_REGUH-VBLNR.
      IT_SPINS-vCHEDA_FTRASPASO	=	WA_REGUH-LAUFD.
      IT_SPINS-vCHEDA_CUSUARIO  = WA_PAYR-PRIUS.
      IT_SPINS-vFEC_PROPUESTA_SAP = WA_REGUH-LAUFD.
      CONCATENATE IT_SPINS-vFEC_PROPUESTA_SAP+6(2) '.' IT_SPINS-vFEC_PROPUESTA_SAP+4(2) '.' IT_SPINS-vFEC_PROPUESTA_SAP+0(4)   INTO IT_SPINS-vFEC_PROPUESTA_SAP.
      IT_SPINS-vID_PROPUESTA_SAP = WA_REGUH-LAUFI.
      APPEND IT_SPINS.
    ENDIF.
  ENDIF.
ENDLOOP.

exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.
*         execute procedure pkg_sap_cargas.sap_carga_detalle_gasto ( IN :hkont )
try.
  LOOP AT IT_SPINS.
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
                                                                    IN :IT_spins-vID_PROPUESTA_SAP)

    ENDEXEC.
  ENDLOOP.
message `Datos ingresados correctamente` type 'I'.
catch cx_sy_native_sql_error.
*  message text-001 type 'I'.
  message `Error in Native SQL.` type 'I'.
endtry.

exec sql.
  SET CONNECTION DEFAULT
endexec.
