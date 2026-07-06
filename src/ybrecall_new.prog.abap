*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZZRECALL_NEW (V5.600 -II)
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
*
REPORT  ybrecall_new MESSAGE-ID va.
*
*------------ DDIC-Tabellen -------------------------------------------*
TABLES: knvv,                          "Kunden des Vertriebes.
        knvp,                          "Partnerrollen
        m_debis,                       "Matchcode VKORG
        m_vknka.                       "Matchcode Ansprechpartner


TABLES: tvkov,                         "Umsch. Vertriebsweg
        tvkos,                         "Umsch. Sparte
        tpakd,                         "Zuordnung Kontogruppe zu Partner
        tpar,                          "Partnerrollen
        t077d.                         "Debitorengruppen

TABLES: dokhl,                         "Own Help-Request
        tline.

*TABLES: ZZRECALL                      "View on deliveries,KNA1 KL231105
TABLES: lips."                        "delivery items          KL231105

*------------ Felder für die Adressselektion --------------------------*
TYPE-POOLS: lv43m.
INCLUDE lv43mdat.

*------------ Selektionskriterien -------------------------------------*
*
*------------ Organisationsdaten --------------------------------------*
PARAMETER: s_vkorg LIKE knvv-vkorg       "Vertriebsorganisation
                 MEMORY ID vko MODIF ID 001
                 OBLIGATORY,
           s_vtweg LIKE knvv-vtweg       "Vertriebsweg
                 MEMORY ID vtw MODIF ID 002
                 OBLIGATORY,
           s_spart LIKE knvv-spart       "Sparte
                 MEMORY ID spa MODIF ID 003
                 OBLIGATORY.

*------------ Kunde/Partner/Vertriebsbeauftragter ---------------------*
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK partner WITH FRAME TITLE text-a01.
SELECT-OPTIONS: s_kunnr FOR knvv-kunnr   "Kunde/Interessent
                MATCHCODE OBJECT debi.
*select-options: parnr for knvk-parnr   "Ansprechpartner
*                matchcode object vknk.
*select-options: vrtnr for knvp-pernr   "Vertriebsbeauftragter
*                matchcode object prem.
SELECTION-SCREEN END   OF BLOCK partner.

*------------ Selektionsumfang ----------------------------------------*
*------------ Kundenadresse/Kunde -------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK adresse WITH FRAME TITLE text-a02.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER padresse AS CHECKBOX.     "Flag Privatadresse
SELECTION-SCREEN COMMENT  3(27) text-p05.
SELECTION-SCREEN POSITION 53.
PARAMETER kunde AS CHECKBOX.        "Flag Kunde
SELECTION-SCREEN COMMENT  55(24) text-p02.
SELECTION-SCREEN END OF LINE.
*------------ Dienstadresse/Interessent -------------------------------*
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER dadresse AS CHECKBOX.     "Flag Dienstadresse
SELECTION-SCREEN COMMENT  3(27) text-p03.
SELECTION-SCREEN POSITION 53.
PARAMETER potkunde AS CHECKBOX.      "Flag Interessent
SELECTION-SCREEN COMMENT  55(24) text-p04.
SELECTION-SCREEN END OF LINE.
*------------ Privatadresse -------------------------------------------*
SELECTION-SCREEN BEGIN OF LINE.
PARAMETER kadresse  AS CHECKBOX.    "Flag Kundenadresse
SELECTION-SCREEN COMMENT  3(27) text-p01.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END   OF BLOCK adresse.
*-------------Steuerung ------------------------------------------------
PARAMETERS: p_listnr LIKE vbka-vbeln NO-DISPLAY.     "Belegnummer
PARAMETERS: p_versi LIKE sadlstadm-version NO-DISPLAY.
PARAMETERS: p_vtext LIKE sadlstadm-vtext NO-DISPLAY.
PARAMETERS: p_uname LIKE sadlstadm-ernam NO-DISPLAY.
PARAMETERS: p_vari  LIKE vari-variant NO-DISPLAY.
PARAMETERS: p_vbeln LIKE sadlstwu-objid NO-DISPLAY.
PARAMETERS: p_objtyp LIKE sadlstwu-objtype NO-DISPLAY.

