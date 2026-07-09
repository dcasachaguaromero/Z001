FUNCTION-POOL ZDTE_ENVIO_NOTIFICACION.      "MESSAGE-ID ..

DATA: lc_key      TYPE i VALUE 26101957,
      lc_rfc_dest LIKE rfcdes-rfcdest ."VALUE 'SAPFTPA'.          "RFC Destination

DATA: lv_pwd_len TYPE i,
      lv_handle  TYPE i.

DATA: "li_data TYPE TABLE OF char80 WITH HEADER LINE,
      li_result TYPE TABLE OF char80 WITH HEADER LINE.

TYPES: BEGIN OF ty_data,
         linea(200) type c,
       end of ty_data.

DATA gt_data TYPE STANDARD TABLE OF ty_data.
DATA wa_data LIKE LINE OF gt_data.

DATA: v_cmd_01(80) TYPE c.
DATA: v_cmd_02(80) TYPE c.
DATA: v_cmd_03(80) TYPE c.
DATA: v_cmd_04(80) TYPE c.
DATA: v_cmd_05(80) TYPE c.
DATA: v_path_01 LIKE sxpgcolist-parameters." VALUE '/DTE_RECIBIDOS'.       "Recibidos
DATA: v_path_02 LIKE sxpgcolist-parameters." VALUE '/DTE/DTE_PROCESADOS'.  "Procesados
DATA: v_path_03 LIKE sxpgcolist-parameters." VALUE '/DTE/DTE_ERROR'.       "Erroneos
DATA: v_path_04 LIKE sxpgcolist-parameters." VALUE '/DTE/DTE_RESPUESTA'.   "Rechazados
