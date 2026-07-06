*&---------------------------------------------------------------------*
*& Include ZFIMDP_REVALIDADOR_TOP                            Modulpool        ZFIMDP_REVALIDADOR
*&
*&---------------------------------------------------------------------*

PROGRAM  zfimdp_revalidador.

TABLES: bkpf, bseg, t012, payr, t012t, zfirmadigital, lfa1, zagencia,
        skb1.
DATA: c_vall.  "Visualiza todos los documentos.
CONSTANTS: c_timbrado TYPE char10 VALUE 'Timbrado'.
CONSTANTS: c_revalid  TYPE char10 VALUE 'Revalidado'.

* Sociedad
SELECTION-SCREEN BEGIN OF SCREEN 0101 AS SUBSCREEN.
SELECT-OPTIONS: bukrs FOR bkpf-bukrs NO INTERVALS NO-EXTENSION OBLIGATORY.
SELECTION-SCREEN END OF SCREEN 0101.
* Banco
SELECTION-SCREEN BEGIN OF SCREEN 0102 AS SUBSCREEN.
SELECT-OPTIONS: hbkid FOR t012-hbkid NO INTERVALS NO-EXTENSION OBLIGATORY.
SELECTION-SCREEN END OF SCREEN 0102.
* Area
SELECTION-SCREEN BEGIN OF SCREEN 0103 AS SUBSCREEN.
SELECT-OPTIONS: xref2_hd FOR bkpf-xref2_hd.
SELECTION-SCREEN END OF SCREEN 0103.
* Fecha de revalidación
SELECTION-SCREEN BEGIN OF SCREEN 0104 AS SUBSCREEN.
SELECT-OPTIONS: budat FOR bkpf-budat.
SELECTION-SCREEN END OF SCREEN 0104.
* Nueva fecha revalidación
*SELECTION-SCREEN BEGIN OF SCREEN 0105 AS SUBSCREEN.
*PARAMETERS: budat1 LIKE bkpf-budat.
*SELECTION-SCREEN END OF SCREEN 0105.
* N° de cheque
SELECTION-SCREEN BEGIN OF SCREEN 0106 AS SUBSCREEN.
SELECT-OPTIONS: zuonr FOR bseg-zuonr NO INTERVALS.
SELECTION-SCREEN END OF SCREEN 0106.

* Definición tabla interna a utilizar para Table Control

DATA: BEGIN OF t_data OCCURS 0,
        marca(1),                         " Marca del registro
        xref2_hd LIKE bkpf-xref2_hd,      " Concepto
        zzmot_emis LIKE bseg-zzmot_emis,  " Motivo
        text1 LIKE t012t-text1,           " Nombre Banco
        bukrs LIKE bseg-bukrs,            " Sociedad
        belnr LIKE bkpf-belnr,            " N° de documento
        budat LIKE bkpf-budat,            " Fecha revalidación
        zuonr LIKE bseg-zuonr,            " N° del cheque
        dmbtr(16),                        " Monto
        gjahr LIKE bkpf-gjahr,            " Ejercicio
        hkont LIKE bseg-hkont,            " N° de cuenta
        zz_agencia LIKE bseg-zz_agencia,  " Agencia
        lifnr LIKE bseg-lifnr,            " Acreedor
        name1 LIKE lfa1-name1,             " nombre acredor
        stcd1 LIKE lfa1-stcd1,            "Rut acreedor
        status TYPE char10,               " Estado del documento
    END OF t_data.

DATA: BEGIN OF t_data1 OCCURS 0,
        bukrs LIKE bseg-bukrs,            " Sociedad
        text1 LIKE t012t-text1,           " Nombre Banco
        xref2_hd LIKE bkpf-xref2_hd,      " Concepto
        budat LIKE bkpf-budat,            " Fecha revalidación
        zzmot_emis LIKE bseg-zzmot_emis,  " Motivo
        zuonr LIKE bseg-zuonr,            " N° del cheque
        dmbtr TYPE i,                 " Monto
        belnr LIKE bkpf-belnr,            " N° de documento
        lifnr LIKE bseg-lifnr,            " Acreedor
        name1 LIKE lfa1-name1,             " nombre acredor
        stcd1 LIKE lfa1-stcd1,            "Rut acreedor
        status TYPE char10,               " Estado del documento

    END OF t_data1.

