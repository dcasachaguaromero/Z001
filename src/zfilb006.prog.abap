*&---------------------------------------------------------------------*
*& Report  J_CL_BALANCE_SHEET
*&
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*This report is for country Chile where as per law, companies need to
*submit this report to tax authorities generally at the end of fiscal
*period. This report displays the debit and credit transactions within a
*fiscal period (posting date has been taken into consideration), the
*final balance and the profit and loss statement, before the balance
*sheet and the P&L statement are done.

*********************************************************************
* INCLUDE
*********************************************************************
*Include used for global data declaration.
INCLUDE j_cl_balance_sheet_top.        " global Data
*{   INSERT         ECPK900307                                        1
INCLUDE J_CL_BALANCE_SHEET_DATA_DEF.
*}   INSERT
*
DATA:  gd_pi_fmname    TYPE rs38l_fnam.         "Adobe

* INI - WALDO ALARCON - VISIONONE - 01-05-2020
* tablas para la captura de estructuras de balance.
DATA: BEGIN OF x011p OCCURS 250.
        INCLUDE STRUCTURE rf011p.
      DATA: END   OF x011p.
*     X011Z Interne Tabelle der Bilanzzuordnung
*     -----------------------------------------
DATA: BEGIN OF x011z OCCURS 1100.
        INCLUDE STRUCTURE rf011z.
      DATA: END   OF x011z.
*     X011V Interne Tabelle der Verdichtungsgruppen
*     ---------------------------------------------
DATA: BEGIN OF x011v OCCURS 50.
        INCLUDE STRUCTURE rf011v.
      DATA: END   OF x011v.

TYPES ty_tab(240) TYPE c. "Registro de la tabla

DATA : path_file      LIKE rlgrap-filename,
       v_horiz_tab(1) TYPE c,
       v_newline(1)   TYPE c,
       g_lineas       TYPE i,
       g_primero      TYPE i,
       g_line         TYPE i VALUE 50,
       g_totlaufd     TYPE i,
       s_texto(240)   TYPE c,
       txt1(20),
       txt2(60),
       txt3(20) ,
       txt4(20) ,
       txt5(20) ,
       txt6(20) ,
       txt7(20) ,
       txt8(20),
       txt9(20),
       txt10(20),
       gt_data        TYPE STANDARD TABLE OF ty_tab. "Datos a transferir

CONSTANTS: GC_STRUCTURE_NEW(30) TYPE C VALUE 'ZBALANCECHILE'.
* FIN - WALDO ALARCON - VISIONONE - 01-05-2020

************************************************************************
* Selection Screen
*{   INSERT         ECPK900307                                        2
SELECTION-SCREEN BEGIN OF BLOCK PROG2 WITH FRAME TITLE TEXT-062.
PARAMETERS: p_curtp TYPE curtp DEFAULT gc_currtype OBLIGATORY.

SELECTION-SCREEN END OF BLOCK PROG2.
*}   INSERT
************************************************************************
SELECTION-SCREEN: BEGIN OF BLOCK prog WITH FRAME TITLE TEXT-001.

PARAMETERS: p_date TYPE bkpf-budat DEFAULT sy-datum OBLIGATORY MODIF ID dat. " Date  "Note 2627892
** Begin of note 2627892
PARAMETERS : p_splprd AS CHECKBOX USER-COMMAND prd MODIF ID v1.
** End of note 2627892
PARAMETERS:     bilavers LIKE t011t-versn    MEMORY ID bil
                                             OBLIGATORY.

PARAMETERS: p_zero TYPE jzbal.          " Display zero balance accounts
PARAMETERS: zfile  TYPE localfile.

SELECTION-SCREEN: SKIP.
*PARAMETERS : c_bseg AS CHECKBOX .

*******adobe start
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) TEXT-060 FOR FIELD s_form MODIF ID v1.
PARAMETERS:  s_form AS CHECKBOX DEFAULT ' '              MODIF ID v1.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(18) TEXT-061 FOR FIELD s_name MODIF ID v1.
PARAMETERS:  s_name TYPE tdsfname                        MODIF ID v1.
SELECTION-SCREEN END OF LINE.
******* adobe end

SELECTION-SCREEN: END OF BLOCK prog.

