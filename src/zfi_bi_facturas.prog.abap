REPORT zfi_bi_facturas NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132.

TABLES: lfb1.




DATA : itab TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.

DATA: BEGIN OF tabla OCCURS 0,
        bukrs(4),         "Sociedad
        tipodoc(2),         "Tipo de Documento
        fecfac(10),        "Fecha Factura
        feccon(10),        "Fecha contabilizacion
        vblnr(10),        "Numero de Factura
        textocab(25),     "texto
        lifnr(10),        "Proveedor
        wrbtr(13),        "Valor
        xmwst(1),          "Calculo Impto.
        cpago(04),        "Cond. Pago
        zfbdt(10),         "Fecha Pago
        zlsch(1),         "Via Pago
        asignacion(18),   "Asignacion
        textolin(50),     "texto
        banco(5),         "Banco
        ctabanco(5),      "Cuenta Banco
        ref1(12),          "referncia  1
        ref2(12),          "referncia  2
        contracta(10),     " Contracuenta
        indimpto(2),     " indicador impuesto
        vertn(13),        "numero de contrato
        vertt(1),        " Tipo de Contrato

      END OF tabla.


SELECTION-SCREEN BEGIN OF BLOCK z1 WITH FRAME TITLE text-000.
SELECTION-SCREEN SKIP 2.
PARAMETERS : p_file  LIKE rlgrap-filename DEFAULT 'C:\' OBLIGATORY LOWER CASE.
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN END OF BLOCK z1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = ''
      def_path         = 'C:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Abrir Archivo desde PC'
    IMPORTING
      filename         = p_file
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.

START-OF-SELECTION.
* VARIABLES leer planilla
  DATA : fr    LIKE rlgrap-filename,
         tipo  LIKE rlgrap-filetype.
* Asignacion de variables
  fr   = p_file.
  tipo = 'DAT'.

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename = fr
      filetype = tipo
    TABLES
      data_tab = tabla
    EXCEPTIONS
      OTHERS   = 9.
*
  IF sy-subrc NE 0.
    WRITE:/ 'SE HA PRESENTADO ERROR AL LEER ARCHIVO', p_file.
    STOP.
  ENDIF.


  IF tabla[] IS NOT INITIAL.

    PERFORM contabilizo.

  ELSE.

    MESSAGE e368(00) WITH 'No Existen Registros A Procesar'.

  ENDIF.

END-OF-SELECTION.

  INCLUDE zbatchinput.

*&---------------------------------------------------------------------*
*&      Form  CONTABILIZO_FACTURAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM contabilizo.

  DATA :  valor(15),
         cant_imp(6)  TYPE n.

  REFRESH: bdcdata, itab.

  LOOP AT tabla.


    PERFORM bdc_dynpro      USING 'SAPMF05A' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-NEWKO'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'BKPF-BLDAT'
                                  tabla-fecfac.
    PERFORM bdc_field       USING 'BKPF-BLART'
                                  tabla-tipodoc.
    PERFORM bdc_field       USING 'BKPF-BUKRS'
                                  tabla-bukrs.
    PERFORM bdc_field       USING 'BKPF-BUDAT'
                                  tabla-feccon.
    PERFORM bdc_field       USING 'BKPF-WAERS'
                                  'CLP'.

    PERFORM bdc_field       USING 'BKPF-XBLNR'
                                  tabla-vblnr.
    PERFORM bdc_field       USING 'BKPF-BKTXT'
                                  tabla-textocab.
    PERFORM bdc_field       USING 'RF05A-NEWBS'
                                  '01'.
    PERFORM bdc_field       USING 'RF05A-NEWKO'
                                  tabla-lifnr.


    WRITE  tabla-wrbtr CURRENCY 'CLP'  TO valor.



    PERFORM bdc_dynpro      USING 'SAPMF05A' '0301'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'BSEG-ZLSCH'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ZK'.
    PERFORM bdc_field       USING 'BSEG-WRBTR'
                                  valor.
    PERFORM bdc_field       USING 'BKPF-XMWST'
                                  tabla-xmwst.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input         = tabla-vertn
      IMPORTING
       OUTPUT        =  tabla-vertn.
              .


    PERFORM bdc_field       USING 'BSEG-VERTN'
                                  tabla-vertn.
    PERFORM bdc_field       USING 'BSEG-VERTT'
                                  tabla-vertt.
    PERFORM bdc_field       USING 'BSEG-ZTERM'
                                  tabla-cpago.
    PERFORM bdc_field       USING 'BSEG-ZFBDT'
                                  tabla-zfbdt.
    PERFORM bdc_field       USING 'BSEG-ZLSCH'
                                   tabla-zlsch.
    PERFORM bdc_field       USING 'BSEG-ZUONR'
                                   tabla-asignacion.
    PERFORM bdc_field       USING 'BSEG-SGTXT'
                                   tabla-textolin.
*    PERFORM bdc_field       USING 'BSEG-ZZMOT_EMIS'
*                                  tabla-motivo.
*    PERFORM bdc_field       USING 'BSEG-ZZ_AGENCIA'
*                                  tabla-agencia.

    SELECT SINGLE * FROM lfb1 WHERE lifnr = tabla-lifnr
                              AND   bukrs = tabla-bukrs.

    IF sy-subrc = 0.
      SELECT COUNT(*) INTO cant_imp FROM lfbw
                                    WHERE lifnr = tabla-lifnr
                                    AND   bukrs = tabla-bukrs.
      IF cant_imp > 0.
        PERFORM bdc_dynpro USING  'SAPLFWTD' '0100'.
        PERFORM bdc_field  USING  'BDC_CURSOR'
                                  'WITH_ITEM-WT_WITHCD(01)'.
        PERFORM bdc_field  USING 'BDC_OKCODE'
                                  '/00'.
        PERFORM bdc_field  USING  'WITH_ITEM-WT_WITHCD(01)'
                                  '  '.
      ENDIF.
    ENDIF.

    PERFORM bdc_dynpro      USING 'SAPMF05A' '0331'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF05A-NEWKO'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.

    PERFORM bdc_field       USING 'BSEG-HBKID'
                                  tabla-banco.
    PERFORM bdc_field       USING 'BSEG-HKTID'
                                  tabla-ctabanco.
    PERFORM bdc_field       USING 'BSEG-XREF1'
                                  tabla-ref1.
    PERFORM bdc_field       USING 'BSEG-XREF2'
                                  tabla-ref2.

    WRITE  tabla-wrbtr  CURRENCY 'CLP'  TO valor.
    PERFORM bdc_field       USING 'RF05A-NEWBS'
                                   '50'.
    PERFORM bdc_field       USING 'RF05A-NEWKO'
                                  tabla-contracta.
    PERFORM bdc_dynpro      USING 'SAPMF05A' '0300'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'BSEG-SGTXT'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=BU'.
    PERFORM bdc_field       USING 'BSEG-WRBTR'
                                   valor.
    PERFORM bdc_field       USING 'BSEG-MWSKZ'
                                 tabla-indimpto.

    PERFORM bdc_dynpro      USING 'SAPLKACB' '0002'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'COBL-PRCTR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTE'.

    CALL TRANSACTION 'F-02' USING  bdcdata
                                   MODE 'E'
                                   UPDATE 'S'
                                   MESSAGES INTO itab.



    REFRESH: bdcdata, itab.

  ENDLOOP.

ENDFORM.                    "contabilizar
