*&---------------------------------------------------------------------*
*&  Include           ZCL_GLI0001.
*&---------------------------------------------------------------------*
*
*
*&---------------------------------------------------------------------*
*&      Form  FILL_BUDAT
*&---------------------------------------------------------------------*
FORM FILL_BUDAT USING P_MONAT P_GJAHR.

  DATA V_MONAT LIKE BKPF-MONAT.
  DATA V_GJAHR LIKE BKPF-GJAHR.

  REFRESH BR_BUDAT.
  CLEAR BR_BUDAT.

  V_MONAT = P_MONAT.
  V_GJAHR = P_GJAHR.
*  desde
  BR_BUDAT-LOW+6(02) = '01'.
  BR_BUDAT-LOW+4(02) = V_MONAT.
  BR_BUDAT-LOW+0(04) = V_GJAHR.
* hasta
  BR_BUDAT-HIGH+6(02)   = '01'.
  ADD 1 TO V_MONAT.
  IF V_MONAT > 12.
    V_MONAT = 1.
    ADD 1 TO V_GJAHR.
  ENDIF.
  BR_BUDAT-HIGH+4(02)   = V_MONAT.
  BR_BUDAT-HIGH+0(04)    = V_GJAHR.
  SUBTRACT 1 FROM BR_BUDAT-HIGH.
  BR_BUDAT-SIGN   = 'I'.
  BR_BUDAT-OPTION = 'BT'.

  APPEND BR_BUDAT.

  PERFORM FILL_GJAHR USING P_GJAHR.

ENDFORM.                               " FILL_BUDAT
*&---------------------------------------------------------------------*
*&      Form  FILL_GJAHR
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_GJAHR USING P_GJAHR.

  REFRESH BR_GJAHR.
  BR_GJAHR-LOW    = P_GJAHR.
  BR_GJAHR-HIGH   = P_GJAHR.
  BR_GJAHR-SIGN   = 'I'.
  BR_GJAHR-OPTION = 'EQ'.
  APPEND BR_GJAHR.

ENDFORM.                               " FILL_GJAHR
*&---------------------------------------------------------------------*
*&      Form  CHECK_MONAT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_MONAT USING P_MONAT P_GJAHR.

  IF P_MONAT GT 12 OR P_MONAT LT 1.
    MESSAGE E043.
  ENDIF.
* if p_gjahr = sy-datum(4) and p_monat gt sy-datum+4(2).
*   message e044.
* endif.

ENDFORM.                               " CHECK_MONAT
*&---------------------------------------------------------------------*
*&      Form  FILL_BUDAT_2
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_BUDAT_2 USING P_BUDAT.

  REFRESH BR_BUDAT.
  CLEAR BR_BUDAT.

*  desde
  BR_BUDAT-LOW  = P_BUDAT.
  BR_BUDAT-SIGN   = 'I'.
  BR_BUDAT-OPTION = 'EQ'.
  APPEND BR_BUDAT.

  PERFORM FILL_GJAHR USING P_BUDAT(4).

ENDFORM.                               " FILL_BUDAT_2
*&---------------------------------------------------------------------*
*&      Form  CHECK_BUDAT
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_BUDAT USING P_MONAT P_GJAHR P_BUDAT.

  DATA: V_BUDAT LIKE BKPF-BUDAT.

  MOVE P_BUDAT TO V_BUDAT.
* if v_budat(4) <> p_gjahr.
*   message e044 with text-ebu.
* elseif v_budat+4(2) <> p_monat.
*   message e044 with text-emo.

* endif.

ENDFORM.                               " CHECK_BUDAT
*&---------------------------------------------------------------------*
*&      Form  FILL_BUDAT_3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_MES  text                                                *
*      -->P_P_EJERCI  text                                             *
*      -->P_P_FECHA  text                                              *
*----------------------------------------------------------------------*
FORM FILL_BUDAT_3 USING    P_MONAT
                           P_GJAHR
                           P_BUDAT.

  REFRESH BR_BUDAT.
  CLEAR BR_BUDAT.
*  desde
  BR_BUDAT-LOW+6(02) = '01'.
  BR_BUDAT-LOW+4(02) = P_MONAT.
  BR_BUDAT-LOW+0(04)     = P_GJAHR.
* hasta
  BR_BUDAT-HIGH   = P_BUDAT.
  BR_BUDAT-SIGN   = 'I'.
  BR_BUDAT-OPTION = 'BT'.

  APPEND BR_BUDAT.

  PERFORM FILL_GJAHR USING P_GJAHR.

ENDFORM.                    " FILL_BUDAT_3
