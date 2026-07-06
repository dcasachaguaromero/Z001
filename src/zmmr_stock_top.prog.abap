*&---------------------------------------------------------------------*
*&  Include           ZMMR_STOCK_TOP
*&---------------------------------------------------------------------*
  TYPES: BEGIN OF ty_type_metadata,
           is_hierseq   TYPE abap_bool,
           tabname      TYPE string,
           tabname_line TYPE string,
           s_keyinfo    TYPE kkblo_keyinfo,
           s_layout     TYPE lvc_s_layo,
           t_fcat       TYPE lvc_t_fcat,
           t_filter     TYPE lvc_t_filt,
           t_sort       TYPE lvc_t_sort,
         END OF ty_type_metadata,
* salida de la MB52
         BEGIN OF ty_bestand,
*        Key fields
           matnr    LIKE mara-matnr,
           werks    LIKE t001w-werks,
           lgort    LIKE mard-lgort,
           sobkz    LIKE mkol-sobkz,
           ssnum    LIKE  bickey-ssnum,                     "n531604
           pspnr    LIKE  mspr-pspnr,                       "n531604
           vbeln    LIKE  mska-vbeln,                       "n531604
           posnr    LIKE  mska-posnr,                       "n531604
           lifnr    LIKE mkol-lifnr,
           kunnr    LIKE msku-kunnr,
           kzbws    LIKE mssa-kzbws,
           charg    LIKE mchb-charg,
*        Additional data (texts, unit, ...)
           maktx    LIKE marav-maktx,
           bwkey    LIKE mbew-bwkey,
           mtart    LIKE marav-mtart,
           matkl    LIKE marav-matkl,
           meins    LIKE marav-meins,
           bwtty    LIKE marc-bwtty,
           xchar    LIKE marc-xchar,
           lgobe    LIKE t001l-lgobe,
           bwtar    LIKE mcha-bwtar,
           waers    LIKE t001-waers,
           name1    LIKE t001w-name1,
*        Quantities and currencies
           labst    LIKE mard-labst,  "libre utilizacion
           wlabs    LIKE mbew-salk3,
           insme    LIKE mard-insme,  "Calidad
           winsm    LIKE mbew-salk3,
           speme    LIKE mard-speme,  "Bloqueado
           wspem    LIKE mbew-salk3,
           einme    LIKE mard-einme,
           weinm    LIKE mbew-salk3,
           retme    LIKE mard-retme,
           wretm    LIKE mbew-salk3,
           umlme    LIKE mard-umlme,
           wumlm    LIKE mbew-salk3,
           glgmg    LIKE marc-glgmg,                        "n912093
           wglgm    LIKE mbew-salk3,                        "n912093
           trame    LIKE marc-trame,                        "n912093
           wtram    LIKE mbew-salk3,                        "n912093
           umlmc    LIKE marc-umlmc,                        "n912093
           wumlc    LIKE mbew-salk3,                        "n912093
*        Dummy field
           dummy    TYPE  alv_dummy,
*        Colour
           farbe    TYPE slis_t_specialcol_alv,
           lvorm    LIKE  mard-lvorm,
*        valuated blocked GR stock                       "AC0K020254
           bwesb    LIKE  marc-bwesb,                       "AC0K020254
           wbwesb   LIKE  mbew-salk3,                       "AC0K020254
           sgt_scat LIKE  mchb-sgt_scat,
         END OF ty_bestand,
         ty_t_bestand TYPE TABLE OF ty_bestand,
         BEGIN OF ty_cabn,
           atinn TYPE atinn,
           adzhl TYPE adzhl,
           atnam TYPE atnam,
         END OF ty_cabn.
*
  DATA : BEGIN OF wa_select,
           matnr TYPE mcha-matnr,  "material
           mtart TYPE mara-mtart,  "tipo material
           werks TYPE t001l-werks ,  "centro
           lgort TYPE t001l-lgort,   "almacen
           charg TYPE mchb-charg,  "Lote
           licha TYPE mcha-licha,  "Lote Proveedor
           atwrt TYPE ausp-atwrt,
         END OF wa_select.
*Campos de selección:
*•  Material (De – hasta – Múltiple Selección)
*•  Centro (De – hasta – Múltiple Selección)
*•  Bodega (De – hasta – Múltiple Selección)
*•  Lote (De – hasta – Múltiple Selección)
*Campos de selección especificas:
*•  Lote Proveedor (De – hasta – Múltiple Selección)
*•  Marca (De – hasta – Múltiple Selección)
*•  Fabricante (De – hasta – Múltiple Selección)
*•  Fecha de Caducidad (Rango)
*•  Nr.Serie

  DATA : gt_salida TYPE TABLE OF zes_stock_lote,
         gt_cabn   TYPE TABLE OF ty_cabn,
         wa_salida TYPE zes_stock_lote,
         gv_repid  TYPE sy-repid,
         gr_atinn  TYPE RANGE OF cabn-atinn.

  CONSTANTS : gc_x     TYPE c LENGTH 01 VALUE 'X',
              gc_tabla TYPE c LENGTH 30 VALUE 'ZES_STOCK_LOTE'.
