*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE LFHL2F00                                                   *
*----------------------------------------------------------------------*

*eject
*----------------------------------------------------------------------*
*        FORM  CURTP_TEXT_LESEN                                        *
*----------------------------------------------------------------------*
*        Bezeichnung zum Domänenfestwert der Domäne CURTP lesen        *
*----------------------------------------------------------------------*
*   -->  CURTP_VALUE                                                   *
*   <--  CURTP_TEXT                                                    *
*----------------------------------------------------------------------*
form curtp_text_lesen using
     curtp_value like dd07l-domvalue_l
     curtp_text  like dd07t-ddtext.

  call function 'FI_CUST_READ_DOMVALUETEXT'
    exporting
      domname        = 'CURTP'
      domvalue       = curtp_value
    importing
      ddtext         = curtp_text
    exceptions
      text_not_found = 1.
  if sy-subrc <> 0.
    clear curtp_text.
  endif.

endform.                    "curtp_text_lesen

*eject
*----------------------------------------------------------------------*
*        FORM  DFIESTAB_FUELLEN                                        *
*----------------------------------------------------------------------*
*        Tabelle DFIESTAB füllen                                       *
*----------------------------------------------------------------------*
form dfiestab_fuellen.

*------- DFIES-Informationen zu je einer Tabelle aus TABTAB ------------
  data:  begin of fieldtab occurs 100.
          include structure dfies.
  data:  end of fieldtab.

*------- DFIESTAB füllen -----------------------------------------------
  refresh dfiestab.
  clear dfiestab.
  loop at tabtab.
    call function 'GET_FIELDTAB'
      exporting
        only                = space
        tabname             = tabtab-tbnam
        withtext            = 'X'
      tables
        fieldtab            = fieldtab
      exceptions
        internal_error      = 8
        no_texts_found      = 1
        table_has_no_fields = 4
        table_not_activ     = 4.
    case sy-subrc.
      when 8.
        message e403 with
          'FI_F4_FIELDNAME' 'CALL FUNCTION GET_FIELDTAB'
          'TABTAB-TBNAM = ' tabtab-tbnam
          raising internal_error.
      when 4.
        message e411 with tabtab-tbnam raising table_not_activ.
      when others.
        loop at fieldtab.
          dfiestab = fieldtab.
          append dfiestab.
        endloop.
    endcase.
    refresh fieldtab.
  endloop.
  free fieldtab.

endform.                    "dfiestab_fuellen

*eject
*----------------------------------------------------------------------*
*        FORM  EXCTABS_VERGLEICHEN                                     *
*----------------------------------------------------------------------*
*        Tabelle EXCTAB und OLD_EXCTAB vergleichen                     *
*----------------------------------------------------------------------*
*   <--  SUBRC  Return-Code; '0' bei Gleichheit, '4' bei Ungleichheit  *
*----------------------------------------------------------------------*
form exctabs_vergleichen using subrc like sy-subrc.

  data:  anz1      like sy-tfill,
         anz2      like sy-tfill.

  subrc = 0.
  describe table exctab     lines anz1.
  describe table old_exctab lines anz2.

*------- Anzahl Zeilen verschieden ==> Tabellen verschieden ------------
  if anz1 <> anz2.
    subrc = 4.
  else.

*------- Anzahl Zeilen gleich ==> prüfen, ob Einträge gleich -----------
*        Voraussetzung: EXCTAB enthält keinen Eintrag mehrfach
    loop at exctab.
      loop at old_exctab
           where tname = exctab-tname
           and   fname = exctab-fname.
        exit.
      endloop.
      if sy-subrc <> 0.
        subrc = 4.
        exit.
      endif.
    endloop.
  endif.

endform.                    "exctabs_vergleichen

*eject
*----------------------------------------------------------------------*
*        FORM  FAELLIGKEIT_TEXT_AUFBAUEN                               *
*----------------------------------------------------------------------*
*        Beschreibung der Zeilen zur Fälligkeit aus den Angaben in     *
*        XT052 ermitteln                                               *
*----------------------------------------------------------------------*
*  <-->  TEXT                                                          *
*----------------------------------------------------------------------*
form faelligkeit_text_aufbauen using
     text like zbtxt-ztext.

  data:  zprz3 like xt052-zprz2.       " Hilfsfeld für PERFORM

*------- Text zur 1. Zeile der Fälligkeit ------------------------------
  perform text_aufbauen using
          xt052-zprz1 xt052-ztag1 xt052-zsmn1 xt052-zstg1 text.

*------- Text zur 2. Zeile der Fälligkeit ------------------------------
  if xt052-zprz2 > 0
  or xt052-ztag2 > 0
  or xt052-zsmn2 > 0
  or xt052-zstg2 > 0.
    perform text_aufbauen using
            xt052-zprz2 xt052-ztag2 xt052-zsmn2 xt052-zstg2 text.
  endif.

*------- Text zur 3. Zeile der Fälligkeit ------------------------------
  if xt052-ztag3 > 0
  or xt052-zsmn3 > 0
  or xt052-zstg3 > 0.
    zprz3 = 0.
    perform text_aufbauen using
            zprz3 xt052-ztag3 xt052-zsmn3 xt052-zstg3 text.
  endif.

endform.                    "faelligkeit_text_aufbauen

*eject
*----------------------------------------------------------------------*
*        FORM  FELDN_TNAME_ERMITTELN                                   *
*----------------------------------------------------------------------*
*        E_FELDN und E_TNAME aus FELDTAB-FNAME ermitteln               *
*----------------------------------------------------------------------*
form feldn_tname_ermitteln.

  data: offset like sy-fdpos.

