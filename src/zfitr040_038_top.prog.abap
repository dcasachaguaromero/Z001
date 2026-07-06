*&---------------------------------------------------------------------*
*&  Include           ZFITR040_038_TOP
*&---------------------------------------------------------------------*

TYPES: BEGIN OF gty_log,
         texto TYPE bapi_msg,
       END OF gty_log.

TYPES: gtt_tabla TYPE STANDARD TABLE OF zfitr040_est,
       gtt_log   TYPE STANDARD TABLE OF gty_log.

TYPES: BEGIN OF gty_ztparamftp,
         zruta          TYPE ztxtmami64,
         zruta_respaldo TYPE ztxtmami64,
       END OF gty_ztparamftp.

DATA: gs_ztparamftp TYPE gty_ztparamftp,
      gs_variant    TYPE disvariant.

DATA: gt_tabla TYPE gtt_tabla,
      gt_log   TYPE gtt_log.

DATA: gv_rc      TYPE sysubrc,
      gv_message TYPE bapi_msg,
      gv_repid   TYPE syrepid.
