*----------------------------------------------------------------------*
***INCLUDE ZFIMDP008 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_FORM_0050  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE GET_FORM_0050 INPUT.
  BKPF-BKTXT = ZINVFO-BKTXT.
  BSEG-BTYPE = ZINVFO-BTYPE.
  BSEG-DIEKZ = ZINVFO-DIEKZ.
  BSEZ-EGMLD = ZINVFO-EGMLD.
  BSEG-EGRUP = ZINVFO-EGRUP.
  BSEG-FDLEV = ZINVFO-FDLEV.
  BSEG-FDTAG = ZINVFO-FDTAG.
  BSEG-FIPOS = ZINVFO-FIPOS.
  BSEG-FISTL = ZINVFO-FISTL.
  BSEG-GEBER = ZINVFO-GEBER.
  BSEG-FKBER_LONG = ZINVFO-FKBER_LONG.                       "Note 488469
  BSEG-GRANT_NBR  = ZINVFO-GRANT_NBR.                        "Note 488469
  BSEG-KBLNR = ZINVFO-KBLNR.                                 "note 607502
  BSEG-KBLPOS = ZINVFO-KBLPOS.                               "note 607502
  BSEZ-ERLKZ = ZINVFO-ERLKZ.                                 "note 607502
  BSEG-GSBER = ZINVFO-GSBER.
  BSEG-PARGB = ZINVFO-PARGB.
  BSEG-HKONT = ZINVFO-HKONT.
  BSEG-IDXSP = ZINVFO-IDXSP.
  BSEG-LANDL = ZINVFO-LANDL.
  BSEG-LZBKZ = ZINVFO-LZBKZ.
  BSEG-MABER = ZINVFO-MABER.
  BSEG-MSCHL = ZINVFO-MSCHL.
  BSEG-MANSP = ZINVFO-MANSP.
  BSEG-MADAT = ZINVFO-MADAT.
  BSEG-MANST = ZINVFO-MANST.
  BSEG-STCEG = ZINVFO-STCEG.
  BSEG-VRSDT = ZINVFO-VRSDT.
  BSEG-VRSKZ = ZINVFO-VRSKZ.
  BSEG-VNAME = ZINVFO-VNAME.
  BSEG-XEGDR = ZINVFO-XEGDR.
  IF ZINVFO-XEGDR_HU CO 'BC'.                               "Note1009677
    MOVE ZINVFO-XEGDR_HU TO BSEG-XEGDR.                     "Note1009677
  ENDIF.                                                   "Note1009677
  BSEG-XNEGP = ZINVFO-XNEGP.
  BSEG-XREF1 = ZINVFO-XREF1.
  BSEG-XREF2 = ZINVFO-XREF2.
  BSEG-XREF3 = ZINVFO-XREF3.
  BSEG-ZINKZ = ZINVFO-ZINKZ.
  BSEG-ZUONR = ZINVFO-ZUONR.
  BSEG-VERTN = ZINVFO-VERTN.
  BSEG-VERTT = ZINVFO-VERTT.
  BSEG-VBEWA = ZINVFO-VBEWA.
  BSEG-CESSION_KZ = ZINVFO-CESSION_KZ.                      "Note539224
  IF KOART = 'D'.
    BSEG-KKBER = ZINVFO-KKBER.
  ENDIF.
  IF KOART = 'K'.                                           "Note631469
    BSEG-PENRC = ZINVFO-PENRC.
  ENDIF.
  IF SY-DYNGR = 'DTMM'.
    MOVE-CORRESPONDING ZINVFO TO BKPF.
  ENDIF.
  IF ZINVFO-ZUONR EQ SPACE.
    ZINVFO-ZUONR = ZINVFO-XBLNR.
  ENDIF.

  IF ZINVFO-BKTXT EQ SPACE.
  SET CURSOR FIELD 'ZINVFO-BKTXT'.
        MESSAGE E012(Z1).
  ENDIF.


  GET CURSOR FIELD CURSOR.
  CLEAR G_EXIT_COMMAND.
