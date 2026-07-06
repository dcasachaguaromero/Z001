*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LF064F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ZEILEN_BEARBEITUNG
*&---------------------------------------------------------------------*
FORM ZEILEN_BEARBEITUNG USING INDEX TYPE I ACTP TYPE C
                        CHANGING REFRESH TYPE C.
  DATA: L_AKTYP LIKE T020-AKTYP.                           "Note 339626
  DATA: P_ITEM  TYPE BUZEI VALUE '000'.                    "Note 402273
  DATA: CALLED_BY_ALV VALUE 'X'.                           "Note 1055386

  CLEAR COMREQ.
  CLEAR REFRESH.
  CLEAR BUZTAB.
  REFRESH BUZTAB.
*------------- Aufbau BUZTAB -------------------------------------------
  LOOP AT XBSEG.
    MOVE-CORRESPONDING XBSEG TO BUZTAB.
    CLEAR BUZTAB-FLAEN.
    APPEND BUZTAB.
  ENDLOOP.
  BUZTAB-ZEILE = INDEX.
  IF ACTP = 'V'.
    TCODE = 'FB02'.
  ELSE.
    TCODE = 'FB03'.
  ENDIF.
  IF T020-FUNCL = C_U.                                      "ALRK240194
    TCODE+2(1) = C_U.                                       "ALRK240194
  ENDIF.                                                    "ALRK240194
  IF XBKPF-BSTAT = C_D.
    TCODE+2(1) = C_D.
  ENDIF.
  IF XBKPF-BSTAT = C_M.
    TCODE+2(1) = C_M.
  ENDIF.
* IF XBKPF-BSTAT = C_bel_vorerf.
*   TCODE+2(1) = C_bel_vorerf.
* ENDIF.

* If a new line item is requested in the dialog called,     "ALRK232386
* control will return to the caller, and the dialog has to  "ALRK232386
* be called with the new line.                              "ALRK232386
  DO.                                                       "ALRK232386
*--------------- Benutzeroption jetzt auf Zeilenanzeige schalten -------
    GET PARAMETER ID 'FOP' FIELD RFOPT.
    XSPIU = RFOPT-XSPIU.               "Stand merken
    CLEAR RFOPT-XSPIU.
    SET PARAMETER ID 'FOP' FIELD RFOPT.

    EXPORT CALLED_BY_ALV TO MEMORY ID 'CALLEDBYALV'.        "Note1055386

    CALL DIALOG 'RF_ZEILEN_ANZEIGE'
      EXPORTING
        BUZTAB
        BUZTAB-ZEILE
        TCODE         FROM TCODE
        STATUS-DETAIL FROM C_X                              "ALRK222406
        X_EPAB        FROM EPOS                             "ALRK232386
        X_NOCHANGE                                   "Note 302995
        AKTYP         FROM L_AKTYP                   "Note 339626
      IMPORTING
        BUZTAB
        BUZTABI-INDEX TO BUZTAB-ZEILE                       "ALRK232386
        X_NEXTL                                             "ALRK232386
        NEW_DOC                                             "ALRK232386
        TCODE         TO TCODE                              "ALRK241034
        T020-AKTYP    TO L_AKTYP                     "Note 339626
        X_COMMIT.
*------------------ Benutzeroptionen zurückstellen ---------------------
    RFOPT-XSPIU = XSPIU.
    SET PARAMETER ID 'FOP' FIELD RFOPT.
* Reset line item number for object services                "Note 402273
    EXPORT P_ITEM TO MEMORY ID 'FI_GOS_ITEM'.               "Note 402273

    IF X_COMMIT = C_X.
      XCHNG = C_X.
      IF EPOS = C_X.

*-------------- Bei Änderungen zurück nach FBL* ------------------------
        COMREQ = C_X.
        LEAVE.
      ELSE.

*------------- ...AND WAIT, damit das Ergebnis gleich sichtbar ist -----
        MESSAGE S300.
        COMMIT WORK AND WAIT.
      ENDIF.
      REFRESH = C_X.
      READ TABLE BUZTAB INDEX 1.
      IF STATUS EQ C_STAT_LIST.
        PERFORM BELEG_LESEN USING BUZTAB-BELNR BUZTAB-BUKRS
                                  BUZTAB-GJAHR.
      ELSE.
        PERFORM READ_CROSS_COMPANY_DOCUMENTS USING BVORG.
      ENDIF.
    ENDIF.
*------------- Go to next document, if requested    ------- "ALRK232386
    IF NOT NEW_DOC-BELNR IS INITIAL.                        "ALRK232386
      GET PARAMETER ID 'REF' FIELD XXREF.                   "ALRK241034
      IF XXREF IS INITIAL.                                  "ALRK241034
        SET PARAMETER ID 'BUK' FIELD NEW_DOC-BUKRS.         "ALRK232386
        SET PARAMETER ID 'BLN' FIELD NEW_DOC-BELNR.         "ALRK232386
        SET PARAMETER ID 'GJR' FIELD NEW_DOC-GJAHR.         "ALRK232386
        LEAVE TO TRANSACTION TCODE AND SKIP FIRST SCREEN.   "ALRK232386
      ELSE.                                                 "ALRK241034
        LEAVE TO TRANSACTION TCODE.                         "ALRK241034
      ENDIF.                                                "ALRK241034
    ELSEIF NOT NEW_DOC-BVORG IS INITIAL.                    "ALRK232386
      SET PARAMETER ID 'VRG' FIELD NEW_DOC-BVORG.           "ALRK232386
      LEAVE TO TRANSACTION TCODE AND SKIP FIRST SCREEN.     "ALRK232386
*------------- Exit loop, if no new item requested. ------- "ALRK232386
    ELSEIF X_NEXTL NE C_X.                                  "ALRK232386
      EXIT.                                                 "ALRK232386
    ENDIF.                                                  "ALRK232386
  ENDDO.                                                    "ALRK232386
ENDFORM.                               " ZEILEN_BEARBEITUNG
*&---------------------------------------------------------------------*
*&      Form  BELEG_LESEN
*&---------------------------------------------------------------------*
*       Lesen oder Nachlesen des Beleges
*----------------------------------------------------------------------*
FORM BELEG_LESEN USING
             VALUE(P_BELNR) TYPE BELNR_D
             VALUE(P_BUKRS) TYPE BUKRS
             VALUE(P_GJAHR) TYPE GJAHR.

  DATA: L_ARCHIVED.                                         "ALRK238277
  DATA: L_GROUP_XREADALL LIKE FARC_XREAD                    "ALRK241034
        VALUE 'XXXXXXXXXXXXXXXXXXXXXX'.                     "ALRK241034
*  DATA: l_archbkpf TYPE  abkpf OCCURS 0 WITH HEADER LINE.   "ALRK238277
  DATA: L_ARCHBKPF TYPE  BKPF OCCURS 0 WITH HEADER LINE,    "ERP04
        LT_BSEG TYPE FAGL_T_BSEG,                           "ERP05
        LS_BSEG TYPE BSEG.
  REFRESH ARCHBSEG.                                         "ALRK238277
  CALL FUNCTION 'READ_DOCUMENT_HEADER'
    EXPORTING
      BELNR          = P_BELNR
      BUKRS          = P_BUKRS
      GJAHR          = P_GJAHR
      XBSTV          = 'X'
      XBSTD          = 'X'
      XBSTM          = 'X'
    IMPORTING
      E_BKPF         = BKPF
      E_ARCHIVED     = L_ARCHIVED                           "ALRK238277
    TABLES                                              "Note 319123
      T_ACCDN        = TACCDN                        "Note 319123
    EXCEPTIONS
      EXIT           = 4
      NOT_FOUND      = 8
      ARCHIVE_CANCEL = 12
      OTHERS         = 16.

