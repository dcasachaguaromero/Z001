*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFI_REPORTE_ACREEDORES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfi_reporte_acreedores.

TABLES: bsik,bsak, lfa1, lfb1, bkpf, bseg, vf_kred.

SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.
PARAMETER : p_bukrs     LIKE bkpf-bukrs     OBLIGATORY,
            p_gjahr      LIKE bkpf-gjahr    OBLIGATORY.
SELECT-OPTIONS :  p_fecha      FOR  bkpf-budat    OBLIGATORY,
                  p_cuenta     FOR  bsik-hkont    OBLIGATORY.
PARAMETER  : archivo     TYPE string DEFAULT 'C:\'.
SELECTION-SCREEN END OF BLOCK marco1 .

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




DATA: BEGIN OF t_salida OCCURS 0,
  mandt	          LIKE bkpf-mandt,
  bukrs           LIKE bkpf-bukrs,
  blart           LIKE bkpf-blart ,
  gjahr           LIKE bkpf-gjahr,
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
  belnr           LIKE bkpf-belnr,
  buzei           LIKE bsak-buzei,
  saknr LIKE bseg-buzei,
  hkont LIKE bseg-hkont,
  augbl LIKE bseg-augbl,
  bschl LIKE bseg-bschl,
  koart LIKE bseg-koart,
  umskz LIKE bseg-umskz,
  shkzg LIKE bseg-shkzg,
  mwskz LIKE bseg-mwskz,
  qsskz LIKE bseg-qsskz,
  pswsl LIKE bseg-pswsl,
  zuonr LIKE bseg-zuonr,
  sgtxt LIKE bseg-sgtxt,
  kunnr LIKE bseg-kunnr,
  lifnr LIKE bseg-lifnr,
  zzrut_terc LIKE bseg-zzrut_terc,
  hbkid LIKE bseg-hbkid,
  xref1 LIKE bseg-xref1,
  xref2 LIKE bseg-xref2,
  xref3 LIKE bseg-xref3,
  zzmot_emis LIKE bseg-zzmot_emis,
  valut LIKE bseg-valut,
  augdt LIKE bseg-augdt,
  augcp LIKE bseg-augcp,
  bonfb LIKE bseg-bonfb,
  kzbtr LIKE bseg-kzbtr,
  pswbt LIKE bseg-pswbt,
  stcd1 LIKE lfa1-stcd1,
  ernama LIKE lfa1-ernam,
  erdata LIKE lfa1-erdat,
  ernamb LIKE lfa1-ernam,
  erdatb LIKE lfa1-erdat,

END OF t_salida.



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

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *  INTO CORRESPONDING FIELDS OF TABLE t_bkpf
*    FROM bkpf
*    WHERE  bukrs = p_bukrs
*    AND    gjahr = p_gjahr
*    AND    budat  IN p_fecha.
*
* NEW CODE
  SELECT *
  INTO CORRESPONDING FIELDS OF TABLE t_bkpf
    FROM bkpf
    WHERE  bukrs = p_bukrs
    AND    gjahr = p_gjahr
    AND    budat  IN p_fecha ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


  LOOP AT  t_bkpf.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  bsik WHERE bukrs = t_bkpf-bukrs
*                        AND   belnr = t_bkpf-belnr
*                        AND   gjahr = t_bkpf-gjahr
*                        AND   hkont IN   p_cuenta .
*
* NEW CODE
    SELECT *
 FROM  bsik WHERE bukrs = t_bkpf-bukrs
                        AND   belnr = t_bkpf-belnr
                        AND   gjahr = t_bkpf-gjahr
                        AND   hkont IN   p_cuenta  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM bseg  WHERE bukrs = t_bkpf-bukrs
*                                 AND   belnr = t_bkpf-belnr
*                                 AND   gjahr = t_bkpf-gjahr
*                                 AND   buzei = bsik-buzei.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bseg  WHERE bukrs = t_bkpf-bukrs
                                 AND   belnr = t_bkpf-belnr
                                 AND   gjahr = t_bkpf-gjahr
                                 AND   buzei = bsik-buzei ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


      IF sy-subrc  = 0.


        MOVE-CORRESPONDING  t_bkpf TO t_salida.
        MOVE-CORRESPONDING    bseg TO t_salida.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE   stcd1 ernam erdat   FROM  lfa1 INTO (t_salida-stcd1, t_salida-ernama, t_salida-erdata ) WHERE lifnr = t_salida-lifnr.
