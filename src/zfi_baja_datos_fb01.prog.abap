*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Nombre Programa : ZFI_BAJA_DATOS_FB01
* Descripción     : Interfaz de cuentas de mayor.
*---------------------------------------------------------------------*
* Objetivo        :
*---------------------------------------------------------------------*
* Creado por      : VIsionOne
* Creado en fecha :
*---------------------------------------------------------------------*
REPORT  zfi_baja_datos_fb01 LINE-SIZE 250.

TABLES bkpf.

TYPE-POOLS: slis.
* ALV
DATA: g_repid             LIKE sy-repid,
      gt_events           TYPE slis_t_event,
      gs_variant          LIKE disvariant,
      gs_layout           TYPE slis_layout_alv,
      gt_fieldcat         TYPE slis_t_fieldcat_alv,
      gt_fieldcat_hor     TYPE lvc_t_fcat,
      gt_list_top_of_page TYPE slis_t_listheader,
      gt_list_top_of_dia  TYPE slis_t_listheader,
      g_top_of_page       TYPE slis_formname VALUE 'TOP_OF_PAGE'.

DATA: BEGIN OF t_reg_salida OCCURS 0,
* BKPF
          bukrs   LIKE bbkpf-bukrs,   "Soc
          belnr   LIKE bbkpf-belnr,   "N° Docto
          blart   LIKE bbkpf-blart,   "Clase doc
          waers   LIKE bbkpf-waers,   "Moneda
          kursf   LIKE bbkpf-kursf,   "T/C
          bldat   LIKE bbkpf-bldat,  "FECHA Docto
          budat   LIKE bbkpf-budat,  "FECHA Contab
          bktxt   LIKE bbkpf-bktxt,  "Texto Cab
          xblnr   LIKE bbkpf-xblnr,  "Referencia
*         xblnr2  LIKE bkpf-xref2_hd,
          xref2_hd LIKE bkpf-xref2_hd,
* BSEG
          newbs   LIKE bbseg-newbs, "Clave Contab
          newko   LIKE bbseg-newko, "hkont,
          wrbtr   LIKE bbseg-wrbtr,  "VALOR
          dmbtr   LIKE bbseg-dmbtr,  "VALOR
          dmbe2   LIKE bbseg-dmbe2,  "Importe moneda Loc 2
          dmbe3   LIKE bbseg-dmbe3,  "Importe moneda Loc 3
          zuonr   LIKE bbseg-zuonr,  "ASIGNACION
          valut   LIKE bbseg-valut,  "FECHA
          sgtxt   LIKE bbseg-sgtxt,  "texto
          kostl   LIKE bbseg-kostl,  "CeCo
          prctr   LIKE bbseg-prctr,  "CeBe
          aufnr   LIKE bbseg-aufnr,  "Num Orden
          projk   LIKE bbseg-projk,  "Proyecto.
          hkont   LIKE bbseg-hkont,  "Cuenta de mayor
          zfbdt   LIKE bbseg-zfbdt,  "Fecha Base
          newum   LIKE bbseg-newum,  "CME
          pprct   LIKE bbseg-pprct,  "CeBE
          mwskz   LIKE bbseg-mwskz,  "Indicador IVA
          gsber   LIKE bbseg-gsber,  "Division
          xref1   LIKE bbseg-xref1,  "Referencia 1
          xref2   LIKE bbseg-xref2,  "Referencia 2
          xref3   LIKE bbseg-xref3,  "Referencia 2
          zterm   LIKE bbseg-zterm,  "Cond.Pago
          zbd1t   LIKE bbseg-zbd1t,  "dias pago
          zlsch   LIKE bbseg-zlsch,   "via de Pago
          segment LIKE bbseg-segment, "Segmento
          lifnr   LIKE bseg-lifnr,    "Cta.Tercero
          hbkid   LIKE bbseg-hbkid,   "Bco.Propio
          hktid   LIKE bbseg-hktid,   "ID cuenta
          augbl   LIKE bseg-augbl,  "documento de compensacion
          zzprestac   LIKE bbseg-zzprestac,
          zzunid_pro  LIKE bbseg-zzunid_pro,
          zzdesc_est  LIKE bbseg-zzdesc_est,
          zzmot_emis  LIKE bbseg-zzmot_emis,
          zzrut_terc  LIKE bseg-zzrut_terc,
          zz_agencia  LIKE bseg-zz_agencia,
          stcd1 TYPE lfa1-stcd1, "Rut proveedor
          stcd2 TYPE kna1-stcd1, "Rut deudor
          kunnr TYPE kna1-kunnr, "Deudor
          rut_tercero type lfa1-stcd1, "Rut de terceros
      END OF t_reg_salida,

      BEGIN OF t_augbl OCCURS 0,
        bukrs LIKE bseg-bukrs,
        augbl LIKE bseg-augbl,
        zuonr LIKE bseg-zuonr,
      END OF t_augbl.


