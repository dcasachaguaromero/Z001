FUNCTION ZAC_HELP_KURSF.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR_T
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------

  TABLES: BKPF, TCURC.
  data: lkurst like t003-kurst,
        lwaer  LIKE tcurr-tcurr,
        ldisp  type xfeld.
  DATA source_tab LIKE bkpf OCCURS 1 WITH HEADER LINE.
  check callcontrol-step = 'PRESEL1'.

*---- Benötigte Eingabefelder in BKPF-Feldleiste  übertragen -----------
  CLEAR bkpf.
  rc = 0.

*--------- Hauswährung aus Buchungskreis ableiten ----------------------
  perform READ_FROM_SCREEN using    'BUKRS' shlp
                           changing bkpf-bukrs rc.
  SELECT SINGLE waers FROM t001 INTO lwaer
                      WHERE bukrs = bkpf-bukrs.
  if sy-subrc ne 0.
    message s001 with bkpf-bukrs.
    callcontrol-step = 'RETTOP'.
    exit.
  endif.

*--------------- Belegwährung ------------------------------------------
  perform READ_FROM_SCREEN using    'WAERS' shlp
                           changing bkpf-waers  rc.
  if bkpf-waers is initial.
    message s179.
    callcontrol-step = 'RETTOP'.
    exit.
  endif.
  SELECT single * FROM  TCURC
         WHERE  WAERS  = bkpf-waers.
  if sy-subrc ne 0.
    message s180 with bkpf-waers.
    callcontrol-step = 'RETTOP'.
    exit.
  ENDIF.

*-------------- Keine weitere Aktion, bei Buchung in HW ----------------
  if bkpf-waers = lwaer.
    message s178.
    callcontrol-step = 'RETTOP'.
    exit.
  endif.

*----------------- Buchungsdatum ---------------------------------------
  perform READ_FROM_SCREEN using    'BUDAT' shlp
                           changing bkpf-budat  rc.
  if rc ne 0.
    message id sy-msgid type 'S' number sy-msgno
               with sy-msgv1
                    sy-msgv2
                    sy-msgv3
                    sy-msgv4.
    callcontrol-step = 'RETTOP'.
    exit.
  endif.
  if bkpf-budat is initial.
    bkpf-budat = sy-datlo.
  endif.

*------------ Wertstellungsdatum falls eingegeben ----------------------
  perform READ_FROM_SCREEN using    'WWERT' shlp
                           changing bkpf-wwert  rc.
  if rc ne 0 and not interface_wa-value is initial.
    message id sy-msgid type 'S' number sy-msgno
               with sy-msgv1
                    sy-msgv2
                    sy-msgv3
                    sy-msgv4.
    callcontrol-step = 'RETTOP'.
    exit.
  endif.

*------- Wertstellungsdatum setzen, falls nicht manuell eingegeben -----
  if bkpf-wwert is initial.
    bkpf-wwert = bkpf-budat.
  endif.

*---- Kursfeld holen und in interne Darstellung konvertieren -----------
  perform READ_FROM_SCREEN using    'KURSF' shlp
                           changing bkpf-kursf  rc.

*------------ Anzeige eigenschaft des Kursfeldes merken ----------------
  ldisp = interface_wa-dispfield.
  CALL FUNCTION 'CONVERT_RATE_INPUT'
       EXPORTING
            rate_extern = interface_wa-value
       IMPORTING
            rate        = bkpf-kursf
       exceptions
            error_message = 1.
  if sy-subrc = 1.
    message id sy-msgid type 'S' number sy-msgno
               with sy-msgv1
                    sy-msgv2
                    sy-msgv3
                    sy-msgv4.
    callcontrol-step = 'RETTOP'.
    exit.
  endif.

*------------- Kurstyp aus Belegart ------------------------------------
  perform READ_FROM_SCREEN using    'BLART' shlp
                           changing bkpf-blart  rc.
  select single kurst from t003 into lkurst
                      where blart = bkpf-blart.
  if sy-subrc ne 0.
    message s181.
    lkurst = 'M'.
  endif.
  if lkurst is initial.
    lkurst = 'M'.
  endif.

*------- Eigentlichen F4-Baustein rufen --------------------------------
  CALL FUNCTION 'F4_EXCHANGE_RATE'
       EXPORTING
            type_of_rate     = lkurst
            date             = bkpf-wwert
            foreign_currency = bkpf-waers
            local_currency   = lwaer
            display_only     = ldisp
       CHANGING
            kurs             = bkpf-kursf
       exceptions
            INSUFFICIENT_INPUT = 4.
  if sy-subrc = 4.
    message s177.
    callcontrol-step = 'RETTOP'.
    exit.
  endif.

* ------------Kurs in Trefferliste stellen und Rücksprung --------------
  refresh source_tab.
  APPEND bkpf TO source_tab.

  CALL FUNCTION 'F4UT_RESULTS_MAP'
       EXPORTING
            source_structure = 'BKPF'
       TABLES
            shlp_tab         = shlp_tab
            record_tab       = record_tab
            source_tab       = source_tab
       CHANGING
            shlp             = shlp
            callcontrol      = callcontrol.

  callcontrol-step = 'RETTOP'.
ENDFUNCTION.
