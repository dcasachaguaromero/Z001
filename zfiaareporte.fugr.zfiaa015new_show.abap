FUNCTION ZFIAA015NEW_SHOW.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      ZDTAB STRUCTURE  ZZFIAAREPORTE
*"  CHANGING
*"     VALUE(ZRTMODE) TYPE  AQLIMODE
*"----------------------------------------------------------------------
 call function 'RSAQRT_SET_IDENTIFICATION'
       exporting iqid        = %iqid
                 sscr_report = sy-repid
*      changing  rtmode      = %rtmode.
       changing  rtmode      = zrtmode.

 call function 'RSAQRT_ALV_DISPLAY'
*      tables     dtab         = %dtab[]
*      changing   rtmode       = %rtmode.
       tables     dtab         = zdtab[]
       changing   rtmode       = zrtmode.

ENDFUNCTION.
