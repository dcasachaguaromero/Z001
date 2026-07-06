*&---------------------------------------------------------------------*
*&  Include           ZMM_PUR_RP_COMPRAS_F01
*&---------------------------------------------------------------------*

*--------------------------------------------------------------------*
*&   Form  USER_COMMAND
*--------------------------------------------------------------------*
FORM user_command USING  r_ucomm     LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.

  CONSTANTS: lc_me23n TYPE sytcode VALUE 'ME23N'.
  DATA: ls_lib        TYPE gty_lib.
  DATA: lt_lib_sal    TYPE gtt_lib.
  DATA: lv_ebeln      TYPE ebeln.

  CASE r_ucomm.
    WHEN 'DOBCLICK'.
      CASE rs_selfield-fieldname.
        WHEN 'ICOLIB'.
          lv_ebeln = gt_sal[ rs_selfield-tabindex ]-ebeln.
          LOOP AT gt_lib INTO ls_lib WHERE ebeln = lv_ebeln.
            APPEND ls_lib TO lt_lib_sal.
          ENDLOOP.
          PERFORM display_lib TABLES lt_lib_sal.
        WHEN 'EBELN'.
*         Visualizar Doc. de Compra en Transaccion ME23N
          IF NOT rs_selfield-value IS INITIAL.
            SET PARAMETER ID 'BES' FIELD rs_selfield-value.
            CALL TRANSACTION lc_me23n AND SKIP FIRST SCREEN.
          ENDIF.
      ENDCASE.
  ENDCASE.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  ARMAR_TABLA_SALIDA
*&---------------------------------------------------------------------*
FORM armar_tabla_salida  TABLES it_po   TYPE gtt_po
                                it_lib  TYPE gtt_lib
                                it_ekbe TYPE gtt_ekbe
                                ot_sal  TYPE gtt_sal.

  DATA: ls_sal  TYPE zmm_rp_compras_alv,
        ls_po   TYPE gty_po,
        ls_lib  TYPE gty_lib,
        ls_ekbe TYPE gty_ekbe.

  DATA: lt_sal_x TYPE gtt_sal.

  DATA: lv_awkey TYPE awkey,
        lv_vgart TYPE m8vga,
        lv_stblg TYPE re_stblg.

  CLEAR: ot_sal.

  LOOP AT it_po INTO ls_po.
    CLEAR: ls_sal.
    MOVE-CORRESPONDING ls_po TO ls_sal.
    ls_sal-aedat = ls_po-bedat.
    ls_sal-stcd1 = ls_po-paval.

    ls_sal-maktx = ls_po-txz01.

*   Último liberador
    READ TABLE it_lib INTO ls_lib
      WITH KEY ebeln = ls_po-ebeln BINARY SEARCH.
    IF sy-subrc = 0.
      ls_sal-usuap = ls_lib-username.
      ls_sal-datap = ls_lib-udate.
    ENDIF.
*   Icono detalle de liberaciones
    ls_sal-icolib = '@5Y@'.

*   Buscar stock a la fecha
*    IF ls_po-pstyp <> '9'.
*      CALL FUNCTION 'Z_MM_PUR_STOCK_A_FECHA'
*        EXPORTING
*          i_bukrs = ls_sal-bukrs
*          i_bedat = ls_po-bedat
*          i_matnr = ls_sal-matnr
*          i_werks = ls_po-werks
*        IMPORTING
*          o_menge = ls_sal-labst.
*    ELSE.
*      CLEAR: ls_sal-labst.
*    ENDIF.

    APPEND ls_sal TO lt_sal_x.
  ENDLOOP.

* Agregar lineas del historial
  LOOP AT lt_sal_x INTO ls_sal.
    LOOP AT it_ekbe INTO ls_ekbe WHERE ebeln = ls_sal-ebeln AND
                                       ebelp = ls_sal-ebelp.

      CLEAR: ls_sal-bwart, ls_sal-xblnr_m, ls_sal-budat_m,
             ls_sal-matnr_m, ls_sal-maktx_m, ls_sal-wrbtr_m,
             ls_sal-menge_mr, ls_sal-menge_md, ls_sal-xblnr_f,
             ls_sal-bldat_f, ls_sal-matnr_f, ls_sal-maktx_f,
             ls_sal-menge_f, ls_sal-wrbtr_f, ls_sal-statu_f,
             ls_sal-blart_f, ls_sal-budat_f,  ls_sal-belnr_m, ls_sal-belnr_f.

      IF ls_ekbe-vgabe = '1' AND ls_ekbe-bewtp = 'E'.
