*&---------------------------------------------------------------------*
*&  Include           ZMM_BAJA_CARGA_STOCK_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  BUSQUEDA_ARCHIVO
*&---------------------------------------------------------------------*
FORM busqueda_archivo CHANGING archivo TYPE localfile.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = ' '
      def_path         = 'C:\TEMP\'
      mask             = ',*.CSV.'
      mode             = 'O'
      title            = 'Archivo a importar'
    IMPORTING
      filename         = archivo
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BAJA_STOCK_MB52
*&---------------------------------------------------------------------*
FORM baja_stock_mb52 .
* Types de estructura de salida de METADATA para reportes
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
         BEGIN OF ty_lotes,
           matnr(018),
           charg(015),
           werks(004),
         END OF ty_lotes,
         BEGIN OF ty_matnr,
           matnr LIKE mara-matnr,
           bwkey LIKE mbew-bwkey,
         END OF ty_matnr.
*
  DATA : lt_alv_list        TYPE TABLE OF ty_bestand,
         lt_cabeceras       TYPE STANDARD TABLE OF fieldnames,
         lt_cab_lote        TYPE STANDARD TABLE OF fieldnames,
         lt_lotes           TYPE TABLE OF ty_lotes,
         lt_s_type_metadata TYPE ty_type_metadata,
         lt_pay_data        TYPE REF TO data,
         lt_record          TYPE TABLE OF gty_salida,
         lt_record_z61      TYPE TABLE OF gty_salida,
         lt_record_z62      TYPE TABLE OF gty_salida,
         lt_record_z61_rev  TYPE TABLE OF gty_salida,
         lt_record_z62_rev  TYPE TABLE OF gty_salida,
         lt_matnr           TYPE TABLE OF ty_matnr,
         lv_record_lote     TYPE string VALUE 'LOTES',
         lw_cabeceras       TYPE string,
         lw_alv_list        TYPE ty_bestand,
         lw_lotes           TYPE ty_lotes,
         lw_record          TYPE gty_salida,
         lw_record_paso     TYPE gty_salida,
         lv_record_z61      TYPE string VALUE 'STOCK_Z61',
         lv_record_z62      TYPE string VALUE 'STOCK_Z62',
         lv_texto           TYPE char20,
         lv_budat           TYPE budat,
         lv_fecha           TYPE char10,
         lv_lbkum           TYPE mbewh-lbkum,
         lv_labst           TYPE ty_bestand-labst,
         lv_wlabs           TYPE ty_bestand-wlabs,
         lv_erfmg           TYPE gty_salida-erfmg,
         lv_salk3           TYPE gty_salida-salk3.
*
  FIELD-SYMBOLS : <fs_pay_t_data> TYPE ANY TABLE,
                  <fs_pay_data>   TYPE any.
* prepara el ambiente para la rececpcion de datos
  cl_salv_bs_runtime_info=>set( EXPORTING display  = abap_false
                                          metadata = abap_true
                                          data     = abap_true ).
* REALIZADA LA LLAMADA AL REPORTE
  SUBMIT rm07mlbs
           WITH matnr    IN st_matnr
           WITH werks    IN st_werks
           WITH lgort    IN st_lgort
           WITH charg    IN st_charg
           WITH matart   IN st_mtart
           WITH pa_sond  EQ pt_sond
           WITH so_sobkz IN st_sobkz
           WITH negativ  EQ pt_negat
           WITH xmchb    EQ pt_xmchb
           WITH nozero   EQ pt_noze
           WITH novalues EQ pt_noval
           AND RETURN.
* revisa el resultado del proceso
  TRY.
* OBTIENE LAYOUT Y CATALOGO
      CALL METHOD cl_salv_bs_runtime_info=>get_metadata
        RECEIVING
          value = lt_s_type_metadata.
* OBTIENE LAYOUT Y CATALOGO
      CALL METHOD cl_salv_bs_runtime_info=>get_metadata
        RECEIVING
          value = lt_s_type_metadata.
