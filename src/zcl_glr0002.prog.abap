*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*$*$********************************************************************
*$*$                                                                   *
*$*$ PROGRAMAM  : ZCL_GLR0002                                          *
*$*$ DESCRIPCION: Libro de Ventas                                      *
*$*$                                                                   *
*$*$ AUTOR      : VisioOne.                                            *
*$*$                                                                   *
*$*$ DATA    : 10/11/2011.                                             *
*$*$                                                                   *
*$*$********************************************************************
*$*$                   HISTORIAL DE MODIFICACIONES                     *
*$*$-------------------------------------------------------------------*
*$*$ DATA     | AUTOR          | DESCRIPCION                           *
*$*$-------------------------------------------------------------------*
*$*$ 21.03.14 | VisionOne (RVY)| Se elimiman los documentos nulos del  *
*$*$          |                | archivo que se genera para el SII..   *
*$*$-------------------------------------------------------------------*
*$*$ 06.06.14 | VisionOne (RVY)| se le saca el sigo a los montos nega- *
*$*$          |                | tivos en el archivo que se genera para*
*$*$          |                | el SII..                              *
*$*$-------------------------------------------------------------------*
*$*$********************************************************************
REPORT zcl_glr0002 LINE-SIZE 255 LINE-COUNT 60
MESSAGE-ID zc NO STANDARD PAGE HEADING.

TABLES: kna1, bkpf, bseg, bset, t001, t003t, vbrk , vbrp, vbpa, adrc,
        vbpa3, usr01, itcpo,idcn_loma, zdatsocelec.

DATA ls TYPE i.
DATA l  TYPE i.
DATA str_tot_exe     TYPE string.
DATA str_tot_net     TYPE string.
DATA str_tot_iva     TYPE string.
DATA str_iva_fp      TYPE string.
DATA str_tot_mnt_tot TYPE string.
DATA str_mnt_imp_rec TYPE string.
DATA str_mnt_imp_rec2 TYPE string.
DATA str_mnt_imp_rec3 TYPE string.
DATA str_mnt_imp_rec4 TYPE string.
TABLES vbfa.
DATA: BEGIN OF it_tabla OCCURS 0,
        line(4096) TYPE c,
      END OF it_tabla.
DATA str1 TYPE string.
DATA str2 TYPE string.
DATA: BEGIN OF detalle OCCURS 0,
        tip_doc	      TYPE c LENGTH 2,
        sep1          TYPE c LENGTH 1 VALUE '|',
        folio        	TYPE c LENGTH 10,
        sep2          TYPE c LENGTH 1 VALUE '|',
        nulo          TYPE c LENGTH 1,
        sep3          TYPE c LENGTH 1 VALUE '|',
        oper          TYPE c LENGTH 1,
        sep4          TYPE c LENGTH 1 VALUE '|',
        tas_iva       TYPE c LENGTH 5,
        sep5          TYPE c LENGTH 1 VALUE '|',
        num_int       TYPE c LENGTH 10,
        sep6          TYPE c LENGTH 1 VALUE '|',
        fec_emis      TYPE c LENGTH 10,
        sep7          TYPE c LENGTH 1 VALUE '|',
        suc           TYPE c LENGTH 8,
        sep8          TYPE c LENGTH 1 VALUE '|',
        rut_rec       TYPE c LENGTH 10,
        sep9          TYPE c LENGTH 1 VALUE '|',
        raz_soc       TYPE c LENGTH 50,
        sep10         TYPE c LENGTH 1 VALUE '|',
        tip_doc_ref   TYPE c LENGTH 3,
        sep11         TYPE c LENGTH 1 VALUE '|',
        folio_doc_ref TYPE c LENGTH 18,
        sep12         TYPE c LENGTH 1 VALUE '|',
        mnt_exe       TYPE c LENGTH 18,
        sep13         TYPE c LENGTH 1 VALUE '|',
        mnt_neto      TYPE c LENGTH 18,
        sep14         TYPE c LENGTH 1 VALUE '|',
        mnt_iva       TYPE c LENGTH 18,
        sep15         TYPE c LENGTH 1 VALUE '|',
        iva_fp        TYPE c LENGTH 18,
        sep16         TYPE c LENGTH 1 VALUE '|',
        mnt_tot       TYPE c LENGTH 18,
        sep17         TYPE c LENGTH 1 VALUE '|',
        cod_imp_rec   TYPE c LENGTH 3,
        sep18         TYPE c LENGTH 1 VALUE '|',
        tasa_imp_rec  TYPE c LENGTH 5,
        sep19         TYPE c LENGTH 1 VALUE '|',
        mnt_imp_rec   TYPE c LENGTH 18,
        sep20         TYPE c LENGTH 1 VALUE '|',
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
        vertn         TYPE c LENGTH 13,
        sep21         TYPE c LENGTH 1 VALUE '|',
        vertt         TYPE c LENGTH 2,
        sep22         TYPE c LENGTH 1 VALUE '|',
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
        fr            TYPE c LENGTH 1 VALUE '}',
      END OF detalle.
DATA str_file TYPE string.
DATA: BEGIN OF resumen1 OCCURS 0,
        rut_con	    TYPE zrut_con,
        sep1        TYPE c LENGTH 1 VALUE '|',
        rut_env     TYPE zrut_envia,
        sep2        TYPE c LENGTH 1 VALUE '|',
        per_trib    TYPE c LENGTH 7,
        sep3        TYPE c LENGTH 1 VALUE '|',
        fec_res	    TYPE c LENGTH 10,
        sep4        TYPE c LENGTH 1 VALUE '|',
        num_res	    TYPE c LENGTH 6,
        sep5        TYPE c LENGTH 1 VALUE '|',
        tip_ope     TYPE ztip_oper,
        sep6        TYPE c LENGTH 1 VALUE '|',
        tip_lib     TYPE ztip_lib,
        sep7        TYPE c LENGTH 1 VALUE '|',
        tip_env	    TYPE c LENGTH 7,
        sep8        TYPE c LENGTH 1 VALUE '|',
        fol_not	    TYPE c LENGTH 10,
        sep9        TYPE c LENGTH 1 VALUE '|',
        cod_aut_rec TYPE c LENGTH 10,
        sep10       TYPE c LENGTH 1 VALUE '|',
        fr          TYPE c LENGTH 1 VALUE '}',
      END OF resumen1.

DATA: BEGIN OF resumen2 OCCURS 0,
        tip_doc	     TYPE char03,
        sep1         TYPE c LENGTH 1 VALUE '|',
        can_doc	     TYPE i,
        sep2         TYPE c LENGTH 1 VALUE '|',
        can_doc_anul TYPE i,
        sep3         TYPE c LENGTH 1 VALUE '|',
        tot_exe	     TYPE p DECIMALS 0,
        sep4         TYPE c LENGTH 1 VALUE '|',
        tot_net	     TYPE p DECIMALS 0,
        sep5         TYPE c LENGTH 1 VALUE '|',
        tot_iva	     TYPE p DECIMALS 0,
        sep6         TYPE c LENGTH 1 VALUE '|',
        iva_fp       TYPE p DECIMALS 0,
        sep7         TYPE c LENGTH 1 VALUE '|',
        tot_mnt_tot  TYPE p DECIMALS 0,
        sep8         TYPE c LENGTH 1 VALUE '|',
        cod_imp_rec  TYPE c LENGTH 18,
        sep9         TYPE c LENGTH 1 VALUE '|',
        mnt_imp_rec  TYPE p DECIMALS 0,
        sep10        TYPE c LENGTH 1 VALUE '|',
        cod_imp_rec2 TYPE c LENGTH 18,
        sep11        TYPE c LENGTH 1 VALUE '|',
        mnt_imp_rec2 TYPE p DECIMALS 0,
        sep12        TYPE c LENGTH 1 VALUE '|',
        cod_imp_rec3 TYPE c LENGTH 18,
        sep13        TYPE c LENGTH 1 VALUE '|',
        mnt_imp_rec3 TYPE p DECIMALS 0,
        sep14        TYPE c LENGTH 1 VALUE '|',
        fr           TYPE c LENGTH 1 VALUE '}',
      END OF resumen2.
DATA: swerror  TYPE i.

DATA: BEGIN OF reg_tabla,
        bukrs            LIKE bkpf-bukrs,
        budat            LIKE bkpf-budat,
        tipo             TYPE c LENGTH 1,
        werks            LIKE vbrp-werks,        "Oficina de Ventas
        orig             TYPE c LENGTH 1,
        blart            LIKE bkpf-blart,
        bldat            LIKE bkpf-bldat,
        xblnr            LIKE bkpf-xblnr,
        veces            TYPE i,
        belnr            LIKE bkpf-belnr,
        name1            LIKE kna1-name1,
        name2            LIKE kna1-name2,
        stcd1            LIKE kna1-stcd1,
        waers            LIKE bkpf-waers,
        exent            LIKE bseg-dmbtr,
        exent_mt         LIKE bseg-dmbtr,
        afect            LIKE bseg-dmbtr,
        fepp             LIKE bseg-dmbtr,
        impue            LIKE bseg-dmbtr,
        impue-5          LIKE bseg-dmbtr,
        comaf            LIKE bseg-dmbtr,
*        COMEX            LIKE BSEG-DMBTR,
        totdoc           LIKE bseg-dmbtr,
        totdoc_mt        LIKE bseg-dmbtr,
        vbeln            LIKE vbrk-vbeln, "Nro.Ori SD para ver anulac.
        anul             TYPE c LENGTH 1,
        zero             TYPE c LENGTH 1,
        altext           LIKE t003t-ltext,
        bole             TYPE c LENGTH 1,
        docfi            TYPE c LENGTH 2,
        mwskz            LIKE bseg-mwskz,
        bktxt            LIKE bkpf-bktxt,
        stblg            LIKE bkpf-stblg,
        fkart            LIKE vbrk-fkart,
        propina          LIKE bseg-dmbtr,   "propinas
        exporta          LIKE bseg-dmbtr,   "expotaciones
        zrut_cli_pagador LIKE zfac_anex-zrut_cli_pagador,
        znom_cli_fact    LIKE zfac_anex-znom_cli_fact,
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
        vertn            TYPE ranl,
        vertt            TYPE rantyp,
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
      END   OF reg_tabla.

DATA: tabla     LIKE reg_tabla OCCURS 1000 WITH HEADER LINE.
DATA: tabla_res LIKE reg_tabla OCCURS 1000 WITH HEADER LINE.
DATA: tabla_aux LIKE reg_tabla OCCURS 1000 WITH HEADER LINE.
DATA: tabla_acu LIKE reg_tabla.
DATA: e_tabla   LIKE reg_tabla.
*
DATA: BEGIN OF reg_salida,
        blart  LIKE bkpf-blart,
        bldat  LIKE bkpf-bldat,
        belnr  LIKE bkpf-belnr,
        xblnr  LIKE bkpf-xblnr,
*        VECES    TYPE I,
        anul   TYPE c LENGTH 1,
        budat  LIKE bkpf-budat,
        stcd1  LIKE kna1-stcd1,
        name1  LIKE kna1-name1,
        afect  LIKE bseg-dmbtr,   "afecto
        exent  LIKE bseg-dmbtr,   "exento
        impue  LIKE bseg-dmbtr,   "iva
        totdoc LIKE bseg-dmbtr,   "total
        waers  LIKE bkpf-waers,
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
        vertn  TYPE ranl,
        vertt  TYPE rantyp,
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
      END OF reg_salida.
DATA : budat_aux     LIKE  bkpf-budat.
DATA : blart_aux     LIKE  bkpf-blart.
DATA : xblnr_rea     LIKE  bkpf-xblnr.
DATA : xblnr_aux(16) TYPE  c.
DATA : xblnr_tab(16) TYPE  c.
DATA : etabla_aux    LIKE tabla_aux.
DATA : etabla        LIKE tabla.
*
DATA : l_tabix LIKE sy-tabix,
       x_tabix LIKE sy-tabix,
       l_sem,
       val1    LIKE xblnr_aux,
       val2    LIKE xblnr_aux.
*
DATA t_salida     LIKE reg_salida OCCURS 1000 WITH HEADER LINE.
DATA t_salida_aux LIKE reg_salida OCCURS 1000 WITH HEADER LINE.

TYPE-POOLS slis.
DATA xt_fieldcat    TYPE slis_t_fieldcat_alv.
DATA: gs_layout           TYPE slis_layout_alv,
      lt_events           TYPE slis_t_event,
      ls_fieldcat         TYPE slis_fieldcat_alv,
      gt_fieldcat         TYPE slis_t_fieldcat_alv,
      gs_keyinfo          TYPE slis_keyinfo_alv,
      g_repid             LIKE sy-repid,
      g_variante          LIKE disvariant-variant,
      gs_print            TYPE slis_print_alv,
      gt_sort             TYPE slis_t_sortinfo_alv,
      gt_sp_group         TYPE slis_t_sp_group_alv,
      gt_list_top_of_page TYPE slis_t_listheader,
      g_expande           TYPE c,
      ws-bkpf-blart       LIKE bkpf-blart,
      l_cuenta            TYPE sy-tabix.

DATA: BEGIN OF tb_anuladas OCCURS 1000,
        bukrs LIKE bkpf-bukrs,
        vbeln LIKE vbrk-vbeln,
        xblnr LIKE bkpf-xblnr,
        blart LIKE bkpf-blart,
      END OF tb_anuladas.

DATA: bukrs_ant         LIKE bkpf-bukrs,
      v_anulada         LIKE vbrk-sfakn,
      ws-xblnr          LIKE bkpf-xblnr,
      v_werks           LIKE vbrp-werks,
      doc-nulos(5)      TYPE n,
      var-aux-xblnr(10) TYPE n,
      ws-primer(2)      TYPE c,
      v_tipo(1)         TYPE c,
      doc_zero(1)       TYPE c,
      n_bset            TYPE i,
      xbseg             LIKE bseg,
      origen_exp(1)     TYPE c VALUE '2',         "Exportaciones,
      origen_nac(1)     TYPE c VALUE '1',         "Nacional
*      V_BLART_FACT      LIKE BKPF-BLART VALUE 'RV',
*      V_BLART_FACT2     LIKE BKPF-BLART VALUE 'DR',
*      V_BLART_NCRE      LIKE BKPF-BLART VALUE 'RG',
*      V_BLART_NDEB      LIKE BKPF-BLART VALUE 'RD',
*      V_BLART_BOLE      LIKE BKPF-BLART VALUE 'BV',}
      v_blart_fact      LIKE bkpf-blart, " VALUE 'G3' or 'G1',
      v_blart_fact2     LIKE bkpf-blart, " VALUE 'G4', 'G2',
      v_blart_ncre      LIKE bkpf-blart, " VALUE 'J1', 'J2', 'J3', 'J4',
      v_blart_ndeb      LIKE bkpf-blart, " VALUE 'L1', 'L2', 'L3', 'L4',
      v_blart_bole      LIKE bkpf-blart, " VALUE 'O1', 'O2', 'O3', 'O4',

      v_text_fact       LIKE t003t-ltext,
      v_text_ncre       LIKE t003t-ltext,
      v_text_ndeb       LIKE t003t-ltext,
      v_text_bole       LIKE t003t-ltext,
      v_exent           LIKE bseg-mwskz VALUE '02',    "Exento
      v_hkont_mtr       LIKE bseg-hkont VALUE '0011153010',
      v_hkont_fep       LIKE bseg-hkont VALUE '0001135003',
      v_hkont_bol       LIKE bseg-hkont VALUE '0011114010',
      v_hkont_tgm       LIKE bseg-hkont VALUE '0011114015',
      v_hkont_aju       LIKE bseg-hkont VALUE '0021201511',
      v_hkont_dem       LIKE bseg-hkont VALUE '0011153020',
      v_hkont_pro       LIKE bseg-hkont VALUE '0021201010',
      v_prodh           LIKE vbrp-prodh VALUE '0000300017',
      v_matnr           LIKE bseg-matnr,
      p_sem.

