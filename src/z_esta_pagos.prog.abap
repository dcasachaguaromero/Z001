*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  z_esta_pagos
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  z_esta_pagos.

TABLES: lfa1 , bkpf, bseg.

SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

SELECT-OPTIONS :  p_lifnr    FOR  lfa1-lifnr,
                  p_bukrs    for  bkpf-bukrs,
                  p_gjahr    for  bkpf-gjahr,
                  p_hkont    for  bseg-hkont,
                  p_budat    for  bkpf-budat,
                  p_XREF2    for  bkpf-XREF2_HD.
PARAMETER  : archivo     TYPE string DEFAULT 'C:\'.
SELECTION-SCREEN END  OF BLOCK marco1 .

TYPES: BEGIN OF ty_prov,
    stcd1 like lfa1-stcd1,
    name1 like lfa1-name1,
    name2 like lfa1-name2,
  end of ty_prov.

data: t_prov type ty_prov.

DATA: BEGIN OF t_bkpf OCCURS  0 ,
bukrs           LIKE bkpf-bukrs,
belnr           LIKE bkpf-belnr,
gjahr           LIKE bkpf-gjahr,
budat           LIKE bkpf-budat,
cpudt           LIKE bkpf-cpudt,
usnam           LIKE bkpf-usnam,
bldat           LIKE bkpf-bldat,
lifnr           like bseg-lifnr,
blart           like bkpf-blart,
BKTXT           like bkpf-BKTXT,
XREF2_HD        like bkpf-XREF2_HD,
END OF t_bkpf.

types: BEGIN OF ty_mov ,
bukrs           LIKE bkpf-bukrs,
belnr           LIKE bkpf-belnr,
gjahr           LIKE bkpf-gjahr,
budat           LIKE bkpf-budat,
cpudt           LIKE bkpf-cpudt,
usnam           LIKE bkpf-usnam,
bldat           LIKE bkpf-bldat,
buzei           like bseg-buzei,
augbl           like bseg-augbl,
shkzg           like bseg-shkzg,
sgtxt           like bseg-sgtxt,
lifnr           like bseg-lifnr,
rut             type c length 15,
nombre          type c length 80,
monto           type P,
hkont           like bseg-hkont,
zuonr           like bseg-zuonr,
blart           like bkpf-blart,
BKTXT           like bkpf-BKTXT,
XREF2_HD        like bkpf-XREF2_HD,
END OF ty_mov.

data: t_mov type ty_mov,
      tb_mov type STANDARD TABLE OF ty_mov.

DATA: BEGIN OF t_titulo OCCURS 0,
  titulo(20),
END OF t_titulo.
data: v_lifnr like bseg-lifnr.
DATA: AMOUNT_DISPLAY LIKE WMTO_S-AMOUNT,
      AMOUNT_SAP LIKE WMTO_S-AMOUNT.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR archivo.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Carpeta de Almacenamiento'
      initial_folder  = 'C:\'
    CHANGING
      selected_folder = archivo.

START-OF-SELECTION.


select bkpf~bukrs bkpf~gjahr bkpf~budat bkpf~CPUDT bkpf~usnam bkpf~belnr bkpf~bldat bkpf~blart bkpf~BKTXT bkpf~XREF2_HD
  into CORRESPONDING FIELDS OF TABLE t_bkpf
from bkpf
where bkpf~bukrs in p_bukrs
  and bkpf~gjahr in p_gjahr
  and bkpf~budat in p_budat
  and bkpf~XREF2_HD in p_XREF2
  and bkpf~blart in ('B1','B2','B3','B4','B5','D1','D2','D3','D4','F0','F1','F2','F3','F4','F5','F6','F7','F8','F9','FA','FB','FC','N0','N1','N2','N3','N4','NA','NB','NC').
