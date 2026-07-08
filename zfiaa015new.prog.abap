*&---------------------------------------------------------------------*
*& Report  ZFIAA015NEW
*&*&---------------------------------------------------------------------*
*& Autor: Ramón Vásquez
*& Empresa : Visionone
*& Fecha : 07.12.2013
*& Reporte de activos fijos que se toma del reporte ZFIAA015
*&---------------------------------------------------------------------*

REPORT ZFIAA015NEW.
*&
include ZFIAA015NEW_DAT.

data %dtab type standard table of ZZFIAAREPORTE with header line.

data %subrc type sy-subrc.

include ZFIAA015NEW_SSCR.

include ZFIAA015NEW_SSCRAT.


start-of-selection.
  if %runmode-extr_on <> space.
    call function 'ZFIAA015NEW_EXTR'
         tables     zselopt = %seloptions
                    zdtab   = %dtab
         changing   zrtmode = %runmode
         exceptions no_data = 1
                    others  = 2.
    %subrc = sy-subrc.
    call function 'RSAQRT_CHECK_EXTR'
         exporting extr_subrc = %subrc
         tables    dtab   = %dtab
         changing  rtmode = %runmode.
  endif.


end-of-selection.
  if %runmode-show_on <> space.
*    call function 'ZFIAA015NEW_SHOW'
*         tables   zdtab   = %dtab
*         changing zrtmode = %runmode.
    lv_repid                    = sy-repid.
    wa_layout-zebra             = c_x.
    wa_layout-colwidth_optimize = c_x.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
         i_program_name         = lv_repid
         i_structure_name       = 'ZZFIAAREPORTE'
       CHANGING
         ct_fieldcat            = ti_fieldcat
       EXCEPTIONS
         inconsistent_interface = 1
         program_error          = 2
       OTHERS                   = 3.


    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
         i_callback_program      = lv_repid
         i_callback_user_command = 'USER_COMMAND'
         is_layout               = wa_layout
         it_fieldcat             = ti_fieldcat
         i_default               = c_x
         i_save                  = 'A'
       TABLES
         t_outtab                = %DTAB
       EXCEPTIONS
         program_error           = 1
       OTHERS                  = 2.

  endif.

FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

* Check function code
  CASE r_ucomm.
    WHEN '&IC1'.
*       CLEAR wa_salida.
        READ TABLE %DTAB INDEX rs_selfield-tabindex..
        IF sy-subrc EQ 0.
           IF rs_selfield-fieldname = 'BELNR'.
              SET PARAMETER ID 'BUK' FIELD %DTAB-BUKRS.
              SET PARAMETER ID 'BLN' FIELD %DTAB-BELNR.
              SET PARAMETER ID 'GJR' FIELD %DTAB-GJAHR.
              CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
           Else.
              SET PARAMETER ID 'AN1' FIELD %DTAB-ANLN1.
              SET PARAMETER ID 'AN2' FIELD %DTAB-ANLN2.
              SET PARAMETER ID 'BUK' FIELD %DTAB-BUKRS.
              CALL TRANSACTION 'AS03' AND SKIP FIRST SCREEN.
           endif.
        ENDIF.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------
*    special code for old API and BW extractor calls
*----------------------------------------------------------------

form %set_data changing p_lines type i.

  import ldata to %dtab from memory id 'AQLISTDATA'.
  describe table %dtab lines p_lines.
  free memory id 'AQLISTDATA'.

endform.

form %get_data tables p_dtab  structure %dtab
               using  p_first type i
                      p_last  type i.

  append lines of %dtab from p_first to p_last to p_dtab.

endform.

form %get_ref_to_table using p_lid   type aql_lid
                             p_ref   type ref to data
                             p_subrc type i.

  if p_lid = %iqid-lid.
    create data p_ref like %dtab[].
    p_subrc = 0.
  else.
    p_subrc = 4.
  endif.

endform.
