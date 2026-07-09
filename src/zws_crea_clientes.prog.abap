*&---------------------------------------------------------------------*
*& Report  ZWS_CREA_CLIENTES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZWS_CREA_CLIENTES.

DATA T_DATA TYPE STANDARD TABLE OF ZSD_BI_CLIENTES.
DATA WA_DATA LIKE LINE OF T_DATA.
DATA BDCDATA TYPE STANDARD TABLE OF BDCDATA.
DATA LS_BDC  LIKE LINE OF BDCDATA.
DATA CTUMODE TYPE CTU_MODE   VALUE 'N'.
DATA CUPDATE TYPE CTU_UPDATE VALUE 'L'.
DATA MESSTAB TYPE STANDARD TABLE OF BDCMSGCOLL.
*DATA LS_LOG LIKE LINE OF T_LOG.

PERFORM BDC_DYNPRO USING 'SAPMF02D'    '0100'.
PERFORM BDC_FIELD  USING 'BDC_CURSOR'  'RF02D-REF_KUNNR'.
PERFORM BDC_FIELD  USING 'BDC_OKCODE'  '/00'.
PERFORM BDC_FIELD  USING 'RF02D-BUKRS' WA_DATA-SOCIEDAD.    "CL51
PERFORM BDC_FIELD  USING 'RF02D-VKORG' WA_DATA-OVENTAS.     "CL51
PERFORM BDC_FIELD  USING 'RF02D-VTWEG' WA_DATA-CANAL.       "'01'.
PERFORM BDC_FIELD  USING 'RF02D-SPART' WA_DATA-SECTOR.      "'00'.
PERFORM BDC_FIELD  USING 'RF02D-KTOKD' WA_DATA-GRUPOCUENTAS. "'Z001'.
PERFORM BDC_FIELD  USING 'USE_ZAV'     'X'.
**----------------------------------------------------------------------
PERFORM BDC_DYNPRO USING 'SAPMF02D'              '0111'.
PERFORM BDC_FIELD  USING 'BDC_OKCODE'            '=$MTE'.
PERFORM BDC_FIELD  USING 'BDC_CURSOR'            'ADDR1_DATA-REMARK'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-NAME1'      WA_DATA-NOMBRE1. "'nombre1'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-NAME2'      WA_DATA-NOMBRE2. "'nombre2'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-SORT1'      WA_DATA-RUT."'15.331.915-4'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-SORT2'      WA_DATA-NROCLIENTECORE."'numero cli core
PERFORM BDC_FIELD  USING 'ADDR1_DATA-BUILDING'   WA_DATA-DEPTO."'depto'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-FLOOR'      WA_DATA-PISO."'piso'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-STR_SUPPL1' WA_DATA-CALLE2. "'calle2'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-STR_SUPPL2' WA_DATA-BLOCK."'block'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-STREET'     WA_DATA-CALLE."'calle'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-HOUSE_NUM1' WA_DATA-NUMERO."'num'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-LOCATION'   WA_DATA-VILLA."'villa'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-CITY2'      WA_DATA-COMUNA."'comuna'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-CITY1'      WA_DATA-CIUDAD."'ciudad'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-COUNTRY'    WA_DATA-PAIS."'cl'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-REGION'     WA_DATA-REGION. "'13'.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-LANGU'      SY-LANGU.
PERFORM BDC_FIELD  USING 'ADDR1_DATA-REMARK'     WA_DATA-FECHANAC.
**---------------------------------------------------
PERFORM BDC_DYNPRO USING 'SAPLSPO1' '0600'.
PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=OPT1'.
**---------------------------------------------------
PERFORM BDC_DYNPRO USING 'SAPLSZA6'   '0200'.
PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=NEWL'.
PERFORM BDC_FIELD  USING 'ADTEL-TEL_NUMBER(01)' WA_DATA-TELEFONO1."'telefono1.
**---------------------------------------------------
PERFORM BDC_DYNPRO USING 'SAPLSZA6' '0200'.
PERFORM BDC_FIELD  USING 'BDC_OKCODE' '=NEWL'.
PERFORM BDC_FIELD  USING 'ADTEL-TEL_NUMBER(01)' WA_DATA-TELEFONO2.            "tlefono2.
**--------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPLSZA6' '0200'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=SHTM'.
PERFORM BDC_FIELD       USING 'ADTEL-TEL_NUMBER(01)'
                              WA_DATA-MOVIL."movil.
PERFORM BDC_FIELD       USING 'G_SELECTED(01)'
                              'X'.