RANGES: p_fact FOR bkpf-blart,
        p_fact2 FOR bkpf-blart,
        p_ncre FOR bkpf-blart,
        p_ndeb FOR bkpf-blart,
        p_bole FOR bkpf-blart.

DATA: zlinea(5) TYPE n,
      ok_reg    TYPE boolean.
DATA: p_soc(40),
      p_direc(40),
      p_rut(12).
* Defenir variables para chequeo de BLART (Tipo documento)
DATA: BEGIN OF blart_now OCCURS 0,
        sign(1),
        option(2),
        low       LIKE bkpf-blart,
        high      LIKE bkpf-blart,
      END OF blart_now.

DATA: blart_out LIKE blart_now OCCURS 0 WITH HEADER LINE.
* Defenir variables chequeo MWSKZ (Indicador IVA [exento / afecto])
DATA: BEGIN OF mwskz_exe OCCURS 0,
        sign(1),
        option(2),
        low       LIKE bseg-mwskz,
        high      LIKE bseg-mwskz,
      END OF mwskz_exe.
DATA: mwskz_afe LIKE mwskz_exe OCCURS 0 WITH HEADER LINE.

*paid out en vbrp-matnr {
DATA: BEGIN OF tb_pospo OCCURS 0,
        posnr LIKE vbrp-posnr,
      END OF tb_pospo.
DATA: l_swenc(1).
*paid out en vbrp-matnr }

DEFINE fill_range.
  &1-sign = 'I'.
  &1-option = 'EQ'.
  &1-low = &2.
  APPEND &1.

END-OF-DEFINITION.

DATA: BEGIN OF res_ventas OCCURS 0,
        blart    LIKE bkpf-blart,
        nomb(20),
** Begin:V1 21.03.2014
*        nro(5)   TYPE n,
        nro(6)   TYPE n,
** End:  V1 21.03.2014
        afect    LIKE bseg-dmbtr,
        exent    LIKE bseg-dmbtr,
        impue    LIKE bseg-dmbtr,
        impue-5  LIKE bseg-dmbtr,
        totdoc   LIKE bseg-dmbtr,
        propina  LIKE bseg-dmbtr,
        exporta  LIKE bseg-dmbtr,
        nulos(5) TYPE n,
      END OF res_ventas.

DATA: tot-inf-afect   LIKE bseg-dmbtr,
      tot-inf-exent   LIKE bseg-dmbtr,
      tot-inf-impue   LIKE bseg-dmbtr,
      tot-inf-impue-5 LIKE bseg-dmbtr,
      tot-inf-propina LIKE bseg-dmbtr,
      tot-inf-exporta LIKE bseg-dmbtr,
      tot-inf-totdoc  LIKE bseg-dmbtr.

DEFINE fill_res.
  res_ventas-blart = &1.
  res_ventas-nomb  = &2.
  APPEND res_ventas.
END-OF-DEFINITION.

SELECTION-SCREEN BEGIN OF BLOCK zc_0 WITH FRAME TITLE TEXT-000.
SELECT-OPTIONS so_fac FOR bkpf-blart.
SELECT-OPTIONS so_nc  FOR bkpf-blart.
SELECT-OPTIONS so_nd  FOR bkpf-blart.
SELECT-OPTIONS so_bol FOR bkpf-blart.
SELECTION-SCREEN END OF BLOCK zc_0.

SELECTION-SCREEN BEGIN OF BLOCK zc_1 WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) TEXT-mes.
PARAMETERS: p_monat LIKE bkpf-monat OBLIGATORY DEFAULT sy-datum+4(2),
            p_gjahr LIKE bkpf-gjahr OBLIGATORY DEFAULT sy-datum+0(4).
SELECTION-SCREEN END OF LINE.
* SELECT-OPTIONS : P_WERKS FOR VBRP-WERKS NO Display.
PARAMETERS     : p_def(1) TYPE c NO-DISPLAY.       " Emision definitiva
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER      : p_normal RADIOBUTTON GROUP a DEFAULT 'X'
                             USER-COMMAND rb1.
SELECTION-SCREEN COMMENT 3(16) TEXT-t_n.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 5.
PARAMETERS     : p_gpo    AS CHECKBOX.
SELECTION-SCREEN COMMENT 8(22) TEXT-t_a.
SELECTION-SCREEN END OF LINE.
PARAMETER      : p_alv    RADIOBUTTON GROUP a.
PARAMETER      : p_desc   NO-DISPLAY. " AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN END OF BLOCK zc_1.

SELECTION-SCREEN BEGIN OF BLOCK zc_2 WITH FRAME TITLE TEXT-ex1.
SELECT-OPTIONS : p_belnr FOR bkpf-belnr.
SELECTION-SCREEN END OF BLOCK zc_2.
*
SELECTION-SCREEN BEGIN OF BLOCK zc_3 WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(44) TEXT-002 FOR FIELD p_ile.
PARAMETERS p_iev NO-DISPLAY. " AS CHECKBOX." MODIF ID ELE DEFAULT SPACE
PARAMETERS p_ile AS CHECKBOX USER-COMMAND ile.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF BLOCK b_tpo WITH FRAME TITLE TEXT-p03.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS pc RADIOBUTTON GROUP gae USER-COMMAND gae DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(22) TEXT-p_c.
PARAMETERS p_file LIKE rlgrap-filename.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS server RADIOBUTTON GROUP gae.
SELECTION-SCREEN COMMENT 3(22) TEXT-svr.
PARAMETERS path_o TYPE c LENGTH 60.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 7(18) TEXT-n_f.
PARAMETERS file_o LIKE filename-fileextern.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b_tpo.

SELECTION-SCREEN END OF BLOCK zc_3.

INCLUDE zcl_gli0002.

AT SELECTION-SCREEN ON p_gjahr.
  PERFORM fill_gjahr USING p_gjahr.

AT SELECTION-SCREEN ON p_monat.
  PERFORM check_monat USING p_monat p_gjahr.

* Valida la emision definitiva.
AT SELECTION-SCREEN ON p_def.
  IF NOT p_def IS INITIAL AND p_def NE 'X'.
    MESSAGE e899(fi) WITH 'Indicar letra X'.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = '*.txt'
      def_path         = 'C:\'
      mask             = ',*.txt.'
      mode             = 'O'
      title            = TEXT-c12
    IMPORTING
      filename         = p_file
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

AT SELECTION-SCREEN ON br_bukrs.
  IF br_bukrs-low IS INITIAL.
    MESSAGE e899(fi)  WITH 'Debe ingresar la Sociedad'.
  ELSE.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK' ID 'BUKRS' FIELD br_bukrs-low.
    IF sy-subrc NE 0.
      MESSAGE e899(fi)
       WITH 'No esta autorizado para obtener información de la'
            'Sociedad' br_bukrs-low.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN.
  INCLUDE zcl_gli0001.

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF screen-group1 EQ 'ELE' OR screen-name EQ '%B003062_BLOCK_1000'.
      screen-active = 0.
    ENDIF.
    IF p_normal EQ space.
      IF screen-name EQ 'P_GPO' OR screen-name EQ '%CT_A072_1000'.
        screen-active = 0.
      ENDIF.
    ENDIF.
    IF p_ile = 'X'.
      IF screen-name EQ '%BP03078_BLOCK_1000' OR screen-name EQ 'PC' OR
         screen-name EQ 'SERVER'.
        screen-active = 1.
      ENDIF.
      CASE 'X'.
        WHEN pc.
          CASE screen-name.
            WHEN 'P_FILE'.
              screen-active = 1.
            WHEN 'PATH_O' OR 'FILE_O' OR '%CN_F098_1000'.
              screen-active = 0.
          ENDCASE.
        WHEN server.
          CASE screen-name.
            WHEN 'P_FILE'.
              screen-active = 0.
            WHEN 'FILE_O' OR '%CN_F098_1000'.
              screen-active = 1.
            WHEN 'PATH_O'.
              screen-input      = 0.
              screen-active     = 1.
              screen-display_3d = 0.
          ENDCASE.
      ENDCASE.
    ELSE.
      IF screen-name EQ '%BP03079_BLOCK_1000' OR
         screen-name EQ 'PC'     OR screen-name EQ '%CP_C089_1000' OR
         screen-name EQ 'SERVER' OR screen-name EQ '%CSVR094_1000' OR
         screen-name EQ 'P_FILE' OR screen-name EQ 'PATH_O'        OR
         screen-name EQ 'FILE_O' OR screen-name EQ '%CSVR088_1000' OR
         screen-name EQ '%CN_F098_1000'.
        screen-active = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

  SELECT SINGLE pathintern INTO path_o FROM ztab_pro_mas WHERE tip_lib =
  'VENTAS'.

INITIALIZATION.
  GET PARAMETER ID 'BUK' FIELD br_bukrs-low.
*  FILL_RANGE BLART_NOW 'RV'.  "Factura Electonica
  PERFORM load_doc TABLES so_fac USING 'G1'.
  PERFORM load_doc TABLES so_fac USING 'G2'.
  PERFORM load_doc TABLES so_fac USING 'G3'.
  PERFORM load_doc TABLES so_fac USING 'G4'.
*
  PERFORM load_doc TABLES so_nd  USING 'L1'.
  PERFORM load_doc TABLES so_nd  USING 'L2'.
  PERFORM load_doc TABLES so_nd  USING 'L3'.
  PERFORM load_doc TABLES so_nd  USING 'L4'.
*
  PERFORM load_doc TABLES so_nc  USING 'J1'.
  PERFORM load_doc TABLES so_nc  USING 'J2'.
  PERFORM load_doc TABLES so_nc  USING 'J3'.
  PERFORM load_doc TABLES so_nc  USING 'J4'.
*
  PERFORM load_doc TABLES so_bol USING 'O1'.
  PERFORM load_doc TABLES so_bol USING 'O2'.
  PERFORM load_doc TABLES so_bol USING 'O3'.
  PERFORM load_doc TABLES so_bol USING 'O4'.
*
  LOOP AT SCREEN.
    IF screen-name EQ 'PATH_O'.
      screen-input = '1'.
      MODIFY SCREEN.
    ENDIF.
    CHECK screen-name EQ 'BR_BUKRS-HIGH' OR
          screen-name EQ '%_BR_BUKRS_%_APP_%-VALU_PUSH' OR
          screen-name EQ '%BP03086_BLOCK_1000' OR
          screen-name EQ 'PC' OR
          screen-name EQ '%CP_C089_1000' OR
          screen-name EQ 'SERVER' OR
          screen-name EQ '%CSVR094_1000' OR
          screen-name EQ 'P_FILE' OR
          screen-name EQ 'PATH_O' OR
          screen-name EQ 'FILE_O' OR
          screen-name EQ '%CSVR088_1000' OR
          screen-name EQ '%CN_F098_1000'.
    screen-active = 0.
    MODIFY SCREEN.
  ENDLOOP.
*
***********************************************************************
* -Oficina de Venta:
*    -Si el documento proviene de SD, se asume Org. de Vtas
*    -Si el documento proviene de FI, se asume que en Texto Cabecera,
*     en las primeras posiciones viene informada la oficina en el
*     formato *NNNN, donde NNNN es el codigo de la oficina.
***********************************************************************
START-OF-SELECTION.
  RANGES p_werks FOR vbrp-werks.
  CLEAR ok_reg.
  PERFORM get_blart_text.

GET bkpf.
  CHECK ( bkpf-blart IN so_bol OR bkpf-blart IN so_fac OR bkpf-blart IN
  so_nd OR bkpf-blart IN so_nc ) AND bkpf-budat+4(2) = p_monat AND
  bkpf-bukrs EQ br_bukrs-low.

  MOVE bkpf-blart+0(2) TO bkpf-blart.
  REFRESH tb_pospo.
  IF bkpf-awtyp <> 'VBRK'.
    CHECK bkpf-stblg IS INITIAL.
  ELSE.
    IF bkpf-tcode = 'VBOF'.
      sy-subrc = 1.
      CHECK sy-subrc = 0.
    ENDIF.
  ENDIF.
************************************************************************
  CHECK bkpf-belnr IN p_belnr.
  CLEAR: n_bset, tabla, v_anulada, v_werks.

  IF bkpf-bukrs NE bukrs_ant.
    bukrs_ant = bkpf-bukrs.
    PERFORM read_t001 USING bkpf-bukrs.
  ENDIF.

  IF bkpf-awtyp <> 'VBRK'.             "Es una transaccion de finanzas.
    PERFORM get_data_fi USING bkpf-bktxt bkpf-blart v_werks v_tipo.
    PERFORM carga-oficina-ventas-fi.
  ELSE.
    PERFORM get_data_sd USING bkpf-blart v_tipo v_werks.
    PERFORM busca-anulada.
*
    IF NOT vbrk-fksto IS INITIAL.
      MOVE bkpf-belnr TO v_anulada.
    ELSE.
      IF NOT bkpf-stblg IS INITIAL.
        MOVE bkpf-belnr TO v_anulada.
      ENDIF.
    ENDIF.
    PERFORM carga-oficina-ventas-sd.
    CHECK vbrk-sfakn IS INITIAL.
    CHECK v_werks IN p_werks.
  ENDIF.

  IF NOT v_anulada IS INITIAL.         "Es una anulacion de factura
    IF bkpf-awtyp <> 'VBRK'.
      PERFORM registra_anulacion.
      REJECT 'BKPF'.
    ELSE.
      PERFORM registra_anulacion.
    ENDIF.
  ENDIF.

GET bseg.
*
  IF bkpf-blart = 'RG' AND bseg-koart = 'S'.
    SELECT SINGLE * FROM vbrk WHERE vbeln = bkpf-awkey.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM kna1 WHERE kunnr = vbrk-kunrg.
    ENDIF.
  ENDIF.
*
  IF bseg-koart EQ 'D' OR bseg-hkont = v_hkont_mtr OR
    ( bseg-koart EQ 'S' AND p_sem IS INITIAL AND
      ( ( bseg-hkont = v_hkont_bol OR bseg-hkont = v_hkont_tgm OR
      bseg-hkont = v_hkont_aju  ) OR
        ( bseg-hkont = v_hkont_dem AND
          bkpf-blart NE 'BN' AND
          bkpf-blart NE 'ZF' ) ) ).
*
    IF bseg-koart EQ 'D'.
      MOVE 'X' TO p_sem.
    ENDIF.
*
    IF bseg-shkzg EQ 'H' OR bkpf-blart IN so_nc.
      bseg-dmbtr = bseg-dmbtr * -1.
    ENDIF.
    ADD bseg-dmbtr TO tabla-totdoc.
    PERFORM get_kna1.
