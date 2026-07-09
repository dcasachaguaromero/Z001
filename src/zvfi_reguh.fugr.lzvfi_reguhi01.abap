*----------------------------------------------------------------------*
***INCLUDE LZVFI_REGUHI01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  DATA : p_graba   TYPE c,
         p_archivo TYPE localfile VALUE 'ZVFI_REGUH',
         lv_ucomm  TYPE sy-ucomm.
*
  lv_ucomm = sy-ucomm.
  CLEAR sy-ucomm.
  CASE lv_ucomm.
    WHEN 'EXCEL'.
      CALL FUNCTION 'ZFI_BAJA_TABLA'
        EXPORTING
          p_archivo   = p_archivo
          p_vista     = <vim_total_struc>
          p_tabla_sal = 'ZEFI_REGUH'
        IMPORTING
          p_graba     = p_graba
        TABLES
          ti_extract  = extract.
    WHEN 'CLIP'.
      PERFORM upload_clipboard.
  ENDCASE.
ENDMODULE.
