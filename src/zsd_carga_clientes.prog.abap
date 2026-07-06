*&---------------------------------------------------------------------*
*& Report  ZSD_CARGA_CLIENTES
*&---------------------------------------------------------------------*
*& Autor : Christian Muñoz
*& Empresa : Visionone
*& Transacción : ZSDBI0001
*& Fecha : 01.12.2011
*& Descripcion: Carga masiva de clientes e interlocutores
*&---------------------------------------------------------------------*

REPORT  zsd_carga_clientes.

DATA t_data TYPE STANDARD TABLE OF zsd_bi_clientes.
DATA wa_data LIKE LINE OF t_data.

DATA t_data_int TYPE STANDARD TABLE OF zsd_bi_cli_int.
DATA t_data_int_aux TYPE STANDARD TABLE OF zsd_bi_cli_int.
DATA wa_data_int LIKE LINE OF t_data.
DATA wa_data_int_aux LIKE LINE OF t_data_int_aux.

DATA bdcdata TYPE STANDARD TABLE OF bdcdata.
DATA ls_bdc  LIKE LINE OF bdcdata.
DATA ctumode TYPE ctu_mode   VALUE 'N'.
DATA cupdate TYPE ctu_update VALUE 'L'.
DATA messtab TYPE STANDARD TABLE OF bdcmsgcoll.
DATA ls_mess LIKE LINE OF messtab.
DATA t_log TYPE STANDARD TABLE OF bdcmsgcoll.
DATA gs_thead TYPE thead  .
DATA t_lines TYPE STANDARD TABLE OF tline.
DATA gs_lines LIKE LINE OF t_lines.
DATA g_regindex(10) TYPE c.
DATA l_message TYPE bapi_msg.
DATA l_kunnr TYPE kna1-kunnr.
DATA: c_xd01 TYPE sy-tcode VALUE 'XD01',
      c_xd02 TYPE sy-tcode VALUE 'XD02'.

FIELD-SYMBOLS: <fs_cliente> TYPE zsd_bi_clientes.


SELECTION-SCREEN: BEGIN OF BLOCK uno WITH FRAME TITLE text-001.
PARAMETERS:c1 RADIOBUTTON GROUP g1 DEFAULT 'X',
*          C2 RADIOBUTTON GROUP G1 ,
           c3 RADIOBUTTON GROUP g1.
SELECTION-SCREEN: END OF BLOCK uno.

SELECTION-SCREEN: BEGIN OF BLOCK dos WITH FRAME TITLE text-003.
PARAMETERS:r1 RADIOBUTTON GROUP g2 DEFAULT 'X' USER-COMMAND aaaa,
           r2 RADIOBUTTON GROUP g2.
PARAMETERS: p_file(128) TYPE c DEFAULT 'D:\' LOWER CASE .
PARAMETERS: p_infile  TYPE rlgrap-filename
                        DEFAULT  '/usr/sap/'.
SELECTION-SCREEN: END OF BLOCK dos.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
*---- Opción 1
    IF r1 = 'X'.
      IF screen-name CS 'P_FILE'.
        screen-invisible = '0'.
        screen-input = '1'.
      ELSEIF screen-name CS 'P_INFILE'  .
        screen-invisible = '1'.
        screen-input = '0'.
      ENDIF.

*---- Opción 2
    ELSEIF r2 = 'X'.
      IF screen-name CS 'P_INFILE'.
        screen-invisible = '0'.
        screen-input = '1'.
      ELSEIF screen-name CS 'P_FILE'.
        screen-invisible = '1'.
        screen-input = '0'.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM open_dialog.

START-OF-SELECTION.
  PERFORM subir_archivo.
  CHECK sy-subrc = 0.
  CASE 'X'.
    WHEN c1. "Crear Clientes
      LOOP AT t_data ASSIGNING <fs_cliente>."INTO wa_data.
        g_regindex = sy-tabix.
        CLEAR l_kunnr.
****Se buscará por el rut, para ello se creó un indice a la KNA1
        SELECT kunnr UP TO 1 ROWS
          INTO l_kunnr
          FROM kna1
          WHERE stcd1 = <fs_cliente>-rut2.
        ENDSELECT.

        IF l_kunnr IS INITIAL.
          PERFORM crear_cliente.
        ELSE.
          PERFORM ampliar_cliente.
        ENDIF.
      ENDLOOP.
    WHEN c3."Interlocutores
      SORT t_data_int BY nrocliente
                         oventas
                         canal
                         sector.

      LOOP AT t_data_int INTO wa_data_int.
        g_regindex = sy-tabix.
        READ TABLE t_data_int_aux
        WITH KEY nrocliente = wa_data_int-nrocliente
                 oventas = wa_data_int-oventas
                 canal = wa_data_int-canal
                 sector = wa_data_int-sector
                 TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          APPEND wa_data_int TO t_data_int_aux.
        ELSE.
          PERFORM asignar_interlocutores.
          APPEND wa_data_int TO t_data_int_aux.
        ENDIF.
      ENDLOOP.
      PERFORM asignar_interlocutores.

    WHEN OTHERS.
  ENDCASE.
  IF t_log IS NOT INITIAL.
    PERFORM display_log.
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  CREAR_CLIENTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM crear_cliente .
  DATA ls_log LIKE LINE OF t_log.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF02D-REF_KUNNR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF02D-BUKRS'
                                <fs_cliente>-sociedad.
                                                            "'CL51'.
  PERFORM bdc_field       USING 'RF02D-VKORG'
                                <fs_cliente>-oventas.
                                                            "'cl51'.
  PERFORM bdc_field       USING 'RF02D-VTWEG'
                                <fs_cliente>-canal.         "'01'.
  PERFORM bdc_field       USING 'RF02D-SPART'
                                <fs_cliente>-sector.        "'00'.
  PERFORM bdc_field       USING 'RF02D-KTOKD'
                                <fs_cliente>-grupocuentas.
                                                            "'Z001'.
  PERFORM bdc_field       USING 'USE_ZAV'
                                'X'.