*------- Beleg gefunden, nicht gefunden, archiviert? ------------------*
  CASE SY-SUBRC.
    WHEN 0.
      SET PARAMETER ID 'GJR' FIELD BKPF-GJAHR.
      RF05L-GJAHR = BKPF-GJAHR.                   "        " Note 486975
    WHEN 4.
      MESSAGE E429 WITH P_BELNR P_BUKRS RAISING DISPLAY_NOT_POSSIBLE.
    WHEN 8.
      IF G_UCOMM = 'NB'.
        G_EXIT = C_X.
        MESSAGE E429 WITH P_BELNR P_BUKRS.
      ELSE.
        MESSAGE E429 WITH P_BELNR P_BUKRS RAISING DISPLAY_NOT_POSSIBLE.
      ENDIF.
    WHEN 12.
      MESSAGE E881 WITH P_BELNR P_BUKRS RAISING DISPLAY_NOT_POSSIBLE.
    WHEN OTHERS.
      MESSAGE A370 WITH 'READ_DOCUMENT_HEADER'
                   RAISING DISPLAY_NOT_POSSIBLE.
  ENDCASE.
  IF BKPF-BSTAT = C_BEL_VORERF.
    CALL FUNCTION 'PRELIMINARY_POSTING_DOC_READ'
      EXPORTING
        BELNR                   = BKPF-BELNR
        BUKRS                   = BKPF-BUKRS
        GJAHR                   = BKPF-GJAHR
      TABLES
        T_VBKPF                 = XVBKPF
        T_VBSEC                 = XVBSEC
        T_VBSEG                 = XVBSEG
        T_VBSET                 = XVBSET
      EXCEPTIONS
        DOCUMENT_LINE_NOT_FOUND = 1
        DOCUMENT_NOT_FOUND      = 2
        OTHERS                  = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
              RAISING DISPLAY_NOT_POSSIBLE.
    ENDIF.
  ENDIF.
  CLEAR:   XBKPF.
  REFRESH: XBKPF.
  CLEAR:   XBSEG.
  REFRESH: XBSEG.
  REFRESH: GT_MISSING_AUTH.
  MOVE-CORRESPONDING BKPF TO XBKPF.
  APPEND XBKPF.
  RCODE = 0.
  IF BKPF-BSTAT = 'V'.
    LOOP AT XVBSEG.
      MOVE-CORRESPONDING XVBSEG TO XBSEG.
* Fields with different names in BSEG and VBSEG            "Note 308450
      XBSEG-ETEN2 = XVBSEG-KDEIN.      "Schedule line       Note 308450
      XBSEG-VBEL2 = XVBSEG-KDAUF.      "Sales document      Note 308450
      XBSEG-POSN2 = XVBSEG-KDPOS.      "Sales document item Note 308450
      XBSEG-BEWAR = XVBSEG-RMVCT.      "Transaction type    Note 308450
      XBSEG-PROJK = XVBSEG-PS_PSP_PNR. "Structure element   Note 308450
      XBSEG-PPRCT = XVBSEG-PPRCTR.     "Partner profit ctr  Note 308450
* (del) perform berechtigungen changing rcode.              "Note449741
      PERFORM BERECHTIGUNGEN                                "Note449741
              USING BKPF-BSTAT                              "Note449741
                    G_AKTYP                                 "Note449741
              CHANGING RCODE.                               "Note449741
      IF RCODE = 0.
        IF XBSEG-SHKZG = C_DEBIT.
          PERFORM CHANGE_SIGN.
        ENDIF.
        APPEND XBSEG.
      ELSE.                            " missing authority !
        MOVE-CORRESPONDING XBSEG TO GT_MISSING_AUTH.
        GT_MISSING_AUTH-DASH = C_DASH.
        GT_MISSING_AUTH-SEMICOLON = C_SEMICOLON.
        APPEND GT_MISSING_AUTH.
        RCODE = 0.
      ENDIF.
    ENDLOOP.
  ELSE.
    IF L_ARCHIVED IS INITIAL.                               "ALRK238277
* replace select by function call - support bstat = L  possible for
* documents posted during migration of new gl
*      SELECT        * FROM  bseg
*             WHERE  bukrs       = bkpf-bukrs
*             AND    belnr       = bkpf-belnr
*             AND    gjahr       = bkpf-gjahr     .
*        MOVE-CORRESPONDING bseg TO xbseg.
*        APPEND xbseg.                                       "ALRK238277
*      ENDSELECT.                                            "ALRK238277
      IF BKPF-BSTAT CN 'ABZ'.                                "ERP05/Note 940331
        CALL FUNCTION 'FAGL_GET_BSEG'
          EXPORTING
            I_BUKRS   = BKPF-BUKRS
            I_BELNR   = BKPF-BELNR
            I_GJAHR   = BKPF-GJAHR
            I_BSTAT   = BKPF-BSTAT       " bstat = 'L'/space
          IMPORTING
            ET_BSEG   = LT_BSEG
          EXCEPTIONS
            NOT_FOUND = 1
            OTHERS    = 2.
        IF SY-SUBRC <> 0.
          MESSAGE E397(F5A) WITH BKPF-BELNR BKPF-BUKRS BKPF-GJAHR.
        ELSE.
          LOOP AT LT_BSEG INTO LS_BSEG.
            MOVE-CORRESPONDING LS_BSEG TO XBSEG.
            APPEND XBSEG.
          ENDLOOP.
        ENDIF.
      ENDIF.                                                "ERP05
    ELSE.                                                   "ALRK238277
* ----------ERP04 SP04 replace old archive access ---------------------
*      CALL FUNCTION 'FI_DOCUMENT_READ_SINGLE'               "ALRK238277
*            EXPORTING                                       "ALRK238277
*                 i_bukrs            = bkpf-bukrs            "ALRK238277
*                 i_belnr            = bkpf-belnr            "ALRK238277
*                 i_gjahr            = bkpf-gjahr            "ALRK238277
*                 i_group_xread      = l_group_xreadall      "ALRK241034
*                 i_xuse_database    = space                 "ALRK238277
*                 i_xsuppressdialog  = c_x                   "ALRK238277
*            TABLES                                          "ALRK238277
*                 c_bseg             = archbseg              "ALRK238277
*                 c_bset             = archbset             "Note 490520
*                 c_abkpf            = l_archbkpf            "ALRK238277
*            EXCEPTIONS                                      "ALRK238277
*                OTHERS             = 99.                    "ALRK238277
*      IF sy-subrc NE 0.                                    "Note 323188
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno  "Note 323188
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.  "Note 323188
*      ENDIF.                                               "Note 323188
      CALL FUNCTION 'FAGL_GET_ARCH_FI_DOCUMENT'             "ERP04
        EXPORTING
          I_BUKRS            = BKPF-BUKRS
          I_BELNR            = BKPF-BELNR
          I_GJAHR            = BKPF-GJAHR
        TABLES
          T_BKPF             = L_ARCHBKPF
          T_BSEG             = ARCHBSEG
          T_BSET             = ARCHBSET
        EXCEPTIONS
          ERROR_MESSAGE      = 01
          DOCUMENT_NOT_FOUND = 02.
      IF SY-SUBRC <> 0.
        MESSAGE S397(F5A) WITH BKPF-BELNR BKPF-BUKRS BKPF-GJAHR.
      ELSE.
        MESSAGE S068(F4) WITH BKPF-BUKRS BKPF-BELNR BKPF-GJAHR.
      ENDIF.
      LOOP AT ARCHBSEG.                                     "ALRK238277
        MOVE-CORRESPONDING ARCHBSEG TO XBSEG.               "ALRK238277
        APPEND XBSEG.                                       "ALRK238277
      ENDLOOP.                                              "ALRK238277
      LOOP AT ARCHBSET.                                    "Note 490520
        MOVE-CORRESPONDING ARCHBSET TO XBSET.              "Note 490520
        APPEND XBSET.                                      "Note 490520
      ENDLOOP.                                             "Note 490520
    ENDIF.                                                  "ALRK238277
    LOOP AT XBSEG.                                          "ALRK238277
* (del) perform berechtigungen changing rcode.              "Note449741
      PERFORM BERECHTIGUNGEN                                "Note449741
              USING BKPF-BSTAT                              "Note449741
                    G_AKTYP                                 "Note449741
              CHANGING RCODE.                               "Note449741
      IF RCODE = 0.
        IF XBSEG-SHKZG = 'H'.
          PERFORM CHANGE_SIGN.
          MODIFY XBSEG.                                     "ALRK238277
        ENDIF.
* (del) append xbseg.                                       "ALRK238277
      ELSE.                            " missing authority !
        MOVE-CORRESPONDING XBSEG TO GT_MISSING_AUTH.
        GT_MISSING_AUTH-DASH = C_DASH.
        GT_MISSING_AUTH-SEMICOLON = C_SEMICOLON.
        APPEND GT_MISSING_AUTH.
        DELETE XBSEG.                                       "ALRK238277
        RCODE = 0.
      ENDIF.
    ENDLOOP.                                                "ALRK238277