*       Recepciones y devoluciones de mercadería ----------------------
        ls_sal-bwart = ls_ekbe-bwart.
        IF ls_ekbe-bwart = '101' OR ls_ekbe-bwart = '102'
                                 OR ls_ekbe-bwart = '122'.
          ls_sal-xblnr_m = ls_ekbe-xblnr.
          ls_sal-budat_m = ls_ekbe-budat.
          ls_sal-matnr_m = ls_ekbe-matnr.
*          SELECT SINGLE FROM makt FIELDS maktx WHERE matnr = @ls_ekbe-matnr AND
*                                                     spras = @sy-langu
*                                               INTO @ls_sal-maktx_m.
          ls_sal-maktx_m = ls_sal-maktx.
          ls_sal-wrbtr_m = ls_ekbe-wrbtr.
          ls_sal-belnr_m = ls_ekbe-belnr.
        ENDIF.

        IF ls_ekbe-bwart = '101'.
          ls_sal-menge_mr = ls_ekbe-menge.
        ELSEIF ls_ekbe-bwart = '102' OR ls_ekbe-bwart = '122'.
          ls_sal-menge_md = ls_ekbe-menge.
        ENDIF.

*       Agrega movimiento de mercadería
        APPEND ls_sal TO ot_sal.
      ENDIF.

      IF ls_ekbe-vgabe = '2' AND ls_ekbe-bewtp = 'Q'.
*       Facturas recibidas --------------------------------------------
        CLEAR: lv_vgart, lv_stblg.
        SELECT SINGLE FROM rbkp
          FIELDS xblnr, bldat, blart, budat, vgart, stblg
          WHERE belnr = @ls_ekbe-belnr          AND
                gjahr = @ls_ekbe-gjahr
          INTO (@ls_sal-xblnr_f, @ls_sal-bldat_f,
                @ls_sal-blart_f, @ls_sal-budat_f,
                @lv_vgart, @lv_stblg
               ).

        ls_sal-matnr_f = ls_ekbe-matnr.
        ls_sal-maktx_f = ls_sal-maktx.
        ls_sal-menge_f = ls_ekbe-menge.
        ls_sal-wrbtr_f = ls_ekbe-wrbtr.
        ls_sal-belnr_f = ls_ekbe-belnr.

        CONCATENATE ls_ekbe-belnr ls_ekbe-gjahr
          INTO lv_awkey.

        SELECT SINGLE FROM bkpf
          FIELDS bukrs,
                 belnr,
                 gjahr,
                 awtyp
          WHERE awtyp = 'RMRP'     AND
                awkey = @lv_awkey
          INTO @DATA(ls_key).

        IF sy-subrc = 0.
*         Factura sin anulación
          IF lv_vgart = 'RD' AND lv_stblg IS INITIAL.
            SELECT FROM bsik
              FIELDS xblnr
              WHERE bukrs = @ls_key-bukrs  AND
                    lifnr = @ls_sal-lifnr  AND
                    gjahr = @ls_key-gjahr  AND
                    belnr = @ls_key-belnr
              INTO @DATA(lv_xblnr)
              UP TO 1 ROWS.
            ENDSELECT.
            IF sy-subrc = 0.
              ls_sal-statu_f = 'No Pagada'.
            ELSE.
              SELECT FROM bsak
                FIELDS xblnr
                WHERE bukrs = @ls_key-bukrs  AND
                      lifnr = @ls_sal-lifnr  AND
                      gjahr = @ls_key-gjahr  AND
                      belnr = @ls_key-belnr
                INTO @lv_xblnr
                UP TO 1 ROWS.
              ENDSELECT.
              ls_sal-statu_f = 'Pagada'.
            ENDIF.

          ELSEIF NOT lv_stblg IS INITIAL.
