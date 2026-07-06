*&---------------------------------------------------------------------*
*& Report  ZFI_BI_INTERFAZ_CONTAB
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFI_BI_INTERFAZ_CONTAB.
* Programa que permite cargar una planilla con saldos o Movs. contables

TABLES: BBKPF,      "Cab.documento para documento contable (estruct. bat
        BBSEG,      "Segmento de documento contable (estruct. batch inpu
        BGR00,      "Estructura batch input para datos de juego de datos
        BWITH.      "Estructura batch input para datos de Retención

DATA: BEGIN OF ARCH_PLANO OCCURS 100,       "                    Columna
            INDDOC(1),                      "Indice documento         A
            BLDAT(10),                      "F.documento (AAAAMMDD)   B
            BLART(2),                       "Clase documento          C
            BUKRS(4),                       "Sociedad                 D
            BUDAT(10),                      "F.contabil. (AAAAMMDD)   E
            MONAT(2),                       "Periodo                  F
            WAERS(4),                       "Moneda                   G
            KURSF(9),                       "Tipo Cambio Conversion   H
            BELNR(10),                      "Nº Documento             I
            WWERT(10),                      "Fecha Conversion         J
            XBLNR(16),                      "Referencia               K
            BKTXT(25),                      "Texto Cabecera de docto. L
            XMWST(1),                       "Calcula Imp.Automatica   M
            NEWBS(2),                       "Clave contabil.          N
            NEWKO(17),                      "Cuenta                   O
            NEWUM(1),                       "Indicador CME            P
            WRBTR(13),                      "Importe moneda documento Q
            DMBTR(13),                      "Importe moneda Local     R
            MWSKZ(02),                      "Indicador Impuesto       S
            GSBER(04),                      "División                 T
            ZFBDT(10),                      "Vence                    U
            ZTERM(4),                       "Condicion de Pago        V
            FILLE(1),                       "Base de Descuento        W
            VALUT(10),                      "Fecha Valor              X
            ZLSPR(1),                       "Bloqueo de pago          Y
            BANKL(15),                      "Clave de banco           Z
            BANKS(2),                       "Pais Banco               AA
            BANKN(15),                      "Cta. Corriente           AB
            REGUL(1),                       "Receptor Pago Ind.       AC
            NAME1(35),                      "Nombre Recep.Pago        AD
            NAME3(35),                      "Nombre Recep.Pago Cheq.  AE
            ORT01(35),                      "Ciudad                   AF
            ZUONR(18),                      "Asignacion               AG
            SGTXT(50),                      "Texto Posicion           AH
            KOSTL(10),                      "Centro Costo             AI
            PRCTR(10),                      "Centro Beneficio         AJ
            AUFNR(12),                      "Número de Orden          AK

END OF ARCH_PLANO.

DATA: NOMBRE_LOGICO LIKE V_FILENACI-FILEINTERN VALUE
                         'Z_INTERFAZ_FI',
                         JUEGO_DATOS(75),
                         ARCH_ENTRADA(75),
                         NOM_JD1(12),
                         FECHA_JD LIKE SY-DATUM,
                         REG(44),
                         NUEVO_DOCTO(1).


FIELD-SYMBOLS: <F>, <F1>         .

PARAMETERS: DATASET LIKE RLGRAP-FILENAME LOWER CASE.

START-OF-SELECTION.

*      Se lee el archivo plano con los datos de la interfaz
  PERFORM LEER_ARCH_PLANO.

  JUEGO_DATOS = 'CARGA'.
  OPEN DATASET JUEGO_DATOS FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

*      Inicializa las estructuras del batch-input con '/' (nodata)
  PERFORM INICIALIZA_JD USING BBSEG.
  PERFORM INICIALIZA_JD USING BBKPF.
  PERFORM INICIALIZA_JD USING BWITH.

*      Se genera la estructura de datos

  PERFORM CREAR_JUEGO_DATOS.
  CLOSE DATASET JUEGO_DATOS.

*      Se llama al programa estandar que genera el batch input.
  SUBMIT RFBIBL00 WITH DS_NAME  = JUEGO_DATOS
                  WITH CALLMODE = 'B'
                  AND RETURN.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  INICIALIZA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TABLA      text
