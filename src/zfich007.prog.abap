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


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM  zfich001 WHERE hkont = ''.
*
* NEW CODE
SELECT *
 FROM  zfich001 WHERE hkont = '' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* select SINGLE * FROM   zfich002 WHERE estado = zfich001-estado.
*
* NEW CODE
 SELECT *
 UP TO 1 ROWS  FROM   zfich002 WHERE estado = zfich001-estado ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* select SINGLE  * FROM bseg WHERE bukrs = zfich001-bukrs
*                            AND   belnr =  zfich001-belnr
*                            AND   gjahr =  zfich001-gjahr
*                            AND   shkzg =  zfich002-shkzg.
*
* NEW CODE
 SELECT *
 UP TO 1 ROWS  FROM bseg WHERE bukrs = zfich001-bukrs
                            AND   belnr =  zfich001-belnr
                            AND   gjahr =  zfich001-gjahr
                            AND   shkzg =  zfich002-shkzg ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.
    zfich001-agencia = bseg-zz_agencia.
    zfich001-hkont   = bseg-hkont.
    MODIFY zfich001.
  ELSE.
    zfich001-gjahr = zfich001-gjahr - 1.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE  * FROM bseg WHERE bukrs = zfich001-bukrs
*                            AND   belnr =  zfich001-belnr
*                            AND   gjahr =  zfich001-gjahr
*                            AND   shkzg =  zfich002-shkzg.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM bseg WHERE bukrs = zfich001-bukrs
                            AND   belnr =  zfich001-belnr
                            AND   gjahr =  zfich001-gjahr
                            AND   shkzg =  zfich002-shkzg ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0.
      zfich001-agencia = bseg-zz_agencia.
      zfich001-hkont   = bseg-hkont.
      MODIFY zfich001.
    ENDIF.

  ENDIF.

ENDSELECT.