* OBTIENE LOS DATOS DEL REPORTE
      cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = lt_pay_data ).
      IF lt_pay_data IS NOT INITIAL.
        ASSIGN lt_pay_data->* TO <fs_pay_t_data>.
        IF <fs_pay_t_data> IS ASSIGNED.
          LOOP AT <fs_pay_t_data> ASSIGNING <fs_pay_data>.
            MOVE-CORRESPONDING <fs_pay_data> TO lw_alv_list.
            APPEND lw_alv_list TO lt_alv_list.
          ENDLOOP.
        ENDIF.
      ENDIF.
    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE TEXT-e02 TYPE 'E'.
  ENDTRY.
  cl_salv_bs_runtime_info=>clear_all( ).
*
  CHECK lt_alv_list[] IS NOT INITIAL.
*
*  lt_matnr = CORRESPONDING #( BASE ( lt_matnr ) lt_alv_list ).
*  SORT lt_matnr BY matnr bwkey.
*  DELETE ADJACENT DUPLICATES FROM lt_matnr COMPARING ALL FIELDS.
*  IF lt_matnr[] IS NOT INITIAL.
*    SELECT matnr, bwkey, lfgja, lfmon, lbkum
*          INTO TABLE @DATA(lt_mbewh)
*          FROM mbewh FOR ALL ENTRIES IN @lt_matnr
*                     WHERE matnr EQ @lt_matnr-matnr
*                      AND  bwkey EQ @lt_matnr-bwkey.
*    SORT lt_mbewh BY matnr bwkey lfgja DESCENDING lfmon DESCENDING.
*    DELETE ADJACENT DUPLICATES FROM lt_mbewh COMPARING matnr bwkey.
*  ENDIF.
*
  PERFORM encabezado TABLES lt_cabeceras
                            lt_cab_lote
                     USING  lw_cabeceras.
**
*  PERFORM mes_anterior USING    pt_budat
*                       CHANGING lv_budat.
**
  LOOP AT lt_alv_list INTO lw_alv_list.
    CLEAR : lw_record, lw_record_paso, lv_lbkum.
*    DATA(lv_index) = line_index( lt_mbewh[ matnr = lw_alv_list-matnr
*                                           bwkey = lw_alv_list-bwkey ] ).
*    IF lv_index GT 0.
*      DATA(lw_mbewh) = lt_mbewh[ lv_index ].
*      lv_lbkum       = lw_mbewh-lbkum.
*      IF lw_mbewh-lfgja EQ pt_budat+0(4) AND
*         lw_mbewh-lfmon EQ pt_budat+4(2).
*        WRITE pt_budat           TO lw_record_paso-bldat.
*        WRITE pt_budat           TO lw_record_paso-budat.
*        lv_lbkum = 0.
*      ELSE.
*        IF lw_mbewh-lbkum EQ 0.
*          WRITE pt_budat           TO lw_record_paso-bldat.
*          WRITE pt_budat           TO lw_record_paso-budat.
*        ELSE.
*          WRITE lv_budat           TO lw_record_paso-bldat.
*          WRITE lv_budat           TO lw_record_paso-budat.
*        ENDIF.
*      ENDIF.
*    ELSE.
    WRITE pt_budat           TO lw_record_paso-bldat.
    WRITE pt_budat           TO lw_record_paso-budat.
*    ENDIF.
*
    MOVE : lw_alv_list-werks TO lw_record_paso-werks,
           lw_alv_list-matnr TO lw_record_paso-matnr,
           lw_alv_list-meins TO lw_record_paso-erfme,
           lw_alv_list-lgort TO lw_record_paso-lgort,
           lw_alv_list-charg TO lw_record_paso-charg,
           lw_alv_list-mtart TO lw_record_paso-mtart,
           lw_alv_list-werks TO lw_record_paso-werks,
           lw_alv_list-lgort TO lw_record_paso-lgort,
           lw_alv_list-maktx TO lw_record_paso-maktx.  "texto del material
*
    IF lw_alv_list-charg IS NOT INITIAL.
      MOVE-CORRESPONDING lw_record_paso TO lw_lotes.
      COLLECT lw_lotes INTO lt_lotes.
    ENDIF.

