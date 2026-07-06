*&---------------------------------------------------------------------*
*& Report  ZFI_REPORTE_ACREEDORES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaudit_acreedores.

TABLES: bsik,bsak, lfa1, lfb1, bkpf, bseg, vf_kred.

SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

SELECT-OPTIONS :  p_lifnr    FOR  lfa1-lifnr    .
PARAMETER  :  p_fecini  like SY-DATUM  OBLIGATORY,
              p_fecfin  like SY-DATUM  OBLIGATORY.
PARAMETER  : archivo     TYPE string DEFAULT 'C:\'.
SELECTION-SCREEN END  OF BLOCK marco1 .

data x_erdat LIKE lfa1-erdat.
data x_ernam   LIKE lfa1-ernam.
data x_name1  LIKE lfa1-name1.
data x_name2  LIKE lfa1-name2.
data x_stcd1  LIKE lfa1-stcd1.

DATA: BEGIN OF t_bkpf OCCURS  0 ,
mandt	          LIKE bkpf-mandt,
bukrs           LIKE bkpf-bukrs,
belnr           LIKE bkpf-belnr,
gjahr           LIKE bkpf-gjahr,
blart           LIKE bkpf-blart ,
monat           LIKE bkpf-monat,
usnam           LIKE bkpf-usnam ,
xblnr           LIKE bkpf-xblnr,
stblg           LIKE bkpf-stblg,
bldat           LIKE bkpf-bldat,
budat           LIKE bkpf-budat,
cpudt           LIKE bkpf-cpudt,
aedat           LIKE bkpf-aedat,
upddt           LIKE bkpf-upddt,
stodt           LIKE bkpf-stodt,
bktxt           LIKE bkpf-bktxt,
xref1_hd        LIKE bkpf-xref1_hd,
xref2_hd        LIKE bkpf-xref2_hd ,
END OF t_bkpf.


DATA: BEGIN OF t_salida2 OCCURS 0,
  BUKRS like lfb1-bukrs,
  lifnr like lfa1-lifnr,
  name1 like lfa1-name1,
  name2 like lfa1-name2,
  stcd1 like lfa1-stcd1,
  ERDAT like lfb1-erdat,
  ERNAM like lfb1-ernam,
  merdat like lfa1-erdat,
  mernam like lfa1-ernam,
  fechabsik like bsak-bldat,
  fechabsak like bsak-bldat,

END OF t_salida2.

DATA: BEGIN OF t_salida OCCURS 0,
  BUKRS like lfb1-bukrs,
  lifnr like lfa1-lifnr,
  name1 like lfa1-name1,
  name2 like lfa1-name2,
  stcd1 like lfa1-stcd1,
  ERDAT like lfb1-erdat,
  ERNAM like lfb1-ernam,
  merdat like lfa1-erdat,
  mernam like lfa1-ernam,
  fechabsik like bsak-bldat,
  fechabsak like bsak-bldat,
  sociedad like bsak-bukrs,

END OF t_salida.

DATA: BEGIN OF t_pagosoc OCCURS 0,
  lifnr like lfa1-lifnr,
  name1 like lfa1-name1,
  name2 like lfa1-name2,
  stcd1 like lfa1-stcd1,
  fechabsik like bsak-bldat,
  fechabsak like bsak-bldat,
  sociedad like bsak-bukrs,

END OF t_pagosoc.

DATA vfecha like bsak-bldat.
DATA vfechabsak like bsak-bldat.

DATA: BEGIN OF t_titulo OCCURS 0,
  titulo(20),

END OF t_titulo.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Carpeta de Almacenamiento'
      initial_folder  = 'C:\'
    CHANGING
      selected_folder = archivo.

START-OF-SELECTION.
* acreedor y sociedad
select lfb1~bukrs lfa1~lifnr lfa1~name1 lfa1~name2 lfa1~stcd1 LFB1~ERDAT LFB1~ERNAM into CORRESPONDING FIELDS OF TABLE t_salida2
FROM lfa1 inner join lfb1 on lfa1~LIFNR = lfb1~LIFNR and lfb1~erdat >= p_fecini and lfb1~erdat <= p_fecfin
*select lfb1~bukrs lfb1~lifnr LFB1~ERDAT LFB1~ERNAM  into CORRESPONDING FIELDS OF TABLE t_salida2
*FROM lfb1
where
*   lfb1~erdat >= p_fecini and lfb1~erdat <= p_fecfin.
*  lfa1~erdat in p_fecha and
  lfa1~lifnr in p_lifnr.

  LOOP AT  t_salida2.
    vfecha = ''.
    vfechabsak = ''.

 SELECT single  erdat   into x_erdat  " t_salida2-serdat "  ernam   name1  name2  stcd1
   FROM  lfa1
 where lfa1~LIFNR EQ t_salida2-LIFNR.
   IF sy-subrc <> 0.
      x_erdat = ' '.
    ENDIF.
 t_salida2-merdat = x_erdat.

SELECT single    ernam  into  x_ernam " t_salida2-serdat "  ernam   name1  name2  stcd1
   FROM  lfa1
 where lfa1~LIFNR EQ t_salida2-LIFNR.
     IF sy-subrc <> 0.
      x_ernam = ' '.
    ENDIF.
  t_salida2-mernam = x_ernam.
"


