FUNCTION zfi_baja_tabla.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(P_ARCHIVO) TYPE  LOCALFILE
*"     VALUE(P_VISTA) OPTIONAL
*"     REFERENCE(P_TABLA_SAL) TYPE  LOCALFILE OPTIONAL
*"  EXPORTING
*"     VALUE(P_GRABA) TYPE  CHAR01
*"  TABLES
*"      TI_EXTRACT
*"----------------------------------------------------------------------
  DATA : generic_table TYPE REF TO data,
         l_direc       TYPE localfile.
  FIELD-SYMBOLS: <table> TYPE STANDARD TABLE,
                 <line>  TYPE any.
*
  MOVE p_archivo TO g_table.
  CLEAR g_graba.
*
  PERFORM directorio  CHANGING l_direc .
*
  IF l_direc IS NOT INITIAL.
    CONCATENATE l_direc '\' p_archivo '.CSV' INTO l_direc.
    PERFORM archivo_bajada TABLES ti_extract
                            USING p_vista
                                  p_tabla_sal.
    PERFORM download USING l_direc.
    p_graba = g_graba.
  ENDIF.

ENDFUNCTION.