*------- E_FELDN, E_TNAME ermitteln ------------------------------------
  search feldtab-fname for '-'.
  check sy-subrc = 0.
  e_tname = feldtab-fname(sy-fdpos).
  offset  = sy-fdpos + 1.
  e_feldn = feldtab-fname+offset.

endform.                    "feldn_tname_ermitteln

*eject
*----------------------------------------------------------------------*
*        FORM  FELDTAB_FUELLEN                                         *
*----------------------------------------------------------------------*
*        Tabelle FELDTAB füllen und importierte Selektionsbedingungen  *
*        merken (TABTAB, EXCTAB,...)                                   *
*----------------------------------------------------------------------*
form feldtab_fuellen.

  data:  strln     type i,             " Stringlänge
         old_tbnam like dfiestab-tabname.   " Tabellenname

*------- Initialisierungen ---------------------------------------------
  refresh feldtab.
  clear: feldtab, laenge_fname, laenge_ftext.
  read table dfiestab index 1.
  if sy-subrc = 0.
    old_tbnam = dfiestab-tabname.
  endif.

*------- FELDTAB füllen ------------------------------------------------
  loop at dfiestab.

*------- ... OLD_TBNAM setzen bei Wechsel von TABNAME ------------------
    at end of tabname.
      old_tbnam = dfiestab-tabname.
    endat.

*------- ... erlaubten Feldnamen ermitteln -----------------------------
    loop at exctab
         where tname = dfiestab-tabname
         and   fname = dfiestab-fieldname.
      exit.
    endloop.
    check sy-subrc <> 0.
    if i_xkeyf = space.
      check dfiestab-keyflag = space.
    endif.
    if i_xlogf <> space.
      check dfiestab-logflag <> space.
    endif.
    if i_xgrkl <> space.
      check dfiestab-lowercase <> space.
    endif.
    if i_inttp <> space.
      check i_inttp cs dfiestab-inttype.
    endif.

*------- ... Feldnamen zusammensetzen, falls erforderlich --------------
    clear feldtab.
    if i_xfeld = space.
      feldtab-fname = dfiestab-tabname.
      feldtab-fname+10(1) = '-'.
      feldtab-fname+11 = dfiestab-fieldname.
      condense feldtab-fname no-gaps.
    else.
      feldtab-fname = dfiestab-fieldname.
    endif.

*------- ... Bezeichnung des Feldnamens --------------------------------
    if not dfiestab-scrtext_l is initial.
      feldtab-ftext = dfiestab-scrtext_l.
    elseif not dfiestab-scrtext_m is initial.
      feldtab-ftext = dfiestab-scrtext_m.
    elseif not dfiestab-scrtext_s is initial.
      feldtab-ftext = dfiestab-scrtext_s.
    else.
      feldtab-ftext = dfiestab-fieldtext.
    endif.

*------- ... Feldlänge, Ausgabelänge, interner Datentyp, interne Länge -
    feldtab-dleng = dfiestab-leng.
    feldtab-outpl = dfiestab-outputlen.
    feldtab-inttp = dfiestab-inttype.
    feldtab-intln = dfiestab-intlen.

*------- ... bei I_XFELD <> SPACE keine Feldnamen mehrfach aufnehmen ---
    if i_xfeld = space
    or old_tbnam = dfiestab-tabname.
      append feldtab.
    else.
      loop at feldtab
           where fname = feldtab-fname
           and   ftext = feldtab-ftext
           and   dleng = feldtab-dleng
           and   outpl = feldtab-outpl
           and   inttp = feldtab-inttp
           and   intln = feldtab-intln.
        exit.
      endloop.
      if sy-subrc <> 0.
        append feldtab.
      endif.
    endif.

*------- ... maximale Länge von Feldname und Feldbezeichn. merken ------
    strln = strlen( feldtab-fname ).
    if strln > laenge_fname.
      laenge_fname = strln.
    endif.
    strln = strlen( feldtab-ftext ).
    if strln > laenge_ftext.
      laenge_ftext = strln.
    endif.
  endloop.

*------- Länge von Feldbezeichnung muß mind. 20 sein -------------------
  if laenge_ftext < 20.
    laenge_ftext = 20.
  endif.

*------- importierte Selektionsbedingungen merken ----------------------
  refresh: old_tabtab, old_exctab.
  loop at tabtab.
    old_tabtab = tabtab.
    append old_tabtab.
  endloop.
  loop at exctab.
    old_exctab = exctab.
    append old_exctab.
  endloop.
  old_xfeld = i_xfeld.
  old_xgrkl = i_xgrkl.
  old_xkeyf = i_xkeyf.
  old_xlogf = i_xlogf.
  old_inttp = i_inttp.

endform.                    "feldtab_fuellen

*eject
*----------------------------------------------------------------------*
*        FORM  FELDLISTE_AUSGEBEN                                      *
*----------------------------------------------------------------------*
*        Ausgabe der Feldnamen auf einem Listdynpro                    *
*----------------------------------------------------------------------*
form feldliste_ausgeben.

*------- Liste mit technischen Namen -----------------------------------
  if i_xtech <> space.
    pos = laenge_fname + 2.
    loop at feldtab.
      format color col_key intensified.
      write: at /(laenge_fname) feldtab-fname no-gap, sy-vline no-gap.
      format color col_normal intensified off.
      write: at pos(laenge_ftext) feldtab-ftext.
      hide: feldtab-fname, feldtab-ftext, feldtab-dleng,
            feldtab-outpl, feldtab-inttp, feldtab-intln.
    endloop.