* Definición de Parámetros.
* -------------------------
SELECT-OPTIONS : s_bukrs FOR bkpf-bukrs,
                 s_gjahr FOR bkpf-gjahr,
                 s_cpudt FOR bkpf-cpudt.
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS : s_budat FOR bkpf-budat,
                 s_bldat FOR bkpf-bldat,
                 s_belnr FOR bkpf-belnr,
                 s_tcode FOR bkpf-tcode.
*
SELECTION-SCREEN SKIP 1.
PARAMETER: fichero TYPE string OBLIGATORY.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR fichero.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = fichero
      def_path         = 'c:\'
      mask             = ',*.*,*.*.'
      mode             = 'S'
      title            = 'Directorio de Datos'
    IMPORTING
      filename         = fichero
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

**---------------------------------------------------------------------
**- Inicio Programa Principal -----------------------------------------
**---------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM lee_datos.
  PERFORM muestra_datos.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA : t_bkpf LIKE bkpf OCCURS 0 WITH HEADER LINE,
         t_bseg LIKE bseg OCCURS 0 WITH HEADER LINE.
*
  REFRESH t_augbl.

  TYPES: BEGIN OF t_bsak,
          belnr TYPE bsak-belnr,
          gjahr TYPE bsak-gjahr,
          xblnr TYPE bsak-xblnr,
         END OF t_bsak.

  DATA: ti_bsak TYPE TABLE OF t_bsak,
        wa_bsak TYPE t_bsak.

  SELECT * INTO TABLE t_bkpf
        FROM bkpf WHERE bukrs IN s_bukrs AND
                        gjahr IN s_gjahr AND
                        cpudt IN s_cpudt AND
                        budat IN s_budat AND
                        bldat IN s_bldat AND
                        belnr IN s_belnr AND
                        tcode IN s_tcode.
  IF sy-subrc EQ 0.
SELECT * INTO TABLE t_bseg
FROM bseg FOR ALL ENTRIES IN t_bkpf
WHERE bukrs EQ t_bkpf-bukrs AND
belnr EQ t_bkpf-belnr AND
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*gjahr EQ t_bkpf-gjahr.
GJAHR EQ T_BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
* DATOS DE CABECERA
    LOOP AT t_bkpf.
* DATOS DE POSICION
      LOOP AT t_bseg WHERE bukrs EQ t_bkpf-bukrs  AND
                           belnr EQ t_bkpf-belnr  AND
                           gjahr EQ t_bkpf-gjahr.
*
        MOVE : t_bkpf-bukrs  TO t_reg_salida-bukrs,
               t_bkpf-belnr  TO t_reg_salida-belnr,
               t_bkpf-blart  TO t_reg_salida-blart,
               t_bkpf-waers  TO t_reg_salida-waers,
               t_bkpf-kursf  TO t_reg_salida-kursf,
               t_bkpf-bktxt  TO t_reg_salida-bktxt,
               t_bkpf-xblnr  TO t_reg_salida-xblnr,
               t_bkpf-bldat  TO t_reg_salida-bldat,
               t_bkpf-budat  TO t_reg_salida-budat,
               t_bkpf-xref2_hd TO t_reg_salida-xref2_hd.

        IF t_bkpf-kursf EQ 0.
          CLEAR t_reg_salida-kursf.
        ENDIF.
*
        IF t_bseg-sgtxt IS INITIAL.
          WRITE sy-datum TO t_bseg-sgtxt.
        ENDIF.