*  and bkpf~STBLG is null.
if sy-subrc = 0.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES03 ECDK917080 *
SORT T_BKPF .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 19/12/2019 EY_DES03 ECDK917080 *
    loop at t_bkpf.
      v_lifnr = ' '.
      select single t1~lifnr
        into v_lifnr
      from bsak as t1
        where
          t1~bukrs = t_bkpf-bukrs and
          t1~gjahr = t_bkpf-gjahr and
          t1~belnr = t_bkpf-belnr and
          t1~lifnr in p_lifnr.
      IF sy-subrc = 0.
          t_bkpf-lifnr = v_lifnr.
          modify t_bkpf INDEX sy-tabix.
      ELSEIF sy-subrc = 4.
          v_lifnr = ' '.
          select single t1~lifnr
            into v_lifnr
          from bsik as t1
            where
              t1~bukrs = t_bkpf-bukrs and
              t1~gjahr = t_bkpf-gjahr and
              t1~belnr = t_bkpf-belnr and
              t1~lifnr in p_lifnr.
          IF sy-subrc = 0.
            t_bkpf-lifnr = v_lifnr.
            modify t_bkpf INDEX sy-tabix.
          endif.
      ENDIF.
    ENDLOOP.
    DELETE t_bkpf where lifnr = ' '.

    loop at t_bkpf.
select *
from bseg as t2
where t2~bukrs = t_bkpf-bukrs
and t2~gjahr = t_bkpf-gjahr
and t2~belnr = t_bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES03 ECDK917080 *
*and t2~hkont in p_hkont.
AND T2~HKONT IN P_HKONT ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES03 ECDK917080 *
          if sy-subrc = 0.
              t_mov-bukrs = BSEG-bukrs.
              t_mov-belnr = bseg-belnr.
              t_mov-gjahr = bseg-gjahr.
              t_mov-budat = t_bkpf-budat.
              t_mov-cpudt = t_bkpf-cpudt.
              t_mov-usnam = t_bkpf-usnam.
              t_mov-bldat = t_bkpf-bldat.
              t_mov-blart = t_bkpf-blart.
              t_mov-BKTXT = t_bkpf-BKTXT.
              t_mov-buzei = bseg-buzei.
              t_mov-augbl = bseg-augbl.
              t_mov-shkzg = bseg-shkzg.
              t_mov-sgtxt = bseg-sgtxt.
              t_mov-lifnr = bseg-lifnr.
              t_mov-XREF2_HD = t_bkpf-XREF2_HD.
*
              select SINGLE lfa1~stcd1 lfa1~name1 lfa1~name2 into (t_prov-stcd1, t_prov-name1, t_prov-name2)
              from lfa1
              where lfa1~lifnr = t_bkpf-lifnr.
              if sy-subrc = 0.
                  t_mov-lifnr = t_bkpf-lifnr.
                  t_mov-rut = t_prov-stcd1.
                  CONCATENATE t_prov-name1 t_prov-name2 into t_mov-nombre.
              endif.
*
              AMOUNT_SAP = bseg-DMBTR.
              CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
              EXPORTING
                    CURRENCY              = BSEG-PSWSL
                    AMOUNT_INTERNAL       = AMOUNT_SAP
              IMPORTING
                    AMOUNT_DISPLAY        = AMOUNT_DISPLAY.
              t_mov-monto = AMOUNT_DISPLAY.
              t_mov-hkont = bseg-hkont.
              t_mov-zuonr = bseg-zuonr.
              APPEND t_mov to tb_mov.
          ENDIF.
      ENDSELECT.
    endloop.

    PERFORM BAJAR_ARCHIVO.


endif.


END-OF-SELECTION.

FORM BAJAR_ARCHIVO.
*-----------------*
  DATA : NOMBRE_A  TYPE STRING.
  DATA: FILL(20)       TYPE N.
  DATA :I_DATA(4096) TYPE C OCCURS 0.

  DATA: BEGIN OF I_TITULO OCCURS 0,
    TITULO(4096),
  END OF I_TITULO.


  REFRESH T_TITULO.
  T_TITULO-TITULO = 'Sociedad'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'N° Comp'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Ejercicio'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Fec Conta'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Fec Regis'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Usuario'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Fec Docu'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Posicion'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Doc Comp'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'D/H'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Texto Pos'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Id SAP'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Rut'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Nombre'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Monto'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Cta Ctble'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Referencia'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Clase Doc'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Texto Cab'.
  APPEND T_TITULO.
  T_TITULO-TITULO = 'Origen'.
  APPEND T_TITULO.