* (del) endselect.                                          "ALRK238277
  ENDIF.

  LOOP AT XBSEG.
    PERFORM FILL_KTEXT_KONTO_FAEDT.
    MODIFY XBSEG.
  ENDLOOP.

  LOOP AT XBSEG.                                            "Note1139298
    IF XBSEG-AUGBL = XBKPF-BELNR                            "Note1139298
    AND XBSEG-AUGDT = XBKPF-BUDAT.                          "Note1139298
      XZLBLG = 'X'.                                         "Note1139298
    ENDIF.                                                  "Note1139298
  ENDLOOP.                                                  "Note1139298

*--- Färbungen (nach Bedarf ??): ALV will Feld in Übergabetabelle ------
* PERFORM ZEILENFARBE USING 'C30' '*'.
* PERFORM BETRAGSFARBE.
ENDFORM.                               " BELEG_LESEN
*&---------------------------------------------------------------------*
*&      Form  UEBERGABE_STRUKTUREN
*&---------------------------------------------------------------------*
FORM UEBERGABE_STRUKTUREN.

* Read variant only if not already determined
  CHECK VARIANT_FIX IS INITIAL.

*------------- Vorbereitungen für ALV ----------------------------------
*------------------ Anzeigevarianten -----------------------------------
  VARIANT-REPORT         = 'SAPLF064'.
  VARIANT-USERNAME       = SY-UNAME.

*-------------- Verschiedene Keys für die Aufrufe ----------------------
  VARIANT-HANDLE = 'BSEG'.
  CLEAR VARIANT-VARIANT.                                    "Note 443989

*----------------- Einstiegsvariante ermitteln -------------------------
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      I_SAVE        = 'A'
    CHANGING
      CS_VARIANT    = VARIANT
    EXCEPTIONS
      WRONG_INPUT   = 1
      NOT_FOUND     = 2
      PROGRAM_ERROR = 3
      OTHERS        = 4.
  IF SY-SUBRC NE 0.
    VARIANT-VARIANT = '0SAP'.          "Diese Variante ist ausgeliefert
  ENDIF.

*------------------- Layout --------------------------------------------
  CLEAR LAYOUT.                                             "Note 443989
  LAYOUT-ZEBRA           = 'X'.
  CLEAR LAYOUT-NO_MIN_LINESIZE.
  LAYOUT-MIN_LINESIZE    = '100'.
  LAYOUT-F2CODE          = 'DETA'.
  LAYOUT-KEY_HOTSPOT     = C_X.
  LAYOUT-INFO_FIELDNAME  = 'COLOR'.
  LAYOUT-COLTAB_FIELDNAME = 'COLFW'.

*------------------ Kopfanzeige und Fußzeile via Eventsteuerung --------
  REFRESH EVENTS.
  CLEAR EVENTS_WA.
  EVENTS_WA-NAME = 'TOP_OF_PAGE'.
  EVENTS_WA-FORM = 'KOPF_ANZEIGE'.
  APPEND EVENTS_WA TO EVENTS.
* events_wa-name = 'END_OF_LIST'.
* events_wa-form = 'BELEGSALDO'.
* append events_wa to events.

*------------------ Regards item display in FB05 --------- "Note 302995
* (del) if t020-aktyp = 'H'.                               "Note 302995
* (del)  if t020-aktyp = c_h and t020-aktyp n  "Note 302995 Note 373337
  IF T020-AKTYP = C_H.                                     "Note 373337

*-------- F2 was pressed: both ALV and caller may do something ---------
    IT_EVENT_EXIT_WA-UCOMM  = '&IC1'.
    IT_EVENT_EXIT_WA-BEFORE = 'X'.
    APPEND IT_EVENT_EXIT_WA TO IT_EVENT_EXIT.
  ELSE.

*--------- Display mode: F3 => variant has to be held ------------------
    IT_EVENT_EXIT_WA-UCOMM  = '&F03'.
    IT_EVENT_EXIT_WA-BEFORE = 'X'.
    APPEND IT_EVENT_EXIT_WA TO IT_EVENT_EXIT.
  ENDIF.
ENDFORM.                               " UEBERGABE_STRUKTUREN
*&---------------------------------------------------------------------*
*&      Form  FELDKATALOG
*&---------------------------------------------------------------------*
*       Bearbeiten Feldkatalog
*----------------------------------------------------------------------*
FORM FELDKATALOG_BSEG.

  DATA: BEGIN OF LT_X031L OCCURS 40.
          INCLUDE STRUCTURE X031L.
  DATA: END OF LT_X031L.

  REFRESH: FIELDCAT, FIELDCAT_T.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
       EXPORTING
            I_PROGRAM_NAME         = 'SAPLF064'
            I_INTERNAL_TABNAME     = 'XBSEG'
            I_STRUCTURE_NAME       = 'BSEG'
            I_BUFFER_ACTIVE        = 'X'
*           I_CLIENT_NEVER_DISPLAY = 'X'
*           I_INCLNAME             =
       CHANGING
            CT_FIELDCAT            = FIELDCAT_T
       EXCEPTIONS
            INCONSISTENT_INTERFACE = 1
            PROGRAM_ERROR          = 2
            OTHERS                 = 3.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  APPEND LINES OF FIELDCAT_T TO FIELDCAT.
  IF STATUS = 'H'.
    REFRESH FIELDCAT_T.
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        I_PROGRAM_NAME         = 'SAPLF064'
        I_INTERNAL_TABNAME     = 'XBKPF'
        I_STRUCTURE_NAME       = 'BKPF'
        I_BUFFER_ACTIVE        = 'X'
      CHANGING
        CT_FIELDCAT            = FIELDCAT_T
      EXCEPTIONS
        INCONSISTENT_INTERFACE = 1
        PROGRAM_ERROR          = 2
        OTHERS                 = 3.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
    APPEND LINES OF FIELDCAT_T TO FIELDCAT.
  ENDIF.

*---------- Show company code in simulation mode -----------------------
* Field catalog should always have the same number of      "Note 373337
* entries, if buffering is active                          "Note 373337
* (del) if t020-aktyp ne 'H'.                              "Note 373337
* (del)   delete fieldcat where fieldname = 'BUKRS' and ta "Note 373337
* (del) else.                                              "Note 373337

*------------- ... but not as a key field, so that it can be hidden ----
  FIELDCAT_WA-KEY = SPACE.
  MODIFY FIELDCAT FROM FIELDCAT_WA  TRANSPORTING KEY
                  WHERE FIELDNAME = 'BUKRS'
                  AND   TABNAME   = 'XBSEG'.
* (del) endif.                                             "Note 373337

  DELETE FIELDCAT WHERE ( FIELDNAME = 'BELNR' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'GJAHR' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'XAUTO' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'HWMET' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'DOKID' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'IBLAR' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'XHRES' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'XFAKT' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'XUMAN' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'XANET' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'XNCOP' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'STEKZ' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'TXGRP' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'GLUPM' AND TABNAME = 'XBSEG' )
                  OR    ( FIELDNAME = 'PROJK' AND TABNAME = 'XBSEG' ).

  CLEAR FIELDCAT_WA.
  IF STATUS = C_STAT_HIERSEQ.
    FIELDCAT_WA-FIELDNAME = 'EXPAND'.
    FIELDCAT_WA-TABNAME   = 'XBKPF'.
    APPEND FIELDCAT_WA TO FIELDCAT.
  ENDIF.

  FIELDCAT_WA-FIELDNAME = 'KTEXT'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'KTEXT'.
  FIELDCAT_WA-REF_TABNAME = 'RFPSD'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'KTEXT_GL'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'KTEXT_GL'.
  FIELDCAT_WA-REF_TABNAME = 'RFPSD'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'GL_LTXT'.                        "Note 446719
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'TXT50'.
  FIELDCAT_WA-REF_TABNAME = 'SKAT'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'ASSET_TXT'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'TXT50'.
  FIELDCAT_WA-REF_TABNAME = 'ANLA'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'KONTO'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'KONTO'.
  FIELDCAT_WA-REF_TABNAME = 'RFPSD'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'FAEDT'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'FAEDT'.
  FIELDCAT_WA-REF_TABNAME = 'RFPSD'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'SAKAN'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'SAKAN'.
  FIELDCAT_WA-REF_TABNAME = 'SKA1'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'WAERS'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'WAERS'.
  FIELDCAT_WA-REF_TABNAME = 'BKPF'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'HWAER'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'HWAER'.
  FIELDCAT_WA-REF_TABNAME = 'BKPF'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'HWAE2'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'HWAE2'.
  FIELDCAT_WA-REF_TABNAME = 'BKPF'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'HWAE3'.
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'HWAE3'.
  FIELDCAT_WA-REF_TABNAME = 'BKPF'.
  APPEND FIELDCAT_WA TO FIELDCAT.

  FIELDCAT_WA-FIELDNAME = 'PROJK_EXT'.                      "Note 575107
  FIELDCAT_WA-TABNAME   = 'XBSEG'.
  FIELDCAT_WA-REF_FIELDNAME = 'PROJK'.
  FIELDCAT_WA-REF_TABNAME = 'RFPOS'.
  APPEND FIELDCAT_WA TO FIELDCAT.