*
    IF kna1-land1 EQ t001-land1.       " Si el deudor es extranjero se
      tabla-orig = origen_nac.      " Considera la venta como venta al
    ELSE.                              " extranjero.
      tabla-orig = origen_exp.
    ENDIF.
    MOVE bseg TO xbseg.
  ELSEIF bseg-hkont = v_hkont_pro.
    IF bseg-shkzg EQ 'H' OR bkpf-blart IN so_nc.
      bseg-dmbtr = bseg-dmbtr * -1.
    ENDIF.
    ADD bseg-dmbtr TO tabla-exent.
    ADD bseg-dmbtr TO tabla-exent_mt.
  ENDIF.

  IF bseg-mwskz EQ 'D7' AND bseg-ktosl IS INITIAL AND bseg-shkzg EQ 'H'.
    ADD bseg-dmbtr TO tabla-afect.
  ENDIF.
*
  SELECT SINGLE matnr INTO v_matnr FROM mvke WHERE matnr EQ bseg-matnr
                                               AND prodh EQ v_prodh.
  CLEAR l_swenc.
  IF sy-subrc NE 0 AND bseg-matnr IS INITIAL .
    SELECT posnr INTO vbrp-posnr FROM vbrp WHERE vbeln EQ bkpf-awkey
                                             AND prodh EQ v_prodh
                                             AND netwr EQ bseg-dmbtr.
      READ TABLE tb_pospo WITH KEY posnr = vbrp-posnr.
      IF sy-subrc NE 0.
        tb_pospo-posnr = vbrp-posnr.
        APPEND tb_pospo.
        l_swenc = 1.
        EXIT.
      ENDIF.
    ENDSELECT.
  ENDIF.
*
  IF sy-subrc EQ 0 OR l_swenc = 1.
    IF bseg-shkzg EQ 'H'.
      SUBTRACT bseg-dmbtr FROM tabla-exent. "No debe apare.en Exento
    ELSEIF bseg-shkzg EQ 'S' AND bkpf-blart = 'DG'.  " nota de crédito
      ADD bseg-dmbtr  TO tabla-exent.
    ENDIF.
  ENDIF.

  IF bseg-mwskz EQ ' '.
    IF bseg-bschl = '01' OR bseg-bschl = '11'.
      IF bseg-shkzg EQ 'H'.
        SUBTRACT bseg-dmbtr FROM tabla-exent.
      ELSE.
        ADD bseg-dmbtr       TO  tabla-exent.
      ENDIF.
    ENDIF.
  ENDIF.

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  tabla-vertn = bseg-vertn.
  tabla-vertt = bseg-vertt.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
*
GET bset.
*  MOVE-CORRESPONDING BKPF TO TABLA.
  PERFORM get_data_tax.
  ADD 1 TO n_bset.          "Incluye todo aunque no tenga posicion imp.

GET bkpf LATE.
*
  CHECK bkpf-belnr IN p_belnr.
  MOVE-CORRESPONDING bkpf TO tabla.
  MOVE-CORRESPONDING kna1 TO tabla.
  MOVE-CORRESPONDING xbseg TO tabla.
  MOVE bkpf-bukrs TO tabla-bukrs.
  MOVE bkpf-belnr TO tabla-belnr.
  MOVE vbrk-fkart TO tabla-fkart.
  MOVE bkpf-awkey TO tabla-vbeln.    "Para chequeo de anulacion
  MOVE v_tipo     TO tabla-tipo.
  MOVE v_werks    TO tabla-werks.

  SELECT SINGLE znom_cli_fact zrut_cli_pagador
    INTO (tabla-znom_cli_fact, tabla-zrut_cli_pagador)
    FROM zfac_anex
    WHERE bukrs EQ bkpf-bukrs
      AND belnr EQ bkpf-belnr
      AND gjahr EQ bkpf-gjahr.

  IF NOT tabla-znom_cli_fact IS INITIAL.
    tabla-name1 = tabla-znom_cli_fact.
  ENDIF.

  IF tabla-blart NE 'AJ' AND tabla-blart NE 'AT' AND tabla-blart NE 'ZF'
  AND  tabla-blart NE 'ZG'.
    IF tabla-blart <> 'RG'.
      tabla-totdoc = ( tabla-afect + tabla-impue + tabla-impue-5 +
      tabla-fepp ) + tabla-exent.
    ELSE.
      tabla-totdoc = ( tabla-afect + tabla-impue + tabla-impue-5 +
      tabla-fepp ) - tabla-exent.
      tabla-exent  = tabla-exent * -1.
      tabla-totdoc = tabla-totdoc * -1.
    ENDIF.
  ELSE.
    CASE tabla-blart.
      WHEN 'ZF'.
        tabla-exporta = tabla-exent.
        tabla-totdoc  = tabla-exent.
        CLEAR :  tabla-exent, tabla-exent_mt.
        IF  tabla-exporta < 0.
          tabla-exporta = tabla-exporta * -1.
        ENDIF.
        IF tabla-totdoc < 0.
          tabla-totdoc = tabla-totdoc * -1.
        ENDIF.
      WHEN 'ZG'.
        tabla-exporta = tabla-exent.
        tabla-totdoc  = tabla-exent.
        CLEAR :  tabla-exent, tabla-exent_mt.
      WHEN OTHERS.
        tabla-totdoc = tabla-afect + tabla-impue + tabla-impue-5 +
                       tabla-fepp .
    ENDCASE.
  ENDIF.
  tabla-totdoc_mt =  tabla-exent_mt.
  IF tabla-werks IS INITIAL.
    MOVE 'CMCL' TO tabla-werks.
  ENDIF.
*
  PERFORM verifica_xblr CHANGING tabla-xblnr.
*
  APPEND tabla.
  CLEAR: bkpf, kna1, var-aux-xblnr, tabla.
*
END-OF-SELECTION.
*
  PERFORM procesa_anulados.
  PERFORM procesa_anulados_sd.
*
  PERFORM process_out.
  IF p_belnr[] IS INITIAL.
    PERFORM process_null.
  ENDIF.
  PERFORM nc_feerratas.
  IF p_ile EQ 'X'.
    FREE:  detalle, resumen1, resumen2.
    CLEAR: detalle, resumen1, resumen2.
    SORT tabla BY blart ASCENDING.
    LOOP AT tabla.
** Begin:V1 21.03.2014
      IF tabla-anul = 'X'.
** End:  V1 21.03.2014
      ELSE.
        IF tabla-blart IN so_fac.
          CASE tabla-blart.
            WHEN 'G1'.         " Factura Venta Afecta
              detalle-tip_doc = '30'.
            WHEN 'G2'.         " Factura Venta Exenta
              detalle-tip_doc = '32'.
            WHEN 'G3'.         " Factura Venta Electrónica Afecta
              detalle-tip_doc = '33'.
            WHEN 'G4'.         " Factura Venta Electrónica Exenta
              detalle-tip_doc = '34'.
          ENDCASE.
        ENDIF.
        IF tabla-blart IN so_nc.
          CASE tabla-blart.
            WHEN 'J1' OR 'J2'. " N/C Venta Afecta y Exenta
              detalle-tip_doc = '60'.
            WHEN 'J3' OR 'J4'. " N/C Venta Electrónica Afecta y Exenta
              detalle-tip_doc = '61'.
          ENDCASE.
        ENDIF.
        IF tabla-blart IN so_nd.
          CASE tabla-blart.
            WHEN 'L1' OR 'L2'. " N/D Venta Afecta y Exenta
              detalle-tip_doc = '55'.
            WHEN 'L3' OR 'L4'. " N/D Venta Electrónica Afecta y Exenta
              detalle-tip_doc = '56'.
          ENDCASE.
        ENDIF.

        IF tabla-blart IN so_bol.
          CASE tabla-blart.
            WHEN 'O1'.         " Boleta Venta Afecta
              detalle-tip_doc = '35'.
*            CHECK TABLA-BLART NE 'O1'.
            WHEN 'O2'.         " Boleta Venta Exenta
              detalle-tip_doc = '38'.
*            CHECK TABLA-BLART NE 'O2'.
            WHEN 'O3'. " Boleta Venta Electrónica Afecta
              detalle-tip_doc = '39'.
            WHEN 'O4'. " Boleta Venta Electrónica Exenta
              detalle-tip_doc = '41'.
*            CHECK TABLA-BLART NE 'O3'.
*            CHECK TABLA-BLART NE 'O4'.
          ENDCASE.
        ENDIF.
        detalle-folio         = tabla-xblnr.
        detalle-nulo          = tabla-anul.
        detalle-oper          = space.
*
        detalle-tas_iva       = space.
*
        detalle-num_int       = tabla-belnr.
        CONCATENATE tabla-budat(4) tabla-budat+4(2) tabla-budat+6(2) INTO
        detalle-fec_emis SEPARATED BY '-'.
        detalle-suc           = space.
*
        IF tabla-zrut_cli_pagador IS INITIAL.
          detalle-rut_rec       = tabla-stcd1.
          detalle-raz_soc       = tabla-name1.
        ELSE.
          detalle-rut_rec       = tabla-zrut_cli_pagador.
          detalle-raz_soc       = tabla-znom_cli_fact.
        ENDIF.
*
        detalle-tip_doc_ref   = space.
        detalle-folio_doc_ref = space.
        IF tabla-blart IN so_nc.
          SELECT SINGLE * FROM bkpf WHERE bukrs EQ br_bukrs-low
                                      AND belnr EQ tabla-belnr
                                      AND gjahr IN br_gjahr.
          IF sy-subrc = 0.
            SELECT SINGLE * FROM vbfa WHERE vbeln   = bkpf-awkey
                                        AND vbtyp_n = 'O'
                                        AND ( vbtyp_v = 'M' OR vbtyp_v =
                                        'P' ).
            IF sy-subrc = 0.
              SELECT SINGLE * FROM vbrk WHERE vbeln EQ vbfa-vbelv.
              IF sy-subrc = 0.
                detalle-tip_doc_ref   = vbrk-zelectronico.
                detalle-folio_doc_ref = vbrk-xblnr.
                IF detalle-folio_doc_ref(1) CN '1234567890'.
                  DO 2 TIMES.
                    SHIFT detalle-folio_doc_ref LEFT.
                  ENDDO.
                  IF NOT detalle-folio_doc_ref IS INITIAL.
                    WHILE detalle-folio_doc_ref(1) = '0'.
                      SHIFT detalle-folio_doc_ref LEFT.
                    ENDWHILE.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
*
        WRITE tabla-exent TO detalle-mnt_exe CURRENCY tabla-waers.
        WRITE tabla-afect TO detalle-mnt_neto CURRENCY tabla-waers.
        IF detalle-mnt_neto CS '-'.
          CLEAR l.
*Begin:V1 21.03.2014
*       SHIFT detalle-mnt_neto RIGHT.
          TRANSLATE detalle-mnt_neto USING '- '.
*End:V1   21.03.2014
          CONCATENATE '-' detalle-mnt_neto INTO detalle-mnt_neto.
        ENDIF.

        IF detalle-mnt_exe NE space.
          WRITE tabla-impue TO detalle-mnt_iva CURRENCY tabla-waers.
          IF detalle-mnt_iva CS '-'.
            CLEAR l.
*Begin:V1 21.03.2014
*         SHIFT detalle-mnt_iva RIGHT.
            TRANSLATE detalle-mnt_iva USING '- '.
*End:V1   21.03.2014
            CONCATENATE '-' detalle-mnt_iva INTO detalle-mnt_iva.
          ENDIF.
          IF detalle-mnt_exe CS '-'.
            CLEAR l.
*Begin:V1 21.03.2014
*         SHIFT detalle-mnt_exe RIGHT.
            TRANSLATE detalle-mnt_exe USING '- '.
*End:V1   21.03.2014
            CONCATENATE '-' detalle-mnt_exe INTO detalle-mnt_exe.
          ENDIF.
        ELSE.
          detalle-mnt_iva       = 0.
        ENDIF.

        detalle-iva_fp        = space.
        WRITE tabla-totdoc TO detalle-mnt_tot CURRENCY tabla-waers.
        IF detalle-mnt_tot CS '-'.
          CLEAR l.
*Begin:V1 21.03.2014
*       SHIFT detalle-mnt_tot RIGHT.
          TRANSLATE detalle-mnt_tot USING '- '.
*End:V1   21.03.2014
          CONCATENATE '-' detalle-mnt_tot INTO detalle-mnt_tot.
        ENDIF.
        detalle-cod_imp_rec   = space.
        detalle-tasa_imp_rec  = space.
        detalle-mnt_imp_rec   = space.

        resumen2-tip_doc      = detalle-tip_doc.
        IF NOT resumen2-tip_doc IS INITIAL.
          WHILE resumen2-tip_doc = '0'.
            SHIFT resumen2-tip_doc LEFT.
          ENDWHILE.
        ENDIF.
        resumen2-can_doc      = 1.
        IF NOT resumen2-tip_doc IS INITIAL.
          WHILE resumen2-tip_doc = '0'.
            SHIFT resumen2-tip_doc LEFT.
          ENDWHILE.
        ENDIF.
        IF detalle-nulo NE space.
          resumen2-can_doc_anul = 1.
          detalle-nulo = 'A'.
        ELSE.
          resumen2-can_doc_anul = 0.
        ENDIF.

        REPLACE ALL OCCURRENCES OF '.' IN detalle-mnt_exe WITH space.
        CONDENSE detalle-mnt_exe NO-GAPS.
        WRITE detalle-mnt_exe TO detalle-mnt_exe RIGHT-JUSTIFIED.
        resumen2-tot_exe      = detalle-mnt_exe.

        REPLACE ALL OCCURRENCES OF '.' IN detalle-mnt_neto WITH space.
        CONDENSE detalle-mnt_neto NO-GAPS.
        WRITE detalle-mnt_neto TO detalle-mnt_neto RIGHT-JUSTIFIED.
        resumen2-tot_net      = detalle-mnt_neto.

        REPLACE ALL OCCURRENCES OF '.' IN detalle-mnt_iva WITH space.
        CONDENSE detalle-mnt_iva NO-GAPS.
        WRITE detalle-mnt_iva TO detalle-mnt_iva RIGHT-JUSTIFIED.
        resumen2-tot_iva      = detalle-mnt_iva.

        REPLACE ALL OCCURRENCES OF '.' IN detalle-iva_fp WITH space.
        CONDENSE detalle-iva_fp NO-GAPS.
        WRITE detalle-iva_fp TO detalle-iva_fp RIGHT-JUSTIFIED.
        resumen2-iva_fp       = detalle-iva_fp.

        REPLACE ALL OCCURRENCES OF '.' IN detalle-mnt_tot WITH space.
        CONDENSE detalle-mnt_tot NO-GAPS.
        WRITE detalle-mnt_tot TO detalle-mnt_tot RIGHT-JUSTIFIED.
        resumen2-tot_mnt_tot  = detalle-mnt_tot.

        resumen2-cod_imp_rec  = space.
        resumen2-mnt_imp_rec  = space.
        resumen2-sep1  = resumen2-sep2  = resumen2-sep3  = resumen2-sep4
        = resumen2-sep5  = '|'.
        resumen2-sep6  = resumen2-sep7  = resumen2-sep8  = resumen2-sep9
        = resumen2-sep10 = '|'.
        resumen2-sep11 = resumen2-sep12 = resumen2-sep13 = resumen2-sep14
        = '|'.
        resumen2-fr = '}'.
        COLLECT resumen2.
        CLEAR resumen2.

        detalle-sep1  = detalle-sep2  = detalle-sep3  = '|'.
        detalle-sep4  = detalle-sep5  = detalle-sep6  = '|'.
        detalle-sep7  = detalle-sep8  = detalle-sep9  = '|'.
        detalle-sep10 = detalle-sep11 = detalle-sep12 = '|'.
        detalle-sep13 = detalle-sep14 = detalle-sep15 = '|'.
        detalle-sep16 = detalle-sep17 = detalle-sep18 = '|'.
        detalle-sep19 = detalle-sep20 = detalle-sep21 = '|'.
        detalle-sep22 = '|'.
        detalle-fr    = '}'.
