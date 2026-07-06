*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zfitr040012a.
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
*&---------------------------------------------------------------------*
*& ZFITR040012A
*&---------------------------------------------------------------------*
*&  Baja retorno de archivo de Novedades de Sociedad, Banco y Nomina
*&  ingresados por parámetros para banco ESTADO (012)
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
        cta(15)    TYPE p,
        rutcia(45),
        fecha(8),
        numero(8)  TYPE n,
        num_c(8)   TYPE c,
        dv(1),
        sumdif(5)  TYPE n,
        suma(15)   TYPE p,
        sumar(15)  TYPE p,
        nuevos(6)  TYPE p,
        estado8(6) TYPE p,
        rechazo(6) TYPE p,
        reg        TYPE znovedadbanco.

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
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    SORT t1_exc .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    READ TABLE t1_exc INDEX 1.
    cia =  t1_exc-identi+0(4).
    SELECT SINGLE * FROM t001
           WHERE bukrs = soc.
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
*&---------------------------------------------------------------------*
*&  Formatea archivo procesado
*&---------------------------------------------------------------------*
*ReSQ: No Need Of Change Internal Table T1_EXC Already Sorted
  READ TABLE t1_exc INDEX 1.
  CONCATENATE t1_exc-fecren+0(4) t1_exc-fecren+5(2) t1_exc-fecren+8(2) INTO fecha.
  IF ( sy-subrc = 0 ).
    IF t1_exc-identi+4(3) <> banco.
      CONCATENATE 'Banco =' ' ' t1_exc-identi+0(4) INTO men.
    ELSE.
      IF t1_exc-identi+0(4) <> soc.
        CONCATENATE 'Sociedad =' ' '  t1_exc-identi+0(4) INTO men.
      ENDIF.
    ENDIF.
  ENDIF.

  IF men = ' '.

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
      znovedadbanco-montow    = t1_exc-monto / 100.
      znovedadbanco-numche    = t1_exc-numche.
      TRANSLATE t1_exc-estado TO UPPER CASE.
      SELECT SINGLE * FROM zestadosbanco
                     WHERE banco  = banco
                       AND codban = t1_exc-estado.

      IF t1_exc-estado  = 'RECHAZADO'.
*    IF days >= 60.
*      znovedadbanco-estpag = 'CHEQUE DEVUELTO'.
*    ELSE.
*      znovedadbanco-estpag = 'VALE VISTA REINTEGRAD'.
*    ENDIF.
      ELSE.
        IF sy-subrc = 0.
          znovedadbanco-estpag   = zestadosbanco-codint.
        ELSE.
          znovedadbanco-estpag   = t1_exc-estado.
        ENDIF.
      ENDIF.
      znovedadbanco-cenpag    = t1_exc-cenpag.
      CONCATENATE t1_exc-fecrec+0(4) t1_exc-fecrec+5(2) t1_exc-fecrec+8(2) INTO znovedadbanco-fecrec.
*      znovedadbanco-fecrec    = t1_exc-fecrec.
      znovedadbanco-numlot    = t1_exc-numlot.
      znovedadbanco-fecpro    = sy-datum.
      CONCATENATE t1_exc-fecpag+0(4) t1_exc-fecpag+5(2) t1_exc-fecpag+8(2) INTO znovedadbanco-fecpag.
*      znovedadbanco-fecpag    = t1_exc-fecpag.
*     znovedadbanco-fecest   =  t1_exc-fecren." sy-datum. HCD 02-09-2019
      CONCATENATE t1_exc-fecren+0(4) t1_exc-fecren+5(2) t1_exc-fecren+8(2) INTO znovedadbanco-fecest." sy-datum. HCD 02-09-2019
*      znovedadbanco-fecest    = '      '.
      znovedadbanco-estado    = 0.

      reg = znovedadbanco.
      CLEAR fec.
      CLEAR est.
*      select * from znovedadbanco
*        where sociedad = reg-sociedad
*          and banco    = reg-banco
*          and identif  = reg-identif
*        order by  fecha descending
*                  hora  descending.
*        if sy-subrc = 0.
*          if fec is initial.
*            fec = znovedadbanco-fecha.
*            est = znovedadbanco-estado.
*          endif.
*        endif.
*      endselect.

*      if fec is initial.
      nuevos = nuevos + 1.
      znovedadbanco = reg.

* ini Waldo Alarcón - Visionone - 05-10-2020
      IF p_fecha IS NOT INITIAL.
        znovedadbanco-fecest = p_fecha.
      ENDIF.
* fin Waldo Alarcón - Visionone - 05-10-2020

      INSERT znovedadbanco.
      suma = suma +  znovedadbanco-montow.
*      else.
*        if est = 8.
*          estado8 = estado8 + 1.
*          znovedadbanco = reg.
*          insert znovedadbanco.
*          suma = suma +  znovedadbanco-montow.
*        else.
*          rechazo = rechazo +  1.
*          sumar = sumar +  znovedadbanco-montow.
*        endif.
*      endif.
      cta = cta + 1.
    ENDLOOP.
*&---------------------------------------------------------------------*
*&  Despliega totales del resultado del proceso realizado
*&---------------------------------------------------------------------*
    WRITE:/ 'Sociedad                   ',  soc.
    WRITE:/ 'Banco                      ',  znovedadbanco-banco.
    WRITE:/ 'Nomina                     ',  znovedadbanco-nomina.
    WRITE:/ 'Registros procesados       ',  cta      DECIMALS 0.
    WRITE:/ 'Registros nuevos           ',  nuevos   DECIMALS 0.
    WRITE:/ 'Registros nulos antes      ',  estado8  DECIMALS 0.
    WRITE:/ 'Suma de Montos grabados    ',  suma     DECIMALS 0.
  ENDIF.
ENDFUNCTION.