* include correct currency type reference fields for currency fields:
  CALL FUNCTION 'DDIF_NAMETAB_GET'
    EXPORTING
      TABNAME   = 'BSEG'
    TABLES
      X031L_TAB = LT_X031L
    EXCEPTIONS
      NOT_FOUND = 1
      OTHERS    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  LOOP AT LT_X031L WHERE DTYP = 'CURR'.
    READ TABLE FIELDCAT WITH KEY FIELDNAME = LT_X031L-FIELDNAME
              INTO FIELDCAT_WA.

    IF LT_X031L-REFFIELD = 'WAERS' AND LT_X031L-REFTABLE = 'BKPF'.
      FIELDCAT_WA-CFIELDNAME = 'WAERS'.
      FIELDCAT_WA-CTABNAME = 'XBSEG'.
      MODIFY FIELDCAT FROM FIELDCAT_WA INDEX SY-TABIX.
    ELSEIF LT_X031L-REFFIELD = 'WAERS' AND LT_X031L-REFTABLE = 'T001'
        OR LT_X031L-REFFIELD = 'HWAER' AND LT_X031L-REFTABLE = 'BKPF'.
      FIELDCAT_WA-CFIELDNAME = 'HWAER'.
      FIELDCAT_WA-CTABNAME = 'XBSEG'.
      MODIFY FIELDCAT FROM FIELDCAT_WA INDEX SY-TABIX.
    ELSEIF LT_X031L-REFFIELD = 'HWAE2' AND LT_X031L-REFTABLE = 'BKPF'.
      FIELDCAT_WA-CFIELDNAME = 'HWAE2'.
      FIELDCAT_WA-CTABNAME = 'XBSEG'.
      MODIFY FIELDCAT FROM FIELDCAT_WA INDEX SY-TABIX.
    ELSEIF LT_X031L-REFFIELD = 'HWAE3' AND LT_X031L-REFTABLE = 'BKPF'.
      FIELDCAT_WA-CFIELDNAME = 'HWAE3'.
      FIELDCAT_WA-CTABNAME = 'XBSEG'.
      MODIFY FIELDCAT FROM FIELDCAT_WA INDEX SY-TABIX.
    ENDIF.

  ENDLOOP.                                                  " lt_x031l

*ENHANCEMENT-POINT feldkatalog_bseg_01 SPOTS es_saplf064.

ENDFORM.                               " FELDKATALOG
*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
*       Beleganzeige BSEG / POSTAB
*----------------------------------------------------------------------*
FORM LIST_DISPLAY.
  DATA: L_LINES_MISSING_AUTH TYPE I,
        L_MISSING_LINES(70),
        L_PERFORM.
  DATA: L_SAVE(1) TYPE C VALUE C_A.    "Authority to save?  Note 319936
  DATA: L_NODMBE2 TYPE XFELD,                               "Note592490
        L_NODMBE3 TYPE XFELD.                               "Note592490


  L_PERFORM = C_YES.

  DESCRIBE TABLE GT_MISSING_AUTH LINES L_LINES_MISSING_AUTH.

  IF L_LINES_MISSING_AUTH > 0.
    LOOP AT GT_MISSING_AUTH.
      CONCATENATE L_MISSING_LINES GT_MISSING_AUTH
                  INTO L_MISSING_LINES
                  SEPARATED BY SPACE.
    ENDLOOP.

    CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
         EXPORTING
*         DEFAULTOPTION  = 'Y'
              DIAGNOSETEXT1  = TEXT-030
              DIAGNOSETEXT2  = L_MISSING_LINES
*         DIAGNOSETEXT3  = ' '
              TEXTLINE1      = TEXT-031
*         TEXTLINE2      = ' '
              TITEL          = TEXT-032
*         START_COLUMN   = 25
*         START_ROW      = 6
              CANCEL_DISPLAY = ' '
         IMPORTING
              ANSWER         = L_PERFORM
              .
  ENDIF.

  IF L_PERFORM = C_YES.

    PERFORM CHECK_LAYOUT_AUTH USING L_SAVE L_SAVE.         "Note 319936

    SET PARAMETER ID 'BUK' FIELD XBKPF-BUKRS.
    SET PARAMETER ID 'GJR' FIELD XBKPF-GJAHR.
    SET PARAMETER ID 'R/R' FIELD XBKPF-XBLNR.              "Note 742890


* --------------- set appropriate SET/GET Parameter ID-----------------
* Note 0399276

    CASE T020-FUNCL.                  " xbkpf-bstat would also do.
      WHEN 'M'.
        SET PARAMETER ID 'BLM' FIELD XBKPF-BELNR.
      WHEN 'D'.
        SET PARAMETER ID 'BLD' FIELD XBKPF-BELNR.
      WHEN OTHERS.
        SET PARAMETER ID 'BLN' FIELD XBKPF-BELNR.
    ENDCASE.


* ------------------- Authority Check ------------------------------
* Check if user has authority to look on amounts in second or third
* local currency in case of profit center valuation. (Note592490)

* check of second local currency
    IF BKPF-CURT2+1(1) = 2.
      CLEAR L_NODMBE2.
      PERFORM AUTHORITY_CHECK_TRANSFER_PR(SAPMF05L)
        USING '03' SPACE BKPF-CURT2+1(1)
        CHANGING L_NODMBE2.
      IF L_NODMBE2 EQ 'X'.
        LOOP AT XBSEG.
          XBSEG-DMBE2 = SPACE.
          XBSEG-DMB21 = SPACE.
          XBSEG-DMB22 = SPACE.
          XBSEG-DMB23 = SPACE.
          XBSEG-SKNT2 = SPACE.
          XBSEG-MWST2 = SPACE.
          XBSEG-NAVH2 = SPACE.
          XBSEG-BDIF2 = SPACE.
          MODIFY XBSEG.
        ENDLOOP.
      ENDIF.
    ENDIF.

* check of third local currency
    IF BKPF-CURT3+1(1) = 2.
      CLEAR L_NODMBE3.
      PERFORM AUTHORITY_CHECK_TRANSFER_PR(SAPMF05L)
        USING '03' SPACE BKPF-CURT3+1(1)
        CHANGING L_NODMBE3.
      IF L_NODMBE3  EQ 'X'.
        LOOP AT XBSEG.
          XBSEG-DMBE3 = SPACE.
          XBSEG-DMB31 = SPACE.
          XBSEG-DMB32 = SPACE.
          XBSEG-DMB33 = SPACE.
          XBSEG-SKNT3 = SPACE.
          XBSEG-MWST3 = SPACE.
          XBSEG-NAVH3 = SPACE.
          XBSEG-BDIF3 = SPACE.
          MODIFY XBSEG.
        ENDLOOP.
      ENDIF.
    ENDIF.


* --------------- Call ALV for display --------------------------------


    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*   CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
*           I_INTERFACE_CHECK        = ' '
            I_BUFFER_ACTIVE          = C_X                  "ALRK241034
            I_CALLBACK_PROGRAM       = SY-REPID
            I_CALLBACK_PF_STATUS_SET = 'PF_STATUS_SET'
            I_CALLBACK_USER_COMMAND  = 'HANDLE_USER_COMMAND'
*           I_STRUCTURE_NAME         = 'BSEG'
            IS_LAYOUT                = LAYOUT
            IT_FIELDCAT              = FIELDCAT
            I_DEFAULT                = 'X'
