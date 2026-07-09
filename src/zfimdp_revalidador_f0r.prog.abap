*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIMDP_REVALIDADOR_F0R
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  INICIALIZA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE inicializa OUTPUT.
  IF primeravez IS INITIAL.
*    CLEAR: bukrs, hbkid, xref2_hd, budat, budat1, zuonr.
    CLEAR: bukrs, hbkid, xref2_hd, budat, zuonr.
    REFRESH t_data.
    CLEAR t_data.
    primeravez = 'X'.
  ENDIF.
ENDMODULE.                 " INICIALIZA  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  IMPRIME_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM imprime_data .
  TABLES: itcpo.

* Se revisa la fecha de revalidación, si no se ingresó una nueva fecha
* se asume como fecha de revalidación la fecha de contabilización del
* documento. Lo primero implica que TODOS los registros quedan con esa
* de revalidación, de lo contrario, cada registro asume su fecha de contabilización.
  CLEAR confecha.

  itcpo-tdcovtitle = 'Timbre Revalidacion Cheque'.
  itcpo-tdnewid = 'X'.
  itcpo-tddest = 'LISA'.   " Láser Isapre

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      device                      = 'PRINTER'
      dialog                      = ' '
      form                        = 'ZFO_REVALIDA'
      language                    = sy-langu
      OPTIONS                     = itcpo
    EXCEPTIONS
      canceled                    = 1
      device                      = 2
      form                        = 3
      OPTIONS                     = 4
      unclosed                    = 5
      mail_options                = 6
      archive_error               = 7
      invalid_fax_number          = 8
      more_params_needed_in_batch = 9
      spool_error                 = 10
      OTHERS                      = 11.

  IF sy-subrc EQ 0.
* Se recorren los registros marcados para impresión
    LOOP AT t_data WHERE marca = 'X'.
      IF confecha IS INITIAL.
        fecharevalidacion = t_data-budat.
      ENDIF.

* Se obtiene el nombre en forma dinámica de la firma electrónica a utilizar
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zfirmadigital
*      WHERE bukrs EQ t_data-bukrs
*      AND orden EQ 3.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zfirmadigital
      WHERE bukrs EQ t_data-bukrs
      AND orden EQ 3 ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF sy-subrc EQ 0.
        v_firma = zfirmadigital-tdname.
      ENDIF.

      CALL FUNCTION 'START_FORM'
        EXPORTING
          startpage = 'FIRST'.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window  = 'CHECK'
        EXCEPTIONS
          element = 1
          window  = 2.

      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          window  = 'FECHA'
        EXCEPTIONS
          element = 1
          window  = 2.

      CALL FUNCTION 'END_FORM'.

* Se actualiza registro en tabla BSEG como impreso
      UPDATE bseg SET projn = 'X'
      WHERE bukrs = t_data-bukrs
        AND belnr = t_data-belnr
        AND gjahr = t_data-gjahr
        AND hkont = t_data-hkont.

      IF sy-subrc EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'CLOSE_FORM'
      EXCEPTIONS
        OTHERS = 1.

  ENDIF.
ENDFORM.                    " IMPRIME_DATA

*&---------------------------------------------------------------------*
*&      Form  NEW-PAGE
*&---------------------------------------------------------------------*
FORM new-page USING  w_titulo.
  NEW-PAGE PRINT ON
  LIST NAME w_titulo
  DESTINATION 'LOCL'
  COPIES '001'
  COVER TEXT w_titulo
  IMMEDIATELY ' '
  KEEP IN SPOOL 'X'
  NEW LIST IDENTIFICATION 'X'
*  LAYOUT 'X_90_120'
  LAYOUT 'X_65_255'
  LINE-SIZE '120'
  LINE-COUNT '90'
  DATASET EXPIRATION '5'
  NEW-SECTION
  NO DIALOG.
ENDFORM.                    " NEW-PAGE