*----------------------------------------------------------------------*
FORM   INICIALIZA_JD USING TABLA.
  DATA: L_ACUMU TYPE I.

  DO.
    ADD 1 TO L_ACUMU.
    ASSIGN COMPONENT L_ACUMU OF STRUCTURE TABLA TO <F>.
    IF SY-SUBRC NE 0. EXIT. ENDIF.
    MOVE '/' TO <F>.
  ENDDO.

ENDFORM.                               "init_nodata

*&---------------------------------------------------------------------*
*&      Form  LEER_ARCH_PLANO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM LEER_ARCH_PLANO.
  CALL FUNCTION 'UPLOAD'
       EXPORTING
*        FILENAME  = 'C:\'
         FILENAME  = DATASET
         FILETYPE  = 'dat'
       TABLES
         DATA_TAB                      = ARCH_PLANO.

ENDFORM.                    "LEER_ARCH_PLANO

*&---------------------------------------------------------------------*
*&      Form  CREAR_JUEGO_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREAR_JUEGO_DATOS.
  DATA SEM.
*     Cabecera de la transacción con el juego de datos
  PERFORM CREA_CABECERA_JD USING JUEGO_DATOS.

  LOOP AT ARCH_PLANO.

    IF ARCH_PLANO-BUKRS NE SPACE.
      IF ARCH_PLANO-INDDOC = 'X'.
        PERFORM CREA_CABECERA_BBKPF USING JUEGO_DATOS.
        PERFORM CREA_CABECERA_BBSEG USING JUEGO_DATOS.
      ELSE.
        PERFORM CREA_CABECERA_BBSEG USING JUEGO_DATOS.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                               " F_CARGA_CUENTA

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_JD USING FICHERO.

  MOVE: '0'            TO BGR00-STYPE,
        FICHERO        TO BGR00-GROUP,
        SY-MANDT       TO BGR00-MANDT,
        SY-UNAME       TO BGR00-USNAM,
        'X'            TO BGR00-XKEEP,
        '/'            TO BGR00-NODATA.
  TRANSFER BGR00 TO FICHERO.

ENDFORM.                               "F_BATCH_DOCU

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBKPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_BBKPF USING FICHERO.

  MOVE: '1'                   TO BBKPF-STYPE,
        'FB01'                TO BBKPF-TCODE,    "Cod. transaccion
        ARCH_PLANO-BLART      TO BBKPF-BLART,    "Clase documento
        ARCH_PLANO-BUKRS      TO BBKPF-BUKRS,    "Sociedad
        ARCH_PLANO-MONAT      TO BBKPF-MONAT,    "Mes contable
        ARCH_PLANO-WAERS      TO BBKPF-WAERS,    "Moneda
        ARCH_PLANO-BKTXT      TO BBKPF-BKTXT.    "Texto Cab.Docto

  CONCATENATE ARCH_PLANO-BLDAT+0(2)
              ARCH_PLANO-BLDAT+3(2)
              ARCH_PLANO-BLDAT+6(4) INTO BBKPF-BLDAT.
  CONCATENATE ARCH_PLANO-BUDAT+0(2)
              ARCH_PLANO-BUDAT+3(2)
              ARCH_PLANO-BUDAT+6(4) INTO BBKPF-BUDAT.

  IF ARCH_PLANO-KURSF NE SPACE.
    MOVE ARCH_PLANO-KURSF    TO BBKPF-KURSF.
  ENDIF.
  IF ARCH_PLANO-BELNR NE SPACE.
    MOVE ARCH_PLANO-BELNR    TO BBKPF-BELNR.
  ENDIF.
  IF ARCH_PLANO-WWERT NE SPACE.
    CONCATENATE ARCH_PLANO-WWERT+0(2)
                ARCH_PLANO-WWERT+3(2)
                ARCH_PLANO-WWERT+6(4) INTO BBKPF-WWERT.
  ENDIF.
  IF ARCH_PLANO-XBLNR NE SPACE.
    MOVE ARCH_PLANO-XBLNR    TO BBKPF-XBLNR.
  ENDIF.


  TRANSFER BBKPF TO FICHERO.
  PERFORM INICIALIZA_JD USING BBKPF.

