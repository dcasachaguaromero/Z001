*&---------------------------------------------------------------------*
*& Report  ZFIPG003_REPARA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfipg003_repara.
TABLES: zfipg002_det.
PARAMETER : bukrs    LIKE bkpf-bukrs     VALUE CHECK  OBLIGATORY .

PARAMETER : laufd    LIKE zfipg002_det-laufd    VALUE CHECK  OBLIGATORY .




* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM zfipg002_det WHERE bukrs  = bukrs
*                           AND   laufd <= laufd.
*
* NEW CODE
SELECT *
 FROM zfipg002_det WHERE bukrs  = bukrs
                           AND   laufd <= laufd ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
   write: / zfipg002_det-LAUFI,zfipg002_det-laufd.
   zfipg002_det-ESTADO = 'P'.
  MODIFY zfipg002_det.
ENDSELECT.
