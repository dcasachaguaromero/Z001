*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zfitr040504a.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(SOC) TYPE  BUKRS
*"     REFERENCE(BANCO) TYPE  UBNKL
*"     REFERENCE(NOM) TYPE  NUM15
*"     REFERENCE(P_FECHA) TYPE  SYDATUM
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& ZFITR040504A
*&---------------------------------------------------------------------*
*&  Baja retorno de archivo de Novedades de Sociedad, Banco y Nomina
*&  ingresados por parámetros para banco BBVA (504)
*&---------------------------------------------------------------------*
  TYPE-POOLS: truxs.

  TYPES: BEGIN OF type_texto,
           todo(256) TYPE c,
         END OF type_texto.

  TYPES: BEGIN OF type_texto1,
           numemp(10) TYPE c,
           rutemi(9)  TYPE c,
           cuenta(10) TYPE n,
           nomben(50) TYPE c,
           rutben(9)  TYPE c,
           monto(15)  TYPE n,
           numche(9)  TYPE c,
           estado(21) TYPE  c,
           cenpag(4)  TYPE n,
           fecrec(10) TYPE c,
           numlot(3)  TYPE n,
           identi(15) TYPE c,
           fecpag(10) TYPE c,
           fecren(10) TYPE c,
         END OF type_texto1.

  CONSTANTS: c_ext_exl   TYPE string     VALUE '*.TXT'.

  DATA: lt_filetable TYPE filetable,
        lx_filetable TYPE file_table,
        wl_sel_text  TYPE string,
        lv_rc        TYPE i.

  DATA:       it_raw   TYPE truxs_t_text_data.

  DATA:       t0_exc   TYPE STANDARD TABLE OF   type_texto   WITH HEADER LINE.
  DATA:       t1_exc   TYPE STANDARD TABLE OF   type_texto1  WITH HEADER LINE.

  DATA: ruta(128),
        cia(4),
        fec        LIKE sy-datum,
        est        LIKE znovedadbanco-estado,
        cta(5)     TYPE p,
        rutcia(45),
        suma(15)   TYPE p,
        sumar(15)  TYPE p,
        nuevos(6)  TYPE p,
        estado8(6) TYPE p,
        rechazo(6) TYPE p,
        reg        TYPE znovedadbanco.
**add comment
  DELETE FROM znovedadbanco. "#EC CI_NOWHERE
**add commnet
*&---------------------------------------------------------------------*
* Buscar archivo a procesar
*----------------------------------------------------------------------*
  CLEAR ruta.
  wl_sel_text = TEXT-s01.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = wl_sel_text
      default_extension       = c_ext_exl
    CHANGING
      file_table              = lt_filetable
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
    SORT lt_filetable .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
    READ TABLE lt_filetable INTO lx_filetable INDEX 1.
    CHECK sy-subrc EQ 0.
    ruta = lx_filetable-filename.
  ENDIF.

*&---------------------------------------------------------------------*
*&     Carga archivo seleccinado
*&---------------------------------------------------------------------*
*& Subir un archivo texto a una tabla interna
*&---------------------------------------------------------------------

  REFRESH: t0_exc, t1_exc.

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename            = ruta
      filetype            = 'DAT'
    TABLES
      data_tab            = t0_exc
    EXCEPTIONS
      conversion_error    = 1
      file_open_error     = 2
      file_read_error     = 3
      invalid_table_width = 4
      invalid_type        = 5
      no_batch            = 6
      unknown_error       = 7
      OTHERS              = 8.

  IF ( sy-subrc <> 0 ).
    MESSAGE TEXT-e02  TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    LOOP AT t0_exc.
      t1_exc = t0_exc.
      APPEND  t1_exc.
    ENDLOOP.
    CLEAR rutcia.
    SELECT SINGLE * FROM t001
           WHERE bukrs = soc.
    IF sy-subrc = 0.
      rutcia = t001-butxt+0(9).
    ENDIF.
  ENDIF.
