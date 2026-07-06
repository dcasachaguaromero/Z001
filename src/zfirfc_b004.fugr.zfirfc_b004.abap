FUNCTION ZFIRFC_B004.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_BELNR) TYPE  BELNR_D
*"     VALUE(I_GJAHR) TYPE  GJAHR
*"     VALUE(I_ZUONR) TYPE  DZUONR OPTIONAL
*"     VALUE(I_LIFNR) TYPE  LIFNR OPTIONAL
*"     VALUE(I_BUZEI) TYPE  BUZEI OPTIONAL
*"     VALUE(XBLNR) TYPE  XBLNR OPTIONAL
*"  EXPORTING
*"     VALUE(ZBUKNR) TYPE  DZBUKR
*"     VALUE(HBKID) TYPE  HBKID
*"     VALUE(HKTID) TYPE  HKTID
*"     VALUE(RZAWE) TYPE  DZLSCH
*"     VALUE(CHECT) TYPE  CHECT
*"     VALUE(ELIFNR) TYPE  LIFNR
*"     VALUE(EKUNNR) TYPE  KUNNR
*"     VALUE(VBLNR) TYPE  VBLNR
*"     VALUE(EGJAHR) TYPE  GJAHR
*"     VALUE(ZALDT) TYPE  DZALDT
*"     VALUE(BANCD) TYPE  BANCD
*"     VALUE(TEXT1) TYPE  FIBL_TXT50
*"     VALUE(BANKL) TYPE  BANKK
*"----------------------------------------------------------------------

TABLES: BKPF, PAYR, BSEG, BSAK.
DATA: WA_REGUP TYPE REGUP,
      WA_BSAK TYPE BSAK,
      WA_PAYR TYPE PAYR.

DATA: POSICION TYPE DOCLN6,
      DCOMP TYPE AUGBL,
      WH_BSEG(1000) TYPE C,
      IS_ANUL LIKE BKPF-XREVERSAL,
      doc_anula like bkpf-STBLG,
      ej_anula like bkpf-STJAH.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    INPUT         = I_BELNR
 IMPORTING
   OUTPUT        = I_BELNR
          .
CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    INPUT         = I_LIFNR
 IMPORTING
   OUTPUT        = I_LIFNR
          .


IF I_GJAHR IS NOT INITIAL AND I_BELNR IS NOT INITIAL AND I_BUKRS IS NOT INITIAL.
   CONCATENATE 'BUKRS EQ ''' I_BUKRS '''' INTO WH_BSEG.
   CONCATENATE WH_BSEG ' AND BELNR EQ ''' I_BELNR '''' INTO WH_BSEG.
   CONCATENATE WH_BSEG ' AND GJAHR EQ ''' I_GJAHR ''''  INTO WH_BSEG.
*   CONCATENATE WH_BSEG ' AND XZAHL EQ ''X''' INTO WH_BSEG.
   IF I_LIFNR IS NOT INITIAL.
     CONCATENATE WH_BSEG ' AND LIFNR EQ ''' I_LIFNR '''' INTO WH_BSEG.
   ENDIF.
   IF I_BUZEI IS NOT INITIAL.
     CONCATENATE WH_BSEG ' AND BUZEI EQ ''' I_BUZEI '''' INTO WH_BSEG.
   ENDIF.
   IF I_ZUONR IS NOT INITIAL.
     CONCATENATE WH_BSEG 'AND ZUONR EQ ''' I_ZUONR '''' INTO WH_BSEG.
   ENDIF.
   IF XBLNR IS NOT INITIAL.
     CONCATENATE WH_BSEG 'AND XBLNR EQ ''' XBLNR '''' INTO WH_BSEG.
   ENDIF.

   SELECT SINGLE XREVERSAL STBLG STJAH INTO (IS_ANUL, doc_anula, ej_anula)
     FROM BKPF CLIENT SPECIFIED
     WHERE MANDT = SY-MANDT
           AND BUKRS = I_BUKRS
           AND BELNR = I_BELNR
           AND GJAHR = I_GJAHR.
     IF SY-SUBRC EQ 0.
       HKTID = IS_ANUL.
       vblnr = doc_anula.
       EGJAHR = ej_anula.

       CHECK DOC_ANULA EQ 0.
       SELECT SINGLE * FROM BSAK
          INTO WA_BSAK
          WHERE (WH_BSEG).
        IF wa_bsak is not initial.
*          IF WA_BSAK-ZLSCH EQ 'C'.
            SELECT SINGLE * FROM PAYR
             INTO WA_PAYR
             WHERE ZBUKR EQ WA_BSAK-BUKRS
*                   AND HBKID EQ WA_BSAK-HBKID
*                   AND RZAWE EQ WA_BSAK-ZLSCH
                   AND VBLNR EQ WA_BSAK-AUGBL
                   .
               HBKID = WA_PAYR-HBKID.
*               HKTID = WA_PAYR-HKTID.
               RZAWE = WA_PAYR-RZAWE.
               CHECT = WA_PAYR-CHECT.
               ELIFNR = WA_PAYR-LIFNR.
               EKUNNR = WA_PAYR-KUNNR.
               VBLNR = WA_PAYR-VBLNR.
               EGJAHR = WA_PAYR-GJAHR.
               ZALDT = WA_PAYR-ZALDT.
               BANCD = WA_PAYR-BANCD.
*          ENDIF.
           ZBUKNR = WA_BSAK-BUKRS.
           HBKID = WA_BSAK-HBKID.
*           HKTID = WA_PAYR-HKTID.
           RZAWE = WA_BSAK-ZLSCH.
*           CHECT = WA_PAYR-CHECT.
           ELIFNR = WA_BSAK-LIFNR.
*           EKUNNR = WA_PAYR-KUNNR.
           VBLNR = WA_BSAK-AUGBL.
           EGJAHR = WA_BSAK-GJAHR.
           TEXT1 = 'Banco Chile'.
           BANKL = '12345'.
*           ZALDT = WA_PAYR-ZALDT.
*           BANCD = WA_PAYR-BANCD.
*           select single * from REGUP
*             INTO WA_REGUP
*             WHERE XVORL NE 'X'
*                   AND LIFNR EQ WA_BSAK-LIFNR
*                   AND VBLNR EQ WA_BSAK-AUGBL
*                   AND BUKRS EQ WA_BSAK-BUKRS
*                   AND BELNR EQ WA_BSAK-BELNR
*                   AND GJAHR EQ WA_BSAK-GJAHR
*                   AND BUZEI EQ WA_BSAK-BUZEI.
        ENDIF.
     ENDIF.
ENDIF.
ENDFUNCTION.