*           Factura anulada
            SELECT FROM bsik
              FIELDS xblnr
              WHERE bukrs = @ls_key-bukrs  AND
                    lifnr = @ls_sal-lifnr  AND
                    gjahr = @ls_key-gjahr  AND
                    belnr = @ls_key-belnr
              INTO @lv_xblnr
              UP TO 1 ROWS.
            ENDSELECT.
            IF sy-subrc = 0.
              ls_sal-statu_f = 'Anulada'.
            ELSE.
              SELECT FROM bsak
                FIELDS xblnr
                WHERE bukrs = @ls_key-bukrs  AND
                      lifnr = @ls_sal-lifnr  AND
                      gjahr = @ls_key-gjahr  AND
                      belnr = @ls_key-belnr
                INTO @lv_xblnr
                UP TO 1 ROWS.
              ENDSELECT.
              ls_sal-statu_f = 'Anulada'.
            ENDIF.
          ENDIF.
        ENDIF.

*       Agrega factura
        APPEND ls_sal TO ot_sal.
      ENDIF.

    ENDLOOP.

    IF sy-subrc <> 0.
      APPEND ls_sal TO ot_sal.
    ENDIF.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  BUSCAR_HISTORIAL
*&---------------------------------------------------------------------*
FORM buscar_historial TABLES it_po   TYPE gtt_po
                             ot_ekbe TYPE gtt_ekbe.

  DATA: BEGIN OF ls_ped,
          ebeln TYPE ebeln,
        END OF ls_ped.

  DATA: ls_po   TYPE gty_po,
        ls_ekbe TYPE gty_ekbe.

  DATA: lt_ped   LIKE STANDARD TABLE OF ls_ped,
        lt_ekbe  TYPE gtt_ekbe,
        lr_vgabe TYPE RANGE OF vgabe,
        lr_bewtp TYPE RANGE OF bewtp,
        lr_ebeln TYPE RANGE OF ebeln,
        ls_ebeln LIKE LINE OF lr_ebeln.


* Dejar un solo registro por pedido
  LOOP AT it_po INTO ls_po.
    ls_ped-ebeln = ls_po-ebeln.
    APPEND ls_ped TO lt_ped.
  ENDLOOP.

  SORT lt_ped BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_ped COMPARING ebeln.

  CHECK NOT lt_ped[] IS INITIAL.

  lr_vgabe = VALUE #( sign   = 'I'
                      option = 'EQ'
                      ( low    = '1' )
                      ( low    = '2' )
                     ).

  lr_bewtp = VALUE #( sign   = 'I'
                      option = 'EQ'
                      ( low    = 'E' )
                      ( low    = 'Q' )
                     ).

  ls_ebeln-sign   = 'I'.
  ls_ebeln-option = 'EQ'.
  LOOP AT lt_ped INTO ls_ped.
    ls_ebeln-low = ls_ped-ebeln.
    APPEND ls_ebeln TO lr_ebeln.
  ENDLOOP.

* No está funcionando la consulta en HDB con el FOR ALL ENTRIES, por eso
* se hace la consulta de esta forma
  SELECT FROM ekbe
    FIELDS ebeln,
           ebelp,
           bwart,
           vgabe,
           bewtp,
           xblnr,
           budat,
           matnr,
           menge,
           wrbtr,
           waers,
           belnr,
           gjahr,
           bldat
    WHERE ebeln IN @lr_ebeln        AND
          vgabe IN @lr_vgabe        AND
          bewtp IN @lr_bewtp
    ORDER BY ebeln,
             ebelp,
             vgabe,
             belnr
    INTO TABLE @lt_ekbe.

  IF sy-subrc = 0.
    ot_ekbe[] = lt_ekbe[].
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_REPORTE
*&---------------------------------------------------------------------*
FORM mostrar_reporte  TABLES it_sal TYPE gtt_sal.

  DATA: lv_repid TYPE syrepid.

  lv_repid = sy-repid.

  PERFORM cargar_fieldcat  TABLES gt_fieldcat.
  PERFORM cargar_layout    USING gs_layout.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = lv_repid
      i_callback_user_command = 'USER_COMMAND'
      i_structure_name        = 'IT_SAL'
      is_layout               = gs_layout
      it_fieldcat             = gt_fieldcat[]
      it_events               = gt_events[]
      i_save                  = gv_save
      is_variant              = gs_variant
    TABLES
      t_outtab                = it_sal.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  CARGAR_FIELDCAT
