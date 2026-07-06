*&---------------------------------------------------------------------*
*& Report  ZUPDATEMASIVO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZUPDATEMASIVO.
TABLES: febko, febep, febre.
data: W_HBKID TYPE HBKID VALUE 'SEC01',
      W_HKTID TYPE HKTID VALUE '00312',
      W_ANWND TYPE ANWND_EBKO VALUE '0001',
      W_ABSND TYPE ABSND_EB VALUE '037            000001128663                  CLP',
      IT_FEBEP TYPE STANDARD TABLE OF FEBEP,
      WA_FEBEP TYPE FEBEP,
      IT_FEBRE TYPE STANDARD TABLE OF FEBRE,
      T_FEBRE TYPE STANDARD TABLE OF FEBRE,
      WA_FEBRE TYPE FEBRE,
      w_lines type i.

PARAMETERS: P_KUKEY LIKE FEBEP-KUKEY,
            P_ESNUM LIKE FEBEP-ESNUM,
            P_STATUS TYPE STATUSFLAG1,
            P_BELNR LIKE FEBEP-BELNR,
            P_GJAHR LIKE FEBEP-GJAHR,
            P_BVDAT LIKE FEBEP-BVDAT,
            P_BUDAT LIKE FEBEP-BUDAT.

AT SELECTION-SCREEN.

IF P_STATUS = 'X'.
  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE IT_FEBEP
      FROM FEBEP
      WHERE KUKEY = P_KUKEY
            AND ESNUM = P_ESNUM
      .
    LOOP AT IT_FEBEP INTO WA_FEBEP.
      WA_FEBEP-EPERL = 'X'.
      WA_FEBEP-VB1OK = 'X'.
      WA_FEBEP-VB2OK = 'X'.
      WA_FEBEP-PIPRE = 'X'.
      WA_FEBEP-BELNR = P_BELNR.
      WA_FEBEP-GJAHR = P_GJAHR.
      WA_FEBEP-BVDAT = P_BVDAT.
      WA_FEBEP-BUDAT = P_BUDAT.
      WA_FEBEP-B1ERR = SPACE.
      WA_FEBEP-INFO1 = 'Cheque marcado "cobrado"'.
      WA_FEBEP-INFO2 = SPACE.
      modify it_febep from wa_febep.
      CLEAR wa_febep.
    ENDLOOP.

    BREAK-POINT.
    UPDATE febep from TABLE it_febep.
ENDIF.
