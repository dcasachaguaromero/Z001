*&---------------------------------------------------------------------*
*& Report  ZFIPROCESACHEQUES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFIPROCESACHEQUES.
TABLES: BSAK, T001, PAYR, REGUH.
TYPE-POOLS SLIS.

types: begin of est_salida,
        empresa(4) TYPE C,
        tipo(2) TYPE C,
        numero(13) TYPE C,
        rol_beneficiario(13) TYPE C,
        beneficiario(50) TYPE C,
        valor(18) TYPE N,
        fec_emision TYPE DATUM,
        num_opago(18) TYPE C,
        motivo(50) TYPE C,
        lugar_pago(27) TYPE C,
        tipo_doc(5) TYPE C,
        referencia(27) TYPE C,
        isap_cempresa(4) TYPE C,
        afil_nrut(13) TYPE C,
        dcomp(10) type c,"augbl
        dorig(10) type c,"belnr
        POS(3) TYPE C,
        CTA_CTE(18) TYPE C,
        BANCO(5) TYPE C,
       end of est_salida.

DATA: WA_T001 TYPE T001,
      R_BUKRS type range of T001-BUKRS WITH HEADER LINE,
      IT_BSAK TYPE STANDARD TABLE OF BSAK,
      SALIDA TYPE STANDARD TABLE OF EST_SALIDA WITH HEADER LINE,
      IT_PAYR TYPE STANDARD TABLE OF PAYR,
      WA_PAYR TYPE PAYR,
      IT_REGUH TYPE STANDARD TABLE OF REGUH,
      WA_REGUH TYPE REGUH.

DATA: DIAFECHA TYPE DATUM,
      BSAK_KEY LIKE LINE OF IT_BSAK.
FIELD-SYMBOLS: <FS_BSAK> TYPE BSAK.

PARAMETERS: FECPROCD TYPE DATUM, FECPROCH TYPE DATUM.

START-OF-SELECTION.

DIAFECHA = FECPROCD.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM T001 CLIENT SPECIFIED INTO WA_T001
*  WHERE MANDT EQ SY-MANDT
*        AND BUKRS LIKE 'CL%'.
*
* NEW CODE
SELECT *
 FROM T001 CLIENT SPECIFIED INTO WA_T001
  WHERE MANDT EQ SY-MANDT
        AND BUKRS LIKE 'CL%' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    r_bukrs-sign = 'I'.
    r_bukrs-option = 'EQ'.
    r_bukrs-low = WA_T001-BUKRS.
    APPEND R_BUKRS.
  ENDSELECT.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT *
*  FROM BSAK CLIENT SPECIFIED INTO TABLE IT_BSAK
*  WHERE MANDT EQ SY-MANDT
*        AND BUKRS IN R_BUKRS
*        AND AUGDT EQ DIAFECHA
*        AND SHKZG EQ 'H'.
*
* NEW CODE
SELECT *

  FROM BSAK CLIENT SPECIFIED INTO TABLE IT_BSAK
  WHERE MANDT EQ SY-MANDT
        AND BUKRS IN R_BUKRS
        AND AUGDT EQ DIAFECHA
        AND SHKZG EQ 'H' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM PAYR CLIENT SPECIFIED
*  INTO TABLE IT_PAYR
*  FOR ALL ENTRIES IN IT_BSAK
*  WHERE MANDT EQ IT_BSAK-MANDT
*        AND VBLNR EQ IT_BSAK-AUGBL.
*
* NEW CODE
SELECT *
 FROM PAYR CLIENT SPECIFIED
  INTO TABLE IT_PAYR
  FOR ALL ENTRIES IN IT_BSAK
  WHERE MANDT EQ IT_BSAK-MANDT
        AND VBLNR EQ IT_BSAK-AUGBL ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM REGUH CLIENT SPECIFIED
*  INTO TABLE IT_REGUH
*  FOR ALL ENTRIES IN IT_BSAK
*  WHERE MANDT EQ IT_BSAK-MANDT
*        AND VBLNR EQ IT_BSAK-AUGBL
*        AND ABSBU EQ IT_BSAK-BUKRS
*        AND XVORL NE 'X'
*        AND RZAWE EQ 'T'.
*
* NEW CODE
SELECT *
 FROM REGUH CLIENT SPECIFIED
  INTO TABLE IT_REGUH
  FOR ALL ENTRIES IN IT_BSAK
  WHERE MANDT EQ IT_BSAK-MANDT
        AND VBLNR EQ IT_BSAK-AUGBL
        AND ABSBU EQ IT_BSAK-BUKRS
        AND XVORL NE 'X'
        AND RZAWE EQ 'T' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

LOOP AT IT_PAYR INTO WA_PAYR.
*    BSAK_KEY-ANFBU = WA_PAYR-ZBUKR.
*    BSAK_KEY-HBKID = WA_PAYR-HBKID.
*    BSAK_KEY-HKTID = WA_PAYR-HKTID.
*    BSAK_KEY-ZLSCH = WA_PAYR-RZAWE.

    READ TABLE IT_BSAK WITH KEY AUGBL = WA_PAYR-VBLNR ASSIGNING <FS_BSAK>.
    IF sy-subrc EQ 0.
        SALIDA-empresa = <FS_BSAK>-BUKRS.