* "libre utilizacion
    IF lw_alv_list-labst NE 0.
      lv_labst = lw_alv_list-labst.
      IF lw_alv_list-waers EQ 'CLP'.
        lv_wlabs = lw_alv_list-wlabs * 100.
      ELSE.
        lv_wlabs = lw_alv_list-wlabs.
      ENDIF.
*      IF lv_lbkum GT 0 AND lv_lbkum LE lw_alv_list-labst.
*        lv_labst = lv_lbkum.
*
*        WRITE lv_labst  TO lv_erfmg  UNIT lw_alv_list-meins.
*
*        CLEAR lw_record.
*        MOVE-CORRESPONDING lw_record_paso TO lw_record.
*        MOVE : 'Z62'             TO lw_record-bwart,
*               lv_erfmg          TO lw_record-erfmg.
*        APPEND lw_record         TO lt_record_z62.
*
**     Subida libre
*        CLEAR lw_record.
*        MOVE-CORRESPONDING lw_record_paso TO lw_record.
*        MOVE: 'Z61'              TO lw_record-bwart,
*              lv_erfmg           TO lw_record-erfmg.
*        APPEND lw_record         TO lt_record_z61.
*
*        lv_labst = lw_alv_list-labst - lv_lbkum.
*        IF lv_labst GT 0.
*          WRITE pt_budat           TO lw_record_paso-bldat.
*          WRITE pt_budat           TO lw_record_paso-budat.
*          WRITE lv_labst  TO lv_erfmg  UNIT lw_alv_list-meins.
*
*          CLEAR lw_record.
*          MOVE-CORRESPONDING lw_record_paso TO lw_record.
*          MOVE : 'Z62'             TO lw_record-bwart,
*                 lv_erfmg          TO lw_record-erfmg.
*          APPEND lw_record         TO lt_record_z62.
*
**     Subida libre
*          CLEAR lw_record.
*          MOVE-CORRESPONDING lw_record_paso TO lw_record.
*          MOVE: 'Z61'              TO lw_record-bwart,
*                lv_erfmg           TO lw_record-erfmg.
*          APPEND lw_record         TO lt_record_z61.
*        ENDIF.
*      ELSEIF lv_lbkum EQ 0 AND lv_lbkum LE lw_alv_list-labst.
      WRITE lv_labst  TO lv_erfmg  UNIT lw_alv_list-meins.
      WRITE lv_wlabs  TO lv_salk3  UNIT lw_alv_list-meins.

      CLEAR lw_record.
      MOVE-CORRESPONDING lw_record_paso TO lw_record.
      MOVE : 'Z62'             TO lw_record-bwart,
             lv_erfmg          TO lw_record-erfmg,
             lv_salk3          TO lw_record-salk3.
      APPEND lw_record         TO lt_record_z62.

**     Subida libre
*        CLEAR lw_record.
*        MOVE-CORRESPONDING lw_record_paso TO lw_record.
*        MOVE: 'Z61'              TO lw_record-bwart,
*              lv_erfmg           TO lw_record-erfmg.
*        APPEND lw_record         TO lt_record_z61.
*      ELSEIF lv_lbkum GT 0.
*        WRITE lv_labst  TO lv_erfmg  UNIT lw_alv_list-meins.
*
*        CLEAR lw_record.
*        MOVE-CORRESPONDING lw_record_paso TO lw_record.
*        MOVE : 'Z62'             TO lw_record-bwart,
*               lv_erfmg          TO lw_record-erfmg.
*        APPEND lw_record         TO lt_record_z62_rev.
*
**     Subida libre
*        CLEAR lw_record.
*        MOVE-CORRESPONDING lw_record_paso TO lw_record.
*        MOVE: 'Z61'              TO lw_record-bwart,
*              lv_erfmg           TO lw_record-erfmg.
*        APPEND lw_record         TO lt_record_z61_rev.
*      ENDIF.
    ENDIF.
  ENDLOOP.
