*&---------------------------------------------------------------------*
*& Report  ZTRAS_NOMINA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZTRAS_NOMINA  no standard page heading.
type-pools: slis.

constants: top_of_page type slis_formname value 'TOP_OF_PAGE',
top_of_list type slis_formname value 'TOP_OF_LIST'.
constants: end_of_list type slis_formname value 'END_OF_LIST',
user_command type slis_formname value 'ALV_USER_COMMAND' .

TABLES: BKPF.

DATA: k_status TYPE slis_formname VALUE 'STANDARD_KR01',
k_user_command TYPE slis_formname VALUE 'USER_COMMAND'.
*----------------------------------------------------------------------*
INCLUDE ole2incl.
*----------------------------------------------------------------------*
DATA: con TYPE ole2_object,
      rec TYPE ole2_object,
      SQL(1023),
      CONTADOR   TYPE I.

******************************************************************'
* Data declarations for the ALV grid
******************************************************************'
DATA:       r_grid      TYPE REF TO cl_gui_alv_grid.

DATA:      alv_fieldcat    TYPE slis_t_fieldcat_alv,
           wa_alv_fieldcat TYPE slis_fieldcat_alv,
           alv_layout      TYPE slis_layout_alv,
           gd_repid        LIKE sy-repid.
******************************************************************'
DATA: s_empresa_medisyn(5),
      s_titulo(100),
      s_ejercicio(10).

DATA: BEGIN OF I1 OCCURS 0,
    CUENTA(20),
    CODIGO(100),
    DESCRIPCION(100),
    NSAP(20),
    FECHA(20),
    EJERCICIO(10),
END OF I1.


DATA: BEGIN OF wa_acree OCCURS 0,
    CUENTA(20),
    CODIGO(100),
    DESCRIPCION(100),
    NSAP(20),
    FECHA(20),
    EJERCICIO(10),
END OF wa_acree.

DATA: BEGIN OF wa_consulta OCCURS 0,
    EMPRESA(20),
    NOMINA(20),
END OF wa_consulta.

DATA: BEGIN OF SPL OCCURS 0,
        VAL(1023),
END OF SPL,

sindx TYPE I.

* parameters: pemcode(5).
SELECTION-SCREEN BEGIN OF BLOCK DATA WITH FRAME TITLE TEXT-T01.
SELECT-OPTIONS:
      S_BUKRS FOR BKPF-BUKRS  NO-EXTENSION
                              NO INTERVALS
                              OBLIGATORY.  .
"Podemos elegir solamente un valor
"OBLIGATORY indica que es obligatorio para ejecutar el programa
PARAMETERS:
      NOMINA(10) OBLIGATORY.
SELECTION-SCREEN END OF BLOCK DATA.



tables: sscrfields.
*----------------------------------------------------------------------*
initialization.
    perform openconnection.
*----------------------------------------------------------------------*
at selection-screen.
*----------------------------------------------------------------------*
start-of-selection.
*    write: / 'Querry'.

    PERFORM alv_setup.
*PERFORM standard_kr01.
    perform Get_Rec.
*----------------------------------------------------------------------*
end-of-selection.
PERFORM display_alv.


*----------------------------------------------------------------------*
form openconnection.
       exec sql.
          connect to 'SAPCSC' as 'CON'
       endexec.
      exec sql.
          set connection 'CON'
      endexec.
endform.
*----------------------------------------------------------------------*

form closeconnection.
    exec sql.
      SET CONNECTION DEFAULT
    endexec.

*    free REC.
*    free CON.
endform.
*----------------------------------------------------------------------*