PARAMETER target LIKE dip02-tabname NO-DISPLAY.  "Zieldatei
*------------ Kundenkriterien -----------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK kunde   WITH FRAME TITLE text-a03.
*PARAMETER: MATNR LIKE ZZRECALL-MATNR OBLIGATORY            "KL231105
*           MATCHCODE OBJECT MAT1.  "Article-number
*PARAMETER: CHARGE LIKE ZZRECALL-CHARG OBLIGATORY           "KL231105
*           MATCHCODE OBJECT MCHA. "Batch-number
SELECT-OPTIONS: matnr FOR lips-matnr  OBLIGATORY            "KL231105
                 MATCHCODE OBJECT mat1  ,
                charge FOR lips-charg OBLIGATORY            "KL231105
                 MATCHCODE OBJECT mcha. "Batch-number.
SELECTION-SCREEN END   OF BLOCK kunde.
*------------ Partnerkriterien ----------------------------------------*

*------------ RANGES --------------------------------------------------*
RANGES:   rvkorg FOR knvv-vkorg,       "Vertriebsorganisation
          rvtweg FOR knvv-vtweg,       "Vertriebsweg
          rspart FOR knvv-spart,       "Sparte
          rkunnr FOR knvv-kunnr,       "Kunde
          rdear1 FOR kna1-dear1,       "Kennzeichen Wettbewerber
          rdear2 FOR kna1-dear2,       "Kennzeichen Vertriebspartner
          rdear3 FOR kna1-dear3,       "Kennzeichen Interessent
          rktokd FOR kna1-ktokd.       "Kontogruppe


*------------ Datenfelder ---------------------------------------------*

*DATA: BEGIN OF xkna1 OCCURS 100.   "HS011007
*        INCLUDE STRUCTURE kna1.
*DATA: END   OF xkna1.

DATA: BEGIN OF xkunnr OCCURS 100.
        INCLUDE STRUCTURE sdcas_kunnr.
DATA: END   OF xkunnr.

DATA: BEGIN OF xknax OCCURS 100.
        INCLUDE STRUCTURE kna1.
DATA       vbeln(10).
DATA       posnr(6) TYPE n.
DATA       matnr(18).
DATA       charg(10).
DATA       vkorg(4).
DATA       vtweg(2).
DATA       spart(2).
DATA END   OF xknax.

DATA: BEGIN OF xknvv OCCURS 100.
        INCLUDE STRUCTURE knvv.
DATA: END   OF xknvv.

DATA: BEGIN OF xknvp OCCURS 100.
        INCLUDE STRUCTURE knvp.
DATA: END   OF xknvp.

DATA: BEGIN OF xknvk OCCURS 100.
        INCLUDE STRUCTURE knvk.
DATA: END   OF xknvk.

DATA: BEGIN OF xm_debis OCCURS 100.
        INCLUDE STRUCTURE m_debis.
DATA: END   OF xm_debis.

TYPES:

 BEGIN OF t_lips ,
         werks LIKE vbrp-werks,
         vbeln LIKE vbrp-vbeln,
         posnr LIKE vbrp-posnr,
         matnr LIKE vbrp-matnr,
         charg LIKE vbrp-charg,
         arktx LIKE vbrp-arktx.
TYPES: END OF t_lips.

DATA: gt_lips TYPE t_lips OCCURS 0.
*------------ Datenfelder ---------------------------------------------*
DATA: select_flag(1).                  "Zugriff auf Tab.
DATA: kna1_flag(1).                    "KNA1 gelesen
DATA: knvv_flag(1).                    "KNVV gelesen
DATA: knvk_flag(1).                    "KNVK gelesen
DATA: field(50).                       "Feldname
DATA: j(8) TYPE n.                     "Zaehler

DATA: xvkorg LIKE knvv-vkorg,          "Orginalstand SPA/GPA
      xvtweg LIKE knvv-vtweg,
      xspart LIKE knvv-spart.

DATA: listnr_org LIKE vbka-vbeln.
DATA: target_org LIKE dip02-tabname.

*------------ Konstanten ----------------------------------------------*
DATA: p_adresse          VALUE '3',    "Privatadresse
      d_adresse          VALUE '2',    "Dienstadresse
      k_adresse          VALUE '1'.    "Kundenadresse