DATA: BEGIN OF t_reporte OCCURS 0,
        zz_agencia LIKE bseg-zz_agencia,  " Agencia
        zzdescr LIKE zagencia-zzdescr,  " Descripción agencia
        bukrs LIKE bseg-bukrs,            " Sociedad
        text1 LIKE t012t-text1,           " Nombre Banco
        xref2_hd LIKE bkpf-xref2_hd,      " Concepto
        budat LIKE bkpf-budat,            " Fecha revalidación
        zzmot_emis LIKE bseg-zzmot_emis,  " Motivo
        rut LIKE lfa1-stcd1,              " Rut
        zuonr LIKE bseg-zuonr,            " N° del cheque
        name1 LIKE lfa1-name1,            " Nombre acreedor
        dmbtr LIKE bseg-dmbtr,            " Monto
        belnr LIKE bkpf-belnr,            " N° de documento
        color(4),                         " Color de la fila
*        cantid TYPE i,                    " Cheques
  END OF t_reporte.

DATA: paso_data LIKE t_data,
      v_dmbtr(13) TYPE n.

TYPES: BEGIN OF tp_data,
        marca(1),                         " Marca del registro
        xref2_hd LIKE bkpf-xref2_hd,      " Concepto
        zzmot_emis LIKE bseg-zzmot_emis,  " Motivo
        text1 LIKE t012t-text1,           " Nombre Banco
        bukrs LIKE bseg-bukrs,            " Sociedad
        belnr LIKE bkpf-belnr,            " N° de documento
        budat LIKE bkpf-budat,            " Fecha revalidación
        zuonr LIKE bseg-zuonr,            " N° del cheque
        dmbtr(16),                        " Monto
        gjahr LIKE bkpf-gjahr,            " Ejercicio
        hkont LIKE bseg-hkont,            " N° de cuenta
        zz_agencia LIKE bseg-zz_agencia,  " Agencia
        lifnr LIKE bseg-lifnr,            " Acreedor
    END OF tp_data.

DATA: BEGIN OF t_info OCCURS 0,
        xref2_hd LIKE bkpf-xref2_hd,      " Concepto
        zzmot_emis LIKE bseg-zzmot_emis,  " Motivo
        text1 LIKE t012t-text1,           " Nombre Banco
        bukrs LIKE bseg-bukrs,            " Sociedad
        belnr LIKE bkpf-belnr,            " N° de documento
        budat LIKE bkpf-budat,            " Fecha revalidación
        zuonr LIKE bseg-zuonr,            " N° del cheque
        dmbtr LIKE bseg-dmbtr,            " Monto
        gjahr LIKE bkpf-gjahr,            " Ejercicio
        waers LIKE bkpf-waers,            " Moneda
        hkont LIKE bseg-hkont,            " N° de cuenta
        zz_agencia LIKE bseg-zz_agencia,  " Agencia
        lifnr LIKE bseg-lifnr,            " Acreedor
    END OF t_info.

* Tabla para contabilizar cheques en table control principal
DATA: BEGIN OF t_cheques OCCURS 0,
          zuonr LIKE bseg-zuonr,
    END OF t_cheques.

* Tabla para contar N° de cheques al momento de Timbrar
DATA: BEGIN OF ti_cheque OCCURS 0,
          zuonr LIKE bseg-zuonr,
    END OF ti_cheque.

DATA: primeravez(1),
      t_bseg LIKE bseg OCCURS 0 WITH HEADER LINE,
      v_index LIKE sy-tabix,
      nro_cheque LIKE payr-chect,
      totalmonto(14),
      totalcheques(14),
      v_total LIKE bseg-dmbtr,
      totaltimbre(14),
      totaltimbre1 LIKE bseg-dmbtr,
      v_totaltimbre TYPE string, "p DECIMALS 3,
      v_totalcheque(14),
      texto1(40),
      texto2(40),
      v_answer(1),
      fecharevalidacion LIKE bkpf-budat,
      confecha(1),
      primera(1),
      error(1),
      wa_data LIKE t_data,
      v_firma LIKE zfirmadigital-tdname,
      v_belnr LIKE bseg-belnr,
      ejecuta(1).