*
        CASE t_bseg-koart.
          WHEN 'K'.  MOVE t_bseg-lifnr   TO t_reg_salida-newko.
          WHEN 'D'.  MOVE t_bseg-kunnr   TO t_reg_salida-newko.
          WHEN 'M'.  MOVE t_bseg-matnr   TO t_reg_salida-newko.
          WHEN 'A'.  MOVE t_bseg-aufnr   TO t_reg_salida-newko.
          WHEN 'S'.  MOVE t_bseg-hkont   TO t_reg_salida-newko.
        ENDCASE.
*
        MOVE : t_bseg-augbl   TO t_reg_salida-augbl,
               t_bseg-bschl   TO t_reg_salida-newbs ,
               t_bseg-zuonr   TO t_reg_salida-zuonr,
               t_bseg-sgtxt   TO t_reg_salida-sgtxt,
               t_bseg-kostl   TO t_reg_salida-kostl,
               t_bseg-prctr   TO t_reg_salida-prctr,
               t_bseg-aufnr   TO t_reg_salida-aufnr,
               t_bseg-projk   TO t_reg_salida-projk ,
               t_bseg-hkont   TO t_reg_salida-hkont,
               t_bseg-umskz   TO t_reg_salida-newum,
               t_bseg-pprct   TO t_reg_salida-pprct,
               t_bseg-mwskz   TO t_reg_salida-mwskz,
               t_bseg-gsber   TO t_reg_salida-gsber,
               t_bseg-xref1   TO t_reg_salida-xref1,
               t_bseg-xref1   TO t_reg_salida-xref2,
               t_bseg-zterm   TO t_reg_salida-zterm,
               t_bseg-zbd1t   TO t_reg_salida-zbd1t,
               t_bseg-segment TO t_reg_salida-segment,
               t_bseg-lifnr   TO t_reg_salida-lifnr,
               t_bseg-hbkid   TO t_reg_salida-hbkid,
               t_bseg-hktid   TO t_reg_salida-hktid,     "RVY
               t_bseg-zlsch   TO t_reg_salida-zlsch,
               t_bseg-zzprestac   TO t_reg_salida-zzprestac,
               t_bseg-zzunid_pro  TO t_reg_salida-zzunid_pro,
               t_bseg-zzdesc_est  TO t_reg_salida-zzdesc_est,
               t_bseg-zzmot_emis  TO t_reg_salida-zzmot_emis,
               t_bseg-zzrut_terc  TO t_reg_salida-zzrut_terc,
               t_bseg-zz_agencia  TO t_reg_salida-zz_agencia,
               t_bseg-kunnr       TO t_reg_salida-kunnr.
*
        IF NOT t_bseg-lifnr IS INITIAL.
          SELECT SINGLE stcd1
            INTO t_reg_salida-stcd1 "Rut proveedor
            FROM lfa1
            WHERE lifnr = t_reg_salida-lifnr.
        ENDIF.

        IF NOT t_bseg-kunnr IS INITIAL.
          SELECT SINGLE stcd1
          INTO t_reg_salida-stcd2 "Rut deudor
          FROM kna1
          WHERE kunnr = t_bseg-kunnr.
        ENDIF.

        if not t_bseg-zzrut_terc is INITIAL.
          SELECT SINGLE stcd1
          INTO t_reg_salida-rut_tercero "Rut de terceros
          FROM lfa1
          WHERE lifnr = t_bseg-zzrut_terc.
        endif.

        IF t_bseg-zfbdt IS NOT INITIAL.
          MOVE t_bseg-zfbdt   TO t_reg_salida-zfbdt.
        ENDIF.
*
        IF t_bseg-valut IS NOT INITIAL.
          MOVE t_bseg-valut   TO t_reg_salida-valut.
        ENDIF.
*
        IF t_reg_salida-bukrs EQ 'CL35' AND
           t_reg_salida-hkont EQ '1011920072' AND
           ( t_reg_salida-kunnr EQ '0000010025' OR
             t_reg_salida-kunnr EQ '0000010029' ).
          t_reg_salida-hkont = '1012110001'."cta relacionada
          "intercompany
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = t_bseg-projk
          IMPORTING
            output = t_bseg-projk.
        IF t_bseg-projk EQ '0'.
          CLEAR t_reg_salida-projk .
        ENDIF.

***Documento de compensación
        REFRESH ti_bsak.
        IF t_bseg-belnr EQ t_bseg-augbl.