DATA: memory_flag(3)     VALUE 'MEM'.  "Speichern in Memory
DATA: cas(3)             VALUE 'CAS'.  "Key-Bestandteil INDX
DATA: adr(3)             VALUE 'ADR'.  "Key-Bestandteil INDX
DATA: adm(3)             VALUE 'ADM'.  "Key-Bestandteil INDX
DATA: auftraggeber(2)    VALUE 'AG'.   "Auftraggeber
DATA: ansprechpartner(2) VALUE 'AP'.   "Ansprechpartner
DATA: vbeauftragter(2)   VALUE 'VE'.   "Vertriebsbeauftragter
DATA: block(3) TYPE n    VALUE 100.    "Blockgroesse der Adressen.
DATA: sblock(3) TYPE n   VALUE 100,    "Blockgroesse des Selektfeldes
      sign_i             VALUE 'I',    "Include
      option_eq(2)       VALUE 'EQ',   "equal
      option_ne(2)       VALUE 'NE'.   "not equal

*------------ EXTRACT -------------------------------------------------*
FIELD-GROUPS: header.                 "Sortierkriterien.

*------------ Initialisierung -----------------------------------------*
INITIALIZATION.
  GET PARAMETER ID 'VKO' FIELD xvkorg.
  GET PARAMETER ID 'VTW' FIELD xvtweg.
  GET PARAMETER ID 'SPA' FIELD xspart.

*------------ Prüfung Selektionseingaben-------------------------------*
AT SELECTION-SCREEN.
  CASE sy-ucomm.
    WHEN 'BACK'.
      PERFORM return_to_menu.
    WHEN 'F15 '.
      PERFORM return_to_menu.
    WHEN 'RW'.
      PERFORM return_to_menu.
  ENDCASE.
  IF NOT ( s_vtweg IS INITIAL ) AND s_vkorg IS INITIAL.
    MESSAGE e100.
  ENDIF.
  IF NOT ( s_spart IS INITIAL ) AND s_vkorg IS INITIAL.
    MESSAGE e100.
  ENDIF.
  IF padresse IS INITIAL AND
     dadresse IS INITIAL AND
     kadresse IS INITIAL.
    SET CURSOR FIELD 'PADRESSE'.
    MESSAGE e102.
  ENDIF.
  IF kunde    IS INITIAL AND
     potkunde IS INITIAL.
    SET CURSOR FIELD 'KUNDE'.
    MESSAGE e103.
  ENDIF.
  CASE sy-ucomm.
    WHEN 'PART'.
      SET CURSOR FIELD 'ABTNR-LOW'. LEAVE SCREEN.
    WHEN 'KUND'.
      SET CURSOR FIELD 'LAND1-LOW'. LEAVE SCREEN.
    WHEN 'ORGA'.
      SET CURSOR FIELD 'VKORG'. LEAVE SCREEN.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  IF listnr_org IS INITIAL.
    listnr_org = p_listnr.
  ENDIF.
  IF target_org IS INITIAL.
    target_org = target.
  ENDIF.

  PERFORM screen_modify.
  SET TITLEBAR '001'.

START-OF-SELECTION.
* Setzen übergebene Parameter
  IF NOT ( listnr_org IS INITIAL ).
    p_listnr = listnr_org.
  ENDIF.
  IF NOT ( target_org IS INITIAL ).
    target = target_org.
  ENDIF.
  PERFORM orgs_umschluesseln.
  PERFORM kunden_ermitteln.
  PERFORM adressen_ermitteln.
* Selektionsbild überspringen.
  IF NOT ( sy-calld IS INITIAL ).
    LEAVE PROGRAM.
  ENDIF.


*---------------------------------------------------------------------*
*       FORM ADRESSEN_ERMITTELN                                       *
*---------------------------------------------------------------------*
*       Adressen der Partner/Kunden ermitteln                         *
*---------------------------------------------------------------------*
FORM adressen_ermitteln.

  CALL FUNCTION 'SDCAS_ADDRESS_LIST_CREATE'
       EXPORTING
            fi_vbeln                       = p_vbeln
            fi_objtype                     = p_objtyp
            fi_listnr                      = p_listnr
            fi_version                     = p_versi
            fi_ernam                       = p_uname
            fi_selreport                   = sy-cprog
            fi_selvariant                  = p_vari
            fi_address_vtext               = p_vtext
            fi_address_customer            = kadresse
*         FI_ABTNR                       =
            fi_address_partner_privat      = padresse
            fi_address_partner_office      = dadresse
            fi_sortfield1                  = 'NAME1_AP'
*         FI_SORTORDER1                  = PSORTD1
            fi_sortfield2                  = 'NAME1'