*------- Liste ohne technische Namen -----------------------------------
  else.
    format color col_normal intensified off.
    loop at feldtab.
      write: at (breite_popup) feldtab-ftext.
      hide: feldtab-fname, feldtab-ftext, feldtab-dleng,
            feldtab-outpl, feldtab-inttp, feldtab-intln.
    endloop.
  endif.
  scroll list to page 1 line index.
  set cursor 2 3.

endform.                    "feldliste_ausgeben

*eject
*----------------------------------------------------------------------*
*        FORM  FLDTAB_EINTRAGEN                                        *
*----------------------------------------------------------------------*
*        Eintrag in FLDTAB für HELP_VALUES_GET_WITH_TABLE              *
*----------------------------------------------------------------------*
form fldtab_eintragen using
            f01_tabname    like help_value-tabname
            f01_fieldname  like help_value-fieldname
            f01_selectflag like help_value-selectflag.
  clear fldtab.
  fldtab-tabname    = f01_tabname.
  fldtab-fieldname  = f01_fieldname.
  fldtab-selectflag = f01_selectflag.
  append fldtab.
endform.                    "fldtab_eintragen

*eject
*----------------------------------------------------------------------*
*        FORM  SKAT_LESEN                                              *
*----------------------------------------------------------------------*
*        Sachkontenlangtext bzw. -kurztext aus SKAT lesen              *
*----------------------------------------------------------------------*
*   <--  TEXT                                                          *
*----------------------------------------------------------------------*
form skat_lesen using
     text like skat-txt50.

  clear text.
  select single * from skat
         where spras = sy-langu
         and   ktopl = t001-ktopl
         and   saknr = skb1-saknr.
  check sy-subrc = 0.
  if not skat-txt50 is initial.
    text = skat-txt50.
  else.
    text = skat-txt20.
  endif.

endform.                    "skat_lesen

*eject
*----------------------------------------------------------------------*
*        FORM  SUCHEN                                                  *
*----------------------------------------------------------------------*
*        Suchen eines Feldnamens bzw. einer Feldbezeichnung in der     *
*        F4-Liste                                                      *
*----------------------------------------------------------------------*
form suchen.

  data:  refe           type i,        " Rechenfeld
         startx         like sy-cucol, " X-Koordiante für Popup
         starty         like sy-curow. " Y-Koordinate für Popup

*------- Koordinaten für Such-Popup bestimmen --------------------------
  refe = 28 - breite_popup / 2.
  if refe < x1.
    startx = x1 - refe.
  else.
    startx = 1.
  endif.
  refe = y1 - 1 + ( y2 - y1 ) / 2.
  if  refe > 0
  and refe <= srows.
    starty = refe.
  else.
    starty = 1.
  endif.

*------- Startindex für Listausgabe merken -----------------------------
  old_index = sy-staro.

*------- Such-Popup senden ---------------------------------------------
  clear: rfcu1-fname, rfcu1-feldt.
  call screen 1000
       starting at startx starty.

*------- eingegebenen Suchstring verarbeiten ---------------------------
  if not rfcu1-fname is initial
  or not rfcu1-feldt is initial.
    index = 0.
    perform suchen_in_feldtab using index.
    if index > 0.
      scroll list to page 1 line index.
    else.
      clear: rfcu1-fname, rfcu1-feldt.
      message i407.
      scroll list to page 1 line old_index.
    endif.
    set cursor 2 3.

*------- Suche abgebrochen ---------------------------------------------
  else.
    scroll list to page 1 line old_index.
    set cursor 2 3.
  endif.

endform.                    "suchen

*eject
*----------------------------------------------------------------------*
*        FORM  SUCHEN_IN_FELDTAB                                       *
*----------------------------------------------------------------------*
*        Feldname/Feldbezeichnung in FELDTAB ab der Zeile INDEX + 1    *
*        suchen (erster Treffer zieht)                                 *
*----------------------------------------------------------------------*
*  <-->  INDEX                                                         *
*----------------------------------------------------------------------*
form suchen_in_feldtab using index like sy-tabix.

  data:  ab_index  like sy-tabix.      " Index, ab dem gesucht wird

  translate rfcu1-fname to upper case.                   "#EC TRANSLANG
  ab_index = index + 1.
  loop at feldtab from ab_index.

*------- Feldname und Feldtext als Suchstring vorgegeben ---------------
    if  not rfcu1-fname is initial
    and not rfcu1-feldt is initial.
      if rfcu1-fname ca '*+'.
        check feldtab-fname cp rfcu1-fname.
      else.
        check feldtab-fname cs rfcu1-fname.
      endif.
      if rfcu1-feldt ca '*+'.
        check feldtab-ftext cp rfcu1-feldt.
      else.
        check feldtab-ftext cs rfcu1-feldt.
      endif.
      index = sy-tabix.
      exit.

*------- nur Feldname als Suchstring vorgegeben ------------------------
    elseif not rfcu1-fname is initial.
      if rfcu1-fname ca '*+'.
        check feldtab-fname cp rfcu1-fname.
      else.
        check feldtab-fname cs rfcu1-fname.
      endif.
      index = sy-tabix.
      exit.

