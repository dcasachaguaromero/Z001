*&---------------------------------------------------------------------*
*&  Include            ZPARTIDAS_ACREEDOR_TOP
*&---------------------------------------------------------------------*

REPORT zpartidas_acreedor NO STANDARD PAGE HEADING.

TABLES: bsak, bkpf, reguh.

TYPES: BEGIN OF g_type_s_test,
         amount  TYPE i,
         repid   TYPE syrepid,
         display TYPE i,
         dynamic TYPE sap_bool,
       END OF g_type_s_test.

TYPES: BEGIN OF ty_s_outtab,
         name1        TYPE name1,
         monto1       TYPE knetwr,
         stcd1        TYPE stcd1,
         znme1        TYPE dznme1,
         rwbtr        TYPE rwbtr,
         checf        TYPE checf,
         identif_pago TYPE char15,
         vblnr        TYPE vblnr,
         zaldt        TYPE dzaldt_zhl,
* ini Waldo Alarcón - Visionone - 20-12-2024
         bankl        TYPE lfbk-bankl,
         bankn        TYPE lfbk-bankn.
* fin Waldo Alarcón - Visionone - 20-12-2024
         INCLUDE STRUCTURE bsak.

       TYPES:  END OF ty_s_outtab.
TYPES: ty_t_outtab TYPE TABLE OF ty_s_outtab.

CONSTANTS: BEGIN OF gc_s_display,
             list       TYPE i VALUE 1,
             fullscreen TYPE i VALUE 2,
             grid       TYPE i VALUE 3,
           END   OF gc_s_display.

DATA: gs_test TYPE g_type_s_test.

*data: gt_outtab type standard table of alv_t_t2.

DATA: gr_table   TYPE REF TO cl_salv_table.

DATA: gr_container TYPE REF TO cl_gui_custom_container.

DATA: g_okcode TYPE syucomm.

CLASS lcl_handle_events DEFINITION DEFERRED.

DATA: gr_outtab        TYPE ty_s_outtab,
      gt_bsak          TYPE TABLE OF bsak WITH HEADER LINE,
      gt_outtab        TYPE ty_t_outtab,
      g_butxt          TYPE butxt,
      g_address_value  TYPE addr1_val,
      g_paval          TYPE paval,
      gt_zfigiro       TYPE TABLE OF zfigiro,
      gr_handle_events TYPE REF TO lcl_handle_events.
*----------------------------------------------------------------------*
* SELECTION-SCREEN - for demonstration purposes only                   *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-008.
PARAMETERS:     p_bukrs TYPE bukrs      OBLIGATORY.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2  WITH FRAME TITLE TEXT-012.

*PYV 02/01/2012 Se Agrega Cuenta de Mayor Como Opcion de Seleccion

*SELECT-OPTIONS: s_lifnr  FOR bsak-lifnr,
*                s_augdt  FOR bsak-augdt,
*                s_augbl  FOR bsak-augbl,
*                s_zuonr  FOR bsak-zuonr,
*                s_gjahr  FOR bkpf-gjahr,
*                s_belnr  FOR bkpf-belnr,
*                s_budat  FOR bkpf-budat,
*                s_waers  FOR bkpf-waers,
*                s_xblnr  FOR bkpf-xblnr,
*                s_blart  FOR bkpf-blart,
*                s_monat  FOR bkpf-monat.

SELECT-OPTIONS: s_lifnr  FOR bsak-lifnr,
                s_augdt  FOR bsak-augdt,
                s_augbl  FOR bsak-augbl,
                s_zuonr  FOR bsak-zuonr,
                s_gjahr  FOR bkpf-gjahr,
                s_belnr  FOR bkpf-belnr,
                s_budat  FOR bkpf-budat,
                s_waers  FOR bkpf-waers,
                s_xblnr  FOR bkpf-xblnr,
                s_blart  FOR bkpf-blart,
                s_monat  FOR bkpf-monat,
                s_hkont  FOR bsak-hkont.

*PYV 02/01/2012 Se Agrega Cuenta de Mayor Como Opcion de Seleccion

SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3  WITH FRAME TITLE TEXT-013.
PARAMETERS: p_op1 TYPE c RADIOBUTTON GROUP g1,
            p_op2 TYPE c RADIOBUTTON GROUP g1,
            p_op3 TYPE c RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK block3.
*********** AUTORIZACIONES ************************************************
*HCD 03-01-2018 se agrega objeto de autorizacion para empresas asociadas.
AT SELECTION-SCREEN.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
        ID 'BUKRS' FIELD p_bukrs
        ID 'ACTVT' FIELD '03'.

  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'Sin autorización para Sociedad.' p_bukrs.
  ENDIF.
***********END AUTORIZACIONES ************************************************