**----------------------------------------------------------------------

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=$MTE'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ADDR1_DATA-REMARK'.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME1'
                                <fs_cliente>-nombre1.       "'nombre1'.
  PERFORM bdc_field       USING 'ADDR1_DATA-NAME2'
                                <fs_cliente>-nombre2.       "'nombre2'.
  PERFORM bdc_field       USING 'ADDR1_DATA-SORT1'
                                <fs_cliente>-rut."'15.331.915-4'.
  PERFORM bdc_field       USING 'ADDR1_DATA-SORT2'
                                <fs_cliente>-nroclientecore."'num.core
  PERFORM bdc_field       USING 'ADDR1_DATA-BUILDING'
                                <fs_cliente>-depto."'depto'.
  PERFORM bdc_field       USING 'ADDR1_DATA-FLOOR'
                                <fs_cliente>-piso."'piso'.
  PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL1'
                                <fs_cliente>-calle2.        "'calle2'.
  PERFORM bdc_field       USING 'ADDR1_DATA-STR_SUPPL2'
                                <fs_cliente>-block."'block'.
  PERFORM bdc_field       USING 'ADDR1_DATA-STREET'
                                <fs_cliente>-calle."'calle'.
  PERFORM bdc_field       USING 'ADDR1_DATA-HOUSE_NUM1'
                                <fs_cliente>-numero."'num'.
  PERFORM bdc_field       USING 'ADDR1_DATA-LOCATION'
                                <fs_cliente>-villa."'villa'.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY2'
                                <fs_cliente>-comuna."'comuna'.
  PERFORM bdc_field       USING 'ADDR1_DATA-CITY1'
                                <fs_cliente>-ciudad."'ciudad'.
  PERFORM bdc_field       USING 'ADDR1_DATA-COUNTRY'
                                <fs_cliente>-pais."'cl'.
  PERFORM bdc_field       USING 'ADDR1_DATA-REGION'
                                <fs_cliente>-region.        "'13'.
  PERFORM bdc_field       USING 'ADDR1_DATA-LANGU'
                                sy-langu.
  PERFORM bdc_field       USING 'ADDR1_DATA-REMARK'
                                <fs_cliente>-fechanac.

  PERFORM bdc_dynpro      USING 'SAPLSZA6' '0200'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NEWL'.
  PERFORM bdc_field       USING 'ADTEL-TEL_NUMBER(01)'
                                <fs_cliente>-telefono1."'telefono1.
**---------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPLSZA6' '0200'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NEWL'.
  PERFORM bdc_field       USING 'ADTEL-TEL_NUMBER(01)'
                                <fs_cliente>-telefono2.     "telefono2.
**--------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPLSZA6' '0200'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SHTM'.
  PERFORM bdc_field       USING 'ADTEL-TEL_NUMBER(01)'
                                <fs_cliente>-movil."movil.
  PERFORM bdc_field       USING 'G_SELECTED(01)'
                                'X'.
*-----------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPLSZA6' '0200'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CONT'.
**--------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=$MMO'.
**----------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPLSZA6' '0200'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CONT'.
**----------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ZUDA'.
**---------------------------------------------------

  PERFORM bdc_dynpro      USING 'SAPLV02Z' '0100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM bdc_field       USING 'KNA1-KATR1'
                                <fs_cliente>-prevision.
  PERFORM bdc_field       USING 'KNA1-KATR2'
                                <fs_cliente>-estadocivil.
  PERFORM bdc_field       USING 'KNA1-KATR3'
                                <fs_cliente>-sexo.
  PERFORM bdc_field       USING 'KNA1-KATR4'
                                <fs_cliente>-catcliente.
  PERFORM bdc_field       USING 'KNA1-KATR5'
                                <fs_cliente>-rangoetareo.
  PERFORM bdc_field       USING 'KNA1-KATR6'
                                <fs_cliente>-perfilcobranza.
  PERFORM bdc_field       USING 'KNA1-KATR7'
                                <fs_cliente>-rentabilidad.
  PERFORM bdc_field       USING 'KNA1-KATR8'
                                <fs_cliente>-profesion.
  PERFORM bdc_field       USING 'KNA1-KATR9'
                                <fs_cliente>-cargo.
**---------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0111'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
**--------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0120'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNA1-STCD1'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KNA1-STCD1'
                                <fs_cliente>-rut2.