*&---------------------------------------------------------------------*
*&      Form  USER_OK_TC
*&---------------------------------------------------------------------*
FORM user_ok_tc USING    p_tc_name TYPE dynfnam
                         p_table_name
                         p_mark_name
                CHANGING p_ok      LIKE sy-ucomm.

  DATA: l_ok              TYPE sy-ucomm,
        l_offset          TYPE i.
  SEARCH p_ok FOR p_tc_name.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  l_offset = STRLEN( p_tc_name ) + 1.
  l_ok = p_ok+l_offset.
  CASE l_ok.
    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      PERFORM compute_scrolling_in_tc USING p_tc_name
                                            l_ok.
      CLEAR p_ok.
    WHEN 'MARK'.                      "mark all filled lines
      PERFORM fcode_tc_mark_lines USING p_tc_name
                                        p_table_name
                                        p_mark_name   .
      CLEAR p_ok.

    WHEN 'DMRK'.                      "demark all filled lines
      PERFORM fcode_tc_demark_lines USING p_tc_name
                                          p_table_name
                                          p_mark_name .
      CLEAR p_ok.

  ENDCASE.
ENDFORM.                    " USER_OK_TC

*&---------------------------------------------------------------------*
*&      Form  COMPUTE_SCROLLING_IN_TC
*&---------------------------------------------------------------------*
FORM compute_scrolling_in_tc USING    p_tc_name
                                       p_ok.
  DATA l_tc_new_top_line     TYPE i.
  DATA l_tc_name             LIKE feld-name.
  DATA l_tc_lines_name       LIKE feld-name.
  DATA l_tc_field_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <lines>      TYPE i.

  ASSIGN (p_tc_name) TO <tc>.
  CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
  ASSIGN (l_tc_lines_name) TO <lines>.


  IF <tc>-lines = 0.
    l_tc_new_top_line = 1.
  ELSE.
    CALL FUNCTION 'SCROLLING_IN_TABLE'
      EXPORTING
        entry_act      = <tc>-top_line
        entry_from     = 1
        entry_to       = <tc>-lines
        last_page_full = 'X'
        loops          = <lines>
        ok_code        = p_ok
        overlapping    = 'X'
      IMPORTING
        entry_new      = l_tc_new_top_line
      EXCEPTIONS
        OTHERS         = 0.
  ENDIF.

  GET CURSOR FIELD l_tc_field_name
             AREA  l_tc_name.

  IF syst-subrc = 0.
    IF l_tc_name = p_tc_name.
      SET CURSOR FIELD l_tc_field_name LINE 1.
    ENDIF.
  ENDIF.

  <tc>-top_line = l_tc_new_top_line.

ENDFORM.                    " COMPUTE_SCROLLING_IN_TC

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_MARK_LINES
*&---------------------------------------------------------------------*
FORM fcode_tc_mark_lines USING p_tc_name
                               p_table_name
                               p_mark_name.
*&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: mark all filled lines                                      *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = 'X'.
  ENDLOOP.
ENDFORM.                    " FCODE_TC_MARK_LINES

*&---------------------------------------------------------------------*
*&      Form  FCODE_TC_DEMARK_LINES
*&---------------------------------------------------------------------*
FORM fcode_tc_demark_lines USING p_tc_name
                                 p_table_name
                                 p_mark_name .
*&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
  DATA l_table_name       LIKE feld-name.

  FIELD-SYMBOLS <tc>         TYPE cxtab_control.
  FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <wa>.
  FIELD-SYMBOLS <mark_field>.
*&SPWIZARD: END OF LOCAL DATA------------------------------------------*

  ASSIGN (p_tc_name) TO <tc>.

*&SPWIZARD: get the table, which belongs to the tc                     *
  CONCATENATE p_table_name '[]' INTO l_table_name. "table body
  ASSIGN (l_table_name) TO <table>.                "not headerline

*&SPWIZARD: demark all filled lines                                    *
  LOOP AT <table> ASSIGNING <wa>.

*&SPWIZARD: access to the component 'FLAG' of the table header         *
    ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.

    <mark_field> = space.
  ENDLOOP.
ENDFORM.                    " FCODE_TC_DEMARK_LINES