* (del)     i_save                   = 'A'                 "Note 319936
            I_SAVE                   = L_SAVE              "Note 319936
            IS_VARIANT               = VARIANT
            IS_PRINT                 = GS_PRINT
            IT_EVENTS                = EVENTS
            IT_EVENT_EXIT            = IT_EVENT_EXIT
         TABLES
              T_OUTTAB                 = XBSEG
         EXCEPTIONS
              PROGRAM_ERROR            = 1
              OTHERS                   = 2.
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.
ENDFORM.                               " LIST_DISPLAY


*&---------------------------------------------------------------------*
*&      Form  SH_BERECHNUNG
*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
FORM INIT USING    P_AKTYP TYPE C
                   P_XEPOS TYPE C.
  EPOS  = P_XEPOS.
  G_AKTYP = P_AKTYP.
  STATUS = C_STAT_LIST.
  S_STATUS-WAEHR = 'F'.
  CLEAR: COMREQ, XCHNG, GS_PRINT.
  GS_PRINT-NO_PRINT_LISTINFOS = C_X.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
  SELECT SINGLE * FROM T020 WHERE TCODE = SY-TCODE.         "ALRK240194

  IF NOT P_AKTYP IS INITIAL.                               "Note 332980
    T020-AKTYP = P_AKTYP.                                  "Note 332980
  ENDIF.                                                   "Note 332980
  GET PARAMETER ID 'FO2' FIELD RFOPT2.
ENDFORM.                               " INIT
*&---------------------------------------------------------------------*
*&      Form  ZEILENFARBE
*&---------------------------------------------------------------------*
*       Die Farbeigenschaften jeder Zeile werden in XBSEG/POSTAB
*       direkt mitgegeben
*       INDEX = '*': alle Zeilen, sonst explizite Zeile
*----------------------------------------------------------------------*
FORM ZEILENFARBE USING
                 COLKEY TYPE C
                 INDEX TYPE I.

  XBSEG-COLOR = COLKEY.
  IF INDEX = '*'.
    MODIFY XBSEG TRANSPORTING COLOR WHERE COLOR EQ SPACE.
  ELSE.
    MODIFY XBSEG INDEX INDEX TRANSPORTING COLOR.
  ENDIF.
ENDFORM.                               " ZEILENFARBE
*&---------------------------------------------------------------------*
*&      Form  BETRAGSFARBE
*&---------------------------------------------------------------------*
*       Hervorheben der Betraege in Belegwaehrung
*----------------------------------------------------------------------*
FORM BETRAGSFARBE.
  COLOR_WA-FIELDNAME = 'WRBTR'.
  COLOR_WA-COLOR-COL = '6'.
  COLOR_WA-COLOR-INT = '0'.
  COLOR_WA-COLOR-INV = '0'.
  APPEND COLOR_WA TO XBSEG-COLFW.
  MODIFY XBSEG TRANSPORTING COLFW WHERE WRBTR NE 0.
ENDFORM.                               " BETRAGSFARBE
*&---------------------------------------------------------------------*
*&      Form  BERECHTIGUNGEN
*&---------------------------------------------------------------------*
*       check authority (display / change) for all document line items
*----------------------------------------------------------------------*
* (del) form berechtigungen changing rc type i.             "Note449741
FORM BERECHTIGUNGEN                                         "Note449741
     USING VALUE(P_BSTAT) LIKE BKPF-BSTAT                   "Note449741
           VALUE(P_AKTYP) LIKE T020-AKTYP                   "Note449741
     CHANGING RC TYPE I.                                    "Note449741

  DATA: L_AUTH(2) TYPE N.
  DATA: L_KOART LIKE BSEG-KOART.                           "Note 321408

  CLEAR RC.                                                 "Note449741
* (del) if g_aktyp = c_aktyp_change.                        "Note449741
* (del)   l_auth = '02'.                                    "Note449741
* (del) elseif g_aktyp = c_aktyp_add.                       "Note449741
* (del)   l_auth = '01'.                                    "Note449741
* (del) else.                                               "Note449741
* (del)   l_auth = '03'.                                    "Note449741
* (del) endif.                                              "Note449741
  IF P_AKTYP = C_AKTYP_CHANGE.                              "Note449741
    IF P_BSTAT NE C_BEL_VORERF.                             "Note449741
      L_AUTH = C_ACT_CHGE.                                  "Note449741
    ELSE.                                                   "Note449741
      L_AUTH = C_ACT_FIPP.                                  "Note449741
    ENDIF.                                                  "Note449741
  ELSEIF G_AKTYP = C_AKTYP_ADD.                             "Note449741
    IF P_BSTAT NE C_BEL_VORERF.                             "Note449741
      L_AUTH = C_ACT_POST.                                  "Note449741
    ELSE.                                                   "Note449741
      L_AUTH = C_ACT_FIPP.                                  "Note449741
    ENDIF.                                                  "Note449741
  ELSE.                                                     "Note449741
    L_AUTH = C_ACT_DISP.                                    "Note449741
  ENDIF.                                                    "Note449741


*--------------- Company code ------------------------------------------
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
    ID 'ACTVT' FIELD L_AUTH
    ID 'BUKRS' FIELD XBSEG-BUKRS.
  IF SY-SUBRC NE 0.
    RC = 4.
    EXIT.
  ENDIF.

*--------------- Account type ------------------------------------------
  IF NOT XBSEG-KOART IS INITIAL.
    IF XBSEG-KOART NE C_B.                                 "Note 321408
      L_KOART = XBSEG-KOART.                               "Note 321408
    ELSE.                                                  "Note 321408
      L_KOART = C_S.                                       "Note 321408
    ENDIF.                                                 "Note 321408
    AUTHORITY-CHECK OBJECT 'F_BKPF_KOA'
      ID 'ACTVT' FIELD L_AUTH
* (del) id 'KOART' field xbseg-koart.                      "Note 321408
      ID 'KOART' FIELD L_KOART.                            "Note 321408
    IF SY-SUBRC NE 0.
      RC = 4.
      EXIT.
    ENDIF.
  ENDIF.

*-------------- business area ------------------------------------------
  IF NOT XBSEG-GSBER IS INITIAL.
    IMPORT AUTH_GSB FROM MEMORY ID 'ALVAUTH_GSB'.
    IF SY-SUBRC NE 0.                                       "Note746724
      CALL FUNCTION 'FI_ADD_AUTHORITY_CHECK'                "Note746724
        EXPORTING                                           "Note746724
           I_BUKRS = SPACE                                  "Note746724
       IMPORTING                                            "Note746724
           E_XGSBE = AUTH_GSB                               "Note746724
      EXCEPTIONS                                            "Note746724
           OTHERS  = 1.                                     "Note746724
    ENDIF.                                                  "Note746724

    IF L_AUTH = '03' AND AUTH_GSB EQ SPACE.
      RC = 0.
    ELSE.
      AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
        ID 'ACTVT' FIELD L_AUTH
        ID 'GSBER' FIELD XBSEG-GSBER.
      IF SY-SUBRC NE 0.
        RC = 4.
        EXIT.                                              "Note 674808
      ENDIF.
    ENDIF.
  ENDIF.

*------------------ accounts -------------------------------------------
  CASE XBSEG-KOART.
    WHEN 'D'.
      PERFORM KNB1_BEGRU_LESEN USING XBSEG-KUNNR XBSEG-BUKRS.
* (del) if not begru is initial.                           "Note 321533
      IF NOT BEGRA IS INITIAL.                             "Note 321533
        AUTHORITY-CHECK OBJECT 'F_BKPF_BED'
          ID 'ACTVT' FIELD L_AUTH
* (del)   id 'BRGRU' field begru.                          "Note 321533
         ID 'BRGRU' FIELD BEGRA.                          "Note 321533
        IF SY-SUBRC NE 0.
          RC = 4.
          EXIT.
        ENDIF.
      ENDIF.
      IF NOT BEGRB IS INITIAL.                             "Note 321533
        AUTHORITY-CHECK OBJECT 'F_BKPF_BED'                "Note 321533
            ID 'ACTVT' FIELD L_AUTH                        "Note 321533
            ID 'BRGRU' FIELD BEGRB.                        "Note 321533
        IF SY-SUBRC NE 0.                                  "Note 321533
          RC = 4.                                          "Note 321533
          EXIT.                                            "Note 321533
        ENDIF.                                             "Note 321533
      ENDIF.                                               "Note 321533
    WHEN 'K'.
      PERFORM LFB1_BEGRU_LESEN USING XBSEG-LIFNR XBSEG-BUKRS.