*         FI_SORTORDER2                  =
*         FI_SORTFIELD3                  =
*         FI_SORTORDER3                  =
*         FI_BLOCKSIZE                   = '100'
       TABLES
*         FT_PARNR                       =
            ft_kunnr                       = xkunnr
*            ft_kna1                        =  xkna1
            ft_knvk                        =  xknvk
       EXCEPTIONS
            no_document_number             = 1
            no_persons                     = 2
            no_addresstype                 = 3
            OTHERS                         = 4.
  CASE sy-subrc.
    WHEN 0.
      MESSAGE s488(vr).
      LEAVE PROGRAM.
    WHEN 1.
      MESSAGE s020(vr).
    WHEN OTHERS.
      MESSAGE s700(vr).
  ENDCASE.
ENDFORM.                    "ADRESSEN_ERMITTELN


*---------------------------------------------------------------------*
*       FORM DEBITORENTYP_SETZEN                                      *
*---------------------------------------------------------------------*
*   Selektionstabellen fuellen.                                       *
*---------------------------------------------------------------------*
FORM debitorentyp_setzen.
* Adressen nur von Kunden/keine CPD-Kunden
  IF NOT ( kunde IS INITIAL ).
    SELECT * FROM tpakd WHERE parvw = auftraggeber.
      PERFORM select_fuellen1 IN PROGRAM saplv06b TABLES rktokd
              USING  sign_i option_eq
                     tpakd-ktokd rktokd-low rktokd-sign rktokd-option.
    ENDSELECT.

    SELECT * FROM t077d WHERE ktokd IN rktokd
                        AND   xcpds = 'X'.
      rktokd-sign = sign_i.
      rktokd-option = option_eq.
      rktokd-low    = t077d-ktokd.
      READ TABLE rktokd WITH KEY rktokd(7) BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE rktokd INDEX sy-tabix.
      ENDIF.
    ENDSELECT.

    IF potkunde IS INITIAL.
* Kein Interessent
      PERFORM select_fuellen1 IN PROGRAM saplv06b TABLES rdear3
              USING  sign_i option_ne
                     'X'    rdear3-low rdear3-sign rdear3-option.
    ENDIF.

  ENDIF.
* Adressen von Interessenten.
  IF NOT ( potkunde IS INITIAL ).
    PERFORM select_fuellen1 IN PROGRAM saplv06b TABLES rdear3
            USING  sign_i option_eq
                   'X'        rdear3-low rdear3-sign rdear3-option.
  ENDIF.
ENDFORM.                    "DEBITORENTYP_SETZEN

*---------------------------------------------------------------------*
*       FORM HELP_REQUEST                                             *
*---------------------------------------------------------------------*
*       process own help-information                                  *
*---------------------------------------------------------------------*
FORM help_request USING value(id) value(object) value(header)
                         value(langu) value(titel).
  CALL FUNCTION 'HELPSCREEN_CREATE'
    EXPORTING
      doku_id     = id
      doku_objekt = object
      headertext  = header
      langu       = langu
      titel       = title.
ENDFORM.                    "HELP_REQUEST


*---------------------------------------------------------------------*
*       FORM KNA1_LESEN                                               *
*---------------------------------------------------------------------*
*       Ermitteln Kunde aus KNA1.                                     *
*---------------------------------------------------------------------*
*  -->  RC                                                            *
*---------------------------------------------------------------------*
FORM kna1_lesen USING rc.
  rc = 4.
* sort kunnr.
* do.
*  perform rkunnr_fuellen.
*    if not ( kunde is initial ) and
*       not ( potkunde is initial ).

  REFRESH gt_lips.
  PERFORM select_delivery TABLES gt_lips.                   "Kl231105

*all deliveries in comb s.org d.ch div from lips not knvv!!!
*only 1 entry per kunnr in xkna1(!)
*only outbound delivery

  SORT  gt_lips BY vbeln posnr.                             "KL231105
  DELETE ADJACENT DUPLICATES FROM gt_lips COMPARING vbeln.  "KL231105

*  SELECT * FROM                                             "KL231105
  SELECT a~kunnr FROM                                       "HS011007
    (   likp AS a
   JOIN lips AS e
    ON e~vbeln = a~vbeln )