*
*  lt_record[] = lt_record_z61_rev[].
*  SORT lt_record BY matnr.
*  DELETE ADJACENT DUPLICATES FROM lt_record COMPARING matnr.
*  LOOP AT lt_record ASSIGNING FIELD-SYMBOL(<campos>).
*    DELETE lt_record_z62 WHERE matnr = <campos>-matnr.
*    DELETE lt_record_z61 WHERE matnr = <campos>-matnr.
*  ENDLOOP.
*
  MOVE '_BAJA_STOCK.CSV' TO lv_texto.
*
*  WRITE pt_budat TO lv_fecha.
*  lt_record[] = lt_record_z61[].
*  DELETE lt_record WHERE budat EQ lv_fecha.
*  IF lt_record[] IS NOT INITIAL.
*    PERFORM baja_cabecera TABLES lt_record      lt_cabeceras
*                          USING  lv_record_z61 lv_texto  lw_cabeceras lv_budat(6).

  lt_record[] = lt_record_z62[].
*    DELETE lt_record WHERE budat EQ lv_fecha.
  PERFORM baja_cabecera TABLES lt_record     lt_cabeceras
                        USING  lv_record_z62 lv_texto  lw_cabeceras pt_budat(6).
*  ENDIF.
**
*  lt_record[] = lt_record_z61[].
*  DELETE lt_record WHERE budat NE lv_fecha.
*  IF lt_record[] IS NOT INITIAL.
*    PERFORM baja_cabecera TABLES lt_record      lt_cabeceras
*                          USING  lv_record_z61 lv_texto  lw_cabeceras pt_budat(6).
*
*    lt_record[] = lt_record_z62[].
*    DELETE lt_record WHERE budat NE lv_fecha.
*    PERFORM baja_cabecera TABLES lt_record     lt_cabeceras
*                          USING  lv_record_z62 lv_texto  lw_cabeceras pt_budat(6).
*  ENDIF.
**
*  lt_record[] = lt_record_z61_rev[].
*  IF lt_record[] IS NOT INITIAL.
*    PERFORM baja_cabecera TABLES lt_record      lt_cabeceras
*                          USING  lv_record_z61 lv_texto  lw_cabeceras 'REVISAR'.
*
*    lt_record[] = lt_record_z62_rev[].
*    PERFORM baja_cabecera TABLES lt_record     lt_cabeceras
*                          USING  lv_record_z62 lv_texto  lw_cabeceras 'REVISAR'.
*  ENDIF.
*  PERFORM baja_cabecera TABLES lt_lotes        lt_cab_lote
*                        USING  lv_record_lote  lv_texto.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CARGA_STOCK
*&---------------------------------------------------------------------*
FORM carga_stock .
*
* BAPI TO Upload Inventory Data
*
* GMCODE Table T158G - 01 - MB01 - Goods Receipts for Purchase Order
*                      02 - MB31 - Goods Receipts for Prod Order
*                      03 - MB1A - Goods Issue
*                      04 - MB1B - Transfer Posting
*                      05 - MB1C - Enter Other Goods Receipt
*                      06 - MB11
*
* Domain: KZBEW - Movement Indicator
*      Goods movement w/o reference
*  B - Goods movement for purchase order
*  F - Goods movement for production order
*  L - Goods movement for delivery note
*  K - Goods movement for kanban requirement (WM - internal only)
*  O - Subsequent adjustment of "material-provided" consumption
*  W - Subsequent adjustment of proportion/product unit material
*
  DATA : lt_record      TYPE TABLE OF gty_salida,
         lt_itab        TYPE TABLE OF bapi2017_gm_item_create,
         lt_errmsg      TYPE TABLE OF bapiret2,
         lt_bapiret2    TYPE TABLE OF bapiret2,
         lw_gmhead      TYPE bapi2017_gm_head_01,
         lw_gmcode      TYPE bapi2017_gm_code,
         lw_mthead      TYPE bapi2017_gm_head_ret,
         lw_itab        TYPE bapi2017_gm_item_create,
         lw_errmsg      TYPE bapiret2,
         lw_record      TYPE gty_salida,
         lv_start_index LIKE sy-tabix,
         lv_end_index   LIKE sy-tabix,
         lv_pa_lin      LIKE sy-tabix,
         lv_fix_rows    LIKE sy-tabix,
         lv_primero     LIKE lw_itab-batch,
         lv_ultimo      LIKE lw_itab-batch,
         lv_tabix       TYPE sy-tabix,
         lv_errflag     TYPE c,
         lv_campo2      TYPE char32,
         lv_text        TYPE char32,
         lv_lin         TYPE i  VALUE '100'.
