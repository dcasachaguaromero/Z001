*&---------------------------------------------------------------------*
*& Report  ZSDREPMSG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zsdrepmsg.

CONSTANTS: c_n TYPE c VALUE 'N',
           c_s TYPE c VALUE 'S'.

TYPES: BEGIN OF t_nast,
         kappl TYPE nast-kappl,
         objky TYPE nast-objky,
         kschl TYPE nast-kschl,
         spras TYPE nast-spras,
         parnr TYPE nast-parnr,
         parvw TYPE nast-parvw,
         erdat TYPE nast-erdat,
         eruhr TYPE nast-eruhr,
         vstat TYPE nast-vstat,
       END OF t_nast.

DATA: ti_nast TYPE TABLE OF t_nast,
      wa_nast TYPE t_nast.

DATA ctumode TYPE c LENGTH 1.
DATA bdcdata LIKE bdcdata OCCURS 0 WITH HEADER LINE.
DATA messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA opt TYPE ctu_params.
DATA: lineas  TYPE i.
DATA: l_kschl TYPE kschl.
DATA: l_fkart  TYPE fkart,
      l_zblart TYPE BLART.
PARAMETERS p_vbeln LIKE vbrk-vbeln.

START-OF-SELECTION.
  DATA : objky    TYPE vbrk-vbeln,
         clas_doc TYPE vbrk-fkart,
         marca TYPE ztdea-dea.
  CLEAR ctumode.

  REFRESH bdcdata.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_vbeln
    IMPORTING
      output = objky.


* BUSCA EL TIPO DE MENSAJE ASOCIADO A LA FACTURA
  SELECT SINGLE fkart zblart INTO ( l_fkart, l_zblart )
         FROM vbrk WHERE vbeln EQ objky.

  CASE l_fkart.
    WHEN 'ZBOL'.
      l_kschl = 'ZBOE'.
    WHEN OTHERS.
      l_kschl = 'ZFAE'.
  ENDCASE.

  SELECT kappl objky kschl spras
         parnr parvw erdat eruhr
         vstat
    INTO TABLE ti_nast
    FROM nast
    WHERE kappl EQ 'V3'
      AND objky EQ objky
      AND kschl EQ l_kschl.

***Solo se repite el mensaje para las clase de documento de la tabla
***ZTDEA que tenga marcado el campo DEA
  SELECT SINGLE zblart
    INTO clas_doc
    FROM zcabpedext
    WHERE factura EQ objky.

  IF sy-subrc <> 0.
     clas_doc = l_zblart.
  ENDIF.

  SELECT SINGLE dea
    INTO marca
    FROM ztdea
    WHERE blart EQ clas_doc.

  CHECK NOT marca IS INITIAL.

  IF ti_nast[] IS INITIAL."Crear mensaje
    PERFORM bdc_dynpro USING 'SAPMV60A'        '0101'.
    PERFORM bdc_field  USING 'BDC_CURSOR'      'VBRK-VBELN'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '/00'.
    PERFORM bdc_field  USING 'VBRK-VBELN'      p_vbeln.

    PERFORM bdc_dynpro USING 'SAPMV60A'        '0104'.
    PERFORM bdc_field  USING 'BDC_CURSOR'      'VBRK-FKART'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=KDOK'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0100'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '/00'.
    PERFORM bdc_field  USING 'DNAST-KSCHL(01)' l_kschl.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0100'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70I'.
    PERFORM bdc_field  USING 'DV70A-SELKZ(01)' 'X'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0102'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70B'.
    PERFORM bdc_field  USING 'NAST-VSZTP'      '3'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0100'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70P'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0101'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70B'.
    PERFORM bdc_field  USING 'NAST-LDEST'      'locl'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0100'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70S'.

  ELSE."Copiar mensaje de haberse tratado antes
    READ TABLE ti_nast INTO wa_nast WITH KEY vstat = '0'.
    CHECK sy-subrc NE 0.
    PERFORM bdc_dynpro USING 'SAPMV60A'        '0101'.
    PERFORM bdc_field  USING 'BDC_CURSOR'      'VBRK-VBELN'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '/00'.
    PERFORM bdc_field  USING 'VBRK-VBELN'      p_vbeln.

    PERFORM bdc_dynpro USING 'SAPMV60A'        '0104'.
    PERFORM bdc_field  USING 'BDC_CURSOR'      'VBRK-FKART'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=KDOK'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0100'.
    PERFORM bdc_field  USING 'BDC_CURSOR'      'DV70A-STATUSICON(01)'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70R'.
    PERFORM bdc_field  USING 'DV70A-SELKZ(01)' 'X'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0100'.
    PERFORM bdc_field  USING 'BDC_CURSOR'      'DV70A-STATUSICON(01)'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70I'.
    PERFORM bdc_field  USING 'DV70A-SELKZ(01)' 'X'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0102'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70B'.
    PERFORM bdc_field  USING 'NAST-VSZTP'      '3'.

    PERFORM bdc_dynpro USING 'SAPDV70A'        '0100'.
    PERFORM bdc_field  USING 'BDC_CURSOR'      'DNAST-KSCHL(01)'.
    PERFORM bdc_field  USING 'BDC_OKCODE'      '=V70S'.
  ENDIF.

  REFRESH messtab.
  opt-dismode = c_n.
  opt-updmode = c_s.
  CALL TRANSACTION 'VF02' USING bdcdata
                          OPTIONS FROM opt
                          MESSAGES INTO messtab.

*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.

  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.

ENDFORM.                    " BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.

  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.

ENDFORM.                    " BDC_DYNPRO