*------- nur Feldbezeichnung als Suchstring vorgegeben -----------------
    elseif not rfcu1-feldt is initial.
      if rfcu1-feldt ca '*+'.
        check feldtab-ftext cp rfcu1-feldt.
      else.
        check feldtab-ftext cs rfcu1-feldt.
      endif.
      index = sy-tabix.
      exit.
    endif.
  endloop.

endform.                    "suchen_in_feldtab

*eject
*---------------------------------------------------------------------*
*       FORM TEXT_AUS_050T                                            *
*---------------------------------------------------------------------*
*       Aus der Tabelle T050T wird der gewünschte Text bereitgestellt *
*---------------------------------------------------------------------*
*  ---> T01_TXTNR  Textnummer des zu lesenden Textes                  *
* <---  T01_ZFELD  Zielfeld für den gelesenen Text                    *
*---------------------------------------------------------------------*
form text_aus_050t using t01_txtnr t01_zfeld.
  select single * from  t050t
                  where spras = sy-langu
                  and   msgid = 'RF'
                  and   txtnr = t01_txtnr.
  if sy-subrc = 0.
    t01_zfeld = t050t-ltext.
  else.
    t01_zfeld = space.
  endif.
endform.                    "text_aus_050t

*eject
*----------------------------------------------------------------------*
*        FORM  TABTABS_VERGLEICHEN                                     *
*----------------------------------------------------------------------*
*        Tabelle TABTAB und OLD_TABTAB vergleichen                     *
*----------------------------------------------------------------------*
*   <--  SUBRC  Return-Code; '0' bei Gleichheit, '4' bei Ungleichheit  *
*----------------------------------------------------------------------*
form tabtabs_vergleichen using subrc like sy-subrc.

  data:  anz1      like sy-tfill,
         anz2      like sy-tfill.

  subrc = 0.
  describe table tabtab     lines anz1.
  describe table old_tabtab lines anz2.

*------- Anzahl Zeilen verschieden ==> Tabellen verschieden ------------
  if anz1 <> anz2.
    subrc = 4.
  else.

*------- Anzahl Zeilen gleich ==> prüfen, ob Einträge gleich -----------
*        Voraussetzung: EXCTAB enthält keinen Eintrag mehrfach
    loop at tabtab.
      loop at old_tabtab
           where tbnam = tabtab-tbnam.
        exit.
      endloop.
      if sy-subrc <> 0.
        subrc = 4.
        exit.
      endif.
    endloop.
  endif.

endform.                    "tabtabs_vergleichen

*eject
*----------------------------------------------------------------------*
*        FORM  TEXT_AUFBAUEN                                           *
*----------------------------------------------------------------------*
*        Textzeile zur Beschreibung der Zahlungsbedingung bzw. Rate    *
*        zusammensetzen und in ZBTXT stellen;                          *
*        Da die Beschreibung erst am Ende komprimiert wird, wird       *
*        diese zunächst in das Feld CHAR gestellt                      *
*----------------------------------------------------------------------*
*   -->  TEXT_PROZ, TEXT_TAGE, TEXT_ZMONA, TEXT_FTAG                   *
*  <-->  TEXT                                                          *
*----------------------------------------------------------------------*
form text_aufbauen using
     text_proz  like xt052-zprz1
     text_tage  like xt052-ztag1
     text_zmona like xt052-zsmn1
     text_ftag  like xt052-zstg1
     text       like zbtxt-ztext.

  clear char.

*------- Frist ---------------------------------------------------------

*------- ... Anzahl Tage -----------------------------------------------
  if text_tage > 0.
    if text_tage > 1.
      char = text-007.
    else.
      char = text-024.
    endif.
    refe = text_tage.
    char7 = refe.
    replace '&1' with char7 into char.

*------- ... feste Tage plus evtl. Zuschlagsmonate ---------------------
  else.

*------- ...... feste Tage > 0 -----------------------------------------
    if text_ftag > 0.
      if text_zmona = 0.
        char = text-008.
      elseif text_zmona = 1.
        char = text-009.
      elseif text_zmona > 1.
        char = text-010.
        refe = text_zmona.
        char7 = refe.
        replace '&2' with char7 into char.
      endif.
      refe = text_ftag.
      write refe to char7(3).
      while char7+2(1) = space.
        shift char7 right.
      endwhile.
      if refe  > 30.
        search char for '&1.'.
        if sy-subrc = 0.
          replace '&1.' with text-026 into char.
        else.
          replace '&1' with text-026 into char.
        endif.
      else.
        replace '&1' with char7(3) into char.
      endif.

*------- ...... feste Tage = 0 -----------------------------------------
    else.
      if  xt052-ztag2 = 0
      and xt052-zstg2 = 0.
        char = text-004.
      else.
        char = text-011.
      endif.
    endif.
  endif.

*------- Prozentsatz ---------------------------------------------------
  offset = strlen( char ).
  offset = offset + 1.

*------- ... Prozentsatz > 0 -------------------------------------------
  if text_proz > 0.
    char+offset = text-006.
    write text_proz to char7.
    while char7+6(1) co ' 0'.
      shift char7 right.
    endwhile.
    if char7+6(1) < '0'
    or char7+6(1) > '9'.
      char7+6(1) = space.
    endif.
    replace '&1' with char7 into char.
  else.
    char+offset = text-005.
  endif.
  condense char.
  if xt052-ztagg <> 0.
    shift char right by 2 places.
  endif.
  if not *t052 is initial.
    shift char right by 2 places.
  endif.
  text = char.
  append zbtxt.