*
  PERFORM lee_archivo TABLES lt_record[] USING pa_file.
  CHECK lt_record[] IS NOT INITIAL.
  READ TABLE lt_record INTO lw_record INDEX 1.
  PERFORM formatea_fecha USING    lw_record-budat
                         CHANGING lw_gmhead-pstng_date .
  PERFORM formatea_fecha USING    lw_record-bldat
                         CHANGING lw_gmhead-doc_date .
  lw_gmhead-pr_uname   = sy-uname.
  lw_gmhead-header_txt = lw_record-bktxt.
  lw_gmcode-gm_code    = '05'.
*
  DESCRIBE TABLE lt_record LINES lv_pa_lin.
  lv_start_index = 1.
  lv_fix_rows    = lv_lin.
  lv_end_index   = lv_start_index + lv_fix_rows - 1.
*
  SELECT matnr, meins INTO TABLE @DATA(lt_mara)
         FROM mara FOR ALL ENTRIES IN @lt_record
                     WHERE matnr EQ @lt_record-matnr.
*
  DO.
    REFRESH : lt_itab, lt_errmsg.
    CLEAR   : lw_mthead.
*
    LOOP AT lt_record INTO lw_record FROM lv_start_index TO lv_end_index.
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input        = lw_record-matnr
        IMPORTING
          output       = lw_record-matnr
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2.

      DATA(lv_index) = line_index( lt_mara[ matnr = lw_record-matnr ] ).
      IF lv_index GT 0.
        DATA(lw_mara)      = lt_mara[ lv_index ].
        lw_itab-material   = lw_mara-matnr.
        lw_itab-entry_uom  = lw_mara-meins.
        lw_itab-move_type  = lw_record-bwart.
        lw_itab-mvt_ind    = ''.
        lw_itab-spec_stock = lw_record-sobkz.
        lw_itab-plant      = lw_record-werks.
*
        PERFORM ajusta_campo USING    lw_record-lifnr
                             CHANGING lw_itab-vendor.
        PERFORM ajusta_campo USING    lw_record-kunnr
                             CHANGING lw_itab-customer.
*
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
          EXPORTING
            input          = lw_record-erfme
            language       = sy-langu
          IMPORTING
            output         = lw_itab-entry_uom
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
*
        TRANSLATE lw_record-erfmg USING '. '.
        TRANSLATE lw_record-erfmg USING ',.'.
        CONDENSE lw_record-erfmg  NO-GAPS.
*
*        REPLACE '_%Z' IN gt_record-charg WITH ''.
*
        lw_itab-entry_qnt  = lw_record-erfmg.
        lw_itab-stge_loc   = lw_record-lgort.
        lw_itab-batch      = lw_record-charg.
*
        TRANSLATE lw_record-salk3 USING '. '.
        TRANSLATE lw_record-salk3 USING ',.'.
        CONDENSE lw_record-salk3  NO-GAPS.
        lw_itab-amount_lc  = lw_record-salk3.

        IF lw_record-charg IS INITIAL.
          lw_itab-prod_date = sy-datum.
        ENDIF.

        APPEND lw_itab TO lt_itab.
        CLEAR  lw_itab.
      ELSE.
        CLEAR lw_errmsg.
        MOVE : 'E'                      TO lw_errmsg-type,
               'MM'                     TO lw_errmsg-id,
               '899'                    TO lw_errmsg-number,
               'Material No existe'     TO lw_errmsg-message_v1,
                lw_record-matnr         TO lw_errmsg-message_v2,
                'Lote'                  TO lw_errmsg-message_v3,
                lw_record-charg        TO lw_errmsg-message_v4.
        PERFORM mueve_log TABLES lt_bapiret2
                          USING ''
                                 lv_campo2
                                 lw_errmsg.
      ENDIF.
    ENDLOOP.
    IF sy-subrc NE 0 OR lt_itab[] IS INITIAL.
      EXIT.
    ENDIF.