"25012019 HCD FIN
  CONCATENATE
      'Sociedad'
      'N° Comp'
      'Ejercicio'
      'Fec Conta'
      'Fec Regis'
      'Usuario'
      'Fec Docu'
      'Posicion'
      'Doc Comp'
      'D/H'
      'Texto Pos'
      'Id SAP'
      'Rut'
      'Nombre'
      'Monto'
      'Cta Ctble'
      'Referencia'
      'Clase Doc'
      'Texto Cab'
      'Origen'
  INTO I_TITULO-TITULO SEPARATED BY ';'.

  DESCRIBE TABLE tb_mov  LINES FILL.
  IF FILL > 1000000.
    CONCATENATE ARCHIVO 'Rep_Acreedores.xls' INTO NOMBRE_A.

    CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
      EXPORTING
        I_FIELD_SEPERATOR    = ';'
        I_LINE_HEADER        = 'X'
      TABLES
        I_TAB_SAP_DATA       = tb_mov
      CHANGING
        I_TAB_CONVERTED_DATA = I_DATA
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    INSERT I_TITULO INTO I_DATA INDEX 1.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = NOMBRE_A
        FILETYPE                = 'ASC'
        CONFIRM_OVERWRITE       = 'X'
      TABLES
        DATA_TAB                = I_DATA
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1 "FIELDNAMES = i_column
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6.
    IF SY-SUBRC <> 0.
      WRITE :/ 'error!!!!'  ,
             /  SY-MSGV1 ,
             /  SY-MSGV2 ,
             /  SY-MSGV3 ,
             /  SY-MSGV4 .

    ELSE.
      SKIP 2 .
      FORMAT COLOR 3 ON.
      WRITE : / 'Se genero archivo :',  NOMBRE_A.
      FORMAT COLOR 3 OFF.
    ENDIF.

  ELSE.
    CONCATENATE ARCHIVO 'Rep_Acreedores.xls' INTO NOMBRE_A.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                = NOMBRE_A
        FILETYPE                = 'DAT'
        CONFIRM_OVERWRITE       = 'X'
      TABLES
        DATA_TAB                = tb_mov
        FIELDNAMES              = T_TITULO
      EXCEPTIONS
        FILE_WRITE_ERROR        = 1
        NO_BATCH                = 2
        GUI_REFUSE_FILETRANSFER = 3
        INVALID_TYPE            = 4
        NO_AUTHORITY            = 5
        UNKNOWN_ERROR           = 6
        HEADER_NOT_ALLOWED      = 7
        SEPARATOR_NOT_ALLOWED   = 8
        FILESIZE_NOT_ALLOWED    = 9
        HEADER_TOO_LONG         = 10
        DP_ERROR_CREATE         = 11
        DP_ERROR_SEND           = 12
        DP_ERROR_WRITE          = 13
        UNKNOWN_DP_ERROR        = 14
        ACCESS_DENIED           = 15
        DP_OUT_OF_MEMORY        = 16
        DISK_FULL               = 17
        DP_TIMEOUT              = 18
        FILE_NOT_FOUND          = 19
        DATAPROVIDER_EXCEPTION  = 20
        CONTROL_FLUSH_ERROR     = 21
        OTHERS                  = 22.



    IF SY-SUBRC <> 0.
      WRITE :/ 'error!!!!'  ,
             /  SY-MSGV1 ,
             /  SY-MSGV2 ,
             /  SY-MSGV3 ,
             /  SY-MSGV4 .

    ELSE.
      SKIP 2 .
      FORMAT COLOR 3 ON.
      WRITE : / 'Se genero archivo :',  NOMBRE_A.
      FORMAT COLOR 3 OFF.
    ENDIF.
  ENDIF.
ENDFORM.                    "bajar_archivo