endform.                    "text_aufbauen

*eject
*----------------------------------------------------------------------*
*        FORM  TEXT_ZTERM_OHNE_RATE                                    *
*----------------------------------------------------------------------*
*        Beschreibung der Fälligkeit bei Zahlungsbedingungen ohne      *
*        Ratenzahlung aus den Angaben in XT052 ermitteln               *
*----------------------------------------------------------------------*
*  <-->  TEXT                                                          *
*----------------------------------------------------------------------*
form text_zterm_ohne_rate using
     text like zbtxt-ztext.

  clear text.

*------- Text zur Taggrenze --------------------------------------------
  if not xt052-ztagg is initial.
    Case I_koart.                                                "821886
    When 'D'.                                                    "821886
       Text = text-112.                                          "821886
    When others.                                                 "821886
       text = text-012.
    Endcase.                                                     "821886
    if xt052-ztagg > 30.
      search text for '&1.'.
      if sy-subrc = 0.
        replace '&1.' with text-026 into text.
      else.
        replace '&1' with text-026 into text.
      endif.
    else.
      replace '&1' with xt052-ztagg into text.
    endif.
    if not *t052 is initial.
      shift text right by 2 places.
    endif.
    append zbtxt.
  endif.

*------- Text zur Fälligkeit -------------------------------------------
  perform faelligkeit_text_aufbauen using text.

endform.                    "text_zterm_ohne_rate

*eject
*----------------------------------------------------------------------*
*        FORM  WTAB_KOART                                              *
*----------------------------------------------------------------------*
*        WHERE-Bedingung für KOART in WTAB stellen                     *
*----------------------------------------------------------------------*
form wtab_koart.

  concatenate ' ( KOART = '' ''' ' OR KOART = ''' i_koart ''' )'
              into wtab.

endform.                    "wtab_koart

*eject
*----------------------------------------------------------------------*
*        FORM  WTAB_XSPLT                                              *
*----------------------------------------------------------------------*
*        WHERE-Bedingung für XSPLT in WTAB stellen                     *
*----------------------------------------------------------------------*
form wtab_xsplt.

  case i_ztype.
    when 'R'.
      wtab = ' XSPLT = ''X'''.
    when 'N'.
      wtab = ' XSPLT = '' '''.
  endcase.

endform.                    "wtab_xsplt

*eject
*----------------------------------------------------------------------*
*        FORM  XT052_FUELLEN                                           *
*----------------------------------------------------------------------*
*        Tabelle XT052 füllen                                          *
*----------------------------------------------------------------------*
form xt052_fuellen.

*------- Einzelfelder --------------------------------------------------
  data:  and(3) type c value 'AND'.

*------- Initialisierung -----------------------------------------------
  refresh: wtab, xt052.
  clear:   wtab, xt052.

