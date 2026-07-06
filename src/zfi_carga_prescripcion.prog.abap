*&---------------------------------------------------------------------*
*& Report  ZFI_CARGA_PRESCRIPCION
*&
*&---------------------------------------------------------------------*
*& Permitir la carga de la tabla ZPRESCRIBE_FECHA para modificar las fechas
*& de emisión de los cheques a Prescribir.
*&---------------------------------------------------------------------*
REPORT  zfi_carga_prescripcion.

TABLES: zprescribe_fecha.

TYPES: BEGIN OF t_data,
            bukrs LIKE zprescribe_fecha-bukrs,
            hbkid LIKE zprescribe_fecha-hbkid,
            hktid LIKE zprescribe_fecha-hktid,
            chect LIKE zprescribe_fecha-chect,
            fecemi LIKE zprescribe_fecha-fecemi,
  END OF t_data.

DATA: t_registros LIKE alsmex_tabline OCCURS 6000 WITH HEADER LINE,
      wa_data TYPE t_data,
      it_data TYPE STANDARD TABLE OF t_data INITIAL SIZE 0,
      tot_reg_leidos TYPE i,
      cta_reg TYPE i,
      wa_presc LIKE zprescribe_fecha.

DATA:  fila TYPE i.

* Selección masiva
SELECTION-SCREEN: BEGIN OF BLOCK uno WITH FRAME TITLE text-001.
PARAMETERS: p_file(128) TYPE c DEFAULT 'D:\' LOWER CASE.
SELECTION-SCREEN: END OF BLOCK uno.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_file
      def_path         = '\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Selección de Archivo'
    IMPORTING
      filename         = p_file
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

START-OF-SELECTION.
  PERFORM carga_archivo.
  PERFORM procesa.

*&---------------------------------------------------------------------*
*&      Form  carga_archivo
*&---------------------------------------------------------------------*
FORM carga_archivo.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = p_file
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '5'
      i_end_row               = '10000'
    TABLES
      intern                  = t_registros
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

* Ordena la tabla por filas y columnas
  SORT t_registros BY row col.
  READ TABLE t_registros INDEX 1.
  fila = t_registros-row.

  LOOP AT t_registros.
    IF t_registros-row NE fila.
      APPEND wa_data TO it_data.
      CLEAR  wa_data.
      fila = t_registros-row.
    ENDIF.

    CASE t_registros-col.
      WHEN '001'.
        wa_data-bukrs = t_registros-value.
      WHEN '002'.
        wa_data-hbkid = t_registros-value.
      WHEN '003'.
        wa_data-hktid = t_registros-value.
      WHEN '004'.
        wa_data-chect = t_registros-value.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = wa_data-chect
          IMPORTING
            output = wa_data-chect.

      WHEN '005'.
* La fecha se ingresa como DDMMYYYY y el programa la ordena como YYYYMMDD
        wa_data-fecemi = t_registros-value.
        CONCATENATE wa_data-fecemi+4(4) wa_data-fecemi+2(2) wa_data-fecemi+0(2) INTO wa_data-fecemi.
    ENDCASE.
  ENDLOOP.
  APPEND wa_data TO it_data.

* Obtiene el total de registros leídos.
  DESCRIBE TABLE it_data LINES tot_reg_leidos.
ENDFORM.                    "carga_archivo

*&---------------------------------------------------------------------*
*&      Form  procesa
*&---------------------------------------------------------------------*
FORM procesa.
  CLEAR cta_reg.
  LOOP AT it_data INTO wa_data.
    cta_reg = cta_reg + 1.
    MOVE-CORRESPONDING wa_data TO wa_presc.
    INSERT zprescribe_fecha FROM wa_presc.
    IF cta_reg = 100.
* Se hace commit cada 100 registros
      COMMIT WORK AND WAIT.
      cta_reg = 0.
      tot_reg_leidos = tot_reg_leidos + 1.
    ENDIF.
  ENDLOOP.
  COMMIT WORK AND WAIT.
  WRITE:/1 'Se insertaron:', tot_reg_leidos, 'registros.'.
ENDFORM.                    "procesa