*&---------------------------------------------------------------------*
FORM cargar_fieldcat  TABLES ot_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: ls_fieldcat  TYPE slis_fieldcat_alv.

  DATA: lv_repid TYPE syrepid.

  lv_repid = sy-repid.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = lv_repid
      i_structure_name       = 'ZMM_RP_COMPRAS_ALV'
    CHANGING
      ct_fieldcat            = ot_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    CLEAR: ot_fieldcat[].
    RETURN.
  ENDIF.

  LOOP AT ot_fieldcat INTO ls_fieldcat.
    CASE ls_fieldcat-fieldname.
      WHEN 'BUKRS'.
*      ls_fieldcat-outputlen = '10'.
        ls_fieldcat-seltext_s = 'Filial'.
        ls_fieldcat-ddictxt   = 'S'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'STCD1'.
        ls_fieldcat-seltext_m = 'RUT Filial'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'EBELN'.
        ls_fieldcat-seltext_s = 'Número OC'.
        ls_fieldcat-ddictxt   = 'S'.
        ls_fieldcat-hotspot   = 'X'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'AEDAT'.
        ls_fieldcat-seltext_s = 'Fecha OC'.
        ls_fieldcat-ddictxt   = 'S'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'NAME1'.
        ls_fieldcat-seltext_m = 'Nombre proveedor'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'LIFNR'.
        ls_fieldcat-seltext_m = 'ID proveedor'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MATNR'.
        ls_fieldcat-seltext_m = 'Código producto'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MAKTX'.
        ls_fieldcat-seltext_m = 'Descripción producto'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MENGE'.
        ls_fieldcat-seltext_m = 'Cantidad producto'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MEINS'.
        ls_fieldcat-seltext_s = 'UM'.
        ls_fieldcat-ddictxt   = 'S'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'NETPR'.
        ls_fieldcat-seltext_m = 'Precio unitario'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'NETWR'.
        ls_fieldcat-seltext_m = 'Monto total'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'ERNAM'.
        ls_fieldcat-seltext_m = 'OC elaborada por'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'USUAP'.
        ls_fieldcat-seltext_m = 'OC aprobada por'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'DATAP'.
        ls_fieldcat-seltext_m = 'Fecha aprob. OC'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'ICOLIB'.
        ls_fieldcat-seltext_m = 'Lib.'.
        ls_fieldcat-just      = 'C'.
        ls_fieldcat-ddictxt   = 'M'.
        ls_fieldcat-hotspot   = 'X'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'LABST'.
        ls_fieldcat-seltext_m = 'Stock fecha OC'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'VERPR'.
        ls_fieldcat-seltext_m = 'Precio promedio'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'BWART'.
        ls_fieldcat-seltext_m = 'Tipo movimiento'.
        ls_fieldcat-ddictxt   = 'M'.
        ls_fieldcat-just      = 'C'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'BELNR_M'.
        ls_fieldcat-seltext_m = 'Doc. Material'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'XBLNR_M'.
        ls_fieldcat-seltext_m = 'Orden Recep.'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'BUDAT_M'.
        ls_fieldcat-seltext_m = 'Fec. Recep.'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MATNR_M'.
        ls_fieldcat-seltext_m = 'Cód. producto'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MAKTX_M'.
        ls_fieldcat-seltext_m = 'Desc. producto'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MENGE_MR'.
        ls_fieldcat-seltext_m = 'Cant.recibida'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MENGE_MD'.
        ls_fieldcat-seltext_m = 'Cant. anulada'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'WRBTR_M'.
        ls_fieldcat-seltext_m = 'Monto total'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'XBLNR_F'.
        ls_fieldcat-seltext_m = 'Nro. factura'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'BELNR_F'.
        ls_fieldcat-seltext_m = 'Doc.Fac.SAP'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'BLDAT_F'.
        ls_fieldcat-seltext_m = 'Fec. Fact.'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MAKTX_F'.
        ls_fieldcat-seltext_m = 'Cód. producto'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MAKTX_F'.
        ls_fieldcat-seltext_m = 'Desc. producto'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'MENGE_F'.
        ls_fieldcat-seltext_m = 'Cant. facturada'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'WRBTR_F'.
        ls_fieldcat-seltext_m = 'Monto total'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.
      WHEN 'STATU_F'.
        ls_fieldcat-seltext_m = 'Estado factura'.
        ls_fieldcat-ddictxt   = 'M'.
        MODIFY ot_fieldcat FROM ls_fieldcat.

    ENDCASE.
  ENDLOOP.