SELECTION-SCREEN BEGIN OF BLOCK prog1 WITH FRAME TITLE TEXT-014.
PARAMETERS : p_xml  AS CHECKBOX TYPE ficl_xml         MODIF ID v1.
PARAMETERS : p_dict AS CHECKBOX TYPE ficl_dict_ind    MODIF ID v1.
PARAMETERS : p_tpid TYPE ficl_txpid                   MODIF ID v1,
             p_rfno TYPE ficl_rectification           MODIF ID v1.
PARAMETERS : p_flenme TYPE regut-fsnam                MODIF ID v1.

SELECTION-SCREEN END OF BLOCK prog1.

AT SELECTION-SCREEN.
*{   DELETE         ECPK900307                                        1
*\  PERFORM validate_xml.
*}   DELETE

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.

*Initialize Fiscal Year
*  CALL FUNCTION 'BUILD_DEFAULT_YEAR'
*    TABLES
*      XGJAHR = SD_GJAHR.

  gv_repid = sy-repid.

*ALV Variant
  CLEAR g_variant.
  g_variant-report = gv_repid.
* Get default variant
  gs_variant = g_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save        = gc_save
    CHANGING
      cs_variant    = gs_variant
    EXCEPTIONS
      wrong_input   = 1
      not_found     = 2
      program_error = 3
      OTHERS        = 4.
  IF sy-subrc <> 0.
* Display no error.
  ENDIF.

************************************************************************
* Selection Screen Validation
************************************************************************
AT SELECTION-SCREEN OUTPUT.
*Subroutine to eliminate unused screen selections
  PERFORM modify_screen.

* INI - WALDO ALARCON - VISIONONE - 01-05-2020
  PERFORM modify_screen_new.
* FIN - WALDO ALARCON - VISIONONE - 01-05-2020

AT SELECTION-SCREEN ON sd_bukrs.
* Choose one Company Code
  IF sd_bukrs-low CA '*'.
    MESSAGE e264.
  ENDIF.

**Fiscal Year Validation
*AT SELECTION-SCREEN ON SD_GJAHR.
*
*  CALL FUNCTION 'BUILD_DEFAULT_YEAR'
*    TABLES
*      XGJAHR = SD_GJAHR.

*Posting date validation.
*AT SELECTION-SCREEN.
*
*  IF P_DATE+0(4) NE SD_GJAHR-LOW.
*    MESSAGE E999 WITH TEXT-012.                             "#EC *
*  ENDIF.

* INI - WALDO ALARCON - VISIONONE - 01-05-2020
AT SELECTION-SCREEN ON VALUE-REQUEST FOR zfile.
  PERFORM value_request_path_down CHANGING  zfile.
* FIN - WALDO ALARCON - VISIONONE - 01-05-2020

*********************************************************************
* INCLUDE
*********************************************************************
*Include for all FORM routines used in the program.
  INCLUDE j_cl_balance_sheet_form.

* INI - WALDO ALARCON - VISIONONE - 01-05-2020
  INCLUDE zfilb006_form.
* FIN - WALDO ALARCON - VISIONONE - 01-05-2020

*********************************************************************
* START OF SELECTION
*********************************************************************
START-OF-SELECTION.
* Fill values for posting date range.
*  PERFORM FILL_RANGE_R_DATE.
  PERFORM fill_range_r_dates.
*Subroutine to get company code data.
  PERFORM get_company_data.

* INI - WALDO ALARCON - VISIONONE - 01-05-2020
* se trae las cuentas estructuras de  balance
  PERFORM fi_import_balance USING bilavers.

  IF sd_rldnr IS INITIAL.
    sd_rldnr-low = '0L'.
  ENDIF.
* FIN - WALDO ALARCON - VISIONONE - 01-05-2020

*Data Selection from Logical Database SDF

