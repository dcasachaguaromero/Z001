*&---------------------------------------------------------------------*
*&  Include           ZFIBI_AS92_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

TYPES: t_excel   TYPE  alsmex_tabline.

TYPES: BEGIN OF t_data,
  ANLN1     TYPE  ANLA-ANLN1,
  BUKRS     TYPE  ANLA-BUKRS,
  SCHRW(13) TYPE  c  ,
END OF t_data.

TYPES: BEGIN OF t_alv,
     pos          TYPE sytabix,      " Numero de posicion del excel
     activo       TYPE anln1,        " N° Activo Fijo.
     bukrs        TYPE bukrs,        " Sociedad
     mensaje(300) TYPE c,            " Mensaje.
     color_l(4)   TYPE c,            " Color Line.
     color_c      TYPE lvc_t_scol,   " Color Celda.
END OF t_alv.

DATA: gt_carga_excel    TYPE TABLE OF t_excel,
      gw_carga_excel    TYPE          t_excel,
      gt_data           TYPE TABLE OF t_data,
      gw_data           TYPE          t_data,
      gt_alv            TYPE TABLE OF t_alv,
      gw_alv            TYPE          t_alv.

DATA: c_x TYPE c VALUE 'X'.
*----------------------------------------------------------------------*
*   DECLARACION DE VARIABLES BACH AS92
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:     bdcdata    LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:     gtmsj      TYPE TABLE OF bdcmsgcoll WITH HEADER LINE .
DATA:     gv_mode(3) TYPE c VALUE 'N'," Modo para BI
          gv_pos     TYPE sytabix,    " posicion del excel
          gv_lineas  TYPE sytabix.    " Contador Total
