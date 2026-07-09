*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_800
*&---------------------------------------------------------------------*

MODULE status_0900 OUTPUT.
  REFRESH tab.
  REFRESH tab.
  MOVE 'PROP' TO tab-fcode.
  APPEND tab.
  MOVE 'REFR' TO tab-fcode.
  APPEND tab.
  MOVE 'PAGO' TO tab-fcode.
  APPEND tab.
  MOVE 'MODMASS' TO tab-fcode.
  APPEND tab.
  MOVE 'EXCEL' TO tab-fcode.
  APPEND tab.
  MOVE 'MODREF' TO tab-fcode.
  APPEND tab.

  bloqueo = 'N'.
  SET  PF-STATUS 'ZFIPG002' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

   *bseg-bukrs = bukrs .
CLEAR ref.


ENDMODULE.                             " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0900 INPUT.

  CASE sy-ucomm.

    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'RW'.
      LEAVE TO SCREEN 0.
    WHEN 'MOD'.
      IF asig = 'X'.
        CLEAR: *bseg-xref1, *bseg-xref2, *bseg-xref3.
        PERFORM modifica_masivo3.
      elseif rese ='X'. "HCD 12-03-2019
        CLEAR: *bseg-xref1, *bseg-xref2, *bseg-xref3.
        PERFORM modifica_masivo4.
      ELSE.
        IF NOT *bseg-xref1 IS INITIAL OR
           NOT *bseg-xref2 IS INITIAL OR
           NOT *bseg-xref3 IS INITIAL.
          PERFORM modifica_masivo2.
        ELSE.
          MESSAGE e004(zfi) WITH 'Debe ingresar a lo menos un dato a modificar'.
        ENDIF.
      ENDIF.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  modifica_masivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM modifica_masivo2.
  DATA   BEGIN OF  t_bkdf  OCCURS 1.
          INCLUDE STRUCTURE  bkdf.
  DATA   END OF t_bkdf.

  DATA   BEGIN OF  t_bkpf OCCURS 1.
          INCLUDE STRUCTURE  bkpf.
  DATA   END OF t_bkpf.

  DATA   BEGIN OF  t_bsec OCCURS 1.
          INCLUDE STRUCTURE  bsec.
  DATA   END OF t_bsec.

  DATA   BEGIN OF  t_bsed OCCURS 1.
          INCLUDE STRUCTURE  bsed.
  DATA   END OF t_bsed.

  DATA   BEGIN OF  t_bseg  OCCURS 1.
          INCLUDE STRUCTURE  bseg .
  DATA   END OF t_bseg.

  DATA   BEGIN OF  t_bset OCCURS 1.
          INCLUDE STRUCTURE  bset.
  DATA   END OF t_bset.

  DATA   BEGIN OF  t_bseg_add OCCURS 1.
          INCLUDE STRUCTURE  bseg_add.
  DATA   END OF t_bseg_add.

  LOOP AT int_tabla3 WHERE sel = 'X'.
    REFRESH:  t_bkpf,t_bseg.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *  INTO t_bkpf FROM bkpf
*    WHERE bukrs = bukrs            AND
*          belnr = int_tabla3-belnr AND
*          gjahr = int_tabla3-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS   INTO t_bkpf FROM bkpf
    WHERE bukrs = bukrs            AND
          belnr = int_tabla3-belnr AND
          gjahr = int_tabla3-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    APPEND t_bkpf.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO t_bseg   FROM bseg
*    WHERE bukrs = bukrs            AND
*          belnr = int_tabla3-belnr AND
*          gjahr = int_tabla3-gjahr AND
*          buzei = int_tabla3-buzei.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO t_bseg   FROM bseg
    WHERE bukrs = bukrs            AND
          belnr = int_tabla3-belnr AND
          gjahr = int_tabla3-gjahr AND
          buzei = int_tabla3-buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF NOT *bseg-xref1 IS INITIAL.
      t_bseg-xref1 = *bseg-xref1.
    ENDIF.

    IF NOT *bseg-xref2 IS INITIAL.
      t_bseg-xref2 = *bseg-xref2.
    ENDIF.

    IF NOT *bseg-xref3 IS INITIAL.
      t_bseg-xref3 = *bseg-xref3.
    ENDIF.

    APPEND  t_bseg.
    CALL FUNCTION 'CHANGE_DOCUMENT'
      TABLES
        t_bkdf = t_bkdf
        t_bkpf = t_bkpf
        t_bsec = t_bsec
        t_bsed = t_bsed
        t_bseg = t_bseg
        t_bset = t_bset.

    IF sy-subrc = 0.
      int_tabla3-sel = ''.
      MODIFY int_tabla3 INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
        MESSAGE 'Datos actualizados' type 'I'.
ENDFORM.                    "modifica_masivo
*&---------------------------------------------------------------------*
*&      Module  BSEG-ZLSPR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*MODULE bseg-zlspr INPUT.
*  bloqueo = 'S'.
*ENDMODULE.                 " BSEG-ZLSPR  INPUT

