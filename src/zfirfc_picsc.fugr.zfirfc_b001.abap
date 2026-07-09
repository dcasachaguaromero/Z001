FUNCTION ZFIRFC_B001.
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
      WA_PAYR TYPE PAYR,
      cuenta type BANKN.

DATA: POSICION TYPE DOCLN6,
      DCOMP TYPE AUGBL,
      WH_BSEG(1000) TYPE C.

CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
  EXPORTING
    INPUT         = I_BELNR
 IMPORTING
   OUTPUT        = I_BELNR
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

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*   SELECT SINGLE * FROM BSAK
*     INTO WA_BSAK
*     WHERE (WH_BSEG).
*
* NEW CODE
   SELECT *
   UP TO 1 ROWS  FROM BSAK
     INTO WA_BSAK
     WHERE (WH_BSEG) ORDER BY PRIMARY KEY.

   ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

     ZBUKNR = WA_BSAK-BUKRS.
      HBKID = WA_BSAK-HBKID.
      HKTID = WA_BSAK-HKTID.
      RZAWE = WA_BSAK-ZLSCH.
*      CHECT = WA_PAYR-CHECT.
      ELIFNR = WA_BSAK-LIFNR.
*      EKUNNR = WA_PAYR-KUNNR.
      VBLNR = WA_BSAK-AUGBL.
      EGJAHR = WA_BSAK-GJAHR.
      ZALDT = WA_BSAK-AUGDT.
*      BANCD = WA_BSAK-AUGDT.
*      select single * from REGUP
*        INTO WA_REGUP
*        WHERE XVORL NE 'X'
*              AND LIFNR EQ WA_BSAK-LIFNR
*              AND VBLNR EQ WA_BSAK-AUGBL
*              AND BUKRS EQ WA_BSAK-BUKRS
*              AND BELNR EQ WA_BSAK-BELNR
*              AND GJAHR EQ WA_BSAK-GJAHR
*              AND BUZEI EQ WA_BSAK-BUZEI.
   IF wa_bsak is not initial.
*     IF WA_BSAK-ZLSCH EQ 'C'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*       SELECT SINGLE * FROM PAYR
*        INTO WA_PAYR
*        WHERE ZBUKR EQ WA_BSAK-BUKRS
**              AND HBKID EQ WA_BSAK-HBKID
**              AND RZAWE EQ WA_BSAK-ZLSCH
*              AND VBLNR EQ WA_BSAK-AUGBL
*              .
*
* NEW CODE
       SELECT *
       UP TO 1 ROWS  FROM PAYR
        INTO WA_PAYR
        WHERE ZBUKR EQ WA_BSAK-BUKRS
*              AND HBKID EQ WA_BSAK-HBKID
*              AND RZAWE EQ WA_BSAK-ZLSCH
              AND VBLNR EQ WA_BSAK-AUGBL
               ORDER BY PRIMARY KEY.

       ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
         IF sy-subrc eq 0.
           HBKID = WA_PAYR-HBKID.
            HKTID = WA_PAYR-HKTID.
*            RZAWE = WA_PAYR-RZAWE.
            CHECT = WA_PAYR-CHECT.
            ELIFNR = WA_PAYR-LIFNR.
            EKUNNR = WA_PAYR-KUNNR.
            VBLNR = WA_PAYR-VBLNR.
            EGJAHR = WA_PAYR-GJAHR.
            ZALDT = WA_PAYR-ZALDT.
            BANCD = WA_PAYR-BANCD.
*       ENDIF.
        SELECT SINGLE t~text1 k~BANKN
                into (text1,cuenta)
              FROM  t012k as k
                      inner join t012t as t
                       ON t~BUKRS eq k~bukrs
                          and t~HBKID eq k~hbkid
                          and t~HKTID eq k~hktid
              where t~SPRAS eq sy-langu
                    and t~bukrs eq wa_bsak-bukrs
                    and t~hbkid eq wa_bsak-hbkid.
*                    and t~hktid eq wa_bsak-hktid.
             BANKL = cuenta+0(15).
         ENDIF.

   ENDIF.
ENDIF.
ENDFUNCTION.
