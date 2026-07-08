*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION ZFITR040012A_ORIGINAL.
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
*function zfitr040012a.
*&---------------------------------------------------------------------*
*& ZFITR040012A ORIGINAL

*&---------------------------------------------------------------------*
*&  Baja retorno de archivo de Novedades de Sociedad, Banco y Nomina,
*&  Ingresados por parámetros para banco ESTADO (012)
*&---------------------------------------------------------------------*
  type-pools: truxs.

  types: begin of type_texto,
         todo(256)       type c,
       end of type_texto.

  types: begin of type_texto1,
           tipreg(1)       type n,
           rutemp(9)       type c,
           dvremp(1)       type c,
           nomemp(50)      type c,
           conven(10)      type c,
           nomcon(50)      type c,
           nomina(10)      type n,
           nomnom(70)      type c,
           fecpag(8)       type n,
           monnom(13)      type n,
           canpag(6)       type n,
           conpag(10)      type n,
           estnom(5)       type c,
           codemp(6)       type n,
        end of type_texto1.

  types: begin of type_texto2,
           tipreg(1)       type n,
           rutben(9)       type n,
           dvrben(1)       type c,
           nomben(30)      type c,
           apepat(15)      type c,
           apemat(15)      type c,
           forpag(2)       type n,
           codban(3)       type n,
           numcta(17)      type n,
           monto(13)       type n,
           estpag(5)       type c,
           mrecha(50)      type c,
           motrch(30)      type c,
           codemp(15)      type c,
         end of type_texto2.

  constants: c_ext_exl   type string     value '*.TXT'.

  data: lt_filetable type filetable,
        lx_filetable type file_table,
        wl_sel_text  type string,
        lv_rc type i.

  data:       it_raw   type truxs_t_text_data.

  data:       t0_exc   type standard table of   type_texto   with header line.
  data:       t1_exc   type standard table of   type_texto1  with header line.
  data:       t2_exc   type standard table of   type_texto2  with header line.

  data: ruta(128),
        cia(4),
        cta(15)      type p,
        rutcia(45),
        suma(15)     type p.

*  DELETE FROM znovedadbanco.

*&---------------------------------------------------------------------*
* Buscar archivo a procesar
*----------------------------------------------------------------------*
  clear ruta.
  wl_sel_text = text-s01.
  call method cl_gui_frontend_services=>file_open_dialog
    exporting
      window_title            = wl_sel_text
      default_extension       = c_ext_exl
    changing
      file_table              = lt_filetable
      rc                      = lv_rc
    exceptions
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      others                  = 5.

  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  else.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT LT_FILETABLE .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    read table lt_filetable into lx_filetable index 1.
    check sy-subrc eq 0.
    ruta = lx_filetable-filename.
  endif.
*&---------------------------------------------------------------------*
*&     Carga archivo seleccinado
*&---------------------------------------------------------------------*
*& Subir un archivo texto a una tabla interna
*&---------------------------------------------------------------------

  refresh: t0_exc, t1_exc, t2_exc.

  call function 'WS_UPLOAD'
    exporting
      filename            = ruta
      filetype            = 'DAT'
    tables
      data_tab            = t0_exc
    exceptions
      conversion_error    = 1
      file_open_error     = 2
      file_read_error     = 3
      invalid_table_width = 4
      invalid_type        = 5
      no_batch            = 6
      unknown_error       = 7
      others              = 8.

  if ( sy-subrc <> 0 ).
    message text-e02  type 'I' display like 'E'.
  else.
    loop at t0_exc.
      if t0_exc+0(1) = '1'.
        t1_exc = t0_exc.
        append  t1_exc.
      else.
        t2_exc  = t0_exc.
        append  t2_exc.
      endif.
    endloop.

    clear rutcia.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from t001
*           where bukrs = soc.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from t001
           where bukrs = soc ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    if sy-subrc = 0.
      rutcia = t001-butxt+0(9).
    endif.
  endif.
*&---------------------------------------------------------------------*
*&  Formatea archivo procesado
*&---------------------------------------------------------------------*
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT T2_EXC .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  read table t2_exc index 1.
  if ( sy-subrc = 0 ).
    if t2_exc-codban <> banco.
      concatenate 'Banco =' ' ' t2_exc-codban into men.
    else.
      if t2_exc-codemp+0(4) <> soc.
        concatenate 'Sociedad =' ' '  t2_exc-codemp+0(4) into men.
      else.
        if  t1_exc-nomina <> nom.
           concatenate 'Nomina  =' ' '   t1_exc-nomina into men.
        endif.
      endif.
    endif.
  endif.
  if men = ' '.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT T1_EXC .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    read table t1_exc index 1.

    loop at t2_exc.
      znovedadbanco-sociedad = soc.
      znovedadbanco-banco	   = banco.
      znovedadbanco-identif	 = t2_exc-codemp.
      znovedadbanco-fecha    = sy-datum.
      znovedadbanco-hora     = sy-uzeit.
      znovedadbanco-nomina   = t1_exc-nomina.
      znovedadbanco-numemp   = '0000000000'.
      concatenate t1_exc-rutemp+1(8) t1_exc-dvremp into znovedadbanco-rutemi.
      znovedadbanco-cuenta   = t2_exc-numcta+7(10).
      concatenate t2_exc-nomben t2_exc-apepat t2_exc-apemat into znovedadbanco-nomben.
      concatenate t2_exc-rutben+1(8) t2_exc-dvrben into znovedadbanco-rutben.
      znovedadbanco-montow   = t2_exc-monto.
      znovedadbanco-numche   = '000000000'.
      znovedadbanco-estpag   = t2_exc-estpag.   " * tabla de traduccion dependiendo del Banco
      znovedadbanco-cenpag   = 0.
      concatenate sy-datum+0(4) '/' sy-datum+4(2) '/' sy-datum+6(02) into znovedadbanco-fecrec.
      znovedadbanco-numlot   = 123.
      znovedadbanco-fecpro   = sy-datum.
      concatenate t1_exc-fecpag+4(4) '/'  t1_exc-fecpag+2(2) '/' t1_exc-fecpag+0(2)  into znovedadbanco-fecpag.
      znovedadbanco-fecest = '      '.
      znovedadbanco-estado  = 0.

* ini Waldo Alarcón - Visionone - 05-10-2020
      IF p_fecha IS NOT INITIAL.
        znovedadbanco-fecest = p_fecha.
      ENDIF.
* fin Waldo Alarcón - Visionone - 05-10-2020

      insert znovedadbanco.
      suma = suma +  znovedadbanco-montow.
      cta = cta + 1.
    endloop.
*&---------------------------------------------------------------------*
*&  Despliega totales del resultado del proceso realizado
*&---------------------------------------------------------------------*
    write:/ 'Sociedad            ',  soc.
    write:/ 'Banco               ',  znovedadbanco-banco.
    write:/ 'Nomina              ',  znovedadbanco-nomina.
    write:/ 'Registros grabados  ',  cta  decimals 0.
    write:/ 'Suma de Montos      ',  suma decimals 0.
  endif.
endfunction.
