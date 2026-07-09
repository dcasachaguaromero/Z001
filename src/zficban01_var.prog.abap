*&---------------------------------------------------------------------*
*&  Include           ZFITR001_VAR
*&---------------------------------------------------------------------*
CONSTANTS :    W_BCI(4)    TYPE C VALUE '016',
               W_STNDR(15) TYPE C VALUE '037',  "Banmedica Santander
               W_CHILE(4)  TYPE C VALUE '001',
               W_BBVA(4)   TYPE C VALUE '504',
               W_CORP(4)   type c value '027',
               W_SECU(4)   TYPE C VALUE '049',
               W_SCTIA(4)  TYPE C VALUE '014',
               W_ESTADO(4) TYPE C VALUE '012',
               W_BICE(4)   TYPE c VALUE '028',
** V1 RVY 20-04-2021
               W_ITAU(4)   TYPE c Value '039'.
** V1 RVY 20-04-2021
*               W_CHILE(4) TYPE C  VALUE  'BECH'.

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