*
        IF tabla-blart IN so_bol.
          CHECK tabla-blart NE 'O1'.
          CHECK tabla-blart NE 'O2'.
          CHECK tabla-blart NE 'O3'.
          CHECK tabla-blart NE 'O4'.
        ENDIF.

*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
        detalle-vertn = tabla-vertn.
        detalle-vertt = tabla-vertt.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP

        APPEND detalle.
        CLEAR detalle.
** Begin:V1 21.03.2014
      ENDIF.
** End:  V1 21.03.2014
    ENDLOOP.

    SORT detalle BY tip_doc DESCENDING.
    LOOP AT detalle.
      IF detalle-mnt_exe CS '-'.
        REPLACE '-' WITH space INTO detalle-mnt_exe.
      ENDIF.
*
      IF detalle-mnt_neto CS '-'.
        REPLACE '-' WITH space INTO detalle-mnt_neto.
      ENDIF.
*
      IF detalle-mnt_iva CS '-'.
        REPLACE '-' WITH space INTO detalle-mnt_iva.
      ENDIF.
*
      IF detalle-mnt_tot CS '-'.
        REPLACE '-' WITH space INTO detalle-mnt_tot.
      ENDIF.
*
      IF detalle-iva_fp CS '-'.
        REPLACE '-' WITH space INTO detalle-iva_fp.
      ENDIF.
*
      it_tabla-line = detalle.
      APPEND it_tabla.
    ENDLOOP.

    it_tabla-line = '~'.
    APPEND it_tabla.
    CLEAR it_tabla.

    SELECT SINGLE * FROM zdatsocelec WHERE bukrs EQ br_bukrs-low.
    IF sy-subrc = 0.
      resumen1-rut_con     = zdatsocelec-rut_contr.
      resumen1-rut_env     = zdatsocelec-rut_envia.
      CONCATENATE p_gjahr p_monat
             INTO resumen1-per_trib SEPARATED BY '-'.
      CONCATENATE zdatsocelec-fec_res(4) zdatsocelec-fec_res+4(2)
      zdatsocelec-fec_res+6(2)
             INTO resumen1-fec_res SEPARATED BY '-'.
      resumen1-num_res     = zdatsocelec-num_res.

      IF NOT resumen1-num_res IS INITIAL.
        WHILE resumen1-num_res(1) = '0'.
          SHIFT resumen1-num_res LEFT.
        ENDWHILE.
      ENDIF.
      resumen1-tip_ope     = zdatsocelec-tip_opera.
      resumen1-tip_lib     = zdatsocelec-tip_lib.
      resumen1-tip_env     = zdatsocelec-tip_env.
      resumen1-fol_not     = zdatsocelec-folio_not.

      CONDENSE resumen1-fol_not NO-GAPS.
      WHILE resumen1-fol_not(1) EQ '0'.
        SHIFT resumen1-fol_not LEFT.
      ENDWHILE.

      resumen1-cod_aut_rec = space.
      resumen1-sep1 = resumen1-sep2 = resumen1-sep3 = resumen1-sep4 =
      resumen1-sep5 = resumen1-sep6 = resumen1-sep7 = resumen1-sep8 =
      resumen1-sep9 = resumen1-sep10 = '|'.
      resumen1-fr = '}'.
      APPEND resumen1.
      it_tabla-line = resumen1.
      APPEND it_tabla.
      CLEAR: resumen1, it_tabla.
    ENDIF.

    it_tabla-line = '~'.
    APPEND it_tabla.
    CLEAR it_tabla.

    SORT resumen2 BY tip_doc DESCENDING.
    LOOP AT resumen2.
      str_tot_exe     = resumen2-tot_exe.
      IF str_tot_exe CS '-'.
        REPLACE '-' WITH space INTO str_tot_exe.
      ENDIF.
      CONDENSE str_tot_exe NO-GAPS.

      str_tot_net     = resumen2-tot_net.
      IF str_tot_net CS '-'.
        REPLACE '-' WITH space INTO str_tot_net.
      ENDIF.
      CONDENSE str_tot_net NO-GAPS.

      str_tot_iva     = resumen2-tot_iva.
      IF str_tot_iva CS '-'.
        REPLACE '-' WITH space INTO str_tot_iva.
      ENDIF.
      CONDENSE str_tot_iva NO-GAPS.

      str_iva_fp      = resumen2-iva_fp.
      IF str_iva_fp CS '-'.
        REPLACE '-' WITH space INTO str_iva_fp.
      ENDIF.
      CONDENSE str_iva_fp NO-GAPS.

      str_tot_mnt_tot = resumen2-tot_mnt_tot.
      IF str_tot_mnt_tot CS '-'.
        REPLACE '-' WITH space INTO str_tot_mnt_tot.
      ENDIF.
      CONDENSE str_tot_mnt_tot NO-GAPS.

      str_mnt_imp_rec  = space. "RESUMEN2-MNT_IMP_REC.
      str_mnt_imp_rec2 = space. "RESUMEN2-COD_IMP_REC2.
      str_mnt_imp_rec3 = space. "RESUMEN2-COD_IMP_REC3.
      CLEAR: str1, str2.
      str1 = resumen2-can_doc.
      str2 = resumen2-can_doc_anul.

      CONDENSE str1 NO-GAPS.
      IF NOT str1 IS INITIAL.
        WHILE str1(1) EQ '0'.
          CLEAR ls.
          ls = strlen( str1 ).
          IF ls > 1.
            SHIFT str1 LEFT.
          ELSE.
            EXIT.
          ENDIF.
        ENDWHILE.
      ENDIF.

      CONDENSE str2 NO-GAPS.
      IF NOT str2 IS INITIAL.
        WHILE str2(1) EQ '0'.
          CLEAR ls.
          ls = strlen( str2 ).
          IF ls > 1.
            SHIFT str2 LEFT.
          ELSE.
            EXIT.
          ENDIF.
        ENDWHILE.
      ENDIF.
      IF resumen2-tip_doc EQ '34'.
        IF str_tot_exe EQ 0.
          str_tot_exe = space.
        ENDIF.
        IF str_tot_net EQ 0.
          str_tot_net = space.
        ENDIF.
        IF str_tot_iva EQ 0.
          str_tot_iva = space.
        ENDIF.
        IF str_iva_fp EQ 0.
          str_iva_fp = space.
        ENDIF.
        IF str_iva_fp EQ 0.
          str_iva_fp = space.
        ENDIF.
      ENDIF.

      CONCATENATE resumen2-tip_doc      resumen2-sep1
                  str1                  resumen2-sep2
                  str2                  resumen2-sep3
                  str_tot_exe           resumen2-sep4
                  str_tot_net           resumen2-sep5
                  str_tot_iva           resumen2-sep6
                  str_iva_fp            resumen2-sep7
                  str_tot_mnt_tot       resumen2-sep8
                  resumen2-cod_imp_rec  resumen2-sep9
                  str_mnt_imp_rec       resumen2-sep10
                  resumen2-cod_imp_rec2 resumen2-sep11
                  str_mnt_imp_rec2      resumen2-sep12
                  resumen2-cod_imp_rec3 resumen2-sep13
                  str_mnt_imp_rec3      resumen2-sep14
                  resumen2-fr
             INTO it_tabla-line.
      APPEND it_tabla.
      CLEAR resumen2.
    ENDLOOP.

    it_tabla-line = '~\'.
    APPEND it_tabla.
    CLEAR it_tabla.

    DATA server_name TYPE string.
    CASE 'X'.
      WHEN pc.
        str_file = p_file.
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
            filename                = str_file
            filetype                = 'ASC'
          TABLES
            data_tab                = it_tabla
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
      WHEN server.
        CLEAR server_name.
        CONCATENATE path_o file_o INTO server_name.
        OPEN DATASET server_name FOR OUTPUT IN TEXT MODE ENCODING
        DEFAULT.
        IF sy-subrc = 0.
          LOOP AT it_tabla.
            TRANSFER it_tabla-line TO server_name.
          ENDLOOP.
        ELSE.
          MESSAGE e899(fi) WITH 'Al archivo' server_name
          'no se pudo acceder'.
        ENDIF.
        CLOSE DATASET server_name.
    ENDCASE.
  ENDIF.
*
  IF p_alv IS INITIAL.
    IF NOT p_desc IS INITIAL.
      DATA: print_parameters TYPE pri_params,
            valid_flag       TYPE c.

      DATA : it_pdf        LIKE tline OCCURS 0 WITH HEADER LINE,
             l_no_of_bytes TYPE i,
             l_pdf_spoolid TYPE tsp01-rqident,
             spoolno       TYPE tsp01-rqident,
             w_full_path   TYPE string,
             l_jobname     TYPE tbtcjob-jobname,
             l_jobcount    TYPE tbtcjob-jobcount.

      CALL FUNCTION 'GET_PRINT_PARAMETERS'
        EXPORTING
          no_dialog            = 'X'
        IMPORTING
          out_parameters       = print_parameters
          valid                = valid_flag
        EXCEPTIONS
          invalid_print_params = 2
          OTHERS               = 4.

      print_parameters-pdest = 'LOCL'.
      print_parameters-linct = sy-linct.
      print_parameters-linsz = sy-linsz.
      print_parameters-paart = 'Z_60_168'.
      print_parameters-primm = space.
      NEW-PAGE PRINT ON PARAMETERS print_parameters NO DIALOG .
      PERFORM imprime_libro_ventas.
      NEW-PAGE PRINT OFF.

      spoolno = sy-spono.

      "Convert spool to PDF
      CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
        EXPORTING
          src_spoolid   = spoolno
          no_dialog     = ' '
        IMPORTING
          pdf_bytecount = l_no_of_bytes
          pdf_spoolid   = l_pdf_spoolid
          btc_jobname   = l_jobname
          btc_jobcount  = l_jobcount
        TABLES
          pdf           = it_pdf.

      DATA: answ TYPE i.

      CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
        EXPORTING
          window_title      = 'Guardar Como'
          default_extension = 'PDF'
        IMPORTING
          fullpath          = w_full_path
          user_action       = answ.

      IF answ NE 9.
        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
*           bin_filesize = w_bin_filesize
            filename = w_full_path
            filetype = 'BIN'
          TABLES
            data_tab = it_pdf.
      ENDIF.
    ELSE.
      PERFORM imprime_libro_ventas.
    ENDIF.
  ELSE.
    PERFORM salida_alv.
  ENDIF.

TOP-OF-PAGE.
  PERFORM header.

AT USER-COMMAND.
  PERFORM imprmir_libro.

AT LINE-SELECTION.
  PERFORM at_line_selection.

*&--------------------------------------------------------------------*
*&      Form  READ_T001
*&--------------------------------------------------------------------*
FORM read_t001 USING bukrs.
  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
ENDFORM.                                                    " READ_T001

*&--------------------------------------------------------------------*
*&      Form  IMPRIME_LIBRO_VENTAS
*&--------------------------------------------------------------------*
FORM imprime_libro_ventas.

  CLEAR zlinea.
  CLEAR doc-nulos.
  PERFORM recup_sociedad.
*
  SORT tabla BY blart budat xblnr.
*
  LOOP AT tabla.
    PERFORM sum_resumen.
  ENDLOOP.

  IF p_gpo = 'X'.
    REFRESH : tabla_aux.
*
    LOOP AT tabla.
      CLEAR e_tabla.
      MOVE-CORRESPONDING tabla TO e_tabla.
      AT NEW budat.
        CLEAR xblnr_aux.
      ENDAT.
*
      CHECK e_tabla-blart IN so_bol AND e_tabla-anul NE 'X'.
*
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = e_tabla-xblnr
        IMPORTING
          output = e_tabla-xblnr.
*
      SEARCH xblnr_aux FOR '-'.
      IF sy-subrc EQ 0.
        CLEAR xblnr_aux.
      ENDIF.
      IF xblnr_aux IS INITIAL.
        CLEAR e_tabla-veces.
        MOVE e_tabla-xblnr TO xblnr_aux.
        MOVE e_tabla-xblnr TO xblnr_tab.
      ELSE.
        DELETE tabla WHERE blart EQ e_tabla-blart
                       AND belnr EQ e_tabla-belnr
                       AND xblnr EQ xblnr_aux.
        ADD 1 TO xblnr_aux.
        CONDENSE xblnr_aux NO-GAPS.
        IF xblnr_aux = e_tabla-xblnr.
          MOVE 1 TO e_tabla-veces.
          DELETE tabla WHERE blart EQ e_tabla-blart
                         AND belnr EQ e_tabla-belnr
                         AND xblnr EQ xblnr_aux.
          CONCATENATE xblnr_tab '-' e_tabla-xblnr INTO e_tabla-xblnr.

        ELSE.
          CLEAR e_tabla-veces.
          MOVE e_tabla-xblnr TO xblnr_aux.
          MOVE e_tabla-xblnr TO xblnr_tab.
        ENDIF.
        DELETE tabla_res WHERE blart EQ e_tabla-blart
                           AND xblnr EQ xblnr_aux.
      ENDIF.
      MOVE-CORRESPONDING e_tabla TO tabla_aux.
      CLEAR : tabla_aux-tipo, tabla_aux-werks, tabla_aux-belnr,
              tabla_aux-stblg, tabla_aux-vbeln.
      SEARCH  tabla_aux-xblnr FOR '-'.
      IF sy-subrc EQ 0.
        MOVE e_tabla-tipo TO tabla_aux-tipo.
      ENDIF.
      COLLECT tabla_aux.
      CLEAR tabla_aux.
    ENDLOOP.
*
    tabla_res[] = tabla[].
*
    CLEAR : tabla_acu, l_sem, x_tabix, l_tabix.
*
    REFRESH tabla.
    CLEAR tabla.
*
    LOOP AT tabla_aux.
      e_tabla = tabla_aux.
*
      IF tabla_aux-veces > 0.
        tabla_acu-exent     = tabla_acu-exent     + tabla_aux-exent.
        tabla_acu-exent_mt  = tabla_acu-exent_mt  + tabla_aux-exent_mt.
        tabla_acu-afect     = tabla_acu-afect     + tabla_aux-afect.
        tabla_acu-fepp      = tabla_acu-fepp      + tabla_aux-fepp .
        tabla_acu-impue     = tabla_acu-impue     + tabla_aux-impue .
        tabla_acu-impue-5   = tabla_acu-impue-5   + tabla_aux-impue-5.
        tabla_acu-comaf     = tabla_acu-comaf     + tabla_aux-comaf.
*        TABLA_ACU-COMEX     = TABLA_ACU-COMEX     + TABLA_AUX-COMEX.
        tabla_acu-totdoc    = tabla_acu-totdoc    + tabla_aux-totdoc.
        tabla_acu-totdoc_mt = tabla_acu-totdoc_mt + tabla_aux-totdoc_mt.
        tabla_acu-propina   = tabla_acu-propina   + tabla_aux-propina.
        tabla_acu-exporta   = tabla_acu-exporta   + tabla_aux-exporta.
        tabla_acu-xblnr     = tabla_aux-xblnr.
        l_sem               = 'X'.
      ELSEIF l_sem EQ 'X'.
        DESCRIBE TABLE tabla LINES x_tabix.
        tabla-exent     = tabla_acu-exent.
        tabla-exent_mt  = tabla_acu-exent_mt.
        tabla-afect     = tabla_acu-afect.
        tabla-fepp      = tabla_acu-fepp.
        tabla-impue     = tabla_acu-impue.
        tabla-impue-5   = tabla_acu-impue-5.
        tabla-comaf     = tabla_acu-comaf.