ENDFORM.                               "F_CREA_CABECERA_BBKPF

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_BBSEG USING FICHERO.
  DATA : XLIFNR       LIKE BBSEG-NEWKO,
         XKUNNR       LIKE BBSEG-NEWKO,
         XBBSEG-NEWKO LIKE BBSEG-NEWKO.

  MOVE '/'                   TO BBSEG-PRODPER.
  MOVE '2'                   TO BBSEG-STYPE.
  MOVE 'BBSEG'               TO BBSEG-TBNAM.
  MOVE  ARCH_PLANO-NEWBS     TO BBSEG-NEWBS.    "Clave contabil.
  MOVE  ARCH_PLANO-NEWKO     TO BBSEG-NEWKO.    "Cuenta
  MOVE  ARCH_PLANO-WRBTR     TO BBSEG-WRBTR.    "Importe mon doc
  MOVE  ARCH_PLANO-DMBTR     TO BBSEG-DMBTR.

*
*  Si Clave Contab. esta entre 21 y 39, Chequea si RUT Proveedor Existe
*
  IF ARCH_PLANO-NEWBS >= '21' AND ARCH_PLANO-NEWBS <= '39'.
    IF BBSEG-NEWKO > '1999990' AND
       BBSEG-NEWKO < '2999999'  OR
       BBSEG-NEWKO > 'REM000'  AND
       BBSEG-NEWKO < 'REM999'.
      MOVE BBSEG-NEWKO TO XBBSEG-NEWKO.
    ELSE.
      MOVE BBSEG-NEWKO(10)   TO XBBSEG-NEWKO.
      SELECT SINGLE LIFNR INTO XLIFNR FROM LFA1
                                  WHERE STCD1 EQ XBBSEG-NEWKO.
      IF SY-SUBRC <> 0.
        WRITE: / 'RUT del Proveedor no Existe : ', XBBSEG-NEWKO.
        EXIT.
      ELSE.
        MOVE  XLIFNR    TO BBSEG-NEWKO.    "Cuenta
        SELECT SINGLE LIFNR INTO XLIFNR FROM LFB1
                                WHERE LIFNR EQ XLIFNR AND
                                      BUKRS EQ ARCH_PLANO-BUKRS.
        IF SY-SUBRC <> 0.
          WRITE: / 'RUT del Proveedor no Existe en Sociedad : ',
                                     XBBSEG-NEWKO.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*
*  Si Clave Contab. esta entre 1 y 19, Chequea si RUT Cliente Existe
*
  IF ARCH_PLANO-NEWBS >= '01' AND ARCH_PLANO-NEWBS <= '19'.
    MOVE BBSEG-NEWKO(10)   TO XBBSEG-NEWKO.
    IF ARCH_PLANO-NEWBS > '01'.
      MOVE '/'   TO BBSEG-ZBD1T.
    ENDIF.
    MOVE BBSEG-NEWKO(10) TO XBBSEG-NEWKO.
    SELECT SINGLE KUNNR INTO XKUNNR FROM KNA1
                               WHERE STCD1 EQ XBBSEG-NEWKO.
    IF SY-SUBRC <> 0.
      WRITE: / 'RUT del Cliente no Existe : ', XBBSEG-NEWKO.
      EXIT.
    ELSE.
      MOVE XKUNNR  TO BBSEG-NEWKO.
      SELECT SINGLE KUNNR INTO XKUNNR FROM KNB1
                               WHERE KUNNR EQ XKUNNR AND
                                     BUKRS EQ ARCH_PLANO-BUKRS.
      IF SY-SUBRC <> 0.
        WRITE: / 'RUT del Cliente No Existe en Sociedad: ', XBBSEG-NEWKO.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.