**
* NEW CODE
        SELECT stcd1 ernam erdat
        UP TO 1 ROWS    FROM  lfa1 INTO (t_salida-stcd1, t_salida-ernama, t_salida-erdata ) WHERE lifnr = t_salida-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE   ernam erdat   FROM  lfb1 INTO (t_salida-ernamb, t_salida-erdatb ) WHERE lifnr = t_salida-lifnr
*                                                                                          AND   bukrs = t_salida-bukrs.
*
* NEW CODE
        SELECT ernam erdat
        UP TO 1 ROWS    FROM  lfb1 INTO (t_salida-ernamb, t_salida-erdatb ) WHERE lifnr = t_salida-lifnr
                                                                                          AND   bukrs = t_salida-bukrs ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


        t_salida-bonfb =  t_salida-bonfb * 100.
        t_salida-kzbtr =  t_salida-kzbtr  * 100.
        t_salida-pswbt =  t_salida-pswbt * 100.
        APPEND t_salida.
      ENDIF .
    ENDSELECT.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  bsak WHERE bukrs = t_bkpf-bukrs
*                            AND   belnr = t_bkpf-belnr
*                            AND   gjahr = t_bkpf-gjahr
*                            AND   hkont IN   p_cuenta .
*
* NEW CODE
    SELECT *
 FROM  bsak WHERE bukrs = t_bkpf-bukrs
                            AND   belnr = t_bkpf-belnr
                            AND   gjahr = t_bkpf-gjahr
                            AND   hkont IN   p_cuenta  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM bseg  WHERE bukrs = t_bkpf-bukrs
*                                      AND   belnr = t_bkpf-belnr
*                                      AND   gjahr = t_bkpf-gjahr
*                                      AND   buzei = bsak-buzei.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM bseg  WHERE bukrs = t_bkpf-bukrs
                                      AND   belnr = t_bkpf-belnr
                                      AND   gjahr = t_bkpf-gjahr
                                      AND   buzei = bsak-buzei ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF sy-subrc  = 0.
        MOVE-CORRESPONDING  t_bkpf TO t_salida.
        MOVE-CORRESPONDING    bseg TO t_salida.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE   stcd1 ernam erdat   FROM  lfa1 INTO (t_salida-stcd1, t_salida-ernama, t_salida-erdata ) WHERE lifnr = t_salida-lifnr.
**
* NEW CODE
        SELECT stcd1 ernam erdat
        UP TO 1 ROWS    FROM  lfa1 INTO (t_salida-stcd1, t_salida-ernama, t_salida-erdata ) WHERE lifnr = t_salida-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE   ernam erdat   FROM  lfb1 INTO (t_salida-ernamb, t_salida-erdatb ) WHERE lifnr = t_salida-lifnr