* Check New G/L functionality activated ?
  CLEAR: ls_error_in_setup, ls_bukrs_actv, ls_new_gl_actv.
  SELECT SINGLE active FROM fagl_activec INTO ls_new_gl_actv.
  IF ls_new_gl_actv IS NOT INITIAL.
    " Check for any errors in the setup ?
    SELECT SINGLE error_in_setup FROM fagl_check_setup INTO ls_error_in_setup.
    IF ls_error_in_setup = 'X'.
      ls_bukrs_actv = 'X'.
      MESSAGE e820(gi) RAISING error_in_setup.
    ELSE.
      " Check if New G/L functionality document splitting is de-activated for the company code ?
      SELECT SINGLE b_inactive FROM fagl_split_actc INTO ls_bukrs_actv WHERE bukrs = sd_bukrs-low.
    ENDIF.
  ENDIF.

* SKA1 EVENT ********************************************************
GET ska1.
* SKB1 EVENT ********************************************************
GET skb1 FIELDS bukrs.
* SKC1A EVENT *******************************************************
* Subroutine to fill internal table with relevant accounts.
  PERFORM fill_output_table TABLES gt_output.

GET skc1a .

  CLEAR: gs_output.

*********************************************************************
* END OF SELECTION
*********************************************************************
END-OF-SELECTION.

* Delete duplicate entries for G/L accounts.
  SORT gt_output BY bukrs saknr ASCENDING.
  DELETE ADJACENT DUPLICATES FROM gt_output COMPARING ALL FIELDS.

* INI - WALDO ALARCON - VISIONONE - 01-05-2020
* Se sacaran las cuantas que no son estructuradas desde
* la tabla GT_OUTPUT
  PERFORM only_estruct.
* FIN - WALDO ALARCON - VISIONONE - 01-05-2020

* Subroutine to modify output internal table with correct amounts.
  PERFORM correction_output_list.

  IF p_zero = ' '.
*Delete lines from table where items with total debit amount and total
*credit amount zero.
    DELETE gt_output WHERE summe_soll = 0 AND
                           summe_haben = 0.
  ENDIF.

  IF gt_output[] IS INITIAL.
*No records have been found for the selection specified
    MESSAGE s130.
    STOP.
  ENDIF.

  SORT gt_output BY bukrs saknr.
* Subroutine to add lines for totals at the end of final internal table.
  PERFORM add_totals.
* Subroutine to fill rows for totals with no.
  PERFORM find_total_rows.

* INI - WALDO ALARCON - VISIONONE - 01-05-2020
*Subroutine for ALV list output.
*  PERFORM alv_list_output.
  PERFORM alv_list_output_new.
* FIN - WALDO ALARCON - VISIONONE - 01-05-2020

* Adobe connection
  IF s_form = 'X'.
    PERFORM adobe_form.
  ENDIF.

  IF p_xml = abap_true.
    PERFORM create_xml.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  adobe_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM adobe_form .
  DATA: fp_outputparams TYPE sfpoutputparams."adobe connection
  DATA:fp_docparams    TYPE sfpdocparams."adobe connection
  DATA idcl_table TYPE TABLE OF idcl_adobe_table_bs.
  DATA temp_output LIKE idcl_table.
  DATA wa_output LIKE LINE OF idcl_table.
*data wa_output_table like line of output_table.
  DATA wa_output_table LIKE LINE OF gt_output.


  DATA: w_cx_root TYPE REF TO cx_root,
        mesg      TYPE string.


  TRY.
      CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
        EXPORTING
          i_name     = s_name
        IMPORTING
          e_funcname = gd_pi_fmname.
    CATCH cx_root INTO w_cx_root.
      mesg = w_cx_root->get_text( ).
      WRITE:/ mesg.
  ENDTRY.

  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = fp_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.

*
*          loop at output_table into wa_output_table .
*            move-corresponding wa_output_table to wa_output.
*            append wa_output to temp_output.
*          endloop.
*

  LOOP AT gt_output INTO wa_output_table .
    MOVE-CORRESPONDING wa_output_table TO wa_output.
    APPEND wa_output TO temp_output.
  ENDLOOP.


  CALL FUNCTION gd_pi_fmname
    EXPORTING
      /1bcdwb/docparams = fp_docparams
      int_adobe         = temp_output
    EXCEPTIONS
      usage_error       = 1
      system_error      = 2
      internal_error    = 3
      OTHERS            = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*--- close the job again
  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " adobe_form

INCLUDE j_cl_balance_sheet_xml.

INCLUDE j_cl_balance_sheet_xml_val.