*        SALIDA-tipo = <FS_BSAK>-ZLSCH.
        SALIDA-TIPO = WA_PAYR-RZAWE.
        SALIDA-numero = WA_PAYR-CHECT.
        SALIDA-rol_beneficiario = <FS_BSAK>-LIFNR.
        SALIDA-beneficiario = WA_PAYR-ZNME1.
        SALIDA-valor = <FS_BSAK>-DMBTR.
        SALIDA-fec_emision = WA_PAYR-ZALDT.
*        SALIDA-num_opago
        SALIDA-motivo = <FS_BSAK>-SGTXT.
        SALIDA-lugar_pago = <FS_BSAK>-ZZ_AGENCIA.
        SALIDA-tipo_doc = <FS_BSAK>-BLART.
        SALIDA-referencia = <FS_BSAK>-XBLNR.
        SALIDA-isap_cempresa = <FS_BSAK>-BUKRS.
        SALIDA-afil_nrut = <FS_BSAK>-LIFNR.
        SALIDA-DCOMP = <FS_BSAK>-AUGBL.
        SALIDA-DORIG = <FS_BSAK>-BELNR.
        SALIDA-POS = <FS_BSAK>-BUZEI.
        SALIDA-CTA_CTE = WA_PAYR-UBHKT.
        SALIDA-BANCO = WA_PAYR-HBKID.
        APPEND SALIDA.
     ENDIF.
ENDLOOP.

LOOP AT IT_REGUH INTO WA_REGUH.
  READ TABLE IT_BSAK WITH KEY AUGBL = WA_REGUH-VBLNR ASSIGNING <FS_BSAK>.
    IF SY-SUBRC EQ 0.
        SALIDA-empresa = <FS_BSAK>-BUKRS.
*        SALIDA-tipo = <FS_BSAK>-ZLSCH.
        SALIDA-TIPO = WA_REGUH-RZAWE.
*        SALIDA-numero = WA_PAYR-CHECT.
        SALIDA-rol_beneficiario = <FS_BSAK>-LIFNR.
        SALIDA-beneficiario = WA_REGUH-ZNME1.
        SALIDA-valor = <FS_BSAK>-DMBTR.
        SALIDA-fec_emision = WA_REGUH-ZALDT.
        CONCATENATE WA_REGUH-LAUFD WA_REGUH-LAUFI INTO SALIDA-num_opago.
        SALIDA-motivo = <FS_BSAK>-SGTXT.
        SALIDA-lugar_pago = <FS_BSAK>-ZZ_AGENCIA.
        SALIDA-tipo_doc = <FS_BSAK>-BLART.
        SALIDA-referencia = <FS_BSAK>-XBLNR.
        SALIDA-isap_cempresa = <FS_BSAK>-BUKRS.
        SALIDA-afil_nrut = <FS_BSAK>-LIFNR.
        SALIDA-DCOMP = <FS_BSAK>-AUGBL.
        SALIDA-DORIG = <FS_BSAK>-BELNR.
        SALIDA-POS = <FS_BSAK>-BUZEI.
        SALIDA-CTA_CTE = WA_REGUH-UBKNT.
        SALIDA-BANCO = WA_REGUH-HBKID.
        APPEND SALIDA.
    ENDIF.
ENDLOOP.

EXEC SQL.
  CONNECT TO 'SAPCSC' AS 'CON'
  ENDEXEC.

EXEC SQL.
  SET CONNECTION 'CON'
  ENDEXEC.

TRY.
loop at SALIDA.
  exec sql.
    INSERT INTO SAP_PAGODOCTOS
        (
            EMPRESA,
            TIPO,
            NUMERO,
            ROL_BENEFICIARIO,
            BENEFICIARIO,
            VALOR,
            FEC_EMISION,
            NUM_OPAGO,
            MOTIVO,
            LUGAR_PAGO,
            TIPO_DOC,
            REFERENCIA,
            ISAP_CEMPRESA,
            AFIL_NRUT,
            DOC_COMPENSA,
            DOC_ORIGINAL,
            CUENTA_CTE,
            BANCO
        )
        VALUES
        (
            :SALIDA-empresa,
            :SALIDA-tipo,
            :SALIDA-numero,
            :SALIDA-rol_beneficiario,
            :SALIDA-beneficiario,
            :SALIDA-valor,
            TO_DATE(:SALIDA-fec_emision,'YYYYMMDD'),
            :SALIDA-num_opago,
            :SALIDA-motivo,
            :SALIDA-lugar_pago,
            :SALIDA-tipo_doc,
            :SALIDA-referencia,
            :SALIDA-isap_cempresa,
            :SALIDA-afil_nrut,
            :SALIDA-DCOMP,
            :SALIDA-DORIG,
            :SALIDA-CTA_CTE,
            :SALIDA-BANCO
        )
    endexec.
endloop.
catch cx_sy_native_sql_error.
  message text-001 type 'I'.
endtry.

exec sql.
  SET CONNECTION DEFAULT
endexec.