* (del) if not begru is initial.                           "Note 321533
      IF NOT BEGRA IS INITIAL.                             "Note 321533
        AUTHORITY-CHECK OBJECT 'F_BKPF_BEK'
          ID 'ACTVT' FIELD L_AUTH
* (del)   id 'BRGRU' field begru.                          "Note 321533
         ID 'BRGRU' FIELD BEGRA.                          "Note 321533
        IF SY-SUBRC NE 0.
          RC = 4.
          EXIT.
        ENDIF.
      ENDIF.
      IF NOT BEGRB IS INITIAL.                             "Note 321533
        AUTHORITY-CHECK OBJECT 'F_BKPF_BEK'                "Note 321533
            ID 'ACTVT' FIELD L_AUTH                        "Note 321533
            ID 'BRGRU' FIELD BEGRB.                        "Note 321533
        IF SY-SUBRC NE 0.                                  "Note 321533
          RC = 4.                                          "Note 321533
          EXIT.                                            "Note 321533
        ENDIF.                                             "Note 321533
      ENDIF.                                               "Note 321533
    WHEN OTHERS.
  ENDCASE.

*-------------- Generell für Hauptbuchkonto ----------------------------
  PERFORM SKB1_BEGRU_LESEN USING XBSEG-HKONT XBSEG-BUKRS.
  IF NOT BEGRU IS INITIAL.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BES'
      ID 'ACTVT' FIELD L_AUTH
      ID 'BRGRU' FIELD BEGRU.
    IF SY-SUBRC NE 0.
      RC = 4.
      EXIT.
    ENDIF.
  ENDIF.

*------------ BADI für weitere AUTHORITY-CHECKs auf Zeilenebene -------
  PERFORM BADI_AUTHORITY_ITEM USING RC L_AUTH.              "Note638895
  IF RC = 4.
    EXIT.
  ENDIF.

ENDFORM.                               " BERECHTIGUNGEN
*&---------------------------------------------------------------------*
*&      Form  SKB1_BEGRU_LESEN
*&---------------------------------------------------------------------*
FORM SKB1_BEGRU_LESEN USING HKONT LIKE SKB1-SAKNR
                            BUKRS LIKE BKPF-BUKRS.

  STATICS: BEGIN OF SKB1_BUFFER,                            "ALRK224203
             BUKRS LIKE SKB1-BUKRS,                         "ALRK224203
             SAKNR LIKE SKB1-SAKNR,                         "ALKR224203
             BEGRU LIKE SKB1-BEGRU,                         "ALRK224203
           END OF SKB1_BUFFER.                              "ALRK224203

  CHECK NOT HKONT IS INITIAL.
  IF BUKRS = SKB1_BUFFER-BUKRS AND                          "ALRK224203
     HKONT = SKB1_BUFFER-SAKNR.                             "ALRK224203
    BEGRU = SKB1_BUFFER-BEGRU.                              "ALRK224203
  ELSE.                                                     "ALRK224203
    CLEAR BEGRU.
    SELECT SINGLE BEGRU  INTO BEGRU  FROM SKB1
           WHERE  BUKRS       = BUKRS
           AND    SAKNR       = HKONT          .
    SKB1_BUFFER-BUKRS = BUKRS.                              "ALRK224203
    SKB1_BUFFER-SAKNR = HKONT.                              "ALRK224203
    SKB1_BUFFER-BEGRU = BEGRU.                              "ALRK224203
  ENDIF.                                                    "ALRK224203
ENDFORM.                               " SKB1_BEGRU_LESEN
*&---------------------------------------------------------------------*
*&      Form  KNB1_BEGRU_LESEN
*&      Note 321533: Content of form routine replaced
*&---------------------------------------------------------------------*
FORM KNB1_BEGRU_LESEN USING  KUNNR TYPE KUNNR
                             BUKRS TYPE BUKRS.
  CLEAR: BEGRA, BEGRB.
  PERFORM READ_CUSTOMER USING KUNNR BUKRS.
  BEGRA = KNB1_BUFFER-BEGRA.
  BEGRB = KNB1_BUFFER-BEGRB.
ENDFORM.                               " KNB1_BEGRU_LESEN
*&---------------------------------------------------------------------*
*&      Form  LFB1_BEGRU_LESEN
*&      Note 321533: Content of form routine replaced
*&---------------------------------------------------------------------*
FORM LFB1_BEGRU_LESEN USING  LIFNR TYPE LIFNR
                             BUKRS TYPE BUKRS.
  CLEAR: BEGRA, BEGRB.
  PERFORM READ_VENDOR USING LIFNR BUKRS.
  BEGRA = LFB1_BUFFER-BEGRA.
  BEGRB = LFB1_BUFFER-BEGRB.
ENDFORM.                               " LFB1_BEGRU_LESEN
*&---------------------------------------------------------------------*
*&      Form  FILL_KTEXT_KONTO_FAEDT
*&---------------------------------------------------------------------*
*  determine account short text and net due date
*----------------------------------------------------------------------*
FORM FILL_KTEXT_KONTO_FAEDT.

  IF T001-BUKRS NE XBSEG-BUKRS.
    SELECT SINGLE * FROM T001
      WHERE BUKRS = XBSEG-BUKRS.
  ENDIF.

  CLEAR: SKA1, SKAT.                                        "Note771410

  CALL FUNCTION 'READ_SKA1'
    EXPORTING
      XKTOPL                = T001-KTOPL
      XSAKNR                = XBSEG-HKONT
      XSKIP_AUTHORITY_CHECK = 'X'
    IMPORTING
      XSKA1                 = SKA1
      XSKAT                 = SKAT
    EXCEPTIONS
      KEY_INCOMPLETE        = 1
      NOT_AUTHORIZED        = 2
      NOT_FOUND             = 3
      OTHERS                = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

*------- text for different types of accounts --------------------------
  CASE XBSEG-KOART.

*------- text for G/L account ------------------------------------------
* (del) when 'A' or 'S' or 'M'.                            "Note 193397
* (del) when c_m or c_s.                       "Note 193397 Note 321408
    WHEN C_B OR C_M OR C_S.                                "Note 321408
      IF SY-SUBRC NE 0.
        CLEAR SKAT-TXT20.
      ENDIF.
      XBSEG-KTEXT       = SKAT-TXT20.
      XBSEG-KTEXT_GL    = SKAT-TXT20.
      XBSEG-GL_LTXT     = SKAT-TXT50.                       "Note 446719

* Begin of note 193397
*--------------- Description of fixed asset ----------------------------
    WHEN C_A.
      IF XBSEG-ANLN1 IS INITIAL OR XBSEG-ANLN1(1) = C_*.   "Note 370744
        XBSEG-KTEXT = SKAT-TXT20.
      ELSE.
* The following statement replaces the call to function    "Note 300419
* module 'ANLA_READ_SINGLE, which was deleted.             "Note 300419
        CONCATENATE XBSEG-ANLN1 XBSEG-ANLN2                "Note 300419
          INTO XBSEG-KTEXT                                 "Note 300419
          SEPARATED BY SPACE.                              "Note 300419
        ANLA-BUKRS = XBSEG-BUKRS.                          "Note 435578
        ANLA-ANLN1 = XBSEG-ANLN1.                          " ......
        ANLA-ANLN2 = XBSEG-ANLN2.
        CALL FUNCTION 'ANLA_READ_SINGLE'
          EXPORTING
            F_ANLA    = ANLA
            I_GETFB   = C_X
            I_LOCK    = SPACE
          IMPORTING
            F_ANLA    = ANLA
          EXCEPTIONS
            NOT_FOUND = 4
            OTHERS    = 8.
        CASE SY-SUBRC.
          WHEN 0.
            XBSEG-ASSET_TXT = ANLA-TXT50.
          WHEN 4.                                          "Note 440851
            XBSEG-ASSET_TXT = TEXT-043.
        ENDCASE.
      ENDIF.

      XBSEG-KTEXT_GL    = SKAT-TXT20.                      "Note 300419
      XBSEG-GL_LTXT     = SKAT-TXT50.                      "Note 446719

* End of note 193397

