REPORT zupdatefb02 NO STANDARD PAGE HEADING LINE-SIZE 255.
DATA ctumode TYPE c LENGTH 1.
DATA bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.

PARAMETERS p_zuonr LIKE bseg-zuonr.
PARAMETERS p_belnr LIKE rf05l-belnr.
PARAMETERS p_bukrs LIKE bkpf-bukrs.
PARAMETERS p_gjahr LIKE bkpf-gjahr.
PARAMETERS p_vertn LIKE bseg-vertn.
PARAMETERS p_vertt LIKE bseg-vertt.


START-OF-SELECTION.

  CHECK p_zuonr IS NOT INITIAL.
*
  PERFORM bdc_dynpro      USING 'SAPMF05L'    '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'  'RF05L-BELNR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '/00'.
  PERFORM bdc_field       USING 'RF05L-BELNR' p_belnr.
  PERFORM bdc_field       USING 'RF05L-BUKRS' p_bukrs.
  PERFORM bdc_field       USING 'RF05L-GJAHR' p_gjahr.

  PERFORM bdc_dynpro      USING 'SAPMF05L'    '0700'.
  PERFORM bdc_field       USING 'BDC_CURSOR'  'RF05L-ANZDT(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '=PK'.

  PERFORM bdc_dynpro      USING 'SAPMF05L'    '0301'.
  PERFORM bdc_field       USING 'BDC_CURSOR'  'BSEG-ZUONR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'  '=AE'.
  PERFORM bdc_field       USING 'BSEG-ZUONR'  p_zuonr.
  IF p_vertn IS NOT INITIAL.
    PERFORM bdc_field       USING 'BSEG-VERTN'  p_vertn.
  ENDIF.
  PERFORM bdc_field       USING 'BSEG-VERTT'  'A'.

  REFRESH messtab.
  ctumode = 'N'.
  CALL TRANSACTION 'FB02' USING bdcdata MODE ctumode UPDATE 'S'
  MESSAGES INTO messtab.

*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.

  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.

ENDFORM.                    " BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.

  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.

ENDFORM.                    "BDC_DYNPRO