**MOD INI
          SELECT belnr gjahr xblnr
            INTO TABLE ti_bsak
            FROM bsak
            WHERE bukrs EQ t_bseg-bukrs
              AND lifnr EQ t_bseg-lifnr
              AND augbl EQ t_bseg-augbl
              AND augdt EQ t_bseg-augdt
              AND belnr NE t_bseg-augbl
            ORDER BY belnr gjahr xblnr.
*MOD FIN
          IF sy-subrc EQ 0.
            CLEAR: t_reg_salida-xblnr, t_reg_salida-sgtxt.
            READ TABLE ti_bsak INTO wa_bsak INDEX 1.
            t_reg_salida-xblnr = wa_bsak-xblnr.
            t_reg_salida-sgtxt = wa_bsak-xblnr.

            LOOP AT ti_bsak INTO wa_bsak FROM 2.
              CONCATENATE t_reg_salida-sgtxt wa_bsak-xblnr
              INTO t_reg_salida-sgtxt SEPARATED BY '/'.
            ENDLOOP.
          ENDIF.
        ENDIF.
* VALORES
        WRITE t_bseg-wrbtr CURRENCY t_bkpf-waers TO t_reg_salida-wrbtr.
        WRITE t_bseg-dmbtr CURRENCY t_bkpf-waers TO t_reg_salida-dmbtr.
        WRITE t_bseg-dmbe2 CURRENCY 'USD'        TO t_reg_salida-dmbe2.
        WRITE t_bseg-dmbe3 CURRENCY t_bkpf-waers TO t_reg_salida-dmbe3.
*
        IF t_reg_salida-zuonr IS INITIAL.
          t_reg_salida-zuonr = '.'.
        ENDIF.

        IF t_reg_salida-sgtxt IS INITIAL.
          t_reg_salida-sgtxt = '.'.
        ENDIF.

***Caso Intercompany
        IF NOT t_bkpf-bvorg IS INITIAL. "Multisociedad
           t_reg_salida-augbl = t_bkpf-belnr.
        ENDIF.
        APPEND t_reg_salida.
        CLEAR t_reg_salida.
      ENDLOOP.
    ENDLOOP.
  ELSE.
    MESSAGE e899(fi) WITH 'NO HA DATOS DE LECTURA'.
  ENDIF.
*

ENDFORM.                    " LEE_DATO
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos.
*
  g_repid               = sy-repid.
  gs_variant-report     = g_repid.
  gs_variant-username   = sy-uname.
*
  PERFORM layout_init     USING gs_layout.
  PERFORM eventtab_build  USING gt_events[] g_top_of_page.
  PERFORM comment_build   USING gt_list_top_of_page[].
  PERFORM fieldcat        USING gt_fieldcat[].
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_program       = g_repid
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
      i_save                   = 'A'
      is_variant               = gs_variant
      it_events                = gt_events[]
    TABLES
      t_outtab                 = t_reg_salida
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc NE 0.
  ENDIF.
ENDFORM.                    "MUESTRA_DATOS
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm TYPE sy-ucomm
                        rs_selfield TYPE slis_selfield.
*
  CASE r_ucomm.
    WHEN 'FC01'.
      PERFORM baja_archivo.
  ENDCASE.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.
  DATA : fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE.
*
  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
*
  fcode_attrib_tab-text      = 'Baja datos'.
  fcode_attrib_tab-icon_id   = '@01@'.
  fcode_attrib_tab-icon_text = 'Baja datos'.
  fcode_attrib_tab-quickinfo = space.
  fcode_attrib_tab-path      = space.
  APPEND fcode_attrib_tab.

  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  BAJA_ARCHIVO
*&---------------------------------------------------------------------*
FORM baja_archivo .

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                        = fichero
*     FILETYPE                        = 'ASC'
      write_field_separator           = 'X'
*   IMPORTING
*     FILELENGTH                      =
    TABLES
      data_tab                        = t_reg_salida
   EXCEPTIONS
     file_write_error                = 1
     no_batch                        = 2
     gui_refuse_filetransfer         = 3
     invalid_type                    = 4
     no_authority                    = 5
     unknown_error                   = 6
     header_not_allowed              = 7
     separator_not_allowed           = 8
     filesize_not_allowed            = 9
     header_too_long                 = 10
     dp_error_create                 = 11
     dp_error_send                   = 12
     dp_error_write                  = 13
     unknown_dp_error                = 14
     access_denied                   = 15
     dp_out_of_memory                = 16
     disk_full                       = 17
     dp_timeout                      = 18
     file_not_found                  = 19
     dataprovider_exception          = 20
     control_flush_error             = 21
     OTHERS                          = 22 .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " BAJA_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.