*--------------- name of customer --------------------------------------
    WHEN 'D'.
      KNA1-KUNNR = XBSEG-KUNNR.
      PERFORM READ_CUSTOMER USING KNA1-KUNNR XBSEG-BUKRS.  "Note 321533
      XBSEG-KTEXT       = KNB1_BUFFER-NAME1.               "Note 321533
      XBSEG-KTEXT_GL    = SKAT-TXT20.
      XBSEG-GL_LTXT     = SKAT-TXT50.                      "Note 446719

*--------------- name of vendor ----------------------------------------
    WHEN 'K'.
      LFA1-LIFNR = XBSEG-LIFNR.
      PERFORM READ_VENDOR USING LFA1-LIFNR XBSEG-BUKRS.    "Note 321533
      XBSEG-KTEXT        = LFB1_BUFFER-NAME1.              "Note 321533
      XBSEG-KTEXT_GL     = SKAT-TXT20.
      XBSEG-GL_LTXT      = SKAT-TXT50.                     "Note 446719

    WHEN OTHERS.
  ENDCASE.

  IF SY-LANGU <> 'J'.                                        "Note 784388
    XBSEG-KTEXT = XBSEG-KTEXT(20).                           "Note 600310
  ENDIF.                                                     "Note 784388

  XBSEG-SAKAN = SKA1-SAKAN.
  CASE XBSEG-KOART.
    WHEN 'A'.
      SHIFT XBSEG-ANLN1 LEFT DELETING LEADING '0'.
      XBSEG-KONTO = XBSEG-SAKAN.                           "Note 193397
      PERFORM ALPHAFORMAT(SAPFS000) USING XBSEG-KONTO XBSEG-KONTO.
    WHEN 'K'.
      XBSEG-KONTO = XBSEG-LIFNR.
    WHEN 'D'.
      XBSEG-KONTO = XBSEG-KUNNR.
    WHEN 'M'.
      XBSEG-KONTO = XBSEG-SAKAN.
      PERFORM ALPHAFORMAT(SAPFS000) USING XBSEG-KONTO XBSEG-KONTO.
* * (del) when 'S'.                                          "Note 321408
    WHEN C_B OR C_S.                                       "Note 321408
      IF NOT XBSEG-SAKAN IS INITIAL.                       "Note 771410
        XBSEG-KONTO = XBSEG-SAKAN.
      ELSE.                                                "Note 771410
        XBSEG-KONTO = XBSEG-HKONT.                         "Note 771410
      ENDIF.                                               "Note 771410
      PERFORM ALPHAFORMAT(SAPFS000) USING XBSEG-KONTO XBSEG-KONTO.
  ENDCASE.

* net due date
  IF NOT XBSEG-ZFBDT IS INITIAL.
    CALL FUNCTION 'NET_DUE_DATE_GET'
      EXPORTING
        I_ZFBDT = XBSEG-ZFBDT
        I_ZBD1T = XBSEG-ZBD1T
        I_ZBD2T = XBSEG-ZBD2T
        I_ZBD3T = XBSEG-ZBD3T
        I_SHKZG = XBSEG-SHKZG
        I_REBZG = XBSEG-REBZG
        I_KOART = XBSEG-KOART
      IMPORTING
        E_FAEDT = XBSEG-FAEDT.
  ENDIF.

* currency keys
  IF XBKPF-BELNR NE XBSEG-BELNR OR XBKPF-BUKRS NE XBSEG-BUKRS.
    READ TABLE XBKPF WITH KEY
       BUKRS = XBSEG-BUKRS BELNR = XBSEG-BELNR.
  ENDIF.
  XBSEG-WAERS = XBKPF-WAERS.
  XBSEG-HWAER = XBKPF-HWAER.
  XBSEG-HWAE2 = XBKPF-HWAE2.
  XBSEG-HWAE3 = XBKPF-HWAE3.


***------------ FIELDS WITH SPECIAL DEMANDS -------------------------*

* ------------- external format -------------------------------------*
  CLEAR XBSEG-PROJK_EXT.                                    "Note600838
  IF NOT XBSEG-PROJK IS INITIAL.                            "Note575107
    WRITE XBSEG-PROJK TO XBSEG-PROJK_EXT.
  ENDIF.

ENDFORM.                               " FILL_KTEXT_KONTO_FAEDT


*---------------------------------------------------------------------*
*       FORM CHANGE_SIGN                                              *
*---------------------------------------------------------------------*
* negative amounts, if this is a debit line item                      *
*---------------------------------------------------------------------*
FORM CHANGE_SIGN.
  XBSEG-WRBTR = 0 - XBSEG-WRBTR.
  XBSEG-WMWST = 0 - XBSEG-WMWST.
  XBSEG-DMBTR = 0 - XBSEG-DMBTR.
  XBSEG-MWSTS = 0 - XBSEG-MWSTS.
  XBSEG-DMBE2 = 0 - XBSEG-DMBE2.
  XBSEG-MWST2 = 0 - XBSEG-MWST2.
  XBSEG-DMBE3 = 0 - XBSEG-DMBE3.
  XBSEG-MWST3 = 0 - XBSEG-MWST3.
  XBSEG-MENGE = - XBSEG-MENGE.                             "Note 328889
  XBSEG-ERFMG = - XBSEG-ERFMG.                             "Note 328889
  XBSEG-PSWBT = - XBSEG-PSWBT.                             "Note 339825
ENDFORM.                               " change_sign
*&---------------------------------------------------------------------*
*&      Form  VARIANT_HOLD
*&---------------------------------------------------------------------*
*--- Keep current variant and list layout ------------------------------
*----------------------------------------------------------------------*
FORM VARIANT_HOLD.

*  Set flag VARIANT_FIX (Note 443989) only in case of a single document
*  display, in order to avoid problems with display variants.
*  For future enhancements/developments,
*  adjust form routines
*  Uebergabe_strukturen (single document display) and
*  Define_structures_cc_display (cross company document),
*  to make sure VARIANT-VARIANT, VARIANT-HANDLE and internal table
*  EVENTS get filled correctly in ANY(!) display case.
  IF STATUS EQ C_STAT_HIERSEQ.                             "Note  443989
    CLEAR VARIANT_FIX.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_LIST_LAYOUT_INFO_GET'          "Note448932
         IMPORTING
              ES_VARIANT = VARIANT
         EXCEPTIONS
              OTHERS     = 4.
    VARIANT_FIX = 'X'.
  ENDIF.

ENDFORM.                               " VARIANT_HOLD
*---------------------------------------------------------------------*
*       FORM check_layout_auth                                        *
*       Form created by note 319936                                   *
*---------------------------------------------------------------------*
*       Check whether user is authorized to change ALV variants       *
*---------------------------------------------------------------------*
*  -->  VALUE(P_INPUT) Requested access                               *
*                      A = Change standard and user variants          *
*                      X = Change standard variants                   *
*                      U = Change user variants                       *
*  -->  P_OUTPUT       Allowed access                                 *
*---------------------------------------------------------------------*
FORM CHECK_LAYOUT_AUTH USING VALUE(P_INPUT) TYPE C
                             P_OUTPUT TYPE C.
  CASE P_INPUT.
    WHEN C_A OR C_X.
      AUTHORITY-CHECK OBJECT 'S_ALV_LAYO'
                          ID 'ACTVT' FIELD '23'.
      IF SY-SUBRC = 0.
        P_OUTPUT = P_INPUT.
      ELSE.
        P_OUTPUT = C_U.
      ENDIF.
    WHEN OTHERS.
      P_OUTPUT = P_INPUT.
  ENDCASE.
ENDFORM.                               " CHECK_LAYOUT_AUTH
*---------------------------------------------------------------------*
*       FORM read_customer                                            *
*       Form created by note 321533                                   *
*---------------------------------------------------------------------*
*       Read customer data into buffer, fill header line              *
*---------------------------------------------------------------------*
*  -->  VALUE(KUNNR)                                                  *
*  -->  VALUE(BUKRS)                                                  *
*---------------------------------------------------------------------*
FORM READ_CUSTOMER USING VALUE(KUNNR) LIKE KNB1-KUNNR
VALUE(BUKRS) LIKE BKPF-BUKRS.

  CLEAR KNB1_BUFFER.
  READ TABLE KNB1_BUFFER WITH KEY KUNNR = KUNNR
                                  BUKRS = BUKRS.
  IF SY-SUBRC NE 0.
    DESCRIBE TABLE KNB1_BUFFER.
    IF SY-TFILL >= MAXBUF.
      DELETE KNB1_BUFFER INDEX 1.
    ENDIF.
    SELECT SINGLE BEGRU NAME1
      INTO (KNB1_BUFFER-BEGRA, KNB1_BUFFER-NAME1)
      FROM KNA1
      WHERE KUNNR = KUNNR.
    SELECT SINGLE BEGRU
      INTO KNB1_BUFFER-BEGRB
      FROM KNB1
      WHERE BUKRS = BUKRS
        AND KUNNR = KUNNR.
    KNB1_BUFFER-BUKRS = BUKRS.
    KNB1_BUFFER-KUNNR = KUNNR.
    APPEND KNB1_BUFFER.
  ENDIF.
