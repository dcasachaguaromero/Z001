FUNCTION ZFI_CARGA_TABLA.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(P_ARCHIVO)
*"  EXPORTING
*"     REFERENCE(P_GRABA)
*"----------------------------------------------------------------------
  DATA : p_file      TYPE rlgrap-filename,
         gt_fieldcat TYPE slis_t_fieldcat_alv,
         it_fieldcat TYPE lvc_t_fcat,
         l_end       TYPE i.
*
  MOVE p_archivo TO g_table.
  CLEAR g_graba.
*
  PERFORM busqueda_archivo  CHANGING p_file.
*

  PERFORM prepara_archivo USING p_archivo
                          CHANGING gt_fieldcat
                                   it_fieldcat
                                   l_end.
  IF p_file IS NOT INITIAL.
    PERFORM carga_archivo   TABLES <ti_table>
                            USING p_file
                                  it_fieldcat
                                  l_end.
  ENDIF.
  PERFORM muestra_datos   TABLES <ti_table>
                          USING gt_fieldcat.

  p_graba = g_graba.

ENDFUNCTION.
