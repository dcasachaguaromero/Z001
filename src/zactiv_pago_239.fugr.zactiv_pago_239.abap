*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZACTIV_PAGO_239.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  EXPORTING
*"     VALUE(MENSAJE) TYPE  CHAR30
*"  TABLES
*"      TI_ENTRADA STRUCTURE  ZACTIVPAGO
*"----------------------------------------------------------------------
  DATA: wa_entrada  TYPE zactivpago,
        v_buzei     TYPE bsik-buzei,
        v_lineas    type i,
        v_cont      TYPE i value 1,
        v_fecha     type char10.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT MESSTAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES01 ECDK917080 *
SORT TI_ENTRADA .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES01 ECDK917080 *
  LOOP AT ti_entrada INTO wa_entrada.

CONCATENATE wa_entrada-fch_pago+6(2) '.' wa_entrada-fch_pago+4(2) '.' wa_entrada-fch_pago(4) into v_fecha.

*    SELECT SINGLE buzei                              "comentado 15.12.2014
*      INTO v_buzei
*      FROM bsik
*      WHERE bukrs EQ wa_entrada-bukrs
*        AND lifnr EQ wa_entrada-lifnr
*        AND belnr EQ wa_entrada-belnr
*        AND budat EQ wa_entrada-budat
*        AND shkzg EQ 'H'.                            "//

    w_mode = 'N'.
    tcode = 'FB09'.

    REFRESH bdcdata.
    CLEAR bdcdata.

    PERFORM bdc USING:
*          '' 'FB09' 'BS AA X   F'
         'X' 'SAPMF05L' '0102'            "ingresa al programa
*         ,'' 'BDC_CURSOR' 'RF05L-BUZEI'
*         ,'' 'BDC_OKCODE' '/00'            "ejecutar
          ,'' 'BDC_CURSOR' 'RF05L-BELNR'        "se posiciona en el centro
          ,'' 'RF05L-BELNR' wa_entrada-belnr     "asigna el valor al centro
          ,'' 'BDC_CURSOR' 'RF05L-BUKRS'
          ,'' 'RF05L-BUKRS' wa_entrada-bukrs
          ,'' 'BDC_CURSOR' 'RF05L-GJAHR'
          ,'' 'RF05L-GJAHR' wa_entrada-budat(4)
          ,'' 'BDC_CURSOR' 'RF05L-BUZEI'
          ,'' 'RF05L-BUZEI' wa_entrada-buzei "v_buzei                    "agregado 15.12.2014
          ,'' 'BDC_OKCODE' '/00'
          ,'X' 'SAPMF05L' '0302'
          ,'' 'BDC_CURSOR' 'BSEG-ZFBDT'
          ,'' 'BSEG-ZFBDT' v_fecha  "wa_entrada-fch_pago
          ,'' 'BDC_CURSOR' 'BSEG-ZLSCH'
          ,'' 'BSEG-ZLSCH' wa_entrada-via_pago
           ,'' 'BDC_CURSOR' 'BSEG-ZLSPR'
          ,'' 'BSEG-ZLSPR' ''
          ,'' 'BDC_OKCODE' '=ZK'
          ,'X' 'SAPMF05L' '1302'
          ,'' 'BDC_CURSOR' 'BSEG-HBKID'
          ,'' 'BSEG-HBKID' wa_entrada-banco_pago
          ,'' 'BDC_CURSOR' 'BSEG-HKTID'
          ,'' 'BSEG-HKTID' wa_entrada-id_banco
          ,'' 'BDC_CURSOR' 'BSEG-BVTYP'
          ,'' 'BSEG-BVTYP' wa_entrada-BVTYP
          ,'' 'BDC_CURSOR' 'BSEG-ZZMOT_EMIS' "MOTIVO DE EMISION
          ,'' 'BSEG-ZZMOT_EMIS' 'EXCESO_239'
          ,'X' 'SAPMF05L' '0302'
          ,'' 'BDC_OKCODE' '/11'


          .

    CALL TRANSACTION tcode USING bdcdata MODE w_mode UPDATE 'S' MESSAGES INTO messtab.

describe TABLE messtab lines v_lineas.
READ TABLE messtab INDEX v_lineas.

if messtab-MSGNR eq '300' or messtab-MSGNR eq '303' .
wa_entrada-modif_pago = 'OK. PARA PAGO'.
MODIFY  ti_entrada from wa_entrada index v_cont.
else.
wa_entrada-modif_pago = 'NO DIPONIBLE PARA PAGO'.
*ReSQ: No Need Of Change Internal Table TI_ENTRADA Already Sorted
MODIFY  ti_entrada from wa_entrada index v_cont.
endif.


v_cont = v_cont + 1.
  ENDLOOP.




ENDFUNCTION.