ENDMODULE.                 " GET_FORM_0050  INPUT
*&---------------------------------------------------------------------*
*&      Module  TEXT_MANDATORY_FROM_DOC_TYPE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TEXT_MANDATORY_FROM_DOC_TYPE INPUT.
  IF SY-UCOMM NE 'BACK'
   AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.

    CHECK G_AKTYP NE 'A'.
    CHECK NO_CHECKS IS INITIAL.                              "Note 203892
    CASE SY-DYNGR.
      WHEN 'MAIN'.
        PERFORM MANADATORY_FIELDS                            "Note 337276
          USING T003-XMTXT SPACE 'X' SPACE.                  "Note 337276
      WHEN 'MORE'.
        PERFORM MANADATORY_FIELDS                            "Note 337276
          USING T003-XMTXT SPACE SPACE 'X'.                  "Note 337276
      WHEN OTHERS.                                           "Note 337276
        PERFORM MANADATORY_FIELDS                            "Note 337276
          USING T003-XMTXT SPACE 'X' 'X'.                    "Note 337276
    ENDCASE.
  ENDIF.
ENDMODULE.                 " TEXT_MANDATORY_FROM_DOC_TYPE  INPUT
*&---------------------------------------------------------------------*
*&      Module  HLP_HKONT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE HLP_HKONT INPUT.
  DATA: HKONT    LIKE BSEG-HKONT,
         HSKAT    LIKE SKAT,
         GREY(1)  TYPE C,
         XORIG(1) TYPE C.

*-------- Can rec. account be entered ? --------------------------------
  LOOP AT SCREEN.
    CHECK SCREEN-NAME = 'ZINVFO-HKONT'.
    IF SCREEN-INPUT = 0.
      GREY = 'X'.
    ENDIF.
    EXIT.
  ENDLOOP.

*------- Get all valid accounts from THKON -----------------------------
  CALL FUNCTION 'LINEITEM_THKON_READ'
    EXPORTING
      I_KTOPL = T001-KTOPL
      I_SAKNR = BSEG-SAKNR
    TABLES
      T_THKON = HKOTAB.

*------- Fill table for F4-Function  Module ----------------------------
  REFRESH FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'THKON'.
  FLDTAB-FIELDNAME  = 'ABWHK'.
  FLDTAB-SELECTFLAG = 'X'.
  APPEND FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'THKON'.
  FLDTAB-FIELDNAME  = 'KRZKY'.
  APPEND FLDTAB.
  CLEAR FLDTAB.
  FLDTAB-TABNAME    = 'SKAT'.
  FLDTAB-FIELDNAME  = 'TXT50'.
  APPEND FLDTAB.

*------- Fill Communication structure to call FModule ------------------
  REFRESH VALTAB.
  XORIG = SPACE.
  LOOP AT HKOTAB.
    VALTAB-FELD = HKOTAB-ABWHK.
    APPEND VALTAB.
    VALTAB-FELD = HKOTAB-KRZKY.
    APPEND VALTAB.
    CLEAR HSKAT.
    CALL FUNCTION 'READ_HAUPTBUCH_TEXT'
      EXPORTING
        KONTENPLAN = T001-KTOPL
        SACHKONTO  = HKOTAB-ABWHK
        SPRACHE    = SY-LANGU
      IMPORTING
        TEXT_WA    = HSKAT
      EXCEPTIONS
        OTHERS     = 0.
    VALTAB-FELD = HSKAT-TXT50.
    APPEND VALTAB.
    IF HKOTAB-ABWHK = BSEG-SAKNR.
      XORIG = 'X'.
    ENDIF.
  ENDLOOP.

*------- Original Reconciliation Account -------------------------------
  IF XORIG = SPACE.
    VALTAB-FELD = BSEG-SAKNR.
    APPEND VALTAB.
    VALTAB-FELD = SPACE.
    APPEND VALTAB.
    CLEAR HSKAT.
    CALL FUNCTION 'READ_HAUPTBUCH_TEXT'
      EXPORTING
        KONTENPLAN = T001-KTOPL
        SACHKONTO  = BSEG-SAKNR
        SPRACHE    = SY-LANGU
      IMPORTING
        TEXT_WA    = HSKAT
      EXCEPTIONS
        OTHERS     = 0.
    VALTAB-FELD = HSKAT-TXT50.
    APPEND VALTAB.
  ENDIF.

*------- Show possible entries -----------------------------------------
  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
    EXPORTING
      DISPLAY      = SPACE
      FIELDNAME    = 'HKONT'
      TABNAME      = 'BSEG'
    IMPORTING
      SELECT_VALUE = HKONT
    TABLES
      FIELDS       = FLDTAB
      VALUETAB     = VALTAB.
  IF NOT HKONT IS INITIAL AND GREY IS INITIAL.
    ZINVFO-HKONT = HKONT.
  ENDIF.
ENDMODULE.                 " HLP_HKONT  INPUT
