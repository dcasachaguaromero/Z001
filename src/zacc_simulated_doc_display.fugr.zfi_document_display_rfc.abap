FUNCTION ZFI_DOCUMENT_DISPLAY_RFC.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_BELNR) TYPE  BELNR_D
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"--------------------------------------------------------------------
  SET PARAMETER ID 'BLN' FIELD i_belnr.
  SET PARAMETER ID 'BUK' FIELD i_bukrs.
  SET PARAMETER ID 'GJR' FIELD i_gjahr.
  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
ENDFUNCTION.