*        TABLA-COMEX     = TABLA_ACU-COMEX.
        tabla-totdoc    = tabla_acu-totdoc.
        tabla-totdoc_mt = tabla_acu-totdoc_mt.
        tabla-propina   = tabla_acu-propina.
        tabla-exporta   = tabla_acu-exporta.
        tabla-xblnr     = tabla_acu-xblnr.
        IF tabla-xblnr CS '-'.
          CLEAR: tabla-name1, tabla-name2, tabla-stcd1.
        ENDIF.
        MODIFY  tabla INDEX x_tabix.
        CLEAR : tabla_acu,  l_sem.
      ENDIF.
      IF tabla_aux-veces = 0.
        tabla_acu-exent     = e_tabla-exent.
        tabla_acu-exent_mt  = e_tabla-exent_mt.
        tabla_acu-afect     = e_tabla-afect.
        tabla_acu-fepp      = e_tabla-fepp.
        tabla_acu-impue     = e_tabla-impue.
        tabla_acu-impue-5   = e_tabla-impue-5.
        tabla_acu-comaf     = e_tabla-comaf.
*        TABLA_ACU-COMEX     = E_TABLA-COMEX.
        tabla_acu-totdoc    = e_tabla-totdoc.
        tabla_acu-totdoc_mt = e_tabla-totdoc_mt.
        tabla_acu-propina   = e_tabla-propina.
        tabla_acu-exporta   = e_tabla-exporta.
*
        tabla = e_tabla.
        APPEND tabla.
      ENDIF.
*
      AT LAST.
        IF l_sem EQ 'X'.
          DESCRIBE TABLE tabla LINES x_tabix.
** AL PASAR TABLA_AUX A TABLA CAMBIA VALORES DE CLAVE Y MODIFICA TABLA
** EN FORMA ERRONEA
          tabla-exent     = tabla_acu-exent.
          tabla-exent_mt  = tabla_acu-exent_mt.
          tabla-afect     = tabla_acu-afect.
          tabla-fepp      = tabla_acu-fepp.
          tabla-impue     = tabla_acu-impue.
          tabla-impue-5   = tabla_acu-impue-5.
          tabla-comaf     = tabla_acu-comaf.
*          TABLA-COMEX     = TABLA_ACU-COMEX.
          tabla-totdoc    = tabla_acu-totdoc.
          tabla-totdoc_mt = tabla_acu-totdoc_mt.
          tabla-propina   = tabla_acu-propina.
          tabla-exporta   = tabla_acu-exporta.
          tabla-xblnr     = tabla_acu-xblnr.

          MODIFY  tabla INDEX x_tabix.
          CLEAR : tabla_acu,  l_sem.
        ENDIF.
      ENDAT.
    ENDLOOP.
    LOOP AT tabla_res WHERE NOT blart IN so_bol.
      MOVE-CORRESPONDING tabla_res TO tabla.
      APPEND tabla.
    ENDLOOP.
  ENDIF.

  SORT tabla BY blart budat xblnr.
  LOOP AT tabla.
*   Movimientos por sucursal.
    IF NOT p_werks IS INITIAL.
      CHECK tabla-werks IN p_werks.
    ENDIF.
    PERFORM det_line.
  ENDLOOP.

  WRITE /60 'Totales:'.
  PERFORM write_amount_fact USING space
                                  tot-inf-afect
                                  tot-inf-exent
                                  tot-inf-impue
                                  tot-inf-impue-5
                                  tot-inf-exporta
                                  tot-inf-totdoc
                                  0
                                  0.
  PERFORM print_resum.

ENDFORM.                               " IMPRIME_LIBRO_VENTAS
*&--------------------------------------------------------------------*
*&      Form  SALIDA_ALV
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM salida_alv.

  DATA g_variant LIKE disvariant.
  REFRESH: lt_events, gt_fieldcat.
*
  LOOP AT tabla WHERE anul NE 'X'.
    MOVE-CORRESPONDING tabla TO t_salida.
    CONCATENATE tabla-name1 tabla-name2
                     INTO t_salida-name1 SEPARATED BY space.
    APPEND t_salida.
    CLEAR t_salida.
  ENDLOOP.
*
  MOVE sy-repid TO g_repid.
  g_variant-report  = g_repid.
  g_variant-variant = g_variante.

  PERFORM comment_build  USING gt_list_top_of_page[].
  PERFORM layout         USING gs_layout.
  PERFORM evento         USING lt_events[] 'TOP_OF_PAGE'
                                           'ALV_TOP_OF_PAGE'.
  PERFORM fieldcat       USING gt_fieldcat[].
  PERFORM sort           USING gt_sort.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = g_repid
      i_callback_user_command = 'USER_COMMAND'
      it_fieldcat             = gt_fieldcat[]
      is_layout               = gs_layout
      it_sort                 = gt_sort[]
      i_default               = 'X'
      i_save                  = 'A'
*     IS_VARIANT              = G_VARIANT
      is_print                = gs_print
      it_events               = lt_events
    TABLES
      t_outtab                = t_salida.

ENDFORM.                    "SALIDA_ALV
*&--------------------------------------------------------------------*
*&      Form  user_command
*&--------------------------------------------------------------------*
FORM user_command  USING ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.
  DATA : tabname(20)   TYPE c,
         fieldname(20) TYPE c.
  FIELD-SYMBOLS <f>.

  CASE rs_selfield-fieldname.
    WHEN 'BELNR'.
      SET PARAMETER ID 'BLN' FIELD rs_selfield-value.
      SET PARAMETER ID 'BUK' FIELD br_bukrs-low.
      SET PARAMETER ID 'GJR' FIELD p_gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&--------------------------------------------------------------------*
*&      Form  GET_DATA_FI
*&---------------------------------------------------------------------*
FORM get_data_fi USING p_bktxt p_blart p_werks p_tipo.
  DATA: v_bktxt LIKE bkpf-bktxt.

  MOVE p_bktxt TO v_bktxt.
* Obtiene Oficina de Ventas de FI, segun convecion
  IF v_bktxt(1) EQ '*'.
    p_werks = v_bktxt+1(4).
*   v_xblnr = bkpf-xblnr.
  ELSE.                                "Error: docto de FI sin oficina
    CLEAR p_werks.
  ENDIF.

* Clasificacion de tipo de documento.
  IF ( NOT ( p_fact IS INITIAL ) ) AND ( p_blart IN p_fact ).
    p_blart = v_blart_fact.
    p_tipo = '1'.
  ELSEIF (  NOT ( p_ncre IS INITIAL ) ) AND ( p_blart IN p_ncre ).
    p_blart = v_blart_ncre.
    p_tipo = '2'.
  ELSEIF (  NOT ( p_ndeb IS INITIAL ) ) AND ( p_blart IN p_ndeb ).
    p_blart = v_blart_ndeb.
    p_tipo = '3'.
  ELSEIF (  NOT ( p_bole IS INITIAL ) ) AND ( p_blart IN p_bole ).
    p_blart = v_blart_bole.
    p_tipo = '4'.
  ELSEIF ( NOT ( p_fact2 IS INITIAL ) ) AND ( p_blart IN p_fact2 ).
** CLR para dejar = dr y rv
    p_blart = v_blart_fact2.
    p_tipo = '1'.
  ENDIF.
ENDFORM.                               " GET_DATA_FI

*&---------------------------------------------------------------------*
*&      Form  GET_DATA_SD
*&---------------------------------------------------------------------*
FORM get_data_sd USING p_blart p_tipo v_werks.
  DATA: v_bktxt LIKE bkpf-bktxt.

*  MOVE P_werks TO V_werks.

* Clasificacion de tipo de documento.
  IF ( NOT ( p_fact IS INITIAL ) ) AND ( p_blart IN p_fact ).
    p_blart = v_blart_fact.
    p_tipo = '1'.
  ELSEIF (  NOT ( p_ncre IS INITIAL ) ) AND ( p_blart IN p_ncre ).
    p_blart = v_blart_ncre.
    p_tipo = '2'.
  ELSEIF (  NOT ( p_ndeb IS INITIAL ) ) AND ( p_blart IN p_ndeb ).
    p_blart = v_blart_ndeb.
    p_tipo = '3'.
  ELSEIF (  NOT ( p_bole IS INITIAL ) ) AND ( p_blart IN p_bole ).
    p_blart = v_blart_bole.
    p_tipo = '4'.
  ENDIF.
ENDFORM.                               " GET_DATA_SD


*&---------------------------------------------------------------------*
*&      Form  GET_DATA_TAX
*&---------------------------------------------------------------------
FORM get_data_tax.

  CHECK bset-mwskz <> v_exent.         "Excluye lo no afecto a impuesto.
* Lee el segmento de impuestos
  IF bset-shkzg EQ 'S'.                " Debe. Para impresion.
    bset-hwbas = bset-hwbas * -1.      " Base Imponible
    bset-fwbas = bset-fwbas * -1.      " Base Imponible
    bset-hwste = bset-hwste * -1.      " Importe de IVA
    bset-fwste = bset-fwste * -1.      " Importe de IVA
  ENDIF.
* IF bset-hwste EQ 0.                  " Cuota de IVA = 0
*Excluye CP impuesto al petroleo por que aparece como exentoy debe ir en
*IVA.
  IF bset-hwste EQ 0 AND bset-mwskz NE 'CP'.     "Cuota de IVA = 0
    ADD bset-hwbas TO tabla-exent.
    ADD bset-fwbas TO tabla-exent_mt.
*    if tabla-exent eq 0.
*      bset-hwbas = bset-hwbas * -1.
*      move bset-hwbas TO tabla-exent.
*      move bset-fwbas TO tabla-exent_mt.
*    endif.
  ELSE.

***** Para que impuesto el Petroleo aparezca en IVA
    IF bset-ktosl EQ 'J3A'.
      tabla-impue = bset-hwbas + tabla-impue.
    ENDIF.
*************
    IF bset-ktosl EQ 'MWS'.
      IF  bset-mwskz NE 'D7'.
        ADD bset-hwbas TO tabla-afect.
      ENDIF.
      ADD bset-hwste TO tabla-impue.
    ELSE.
      ADD bset-hwste TO tabla-impue-5.
    ENDIF.
  ENDIF.
ENDFORM.                               " GET_DATA_TAX
*

*&---------------------------------------------------------------------*
*&      Form  REGISTRA_ANULACION
*&---------------------------------------------------------------------*
FORM registra_anulacion.
  MOVE bkpf-bukrs TO tb_anuladas-bukrs.
  MOVE v_anulada  TO tb_anuladas-vbeln.
  APPEND tb_anuladas.
ENDFORM.                               " REGISTRA_ANULACION

*&---------------------------------------------------------------------*
*&      Form  PROCESA_ANULADOS
*&---------------------------------------------------------------------*
FORM procesa_anulados.

  DATA v_vbtyp LIKE tvfk-vbtyp.

  LOOP AT tb_anuladas.
    LOOP AT tabla WHERE  bukrs = tb_anuladas-bukrs
                    AND  vbeln = tb_anuladas-vbeln.
      tabla-anul = 'X'.
      tabla-name1 = 'Nulo'.
      CLEAR: tabla-exent, tabla-exent_mt, tabla-afect, tabla-fepp,
             tabla-impue, tabla-impue-5, tabla-comaf, tabla-totdoc,
             tabla-totdoc_mt.
      MODIFY  tabla.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                               " PROCESA_ANULADOS

*&---------------------------------------------------------------------*
*&      Form  PROCESA_ANULADOS_SD.
*&---------------------------------------------------------------------*
FORM procesa_anulados_sd.

  DATA v_vbtyp LIKE tvfk-vbtyp.
  LOOP AT tb_anuladas.
    LOOP AT tabla WHERE  bukrs = tb_anuladas-bukrs
                    AND  belnr = tb_anuladas-vbeln.
      tabla-anul = 'X'.
      tabla-name1 = 'Nulo'.
      CLEAR: tabla-exent, tabla-exent_mt, tabla-afect, tabla-fepp,
      tabla-impue, tabla-impue-5, tabla-comaf,
             tabla-totdoc, tabla-totdoc_mt.
      MODIFY  tabla.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                               " PROCESA_ANULADOS

*&---------------------------------------------------------------------*
*&      Form  PROCESA_REF_ZEROS.
*&---------------------------------------------------------------------*
FORM procesa_ref_zeros.

  DATA v_vbtyp LIKE tvfk-vbtyp.

  LOOP AT tabla WHERE xblnr = '0000000000000000'.
    tabla-anul = 'X'.
    CLEAR: tabla-exent, tabla-exent_mt, tabla-afect, tabla-fepp,
    tabla-impue, tabla-impue-5,
           tabla-comaf, tabla-totdoc, tabla-totdoc_mt.
    MODIFY  tabla.
  ENDLOOP.

ENDFORM.                    "procesa_ref_zeros
*&---------------------------------------------------------------------*
*&      Form  GET_TAX_FEP
*&---------------------------------------------------------------------*
FORM get_tax_fep.

* Lee el segmento de impuestos
  IF bseg-shkzg EQ 'S'.                " Debe. Para impresion.
    bseg-dmbtr = bseg-dmbtr * -1.      " Base Imponible
  ENDIF.
  tabla-fepp = tabla-fepp + bseg-dmbtr.

ENDFORM.                               " GET_TAX_FEP

*&---------------------------------------------------------------------*
*&      Form  GET_BLART_TEXT
*&---------------------------------------------------------------------*
FORM get_blart_text.

  PERFORM get_blart_txt.
  PERFORM src_blart_txt USING v_blart_fact CHANGING v_text_fact.
  IF v_text_fact IS INITIAL.
    MOVE TEXT-050 TO v_text_fact.
  ENDIF.
  PERFORM src_blart_txt USING v_blart_ncre CHANGING v_text_ncre.
  IF v_text_ncre IS INITIAL.
    MOVE TEXT-051 TO v_text_ncre.
  ENDIF.
  PERFORM src_blart_txt USING v_blart_ndeb CHANGING v_text_ndeb.
  IF v_text_ndeb IS INITIAL.
    MOVE TEXT-052 TO v_text_ndeb.
  ENDIF.
  PERFORM src_blart_txt USING v_blart_bole CHANGING v_text_bole.
  IF v_text_bole IS INITIAL.
    MOVE TEXT-053 TO v_text_bole.
  ENDIF.

ENDFORM.                               " GET_BLART_TEXT

*&---------------------------------------------------------------------*
*&      Form  GET_KNA1
*&---------------------------------------------------------------------*
FORM get_kna1.

  IF NOT bseg-xcpdd IS INITIAL. " Proveedor CPD
  ELSEIF bkpf-awtyp = 'VBRK'.
    SELECT SINGLE * FROM kna1 WHERE kunnr = bseg-kunnr.
  ELSE.
    SELECT SINGLE * FROM kna1 WHERE kunnr = bseg-kunnr.
  ENDIF.

