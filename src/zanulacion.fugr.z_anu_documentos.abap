FUNCTION Z_ANU_DOCUMENTOS.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(ZBUKRS) TYPE  BUKRS
*"     VALUE(ZBELNS) TYPE  BELNS
*"     VALUE(ZGJAHS) TYPE  GJAHR
*"     VALUE(ZSTGRD) TYPE  STGRD
*"     VALUE(ZBUDAT) TYPE  CACS_CTRTBDL_BDSC
*"     VALUE(ZMONAT) TYPE  C00101
*"     VALUE(ZUPDATE) TYPE  COND00004
*"  EXPORTING
*"     VALUE(ZNUM_DOC) TYPE  MSGV1
*"     VALUE(ZESTADO) TYPE  MSGTYP
*"----------------------------------------------------------------------


DATA: not TYPE CAUFV-AUFNR,
wa_trx TYPE bdcdata,
it_trx TYPE TABLE OF bdcdata.

DATA: BEGIN OF MESSTAB OCCURS 10.
       INCLUDE STRUCTURE BDCMSGCOLL.
DATA: END OF MESSTAB.

wa_trx-PROGRAM = 'SAPMF05A'.
wa_trx-DYNPRO = '0105'.
wa_trx-DYNBEGIN = 'X'.
APPEND wa_trx TO it_trx.
CLEAR wa_trx.


wa_trx-FNAM = 'BDC_CURSOR'.
wa_trx-DYNPRO = 'RF05A-BELNS'.

APPEND wa_trx TO it_trx.
CLEAR wa_trx.


wa_trx-FNAM = 'BDC_OKCODE'.
wa_trx-DYNPRO = '=BU'.
 APPEND wa_trx TO it_trx.
CLEAR wa_trx.


wa_trx-FNAM = 'RF05A-BELNS'.
wa_trx-FVAL = ZBELNS.
 APPEND wa_trx TO it_trx.
CLEAR wa_trx.

wa_trx-FNAM = 'BKPF-BUKRS'.
wa_trx-FVAL = ZBUKRS.
 APPEND wa_trx TO it_trx.
CLEAR wa_trx.
wa_trx-FNAM = 'RF05A-GJAHS'.
wa_trx-FVAL = ZGJAHS.
 APPEND wa_trx TO it_trx.
CLEAR wa_trx.
wa_trx-FNAM = 'UF05A-STGRD'.
wa_trx-FVAL = ZSTGRD.
 APPEND wa_trx TO it_trx.
CLEAR wa_trx.
wa_trx-FNAM = 'BSIS-BUDAT'.
wa_trx-FVAL = ZBUDAT.
 APPEND wa_trx TO it_trx.
CLEAR wa_trx.

"wa_trx-PROGRAM = 'BSIS-MONAT'.
"wa_trx-DYNPRO = ZMONAT.

wa_trx-FNAM = 'BSIS-MONAT'.
wa_trx-FVAL  = ZMONAT.


 APPEND wa_trx TO it_trx.
CLEAR wa_trx.

 wa_trx-fnam     = 'BDC_OKCODE'.
 wa_trx-fval     = '/11'.
 APPEND wa_trx TO it_trx.
 CLEAR wa_trx.
"PERFORM BDC_DYNPRO  using 'SAPMF05A' '0105'.
"PERFORM BDC_FIELD   using 'BDC_CURSOR' 'BSIS-MONAT'.
"PERFORM BDC_FIELD   using 'BDC_OKCODE' '=BU'.
"PERFORM BDC_FIELD   using 'RF05A-BELNS' '100000000'.

"PERFORM BDC_FIELD using 'BKPF-BUKRS' 'CL01'.
"PERFORM BDC_FIELD using 'RF05A-GJAHS' '2023'.
"PERFORM BDC_FIELD using 'RF05A-BELNS' '02'.
"PERFORM BDC_FIELD using 'BSIS-BUDAT' '29.05.2023'.

"PERFORM bdc_field using 'BSIS-MONAT' '5'.


CALL TRANSACTION 'FB08' USING it_trx
     MODE 'N'
    UPDATE 'S'
 MESSAGES INTO MESSTAB.

LOOP AT MESSTAB.
   ZESTADO  = MESSTAB-MSGTYP.
   ZNUM_DOC =  MESSTAB-MSGV1.
ENDLOOP.


ENDFUNCTION.