*into t_salida2-serdat  t_salida2-sernam t_salida2-merdat t_salida2-mernam
*  t_salida2-name1 t_salida2-name2 t_salida2-stcd1
* qry recibidos no pagados
    SELECT max( bldat )   from bsik into vfecha
    WHERE lifnr = t_salida2-lifnr
    and   BUKRS = t_salida2-BUKRS
    AND   blart IN ('D1','D3','D4','F0','F1','F2','F3','F4','F5','F6','F9','FA','FC','I1','N1','N2','N3','N4','N0','NA', 'B1','B2','B3','B4','B5')
    and ZZMOT_EMIS <> 'PAGOPRES'.
* qry pagados
    SELECT  max( bldat ) from bsak into vfechabsak
    WHERE lifnr = t_salida2-lifnr
    and   BUKRS = t_salida2-BUKRS
    AND   blart IN ('D1','D3','D4','F0','F1','F2','F3','F4','F5','F6','F9','FA','FC','I1','N1','N2','N3','N4','N0','NA', 'B1','B2','B3','B4','B5')
    and ZZMOT_EMIS <> 'PAGOPRES'.

    CALL FUNCTION 'RP_CHECK_DATE'
      EXPORTING
        DATE = vfecha
      EXCEPTIONS
        DATE_INVALID = 1.
    IF sy-subrc <> 0.
      vfecha = ' '.
    ENDIF.
    CALL FUNCTION 'RP_CHECK_DATE'
      EXPORTING
        DATE = vfechabsak
      EXCEPTIONS
        DATE_INVALID = 1.
    IF sy-subrc <> 0.
      vfechabsak = ' '.
    ENDIF.
    if vfecha <> '' or vfechabsak <> ''.
       t_salida2-fechabsik = vfecha.
       t_salida2-fechabsak = vfechabsak.
       MOVE-CORRESPONDING t_salida2 to t_salida.
       APPEND t_salida.
    ENDIF.
    if sy-subrc = 99.
      exit.
    ENDIF.
  ENDLOOP.

  PERFORM bajar_archivo.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  bajar_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM bajar_archivo.
*-----------------*
  DATA : nombre_a  TYPE string.
  DATA: fill(11)       TYPE n.
  DATA :i_data(4096) TYPE c OCCURS 0.

  DATA: BEGIN OF i_titulo OCCURS 0,
    titulo(4096),
  END OF i_titulo.


  REFRESH t_titulo.
  t_titulo-titulo = 'Sociedad'.
  APPEND t_titulo.
  t_titulo-titulo = 'Id SAP'.
  APPEND t_titulo.
  t_titulo-titulo = 'Name1'.
  APPEND t_titulo.
  t_titulo-titulo = 'NAme2'.
  APPEND t_titulo.
  t_titulo-titulo = 'Rut'.
  APPEND t_titulo.
* "25012019 HCD INI
  t_titulo-titulo = 'FechaCreaSoc'.
  APPEND t_titulo.
   t_titulo-titulo = 'CreadorSoc'.
  APPEND t_titulo.
   t_titulo-titulo = 'FechaCreaenSAP'.
  APPEND t_titulo.
  t_titulo-titulo = 'CreadorenSap'.
  APPEND t_titulo.
  t_titulo-titulo = 'FechaNoPagado'.
  APPEND t_titulo.
  t_titulo-titulo = 'FechaPagado'.
  APPEND t_titulo.
"25012019 HCD FIN
  CONCATENATE
  'Sociedad'
  'Id SAP'
  'Name1'
  'NAme2'
  'Rut'
  'FechaCreaSoc' "25012019 HCD
  'CreadorSoc'    "25012019 HCD
  'FechaCreaenSAP' "25012019 HCD
  'CreadorenSap' "25012019 HCD
  'FechaNoPagado'
  'FechaPagado'
  INTO i_titulo-titulo SEPARATED BY ';'.

  DESCRIBE TABLE t_salida  LINES fill.
  IF fill > 1000000.
    CONCATENATE archivo 'Rep_AcreedoresAudi.xls' INTO nombre_a.

    CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
      EXPORTING
        i_field_seperator    = ';'
        i_line_header        = 'X'
      TABLES
        i_tab_sap_data       = t_salida
      CHANGING
        i_tab_converted_data = i_data
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
    INSERT i_titulo INTO i_data INDEX 1.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = nombre_a
        filetype                = 'ASC'
        confirm_overwrite       = 'X'
      TABLES
        data_tab                = i_data
      EXCEPTIONS
        file_write_error        = 1 "FIELDNAMES = i_column
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6.
    IF sy-subrc <> 0.
      WRITE :/ 'error!!!!'  ,
             /  sy-msgv1 ,
             /  sy-msgv2 ,
             /  sy-msgv3 ,
             /  sy-msgv4 .

    ELSE.
      SKIP 2 .
      FORMAT COLOR 3 ON.
      WRITE : / 'Se genero archivo :',  nombre_a.
      FORMAT COLOR 3 OFF.
    ENDIF.

  ELSE.
    CONCATENATE archivo 'Rep_Acreedores.xls' INTO nombre_a.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = nombre_a
        filetype                = 'DAT'
        confirm_overwrite       = 'X'
      TABLES
        data_tab                = t_salida
        fieldnames              = t_titulo
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
      WRITE :/ 'error!!!!'  ,
             /  sy-msgv1 ,
             /  sy-msgv2 ,
             /  sy-msgv3 ,
             /  sy-msgv4 .

    ELSE.
      SKIP 2 .
      FORMAT COLOR 3 ON.
      WRITE : / 'Se genero archivo :',  nombre_a.
      FORMAT COLOR 3 OFF.
    ENDIF.
  ENDIF.
ENDFORM.                    "bajar_archivo
