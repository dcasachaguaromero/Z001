*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZFIR001_CONC_BANCOS
*&
*&---------------------------------------------------------------------*
*& Respons  Fecha       Observaciones
*&---------------------------------------------------------------------*
*& LBERNAL  22.08.2011  Agregar CtaContable y Opcion solo Detalle
*& LBERNAL  29.08.2011  Ajustar Textos de los columnas y Layout
*& LBERNAL  08.09.2011  Monitoreo si es Proceso de Fondo
*&---------------------------------------------------------------------*

REPORT  ZFIR001_CONC_BANCOS
  NO STANDARD PAGE HEADING
    MESSAGE-ID ZFI.

INCLUDE ZFIR001_CONC_BANCOS_TOP.


*********** PARAMETROS ************************************************
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
  PARAMETERS:     P_BUKRS LIKE T001-BUKRS OBLIGATORY.    "Sociedad
  SELECT-OPTIONS: S_HBKID FOR  T012-HBKID NO INTERVALS,  "Bco.Propio
                  S_SAKNR FOR  SKB1-SAKNR NO INTERVALS,  "Cta.Contable
                  S_BLART FOR  BSIS-BLART NO INTERVALS
                               DEFAULT 'ZR' NO-DISPLAY.  "Tipo Documto
  PARAMETERS:
                  P_BUDAT LIKE SY-DATUM OBLIGATORY,      "Fecha
                  P_ACC   AS CHECKBOX,                   "Poyeccion Anual
                  P_OPEN  AS CHECKBOX DEFAULT 'X',       "Solo Partidas Abiertas
                  P_DETA  AS CHECKBOX,                   "Solo Detalle
                  P_PCTA  LIKE SKAT-ktopl      DEFAULT 'B100' NO-DISPLAY,
                  P_LEDGE TYPE FAGLFLEXT-RLDNR DEFAULT '0L'   NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK blk1.

PARAMETERS:
          S_VARI LIKE DISVARIANT-VARIANT MEMORY ID pid,
          P_ALV  AS CHECKBOX DEFAULT 'X'.


*********** AUTORIZACIONES ************************************************
AT SELECTION-SCREEN ON p_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e004(zfi) WITH 'Sin autorización para Sociedad.' p_bukrs.
  ENDIF.

* ------------------------------------------------------ ALV variants
AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_VARI.

  PERFORM FOR_VARIANT.
  PERFORM PAI_OF_SELECTION_SCREEN.


*********** INICIALIZACION ************************************************
INITIALIZATION.
  MOVE  SY-DATUM TO P_BUDAT.
  PERFORM ALV_INITIALIZATION.



***********   PROCESO     ************************************************
START-OF-SELECTION.

  wa_batch = 'N'.
  IF sy-batch is initial.
     wa_batch = 'N'.
  ELSE.
     IF P_DETA is initial.
        wa_batch = 'S'.
     ENDIF.
  ENDIF.


  PERFORM select_param.
  IF P_OPEN = 'X' OR P_ACC = 'X'.
     PERFORM select_items_abiertos.
  ELSE.
     PERFORM select_items_abiertos.
     PERFORM select_items_compensadas.
  ENDIF.

* Asigno las Descripciones de Cuentas a Caratula y Proyeccion Anual.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
SORT IT_CARATULA .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  LOOP AT it_caratula.
       wa_tabix = sy-tabix.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*       SELECT SINGLE txt50 INTO it_caratula-txt50 FROM skat
*           WHERE ktopl = p_pcta
*             AND SAKNR = it_caratula-HKONT
*             AND spras = sy-langu.
*
* NEW CODE
       SELECT txt50
       UP TO 1 ROWS  INTO it_caratula-txt50 FROM skat
           WHERE ktopl = p_pcta
             AND SAKNR = it_caratula-HKONT
             AND spras = sy-langu ORDER BY PRIMARY KEY.

       ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
       MODIFY it_caratula index wa_tabix.
  ENDLOOP.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
SORT IT_PROYECCION .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  LOOP AT it_proyeccion.
       wa_tabix = sy-tabix.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*       SELECT SINGLE txt50 INTO it_proyeccion-txt50 FROM skat
*           WHERE ktopl = p_pcta
*             AND SAKNR = it_proyeccion-HKONT
*             AND spras = sy-langu.
*
* NEW CODE
       SELECT txt50
       UP TO 1 ROWS  INTO it_proyeccion-txt50 FROM skat
           WHERE ktopl = p_pcta
             AND SAKNR = it_proyeccion-HKONT
             AND spras = sy-langu ORDER BY PRIMARY KEY.

       ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
       MODIFY it_proyeccion index wa_tabix.
  ENDLOOP.


END-OF-SELECTION.

 IF P_DETA = 'X'.
      PERFORM BUSCA_DETALLE_OPEN.

 ELSE.
   IF P_ACC = 'X'.
      SORT it_proyeccion BY  bukrs hkont SISTEMA USUARIO.
      PERFORM lista_alv_proyeccion.
   ELSE.
      SORT it_caratula BY  bukrs hkont .
      PERFORM lista_alv.
   ENDIF.
  ENDIF.
*
INCLUDE ZFIR001_CONC_BANCOS_INCLUDE.
INCLUDE ZFIR001_CONC_BANCOS_ALV.

*
