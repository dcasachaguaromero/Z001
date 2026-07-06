*****Get PO title ****************************************
DATA: WA_T166U TYPE T166U.


SELECT SINGLE *
INTO WA_T166U
FROM T166U
WHERE SPRAS = GV_LANGUAGE
AND DRUVO = IV_DRUVO
AND BSTYP = IS_EKKO-BSTYP
AND BSART = IS_EKKO-BSART.


GV_DOC_TYPE = WA_T166U-DRTYP.
GV_FORM_TITLE = WA_T166U-DRART.
GV_FORM_HEADING = WA_T166U-DRNUM.

** Optional part: doc_type => form_title
** if only doc_type is specified, but form_total not.
** then print the doc_type in big font size.
IF GV_FORM_TITLE IS INITIAL AND
NOT GV_DOC_TYPE IS INITIAL.
GV_FORM_TITLE = GV_DOC_TYPE.
CLEAR GV_DOC_TYPE.
ENDIF.






















