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




SELECT * FROM zfipg002_det WHERE bukrs  = bukrs
                           AND   laufd <= laufd.
   write: / zfipg002_det-LAUFI,zfipg002_det-laufd.
   zfipg002_det-ESTADO = 'P'.
  MODIFY zfipg002_det.
ENDSELECT.