ENDFORM.                                                    " GET_KNA1
*&---------------------------------------------------------------------*
*&      Form  GENÉRICO
*&---------------------------------------------------------------------*
FORM generico.

  IF kna1-ktokd = 'Z001' OR kna1-ktokd = '    '.
    SELECT SINGLE * FROM vbpa WHERE vbeln = vbrk-zuonr
                                AND parvw = 'RG'.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM adrc WHERE addrnumber = vbpa-adrnr.
      IF sy-subrc = 0.
        kna1-name1 = adrc-name1.
        kna1-name2 = adrc-name2.
        SELECT SINGLE * FROM vbpa3 WHERE vbeln = vbrk-zuonr
                                      AND parvw = 'RG'.
        IF sy-subrc = 0.
          kna1-stcd1 = vbpa3-stcd1.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "GENERICO
*&---------------------------------------------------------------------*
*&      Form  HEADER
*&---------------------------------------------------------------------*
FORM header.

  DATA: fec1  TYPE sy-datum,
        fec2  TYPE sy-datum,
        l_mes LIKE t247-ltx.
*
  CONCATENATE p_gjahr p_monat '01' INTO fec1.
  CALL FUNCTION 'SLS_MISC_GET_LAST_DAY_OF_MONTH'
    EXPORTING
      day_in            = fec1
    IMPORTING
      last_day_of_month = fec2.

  IF p_def NE 'X'.
    WRITE: /   p_soc,
           107 'Fecha Emisión:', 122 sy-datum,
           /   p_rut,
            55 TEXT-001,
           107 'Hora Emisión :', 122 sy-uzeit,
           /   p_direc,
           107 'Página       :', 122 sy-pagno LEFT-JUSTIFIED, /.
    WRITE: /45 'Desde:', fec1,
            66 'Hasta:', fec2, /.
  ELSE.
    SKIP 8.
    WRITE: /55 TEXT-001, /.
    SELECT SINGLE ltx INTO l_mes FROM t247 WHERE spras EQ sy-langu
                                             AND mnr   EQ p_monat.
    WRITE: /45  TEXT-018, l_mes, TEXT-019, p_gjahr.
  ENDIF.

  SKIP 4.

  ULINE.

  IF p_iev EQ 'X'.
    WRITE: /01 'DE', 'A', 'Linea'.
    WRITE:  12 TEXT-101,
            15 TEXT-110,
            36 TEXT-102,
            47 TEXT-103,
            65 TEXT-109,
            79 TEXT-009 RIGHT-JUSTIFIED,
            94 TEXT-104 RIGHT-JUSTIFIED.
  ELSE.
    WRITE:/01 TEXT-100,
           07 TEXT-101,
           10 TEXT-110,
           31 TEXT-102,
           42 TEXT-103,
           60 TEXT-109,
           74 TEXT-009 RIGHT-JUSTIFIED,
           89 TEXT-104 RIGHT-JUSTIFIED.
  ENDIF.
  WRITE: 131 TEXT-010 RIGHT-JUSTIFIED,
             TEXT-011 RIGHT-JUSTIFIED,
             TEXT-012 RIGHT-JUSTIFIED,
             TEXT-013 RIGHT-JUSTIFIED.
*-> BEG INS V1-CNN ECDK922573 Facturación el línea HELP
  WRITE: 195 TEXT-127 LEFT-JUSTIFIED,
             TEXT-129 LEFT-JUSTIFIED.
*-> END INS V1-CNN ECDK922573 Facturación el línea HELP
  ULINE.

ENDFORM.                    " HEADER


*&---------------------------------------------------------------------*
*&      Form  WRITE_HEADER_FACT
*&---------------------------------------------------------------------*
FORM write_header_fact USING p_ok.

  DATA: cliente(35),
        str(16),
        rut_form(13).
  DATA desc TYPE c LENGTH 19.
  DATA tipo(2).
  DATA: ok_upd TYPE boolean,
        ind    TYPE sy-tabix,
        anul   TYPE c.
  DATA tmp_belnr LIKE tabla-belnr.
  TABLES nast.
*
  ADD 1 TO zlinea.
  str = tabla-xblnr.
  doc_zero = '1'.
  CLEAR desc.
  CASE tabla-blart.
    WHEN 'G1'.
      desc = TEXT-111.
    WHEN 'G2'.
      desc = TEXT-112.
    WHEN 'G3'.
      desc = TEXT-113.
    WHEN 'G4'.
      desc = TEXT-114.
    WHEN 'J1'.
      desc = TEXT-115.
    WHEN 'J2'.
      desc = TEXT-116.
    WHEN 'J3'.
      desc = TEXT-117.
    WHEN 'J4'.
      desc = TEXT-118.
    WHEN 'L1'.
      desc = TEXT-119.
    WHEN 'L2'.
      desc = TEXT-120.
    WHEN 'L3'.
      desc = TEXT-121.
    WHEN 'L4'.
      desc = TEXT-122.
    WHEN 'O1'.
      desc = TEXT-123.
    WHEN 'O2'.
      desc = TEXT-124.
    WHEN 'O3'.
      desc = TEXT-125.
    WHEN 'O4'.
      desc = TEXT-126.
  ENDCASE.
  IF p_ok = 'X'.
    PERFORM edit_stcd1 USING tabla-stcd1 CHANGING rut_form.
    CONCATENATE tabla-name1 tabla-name2 INTO cliente SEPARATED BY space.
    doc_zero = '0'.
    CLEAR tipo.

    CASE tabla-blart.
      WHEN 'BV'.
        READ TABLE res_ventas WITH KEY blart = 'BO'.
        IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
        tipo = '35'.
      WHEN 'RD'.
        READ TABLE res_ventas WITH KEY blart = 'ND'.
        IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
        tipo = '56'.
      WHEN 'YN'.
        tipo = '61'.
      WHEN 'RG'.
        READ TABLE res_ventas WITH KEY blart = 'NC'.
        IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
        tipo = '61'.
      WHEN 'YF'.
        CASE tabla-mwskz.
          WHEN '02' OR 'D3'.
            tipo = '34'.
          WHEN OTHERS.
            tipo = '33'.
        ENDCASE.
      WHEN 'RV' OR 'RP' OR 'DR'.
        CASE tabla-mwskz.
*    when mwskz_exe.
*        when 'D0'.
          WHEN '02'.
            READ TABLE res_ventas WITH KEY blart = 'FE'.
            IF sy-subrc = 0.
              ok_upd = 'X'.
              ind = sy-tabix.
            ENDIF.
            tipo = '34'.
          WHEN 'D3'.
            READ TABLE res_ventas WITH KEY blart = 'FE'.
            IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
            tipo = '34'.
          WHEN '18'.
            READ TABLE res_ventas WITH KEY blart = 'FA'.
            IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
            tipo = '33'.
          WHEN '**' OR '  '.
            IF tabla-impue <> '0'.
              READ TABLE res_ventas WITH KEY blart = 'FA'.
              IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
            ELSE.
              READ TABLE res_ventas WITH KEY blart = 'FE'.
              IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
            ENDIF.
        ENDCASE.
    ENDCASE.

    CLEAR tmp_belnr.
    tmp_belnr = tabla-vbeln.
    WHILE tmp_belnr(1) = '0'.
      SHIFT tmp_belnr LEFT.
    ENDWHILE.
    DO 2 TIMES.
      SHIFT tmp_belnr RIGHT.
      WRITE '0' TO tmp_belnr(1).
    ENDDO.

    SELECT SINGLE * FROM vbpa WHERE vbeln EQ tabla-vbeln
                                AND parvw EQ 'RE'.
**mod ini
    SELECT SINGLE KAPPL, OBJKY, KSCHL, SPRAS,
      PARNR, PARVW, ERDAT,ERUHR
       FROM nast
      INTO @data(ls_nast)
      WHERE kappl = 'V3'
       AND objky = @tmp_belnr
       AND kschl = 'ZDTE'
       AND spras = @sy-langu
       AND parnr = @vbpa-kunnr
       AND parvw = 'RE'
       AND nacha = '1'
       AND vstat = '1'.
**mod fin
    IF sy-subrc NE 0.
*
      CASE tipo.
        WHEN '33'. MOVE '30' TO tipo.  "factura
        WHEN '34'. MOVE '32' TO tipo.  "factura exenta electronica
        WHEN '52'. MOVE '50' TO tipo.  "guia de despacho
        WHEN '61'. MOVE '60' TO tipo.  "nota de credito
        WHEN '56'. MOVE '55' TO tipo.  "nota de debito
        WHEN '46'. MOVE '45' TO tipo.  "factura de compra
        WHEN '39'. MOVE '35' TO tipo.  "boleta
        WHEN '41'. MOVE '38' TO tipo.  "boleta exenta.
      ENDCASE.
    ENDIF.

    CLEAR anul.
    IF ok_upd = space.
      CASE p_iev.
        WHEN 'X'.
          anul     = 'A'.
          rut_form = '1-1'.
        WHEN OTHERS.
          anul = 'X'.
      ENDCASE.
    ELSE.
      IF tabla-totdoc <> 0.
      ELSE.
        CASE p_iev.
          WHEN 'X'.
            anul     = 'A'.
            rut_form = '1-1'.
          WHEN OTHERS.
            anul = 'X'.
        ENDCASE.
      ENDIF.
    ENDIF.

    IF p_iev EQ 'X'.
      WRITE:/ tipo , anul, zlinea NO-ZERO LEFT-JUSTIFIED.
    ELSE.
      WRITE:/ zlinea NO-ZERO LEFT-JUSTIFIED.
    ENDIF.
    WRITE:   tabla-blart ,
             desc         UNDER TEXT-110,
             tabla-bldat UNDER TEXT-102,
             str NO-ZERO RIGHT-JUSTIFIED UNDER TEXT-103,
             tabla-belnr UNDER TEXT-109,
             rut_form RIGHT-JUSTIFIED UNDER TEXT-009,
             cliente UNDER TEXT-104.
  ELSE.
    doc_zero = '0'.
    WRITE: /04 zlinea NO-ZERO LEFT-JUSTIFIED,
            08 tabla-blart,
               desc UNDER TEXT-110,
               tabla-bldat UNDER TEXT-102,
               str NO-ZERO RIGHT-JUSTIFIED UNDER TEXT-103,
               tabla-belnr UNDER TEXT-009,
               TEXT-020 UNDER TEXT-104.
  ENDIF.
  IF doc_zero = '1'.
    CLEAR tabla-exent.
    CLEAR tabla-impue.
    CLEAR tabla-impue-5.
    CLEAR tabla-totdoc.
    CLEAR tabla-exent_mt.
    CLEAR tabla-totdoc_mt.
  ENDIF.

ENDFORM.                               " WRITE_HEADER_FACT

*&---------------------------------------------------------------------*
*&      Form  EDIT_STCD1
*&---------------------------------------------------------------------*
FORM edit_stcd1 USING p_in CHANGING p_out.
  DATA: i_length TYPE p.
*
  p_out = p_in.
  IF p_in IS INITIAL. EXIT. ENDIF.
  IF p_in <> '0-0'.
    TRANSLATE p_in USING '- '.
    CONDENSE p_in NO-GAPS.
    i_length = 10 - strlen( p_in ).
    SHIFT p_in BY i_length PLACES RIGHT.
    WRITE p_in TO p_out USING EDIT MASK '___.___.___-_'.
  ENDIF.
ENDFORM.                               " EDIT_STCD1

*&---------------------------------------------------------------------*
*&      Form  DET_LINE
*&---------------------------------------------------------------------*
FORM det_line.

  IF tabla-anul EQ 'X' .


  ELSEIF tabla-bole EQ 'X'.         " Boletas de venta
    PERFORM write_header_fact USING 'X'.
    IF doc_zero = '0'.
      PERFORM write_lin_fact_det USING 'X'
                                  tabla-afect
                                  tabla-exent
                                  tabla-impue
                                  tabla-impue-5
                                  tabla-exporta
                                  tabla-totdoc
                                  tabla-exent_mt
                                  tabla-totdoc_mt
                                  tabla-vertn
                                  tabla-vertt.

      HIDE  tabla-belnr.
      CLEAR tabla-belnr.
    ENDIF.
  ELSEIF tabla-zero EQ 'X'.         " Documentos con Valor cero.
    PERFORM write_header_fact USING 'X'.
    WRITE tabla-altext.
    HIDE  tabla-belnr.
    CLEAR tabla-belnr.
  ELSE.
    PERFORM write_header_fact USING 'X'.
    IF doc_zero = '0'.
      PERFORM write_lin_fact_det USING 'X'
                                   tabla-afect
                                   tabla-exent
                                   tabla-impue
                                   tabla-impue-5
                                   tabla-exporta
                                   tabla-totdoc
                                   tabla-exent_mt
                                   tabla-totdoc_mt
                                   tabla-vertn
                                   tabla-vertt.
    ENDIF.
    HIDE  tabla-belnr.
    CLEAR tabla-belnr.
  ENDIF.
ENDFORM.                    " DET_LINE

*&---------------------------------------------------------------------*
*&      Form  WRITE_AMOUNT_FACT
*&---------------------------------------------------------------------*
FORM write_amount_fact USING p_mt
                             p_afect
                             p_exent
                             p_impue
                             p_impue-5
                             p_exporta
                             p_totdoc
                             p_exent_mt
                             p_totdoc_mt.

  DATA: char_afec(14),
        char_exen(14),
        char_impu(14),
        char_impu-5(14),
        char_tota(16),
        char_exen_mt(11),
        char_tota_mt(16),
        char_prop(14),
        char_expo(14).

  PERFORM convert_to_char USING p_afect     char_afec.
  PERFORM convert_to_char USING p_exent     char_exen.
  PERFORM convert_to_char USING p_impue     char_impu.
  PERFORM convert_to_char USING p_impue-5   char_impu-5.
  PERFORM convert_to_char USING p_totdoc    char_tota.
  PERFORM convert_to_char USING p_exent_mt  char_exen_mt.
  PERFORM convert_to_char USING p_totdoc_mt char_tota_mt.
*
  PERFORM convert_to_char USING p_exporta   char_expo.
*
  WRITE: char_exen   UNDER TEXT-011,
         char_afec   UNDER TEXT-010,
         char_impu   UNDER TEXT-012,
         char_expo   UNDER TEXT-106,
*        char_impu-5 UNDER text-014,
         char_tota   UNDER TEXT-013.

ENDFORM.                               " WRITE_AMOUNT_FACT

*&---------------------------------------------------------------------*
*&      Form  WRITE_LIN_FACT_DET
*&---------------------------------------------------------------------*
FORM write_lin_fact_det USING p_mt
                             p_afect
                             p_exent
                             p_impue
                             p_impue-5
                             p_exporta
                             p_totdoc
                             p_exent_mt
                             p_totdoc_mt
                             p_vertn
                             p_vertt.

  DATA: char_afec(14),
        char_exen(14),
        char_impu(14),
        char_impu-5(14),
        char_tota(16),
        char_exen_mt(11),
        char_tota_mt(16),
        char_prop(14),
        char_expo(14).

  PERFORM convert_to_char USING p_afect     char_afec.
  PERFORM convert_to_char USING p_exent     char_exen.
  PERFORM convert_to_char USING p_impue     char_impu.
  PERFORM convert_to_char USING p_impue-5   char_impu-5.
  PERFORM convert_to_char USING p_totdoc    char_tota.
  PERFORM convert_to_char USING p_exent_mt  char_exen_mt.
  PERFORM convert_to_char USING p_totdoc_mt char_tota_mt.
*
  PERFORM convert_to_char USING p_exporta   char_expo.
