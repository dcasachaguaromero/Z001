*&---------------------------------------------------------------------*
*&  Include           ZEICCCBM_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS slis.

TYPES: BEGIN OF ty_sapctactebsid.
INCLUDE TYPE zsapctactebsid.
TYPES END OF ty_sapctactebsid.
TYPES tyt_sapctactebsid TYPE STANDARD TABLE OF ty_sapctactebsid.
TABLES bsid.

CONSTANTS true                   TYPE c VALUE 'X'.
CONSTANTS c_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
CONSTANTS c_formname_top_of_list TYPE slis_formname VALUE 'TOP_OF_LIST'.
CONSTANTS c_formname_end_of_list TYPE slis_formname VALUE 'END_OF_LIST'.
*DATA sapctactebsid TYPE STANDARD TABLE OF zsapctactebsid.

DATA is_u_layout   TYPE slis_layout_alv.
DATA it_u_fieldcat TYPE slis_t_fieldcat_alv.
DATA it_u_sort     TYPE slis_t_sortinfo_alv.
DATA is_print      TYPE slis_print_alv.
DATA gt_events     TYPE slis_t_event.
DATA wznum_doc_core TYPE vbrk-znum_doc_core.
DATA wa_event      TYPE slis_alv_event.
*DATA gt_event_exit TYPE slis_t_event_exit.

TYPES: BEGIN OF t_bseg,
         bukrs TYPE bseg-bukrs,
         belnr TYPE bseg-belnr,
         gjahr TYPE bseg-gjahr,
         fdtag TYPE bseg-fdtag,
         nebtr TYPE bseg-nebtr,
       END OF t_bseg.

TYPES: BEGIN OF t_kna1,
         kunnr TYPE kna1-kunnr,
         stcd1 TYPE kna1-stcd1,
       END OF t_kna1.

DATA: ti_bseg TYPE TABLE OF t_bseg,
      ti_kna1 TYPE TABLE OF t_kna1,
      ti_anex TYPE TABLE OF zfac_anex,
      wa_anex TYPE zfac_anex,
      wa_bseg TYPE t_bseg,
      wa_kna1 TYPE t_kna1.

FIELD-SYMBOLS: <fs> TYPE zsapctactebsid.


DATA tmp_bsid TYPE STANDARD TABLE OF zsapctactebsid .
DATA ls_bsid LIKE LINE OF tmp_bsid.
*DATA error_text TYPE string.
DATA tmp_dmbtr(16).
DATA tmp_wrbtr(16).
DATA tmp_nebtr(16).


DATA tmp_bsad TYPE STANDARD TABLE OF zsapctactebsid.
DATA ls_bsad LIKE LINE OF tmp_bsad.
