*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zfitr040027a.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(SOC) TYPE  BUKRS
*"     REFERENCE(BANCO) TYPE  UBNKL
*"     REFERENCE(NOM) TYPE  NUM15
*"     REFERENCE(P_FECHA) TYPE  SYDATUM
*"  EXPORTING
*"     REFERENCE(MEN) TYPE  CHAR30
*"----------------------------------------------------------------------
*& ZFITR040027A
*&---------------------------------------------------------------------*
*&  Baja retorno de archivo de Novedades de Sociedad, Banco y Nómina
*&  ingresados por parámetros para BANCO CORPBANCA (027)
*&---------------------------------------------------------------------*
  TYPE-POOLS: truxs.

  TYPES: BEGIN OF type_texto,
           todo(335) TYPE c,
         END OF type_texto.

  TYPES: BEGIN OF type_texto1,
           fecpag(10)  TYPE c,
           rutben(11)  TYPE c,
           nomben(45)  TYPE c,
           montow(15)  TYPE n,
           metodo(30)  TYPE c,
           codban(3)   TYPE c,
           numcta(18)  TYPE n,
           estpag(25)  TYPE c,
           mrecha(50)  TYPE c,
           refcli(100) TYPE c,
           nomina(12)  TYPE n,
           retfac(2)   TYPE c,
           doctos(3)   TYPE n,
           fechax      LIKE sy-datum,
         END OF type_texto1.

  CONSTANTS: c_ext_exl   TYPE string     VALUE '*.TXT'.

  DATA: lt_filetable TYPE filetable,
        lx_filetable TYPE file_table,
        wl_sel_text  TYPE string,
        lv_rc        TYPE i.

  DATA:       it_raw   TYPE truxs_t_text_data.

  DATA:       tl_exc   TYPE STANDARD TABLE OF   type_texto  WITH HEADER LINE.
  DATA:       to_file  TYPE STANDARD TABLE OF   type_texto1 WITH HEADER LINE.

  DATA: ruta(128),
        cia(4),
        fechax     LIKE sy-datum,
        fec        LIKE sy-datum,
        est        LIKE znovedadbanco-estado,
        years      TYPE  pea_scryy,
        months     TYPE  pea_scrmm,
        days       TYPE  pea_scrdd,
        cta(6)     TYPE p,
        rutcia(10),
        numero(8)  TYPE n,
        num_c(8)   TYPE c,
        dv(1),
        suma(15)   TYPE p,
        sumar(15)  TYPE p,
        nuevos(6)  TYPE p,
        estado8(6) TYPE p,
        rechazo(6) TYPE p,
        reg        TYPE znovedadbanco.

* DELETE FROM znovedadbanco.

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
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    SORT lt_filetable .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    READ TABLE lt_filetable INTO lx_filetable INDEX 1.
    CHECK sy-subrc EQ 0.
    ruta = lx_filetable-filename.
  ENDIF.
*&---------------------------------------------------------------------*
*&     Carga archivo seleccionado
*&---------------------------------------------------------------------*
*& Subir un archivo texto a una tabla interna
*&---------------------------------------------------------------------*
  REFRESH: to_file, tl_exc.

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename            = ruta
      filetype            = 'DAT'
    TABLES
      data_tab            = tl_exc
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
    LOOP AT tl_exc.
      IF tl_exc+2(1) = '/'.
        to_file = tl_exc.
        APPEND  to_file.
      ENDIF.
    ENDLOOP.

    CLEAR rutcia.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
*SORT TO_FILE .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    READ TABLE to_file INDEX 1.
    cia =  to_file-refcli+0(4).
    SELECT SINGLE * FROM t001
           WHERE bukrs = cia.
    IF sy-subrc = 0.
      SELECT SINGLE * FROM adrc
            WHERE addrnumber = t001-adrnr.
    ENDIF.
  ENDIF.
  IF adrc-sort1 IS NOT INITIAL.
    SPLIT adrc-sort1 AT '-' INTO num_c dv.
    numero = num_c.
    CONCATENATE numero dv INTO rutcia.
  ENDIF.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
*SORT TL_EXC .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  READ TABLE tl_exc INDEX 1.
  IF ( sy-subrc = 0 ).
    IF tl_exc+111(3) <> banco.
      CONCATENATE 'Banco =' ' ' tl_exc+111(3) INTO men.
    ELSE.
      IF tl_exc+207(4) <> soc.
        CONCATENATE 'Sociedad =' ' ' tl_exc+207(4) INTO men.
      ELSE.
        IF tl_exc+307(12) <> nom.
          CONCATENATE 'Nomina =' ' '  tl_exc+307(12) INTO men.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

*&---------------------------------------------------------------------*
*&  Formatea archivo procesado
*&---------------------------------------------------------------------*
  IF men = '  '.
    LOOP AT to_file.