*                                                                                          AND   bukrs = t_salida-bukrs.
*
* NEW CODE
        SELECT ernam erdat
        UP TO 1 ROWS    FROM  lfb1 INTO (t_salida-ernamb, t_salida-erdatb ) WHERE lifnr = t_salida-lifnr
                                                                                          AND   bukrs = t_salida-bukrs ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        t_salida-bonfb =  t_salida-bonfb * 100.
        t_salida-kzbtr =  t_salida-kzbtr  * 100.
        t_salida-pswbt =  t_salida-pswbt * 100.
        APPEND t_salida.
      ENDIF .
    ENDSELECT.

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
  DATA: fill(7)       TYPE n.
  DATA :i_data(4096) TYPE c OCCURS 0.

  DATA: BEGIN OF i_titulo OCCURS 0,
    titulo(4096),
  END OF i_titulo.


  REFRESH t_titulo.
  t_titulo-titulo = 'Md.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Soc.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Clase doc.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Año'.
  APPEND t_titulo.
  t_titulo-titulo = 'Período'.
  APPEND t_titulo.
  t_titulo-titulo = 'Nombre del usuario'.
  APPEND t_titulo.
  t_titulo-titulo ='Referencia'.
  APPEND t_titulo.
  t_titulo-titulo = 'Anul.con'.
  APPEND t_titulo.
  t_titulo-titulo = 'Fecha doc.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Fe.contab.'.
  APPEND t_titulo.
  t_titulo-titulo = 'FechaEntr'.
  APPEND t_titulo.
  t_titulo-titulo =  'Modif.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Últ.act.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Fe.anulación'.
  APPEND t_titulo.
  t_titulo-titulo = 'Texto cab.documento'.
  APPEND t_titulo.
  t_titulo-titulo = 'ClvRefCab1'.
  APPEND t_titulo.
  t_titulo-titulo = 'ClvRefCab2'.
  APPEND t_titulo.
  t_titulo-titulo ='Nº doc.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Pos'.
  APPEND t_titulo.
  t_titulo-titulo = 'Cta.mayor'.
  APPEND t_titulo.
  t_titulo-titulo = 'Lib.mayor'.
  APPEND t_titulo.
  t_titulo-titulo = 'Doc.comp.'.
  APPEND t_titulo.
  t_titulo-titulo = 'CT'.
  APPEND t_titulo.
  t_titulo-titulo ='ClCta'.
  APPEND t_titulo.
  t_titulo-titulo =   'IO'.
  APPEND t_titulo.
  t_titulo-titulo =  'D/H'.
  APPEND t_titulo.
  t_titulo-titulo =  'II'.
  APPEND t_titulo.
  t_titulo-titulo = 'IR'.
  APPEND t_titulo.
  t_titulo-titulo =   'Mon.'.
  APPEND t_titulo.
  t_titulo-titulo =   'Asignación'.
  APPEND t_titulo.
  t_titulo-titulo =   'Texto'.
  APPEND t_titulo.
  t_titulo-titulo =   'Cliente'.
  APPEND t_titulo.
  t_titulo-titulo =   'Acreedor'.
  APPEND t_titulo.
  t_titulo-titulo = 'RUT de terceros'.
  APPEND t_titulo.
  t_titulo-titulo = 'Bco.prp.'.
  APPEND t_titulo.
  t_titulo-titulo ='Clv.ref.1'.
  APPEND t_titulo.
  t_titulo-titulo = 'Clv.ref.2'.
  APPEND t_titulo.
  t_titulo-titulo = 'Clv.ref.3'.
  APPEND t_titulo.
  t_titulo-titulo =   'Emisión'.
  APPEND t_titulo.
  t_titulo-titulo = 'Fe.valor'.
  APPEND t_titulo.
  t_titulo-titulo = 'Compens.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Fe.comp.'.
  APPEND t_titulo.
  t_titulo-titulo ='BONFB'.
  APPEND t_titulo.
  t_titulo-titulo = 'Reducc. origin.'.
  APPEND t_titulo.
  t_titulo-titulo = 'Importe libro mayor'.
  APPEND t_titulo.
  t_titulo-titulo = 'Rut'.
  APPEND t_titulo.
  t_titulo-titulo = 'Autor'.
  APPEND t_titulo.
  t_titulo-titulo = 'Fecha'.
  APPEND t_titulo.
  t_titulo-titulo = 'Autor'.
  APPEND t_titulo.
  t_titulo-titulo = 'Fecha'.
  APPEND t_titulo.



  CONCATENATE
  'Md.'
    'Soc.'
    'Clase doc.'
    'Año'
    'Período'
   'Nombre del usuario'
   'Referencia'
   'Anul.con'
   'Fecha doc.'
   'Fe.contab.'
    'FechaEntr'
    'Modif.'
    'Últ.act.'
    'Fe.anulación'
    'Texto cab.documento'
    'ClvRefCab1'
    'ClvRefCab2'
    'Nº doc.'
    'Pos'
    'Cta.mayor'
    'Lib.mayor'
    'Doc.comp.'
  'CT'
  'ClCta'
    'IO'
    'D/H'
  'II'
   'IR'
    'Mon.'
    'Asignación'
    'Texto'
     'Cliente'
     'Acreedor'
   'RUT de terceros'
  'Bco.prp.'
  'Clv.ref.1'
  'Clv.ref.2'
  'Clv.ref.3'
    'Emisión'
  'Fe.valor'
   'Compens.'
  'Fe.comp.'
  'BONFB'
   'Reducc. origin.'
  'Importe libro mayor'
  'Rut'
  'Autor'
   'Fecha'
  'Autor'
   'Fecha'
  INTO i_titulo-titulo SEPARATED BY ';'.

  DESCRIBE TABLE t_salida  LINES fill.
  IF fill > 1000000.
    CONCATENATE archivo 'Rep_Acreedores.csv' INTO nombre_a.

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