FORM modifica_masivo3.
  DATA        VALOR_TRASPASO(18).

  DATA   BEGIN OF  t_bkdf  OCCURS 1.
          INCLUDE STRUCTURE  bkdf.
  DATA   END OF t_bkdf.

  DATA   BEGIN OF  t_bkpf OCCURS 1.
          INCLUDE STRUCTURE  bkpf.
  DATA   END OF t_bkpf.

  DATA   BEGIN OF  t_bsec OCCURS 1.
          INCLUDE STRUCTURE  bsec.
  DATA   END OF t_bsec.

  DATA   BEGIN OF  t_bsed OCCURS 1.
          INCLUDE STRUCTURE  bsed.
  DATA   END OF t_bsed.

  DATA   BEGIN OF  t_bseg  OCCURS 1.
          INCLUDE STRUCTURE  bseg .
  DATA   END OF t_bseg.

  DATA   BEGIN OF  t_bset OCCURS 1.
          INCLUDE STRUCTURE  bset.
  DATA   END OF t_bset.

  DATA   BEGIN OF  t_bseg_add OCCURS 1.
          INCLUDE STRUCTURE  bseg_add.
  DATA   END OF t_bseg_add.

  LOOP AT int_tabla3 WHERE sel = 'X'.
    REFRESH:  t_bkpf,t_bseg.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *  INTO t_bkpf FROM bkpf
*    WHERE bukrs = bukrs            AND
*          belnr = int_tabla3-belnr AND
*          gjahr = int_tabla3-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS   INTO t_bkpf FROM bkpf
    WHERE bukrs = bukrs            AND
          belnr = int_tabla3-belnr AND
          gjahr = int_tabla3-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    APPEND t_bkpf.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO t_bseg   FROM bseg
*    WHERE bukrs = bukrs            AND
*          belnr = int_tabla3-belnr AND
*          gjahr = int_tabla3-gjahr AND
*          buzei = int_tabla3-buzei.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO t_bseg   FROM bseg
    WHERE bukrs = bukrs            AND
          belnr = int_tabla3-belnr AND
          gjahr = int_tabla3-gjahr AND
          buzei = int_tabla3-buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* t_bseg-xref1 = t_bseg-zuonr. "ORIGINAL 25012019
*CAMBIO 25-01-2019 HCD
VALOR_TRASPASO = t_bseg-zuonr.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
 EXPORTING
  INPUT = VALOR_TRASPASO
 IMPORTING
  OUTPUT = t_bseg-xref1.

*FIN CAMBIO 25-01-2019 HCD



    APPEND  t_bseg.
    CALL FUNCTION 'CHANGE_DOCUMENT'
      TABLES
        t_bkdf = t_bkdf
        t_bkpf = t_bkpf
        t_bsec = t_bsec
        t_bsed = t_bsed
        t_bseg = t_bseg
        t_bset = t_bset.

    IF sy-subrc = 0.
      int_tabla3-sel = ''.
      MODIFY int_tabla3 INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
      MESSAGE 'Datos actualizados' type 'I'.
ENDFORM.                    "modifica_masivo

FORM modifica_masivo4.
  DATA        VALOR_TRASPASO(18).
  DATA   SECUENCIA(12).
  DATA   BEGIN OF  t_bkdf  OCCURS 1.
          INCLUDE STRUCTURE  bkdf.
  DATA   END OF t_bkdf.

  DATA   BEGIN OF  t_bkpf OCCURS 1.
          INCLUDE STRUCTURE  bkpf.
  DATA   END OF t_bkpf.

  DATA   BEGIN OF  t_bsec OCCURS 1.
          INCLUDE STRUCTURE  bsec.
  DATA   END OF t_bsec.

  DATA   BEGIN OF  t_bsed OCCURS 1.
          INCLUDE STRUCTURE  bsed.
  DATA   END OF t_bsed.

  DATA   BEGIN OF  t_bseg  OCCURS 1.
          INCLUDE STRUCTURE  bseg .
  DATA   END OF t_bseg.

  DATA   BEGIN OF  t_bset OCCURS 1.
          INCLUDE STRUCTURE  bset.
  DATA   END OF t_bset.

  DATA   BEGIN OF  t_bseg_add OCCURS 1.
          INCLUDE STRUCTURE  bseg_add.
  DATA   END OF t_bseg_add.
  VALOR_TRASPASO = 0.
  LOOP AT int_tabla3 WHERE sel = 'X'.
    REFRESH:  t_bkpf,t_bseg.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *  INTO t_bkpf FROM bkpf
*    WHERE bukrs = bukrs            AND
*          belnr = int_tabla3-belnr AND
*          gjahr = int_tabla3-gjahr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS   INTO t_bkpf FROM bkpf
    WHERE bukrs = bukrs            AND
          belnr = int_tabla3-belnr AND
          gjahr = int_tabla3-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    APPEND t_bkpf.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO t_bseg   FROM bseg
*    WHERE bukrs = bukrs            AND
*          belnr = int_tabla3-belnr AND
*          gjahr = int_tabla3-gjahr AND
*          buzei = int_tabla3-buzei.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO t_bseg   FROM bseg
    WHERE bukrs = bukrs            AND
          belnr = int_tabla3-belnr AND
          gjahr = int_tabla3-gjahr AND
          buzei = int_tabla3-buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* t_bseg-xref1 = t_bseg-zuonr. "ORIGINAL 25012019
*CAMBIO 12-03-2019 HCD
VALOR_TRASPASO = VALOR_TRASPASO + 1.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
 EXPORTING
  INPUT = VALOR_TRASPASO
 IMPORTING
  OUTPUT = t_bseg-xref1.
*FIN CAMBIO 12-03-2019 HCD



    APPEND  t_bseg.
    CALL FUNCTION 'CHANGE_DOCUMENT'
      TABLES
        t_bkdf = t_bkdf
        t_bkpf = t_bkpf
        t_bsec = t_bsec
        t_bsed = t_bsed
        t_bseg = t_bseg
        t_bset = t_bset.

    IF sy-subrc = 0.
      int_tabla3-sel = ''.
      MODIFY int_tabla3 INDEX sy-tabix.
    ENDIF.
  ENDLOOP.
      MESSAGE 'Datos actualizados' type 'I'.
ENDFORM.                    "modifica_masivo4
