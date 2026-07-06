*&---------------------------------------------------------------------*
*&  Include           ZFIMOD_EMIS4_SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                              SELECT-OPTIONS
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
SELECT-OPTIONS: s_bukr FOR bkpf-bukrs OBLIGATORY, "NO-EXTENSION
                                                  "NO INTERVALS
                s_beln FOR bkpf-belnr,
                s_blar FOR bkpf-blart DEFAULT 'ZA' NO-EXTENSION
                                                   NO INTERVALS
                                                   ,
                s_cpud FOR bkpf-cpudt OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.


*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
*
  PERFORM get_label USING 'BKPF' 'S': 'BUKRS' gv_zbukr,
                                      'BELNR' gv_vblnr,
                                      'GJAHR' gv_gjahr.
  PERFORM get_label USING 'BSEG' 'M': 'BUZEI' gv_buzei.

  gv_repid = sy-repid.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*

AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
*    CHECK screen-group1 EQ 'PRO'.
    IF screen-name = 'S_BLAR-LOW' OR screen-name = 'S_BLAR-HIGH'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON s_bukr.

  SELECT FROM t001 FIELDS bukrs, butxt
    WHERE bukrs IN @s_bukr
    INTO TABLE @DATA(gt_t001).

  LOOP AT gt_t001 ASSIGNING FIELD-SYMBOL(<ls_t001>).

    AUTHORITY-CHECK OBJECT 'F_PAYR_BUK' ID 'BUKRS' FIELD <ls_t001>-bukrs
                                        ID 'ACTVT' FIELD '02'.
*   Authority check
    IF sy-subrc <> 0.
      SET CURSOR FIELD 'S_BUKR'.
*     Sin autorización para visualizar en sociedad &
      MESSAGE e515 WITH <ls_t001>-bukrs.
    ENDIF.

  ENDLOOP.

* Company code check
  IF sy-subrc <> 0.
*   La sociedad & no está prevista
    MESSAGE e165(f5) WITH s_bukr-low.
  ENDIF.