ENDFORM.                    " CARGAR_FIELDCAT


*&---------------------------------------------------------------------*
*&      Form  CARGAR_LAYOUT
*&---------------------------------------------------------------------*
FORM cargar_layout USING ls_layout TYPE slis_layout_alv.

  ls_layout-zebra                 = 'X'.
  ls_layout-colwidth_optimize     = ' '.
  ls_layout-box_fieldname         = space.
  ls_layout-no_input              = 'X'.
  ls_layout-no_vline              = ' '.
  ls_layout-no_colhead            = ' '.
  ls_layout-lights_condense       = 'X'.
* ls_layout-info_fieldname        = 'ALV_COLOR'.
* ls_layout-confirmation_prompt   = 'X'.
  ls_layout-detail_popup          = 'X'.
  ls_layout-detail_initial_lines  = 'X'.
  ls_layout-detail_titlebar       = sy-title.
* ls_layout-numc_sum              = 'X'.
  gs_layout-f2code                = 'DOBCLICK'.

ENDFORM.                    "CARGAR_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  GET_DATA_PO
*&---------------------------------------------------------------------*
FORM get_data_po  TABLES it_po TYPE gtt_po.

  SELECT FROM ekko      AS k
    INNER JOIN ekpo     AS p
    ON k~ebeln = p~ebeln
    INNER JOIN lfa1     AS l
    ON k~lifnr = l~lifnr
    LEFT JOIN mbew      AS w
    ON p~matnr = w~matnr AND
       p~werks = w~bwkey
    LEFT JOIN t001z     AS z
    ON k~bukrs = z~bukrs
    FIELDS k~ebeln,
           k~bedat,
           k~bukrs,
           k~lifnr,
           k~waers,
           k~ernam,
           k~aedat,
           p~ebelp,
           p~matnr,
           p~menge,
           p~meins,
           p~netpr,
           p~netwr,
           p~werks,
           p~txz01,
           p~pstyp,
           l~name1,
           w~verpr,
           z~paval
    WHERE k~ebeln IN @s_ebeln   AND
          k~bsart IN @s_bsart   AND
          k~bukrs IN @s_bukrs   AND
          k~bedat IN @s_bedat   AND
          k~lifnr IN @s_lifnr   AND
          p~werks IN @s_werks   AND
          p~matnr IN @s_matnr
    INTO TABLE @it_po.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  BUSCAR_LIBERADORES
*&---------------------------------------------------------------------*
FORM buscar_liberadores  TABLES it_po  TYPE gtt_po
                                ot_lib TYPE gtt_lib.

  DATA: BEGIN OF ls_ebeln,
          ebeln TYPE cdhdr-objectid,
        END OF ls_ebeln.

  DATA: ls_po    TYPE gty_po.
  DATA: lt_ebeln LIKE STANDARD TABLE OF ls_ebeln.
  DATA: lr_tcode TYPE RANGE OF sytcode.

* Dejar un solo registro por pedido
  LOOP AT it_po INTO ls_po.
    ls_ebeln-ebeln = ls_po-ebeln.
    APPEND ls_ebeln TO lt_ebeln.
  ENDLOOP.

  SORT lt_ebeln BY ebeln.
  DELETE ADJACENT DUPLICATES FROM lt_ebeln.

  CHECK NOT lt_ebeln IS INITIAL.