*&---------------------------------------------------------------------*
*&      Form  REPORTE
*&---------------------------------------------------------------------*
FORM reporte .
  REFRESH t_reporte.
  CLEAR t_reporte.
  LOOP AT t_data WHERE marca = 'X'.
    IF t_data-status EQ c_timbrado.
      MESSAGE i001(00) WITH 'Doc. no se procesara por encontrarse ya timbrado'.
      CONTINUE.
    ENDIF.
    CLEAR: t_reporte, v_dmbtr.
    TRANSLATE t_data-dmbtr USING '. '.
    CONDENSE t_data-dmbtr NO-GAPS.
    MOVE-CORRESPONDING t_data TO t_reporte.
    v_dmbtr = t_data-dmbtr.
    t_reporte-dmbtr = v_dmbtr / 100.
* Se obtiene el rut asociado al acreedor
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE lifnr INTO t_data-lifnr
*      FROM payr
*      WHERE zbukr IN bukrs AND hbkid IN hbkid AND
*            chect EQ t_data-zuonr.
*
* NEW CODE
    SELECT lifnr
    UP TO 1 ROWS  INTO t_data-lifnr
      FROM payr
      WHERE zbukr IN bukrs AND hbkid IN hbkid AND
            chect EQ t_data-zuonr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE stcd1 name1 INTO (t_reporte-rut, t_reporte-name1)
*      FROM lfa1
*      WHERE lifnr = t_data-lifnr.
*
* NEW CODE
    SELECT stcd1 name1
    UP TO 1 ROWS  INTO (t_reporte-rut, t_reporte-name1)
      FROM lfa1
      WHERE lifnr = t_data-lifnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* Se obtiene la glosa de la agencia
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE zzdescr INTO t_reporte-zzdescr FROM zagencia
*      WHERE bukrs = t_data-bukrs
*        AND zzcod_unidad = t_data-zz_agencia.
*
* NEW CODE
    SELECT zzdescr
    UP TO 1 ROWS  INTO t_reporte-zzdescr FROM zagencia
      WHERE bukrs = t_data-bukrs
        AND zzcod_unidad = t_data-zz_agencia ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = t_reporte-zz_agencia
      IMPORTING
        output = t_reporte-zz_agencia.

*    t_reporte-cantid = 1.
    t_reporte-color = 'C200'.   " Fondo blanco con letras negras
    APPEND t_reporte.
  ENDLOOP.

  SORT t_reporte BY zz_agencia.
  DESCRIBE TABLE t_reporte.
  IF sy-tfill EQ 0.
    sy-ucomm = 'PRIN'.
  ELSE.
    PERFORM procesa_alv.
  ENDIF.
ENDFORM.                    " REPORTE

*&---------------------------------------------------------------------*
*&      Form  procesa_alv
*&---------------------------------------------------------------------*
FORM procesa_alv.
  REFRESH fieldtab.
  PERFORM inializar_fieldcat USING fieldtab[].
  PERFORM build_eventtab USING events[].
  PERFORM build_layout USING layout.
  PERFORM imprime_salida.
ENDFORM.                    "procesa_alv

*---------------------------------------------------------------------*
*       FORM inializar_fieldcat                                       *
*---------------------------------------------------------------------*
FORM inializar_fieldcat
               USING p_fieldtab TYPE slis_t_fieldcat_alv.
  DATA: l_fieldcat TYPE slis_fieldcat_alv.

  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'ZZ_AGENCIA'.
  l_fieldcat-seltext_l = 'Agencia'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'ZZDESCR'.
  l_fieldcat-seltext_l = 'Descripción'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'BUKRS'.
  l_fieldcat-seltext_l = 'Sociedad'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'TEXT1'.
  l_fieldcat-seltext_l = 'Banco'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'XREF2_HD'.
  l_fieldcat-seltext_l = 'Area'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'BUDAT'.
  l_fieldcat-seltext_l = 'Fecha Revalidación'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'ZZMOT_EMIS'.
  l_fieldcat-seltext_l = 'Motivo'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'RUT'.
  l_fieldcat-seltext_l = 'Rut'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'ZUONR'.
  l_fieldcat-seltext_l = 'N° Cheque'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'NAME1'.
  l_fieldcat-seltext_l = 'Glosa Cheque'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-currency = 'CLP'.
  l_fieldcat-fieldname = 'DMBTR'.
  l_fieldcat-seltext_l = 'Monto'.
  l_fieldcat-do_sum = 'X'.
  APPEND l_fieldcat TO p_fieldtab.