*
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = lw_gmhead
        goodsmvt_code    = lw_gmcode
        testrun          = pa_test
      IMPORTING
        goodsmvt_headret = lw_mthead
      TABLES
        goodsmvt_item    = lt_itab
        return           = lt_errmsg.
    CLEAR lv_errflag.

    DESCRIBE TABLE lt_itab LINES lv_tabix.
    READ TABLE lt_itab INTO lw_itab INDEX 1.
    MOVE lw_itab-batch TO lv_primero.

    READ TABLE lt_itab INTO lw_itab INDEX lv_tabix.
    MOVE lw_itab-batch TO lv_ultimo.

    CONCATENATE 'Rango:' lv_primero '-' lv_ultimo INTO lv_campo2 .
    CLEAR lw_errmsg.
    MOVE : 'S'                      TO lw_errmsg-type,
           'MM'                     TO lw_errmsg-id,
           '899'                    TO lw_errmsg-number,
           'Desde linea'            TO lw_errmsg-message_v1,
            lv_start_index          TO lw_errmsg-message_v2,
            'a linea'               TO lw_errmsg-message_v3,
            lv_tabix                TO lw_errmsg-message_v4.
    MESSAGE ID lw_errmsg-id TYPE lw_errmsg-type NUMBER lw_errmsg-number
            WITH lw_errmsg-message_v1 lw_errmsg-message_v2
                 lw_errmsg-message_v3 lw_errmsg-message_v4
            INTO lw_errmsg-message.
    PERFORM mueve_log TABLES lt_bapiret2
                      USING 'Rango leido'
                             lv_campo2
                             lw_errmsg.

    LOOP AT lt_errmsg INTO lw_errmsg.
      IF lw_errmsg-type EQ 'E'.
        lv_errflag = 'X'.
        READ TABLE lt_itab INTO lw_itab INDEX lw_errmsg-row.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lw_itab-material
          IMPORTING
            output = lw_itab-material.

        CONCATENATE 'ERROR en material' lw_itab-material 'Posición:' INTO lv_text SEPARATED BY space.
        PERFORM mueve_log  TABLES lt_bapiret2
                           USING lv_text
                                 lw_errmsg-row
                                 lw_errmsg.
      ELSE.
        PERFORM mueve_log  TABLES lt_bapiret2
                           USING 'Dato leido ok'
                                 lw_errmsg-row
                                 lw_errmsg.
      ENDIF.
    ENDLOOP.

    IF lv_errflag IS INITIAL.
      COMMIT WORK AND WAIT.
*
      MOVE : 'S'                      TO lw_errmsg-type,
             'MM'                     TO lw_errmsg-id,
             '899'                    TO lw_errmsg-number,
             'Documento Creado'       TO lw_errmsg-message_v1,
              lw_mthead-mat_doc       TO lw_errmsg-message_v2,
              'Año'                   TO lw_errmsg-message_v3,
              lw_mthead-doc_year      TO lw_errmsg-message_v4.
      MESSAGE ID lw_errmsg-id TYPE lw_errmsg-type NUMBER lw_errmsg-number
              WITH lw_errmsg-message_v1 lw_errmsg-message_v2
                   lw_errmsg-message_v3 lw_errmsg-message_v4
              INTO lw_errmsg-message.
      PERFORM mueve_log  TABLES lt_bapiret2
                          USING 'DOCUMENTO CREADO'
                               lv_campo2
                               lw_errmsg.
    ELSE.
      MOVE : 'E'                      TO lw_errmsg-type,
             'MM'                     TO lw_errmsg-id,
             '899'                    TO lw_errmsg-number,
             'Desde linea'            TO lw_errmsg-message_v1,
              lv_start_index          TO lw_errmsg-message_v2,
              'a linea'               TO lw_errmsg-message_v3,
              lv_tabix                TO lw_errmsg-message_v4.
      MESSAGE ID lw_errmsg-id TYPE lw_errmsg-type NUMBER lw_errmsg-number
              WITH lw_errmsg-message_v1 lw_errmsg-message_v2
                   lw_errmsg-message_v3 lw_errmsg-message_v4
              INTO lw_errmsg-message.
      PERFORM mueve_log TABLES lt_bapiret2
                        USING 'Rango CON ERRORES'
                               lv_campo2
                               lw_errmsg.
    ENDIF.
