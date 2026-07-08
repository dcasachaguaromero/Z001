FUNCTION ZSCR_POPUP_FIELD_INPUT01.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  CHANGING
*"     VALUE(E_BLART) TYPE  BLART
*"     VALUE(E_BUDAT) TYPE  BUDAT
*"     VALUE(E_UCOMM) TYPE  SY-UCOMM
*"     VALUE(E_CTU_MODE) TYPE  CTU_MODE OPTIONAL
*"----------------------------------------------------------------------
  CTU_PARAMS-DISMODE = 'E'.
  BKPF-BLART = 'DA'.
  BKPF-BUDAT = SY-DATUM.
  CALL SCREEN 100 STARTING AT 10 5.
  E_BLART = BKPF-BLART.
  E_BUDAT = BKPF-BUDAT.
  E_UCOMM = OK_CODE.
  E_CTU_MODE = CTU_PARAMS-DISMODE.

ENDFUNCTION.