form Get_Rec.

    perform openconnection.

    IF S_BUKRS = 'IEQCL17' or S_BUKRS = 'IEQCL13'  or S_BUKRS = 'IEQCL15'.
          wa_consulta-empresa = '1'.
    ENDIF.

    IF S_BUKRS = 'IEQCL35' or S_BUKRS = 'IEQCL36'.
          wa_consulta-empresa = '2'.
    ENDIF.

    IF S_BUKRS = 'IEQCL27' or S_BUKRS = 'IEQCL28'.
         wa_consulta-empresa = '4'.
    ENDIF.

    IF S_BUKRS = 'IEQCL29' or S_BUKRS = 'IEQCL30'.
          wa_consulta-empresa = '5'.
    ENDIF.

    IF S_BUKRS = 'IEQCL39' or S_BUKRS = 'IEQCL40'.
          wa_consulta-empresa = '6'.
    ENDIF.
    wa_consulta-nomina  = NOMINA.


*  write: / wa_consulta-empresa.
*  write: / wa_consulta-nomina.
*  write: / S_BUKRS.

try.
EXEC SQL.
    EXECUTE PROCEDURE csc_iface_abastecimiento_pkg.PROC_NOMINA_ABASTECIMIENTO(
                                                                    IN :wa_consulta-empresa  ,
                                                                    IN :wa_consulta-nomina   )
 ENDEXEC.


        EXEC SQL.
          OPEN c1 FOR
            select rut_proveedor , desc_proveedor , numero_documento ,nvl(n_sap,'0') , to_char(FECHA_EMISION_DOCUMENTO,'dd-mm-yyyy'),
                   to_char(fecha_contabilizacion,'yyyy')
            from TES_ENCIMPDOC
            where cod_empresa = :wa_consulta-empresa
            and   num_nomina  = :wa_consulta-nomina
         ENDEXEC.
    DO.
      EXEC SQL.
        FETCH NEXT c1 INTO  :wa_acree-cuenta , :wa_acree-codigo , :wa_acree-descripcion , :wa_acree-nsap ,:wa_acree-fecha ,:wa_acree-ejercicio

      ENDEXEC.
      IF sy-subrc <> 0.
*         message `NO EXISTEN DATOS.` type 'I'.
        EXIT.
      ELSE.
        APPEND WA_ACREE TO I1.
        s_ejercicio = wa_acree-ejercicio.
      ENDIF.
    ENDDO.
    EXEC SQL.
      CLOSE c1
    ENDEXEC.

 catch cx_sy_native_sql_error.
   message `Error in Native SQL.` type 'I'.
  endtry.


endform.
*&---------------------------------------------------------------------*
*&      Form  alv_setup
*&---------------------------------------------------------------------*
*
*  Setup of the columns in the ALV grid
*
*----------------------------------------------------------------------*
FORM alv_setup.

  CLEAR wa_alv_fieldcat.
  REFRESH alv_fieldcat.
  wa_alv_fieldcat-key = 'X'.                     "This is a key column
  wa_alv_fieldcat-fieldname = 'NSAP'.           "Name of the table field
  wa_alv_fieldcat-seltext_s = 'NUM_SAP'.           "Short column heading
  wa_alv_fieldcat-seltext_m = 'NUM_SAP'.    "Medium column heading
  wa_alv_fieldcat-seltext_l = 'NUM_SAP'. "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  wa_alv_fieldcat-key = 'X'.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'DESCRIPCION'.
  wa_alv_fieldcat-seltext_s = 'NUMERO DOCUMENTO'.
  wa_alv_fieldcat-seltext_m = 'NUMERO DOCUMENTO'.
  wa_alv_fieldcat-seltext_l = 'NUMERO DOCUMENTO'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.

* Mat text field
  wa_alv_fieldcat-key = 'X'.                      "This is not a key column
  wa_alv_fieldcat-fieldname = 'FECHA'.
  wa_alv_fieldcat-seltext_s = 'FECHA DOCUMENTO'.
  wa_alv_fieldcat-seltext_m = 'FECHA DOCUMENTO'.
  wa_alv_fieldcat-seltext_l = 'FECHA DOCUMENTO'.
  APPEND wa_alv_fieldcat TO alv_fieldcat.


  wa_alv_fieldcat-key = 'X'.                     "This is a key column
  wa_alv_fieldcat-fieldname = 'CUENTA'.           "Name of the table field
  wa_alv_fieldcat-seltext_s = 'RUT PROVEEDOR'.           "Short column heading
  wa_alv_fieldcat-seltext_m = 'RUT PROVEEDOR'.    "Medium column heading
  wa_alv_fieldcat-seltext_l = 'RUT PROVEEDOR'. "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.