*
    lv_start_index = lv_end_index + 1.
    lv_end_index   = lv_start_index + lv_fix_rows - 1.
*
    WAIT UP TO 2 SECONDS.
    COMMIT WORK AND WAIT.
  ENDDO.

  PERFORM muestra_datos TABLES lt_bapiret2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ENCABEZADO
*&---------------------------------------------------------------------*
FORM encabezado TABLES ti_cabeceras
                       ti_cab_lotes
                USING p_lw_cabeceras TYPE string.
  DATA : lt_cabeceras TYPE STANDARD TABLE OF fieldnames,
         lt_cab_lote  TYPE STANDARD TABLE OF fieldnames,
         lw_cabeceras TYPE fieldnames.
*
  CLEAR : ti_cabeceras[], ti_cab_lotes[].
  lw_cabeceras-fieldname = 'Fecha doc'.       APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Fecha Contab'.    APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Texto cabecera'.  APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Clase Mov'.       APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Centro'.          APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Stock Special'.   APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Proveedor'.       APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Cliente'.         APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Material'.        APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Cantidad'.        APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Unida Medida'.    APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Almacén '.        APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Lote'.            APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'VACIO'.           APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Tipo Material'.   APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Texto material'.  APPEND lw_cabeceras TO lt_cabeceras.
  lw_cabeceras-fieldname = 'Valor Stock Valorado Total'.  APPEND lw_cabeceras TO lt_cabeceras.
  APPEND LINES OF lt_cabeceras TO ti_cabeceras.
  LOOP AT lt_cabeceras INTO lw_cabeceras.
    CASE sy-tabix.
      WHEN 1.
        p_lw_cabeceras = lw_cabeceras-fieldname.
      WHEN OTHERS.
        p_lw_cabeceras = p_lw_cabeceras && ';' && lw_cabeceras-fieldname.
    ENDCASE.
  ENDLOOP.
*
  lw_cabeceras-fieldname = 'Material'.        APPEND lw_cabeceras TO lt_cab_lote.
  lw_cabeceras-fieldname = 'Lote'.            APPEND lw_cabeceras TO lt_cab_lote.
  lw_cabeceras-fieldname = 'Centro'.          APPEND lw_cabeceras TO lt_cab_lote.
  APPEND LINES OF lt_cab_lote TO ti_cab_lotes.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BAJA_CABECERA
*&---------------------------------------------------------------------*
FORM baja_cabecera  TABLES ti_tabla     TYPE gty_t_salida
                           ti_cabeceras
                    USING p_name p_texto
                          p_lw_cabeceras TYPE string
                          p_fecha.
  DATA : lv_filename   TYPE string,
         lt_tabla_paso TYPE truxs_t_text_data,
         lt_tabla      TYPE truxs_t_text_data.
*
  CHECK ti_tabla[] IS NOT INITIAL.
  CONCATENATE pa_fbaja p_name '_' p_fecha p_texto INTO lv_filename.
*
  CALL FUNCTION 'SAP_CONVERT_TO_CSV_FORMAT'
    EXPORTING
      i_field_seperator    = ';'
    TABLES
      i_tab_sap_data       = ti_tabla
    CHANGING
      i_tab_converted_data = lt_tabla_paso
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.

  APPEND p_lw_cabeceras         TO lt_tabla .
  APPEND LINES OF lt_tabla_paso TO lt_tabla.
*
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = lv_filename
      write_field_separator   = 'X'
      filetype                = 'DAT'
*     write_field_separator   = ' '
    TABLES
      data_tab                = lt_tabla