*&---------------------------------------------------------------------*
*&  Formatea archivo procesado
*&---------------------------------------------------------------------*
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
  SORT t1_exc .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 24/12/2019 EY_DES02 ECDK917080 *
  READ TABLE t1_exc INDEX 1.

  LOOP AT t1_exc.
    znovedadbanco-sociedad  = soc.
    znovedadbanco-banco     = banco.
    znovedadbanco-identif   = t1_exc-identi.
    znovedadbanco-fecha     = sy-datum.
    znovedadbanco-hora      = sy-uzeit.
    znovedadbanco-nomina    = nom.
    znovedadbanco-numemp    = t1_exc-numemp.
    znovedadbanco-rutemi    = t1_exc-rutemi.
    znovedadbanco-cuenta    = t1_exc-cuenta.
    znovedadbanco-nomben    = t1_exc-nomben.
    znovedadbanco-rutben    = t1_exc-rutben.
    znovedadbanco-montow    = t1_exc-monto.
    znovedadbanco-numche    = t1_exc-numche.
    znovedadbanco-estpag    = t1_exc-estado.
    znovedadbanco-cenpag    = t1_exc-cenpag.
    znovedadbanco-fecrec    = t1_exc-fecrec.
    znovedadbanco-numlot    = t1_exc-numlot.
    znovedadbanco-fecpro    = sy-datum.
    znovedadbanco-fecpag    = t1_exc-fecpag.
    znovedadbanco-fecest    = '      '.
    znovedadbanco-estado    = 0.

* ini Waldo Alarcón - Visionone - 05-10-2020
    IF p_fecha IS NOT INITIAL.
      znovedadbanco-fecest = p_fecha.
    ENDIF.
* fin Waldo Alarcón - Visionone - 05-10-2020

    reg = znovedadbanco.
    CLEAR fec.
    CLEAR est.
    SELECT * FROM znovedadbanco
      WHERE sociedad = reg-sociedad
        AND banco    = reg-banco
        AND identif  = reg-identif
      ORDER BY  fecha DESCENDING
                hora  DESCENDING.
      IF sy-subrc = 0.
        IF fec IS INITIAL.
          fec = znovedadbanco-fecha.
          est = znovedadbanco-estado.
        ENDIF.
      ENDIF.
    ENDSELECT.

    IF fec IS INITIAL.
      nuevos = nuevos + 1.
      znovedadbanco = reg.
      INSERT znovedadbanco.
      suma = suma +  znovedadbanco-montow.
    ELSE.
      IF est = 8.
        estado8 = estado8 + 1.
        znovedadbanco = reg.
        INSERT znovedadbanco.
        suma = suma +  znovedadbanco-montow.
      ELSE.
        rechazo = rechazo +  1.
        sumar = sumar +  znovedadbanco-montow.
      ENDIF.
    ENDIF.
    cta = cta + 1.
  ENDLOOP.
*&---------------------------------------------------------------------*
*&  Despliega totales del resultado del proceso realizado
*&---------------------------------------------------------------------*
  WRITE:/ 'Sociedad                   ',  t001-bukrs.
  WRITE:/ 'Banco                      ',  znovedadbanco-banco.
  WRITE:/ 'Nomina                     ',  znovedadbanco-nomina.
  WRITE:/ 'Registros procesados       ',  cta      DECIMALS 0.
  WRITE:/ 'Registros nuevos           ',  nuevos   DECIMALS 0.
  WRITE:/ 'Registros nulos antes      ',  estado8  DECIMALS 0.
  WRITE:/ 'Registros rechazados       ',  rechazo  DECIMALS 0.
  WRITE:/ 'Suma de Montos grabados    ',  suma     DECIMALS 0.
  WRITE:/ 'Suma de Montos Rechazados  ',  sumar     DECIMALS 0.

ENDFUNCTION.