*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*       input  = to_file-rutben
*      IMPORTING
*        output = to_file-rutben.

      CONCATENATE to_file-fecpag+6(4) to_file-fecpag+3(2) to_file-fecpag+0(2) INTO fechax.
      znovedadbanco-fecpag   = fechax.

      CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
        EXPORTING
          date1         = sy-datum
          date2         = fechax
          output_format = '03'
        IMPORTING
          years         = years
          months        = months
          days          = days.
*     EXCEPTIONS
*       INVALID_DATES_SPECIFIED       = 1
*       OTHERS                        = 2
      days = days - 1.

      IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      znovedadbanco-sociedad = soc.
      znovedadbanco-banco	   = banco.


      SELECT SINGLE * FROM reguh WHERE identif_pago = to_file-refcli.
      IF sy-subrc = 0.
        znovedadbanco-cuenta = reguh-ubknt.
      ENDIF.

      znovedadbanco-identif	 = to_file-refcli+0(15).
      znovedadbanco-fecha    = sy-datum.
      znovedadbanco-hora     = sy-uzeit.
      znovedadbanco-nomina   = nom.
      znovedadbanco-numemp   = '0000000000'.
      znovedadbanco-rutemi   = rutcia.
      znovedadbanco-nomben   = to_file-nomben.
      znovedadbanco-rutben   = to_file-rutben.
      znovedadbanco-montow   = to_file-montow.
      znovedadbanco-numche   = '000000000'.

      TRANSLATE to_file-estpag TO UPPER CASE.
      SELECT SINGLE * FROM zestadosbanco
                     WHERE banco  = banco
                       AND codban = to_file-estpag.

      IF to_file-estpag  = 'RECHAZADO'.
        IF days >= 60.
          znovedadbanco-estpag = 'CHEQUE DEVUELTO'.
        ELSE.
          znovedadbanco-estpag = 'VALE VISTA REINTEGRAD'.
        ENDIF.
      ELSE.
        IF sy-subrc = 0.
          znovedadbanco-estpag   = zestadosbanco-codint.
        ELSE.
          znovedadbanco-estpag   = to_file-estpag.
        ENDIF.
      ENDIF.

      znovedadbanco-cenpag   = 0.
      znovedadbanco-fecrec   = sy-datum.
      znovedadbanco-numlot   = 123.
      znovedadbanco-numlot   = to_file-nomina+9(3).
      znovedadbanco-fecpro   = sy-datum.

      znovedadbanco-fecest   = sy-datum.
      znovedadbanco-estado   = 0.

      reg = znovedadbanco.
      CLEAR fec.
      CLEAR est.
*      SELECT * FROM znovedadbanco
*        WHERE sociedad = reg-sociedad
*          AND banco    = reg-banco
*          AND identif  = reg-identif
*        ORDER BY  fecha DESCENDING
*                  hora  DESCENDING.
*        IF sy-subrc = 0.
*          IF fec IS INITIAL.
*            fec = znovedadbanco-fecha.
*            est = znovedadbanco-estado.
*          ENDIF.
*        ENDIF.
*      ENDSELECT.

*      IF fec IS INITIAL.
      nuevos = nuevos + 1.
      znovedadbanco = reg.

* ini Waldo Alarcón - Visionone - 05-10-2020
      IF p_fecha IS NOT INITIAL.
        znovedadbanco-fecest = p_fecha.
      ENDIF.
* fin Waldo Alarcón - Visionone - 05-10-2020

      INSERT znovedadbanco.
      suma = suma +  znovedadbanco-montow.
*      ELSE.
*        IF est = 8.
*          estado8 = estado8 + 1.
*          znovedadbanco = reg.
*          INSERT znovedadbanco.
*          suma = suma +  znovedadbanco-montow.
*        ELSE.
*          rechazo = rechazo +  1.
*          sumar = sumar +  znovedadbanco-montow.
*        ENDIF.
*      ENDIF.

      cta = cta + 1.
    ENDLOOP.
*&---------------------------------------------------------------------*
*&  Despliega resultados del proceso realizado
*&---------------------------------------------------------------------*
    WRITE:/ 'Sociedad                   ',  t001-bukrs.
    WRITE:/ 'Banco                      ',  znovedadbanco-banco.
    WRITE:/ 'Nomina                     ',  znovedadbanco-nomina.
    WRITE:/ 'Registros procesados       ',  cta      DECIMALS 0.
    WRITE:/ 'Registros nuevos           ',  nuevos   DECIMALS 0.
    WRITE:/ 'Registros nulos antes      ',  estado8  DECIMALS 0.
    WRITE:/ 'Suma de Montos grabados    ',  suma     DECIMALS 0.
  ENDIF.

ENDFUNCTION.
