FUNCTION ZFI_DOCUMENT_LIST_DISPLAY.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(BUKRS) LIKE  BKPF-BUKRS
*"     VALUE(BELNR) LIKE  BKPF-BELNR
*"     VALUE(GJAHR) LIKE  BKPF-GJAHR OPTIONAL
*"     VALUE(AKTYP) LIKE  T020-AKTYP DEFAULT 'A'
*"     VALUE(XEPOS) LIKE  BOOLE-BOOLE OPTIONAL
*"     VALUE(I_NOCHANGE) LIKE  BOOLE-BOOLE OPTIONAL
*"     VALUE(XPRNT) TYPE  CHAR1 OPTIONAL
*"  EXPORTING
*"     VALUE(E_CMRQ) LIKE  BOOLE-BOOLE
*"     VALUE(E_CHNG) LIKE  BOOLE-BOOLE
*"  EXCEPTIONS
*"      DISPLAY_NOT_POSSIBLE
*"      NO_AUTHORITY
*"--------------------------------------------------------------------
  clear: e_cmrq, e_chng.
* Input parameters are local to function module and not    "Note 302995
* visible in called routines.                              "Note 302995
  if not xprnt is initial.
    MESSAGE S286(F5A).
*   Vorschau zum Drucken eines Buchhaltungsbelegs.
  endif.
  x_nochange = i_nochange.                                 "Note 302995
  PERFORM INIT USING AKTYP XEPOS.
  PERFORM BELEG_LESEN USING BELNR BUKRS GJAHR.
  PERFORM PUBLISH_DOC_ICON
        USING 'BKPF' BUKRS BELNR
              GJAHR '000' SPACE RCODE.                      "Note 402273
  PERFORM UEBERGABE_STRUKTUREN.
  PERFORM FELDKATALOG_BSEG.
  PERFORM LIST_DISPLAY.
  PERFORM UNPUBLISH_ICON.                                   "Note 402273
  E_CMRQ = COMREQ.
  E_CHNG = XCHNG.
ENDFUNCTION.