ENDFORM.                               "read_customer
*---------------------------------------------------------------------*
*       FORM read_vendor                                              *
*       Form created by note 321533                                   *
*---------------------------------------------------------------------*
*       Read vendor data into buffer, fill header line                *
*---------------------------------------------------------------------*
*  -->  VALUE(LIFNR)                                                  *
*  -->  VALUE(BUKRS)                                                  *
*---------------------------------------------------------------------*
FORM READ_VENDOR USING VALUE(LIFNR) LIKE LFB1-LIFNR
                       VALUE(BUKRS) LIKE BKPF-BUKRS.
  CLEAR LFB1_BUFFER.
  READ TABLE LFB1_BUFFER WITH KEY LIFNR = LIFNR
                                  BUKRS = BUKRS.
  IF SY-SUBRC NE 0.
    DESCRIBE TABLE LFB1_BUFFER.
    IF SY-TFILL >= MAXBUF.
      DELETE LFB1_BUFFER INDEX 1.
    ENDIF.
    SELECT SINGLE BEGRU NAME1
      INTO (LFB1_BUFFER-BEGRA, LFB1_BUFFER-NAME1)
      FROM LFA1
      WHERE LIFNR = LIFNR.
    SELECT SINGLE BEGRU
      INTO LFB1_BUFFER-BEGRB
      FROM LFB1
      WHERE BUKRS = BUKRS
        AND LIFNR = LIFNR.
    LFB1_BUFFER-BUKRS = BUKRS.
    LFB1_BUFFER-LIFNR = LIFNR.
    APPEND LFB1_BUFFER.
  ENDIF.
ENDFORM.                               "read_vendor
*---------------------------------------------------------------------*
*       FORM check_tcode_auth                                         *
*       Form created by note 323188                                   *
*---------------------------------------------------------------------*
*       Check if user has authority for a transaction to be called    *
*---------------------------------------------------------------------*
*  -->  VALUE(P_TCODE) Transacton code                                *
*  -->  P_SUBRC        0 = User has authority                         *
*                      4 = User has no authority
*---------------------------------------------------------------------*
FORM CHECK_TCODE_AUTH USING VALUE(P_TCODE) LIKE SY-TCODE
                            P_SUBRC LIKE SY-SUBRC.
  DATA: L_TCODE LIKE SY-TCODE.

* Convert to correct length
  L_TCODE = P_TCODE.
  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
    EXPORTING
      TCODE  = L_TCODE
    EXCEPTIONS
      OK     = 0
      OTHERS = 4.
  P_SUBRC = SY-SUBRC.
ENDFORM.                               "check_tcode_auth
*&---------------------------------------------------------------------*
*&      Form  set_document_key
*&---------------------------------------------------------------------*
*  Fill tables xbkpf, xbseg according to chosen item (Note 388044)
*----------------------------------------------------------------------*
FORM SET_CC_DOC_KEY USING YRS_SELFIELD TYPE SLIS_SELFIELD.

* cross company document display ? ( = sequentiel hierarchy list ?)

  CHECK STATUS EQ C_STAT_HIERSEQ.

* set document key in case cross-company document is displayed

  SY-SUBRC = 4.

  IF YRS_SELFIELD-TABNAME = 'XBSEG'.
    READ TABLE XBSEG INDEX YRS_SELFIELD-TABINDEX.
    READ TABLE XBKPF WITH KEY BUKRS = XBSEG-BUKRS
                              BELNR = XBSEG-BELNR
                              GJAHR = XBSEG-GJAHR.

  ELSEIF YRS_SELFIELD-TABNAME = 'XBKPF'.
    READ TABLE XBKPF INDEX YRS_SELFIELD-TABINDEX.
  ENDIF.

* rc is not equal zero when rsfield-tabname is incorrect or in case
* internal tables are inconsistent.

  CHECK SY-SUBRC NE 0.
  MESSAGE E898 WITH SY-REPID.

ENDFORM.                               " set_document_key
*&---------------------------------------------------------------------*
*&      Form  check_if_archived
*&---------------------------------------------------------------------*
*      Check if document specified in XBKPF is in database (Note 389794)
*----------------------------------------------------------------------*
FORM CHECK_IF_ARCHIVED USING P_BUKRS LIKE BKPF-BUKRS
                             P_BELNR LIKE BKPF-BELNR
                             P_GJAHR LIKE BKPF-GJAHR
                             P_RC    LIKE SY-SUBRC.

* check if document (specified by xbbkf) is really in bkpf

*  select single * from bkpf where bukrs eq p_bukrs and
*                                  belnr eq p_belnr and
*                                  gjahr eq p_gjahr.
*  p_rc = sy-subrc.

* For performance reasons: check if document is in taccdn. Note 532370.

  READ TABLE TACCDN WITH KEY BUKRS = BKPF-BUKRS
                             BELNR = BKPF-BELNR
                             GJAHR = BKPF-GJAHR.
  IF SY-SUBRC = 0.
    P_RC = 1.
  ELSE.
    P_RC = 0.
  ENDIF.

ENDFORM.                    " check_if_archived

*&---------------------------------------------------------------------*
*&      Form  badi_authority_item
*&---------------------------------------------------------------------*
*       Checking further authorizations for line item                  *
*       (Created by note 638895)                                       *
*----------------------------------------------------------------------*
*  -->  l_rcode          '4' if no authorization at all                *
*----------------------------------------------------------------------*
FORM BADI_AUTHORITY_ITEM USING L_RCODE L_AUTH.

  DATA: L_BERACT(2) TYPE C,
        MSG LIKE EDIMESSAGE.

* Typkonvertierung
  L_BERACT = L_AUTH.

*------- BADI zum Prüfen von Berechtigungen ----
  STATICS:
    BADI_EXIT TYPE REF TO IF_EX_FI_AUTHORITY_ITEM,
    BADI_CALLED.

* BADI Initialisieren
  IF BADI_CALLED = SPACE.
    BADI_CALLED = 'X'.
    CALL METHOD CL_EXITHANDLER=>GET_INSTANCE
      EXPORTING
        EXIT_NAME              = 'FI_AUTHORITY_ITEM'
        NULL_INSTANCE_ACCEPTED = SEEX_TRUE
      CHANGING
        INSTANCE               = BADI_EXIT
      EXCEPTIONS
        OTHERS                 = 1.
    IF SY-SUBRC <> 0.
      CLEAR BADI_EXIT.
    ENDIF.
  ENDIF.

* Nur prozessieren wenn BADI aktiv ist
  IF BADI_EXIT IS NOT INITIAL.
    MOVE-CORRESPONDING XBSEG TO BSEG.
*   BADI aufrufen
    CALL METHOD BADI_EXIT->FI_AUTHORITY_ITEM
      EXPORTING
        I_BSEG   = BSEG
        I_BERACT = L_BERACT
      IMPORTING
        E_MSGID  = MSG-MSGID
        E_MSGNO  = MSG-MSGNO
        E_MSGV1  = MSG-MSGV1
        E_MSGV2  = MSG-MSGV2
        E_MSGV3  = MSG-MSGV3
        E_MSGV4  = MSG-MSGV4
      CHANGING
        C_RCODE  = L_RCODE.
  ENDIF.

  IF L_RCODE <> 0 AND NOT MSG-MSGID IS INITIAL.
    MESSAGE ID MSG-MSGID TYPE 'S' NUMBER MSG-MSGNO
            WITH MSG-MSGV1 MSG-MSGV2 MSG-MSGV3 MSG-MSGV4.
  ENDIF.

ENDFORM.                    " badi_authority_item
