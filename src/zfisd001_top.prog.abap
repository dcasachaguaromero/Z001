*&---------------------------------------------------------------------*
*&  Include           ZFISD001_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : slis.

CONSTANTS : c_j TYPE c VALUE 'J',
            c_k TYPE c VALUE 'K',
            c_h TYPE c VALUE 'H',
            c_c TYPE c VALUE 'C',
            c_x TYPE c VALUE 'X'.


DATA: ti_VBRK TYPE TABLE OF VBRK.

FIELD-SYMBOLS: <fs> TYPE VBRK.

DATA: BEGIN OF ti_entrada OCCURS 0,
         nrocore      TYPE vbrk-znum_doc_core,
         vbeln        TYPE vbrk-vbeln,
         Belnr        TYPE vbrk-belnr,
      END OF ti_entrada.


* Catálogo de campos: contiene la descripción de los campos de salida
DATA: gt_fieldcat         TYPE slis_t_fieldcat_alv ,
      gt_sort             TYPE slis_t_sortinfo_alv WITH HEADER LINE,
* Especificaciones de la disposición de la lista: descripción de la
* estructura de salida
      gs_layout            TYPE slis_layout_alv,
      gt_list_top_of_page  TYPE slis_t_listheader,
      gt_events            TYPE slis_t_event,
*     gt_sort              type slis_t_sortinfo_alv,
      ls_vari              TYPE disvariant,
      g_repid              LIKE sy-repid.