*
  CLEAR l_fieldcat.
  l_fieldcat-tabname   = 'T_REPORTE'.
  l_fieldcat-fieldname = 'BELNR'.
  l_fieldcat-seltext_l = 'N° documento'.
  APPEND l_fieldcat TO p_fieldtab.
*
*  CLEAR l_fieldcat.
*  l_fieldcat-tabname   = 'T_REPORTE'.
*  l_fieldcat-fieldname = 'CANTID'.
*  l_fieldcat-seltext_l = 'Cantidad de cheques'.
*  l_fieldcat-do_sum = 'X'.
*  APPEND l_fieldcat TO p_fieldtab.
*
ENDFORM.                    "inializar_fieldcat

*---------------------------------------------------------------------*
*       FORM build_eventtab                                           *
*---------------------------------------------------------------------*
FORM build_eventtab USING    p_events TYPE slis_t_event.
  DATA: ls_event TYPE slis_alv_event.
  REFRESH p_events.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = p_events.

  READ TABLE p_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE formname_top_of_page TO ls_event-form.
    APPEND ls_event TO p_events.
  ENDIF.

  READ TABLE p_events WITH KEY name = slis_ev_end_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE formname_end_of_page TO ls_event-form.
    APPEND ls_event TO p_events.
  ENDIF.

  READ TABLE p_events WITH KEY name = slis_ev_before_line_output
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE c_form_before_line TO ls_event-form.
    APPEND ls_event TO p_events.
  ENDIF.
ENDFORM.                    " build_eventtab

*---------------------------------------------------------------------*
*       FORM build_layout                                             *
*---------------------------------------------------------------------*
FORM build_layout USING    p_layout TYPE slis_layout_alv.
  p_layout-zebra        = 'X'.
  p_layout-colwidth_optimize = 'X'.
  p_layout-info_fieldname = 'COLOR'.
ENDFORM.                    " build_layout

*---------------------------------------------------------------------*
*       FORM imprime_salida                                           *
*---------------------------------------------------------------------*
FORM imprime_salida.
  DATA: gd_repid LIKE sy-repid,
        lt_sort TYPE slis_t_sortinfo_alv,
        ls_sort TYPE slis_sortinfo_alv.

  REFRESH lt_sort.
  ADD 1 TO ls_sort-spos.
  ls_sort-fieldname = 'ZZ_AGENCIA'.
  ls_sort-up        = 'X'.
  ls_sort-subtot    = 'X'.
  APPEND ls_sort TO lt_sort.

  gd_repid = sy-repid.

  CLEAR t_print.
  t_print-print = 'X'.    " Sin despliegue de reporte
  t_print-prnt_title = 'X'.
  t_print-prnt_info = 'X'.
  t_print-no_print_selinfos = 'X'.
  t_print-no_print_listinfos = 'X'.
*  t_print-print_ctrl-pri_params-pdest = 'LOCL'.  " Dispositivo
*  t_print-print_ctrl-pri_params-prtxt = 'Reporte Revalidaciones'.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_callback_program = gd_repid
      is_layout          = layout
      it_fieldcat        = fieldtab
      it_events          = events[]
      it_sort            = lt_sort
      i_save             = 'A'
      is_variant         = gx_variant
      is_print           = t_print
    TABLES
      t_outtab           = t_reporte
    EXCEPTIONS
      program_error      = 1.
ENDFORM.                    "imprime_salida

*---------------------------------------------------------------------*
*       FORM top_of_page                                              *
*---------------------------------------------------------------------*
FORM top_of_page.
  DATA: hline TYPE slis_listheader,
        v_werks LIKE t001w-werks,
        w_texto(80) TYPE c,
        v_fecha(10),
        v_hora(8).

* Titulo Principal
  REFRESH i_list_comments.
  w_list_comments-typ  = 'H'. "H=Header, S=Selection, A=Action
  w_list_comments-key  = ''.
  w_list_comments-info = 'Listado de Cheques Revalidados'.
  APPEND w_list_comments TO i_list_comments.

