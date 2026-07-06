*&---------------------------------------------------------------------*
*&  Include           ZFITR001_VAR
*&---------------------------------------------------------------------*
CONSTANTS :    W_BCI(4)    TYPE C VALUE   '016',
               W_STNDR(15) TYPE C  VALUE   '037',  "Banmedica Santander
               W_CHILE(4) TYPE C  VALUE  'BECH'.

TYPES:
*-- Single Value in Value Set
       BEGIN OF VRM_VALUE,
         KEY(40) TYPE C,
         TEXT(80) TYPE C,
       END OF VRM_VALUE.
TYPES:VRM_ID TYPE VRM_VALUE-TEXT,
      VRM_VALUES TYPE VRM_VALUE OCCURS 0,
      TY_BANCO(15) type c    .

DATA:   NAME TYPE VRM_ID,
        LIST TYPE VRM_VALUES,
        VALUE LIKE LINE OF LIST,
        W_BNCO  type TY_BANCO.