*     JOIN kna1 AS k        "HS011007
*     ON a~kunnr = k~kunnr  "HS011007
*  INTO CORRESPONDING FIELDS OF TABLE xkna1                 "HS011007
  INTO TABLE xkunnr
 FOR ALL ENTRIES IN gt_lips
 WHERE
      a~vbtyp       = 'J'           AND "only outbound delivery
      a~vbeln       = gt_lips-vbeln AND
      a~kunnr       IN s_kunnr      AND
      e~posnr       = gt_lips-posnr AND
      a~vkorg = s_vkorg  AND
      e~vtweg = s_vtweg  AND
      e~spart = s_spart  AND
      e~matnr  IN matnr  AND
      e~charg  IN charge .                                  "KL231105

*  SORT xkna1 BY kunnr.                                      "KL231105
*  DELETE ADJACENT DUPLICATES FROM xkna1 COMPARING kunnr.    "KL231105

 SORT xkunnr.                                              "HS011007
  DELETE ADJACENT DUPLICATES FROM xkunnr.                   "HS011007

*    SELECT * FROM ZZRECALL WHERE                           "KL231105
*        CHARG = CHARGE AND                                 "KL231105
*        MATNR = MATNR  AND                                 "KL231105
*        VKORG = S_VKORG  AND                               "KL231105
*        VTWEG = S_VTWEG  AND                               "KL231105
*        SPART = S_SPART.                                   "KL231105
*    MOVE-CORRESPONDING ZZRECALL TO XKNA1.                  "KL231105
*    APPEND XKNA1.                                          "KL231105
*  ENDSELECT.                                               "KL231105

*  endif.
*   describe table kunnr lines sy-tfill.
*   if sy-tfill = 0. exit. endif.
* enddo.

* begin del HS011007
*  DESCRIBE TABLE xkna1 LINES sy-tfill.
*  IF sy-tfill > 0.
*    rc = 0.
*    REFRESH kunnr.
*    LOOP AT xkna1.
*      PERFORM select_fuellen1 IN PROGRAM saplv06b TABLES kunnr
*              USING  sign_i option_eq
*                     xkna1-kunnr kunnr-low kunnr-sign kunnr-option.
*    ENDLOOP.
*  ENDIF.
* end del HS011007
  kna1_flag = 'X'.
ENDFORM.                                                    "KNA1_LESEN


*---------------------------------------------------------------------*
*       FORM KREUZE_SETZEN                                            *
*---------------------------------------------------------------------*
*       Setzen oder Loeschen Kreuz in dem ausgewählten Feld           *
*---------------------------------------------------------------------*
*  -->  FELD                                                          *
*---------------------------------------------------------------------*
FORM kreuze_setzen USING feld.
  IF feld IS INITIAL.
    feld =  'X'.
  ELSE.
    CLEAR feld.
  ENDIF.
ENDFORM.                    "KREUZE_SETZEN

*---------------------------------------------------------------------*
*       FORM KUNDEN_ERMITTELN                                         *
*---------------------------------------------------------------------*
*       Ermitteln der Kunden/Partner                                  *
*---------------------------------------------------------------------*
FORM kunden_ermitteln.
  DATA: rc LIKE sy-subrc.
*  perform debitorentyp_setzen.
*  clear select_flag.
  PERFORM kna1_lesen USING rc.
ENDFORM.                    "KUNDEN_ERMITTELN

*---------------------------------------------------------------------*
*       FORM ORGS_UMSCHLUESSELN                                       *
*---------------------------------------------------------------------*
*       Vertriebsweg und Sparte werden über die dazugehörigen         *
*       Tabellen umgeschluesselt                                      *
*---------------------------------------------------------------------*
FORM orgs_umschluesseln.
*------- Verkaufsorganisation                                          *
  IF NOT ( s_vkorg IS INITIAL ).
    PERFORM select_fuellen1 IN PROGRAM saplv06b TABLES rvkorg
            USING  sign_i option_eq
                   s_vkorg rvkorg-low rvkorg-sign rvkorg-option.
  ENDIF.

*------- Vertriebsweg -------------------------------------------------*
  SELECT SINGLE * FROM tvkov WHERE vkorg = s_vkorg
                             AND   vtweg = s_vtweg.
  IF NOT ( s_vtweg IS INITIAL ).
    IF sy-subrc = 0.
      PERFORM  select_fuellen1 IN PROGRAM saplv06b TABLES rvtweg
               USING  sign_i option_eq
                      tvkov-vtwku rvtweg-low rvtweg-sign rvtweg-option.
    ENDIF.
  ENDIF.