*
  WRITE: char_exen   UNDER TEXT-011,
         char_afec   UNDER TEXT-010,
         char_impu   UNDER TEXT-012,
         char_expo   UNDER TEXT-106,
         char_tota   UNDER TEXT-013,
         p_vertn     UNDER TEXT-127 RIGHT-JUSTIFIED,
         p_vertt     UNDER TEXT-129.

ENDFORM.                               " WRITE_LIN_FACT_DET


*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_CHAR
*&---------------------------------------------------------------------*
FORM convert_to_char USING p_amount p_char_amount.
  CLEAR p_char_amount.
  IF p_amount = 0. EXIT. ENDIF.
  WRITE p_amount CURRENCY t001-waers TO p_char_amount.
ENDFORM.                               " CONVERT_TO_CHAR

*&---------------------------------------------------------------------*
*&      Form  FILL_RANGE_BUDAT
*&---------------------------------------------------------------------*
FORM fill_range_budat.
  DATA: mes     LIKE bkpf-monat,
        ano     LIKE bkpf-gjahr,
        fec_fin TYPE sy-datum.
  PERFORM fill_budat USING p_monat p_gjahr.
  fec_fin = br_budat-high.
  IF mes = 1.
    mes = 12.
    ano = p_gjahr - 1.
  ELSE.
    mes = p_monat - 1.
    ano = p_gjahr.
  ENDIF.
  PERFORM fill_budat USING mes ano.
  br_budat-high = fec_fin.
  MODIFY br_budat INDEX 1.
ENDFORM.                    " FILL_RANGE_BUDAT

*&---------------------------------------------------------------------*
*&      Form  SUM_RESUMEN
*&---------------------------------------------------------------------*
FORM sum_resumen.

  DATA: ok_upd   TYPE boolean,
        ind      TYPE sy-tabix,
        val1(10) TYPE c,
        val2(10) TYPE c,
        val3     TYPE i.
*
  ind = 0.

  CASE tabla-blart.
    WHEN 'DB'.  "NOTA DEBITO
      READ TABLE res_ventas WITH KEY blart = tabla-blart.
      IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
    WHEN 'DG'.  "NOTA DE CREDITO
      READ TABLE res_ventas WITH KEY blart = tabla-blart.
      IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
    WHEN 'ZB'.  "NOTA DEBITO exportacion
      READ TABLE res_ventas WITH KEY blart = tabla-blart.
      IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
    WHEN 'ZG'.  "NOTA DE CREDITO exportacion
      READ TABLE res_ventas WITH KEY blart = tabla-blart.
      IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
    WHEN 'ZF'.  "FACTURA EXPORTACION
      READ TABLE res_ventas WITH KEY blart = tabla-blart.
      IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
    WHEN 'RV' OR 'DR' OR 'ZT' OR 'ZL'.  "FACTURAS
      CASE tabla-mwskz.
        WHEN 'D0'.
          IF tabla-impue <> 0.
            READ TABLE res_ventas WITH KEY blart = 'FA'.
            IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
          ELSE.
            READ TABLE res_ventas WITH KEY blart = 'FE'.
            IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
          ENDIF.
        WHEN 'D1'.
          READ TABLE res_ventas WITH KEY blart = 'FA'.
          IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
        WHEN '**' OR '  '.
          IF tabla-impue <> '0'.
            READ TABLE res_ventas WITH KEY blart = 'FA'.
            IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
          ELSE.
            READ TABLE res_ventas WITH KEY blart = 'FA'.
            IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
          ENDIF.
      ENDCASE.
    WHEN 'ZE'.  "FACTURA EXENTA
      READ TABLE res_ventas WITH KEY blart = 'FE'.
      IF sy-subrc = 0. ok_upd = 'X'. ind = sy-tabix. ENDIF.
    WHEN OTHERS.
      READ TABLE res_ventas WITH KEY blart = tabla-blart.
      IF sy-subrc = 0.
        ok_upd = 'X'.
        ind = sy-tabix.
      ENDIF.
  ENDCASE.

  IF ok_upd = 'X' AND tabla-anul IS INITIAL.
    val3 = 0.
    IF tabla-totdoc <> 0.
      SEARCH tabla-xblnr FOR '-'.
      IF sy-subrc EQ 0.
        SPLIT  tabla-xblnr AT '-' INTO val1 val2.
        IF val2 GT val1.
          val3 = ( val2 - val1 ) + 1.
        ELSE.
          val3 = ( val1 - val2 ) + 1.
        ENDIF.
        ADD val3 TO res_ventas-nro.
      ELSE.
        ADD 1    TO res_ventas-nro.
      ENDIF.
    ELSE.
    ENDIF.
    ADD tabla-afect   TO res_ventas-afect.
    ADD tabla-afect   TO tot-inf-afect.
*
    ADD tabla-exent   TO res_ventas-exent.
    ADD tabla-exent   TO tot-inf-exent.
*
    ADD tabla-impue   TO res_ventas-impue.
    ADD tabla-impue   TO tot-inf-impue.
*
    ADD tabla-impue-5 TO res_ventas-impue-5.
    ADD tabla-impue-5 TO tot-inf-impue-5.
*
    ADD tabla-totdoc  TO res_ventas-totdoc.
    ADD tabla-totdoc  TO tot-inf-totdoc.

    ADD tabla-exporta  TO res_ventas-exporta.
*
    ADD tabla-exporta  TO tot-inf-exporta.
*
    MODIFY res_ventas INDEX ind.
  ELSE.
**clr  para separar nul
** solo sumara como nulos los que vienen de la tabla idcn_excp
** que son grabador conn la letra N en vez de X.

**   IF NOT tabla-anul IS INITIAL.
    val3 = 0.
    IF tabla-anul = 'N'.
      SEARCH  tabla-xblnr FOR '-'.
      IF sy-subrc EQ 0.
*       SPLIT  tabla-xblnr AT '-' INTO val1 val2 IN CHARACTER MODE.
        SPLIT  tabla-xblnr AT '-' INTO val1 val2."IN CHARACTER MODE.
        IF val2 GT val1.
          val3 = ( val2 - val1 ) + 1.
        ELSE.
          val3 = ( val1 - val2 ) + 1.
        ENDIF.
        ADD val3 TO doc-nulos.
      ELSE.
        ADD 1 TO doc-nulos.
      ENDIF.
**
      IF ind > 0.
        IF val3 GT 0.
          ADD val3  TO res_ventas-nulos.
        ELSE.
          ADD 1  TO res_ventas-nulos.
        ENDIF.
        MODIFY res_ventas INDEX ind.
      ELSE.
        CLEAR res_ventas.
*        RES_VENTAS-BLART = 'XX'.
*        RES_VENTAS-NOMB  = 'Nulos NN'.
*        RES_VENTAS-NULOS = 1.
*        COLLECT RES_VENTAS.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " SUM_RESUMEN

*&---------------------------------------------------------------------*
*&      Form  PRINT_RESUM
*&---------------------------------------------------------------------*
FORM print_resum.

** Begin:V1 21.03.2014
*  DATA: znro(5)   TYPE n,
*        znulos(5) TYPE n,
  DATA: znro(6)   TYPE n,
        znulos(6) TYPE n,
** End:  V1 21.03.2014
        zafect    LIKE bseg-dmbtr,
        zexent    LIKE bseg-dmbtr,
        zimpue    LIKE bseg-dmbtr,
        zimpue-5  LIKE bseg-dmbtr,
        zpropina  LIKE bseg-dmbtr,
        zexporta  LIKE bseg-dmbtr,
        ztotdoc   LIKE bseg-dmbtr.

  NEW-PAGE.
  SKIP 2.
  WRITE: /33 'Doctos.',
*          43 'D.Nulos',
              TEXT-010 RIGHT-JUSTIFIED,
              TEXT-011 RIGHT-JUSTIFIED,
              TEXT-012 RIGHT-JUSTIFIED,
*              TEXT-106 RIGHT-JUSTIFIED,
*             text-014 RIGHT-JUSTIFIED,
              TEXT-013 RIGHT-JUSTIFIED.

  LOOP AT res_ventas.
    WRITE: /06 res_ventas-nomb,
            31 res_ventas-nro NO-ZERO RIGHT-JUSTIFIED.
*            41 RES_VENTAS-NULOS NO-ZERO RIGHT-JUSTIFIED.
    PERFORM write_amount_fact USING space
                                    res_ventas-afect
                                    res_ventas-exent
                                    res_ventas-impue
                                    res_ventas-impue-5
                                    res_ventas-exporta
                                    res_ventas-totdoc 0
                                    0.
    ADD res_ventas-nro     TO znro.
    ADD res_ventas-afect   TO zafect.
    ADD res_ventas-exent   TO zexent.
    ADD res_ventas-impue   TO zimpue.
    ADD res_ventas-impue-5 TO zimpue-5.
    ADD res_ventas-totdoc  TO ztotdoc.
    ADD res_ventas-exporta TO zexporta.
    ADD res_ventas-nulos   TO znulos.
  ENDLOOP.

  WRITE: /06 TEXT-030, 31 doc-nulos NO-ZERO RIGHT-JUSTIFIED.
  SKIP.
  ULINE AT 33(123).
  SKIP.
  ADD doc-nulos TO znro.
  WRITE: /06 'Total',
          31 znro   NO-ZERO RIGHT-JUSTIFIED.
*          41 ZNULOS NO-ZERO RIGHT-JUSTIFIED.
  PERFORM write_amount_fact USING space
                                  zafect
                                  zexent
                                  zimpue
                                  zimpue-5
                                  zexporta
                                  ztotdoc 0
                                  0.

ENDFORM.                    " PRINT_RESUM

*&---------------------------------------------------------------------*
*&      Form  RECUP_SOCIEDAD
*&---------------------------------------------------------------------*
FORM recup_sociedad.
  DATA: zname1      LIKE adrc-name1,
        zname2      LIKE adrc-name2,
        zstreet     LIKE adrc-street,
        zhouse_num1 LIKE adrc-house_num1.

  READ TABLE tabla INDEX 1.
**add comment ini
  SELECT SINGLE adrc~name1 adrc~name2 adrc~street adrc~house_num1
    INTO (zname1, zname2, zstreet, zhouse_num1)
    FROM ( t001 INNER JOIN adrc ON
           t001~adrnr EQ adrc~addrnumber )
    WHERE t001~bukrs = tabla-bukrs."#EC CI_BUFFJOIN
**add comment fin
  CONCATENATE zname1 zname2 INTO p_soc SEPARATED BY space.
  CONCATENATE zstreet zhouse_num1 INTO p_direc SEPARATED BY space.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
  SELECT SINGLE paval INTO p_rut
         FROM t001z WHERE bukrs = tabla-bukrs
                      AND party = 'TAXNR'.
ENDFORM.                    " RECUP_SOCIEDAD

*&---------------------------------------------------------------------*
*&      Form  PROCESS_OUT
*&---------------------------------------------------------------------*
FORM process_out.
  DATA: BEGIN OF tb_paso OCCURS 0,
          bukrs         LIKE bkpf-bukrs,
          blart         LIKE bkpf-blart,
          bldat         LIKE bkpf-bldat,
          xblnr         LIKE bkpf-xblnr,
          budat         LIKE bkpf-budat,
          belnr         LIKE bkpf-belnr,
          waers         LIKE bkpf-waers,
          awtyp         LIKE bkpf-awtyp,
          gjahr         LIKE bkpf-gjahr,
          bktxt         LIKE bkpf-bktxt,
          znom_cli_fact LIKE bkpf-znom_cli_fact,
        END OF tb_paso.
  DATA zkunnr TYPE kunnr.

  SELECT bukrs blart bldat xblnr budat belnr waers awtyp gjahr bktxt
                         FROM bkpf INTO TABLE tb_paso
                         WHERE bukrs = tabla-bukrs
                           AND bstat = 'S'
                           AND stblg IS NOT NULL
                           AND ( blart = 'RG' OR blart = 'RD' )
                           AND gjahr = p_gjahr
                           AND monat = p_monat.
  LOOP AT tb_paso.
    CLEAR tabla.
    MOVE-CORRESPONDING tb_paso TO tabla.
*    MOVE TB_PASO-ZNOM_CLI_FACT TO TABLA-NAME1.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
    SELECT SINGLE kunnr INTO zkunnr FROM bseg
                        WHERE bukrs = tb_paso-bukrs
                          AND belnr = tb_paso-belnr
                          AND gjahr = tb_paso-gjahr.
    SELECT SINGLE name1 name2 stcd1 INTO
                  (tabla-name1, tabla-name2, tabla-stcd1)
             FROM kna1 WHERE kunnr = zkunnr.
*
    PERFORM verifica_xblr CHANGING tabla-xblnr.
*
    APPEND tabla.
  ENDLOOP.
ENDFORM.                    " PROCESS_OUT

*&---------------------------------------------------------------------*
*&      Form  PROCESS_NULL
*&---------------------------------------------------------------------*
FORM process_null.

  DATA: BEGIN OF tb_paso OCCURS 0,
          bukrs     LIKE bkpf-bukrs,
          blart(04),
          bldat     LIKE bkpf-bldat,
          xblnr     LIKE bkpf-xblnr,
          budat     LIKE bkpf-budat,
          belnr     LIKE bkpf-belnr,
        END OF tb_paso.
  DATA: fec1   TYPE sy-datum,
        fec2   TYPE sy-datum,
        xvidrs LIKE idcn_excp-vidrs.

  xvidrs = '0001'.

  IF br_budat-low IS INITIAL AND br_budat-high IS INITIAL.
    CONCATENATE p_gjahr p_monat '01' INTO fec1.
    CALL FUNCTION 'SLS_MISC_GET_LAST_DAY_OF_MONTH'
      EXPORTING
        day_in            = fec1
      IMPORTING
        last_day_of_month = fec2.
  ELSE.
    MOVE br_budat-low  TO fec1.
    MOVE br_budat-high TO fec2.
  ENDIF.
  IF p_werks-low IS INITIAL.
    SELECT bukrs lotno AS blart issdt AS bldat xblnr
                    issdt AS budat invno AS belnr
                    FROM idcn_excp INTO TABLE tb_paso
                    WHERE
                    bukrs = br_bukrs-low
                    AND   issdt BETWEEN fec1 AND fec2
                    AND   lotno <> 'YE00'. "***Guias de Despacho
  ELSE.
    SELECT bukrs lotno AS blart issdt AS bldat xblnr
                    issdt AS budat invno AS belnr
                    FROM idcn_excp INTO TABLE tb_paso
                    WHERE bukrs = br_bukrs-low
                    AND   vidrs  = xvidrs
                    AND   issdt BETWEEN fec1 AND fec2
                    AND   lotno <> 'YE00'.   "***Guias de Despacho
  ENDIF.
  LOOP AT tb_paso.

    SELECT SINGLE * FROM idcn_loma WHERE bukrs = tb_paso-bukrs
                                   AND   lotno = tb_paso-blart.

*DB	Nota de Debito
*DG	Nota de Credito
*RV	Factura Afecta
*ZB	Nota Debito Exporta
*ZE	Factura Exenta
*ZF	Factura Exportacion
*ZG	Nota Credito Exporta

    CLEAR tabla.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = tb_paso-belnr
      IMPORTING
        output = tb_paso-xblnr.
    MOVE-CORRESPONDING tb_paso TO tabla.

    CONCATENATE tb_paso-budat+6(2) '.' tb_paso-budat+4(2) '.'
                tb_paso-budat+0(4)               INTO tabla-bktxt.
    tabla-waers = 'CLP'.
