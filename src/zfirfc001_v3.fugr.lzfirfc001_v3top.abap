FUNCTION-POOL zfirfc001_v3.                 "MESSAGE-ID ..

TABLES: lfa1,lfb1, kna1,knb1, bsik.
TABLES: zfirfc01,zfirfc02,zfirfc03,zfirfc04.
* Definicion de varibles Globales.
DATA: t_error TYPE sy-subrc.

* Tabla de interna que registrara los errores de validacion de datos en las estructuras.
DATA: BEGIN OF ti_error_cab OCCURS 0.
        INCLUDE STRUCTURE zcabecerav3.
      DATA: END OF ti_error_cab.
DATA: BEGIN OF ti_error_det OCCURS 0.
        INCLUDE STRUCTURE zdetallev3.
      DATA: END OF ti_error_det.
* Tabla de interna que registrara los documentos a contabiliozar.
DATA: BEGIN OF ti_cont_cab OCCURS 0.
DATA: tipo(2) TYPE c.
      INCLUDE STRUCTURE zcabecerav3.
      DATA: END OF ti_cont_cab.
DATA: BEGIN OF ti_cont_det OCCURS 0.
        INCLUDE STRUCTURE zdetallev3.
        DATA: tipo(2) TYPE c.
DATA: END OF ti_cont_det.
DATA: ti_cont_det_paso LIKE ti_cont_det.
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

* ini Waldo Alarcón - Visionone - 11-11-2024
DATA : g_carga_masiva TYPE xflag.
* fin Waldo Alarcón - Visionone - 11-11-2024
