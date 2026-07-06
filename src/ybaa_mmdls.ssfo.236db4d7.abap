*****Get PO title ****************************************
DATA ls_t166u TYPE t166u.

SELECT SINGLE * INTO ls_t166u FROM t166u
WHERE spras = gv_language
AND druvo = iv_druvo
AND bstyp = is_ekko-bstyp
AND bsart = is_ekko-bsart.

gv_doc_type     = ls_t166u-drtyp.
gv_form_title   = ls_t166u-drart.
gv_form_heading = ls_t166u-drnum.

** Optional part: doc_type => form_title
** if only doc_type is specified, but form_total not.
** then print the doc_type in big font size.
IF gv_form_title IS INITIAL AND
NOT gv_doc_type IS INITIAL.
gv_form_title = gv_doc_type.
CLEAR gv_doc_type.
ENDIF.




