* Fecha
  CLEAR: w_list_comments, w_texto, v_fecha.
  CONCATENATE sy-datum+6(2) '-' sy-datum+4(2) '-' sy-datum+0(4)
      INTO v_fecha.
  CONCATENATE 'Fecha:' v_fecha INTO w_texto SEPARATED BY space.
  w_list_comments-typ  = 'S'.
  w_list_comments-key  = ''.
  w_list_comments-info = w_texto.
  APPEND w_list_comments TO i_list_comments.

* Hora
  CLEAR: w_list_comments, w_texto, v_hora.
  CONCATENATE sy-timlo+0(2) ':' sy-datum+4(2) ':' sy-datum+6(2)
      INTO v_hora.
  CONCATENATE 'Hora:' v_hora INTO w_texto SEPARATED BY space.
  w_list_comments-typ  = 'S'.
  w_list_comments-key  = ''.
  w_list_comments-info = w_texto.
  APPEND w_list_comments TO i_list_comments.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_list_comments.
ENDFORM.                    "top_of_page

*&---------------------------------------------------------------------*
*&      Form  end_of_page
*&---------------------------------------------------------------------*
FORM end_of_page.
ENDFORM.                    "end_of_page

*&---------------------------------------------------------------------*
*&      Form  before_line_output
*&---------------------------------------------------------------------*
FORM before_line_output USING p_ll TYPE kkblo_lineinfo.
  IF d_agencia NE t_reporte-zz_agencia.
    d_agencia = t_reporte-zz_agencia.
    IF p_ll-tabindex GT 1.
      ULINE:/(161).
      NEW-PAGE.
    ENDIF.
  ENDIF.
ENDFORM.                    "before_line_output

*&---------------------------------------------------------------------*
*&      Form  EJECUTA_CONSULTA
*&---------------------------------------------------------------------*
FORM ejecuta_consulta .

  CLEAR: totalcheques, totalmonto.
  IF budat IS INITIAL.
    MESSAGE 'Debe ingresar la fecha de Revalidación como mínimo.' TYPE 'I'.
  ELSE.
  "04.06.2014.- Actualizacion de clases de documento
  "se agrego XD como revalidado. Seidor Crystalis
  ranges: r_blart for bkpf-blart.
  clear r_blart.
  r_blart-low = 'ZA'.
  r_blart-option = 'EQ'.
  r_blart-sign = 'I'.
  append r_blart.

  clear r_blart.
  r_blart-low = 'XD'.
  r_blart-option = 'EQ'.
  r_blart-sign = 'I'.
  append r_blart.

* Se obtiene la información a partir de los filtros y se deja
* en la tabla interna T_DATA
    REFRESH: t_info, t_data, t_cheques.
    CLEAR: t_info, t_data, v_total.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * INTO CORRESPONDING FIELDS OF TABLE t_info
*    FROM bkpf
*    WHERE bukrs IN bukrs              " Sociedad
**      and blart = 'ZA'         "mod 04.06.2014 Seidor Crystalis
*      and blart in r_blart      "mod 04.06.2014 Seidor Crystalis
*      AND xref2_hd IN xref2_hd        " Concepto
*      AND budat IN budat.             
*
* NEW CODE
    SELECT *
 INTO CORRESPONDING FIELDS OF TABLE t_info
    FROM bkpf
    WHERE bukrs IN bukrs              " Sociedad
*      and blart = 'ZA'         "mod 04.06.2014 Seidor Crystalis
      and blart in r_blart      "mod 04.06.2014 Seidor Crystalis
      AND xref2_hd IN xref2_hd        " Concepto
      AND budat IN budat ORDER BY PRIMARY KEY.             

* END. 07-07-2026 - ATC - ATC-03" Fecha Revalidación

    LOOP AT t_info.
      v_index = sy-tabix.
      REFRESH t_bseg.
SELECT * INTO TABLE t_bseg
FROM bseg
WHERE bukrs = t_info-bukrs
AND belnr = t_info-belnr
AND gjahr = t_info-gjahr
and AUGBL = ' '
AND bschl = '50'
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
*AND zuonr IN zuonr.
AND ZUONR IN ZUONR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *

*          READ TABLE t_bseg WITH KEY hkont+9(1) = '9'.     " Revalidado
      LOOP AT t_bseg.
* Según nueva definición, para determinar si la cuenta es una revalidación,
* se debe revisar la tabla SKB1
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM skb1
*        WHERE bukrs = t_info-bukrs
*          AND saknr = t_bseg-hkont
*          AND fdlev = 'B9'
*          AND fstag = 'G005'.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM skb1
        WHERE bukrs = t_info-bukrs
          AND saknr = t_bseg-hkont
          AND fdlev = 'B9'
          AND fstag = 'G005' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0.

*          IF t_bseg-projn IS INITIAL  .   " Si es igual a X, ya fue impreso
          t_info-zzmot_emis = t_bseg-zzmot_emis.
          t_info-zuonr = t_bseg-zuonr.
          t_info-dmbtr = t_bseg-dmbtr.
          t_info-hkont = t_bseg-hkont.
          t_info-zz_agencia = t_bseg-zz_agencia.
          t_info-lifnr = t_bseg-lifnr.

* Se determina el banco pagador
          CLEAR nro_cheque.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = t_bseg-zuonr
            IMPORTING
              output = nro_cheque.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = nro_cheque
            IMPORTING
              output = nro_cheque.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM payr
*           WHERE zbukr = t_info-bukrs
*             AND hbkid IN hbkid
*             AND chect = t_bseg-zuonr
*             AND voidr = ''.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM payr
           WHERE zbukr = t_info-bukrs
             AND hbkid IN hbkid
             AND chect = t_bseg-zuonr
             AND voidr = '' ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          IF sy-subrc EQ 0.

* FCV - 23.11.2010
* Se comparan los montos
            IF ABS( t_info-dmbtr ) = ABS( payr-rwbtr ).
* Fin FCV - 23.11.2010

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * FROM t012t
*                WHERE spras = sy-langu
*                  AND bukrs = t_info-bukrs
*                  AND hbkid = payr-hbkid
*                  AND hktid = payr-hktid.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM t012t
                WHERE spras = sy-langu
                  AND bukrs = t_info-bukrs
                  AND hbkid = payr-hbkid
                  AND hktid = payr-hktid ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

              IF sy-subrc EQ 0.
                t_info-text1 = t012t-text1.
              ENDIF.
              IF t_info-lifnr IS INITIAL.
                t_info-lifnr = payr-lifnr.
              ENDIF.
              t_info-dmbtr = payr-rwbtr.
* FCV - 12.09.2010
* Se rescata el monto del cheque
              IF t_info-dmbtr < 0.
                t_info-dmbtr = t_info-dmbtr * -1.
              ENDIF.
* fin FCV - 12.09.2010
              MODIFY t_info INDEX v_index.
              MOVE-CORRESPONDING t_info TO t_data.

* FCV - 17.10.2010 - Se obtiene el N° correcto de documento siempre y cuando el cheque
* se encuentre en màs de un banco
              REFRESH t_payr.
              CLEAR cuenta_reg.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*              SELECT * INTO TABLE t_payr
*              FROM payr
*              WHERE zbukr = t_data-bukrs
*                and HBKID = hbkid-low
*                AND chect = t_data-zuonr.
*
* NEW CODE
              SELECT *
 INTO TABLE t_payr
              FROM payr
              WHERE zbukr = t_data-bukrs
                and HBKID = hbkid-low
                AND chect = t_data-zuonr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

              DESCRIBE TABLE t_payr LINES cuenta_reg.
              IF cuenta_reg > 1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*                SELECT SINGLE belnr INTO t_data-belnr
*                  FROM bseg
*                  WHERE bukrs = t_data-bukrs
*                    AND gjahr = t_data-gjahr
*                    AND augbl = ' '
*                    AND shkzg = 'H'
*                    AND zuonr = t_data-zuonr
*                    AND hkont = t_data-hkont.
*
* NEW CODE
                SELECT belnr
                UP TO 1 ROWS  INTO t_data-belnr
                  FROM bseg
                  WHERE bukrs = t_data-bukrs
                    AND gjahr = t_data-gjahr
                    AND augbl = ' '
                    AND shkzg = 'H'
                    AND zuonr = t_data-zuonr
                    AND hkont = t_data-hkont ORDER BY PRIMARY KEY.

                ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              ENDIF.