*-----------------------------------------------
PERFORM BDC_DYNPRO USING 'SAPLSZA6' '0200'.
PERFORM BDC_FIELD  USING 'BDC_OKCODE'                              '=CONT'.
**--------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0111'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=$MMO'.
**----------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPLSZA6' '0200'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=CONT'.
**----------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0111'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=ZUDA'.
**---------------------------------------------------

PERFORM BDC_DYNPRO      USING 'SAPLV02Z' '0100'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=BACK'.
PERFORM BDC_FIELD       USING 'KNA1-KATR1'
                              WA_DATA-PREVISION.
PERFORM BDC_FIELD       USING 'KNA1-KATR2'
                              WA_DATA-ESTADOCIVIL.
PERFORM BDC_FIELD       USING 'KNA1-KATR3'
                              WA_DATA-SEXO.
PERFORM BDC_FIELD       USING 'KNA1-KATR4'
                              WA_DATA-CATCLIENTE.
PERFORM BDC_FIELD       USING 'KNA1-KATR5'
                              WA_DATA-RANGOETAREO.
PERFORM BDC_FIELD       USING 'KNA1-KATR6'
                              WA_DATA-PERFILCOBRANZA.
PERFORM BDC_FIELD       USING 'KNA1-KATR7'
                              WA_DATA-RENTABILIDAD.
PERFORM BDC_FIELD       USING 'KNA1-KATR8'
                              WA_DATA-PROFESION.
PERFORM BDC_FIELD       USING 'KNA1-KATR9'
                              WA_DATA-CARGO.
**---------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0111'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
**--------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0120'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNA1-STCD1'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'KNA1-STCD1'
                              WA_DATA-RUT2.
**------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0125'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNA1-NIELS'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
**------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0130'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNBK-BANKS(01)'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=ENTR'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0360'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNVK-NAMEV(01)'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=ENTR'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0210'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNB1-FDGRV'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'KNB1-AKONT'
                              WA_DATA-CUENTAASOCIADA.
PERFORM BDC_FIELD       USING 'KNB1-ZUAWA'
                              WA_DATA-CLAVECLASIF.
PERFORM BDC_FIELD       USING 'KNB1-FDGRV'
                              WA_DATA-GRUPOTESORERIA.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0215'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNB1-HBKID'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'KNB1-ZTERM'
                              WA_DATA-CONDICIONPAGO.        "'ZD00'.
PERFORM BDC_FIELD       USING 'KNB1-XZVER'
                              'X'.
PERFORM BDC_FIELD       USING 'KNB1-ZWELS'
                              WA_DATA-VIAPAGO."'DET'.
PERFORM BDC_FIELD       USING 'KNB1-HBKID'
                              WA_DATA-BANCOPROPIO.          "'BIC00'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0220'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNB5-MAHNA'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0230'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNB1-VRSNR'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0610'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RF02D-KUNNR'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0310'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNVV-BZIRK'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'KNVV-BZIRK'
                              ''.
PERFORM BDC_FIELD       USING 'KNVV-AWAHR'
                              '100'.
PERFORM BDC_FIELD       USING 'KNVV-WAERS'
                              'CLP'.
PERFORM BDC_FIELD       USING 'KNVV-KALKS'
                              '1'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '0320'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNVV-KTGRD'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '/00'.
PERFORM BDC_FIELD       USING 'KNVV-ZTERM'
                              WA_DATA-CONDPAGO.             "'ZD00'.
PERFORM BDC_FIELD       USING 'KNVV-KTGRD'
                              WA_DATA-GRUPOIMPUTACION.      "'01'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '1350'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'KNVI-TAXKD(01)'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=ENTR'.
PERFORM BDC_FIELD       USING 'KNVI-TAXKD(01)'
                              WA_DATA-CLASIFFISCAL.         "'1'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '1350'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RF02D-KUNNR'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=TEXT'.
**--------------------------------------------------------
PERFORM BDC_DYNPRO      USING 'SAPMF02D' '3500'.
PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                              'RF02D-KUNNR'.
PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                              '=UPDA'.

CALL TRANSACTION 'XD01' USING BDCDATA
                 MODE   CTUMODE
                 UPDATE CUPDATE
                 MESSAGES INTO MESSTAB.

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PROGRAM    text
*      -->DYNPRO     text
*----------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.

  CLEAR LS_BDC.
  LS_BDC-PROGRAM  = PROGRAM.
  LS_BDC-DYNPRO   = DYNPRO.
  LS_BDC-DYNBEGIN = 'X'.
  APPEND LS_BDC TO BDCDATA.

ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FNAM       text
*      -->FVAL       text
*----------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.

  CLEAR LS_BDC.
  LS_BDC-FNAM = FNAM.
  LS_BDC-FVAL = FVAL.
  APPEND LS_BDC TO BDCDATA.

ENDFORM.                    "BDC_FIELD