"     fieldnames              = ti_cabeceras
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

    WRITE :/ 'ARCHIVO bajado : ', lv_filename.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_ARCHIVO
*&---------------------------------------------------------------------*
FORM lee_archivo  TABLES   p_table TYPE  gty_t_salida
                  USING    p_pa_file.
  DATA : lt_tab    TYPE TABLE OF text1000,
         lv_file   TYPE string,
         lw_record TYPE gty_salida.
*
  CLEAR p_table[].
  lv_file = p_pa_file.
*
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_file
      filetype                = 'DAT'
    TABLES
      data_tab                = lt_tab
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    LOOP AT lt_tab INTO DATA(lw_tab) FROM 2.
      CLEAR lw_record.
      SPLIT lw_tab AT ';' INTO lw_record-bldat
                               lw_record-budat
                               lw_record-bktxt
                               lw_record-bwart
                               lw_record-werks
                               lw_record-sobkz
                               lw_record-lifnr
                               lw_record-kunnr
*---------- Posiciones ----------
                               lw_record-matnr
                               lw_record-erfmg
                               lw_record-erfme
                               lw_record-lgort
                               lw_record-charg
                               lw_record-err
*
                               lw_record-mtart
                               lw_record-maktx
                               lw_record-salk3.

      lw_record-matnr = |{ lw_record-matnr ALPHA = IN }|.
      APPEND lw_record TO p_table.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FORMATEA_FECHA
*&---------------------------------------------------------------------*
FORM formatea_fecha  USING    p_fecha_ent
                     CHANGING p_fecha_sal.
  DATA lv_fecha TYPE char10.
*
  CHECK p_fecha_ent IS NOT INITIAL.
  CLEAR p_fecha_sal.
  MOVE p_fecha_ent(10) TO lv_fecha.
  TRANSLATE lv_fecha USING '-.'.
*
  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external            = lv_fecha
    IMPORTING
      date_internal            = p_fecha_sal
    EXCEPTIONS
      date_external_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  AJUSTA_CAMPO
*&---------------------------------------------------------------------*
FORM ajusta_campo  USING    p_input
                   CHANGING p_output.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_input
    IMPORTING
      output = p_output.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUEVE_LO
*&---------------------------------------------------------------------*
FORM mueve_log  TABLES  ti_bapiret2 STRUCTURE bapiret2
                 USING   p_mensaje
                         p_valor
                         p_lt_messtab  TYPE bapiret2.
  DATA : lw_bapiret2 TYPE bapiret2,
         lv_message  TYPE bapi_msg.

  MOVE-CORRESPONDING p_lt_messtab TO lw_bapiret2.
  MOVE p_mensaje                  TO lw_bapiret2-parameter.
  MOVE p_valor                    TO lw_bapiret2-field.

  APPEND lw_bapiret2 TO ti_bapiret2.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos TABLES ti_bapiret.
  DATA : lw_layout           TYPE slis_layout_alv.
*
  PERFORM layout_init     USING lw_layout.
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = gv_repid
      is_layout          = lw_layout
      i_structure_name   = 'BAPIRET2'
      i_save             = 'A'
    TABLES
      t_outtab           = ti_bapiret
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.
*-- Construye layout para desplegar lista
  rs_layout-detail_popup      = 'X'.
  rs_layout-colwidth_optimize = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MES_ANTERIOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PT_BUDAT  text
*      <--P_LV_BUDAT  text
*----------------------------------------------------------------------*
FORM mes_anterior  USING    p_pt_budat
                   CHANGING p_lv_budat.
  DATA : lv_date   LIKE  p0001-begda,
         lv_days   LIKE  t5a4a-dlydy,
         lv_months LIKE  t5a4a-dlymo,
         lv_signum LIKE  t5a4a-split,
         lv_years  LIKE  t5a4a-dlyyr.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = p_pt_budat
      days      = lv_days
      months    = 1
      signum    = '-'
      years     = lv_years
    IMPORTING
      calc_date = p_lv_budat.

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = p_lv_budat
    IMPORTING
      last_day_of_month = p_lv_budat
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.