* Matnr field
  wa_alv_fieldcat-key = ''.                     "This is a key column
  wa_alv_fieldcat-fieldname = 'CODIGO'.           "Name of the table field
  wa_alv_fieldcat-seltext_s = 'NOMBRE'.           "Short column heading
  wa_alv_fieldcat-seltext_m = 'NOMBRE'.    "Medium column heading
  wa_alv_fieldcat-seltext_l = 'NOMBRE'. "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.

  wa_alv_fieldcat-key = ''.                     "This is a key column
  wa_alv_fieldcat-fieldname = 'EJERCICIO'.           "Name of the table field
  wa_alv_fieldcat-seltext_s = 'EJERCICIO'.           "Short column heading
  wa_alv_fieldcat-seltext_m = 'EJERCICIO'.    "Medium column heading
  wa_alv_fieldcat-seltext_l = 'EJERCICIO'. "Long column heading
  APPEND wa_alv_fieldcat TO alv_fieldcat.


ENDFORM.                    " alv_setup

*FORM standard_kr01 USING extab TYPE slis_t_extab.
*
*DATA: extab1 LIKE extab WITH HEADER LINE.
*extab1-fcode = 'AEND'.
*APPEND extab1 TO extab.
*SET PF-STATUS 'ZSDSGUIDES' EXCLUDING extab.
*
*ENDFORM. "standard_kr01


*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
*  Display data in the ALV grid
*
*----------------------------------------------------------------------*
FORM display_alv.

  gd_repid = sy-repid.

* Configure layout of screen
  alv_layout-colwidth_optimize = 'X'.
  alv_layout-zebra             = 'X'.
  alv_layout-no_min_linesize   = 'X'.

* Now call display function
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
           i_callback_program       = gd_repid
           i_callback_top_of_page   = 'TOP_OF_PAGE_SETUP' "Ref to form
           is_layout                = alv_layout
           it_fieldcat              = alv_fieldcat
           i_callback_user_command  = user_command
            i_save = 'X'
      TABLES
            t_outtab                = I1
     EXCEPTIONS
         program_error              = 1
         OTHERS                     = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " display_alv

*&---------------------------------------------------------------------*
*&      Form  top_of_page_setup
*&---------------------------------------------------------------------*
*
*  Set-up what to display at the top of the ALV pages
*  Note that the link to this form is in the
*  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY' parameter
*  i_callback_top_of_page   = 'TOP_OF_PAGE' in form display_alv
*----------------------------------------------------------------------*
FORM top_of_page_setup.

  DATA: t_header TYPE slis_t_listheader,
        wa_header TYPE slis_listheader.

  concatenate  'LISTADO DE NOMINA NRO: '  NOMINA into s_titulo.

  wa_header-typ  = 'H'.
  wa_header-info = s_titulo.
  APPEND wa_header TO t_header.

  CLEAR wa_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
       EXPORTING
            it_list_commentary = t_header.
ENDFORM.                    " top_of_page_setup


*---------------------------------------------------------------------*
* FORM user_command
*---------------------------------------------------------------------*
*
*---------------------------------------------------------------------*
* --> R_UCOMM
* --> RS_SELFIELD
*---------------------------------------------------------------------*
FORM alv_user_command  USING r_ucomm LIKE sy-ucomm
rs_selfield TYPE slis_selfield.

* rs_selfield-fieldname = 'EJERCICIO'.
* MESSAGE ID 'AT' TYPE 'E' NUMBER '315' WITH
*              rs_selfield-value.

if rs_SELFIELD-fieldname = 'NSAP' AND rs_selfield-value <> '0'.
        SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
        SET PARAMETER ID 'BUK' FIELD S_BUKRS-low.
        SET PARAMETER ID 'GJR' FIELD s_ejercicio.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

endif.


ENDFORM. "user_command