* Transacciones de modificación de liberación
  lr_tcode[] = VALUE #( sign   = 'I'
                        option = 'EQ'
                        ( low    = 'ZMM07')
                        ( low    = 'ME29N')
                        ( low    = 'ME28')
                      ).

* Búsqueda de liberadores
  SELECT FROM cdhdr
    FIELDS objectid,
           username,
           udate,
           utime
    FOR ALL ENTRIES IN @lt_ebeln
    WHERE objectclas  = 'EINKBELEG'     AND
          objectid    = @lt_ebeln-ebeln AND
          change_ind  = 'U'             AND
          tcode      IN @lr_tcode
    INTO TABLE @ot_lib.

  SORT ot_lib BY ebeln ASCENDING
                 udate DESCENDING
                 utime DESCENDING.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LIB
*&---------------------------------------------------------------------*
FORM display_lib  TABLES it_lib_sal TYPE gtt_lib.

  DATA: ls_private  TYPE slis_data_caller_exit,
        ls_fieldcat TYPE slis_fieldcat_alv.

  DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.

* Macro definition
  DEFINE m_fieldcat.
    ADD 1 TO ls_fieldcat-col_pos.
    ls_fieldcat-fieldname   = &1.
    ls_fieldcat-ref_tabname = &2.
    ls_fieldcat-outputlen   = &3.
    APPEND ls_fieldcat TO lt_fieldcat.
  END-OF-DEFINITION.


* Build the field catalog
  m_fieldcat 'EBELN'    'EKKO'  '12'.
  m_fieldcat 'USERNAME' 'CDHDR' '15'.
  m_fieldcat 'UDATE'    'CDHDR' '10'.
  m_fieldcat 'UTIME'    'CDHDR' '8'.

* Display the second list
*  ls_private-columnopt = 'X'.

  CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
    EXPORTING
      i_title                 = TEXT-t03   "Liberaciones efectuadas
      i_selection             = ' '
      i_tabname               = 'IT_LIB_SAL'
      it_fieldcat             = lt_fieldcat
      is_private              = ls_private
      i_callback_program      = sy-cprog
      i_callback_user_command = 'USER_COMMAND_LIB'
    TABLES
      t_outtab                = it_lib_sal.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  CAMPOS_POR_DEFECTO
*&---------------------------------------------------------------------*
FORM campos_por_defecto .

  DATA: lv_ini TYPE sy-datum,
        lv_fin TYPE sy-datum.


* Fechas
  lv_fin = sy-datum.
  lv_ini = '20190501'.

  s_bedat[] = VALUE #( ( sign   = 'I'
                         option = 'BT'
                         low    = lv_ini
                         high   = lv_fin
                       )
                   ).

* Centros
*  s_bukrs[] = VALUE #( sign   = 'I'
*                       option = 'EQ'
*                     ( low    = 'CL12' )
*                     ( low    = 'CL16' )
*                     ( low    = 'CL65' )
*                     ( low    = 'CL91' )
*                     ( low    = 'CL95' )
*                     ( low    = 'CL96' )
*                     ( low    = 'CL97' )
*                     ( low    = 'CL98' )
*                   ).

  s_bukrs[] = VALUE #( ( sign   = 'I'
                         option = 'BT'
                         low    = 'CL00'
                         high   = 'CL99'
                       )
                   ).


ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  VERIFICAR ACCESO
*&---------------------------------------------------------------------*
FORM verificar_acceso.

  AUTHORITY-CHECK OBJECT 'S_TCODE'
         ID 'TCD' FIELD gc_tcode.

  IF sy-subrc <> 0.
*   Falta autorización para transacción &
    MESSAGE i077(s#) WITH gc_tcode.
    LEAVE PROGRAM.
  ENDIF.

ENDFORM.      "verificar_acceso


*---------------------------------------------------------------------*
*       FORM F4_FOR_VARIANT                                           *
*---------------------------------------------------------------------*
FORM f4_for_variant.
*
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = gs_variant
      i_save     = gv_save
*     it_default_fieldcat =
    IMPORTING
      e_exit     = gv_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF gv_exit = space.
      p_vari = gx_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    "F4_FOR_VARIANT