*------- Sparte -------------------------------------------------------*
  SELECT SINGLE * FROM tvkos WHERE vkorg = s_vkorg
                             AND   spart = s_spart.

  IF NOT ( s_spart IS INITIAL ).
    IF sy-subrc = 0.
      PERFORM select_fuellen1 IN PROGRAM saplv06b TABLES rspart
              USING  sign_i option_eq
                     tvkos-spaku rspart-low rspart-sign rspart-option.
    ENDIF.
  ENDIF.
ENDFORM.                    "ORGS_UMSCHLUESSELN

**---------------------------------------------------------------------*
**       FORM RKUNNR_FUELLEN                                           *
**---------------------------------------------------------------------*
**       Fuellen 100-Blöcke in Selections-Set RKUNNR                   *
**---------------------------------------------------------------------*
*FORM rkunnr_fuellen.
*  REFRESH rkunnr.
*  CLEAR   rkunnr.
*  DO sblock TIMES.
*    READ TABLE kunnr INDEX 1.
*    IF sy-subrc <> 0. EXIT. ENDIF.
*    IF kunnr-low <> rkunnr-low.
*      rkunnr = kunnr.
*      APPEND rkunnr.
*    ENDIF.
*    DELETE kunnr INDEX 1.
*  ENDDO.
*ENDFORM.                    "RKUNNR_FUELLEN

*---------------------------------------------------------------------*
*       FORM SCREEN_MODIFY                                            *
*---------------------------------------------------------------------*
*       Sind die Organisationsdaten gesetzt, dann dürfen sie nicht    *
*       mehr geändert werden (nur bei Ansprung aus Kontaktpflege)     *
*---------------------------------------------------------------------*
FORM screen_modify.

  CHECK sy-tcode CS 'VC0'.
  GET PARAMETER ID 'VKO' FIELD s_vkorg.
  GET PARAMETER ID 'VTW' FIELD s_vtweg.
  GET PARAMETER ID 'SPA' FIELD s_spart.
  LOOP AT SCREEN.
    IF screen-group1 = '001' AND NOT ( xvkorg IS INITIAL ).
      screen-input = off.
    ENDIF.
    IF screen-group1 = '002' AND NOT ( xvtweg IS INITIAL ).
      screen-input = off.
    ENDIF.
    IF screen-group1 = '003' AND NOT ( xspart IS INITIAL ).
      screen-input = off.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    "SCREEN_MODIFY

*---------------------------------------------------------------------*
*       FORM SELECT_FLAG_SETZEN                                       *
*---------------------------------------------------------------------*
*       Ermitteln, ob es vorteilhaft ist, auf die Tabelle zuzugreifen *
*---------------------------------------------------------------------*
*  -->  TABELLE                                                       *
*---------------------------------------------------------------------*
FORM select_flag_setzen TABLES tabelle.
  DESCRIBE TABLE tabelle LINES sy-tfill.
  IF sy-tfill > 0.
    select_flag = 'X'.
  ENDIF.
ENDFORM.                    "SELECT_FLAG_SETZEN

INCLUDE abapretn.

*&--------------------------------------------------------------------*
*&      Form  select_delivery
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM select_delivery TABLES lt_lips .

  DATA: lv_maind         LIKE tvind-maind.

* Check if index VLPMA is active:
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
  SELECT SINGLE maind INTO lv_maind FROM tvind WHERE trvog EQ '6'.
  IF NOT sy-subrc IS INITIAL.
    CLEAR lv_maind.
  ENDIF.

  REFRESH :  lt_lips.

  CASE lv_maind.
* VLPMA is active
    WHEN 'X'.
      SELECT s~werks s~vbeln s~posnr s~matnr s~charg s~arktx
      INTO CORRESPONDING FIELDS OF TABLE lt_lips
      FROM lips AS s INNER JOIN vlpma AS p
      ON s~vbeln EQ p~vbeln AND
         s~posnr EQ p~posnr
      WHERE p~matnr IN matnr
      AND s~charg IN charge
      AND s~xchpf EQ 'X'.

    WHEN OTHERS.
* If VLPMA is NOT active then select as usual
      SELECT werks vbeln posnr matnr charg arktx
      INTO CORRESPONDING FIELDS OF TABLE lt_lips
      FROM lips WHERE   matnr IN matnr
                AND     charg IN charge
                AND NOT xchpf EQ ' '.
  ENDCASE.

ENDFORM.                    "select_delivery