**------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0125'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNA1-NIELS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
**------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0130'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNBK-BANKS(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0360'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNVK-NAMEV(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0210'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNB1-FDGRV'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KNB1-AKONT'
                                <fs_cliente>-cuentaasociada.
  PERFORM bdc_field       USING 'KNB1-ZUAWA'
                                <fs_cliente>-claveclasif.
  PERFORM bdc_field       USING 'KNB1-FDGRV'
                                <fs_cliente>-grupotesoreria.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0215'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNB1-HBKID'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KNB1-ZTERM'
                                <fs_cliente>-condicionpago. "'ZD00'.
  PERFORM bdc_field       USING 'KNB1-XZVER'
                                'X'.
  PERFORM bdc_field       USING 'KNB1-ZWELS'
                                <fs_cliente>-viapago."'DET'.
  PERFORM bdc_field       USING 'KNB1-HBKID'
                                <fs_cliente>-bancopropio.   "'BIC00'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0220'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNB5-MAHNA'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0230'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNB1-VRSNR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0610'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF02D-KUNNR'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0310'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNVV-BZIRK'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KNVV-BZIRK'
                                ''.
  PERFORM bdc_field       USING 'KNVV-AWAHR'
                                '100'.
  PERFORM bdc_field       USING 'KNVV-WAERS'
                                'CLP'.
  PERFORM bdc_field       USING 'KNVV-KALKS'
                                '1'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0320'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNVV-KTGRD'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'KNVV-ZTERM'
                                <fs_cliente>-condpago.      "'ZD00'.
  PERFORM bdc_field       USING 'KNVV-KTGRD'
                                <fs_cliente>-grupoimputacion. "'01'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '1350'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNVI-TAXKD(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM bdc_field       USING 'KNVI-TAXKD(01)'
                                <fs_cliente>-clasiffiscal.  "'1'.
**--------------------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '1350'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RF02D-KUNNR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=VW'.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0324'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=UPDA'.

**--------------------------------------------------------
*  PERFORM bdc_dynpro      USING 'SAPMF02D' '3500'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RF02D-KUNNR'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=UPDA'.

  CALL TRANSACTION c_xd01 USING bdcdata
                   MODE   ctumode
                   UPDATE cupdate
                   MESSAGES INTO messtab.

  CLEAR ls_mess.
  READ TABLE messtab INTO ls_mess WITH KEY msgtyp = 'S'
                              msgid = 'F2'
                              msgnr = '174'.
  IF sy-subrc = 0.
    ls_log-msgtyp = ls_mess-msgtyp.
    ls_log-msgid = '00'.
    ls_log-msgnr = '398'.
    ls_log-msgv1 = g_regindex .
    CONCATENATE text-006 "'El deudor'
                ls_mess-msgv1 INTO ls_log-msgv2 SEPARATED BY space.
    CONCATENATE text-007 "' se ha creado para sociedad'
                ls_mess-msgv2 INTO ls_log-msgv3 SEPARATED BY space.
    CONCATENATE text-008 "' y área de ventas'
                ls_mess-msgv3 INTO ls_log-msgv4 SEPARATED BY space.

    <fs_cliente>-nrocliente = ls_mess-msgv1.
    APPEND ls_log TO t_log.
    PERFORM actualizar_textos.
  ELSE.
    LOOP AT messtab INTO ls_mess WHERE msgtyp = 'A' OR msgtyp = 'E' OR
                                        msgtyp = 'I' OR msgtyp = 'W'
                                        OR msgtyp = 'S' OR msgtyp ='X'
                                        .

      MESSAGE ID ls_mess-msgid TYPE ls_mess-msgtyp NUMBER ls_mess-msgnr
        INTO l_message
        WITH ls_mess-msgv1 ls_mess-msgv2 ls_mess-msgv3 ls_mess-msgv4.
      CONDENSE l_message.
      ls_log-msgtyp = ls_mess-msgtyp.
      ls_log-msgid = '00'.
      ls_log-msgnr = '398'.
      ls_log-msgv1 = g_regindex .
      ls_log-msgv2 = l_message.
      APPEND ls_log TO t_log.
    ENDLOOP.
  ENDIF.
  FREE messtab.
  FREE bdcdata.
ENDFORM.                    " CREAR CLIENTE
*&---------------------------------------------------------------------*
*&      Form  SUBIR_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM subir_archivo .
  TYPE-POOLS: truxs.
  DATA: it_raw TYPE truxs_t_text_data.
  DATA: ld_file TYPE rlgrap-filename.
  FIELD-SYMBOLS: <fs> TYPE STANDARD TABLE,
                 <wa> TYPE ANY.

  DATA: wa_string(744) TYPE c.

  CLASS cl_abap_char_utilities DEFINITION LOAD.
  CONSTANTS:
     con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.

*Text version of data table
  TYPES: BEGIN OF t_uploadtxt,
    nrocliente(10) TYPE c,
    sociedad(4) TYPE c,
    oventas(4) TYPE c,
    canal(2) TYPE c,
    sector(2) TYPE c,
    grupocuentas(4) TYPE c,
    nombre1(30) TYPE c,
    nombre2(30) TYPE c,
    rut(20) TYPE c,
    nroclientecore(20) TYPE c,
    calle(60) TYPE c,
    calle2(40) TYPE c,
    numero(10) TYPE c,
    depto(20) TYPE c,
    piso(10) TYPE c,
    block(40) TYPE c,
    villa(40) TYPE c,
    comuna(40) TYPE c,
    ciudad(40) TYPE c,
    pais(3) TYPE c,
    region(3) TYPE c,
     fechanac(50) TYPE c,
     telefono1(30) TYPE c,
     telefono2(30) TYPE c,
     movil(30) TYPE c,
     prevision(2) TYPE c,
     estadocivil(2) TYPE c,
     sexo(2) TYPE c,
     catcliente(2) TYPE c,
     rangoetareo(2) TYPE c,
     perfilcobranza(3) TYPE c,
     rentabilidad(3) TYPE c,
     profesion(3) TYPE c,
     cargo(3) TYPE c,
     rut2(16) TYPE c,
     cuentaasociada(10) TYPE c,
     claveclasif(3) TYPE c,
     grupotesoreria(10) TYPE c,
     condicionpago(4) TYPE c,
     viapago(10) TYPE c,
    grabarhpagos(1) TYPE c,
    bancopropio(5) TYPE c,
    condpago(4) TYPE c,
    grupoimputacion(2) TYPE c,
    clasiffiscal(1) TYPE c,
    texto1(40) TYPE c,
    texto2(40) TYPE c,
   END OF t_uploadtxt.
  DATA: wa_uploadtxt TYPE t_uploadtxt.
  TYPES: BEGIN OF t_uploadtxt2,
      nrocliente(10) TYPE c,
      oventas(4) TYPE c,
      canal(2) TYPE c,
      sector(2) TYPE c,
      funcionint(2) TYPE c,
      codigoint(10) TYPE c,
   END OF t_uploadtxt2.
  DATA: wa_uploadtxt2 TYPE t_uploadtxt2.

  CASE 'X'.
    WHEN c1 .                                               "OR C2.
      ASSIGN t_data[] TO <fs>.
      ASSIGN wa_data TO <wa>.
    WHEN c3.
      ASSIGN t_data_int[] TO <fs>.
      ASSIGN wa_data_int TO <wa>.

    WHEN OTHERS.
  ENDCASE.

**---------------------------------------
  IF r1 = 'X'." Local
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_line_header        = 'X'
        i_tab_raw_data       = it_raw       " WORK TABLE
        i_filename           = p_file
      TABLES
        i_tab_converted_data = <fs>    "ACTUAL DATA
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF <fs> IS INITIAL.
        sy-subrc = 4.
        MESSAGE 'No existen registros para procesar'(002) TYPE 'I'.
      ENDIF.
    ENDIF.
  ELSEIF r2 = 'X'.
    ld_file = p_infile.
    OPEN DATASET ld_file FOR INPUT IN TEXT MODE ENCODING DEFAULT
    IGNORING CONVERSION ERRORS.
    IF sy-subrc <> 0.
      MESSAGE 'Error al abrir archivo en servidor(OPEN)'(004) TYPE 'I'.
    ELSE.
      DO.
        CLEAR: wa_string, wa_uploadtxt.
        READ DATASET ld_file INTO wa_string.
        IF sy-subrc <> 0.
          EXIT.
        ELSE.
          CASE 'X'.
            WHEN c1 .                                       "OR C2.
              SPLIT wa_string AT con_tab INTO
                  wa_uploadtxt-nrocliente
                  wa_uploadtxt-sociedad
                  wa_uploadtxt-oventas
                  wa_uploadtxt-canal
                  wa_uploadtxt-sector
                  wa_uploadtxt-grupocuentas
                  wa_uploadtxt-nombre1
                  wa_uploadtxt-nombre2
                  wa_uploadtxt-rut
                  wa_uploadtxt-nroclientecore
                  wa_uploadtxt-calle
                  wa_uploadtxt-calle2
                  wa_uploadtxt-numero
                  wa_uploadtxt-depto
                  wa_uploadtxt-piso
                  wa_uploadtxt-block
                  wa_uploadtxt-villa
                  wa_uploadtxt-comuna
                  wa_uploadtxt-ciudad
                  wa_uploadtxt-pais
                  wa_uploadtxt-region
                  wa_uploadtxt-fechanac
                  wa_uploadtxt-telefono1
                  wa_uploadtxt-telefono2
                  wa_uploadtxt-movil
                  wa_uploadtxt-prevision
                  wa_uploadtxt-estadocivil
                  wa_uploadtxt-sexo
                  wa_uploadtxt-catcliente
                  wa_uploadtxt-rangoetareo
                  wa_uploadtxt-perfilcobranza
                  wa_uploadtxt-rentabilidad
                  wa_uploadtxt-profesion
                  wa_uploadtxt-cargo
                  wa_uploadtxt-rut2
                  wa_uploadtxt-cuentaasociada
                  wa_uploadtxt-claveclasif
                  wa_uploadtxt-grupotesoreria
                  wa_uploadtxt-condicionpago
                  wa_uploadtxt-viapago
                  wa_uploadtxt-grabarhpagos
                  wa_uploadtxt-bancopropio
                  wa_uploadtxt-condpago
                  wa_uploadtxt-grupoimputacion
                  wa_uploadtxt-clasiffiscal
                  wa_uploadtxt-texto1
                  wa_uploadtxt-texto2.


              PERFORM reemplazar USING 'Ñ'
                                 CHANGING wa_uploadtxt-comuna.

              PERFORM reemplazar USING 'Ñ'
                                 CHANGING wa_uploadtxt-calle.

              PERFORM reemplazar USING 'Ñ'
                                 CHANGING wa_uploadtxt-calle2.

              PERFORM reemplazar USING 'Ñ'
                                 CHANGING wa_uploadtxt-villa.

              MOVE-CORRESPONDING wa_uploadtxt TO <wa>.
            WHEN c3.
              SPLIT wa_string AT con_tab INTO
              wa_uploadtxt2-nrocliente
              wa_uploadtxt2-oventas
              wa_uploadtxt2-canal
              wa_uploadtxt2-sector
              wa_uploadtxt2-funcionint
              wa_uploadtxt2-codigoint.
              MOVE-CORRESPONDING wa_uploadtxt2 TO <wa>.

            WHEN OTHERS.
          ENDCASE.
          APPEND  <wa> TO <fs>.
        ENDIF.
      ENDDO.
      CLOSE DATASET ld_file.
    ENDIF.
  ENDIF.
ENDFORM.                    " SUBIR_ARCHIVO

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR ls_bdc.
  ls_bdc-program  = program.
  ls_bdc-dynpro   = dynpro.
  ls_bdc-dynbegin = 'X'.
  APPEND ls_bdc TO bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR ls_bdc.
  ls_bdc-fnam = fnam.
  ls_bdc-fval = fval.
  APPEND ls_bdc TO bdcdata.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_log .
  DATA: lf_obj        TYPE balobj_d,
        lf_subobj     TYPE balsubobj,
        ls_header     TYPE balhdri,
        lf_log_handle TYPE balloghndl,
        lf_log_number TYPE balognr,                         "#EC NEEDED
        lt_msg        TYPE balmi_tab,
        ls_msg        TYPE balmi.
*
  lf_obj     = 'ZSD_LOG'.
  CASE 'X'.
    WHEN c1.
      lf_subobj  = 'Z01'.
    WHEN c3.
      lf_subobj  = 'Z03'.
    WHEN OTHERS.
  ENDCASE.

  ls_header-object     = lf_obj.
  ls_header-subobject  = lf_subobj.
  ls_header-aldate     = sy-datum.
  ls_header-altime     = sy-uzeit.
  ls_header-aluser     = sy-uname.
  ls_header-aldate_del = sy-datum + 1.
*

  CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
    EXPORTING
      header              = ls_header
    IMPORTING
      e_log_handle        = lf_log_handle
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2
      error               = 3
      OTHERS              = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'BAL_DB_LOGNUMBER_GET'
    EXPORTING
      i_client                 = sy-mandt
      i_log_handle             = lf_log_handle
    IMPORTING
      e_lognumber              = lf_log_number              "#EC NEEDED
    EXCEPTIONS
      log_not_found            = 1
      lognumber_already_exists = 2
      numbering_error          = 3
      OTHERS                   = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT t_log INTO ls_mess.
    MOVE-CORRESPONDING  ls_mess TO ls_msg.
    MOVE: ls_mess-msgtyp TO ls_msg-msgty,
          ls_mess-msgnr TO ls_msg-msgno.
    APPEND ls_msg TO lt_msg.
  ENDLOOP.

  CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
    EXPORTING
      object              = lf_obj
      subobject           = lf_subobj
      log_handle          = lf_log_handle
    TABLES
      messages            = lt_msg
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2
      OTHERS              = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'.
ENDFORM.                    " DISPLAY_LOG
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZAR_TEXTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM actualizar_textos .
  DATA ls_log LIKE LINE OF t_log.
  CLEAR gs_thead.
  CLEAR gs_lines.
  REFRESH t_lines.

  gs_thead-tdobject = 'KNA1'.
  gs_thead-tdname = <fs_cliente>-nrocliente.
  gs_thead-tdid  =  'Z001'.
  gs_thead-tdspras = sy-langu.

  gs_lines-tdformat = '*'.
  gs_lines-tdline = <fs_cliente>-texto1.
  APPEND gs_lines TO t_lines.
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = gs_thead
      savemode_direct = 'X'
    TABLES
      lines           = t_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    PERFORM add_sy_mess_to_log.
  ELSE.
    ls_log-msgtyp = 'I'.
    ls_log-msgid = '00'.
    ls_log-msgnr = '398'.
    ls_log-msgv1 = g_regindex .
    ls_log-msgv2 = text-009. "'Texto1 Cliente'.
    ls_log-msgv3 = <fs_cliente>-nrocliente.
    ls_log-msgv4 = text-010."'actualizado con exito'.
    APPEND ls_log TO t_log.
  ENDIF.
**---------------------------------
  CLEAR gs_lines.
  REFRESH t_lines.
  gs_lines-tdformat = '*'.
  gs_lines-tdline = <fs_cliente>-texto2.
  APPEND gs_lines TO t_lines.
  gs_thead-tdid  =  'Z002'.
  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header          = gs_thead
      savemode_direct = 'X'
    TABLES
      lines           = t_lines
    EXCEPTIONS
      id              = 1
      language        = 2
      name            = 3
      object          = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    PERFORM add_sy_mess_to_log.
  ELSE.
    ls_log-msgtyp = 'I'.
    ls_log-msgid = '00'.
    ls_log-msgnr = '398'.
    ls_log-msgv1 = g_regindex .
    ls_log-msgv2 = text-011. "'Texto2 Cliente'.
    ls_log-msgv3 = <fs_cliente>-nrocliente.
    ls_log-msgv4 = text-010. "'actualizado con exito'.
    APPEND ls_log TO t_log.
  ENDIF.


ENDFORM.                    " ACTUALIZAR_TEXTOS
*&---------------------------------------------------------------------*
*&      Form  ADD_SY_MESS_TO_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM add_sy_mess_to_log .
  DATA ls_log LIKE LINE OF t_log.
  ls_log-msgtyp = sy-msgty.
  ls_log-msgspra = sy-langu.
  ls_log-msgid =  sy-msgid.
  ls_log-msgnr = sy-msgno.
  ls_log-msgv1 = sy-msgv1.
  ls_log-msgv2 = sy-msgv2.
  ls_log-msgv3 = sy-msgv3.
  ls_log-msgv4 =  sy-msgv3.
  APPEND  ls_log TO t_log.
ENDFORM.                    " ADD_SY_MESS_TO_LOG
*&---------------------------------------------------------------------*
*&      Form  ASIGNAR_INTERLOCUTORES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM asignar_interlocutores .
  TYPES: BEGIN OF t_knvp,
          parvw TYPE knvp-parvw,
          kunn2 TYPE knvp-kunn2,
         END OF t_knvp.

  DATA ls_log LIKE LINE OF t_log.
  DATA lt_knvp TYPE TABLE OF t_knvp.
  DATA l_flg_fun TYPE boolean.
  DATA l_nrocliente TYPE knvp-kunnr.
  DATA l_nrointerloc TYPE knvp-kunnr.

  FIELD-SYMBOLS : <fs_data> TYPE zsd_bi_cli_int,
                  <fs_knvp> TYPE t_knvp.

  sy-tfill = LINES( t_data_int_aux ).
  CHECK sy-tfill > 0.

  LOOP AT t_data_int_aux ASSIGNING <fs_data>.
    CLEAR : l_nrocliente, l_nrointerloc.
    CASE <fs_data>-funcionint.
      WHEN 'ZC'.
***Se buscara por el RUT del cliente, para ello se creó un indice
***en la tabla KNA1 con el campo STCD1
        SELECT SINGLE kunnr                                 "#EC *
        INTO l_nrocliente
        FROM kna1
         WHERE stcd1 = <fs_data>-nrocliente.
        CHECK sy-subrc = 0.

***Se buscara por el nombre del cliente, para ello se creó un indice
***en la tabla KNA1 con el campo NAME1
        SELECT SINGLE kunnr                                 "#EC *
        INTO l_nrointerloc
        FROM kna1
         WHERE name1 = <fs_data>-codigoint.

        CHECK sy-subrc = 0.
      WHEN 'ZB'.
        SELECT SINGLE kunnr                                 "#EC *
        INTO l_nrocliente
        FROM kna1
         WHERE name1 = <fs_data>-nrocliente.

        CHECK sy-subrc = 0.
        SELECT SINGLE kunnr                                 "#EC *
        INTO l_nrointerloc
        FROM kna1
         WHERE stcd1 = <fs_data>-codigoint.
        CHECK sy-subrc = 0.

      WHEN OTHERS.
    ENDCASE.
    <fs_data>-nrocliente = l_nrocliente.
    <fs_data>-codigoint = l_nrointerloc.
  ENDLOOP.

  READ TABLE t_data_int_aux ASSIGNING <fs_data> INDEX 1.
  CHECK sy-subrc = 0.
  REFRESH lt_knvp.
  SELECT parvw kunn2
    FROM knvp
    INTO TABLE lt_knvp
    WHERE kunnr = l_nrocliente      AND
          vkorg = <fs_data>-oventas AND
          vtweg = <fs_data>-canal   AND
          spart = <fs_data>-sector.

  IF sy-subrc = 0.
    SORT lt_knvp BY parvw.
    l_flg_fun = 'X'.
    sy-tfill = LINES( lt_knvp ).
    READ TABLE lt_knvp ASSIGNING <fs_knvp> INDEX sy-tfill.
  ENDIF.

  PERFORM bdc_dynpro      USING 'SAPMF02D' '0101'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RF02D-D0324'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'RF02D-KUNNR'
                                <fs_data>-nrocliente.
  PERFORM bdc_field       USING 'RF02D-VKORG'
                                <fs_data>-oventas.
  PERFORM bdc_field       USING 'RF02D-VTWEG'
                                <fs_data>-canal.
  PERFORM bdc_field       USING 'RF02D-SPART'
                                <fs_data>-sector.
  PERFORM bdc_field       USING 'RF02D-D0324'
                                'X'.
**----------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0324'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                '*RF02D-KTONR'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTR'.
  IF l_flg_fun = 'X'.
    PERFORM bdc_field       USING '*KNVP-PARVW'
                                  <fs_knvp>-parvw.
    PERFORM bdc_field       USING '*RF02D-KTONR'
                                  <fs_knvp>-kunn2.
  ENDIF.

  LOOP AT t_data_int_aux  ASSIGNING <fs_data>.
**----------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0324'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KTONR(02)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_field       USING 'KNVP-PARVW(02)'
                                  <fs_data>-funcionint.
    PERFORM bdc_field       USING 'RF02D-KTONR(02)'
                                  <fs_data>-codigoint.
**------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0324'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  '*RF02D-KTONR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_field       USING '*KNVP-PARVW'
                                  <fs_data>-funcionint.
    PERFORM bdc_field       USING '*RF02D-KTONR'
                                  <fs_data>-codigoint.
  ENDLOOP.
**----------------------------------------------
  PERFORM bdc_dynpro      USING 'SAPMF02D' '0324'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'KNVP-PARVW(01)'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=UPDA'.

  CALL TRANSACTION c_xd02 USING bdcdata
                   MODE   ctumode
                   UPDATE cupdate
                   MESSAGES INTO messtab.
  CLEAR ls_mess.
  READ TABLE messtab INTO ls_mess WITH KEY msgtyp = 'S'
                              msgid = 'F2'
                              msgnr = '056'.
  IF sy-subrc = 0.
    MESSAGE ID ls_mess-msgid TYPE ls_mess-msgtyp NUMBER ls_mess-msgnr
      INTO l_message
      WITH ls_mess-msgv1 ls_mess-msgv2 ls_mess-msgv3 ls_mess-msgv4.
    CONDENSE l_message.
**--
    LOOP AT t_data_int_aux INTO wa_data_int_aux.
      ls_log-msgtyp = ls_mess-msgtyp.
      ls_log-msgid = '00'.
      ls_log-msgnr = '398'.
      ls_log-msgv1 = wa_data_int_aux-nrocliente .
      CONCATENATE  wa_data_int_aux-oventas wa_data_int_aux-canal
      wa_data_int_aux-sector wa_data_int_aux-codigoint
                   INTO ls_log-msgv2 SEPARATED BY '-'.
      ls_log-msgv3 =  l_message.

      APPEND ls_log TO t_log.
    ENDLOOP.
  ELSE.
    LOOP AT messtab INTO ls_mess WHERE msgtyp <> 'S'.
      MESSAGE ID ls_mess-msgid TYPE ls_mess-msgtyp NUMBER ls_mess-msgnr
        INTO l_message
        WITH ls_mess-msgv1 ls_mess-msgv2 ls_mess-msgv3 ls_mess-msgv4.
      CONDENSE l_message.
      ls_log-msgtyp = ls_mess-msgtyp.
      ls_log-msgid = '00'.
      ls_log-msgnr = '398'.
      ls_log-msgv1 = wa_data_int_aux-nrocliente .
      ls_log-msgv2 = l_message.
      APPEND ls_log TO t_log.
    ENDLOOP.
  ENDIF.
  FREE messtab.
  FREE bdcdata.
  REFRESH  t_data_int_aux[].
ENDFORM.                    " ASIGNAR_INTERLOCUTORES
*&---------------------------------------------------------------------*
*&      Form  AMPLIAR_CLIENTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM ampliar_cliente .
  DATA ls_log LIKE LINE OF t_log.
  DATA: cliente TYPE kna1-kunnr.

  SELECT SINGLE kunnr
  INTO   cliente
  FROM   knb1
  WHERE  bukrs = <fs_cliente>-sociedad
  AND    kunnr = l_kunnr.

  IF cliente IS INITIAL.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'USE_ZAV'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF02D-KUNNR'
                                  l_kunnr.
    PERFORM bdc_field       USING 'RF02D-BUKRS'
                                  <fs_cliente>-sociedad.
    PERFORM bdc_field       USING 'RF02D-VKORG'
                                  <fs_cliente>-oventas.
    PERFORM bdc_field       USING 'RF02D-VTWEG'
                                  <fs_cliente>-canal.
    PERFORM bdc_field       USING 'RF02D-SPART'
                                  <fs_cliente>-sector.
    PERFORM bdc_field       USING 'RF02D-KTOKD'
                                  <fs_cliente>-grupocuentas.
    PERFORM bdc_field       USING 'USE_ZAV'
                                  'X'.
**---------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0210'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNB1-FDGRV'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KNB1-AKONT'
                                  <fs_cliente>-cuentaasociada.
    PERFORM bdc_field       USING 'KNB1-ZUAWA'
                                  <fs_cliente>-claveclasif.
    PERFORM bdc_field       USING 'KNB1-FDGRV'
                                  <fs_cliente>-grupotesoreria.
**--------------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0215'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNB1-ZWELS'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KNB1-ZTERM'
                                  <fs_cliente>-condicionpago.
    PERFORM bdc_field       USING 'KNB1-XZVER'
                                  'X'.
    PERFORM bdc_field       USING 'KNB1-ZWELS'
                                  <fs_cliente>-viapago.
    PERFORM bdc_field       USING 'KNB1-HBKID'
                                  <fs_cliente>-bancopropio.
**----------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0220'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNB5-MAHNA'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
**--------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0230'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNB1-VRSNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
**-------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0610'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KUNNR'.
**-----------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0310'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVV-BZIRK'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KNVV-AWAHR'
                                  '100'.
    PERFORM bdc_field       USING 'KNVV-WAERS'
                                  'CLP'.
    PERFORM bdc_field       USING 'KNVV-KALKS'
                                  '1'.
**------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0320'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVV-KTGRD'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KNVV-ZTERM'
                                  <fs_cliente>-condpago.
    PERFORM bdc_field       USING 'KNVV-KTGRD'
                                  <fs_cliente>-grupoimputacion.

    PERFORM bdc_dynpro      USING 'SAPMF02D' '1350'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVI-TAXKD(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_field       USING 'KNVI-TAXKD(01)'
                                  <fs_cliente>-clasiffiscal.
**--------------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '1350'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KUNNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=TEXT'.
**--------------------------------------------------------
    PERFORM bdc_dynpro      USING 'SAPMF02D' '3500'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KUNNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=UPDA'.
    CALL TRANSACTION c_xd01 USING bdcdata
                     MODE   ctumode
                     UPDATE cupdate
                     MESSAGES INTO messtab.
  ELSE.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KUNNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF02D-KUNNR'
                                  l_kunnr.
    PERFORM bdc_field       USING 'RF02D-BUKRS'
                                  <fs_cliente>-sociedad.
    PERFORM bdc_field       USING 'RF02D-VKORG'
                                  <fs_cliente>-oventas.
    PERFORM bdc_field       USING 'RF02D-VTWEG'
                                  <fs_cliente>-canal.
    PERFORM bdc_field       USING 'RF02D-SPART'
                                  <fs_cliente>-sector.
    PERFORM bdc_field       USING 'RF02D-KTOKD'
                                  <fs_cliente>-grupocuentas.
    PERFORM bdc_field       USING 'USE_ZAV'
                                  'X'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0310'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVV-BZIRK'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KNVV-AWAHR'
                                  '100'.
    PERFORM bdc_field       USING 'KNVV-WAERS'
                                  'CLP'.
    PERFORM bdc_field       USING 'KNVV-KALKS'
                                  '1'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0320'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVV-KTGRD'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KNVV-ZTERM'
                                  <fs_cliente>-condpago.
    PERFORM bdc_field       USING 'KNVV-KTGRD'
                                  <fs_cliente>-grupoimputacion.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '1350'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVI-TAXKD(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_field       USING 'KNVI-TAXKD(01)'
                                  <fs_cliente>-clasiffiscal. "'1'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '1350'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVI-TAXKD(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=UPDA'.
    CALL TRANSACTION c_xd01 USING bdcdata
                     MODE   ctumode
                     UPDATE cupdate
                     MESSAGES INTO messtab.
  ENDIF.

  CLEAR ls_mess.
  READ TABLE messtab INTO ls_mess WITH KEY msgtyp = 'S'
                              msgid = 'F2'
                              msgnr = '174'.
  IF sy-subrc = 0.
    ls_log-msgtyp = ls_mess-msgtyp.
    ls_log-msgid = '00'.
    ls_log-msgnr = '398'.
    ls_log-msgv1 = g_regindex .
    CONCATENATE text-006 "'El deudor'
                ls_mess-msgv1 INTO ls_log-msgv2 SEPARATED BY space.
    CONCATENATE text-007 "' se ha creado para sociedad'
                ls_mess-msgv2 INTO ls_log-msgv3 SEPARATED BY space.
    CONCATENATE text-008 "' y área de ventas'
                 ls_mess-msgv3 INTO ls_log-msgv4 SEPARATED BY space.
    <fs_cliente>-nrocliente = ls_mess-msgv1.
    APPEND ls_log TO t_log.
    PERFORM actualizar_textos.
  ELSE.
    LOOP AT messtab INTO ls_mess WHERE msgtyp <> 'S'.
      MESSAGE ID ls_mess-msgid TYPE ls_mess-msgtyp NUMBER ls_mess-msgnr
        INTO l_message
        WITH ls_mess-msgv1 ls_mess-msgv2 ls_mess-msgv3 ls_mess-msgv4.
      CONDENSE l_message.
      ls_log-msgtyp = ls_mess-msgtyp.
      ls_log-msgid = '00'.
      ls_log-msgnr = '398'.
      ls_log-msgv1 = g_regindex .
      ls_log-msgv2 = l_message.
      APPEND ls_log TO t_log.
    ENDLOOP.
  ENDIF.
  FREE messtab.
  FREE bdcdata.
ENDFORM.                    " AMPLIAR_CLIENTE
*&---------------------------------------------------------------------*
*&      Form  REEMPLAZAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_WA_UPLOADTXT_COMUNA  text
*----------------------------------------------------------------------*
FORM reemplazar  USING p_caracter
                 CHANGING p_texto.
  DATA: c_a(2) TYPE c VALUE '#A',
      c_e(2) TYPE c VALUE '#E',
      c_i(2) TYPE c VALUE '#I',
      c_o(2) TYPE c VALUE '#O',
      c_u(2) TYPE c VALUE '#U'.

  IF p_texto CS c_a OR
     p_texto CS c_e OR
     p_texto CS c_i OR
     p_texto CS c_o OR
     p_texto CS c_u.
    REPLACE ALL OCCURRENCES OF '#' IN p_texto
    WITH p_caracter.
  ENDIF.

  IF p_texto CS '#'.
    REPLACE ALL OCCURRENCES OF '#' IN p_texto
    WITH ' '.
  ENDIF.
ENDFORM.                    " REEMPLAZAR
*&---------------------------------------------------------------------*
*&      Form  OPEN_DIALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM open_dialog .
  DATA:lt_files TYPE filetable,
       l_file TYPE file_table,
       l_title TYPE string,
       l_subrc TYPE i,
       l_usr_act TYPE i,
       l_def_file TYPE string.

  l_title = text-005.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = l_title
      default_extension       = 'txt'
      default_filename        = '.txt'
    CHANGING
      file_table              = lt_files
      rc                      = l_subrc
      user_action             = l_usr_act
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0 AND
     l_usr_act <> cl_gui_frontend_services=>action_cancel.
    READ TABLE lt_files INTO l_file INDEX 1.
    IF sy-subrc = 0.
      MOVE l_file-filename TO l_def_file.
      MOVE l_def_file TO p_file.
    ENDIF.
  ENDIF.
ENDFORM.                    " OPEN_DIALOG
