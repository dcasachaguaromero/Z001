*&---------------------------------------------------------------------*
*&  Include           ZXVVFU01
*&---------------------------------------------------------------------*


CASE vbrk-vkorg.
  WHEN 'CL06'.                   "Bem.
    IF vbrk-fkart EQ 'ZFAC'.     "Clase de Documento Factura.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'G3'. "Factura Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'G4'. "Factura Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'G1'. "Factura Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'G2'. "Factura Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZBOL'.     "Clase de Documento Boleta.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'O3'. "Boleta Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'O4'. "Boleta Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'O1'. "Boleta Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'O2'. "Boleta Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZNC'.     "Clase de Documento Nota Credito.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'J3'. "Nota Credito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'J4'. "Nota Credito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'J1'. "Nota Credito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'J2'. "Nota Credito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZND'.     "Clase de Documento Nota Debito.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'L3'. "Nota Debito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'L4'. "Nota Debito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'L1'. "Nota Debito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'L2'. "Nota Debito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.

  WHEN 'CL51'.                   "Help.
    IF vbrk-fkart EQ 'ZFAC'.     "Clase de Documento Factura.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'G3'. "Factura Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'G4'. "Factura Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'G1'. "Factura Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'G2'. "Factura Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZBOL'.     "Clase de Documento Boleta.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'O3'. "Boleta Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'O4'. "Boleta Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'O1'. "Boleta Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'O2'. "Boleta Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZNC'.     "Clase de Documento Nota Credito.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'J3'. "Nota Credito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'J4'. "Nota Credito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'J1'. "Nota Credito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'J2'. "Nota Credito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZND'.     "Clase de Documento Nota Debito.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'L3'. "Nota Debito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'L4'. "Nota Debito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'L1'. "Nota Debito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'L2'. "Nota Debito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.

  WHEN 'CL57'.                   "Help Service.
    IF vbrk-fkart EQ 'ZFAC'.     "Clase de Documento Factura.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'G3'. "Factura Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'G4'. "Factura Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'G1'. "Factura Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'G2'. "Factura Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZBOL'.     "Clase de Documento Boleta.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'O3'. "Boleta Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'O4'. "Boleta Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'O1'. "Boleta Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'O2'. "Boleta Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZNC'.     "Clase de Documento Nota Credito.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'J3'. "Nota Credito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'J4'. "Nota Credito  Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'J1'. "Nota Credito  Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xacchd-bktxt = '.'.
            xaccit-blart = 'J2'. "Nota Credito  Exenta.
          ENDIF.
      ENDCASE.
    ENDIF.
    IF vbrk-fkart EQ 'ZND'.     "Clase de Documento Nota Debito.
      CASE cvbrp-kvgr1.
        WHEN '01'.               "Documento Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'L3'. "Nota Debito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'L4'. "Nota Debito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
        WHEN '02'.               "Documento No Electronico.
          IF cvbrp-kvgr2 = '01'. "Ind. impuesto.
            xaccit-blart = 'L1'. "Nota Debito Afecta.
            xacchd-bktxt = '.'.
          ELSE.
            xaccit-blart = 'L2'. "Nota Debito Exenta.
            xacchd-bktxt = '.'.
          ENDIF.
      ENDCASE.
    ENDIF.
ENDCASE.

IF vbrk-vkorg EQ 'CL06' OR vbrk-vkorg EQ 'CL51' OR vbrk-vkorg EQ 'CL57'.
  IF  vbrk-fkart EQ 'ZDYA'.
    xaccit-blart = 'ZJ'.
    xacchd-bktxt = '.'.
  ENDIF.
*IF vbrk-netwr EQ '0.00'.
* xaccit-blart = 'DR'.
* xacchd-bktxt = '.'.
*ENDIF.
  IF cvbrp-kvgr5 EQ '02'.
    xaccit-blart = 'ZJ'.
    xacchd-bktxt = '.'.
  ENDIF.
ENDIF.
