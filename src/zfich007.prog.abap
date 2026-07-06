*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFICH007
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfich007.

TABLES: zfich001,
        zfich002,
        bseg.


SELECT * FROM  zfich001 WHERE hkont = ''.
 select SINGLE * FROM   zfich002 WHERE estado = zfich001-estado.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
 select SINGLE  * FROM bseg WHERE bukrs = zfich001-bukrs
                            AND   belnr =  zfich001-belnr
                            AND   gjahr =  zfich001-gjahr
                            AND   shkzg =  zfich002-shkzg.
  IF sy-subrc = 0.
    zfich001-agencia = bseg-zz_agencia.
    zfich001-hkont   = bseg-hkont.
    MODIFY zfich001.
  ELSE.
    zfich001-gjahr = zfich001-gjahr - 1.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
    SELECT SINGLE  * FROM bseg WHERE bukrs = zfich001-bukrs
                            AND   belnr =  zfich001-belnr
                            AND   gjahr =  zfich001-gjahr
                            AND   shkzg =  zfich002-shkzg.

    IF sy-subrc = 0.
      zfich001-agencia = bseg-zz_agencia.
      zfich001-hkont   = bseg-hkont.
      MODIFY zfich001.
    ENDIF.

  ENDIF.

ENDSELECT.