*
  IF ARCH_PLANO-NEWUM NE SPACE.
    MOVE ARCH_PLANO-NEWUM    TO BBSEG-NEWUM.
  ENDIF.
  IF ARCH_PLANO-ZFBDT NE SPACE AND ARCH_PLANO-ZFBDT NE '00.00.0000'.
    CONCATENATE ARCH_PLANO-ZFBDT+0(2)
                ARCH_PLANO-ZFBDT+3(2)
                ARCH_PLANO-ZFBDT+6(4) INTO BBSEG-ZFBDT.
  ELSE.
    MOVE '/'   TO BBSEG-ZFBDT.
  ENDIF.

  IF ARCH_PLANO-ZTERM NE '/'.
    MOVE ARCH_PLANO-ZTERM TO BBSEG-ZTERM.
    MOVE '  '          TO BBSEG-ZBD1T.
  ELSE.
    IF ARCH_PLANO-NEWBS = '01'.
      MOVE '    '        TO BBSEG-ZTERM.
      MOVE '  '          TO BBSEG-ZBD1T.
    ENDIF.
  ENDIF.

  IF ARCH_PLANO-VALUT NE SPACE AND ARCH_PLANO-VALUT NE '00.00.0000'.
    CONCATENATE ARCH_PLANO-VALUT+0(2)
                ARCH_PLANO-VALUT+3(2)
                ARCH_PLANO-VALUT+6(4) INTO BBSEG-VALUT.
  ENDIF.
  IF ARCH_PLANO-ZLSPR NE SPACE.
    MOVE ARCH_PLANO-ZLSPR    TO BBSEG-ZLSPR.
  ENDIF.
*
  IF ARCH_PLANO-BANKL NE SPACE.
    MOVE ARCH_PLANO-BANKL    TO BBSEG-BANKL.
  ENDIF.
  IF ARCH_PLANO-BANKS NE SPACE.
    MOVE ARCH_PLANO-BANKS    TO BBSEG-BANKS.
  ENDIF.
  IF ARCH_PLANO-BANKN NE SPACE.
    MOVE ARCH_PLANO-BANKN    TO BBSEG-BANKN.
  ENDIF.
  IF ARCH_PLANO-REGUL NE SPACE.
    MOVE ARCH_PLANO-REGUL    TO BBSEG-REGUL.
  ENDIF.
  IF ARCH_PLANO-NAME1 NE SPACE.
    MOVE ARCH_PLANO-NAME1    TO BBSEG-NAME1.
  ENDIF.
  IF ARCH_PLANO-NAME3 NE SPACE.
    MOVE ARCH_PLANO-NAME3    TO BBSEG-NAME3.
  ENDIF.
  IF ARCH_PLANO-ORT01 NE SPACE.
    MOVE ARCH_PLANO-ORT01    TO BBSEG-ORT01.
  ENDIF.
  IF ARCH_PLANO-ZUONR NE SPACE.
    MOVE ARCH_PLANO-ZUONR    TO BBSEG-ZUONR.
  ENDIF.
  IF ARCH_PLANO-SGTXT NE SPACE.
    MOVE ARCH_PLANO-SGTXT    TO BBSEG-SGTXT.
  ENDIF.
  IF ARCH_PLANO-MWSKZ NE SPACE.
    MOVE ARCH_PLANO-MWSKZ    TO BBSEG-MWSKZ.
  ENDIF.
  IF ARCH_PLANO-KOSTL NE SPACE.
    MOVE ARCH_PLANO-KOSTL    TO BBSEG-KOSTL.
  ENDIF.
  IF ARCH_PLANO-AUFNR NE SPACE.
    MOVE ARCH_PLANO-AUFNR    TO BBSEG-AUFNR.
  ENDIF.
  IF ARCH_PLANO-PRCTR NE SPACE.
    MOVE ARCH_PLANO-PRCTR    TO BBSEG-PRCTR.
  ENDIF.
  IF ARCH_PLANO-GSBER NE SPACE.
    MOVE ARCH_PLANO-GSBER    TO BBSEG-GSBER.
  ENDIF.
*
  TRANSFER BBSEG TO FICHERO.
  PERFORM INICIALIZA_JD USING BBSEG.
*
ENDFORM.                    "CREA_CABECERA_BBSEG