**    CASE tb_paso-blart.
*    CASE IDCN_LOMA-INVTP.
*      WHEN 'RV'.
*        TABLA-NAME1 = 'Factura         Anulada'.
*        TABLA-BLART = 'RV'.
*      WHEN 'ZE'.
*        TABLA-NAME1 = 'Factura Exenta  Anulada'.
*        TABLA-BLART = 'ZE'.
*      WHEN 'ZF'.
*        TABLA-NAME1 = 'Factura Export. Anulada'.
*        TABLA-BLART = 'ZF'.
*      WHEN 'DB'.
*        TABLA-NAME1 = 'Nota Debito,    Anulada.'.
*        TABLA-BLART = 'DB'.
*      WHEN 'DG'.
*        TABLA-NAME1 = 'Nota Credito,   Anulada.'.
*        TABLA-BLART = 'DG'.
*      WHEN 'BV'.
*        TABLA-NAME1 = 'Boleta,         Anulada.'.
*        TABLA-BLART = 'BV'.
*      WHEN 'BE'.
*        TABLA-NAME1 = 'Boleta Exenta,  Anulada.'.
*        TABLA-BLART = 'BE'.
*      WHEN 'BN'.
*        TABLA-NAME1 = 'Boleta Nomtva.  Anulada.'.
*        TABLA-BLART = 'BN'.
*      WHEN 'AT'.
*        TABLA-NAME1 = 'Actas Tragam.   Anulada.'.
*      WHEN 'AJ'.
*        TABLA-NAME1 = 'Actas Juego     Anulada.'.
*      WHEN OTHERS.
*        CONCATENATE 'Folio ' TABLA-BLART ',Anulada'
*                                   INTO TABLA-NAME1 SEPARATED BY SPACE.
*    ENDCSE.
    tabla-name1 = 'Nulo'.
    IF NOT so_fac IS INITIAL AND idcn_loma-invtp IN so_fac.
      tabla-name1 = 'Factura,   Anulada.'.
      tabla-blart = idcn_loma-invtp.
    ENDIF.
    IF NOT so_nd IS INITIAL AND idcn_loma-invtp IN so_nd.
      tabla-name1 = 'Nota Débito,   Anulada.'.
      tabla-blart = idcn_loma-invtp.
    ENDIF.
    IF NOT so_nc IS INITIAL AND idcn_loma-invtp IN so_nc.
      tabla-name1 = 'Nota Credito,   Anulada.'.
      tabla-blart = idcn_loma-invtp.
    ENDIF.
    IF NOT so_bol IS INITIAL AND idcn_loma-invtp IN so_bol.
      tabla-name1 = 'Boleta,   Anulada.'.
      tabla-blart = idcn_loma-invtp.
    ENDIF.

    IF p_werks-low IS INITIAL.
      MOVE 'OVFI' TO tabla-werks.
    ELSE.
      MOVE p_werks-low TO tabla-werks.
    ENDIF.
*
    PERFORM verifica_xblr CHANGING tabla-xblnr.
*
    tabla-anul = 'N'.

    APPEND tabla.
  ENDLOOP.

ENDFORM.                    " PROCESS_NULL

*&---------------------------------------------------------------------*
*&      Form  AT_LINE_SELECTION
*&---------------------------------------------------------------------*
FORM at_line_selection.
  IF NOT tabla-belnr IS INITIAL.
    SET PARAMETER ID 'BLN' FIELD tabla-belnr.
    SET PARAMETER ID 'BUK' FIELD tabla-bukrs.
    SET PARAMETER ID 'GJR' FIELD p_gjahr.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.
  CLEAR tabla-belnr.
ENDFORM.                    " AT_LINE_SELECTION
*&---------------------------------------------------------------------*
*&      Form  busca-anulada
*&---------------------------------------------------------------------*
FORM busca-anulada.
  SELECT SINGLE * FROM vbrk WHERE vbeln EQ bkpf-awkey.
  SELECT SINGLE * FROM vbrp WHERE vbeln EQ bkpf-awkey.
ENDFORM.                    " busca-anulada
*&---------------------------------------------------------------------*
*&      Form  CARGA-OFICINA-VENTAS-FI
*&---------------------------------------------------------------------*
FORM carga-oficina-ventas-fi.
  v_werks = 'OVFI'.
ENDFORM.                    " CARGA-OFICINA-VENTAS-FI

*---------------------------------------------------------------------*
*       FORM CARGA-OFICINA-VENTAS-SD                                  *
*---------------------------------------------------------------------*
FORM carga-oficina-ventas-sd.

  v_werks = vbrp-werks.

ENDFORM.                    " CARGA-OFICINA-VENTAS-SD
*&---------------------------------------------------------------------*
*&      Form  procesa-num-duplicados
*&---------------------------------------------------------------------*
FORM procesa-num-duplicados.

  SORT tabla BY xblnr.
  MOVE 'SI' TO ws-primer.
  LOOP AT tabla.
    IF  ws-primer = 'SI'.
      MOVE 'NO'        TO ws-primer.
      MOVE tabla-xblnr TO ws-xblnr.
    ELSE.
      IF tabla-xblnr  EQ ws-xblnr.
        IF NOT tabla-xblnr = '0000000000000000'.
*aca ABRIR LA IMPRESIÓN PARA TODA LA TABLA
          WRITE :/ tabla-xblnr.
        ENDIF.
        DELETE tabla.
      ELSE.
        MOVE tabla-xblnr TO ws-xblnr.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " procesa-num-duplicados
*&---------------------------------------------------------------------*
*&      Form  nc_feerratas
*&---------------------------------------------------------------------*
FORM nc_feerratas.

  TABLES:  znc_especial.
  CLEAR tabla.

  SELECT * FROM znc_especial.
    IF znc_especial-sociedad   EQ br_bukrs-low AND
       znc_especial-fecha+0(4) EQ p_gjahr AND
       znc_especial-fecha+4(2) EQ p_monat.

      MOVE znc_especial-sociedad TO tabla-bukrs.
      MOVE znc_especial-numero   TO tabla-xblnr.
      MOVE znc_especial-rut      TO tabla-stcd1.
      MOVE znc_especial-nombre   TO tabla-name1.
      MOVE znc_especial-fecha    TO tabla-bldat.
      MOVE znc_especial-blart    TO tabla-blart.
      MOVE znc_especial-moneda   TO tabla-waers.
      APPEND tabla.
    ENDIF.
  ENDSELECT.

ENDFORM.                    " nc_feerratas
*&---------------------------------------------------------------------*
*&      Form  imprmir_libro
*&---------------------------------------------------------------------*
FORM imprmir_libro .

  SELECT SINGLE * FROM usr01 WHERE bname = sy-uname.
  itcpo-tddest    = usr01-spld.
  itcpo-tdcover   = ' '.
  itcpo-tdimmed   = 'X'.
  itcpo-tddelete  = 'X'.
  itcpo-tdcopies  = 1.
  itcpo-tdreceiver = sy-uname.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      form     = 'ZCALLETR_AZA'
*     FORM     = 'ZARFIF_LETRAS'
      options  = itcpo
      device   = 'PRINTER'
      dialog   = 'X'
    EXCEPTIONS
      canceled = 1
      device   = 2
      form     = 3
      options  = 4
      unclosed = 5.

  IF sy-subrc <> 0.
    swerror = 1.
  ENDIF.

*Nombre Cliente
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'NOM_CLI'
      element = '1000'.
*Direccion Cliente
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'DIR_CLI'
      element = '1010'.
*Ciudad Cliente
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'CIU_CLI'
      element = '1020'.
*RUT Cliente
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'RUT_CLI'
      element = '1030'.
*FACTURAS
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'FACTURAS'
      element = '1100'.
*FECHA DE VENCIMIENTO
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'FEC_VTO'
      element = '1200'.
*FECHA DE VENCIMIENTO 2
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'FEC_VTO2'
      element = '1300'.
*FECHA DIA
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'FEC_DIA'
      element = '1400'.
*FECHA MES
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'FEC_MES'
      element = '1410'.
*FECHA ANO
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'FEC_ANO'
      element = '1420'.

*FECHA CANT_NUM
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'CANT_NUM'
      element = '1500'.
*FECHA CANT_NUM
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'CANT_PAL'
      element = '1600'.
*NUMERO DE LETRA
  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      window  = 'NUM_LETR'
      element = '1700'.

*Cierre Formulario
  CALL FUNCTION 'CLOSE_FORM'.

ENDFORM.                    " imprmir_libro
*&---------------------------------------------------------------------*
*&      Form  comment_build
*&---------------------------------------------------------------------*
FORM comment_build USING lt_top_of_page TYPE slis_t_listheader.
  DATA: ls_line TYPE slis_listheader.
*
  REFRESH lt_top_of_page.
  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = TEXT-tit.
  APPEND ls_line TO lt_top_of_page.
  CLEAR ls_line.
  ls_line-typ  = 'S'.
  MOVE TEXT-fec   TO ls_line-key.
  WRITE sy-datum  TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.

  MOVE TEXT-hor TO ls_line-key.
  WRITE sy-uzeit  TO  ls_line-info.
  APPEND ls_line TO lt_top_of_page.

ENDFORM.                    " comment_build
*&---------------------------------------------------------------------*
*&      Form  layout
*&---------------------------------------------------------------------*
FORM layout USING    p_gs_layout TYPE slis_layout_alv.

  CLEAR p_gs_layout.
  p_gs_layout-f2code                = 'DISPLAY'.
  p_gs_layout-zebra                 = 'X'.
  p_gs_layout-totals_text           = 'TOTAL'.
  p_gs_layout-group_change_edit     = 'X'.
  p_gs_layout-detail_popup          = 'X'.
  p_gs_layout-detail_initial_lines  = 'X'.
  p_gs_layout-colwidth_optimize     = 'X'.
  p_gs_layout-min_linesize          = 132.
  p_gs_layout-no_vline              = 'X'.

  p_gs_layout-get_selinfos          = 'X'.
  p_gs_layout-group_change_edit     = 'X'.

ENDFORM.                    " layout
*&---------------------------------------------------------------------*
*&      Form  evento
*&---------------------------------------------------------------------*
FORM evento USING    p_lt_events TYPE slis_t_event
                     p_evento_name
                     p_evento_form.
  DATA :   ls_event   TYPE slis_alv_event.


  ls_event-name = p_evento_name.
  ls_event-form = p_evento_form.
  APPEND ls_event TO p_lt_events.

ENDFORM.                    " evento
*&---------------------------------------------------------------------*
*&      Form  fieldcat
*&---------------------------------------------------------------------*
FORM fieldcat USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA : ls_fieldcat      TYPE slis_fieldcat_alv,
         datatype         LIKE dd03l-datatype,
         tabla(30)        TYPE c VALUE 'REG_SALIDA',
         lv_alvbuffer(11) TYPE c.
*
  lv_alvbuffer = 'BFOFF EUOFF'.
  SET PARAMETER ID 'ALVBUFFER' FIELD lv_alvbuffer.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_internal_tabname     = tabla
      i_inclname             = g_repid
    CHANGING
      ct_fieldcat            = xt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE e000 WITH 'Error generating field catalog'.
  ENDIF.
*
  LOOP AT xt_fieldcat INTO ls_fieldcat.
    CASE ls_fieldcat-fieldname.
      WHEN 'ANUL'.
        MOVE 'Anulados'           TO ls_fieldcat-seltext_m.
      WHEN 'BELNR'.
        MOVE 'Doc. SAP'           TO ls_fieldcat-seltext_m.
        MOVE 'X'                  TO ls_fieldcat-hotspot.
        MOVE 'X'                  TO ls_fieldcat-key_sel.
        MOVE ' '                  TO ls_fieldcat-key.
      WHEN 'XBLNR'.
        MOVE 'Referencia'         TO ls_fieldcat-seltext_m.
      WHEN 'NAME1'.
        MOVE 'Razon Social'       TO ls_fieldcat-seltext_m.
      WHEN 'BLART'.
        MOVE 'X'                  TO ls_fieldcat-just.
      WHEN 'AFECT'.
        MOVE 'Valor neto'         TO ls_fieldcat-seltext_m.
        MOVE 'X'                  TO ls_fieldcat-do_sum.
      WHEN 'EXENT'.
        MOVE 'Exento'             TO ls_fieldcat-seltext_m.
        MOVE 'X'                  TO ls_fieldcat-do_sum.
      WHEN 'IMPUE'.
        MOVE 'I.V.A.'             TO ls_fieldcat-seltext_m.
        MOVE 'X'                  TO ls_fieldcat-do_sum.
      WHEN 'TOTDOC'.
        MOVE 'Total Doc.'         TO ls_fieldcat-seltext_m.
        MOVE 'X'                  TO ls_fieldcat-do_sum.
      WHEN 'WAERS' OR 'MWSKZ' OR 'HWSTE_CT'.
        MOVE 'X'                  TO ls_fieldcat-no_out.
    ENDCASE.
    ls_fieldcat-ddictxt = 'M'.
*
    APPEND ls_fieldcat TO lt_fieldcat.
    CLEAR ls_fieldcat.
  ENDLOOP.
*
ENDFORM.                    " fieldcat
*&---------------------------------------------------------------------*
*&      Form  alv_top_of_list
*&---------------------------------------------------------------------*
FORM alv_top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "ALV_TOP_OF_LIST
*&---------------------------------------------------------------------*
*&      Form  sort
*&---------------------------------------------------------------------*
FORM sort USING    p_gt_sort  TYPE slis_t_sortinfo_alv.
  DATA: ls_sort TYPE slis_sortinfo_alv.

  REFRESH p_gt_sort.
*
  MOVE 'BLART'     TO ls_sort-fieldname.
  MOVE 'T_SALIDA'  TO ls_sort-tabname.
  ADD 1            TO ls_sort-spos.
  APPEND ls_sort TO p_gt_sort.
  CLEAR ls_sort.
*
  MOVE 'BLDAT'     TO ls_sort-fieldname.
  MOVE 'T_SALIDA'  TO ls_sort-tabname.
  ADD 1            TO ls_sort-spos.
  APPEND ls_sort TO p_gt_sort.

ENDFORM.                    " sort
*&---------------------------------------------------------------------*
*&      Form  verifica_xblr
*&---------------------------------------------------------------------*
FORM verifica_xblr  CHANGING p_tabla_xblnr.

  DATA : xnum(10)   TYPE c VALUE '0123456789'.
  SEARCH xnum FOR  p_tabla_xblnr+0(1).
  IF sy-subrc <> 0 .
    p_tabla_xblnr = p_tabla_xblnr+3.
  ENDIF.
***
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = p_tabla_xblnr
    IMPORTING
      output = p_tabla_xblnr.

ENDFORM.                    " verifica_
*&---------------------------------------------------------------------*
*&      Form  LOAD_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SO_FAC  text
*      -->P_1039   text
*----------------------------------------------------------------------*
FORM load_doc TABLES blart STRUCTURE so_fac
               USING low.

  CLEAR blart.
  blart-sign   = 'I'.
  blart-option = 'EQ'.
  blart-low    = low.
  APPEND blart.

  res_ventas-blart = low.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
  SELECT SINGLE ltext INTO res_ventas-nomb FROM t003t WHERE spras EQ
  sy-langu
                                                        AND blart EQ low
                                                        .
  APPEND res_ventas.

ENDFORM.                    " LOAD_DOC
