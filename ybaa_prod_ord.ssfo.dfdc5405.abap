clear z_text_key.
CALL FUNCTION 'CO_ZK_TEXTKEY_CAUFV'
EXPORTING
AUFNR = it_caufvd-aufnr
IMPORTING
LTSCH = Z_text_key.





















