FUNCTION-POOL zfirfc004.                    "MESSAGE-ID ..

* INCLUDE LZFIRFC004D...                     " Local class definition
* Definicion de varibles Globales.
DATA: t_error TYPE sy-subrc.

* Tabla de interna que registrara los errores de validacion de datos en las estructuras.
DATA: ti_error_cab    TYPE TABLE OF zcabecera_me   WITH HEADER LINE,
      ti_error_det    TYPE TABLE OF zdetalle_me    WITH HEADER LINE,
*-> BEG INS V1-CNN ECDK923606 02.03.2023 Habilitación nueva moneda
      ti_error_det_ct TYPE TABLE OF zdetalle_me_ct WITH HEADER LINE.
*-> End INS V1-CNN ECDK923606 02.03.2023 Habilitación nueva moneda
* Tabla de interna que registrara los documentos a contabiliozar.
DATA: BEGIN OF ti_cont_cab OCCURS 0.
DATA: tipo(2) TYPE c.
      INCLUDE STRUCTURE zcabecera_me.
      DATA: END OF ti_cont_cab.
DATA: BEGIN OF ti_cont_det OCCURS 0.
        INCLUDE STRUCTURE zdetalle_me.
        DATA: tipo(2) TYPE c.
DATA: END OF ti_cont_det.
DATA: ti_cont_det_paso LIKE ti_cont_det.

*-> BEG INS V1-CNN ECDK923606 02.03.2023 Habilitación nueva moneda
DATA: BEGIN OF ti_cont_det_ct OCCURS 0.
        INCLUDE STRUCTURE zdetalle_me_ct.
        DATA: tipo(2) TYPE c.
DATA: END OF ti_cont_det_ct.
DATA: ti_cont_det_paso_ct LIKE ti_cont_det_ct.

TYPES: gty_cont_det_ct LIKE ti_cont_det_ct,
       gty_importe     TYPE c LENGTH 15.

TYPES: BEGIN OF gty_lfbw,
         lifnr     TYPE lifnr,
         bukrs     TYPE bukrs,
         witht     TYPE witht,
         wt_subjct TYPE wt_subjct,
         wt_withcd TYPE wt_withcd,
       END OF gty_lfbw,

       gtt_lfbw TYPE STANDARD TABLE OF gty_lfbw.
*-> END INS V1-CNN ECDK923606 02.03.2023 Habilitación nueva moneda

DATA:
  documentheader    LIKE bapiache09 OCCURS 0 WITH HEADER LINE,
  customercpd       LIKE bapiacpa09,
  contractheader    LIKE bapiaccahd,
  accountgl         LIKE bapiacgl09 OCCURS 0  WITH HEADER LINE,
  accountreceivable LIKE bapiacar09 OCCURS 0 WITH HEADER LINE,
  accountpayable    LIKE bapiacap09 OCCURS 0  WITH HEADER LINE,
  accounttax        LIKE bapiactx09 OCCURS 0 WITH HEADER LINE,
  currencyamount    LIKE bapiaccr09 OCCURS 0 WITH HEADER LINE,
  criteria          LIKE bapiackec9 OCCURS 0,
  valuefield        LIKE bapiackev9 OCCURS 0,
  realestate        LIKE bapiacre09 OCCURS 0,
  extension1        LIKE bapiacextc OCCURS  0 WITH HEADER LINE,
  extension2        LIKE bapiparex OCCURS 0,
  return            LIKE bapiret2 OCCURS 0  WITH HEADER LINE,
  return2           LIKE bapiret2 OCCURS 0  WITH HEADER LINE,
  paymentcard       LIKE bapiacpc09 OCCURS 0,
  contractitem      LIKE bapiaccait OCCURS 0,
  withholdingtax    LIKE bapiacwt09 OCCURS 0,
  accountwt         LIKE bapiacwt09 OCCURS 0  WITH HEADER LINE,
  t_mwdat           LIKE rtax1u15 OCCURS 0  WITH HEADER LINE.

*----------------------------------------------------------------------*
*       CLASS lcl_bdc DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_bdc DEFINITION.

  PUBLIC SECTION.

    DATA: gt_bdcdata TYPE tab_bdcdata.

    METHODS:
      new_data,

      add_dynpro IMPORTING iv_program TYPE bdc_prog
                           iv_dynpro  TYPE bdc_dynr,

      add_field IMPORTING iv_field TYPE fnam_____4
                          iv_value TYPE any,            "bdc_fval.

      call_transaction IMPORTING iv_tcode   TYPE sytcode
                                 iv_mode    TYPE ctu_mode
                                 iv_update  TYPE ctu_update
                       EXPORTING es_retcode TYPE bapiret2
                                 ev_rc      TYPE sy-subrc.

ENDCLASS.