*"Build layout for list display
  rs_layout-f2code               = 'DISPLAY'.
  rs_layout-zebra                = 'X'.
  rs_layout-detail_popup         = 'X'.
  rs_layout-detail_initial_lines = 'X'.
  rs_layout-colwidth_optimize    = 'X'.
  rs_layout-coltab_fieldname     = 'TABCOLOR'.
ENDFORM.                    " LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
FORM eventtab_build USING rt_events TYPE slis_t_event
                          p_g_top_of_page.
*"Registration of events to happen during list display
  DATA: ls_event TYPE slis_alv_event.
*
  REFRESH rt_events.
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE p_g_top_of_page TO ls_event-form.
    APPEND ls_event      TO rt_events.
  ENDIF.
ENDFORM.                    " EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM comment_build USING lt_top_of_page TYPE slis_t_listheader.
  DATA: ls_line     TYPE slis_listheader,
        l_fecha_ini TYPE char10,
        l_fecha_fin TYPE char10.
*
  REFRESH lt_top_of_page.
  CLEAR   lt_top_of_page.
*
* LIST HEADING LINE: TYPE H
  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = text-010.
  APPEND ls_line TO lt_top_of_page.
*  STATUS LINE: TYPE S
  CLEAR ls_line-info.
  ls_line-typ  = 'S'.
  ls_line-key  = text-011.
  WRITE sy-datum TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.
*  STATUS LINE: TYPE S
  CLEAR ls_line-info.
  ls_line-typ  = 'S'.
  ls_line-key  = text-012.
  WRITE sy-uzeit TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.
ENDFORM.                    " COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT
*&---------------------------------------------------------------------*
FORM fieldcat USING pt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat      TYPE slis_fieldcat_alv,
        gt_fieldcat_p    TYPE slis_t_fieldcat_alv,
        ls_fieldcat_hor  TYPE lvc_s_fcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
       i_program_name      = g_repid
       i_internal_tabname  = 'T_REG_SALIDA'
       i_inclname          = g_repid
*      i_structure_name       = 'ZEFI_REPORTE_DET'
    CHANGING
      ct_fieldcat            = pt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc NE 0.
  ENDIF.

*
*  LOOP AT pt_fieldcat INTO ls_fieldcat.
*    ls_fieldcat-ddictxt = 'M'.
*    CASE ls_fieldcat-fieldname.
*      WHEN 'BLDAT'.
*        ls_fieldcat-seltext_m     = 'Fecha documento'.
*        ls_fieldcat-ref_fieldname = 'BLDAT'.
*        ls_fieldcat-ref_tabname   = 'BSEG'.
*      WHEN 'BUDAT'.
*        ls_fieldcat-seltext_m     = 'Fecha contable'.
*        ls_fieldcat-ref_fieldname = 'BUDAT'.
*        ls_fieldcat-ref_tabname   = 'BSEG'.
*      WHEN 'WRBTR'.
*        ls_fieldcat-seltext_m     = 'Monto WRBTR'.
*        ls_fieldcat-ref_fieldname = 'WRBTR'.
*        ls_fieldcat-ref_tabname   = 'BSEG'.
*      WHEN 'DMBTR'.
*        ls_fieldcat-seltext_m     = 'Monto DMBTR'.
*        ls_fieldcat-ref_fieldname = 'DMBTR'.
*        ls_fieldcat-ref_tabname   = 'BSEG'.
*      WHEN 'VALUT'.
*        ls_fieldcat-seltext_m     = 'Monto VALUT'.
*        ls_fieldcat-ref_fieldname = 'VALUT'.
*        ls_fieldcat-ref_tabname   = 'BSEG'.
*      WHEN 'ZFBDT'.
*        ls_fieldcat-seltext_m     = 'Monto ZFBDT'.
*        ls_fieldcat-ref_fieldname = 'ZFBDT'.
*        ls_fieldcat-ref_tabname   = 'BSEG'.
*    ENDCASE.
*    MODIFY pt_fieldcat FROM ls_fieldcat.
*  ENDLOOP.
ENDFORM.                    " FIELDCAT