DATA: t_head TYPE STANDARD TABLE OF gxxlt_v,
wa_head LIKE LINE OF t_head,
t_tab1 TYPE STANDARD TABLE OF gxxlt_o,
t_tab2 TYPE STANDARD TABLE OF gxxlt_p,
t_datos TYPE STANDARD TABLE OF tp_data,
w_file TYPE gxxld_file,
cta_reg TYPE i,
t_payr LIKE payr OCCURS 0 WITH HEADER LINE,
cuenta_reg TYPE i.

CONTROLS: tc_revalida TYPE TABLEVIEW USING SCREEN 0100.

DATA: g_tc_revalida_lines  LIKE sy-loopc.

DATA: ok_code LIKE sy-ucomm.

DATA: BEGIN OF t_values OCCURS 0,
value(20) TYPE c.
DATA: END OF t_values.

DATA: BEGIN OF t_fields OCCURS 0.
        INCLUDE STRUCTURE help_value.
DATA END OF t_fields.
DATA: valor(20) TYPE c.

DATA: BEGIN OF t_match OCCURS 0,
        xref2_hd LIKE bkpf-xref2_hd,
    END OF t_match.

DATA: l_variable(30) TYPE c VALUE '(SAPLKKBL)L_UCOMM_SAVE'.
FIELD-SYMBOLS: <fs_variable> TYPE ANY.
DATA: l_ucomm_save LIKE sy-ucomm.

DATA: l_variable1(30) TYPE c VALUE 'SAPLWBABAP(XCODE)'.
FIELD-SYMBOLS: <fs_variable1> TYPE ANY.

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Variables para uso de ALV
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
DATA : titulo       LIKE sy-title.
TYPE-POOLS: slis, kkblo.
CONSTANTS: formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE',
           formname_end_of_page TYPE slis_formname VALUE 'END_OF_PAGE',
           c_pf_status_set TYPE slis_formname VALUE 'PF_STATUS_SET',
           c_form_before_line TYPE slis_formname VALUE 'BEFORE_LINE_OUTPUT'.

DATA: fieldtab TYPE slis_t_fieldcat_alv,
      heading  TYPE slis_t_listheader,
      layout   TYPE slis_layout_alv,
      events   TYPE slis_t_event,
      repname  LIKE sy-repid,
      f2code   LIKE sy-ucomm VALUE  '&ETA',
      g_save(1) TYPE c,
      g_exit(1) TYPE c,
      g_variant LIKE disvariant,
      gx_variant LIKE disvariant,
      i_list_comments     TYPE slis_t_listheader,
      gt_sort TYPE slis_t_sortinfo_alv,
      lt_commentary TYPE slis_t_listheader WITH HEADER LINE,
      w_list_comments LIKE LINE OF i_list_comments,
      t_print             TYPE slis_print_alv,
      w_callback_ucomm TYPE  slis_formname,
      alv_variant      LIKE disvariant,
      v_hora LIKE sy-timlo,
      v_indice TYPE i,
      d_agencia LIKE bseg-zz_agencia.
*
DATA: grid2  TYPE REF TO cl_gui_alv_grid.

*********************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR xref2_hd-low.

  REFRESH: t_values, t_fields.
  CLEAR : t_values, t_fields.

  t_fields-fieldname = 'XREF2_HD'.
  t_fields-tabname = 'BKPF'.
  t_fields-selectflag = 'X'.
  APPEND t_fields. CLEAR t_fields.

  REFRESH t_match.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_match
    FROM bkpf
    WHERE xref2_hd <> ' '.

  SORT t_match BY xref2_hd.
  DELETE ADJACENT DUPLICATES FROM t_match.
  LOOP AT t_match.
    t_values-value = t_match-xref2_hd.
    APPEND t_values.
  ENDLOOP.

  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
    EXPORTING
      tabname      = 'T_MATCH'
      fieldname    = 'xref2_hd'
    IMPORTING
      select_value = xref2_hd-low
    TABLES
      fields       = t_fields
      valuetab     = t_values.