* Fin FCV - 17.10.2010

              WRITE t_info-dmbtr CURRENCY t_info-waers TO t_data-dmbtr.
              CONDENSE t_data-dmbtr NO-GAPS.
              SHIFT t_data-dmbtr RIGHT DELETING TRAILING space.
*            v_total = v_total + t_info-dmbtr.



              CLEAR: t_data-name1, t_data-stcd1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE name1 stcd1 INTO (t_data-name1, t_data-stcd1)
*                FROM lfa1
*                WHERE lifnr = t_info-lifnr.
*
* NEW CODE
              SELECT name1 stcd1
              UP TO 1 ROWS  INTO (t_data-name1, t_data-stcd1)
                FROM lfa1
                WHERE lifnr = t_info-lifnr ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


              IF c_vall = 'X'.
                IF t_bseg-projn IS INITIAL.
                  t_data-status = c_revalid.
                ELSE.
                  t_data-status = c_timbrado.
                ENDIF.
                v_total = v_total + t_info-dmbtr.
                APPEND t_data.
                t_cheques-zuonr = t_data-zuonr.
                APPEND t_cheques.
              ELSE.
                IF t_bseg-projn IS INITIAL.
                  t_data-status = c_revalid.
                  v_total = v_total + t_info-dmbtr.
                  APPEND t_data.
                  t_cheques-zuonr = t_data-zuonr.
                  APPEND t_cheques.
                ENDIF.
              ENDIF.

            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

* FCV - 24.10.2010
* Actualiza el N° de documento
    LOOP AT t_data.
      v_index = sy-tabix.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM payr
*        WHERE zbukr = t_data-bukrs
*          AND hbkid = hbkid-low
*          AND chect = t_data-zuonr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM payr
        WHERE zbukr = t_data-bukrs
          AND hbkid = hbkid-low
          AND chect = t_data-zuonr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      PERFORM busca_docto USING payr-vblnr.
      PERFORM procesa.

      MODIFY t_data INDEX v_index.
    ENDLOOP.
* fin FCV - 24.10.2010

    SORT t_cheques BY zuonr.
    DELETE ADJACENT DUPLICATES FROM t_cheques.
    DESCRIBE TABLE t_cheques LINES totalcheques.
    WRITE v_total CURRENCY 'CLP' TO totalmonto.
    CONDENSE: totalcheques, totalmonto NO-GAPS.
    SHIFT totalcheques RIGHT DELETING TRAILING space.
    SHIFT totalmonto RIGHT DELETING TRAILING space.
  ENDIF.
  CLEAR sy-ucomm.
ENDFORM.                    " EJECUTA_CONSULTA

*&---------------------------------------------------------------------*
*&      Form  procesa
*&---------------------------------------------------------------------*
FORM procesa.
  CLEAR cta_reg.
  DESCRIBE TABLE t_bseg LINES cta_reg.
  IF cta_reg = '1'.
    READ TABLE t_bseg INDEX 1.
    IF t_bseg-augbl = ' '.
      t_data-belnr = t_bseg-belnr.
    ELSE.
      PERFORM busca_docto USING t_bseg-augbl.
      PERFORM procesa.
    ENDIF.
  ELSE.
    LOOP AT t_bseg.
      PERFORM busca_docto USING t_bseg-augbl.
      PERFORM procesa.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "procesa
*&---------------------------------------------------------------------*
*&      Form  busca_docto
*&---------------------------------------------------------------------*
FORM busca_docto USING p_vblnr.
  REFRESH t_bseg.
SELECT * INTO TABLE t_bseg
FROM bseg
WHERE bukrs = t_data-bukrs
AND belnr = p_vblnr
AND gjahr = t_data-gjahr
and belnr <> p_vblnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
*AND bschl = '50'.
AND BSCHL = '50' ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
*
  IF sy-subrc NE 0.
    t_data-belnr = p_vblnr.
    EXIT.
  ENDIF.
ENDFORM.                    "busca_docto
