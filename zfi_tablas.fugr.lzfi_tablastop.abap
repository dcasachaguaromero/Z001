FUNCTION-POOL zfi_tablas.                   "MESSAGE-ID ..

* INCLUDE LZFI_TABLASD...                    " Local class definition

TYPE-POOLS: slis,
            truxs.
*
INCLUDE <icons>.
*
TYPES : BEGIN OF ty_fieldnames,
          fieldname TYPE  scrtext_l,
        END OF ty_fieldnames.

DATA : g_repid      TYPE syrepid,
       g_graba      TYPE c,
       g_table      TYPE dd02l-tabname,
       gt_cabeceras TYPE STANDARD TABLE OF ty_fieldnames.
*
CONSTANTS : c_x       TYPE c LENGTH 01 VALUE 'X'.
*
FIELD-SYMBOLS: <ti_table> TYPE STANDARD TABLE,
               <l_line>   TYPE any.