*------- WTAB füllen bei generischem F4 --------------------------------
  if i_zterm ca '*+'.
    translate i_zterm using '*%'.
    translate i_zterm using '+_'.
    concatenate 'ZTERM LIKE ''' i_zterm '''' into wtab.
    append wtab.
    if i_koart ca 'DK'.
      perform wtab_koart.
      concatenate and wtab into wtab.
      append wtab.
    endif.
    if i_ztype <> space.
      perform wtab_xsplt.
      concatenate and wtab into wtab.
      append wtab.
    endif.

*------- WTAB füllen bei "normalem" F4 ---------------------------------
  else.
    if i_koart ca 'DK'.
      perform wtab_koart.
      append wtab.
      if i_ztype <> space.
        perform wtab_xsplt.
        concatenate and wtab into wtab.
        append wtab.
      endif.
    elseif i_ztype <> space.
      perform wtab_xsplt.
      append wtab.
    endif.
  endif.

*------- XT052 füllen --------------------------------------------------
  select * from t052 into table xt052
         where (wtab).

endform.                    "xt052_fuellen

*eject
*----------------------------------------------------------------------*
*        FORM  ZBTXT_FUELLEN                                           *
*----------------------------------------------------------------------*
*        Beschreibung der Zahlungsbedingungen aus T052U oder aus den   *
*        Angaben in T052 ermitteln und in Tabelle ZBTXT stellen        *
*----------------------------------------------------------------------*
form zbtxt_fuellen.

  data:  xt052u(1) type c.             " Kennz.: Text aus T052U?

  refresh zbtxt.
  loop at xt052.
    clear: zbtxt, xt052u.
    zbtxt-zterm = xt052-zterm.

*------- Beschreibung aus T052U ----------------------------------------
    select single * from t052u
           where spras = sy-langu
           and   zterm = xt052-zterm
           and   ztagg = xt052-ztagg.
    if  sy-subrc = 0
    and not t052u-text1 is initial.
      zbtxt-ztext = t052u-text1.
      append zbtxt.
      xt052u = 'X'.
    endif.

*------- Beschreibung aus Einträgen in T052 ermitteln ------------------
    if xt052u = space.
      perform ztext_ermitteln using zbtxt-ztext.
    endif.
  endloop.

endform.                    "zbtxt_fuellen

*eject
*----------------------------------------------------------------------*
*        FORM  ZBTXT_FUELLEN_PRINT                                     *
*----------------------------------------------------------------------*
*        Beschreibung der Zahlungsbedingung aus T052U oder aus den     *
*        Angaben in T052 in Druckaufbereitung ermitteln und in Tabelle *
*        ZBTXT stellen                                                 *
*----------------------------------------------------------------------*
form zbtxt_fuellen_print.

  data:  xt052u(1) type c.             " Kennz.: Text aus T052U?

  refresh zbtxt.
  loop at xt052
       where zterm = i_zterm.
    clear: zbtxt, xt052u.
    zbtxt-zterm = xt052-zterm.

*------- Beschreibung aus T052U, falls gewünscht -----------------------
    if i_xt052u <> space.
      select single * from t052u
             where spras = i_langu
             and   zterm = xt052-zterm
             and   ztagg = xt052-ztagg.
      if  sy-subrc = 0
      and not t052u-text1 is initial.
        zbtxt-ztext = t052u-text1.
        append zbtxt.
        xt052u = 'X'.
* Note 316851: Begin of insertion
* Print user text for installments (day limit not supported)
        if not xt052-xsplt is initial.
*ResQ Comment:Correction not required 24/12/2019 EY_DES02 ECDK917080 *
          select * from t052s
            where zterm = xt052-zterm
            order by primary key.
            select single * from t052u
              where spras = i_langu
                and zterm = t052s-ratzt
                and ztagg = '00'.
            if sy-subrc = 0 and not t052u-text1 is initial.
              zbtxt-ztext = t052u-text1.
              append zbtxt.
            endif.
          endselect.
        endif.
* Note 316851: End of insertion
      endif.
    endif.

*------- Beschreibung aus XT052 ermitteln ------------------------------
    check xt052u = space.
    perform ztext_ermitteln_print using zbtxt-ztext.
  endloop.

endform.                    "zbtxt_fuellen_print

*eject
*----------------------------------------------------------------------*
*        FORM  ZBTXT_FUELLEN_TEXT                                      *
*----------------------------------------------------------------------*
*        Beschreibung der Zahlungsbedingung aus den Angaben in XT052   *
*        für den View V_T052 ermitteln                                 *
*----------------------------------------------------------------------*
form zbtxt_fuellen_text.

  refresh zbtxt.
  clear zbtxt.

*------- Beschreibung aus XT052 ermitteln ------------------------------
  zbtxt-zterm = xt052-zterm.
  perform ztext_ermitteln_text using zbtxt-ztext.

endform.                    "zbtxt_fuellen_text

*eject
*----------------------------------------------------------------------*
*        FORM  ZFBDT_TEXT_AUFBAUEN                                     *
*----------------------------------------------------------------------*
*        Beschreibung zur Berechnung des Basisdatums aus den Angaben   *
*        in XT052 ermitteln                                            *
*----------------------------------------------------------------------*
*  <-->  TEXT                                                          *
*----------------------------------------------------------------------*
form zfbdt_text_aufbauen using
     text like zbtxt-ztext.

  clear: char, text.

*------- verschobenes Basisdatum ohne festen Tag -----------------------
  if xt052-zfael co ' 0'.
    if xt052-zmona = 1.
      char = text-019.
    elseif xt052-zmona > 1.
      char = text-020.
    endif.

*------- verschobenes Basisdatum mit festem Tag ------------------------
  else.
    if xt052-zmona = 0.
      char = text-016.
    elseif xt052-zmona = 1.
      char = text-017.
    else.
      char = text-018.
    endif.
  endif.

*------- Variablen im Text bei verschobenem Basisdatum ersetzen --------
  check not char is initial.
  char7 = xt052-zfael.
  if char7(1) = '0'.
    char7(1) = ' '.
  endif.
  if xt052-zfael > 30.
    search char for '&1.'.
    if sy-subrc = 0.
      replace '&1.' with text-026 into char.
    else.
      replace '&1' with text-026 into char.
    endif.
  else.
    replace '&1' with char7(2) into char.
  endif.
  char7 = xt052-zmona.
  if char7(1) = '0'.
    char7(1) = ' '.
  endif.
  replace '&2' with char7(2) into char.
  condense char.
  if xt052-ztagg <> 0.
    shift char right by 2 places.
  endif.
  if not *t052 is initial.
    shift char right by 2 places.
  endif.
  zbtxt-ztext = char.
  append zbtxt.

endform.                    "zfbdt_text_aufbauen

*eject
*----------------------------------------------------------------------*
*        FORM  ZTERM_LISTE                                             *
*----------------------------------------------------------------------*
*        Ausgabe der Zahlungsbedingungen und ihrer Beschreibung auf    *
*        einem Listdynpro                                              *
*----------------------------------------------------------------------*
form zterm_liste.

  data:  off(1) type c value 'X'.

  loop at zbtxt.
    new-line.
    at new zterm.
      write: zbtxt-zterm no-gap color col_key intensified.
      translate off using 'X  X'.
    endat.
    write: 5 sy-vline no-gap.
    if off = space.
      write: 6(60) zbtxt-ztext color col_normal intensified.
    else.
      write: 6(60) zbtxt-ztext color col_normal intensified off.
    endif.
    hide: zbtxt-zterm.
  endloop.

  if sy-subrc = 0.                                      "note 0443906
    set cursor line 3.  "values start at line 3 (header)
  endif.

endform.                    "zterm_liste

*eject
*----------------------------------------------------------------------*
*        FORM  ZTEXT_ERMITTELN                                         *
*----------------------------------------------------------------------*
*        Beschreibung der Zahlungsbedingungen aus den Angaben in       *
*        XT052 ermitteln                                               *
*----------------------------------------------------------------------*
*  <-->  TEXT                                                          *
*----------------------------------------------------------------------*
form ztext_ermitteln using
     text like zbtxt-ztext.

*------- Zahlungsbedingung ohne Ratenzahlung ---------------------------
  if xt052-xsplt = space.
    perform text_zterm_ohne_rate using text.

*------- Zahlungsbedingung mit Ratenzahlung ----------------------------
  else.
    clear: char, text.

*------- ... vorläufig Text für 1 Rate setzen und Index merken ---------
    text = text-014.
    append zbtxt.
    index = sy-tabix.

*------- ... einzelne Raten ermitteln ----------------------------------
*ResQ Comment:Correction not required 24/12/2019 EY_DES02 ECDK917080 *
    select * from t052s
           where zterm = xt052-zterm
           order by primary key.
      char = text-015.
      if t052s-ratnr > 9.
        replace '&1' with t052s-ratnr into char.
      else.
        replace '&1' with t052s-ratnr+1(1) into char.
      endif.
      write t052s-ratpz to char7.
      replace '&2' with char7 into char.
      replace '&3' with t052s-ratzt into char.
      condense char.
      text = char.
      append zbtxt.
    endselect.

*------- ... mehr als eine oder keine Rate ==> Text modifizieren ----
    if sy-dbcnt <> 1.
      if sy-dbcnt > 1.
        char = text-013.
        char7 = sy-dbcnt.
        replace '&1' with char7 into char.
        condense char.
      else.
        char = text-025.
      endif.
      read table zbtxt index index.
      zbtxt-ztext = char.
      modify zbtxt index index.
    endif.
  endif.

*------- Beschreibung für Berechnung des Basisdatums -------------------
  perform zfbdt_text_aufbauen using text.

endform.                    "ztext_ermitteln

*eject
*----------------------------------------------------------------------*
*        FORM  ZTEXT_ERMITTELN_PRINT                                   *
*----------------------------------------------------------------------*
*        Beschreibung der Zahlungsbedingungen aus den Angaben in XT052 *
*        in Druckaufbereitung ermitteln                                *
*----------------------------------------------------------------------*
*  <-->  TEXT                                                          *
*----------------------------------------------------------------------*
form ztext_ermitteln_print using
     text like zbtxt-ztext.

  data:  dbcnt like sy-dbcnt.

*------- Zahlungsbedingung ohne Ratenzahlung ---------------------------
  if xt052-xsplt = space.
    perform text_zterm_ohne_rate using text.

*------- Zahlungsbedingung mit Ratenzahlung ----------------------------
  else.
    clear: char, text.

*------- ... vorläufig Text für 1 Rate setzen und Index merken ---------
    text = text-014.
    append zbtxt.
    index = sy-tabix.

*------- ... einzelne Raten ermitteln ----------------------------------
     *t052 = xt052.
    dbcnt = 0.

*ResQ Comment:Correction not required 24/12/2019 EY_DES02 ECDK917080 *
    select * from t052s
           where zterm = *t052-zterm
           order by primary key.
      dbcnt = dbcnt + 1.
      char = text-023.
      if t052s-ratnr > 9.
        replace '&1' with t052s-ratnr into char.
      else.
        replace '&1' with t052s-ratnr+1(1) into char.
      endif.
      write t052s-ratpz to char7.
      replace '&2' with char7 into char.
      condense char.
      text = char.
      append zbtxt.

*------- ...... Beschreibung der Zahlungsbed. aus der Rate -------------
*ResQ Comment:Correction not required 24/12/2019 EY_DES02 ECDK917080 *
      select * from t052 into xt052
             where zterm = t052s-ratzt.
        perform ztext_ermitteln using zbtxt-ztext.
      endselect.
    endselect.
    xt052 = *t052.
    clear *t052.

*------- ... mehr als eine Rate ==> Text modifizieren ------------------
    if dbcnt <> 1.
      if dbcnt > 1.
        char = text-013.
        char7 = dbcnt.
        replace '&1' with char7 into char.
        condense char.
      else.
        char = text-025.
      endif.
      read table zbtxt index index.
      zbtxt-ztext = char.
      modify zbtxt index index.
    endif.
  endif.

*------- Beschreibung für Berechnung des Basisdatums -------------------
  perform zfbdt_text_aufbauen using text.

endform.                    "ztext_ermitteln_print

*eject
*----------------------------------------------------------------------*
*        FORM  ZTEXT_ERMITTELN_TEXT                                    *
*----------------------------------------------------------------------*
*        Beschreibung der Zahlungsbedingungen aus den Angaben in XT052 *
*        für View V_T052 ermitteln (es wird keine Beschreibung der     *
*        Taggrenze ermittelt)
*----------------------------------------------------------------------*
*  <-->  TEXT                                                          *
*----------------------------------------------------------------------*
form ztext_ermitteln_text using
     text like zbtxt-ztext.

*------- Beschreibung für Berechnung des Basisdatums -------------------
  perform zfbdt_text_aufbauen using text.

*------- Zahlungsbedingung ohne Ratenzahlung ---------------------------
  if xt052-xsplt = space.
    perform faelligkeit_text_aufbauen using text.

*------- Zahlungsbedingung mit Ratenzahlung ----------------------------
  else.
    clear: char, text.

*------- ... vorläufig Text für 1 Rate setzen und Index merken ---------
    text = text-014.
    append zbtxt.
    index = sy-tabix.

*------- ... einzelne Raten ermitteln: nur so viele Raten, daß ---------
*            Anzahl Einträge in ZBTXT <> 4, aber alle Raten lesen,
*            da Gesamtzahl benötigt wird
    select * from t052s
           where zterm = xt052-zterm
           order by primary key.
      refe = index + sy-dbcnt.
      check refe <= 4.
      char = text-015.
      if t052s-ratnr > 9.
        replace '&1' with t052s-ratnr into char.
      else.
        replace '&1' with t052s-ratnr+1(1) into char.
      endif.
      write t052s-ratpz to char7.
      replace '&2' with char7 into char.
      replace '&3' with t052s-ratzt into char.
      condense char.
      text = char.
      append zbtxt.
    endselect.

*------- ... mehr als eine oder keine Rate ==> Text modifizieren -------
    if sy-dbcnt <> 1.
      if sy-dbcnt > 1.
        char = text-013.
        char7 = sy-dbcnt.
        replace '&1' with char7 into char.
        condense char.
      else.
        char = text-025.
      endif.
      read table zbtxt index index.
      zbtxt-ztext = char.
      modify zbtxt index index.
    endif.
  endif.

endform.                    "ztext_ermitteln_text
*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDNAMES
*&---------------------------------------------------------------------*
form fill_fieldnames using tabname
                           fieldname.
  fldtab-tabname = tabname.
  fldtab-fieldname = fieldname.
  append fldtab.
endform.                               " FILL_FIELDNAMES
*&---------------------------------------------------------------------*
*&      Form  FILL_MWSTAB
*&---------------------------------------------------------------------*
form fill_mwstab using mwskz.
  mwstab-mwstx = mwskz.
  append mwstab.                                        "Note599866
endform.                               " FILL_MWSTAB

*&---------------------------------------------------------------------*
*&      Form  HELP_VALUES_GET
*&---------------------------------------------------------------------*
form help_values_get using    retfield
                              show
                              dynpfield.
  data:    returntab like ddshretval occurs 0 with header line.
  data:    fieldtab  like dfies      occurs 0 with header line.
  data:    value     like help_info-fldvalue.

*-------------- F4 Baustein verlangt anderes Format --------------------
  loop at fldtab.
    move-corresponding fldtab to fieldtab.
    append fieldtab.
  endloop.
  value = dynpfield.
  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
    exporting
      retfield        = retfield
      value           = value
      display         = show
    tables
      value_tab       = mwstab
      field_tab       = fieldtab
      return_tab      = returntab
    exceptions
      parameter_error = 1
      no_values_found = 2
      others          = 3.

endform.                               " HELP_VALUES_GET
*&---------------------------------------------------------------------*
*&      Form  READ
*&---------------------------------------------------------------------*
form read using fname changing target.
endform.                               " READ
*&---------------------------------------------------------------------*
*&      Form  READ_FROM_SCREEN
*&---------------------------------------------------------------------*
form read_from_screen using    fname
                               loc_shlp type shlp_descr_t
                      changing target rcode.

  rcode = 0.
  read table loc_shlp-interface with key shlpfield = fname
                                into interface_wa.
  if sy-subrc = 0.
    if fname = 'BUDAT' or fname = 'WWERT'.
      call function 'CONVERT_DATE_TO_INTERNAL'
        exporting
          date_external = interface_wa-value
        importing
          date_internal = target
        exceptions
          error_message = 1.
      if  sy-subrc = 1.
        rcode = 1.
        exit.
      endif.

*------------ Umrechnungskurs wird sepatrat versorgt -------------------
    elseif fname = 'KURSF'.
      clear target.
    else.
      target = interface_wa-value.
    endif.
  endif.
endform.                               " READ_FROM_SCREEN
*&---------------------------------------------------------------------*
*&      Form  CONCATENATE
*&---------------------------------------------------------------------*
*       Im FI wird in einer Listbox zusätzlich der Key mit angezeigt
*----------------------------------------------------------------------*
form concatenate using    mwskz        " GLVOR
                 changing text1.
  data: text_in_brackets(60).

*  if GLVOR = 'RFBU'.
  concatenate '(' text1 ')' into text_in_brackets.
  concatenate mwskz text_in_brackets into text1 separated by space.
*  endif.
endform.                               " CONCATENATE

*&---------------------------------------------------------------------*
*&      Form  delete_ajacent
*&      Form created by note 303505
*&      AL0K002732: Unicode-Adjustments
*&---------------------------------------------------------------------*
*       Delete duplicate records in search help for account assignment
*       models.
*----------------------------------------------------------------------*
*      -->P_RECORD_TAB  text
*----------------------------------------------------------------------*
form delete_adjacent tables  p_record_tab structure seahlpres.
  types: begin of f05a_h_komu,
           mandt type mandt,
           kmnam type kmnam_enj,                            "Note 425554
         end of f05a_h_komu.
  data: l_old_kmnam type kmnam_enj.                         "Note 425554
  data: l_h_komu type f05a_h_komu.

  sort p_record_tab by string.
  loop at p_record_tab.
    call method cl_abap_container_utilities=>read_container_c
      exporting
        im_container           = p_record_tab-string
      importing
        ex_value               = l_h_komu
      exceptions
        illegal_parameter_type = 1
        others                 = 2.
    if sy-subrc <> 0.
      continue.
    endif.
    if l_h_komu-kmnam = l_old_kmnam.
      delete p_record_tab.
    else.
      l_old_kmnam = l_h_komu-kmnam.
    endif.
  endloop.
endform.                               " delete_adjacent
