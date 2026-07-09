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

MODULE status_0800 OUTPUT.
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


ENDMODULE.                             " STATUS_0100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0800 INPUT.

  CASE sy-ucomm.

    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'RW'.
      LEAVE TO SCREEN 0.
    WHEN 'MOD'.
      IF NOT *bseg-zfbdt IS INITIAL OR
         NOT *bseg-zterm IS INITIAL OR
         NOT *bseg-zbd1t IS INITIAL OR
         bloqueo ='S'              OR
         NOT *bseg-zlsch IS INITIAL OR
         NOT *bseg-hbkid IS INITIAL OR
         NOT *bseg-hktid IS INITIAL OR
         NOT *bseg-zuonr IS INITIAL.
        PERFORM modifica_masivo.
      ELSE.
        MESSAGE e004(zfi) WITH 'Debe ingresar a lo menos un dato a modificar'.
      ENDIF.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  modifica_masivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM modifica_masivo.

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

    IF NOT *bseg-zfbdt IS INITIAL.
      t_bseg-zfbdt = *bseg-zfbdt.
    ENDIF.
    IF NOT  *bseg-zterm IS INITIAL.
      t_bseg-zterm = *bseg-zterm.
    ENDIF.
    IF NOT  *bseg-zbd1t IS INITIAL.
      t_bseg-zbd1t = *bseg-zbd1t.
    ENDIF.
    IF  bloqueo = 'S'.
      t_bseg-zlspr = *bseg-zlspr.
    ENDIF.
    IF NOT  *bseg-zlsch IS INITIAL.
      t_bseg-zlsch = *bseg-zlsch.
    ENDIF.

    IF NOT  *bseg-hbkid IS INITIAL.
      t_bseg-hbkid = *bseg-hbkid.
      IF  *bseg-hktid IS INITIAL.
        MESSAGE e004(zfi) WITH 'Si modica id de banco ' 'debe ingresar Clave banco cuenta'.
      ENDIF.

    ENDIF.


    IF NOT  *bseg-hktid IS INITIAL.
      t_bseg-hktid = *bseg-hktid.
      IF  *bseg-hbkid IS INITIAL.
          MESSAGE e004(zfi) WITH 'Si modica Clave banco cuenta ' 'debe ingresar id de banco'.
      ENDIF.
    ENDIF.


    IF NOT *bseg-zuonr IS INITIAL.
      t_bseg-zuonr = *bseg-zuonr.
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
MODULE bseg-zlspr INPUT.
  bloqueo = 'S'.
ENDMODULE.                 " BSEG-ZLSPR  INPUT
