*&---------------------------------------------------------------------*
*& Report  razuga_ALV01                                                *
*&         mit ALV Unterstützung                                       *
*&---------------------------------------------------------------------*
*&                                                                     *
*&                                                                     *
*&---------------------------------------------------------------------*

REPORT razuga_alv01 MESSAGE-ID ab
                    LINE-SIZE 132
                    NO STANDARD PAGE HEADING.

NODES: anla0,
       anlav,
       anlb,
       anek,
       anepv.

TABLES: anlh,
  bkpf,
  ekkn,
  ekko,
  ekpo,
  eban,
  ekbe,
  lfa1.

TABLES: tabw, tabwg, tabwt.

TYPE-POOLS:  slis.

DATA: itab_keyinfo      TYPE slis_keyinfo_alv.
* Arbeitsversion Tabelle TABW.
DATA: BEGIN OF xabw OCCURS 200,
        bwasl  LIKE tabw-bwasl,
        bwagrp LIKE tabw-bwagrp,
        anshkz LIKE tabw-anshkz,
        bwaslg LIKE tabw-bwaslg,
      END OF xabw.

DATA : netpr(12)  TYPE c.
DATA : netwr(12)  TYPE c.
DATA : wkurs(12)  TYPE c.



* Arbeitsversion Tabelle TABWG.
DATA: BEGIN OF xabwg OCCURS 100.
        INCLUDE STRUCTURE tabwg.
DATA: END OF xabwg.

* Arbeitsversion Tabelle TABWT.
DATA: BEGIN OF xabwt OCCURS 200,
        bwasl  LIKE tabwt-bwasl,
        bwatxt LIKE tabwt-bwatxt,
      END OF xabwt.


* Merkleiste fuer ANLAV.
DATA: BEGIN OF hlp_anlav.
        INCLUDE STRUCTURE anlav.
DATA: END OF hlp_anlav.
* Merkleiste fuer ANLAV.
DATA: BEGIN OF hlp_anlb.
        INCLUDE STRUCTURE anlb.
DATA: END OF hlp_anlb.
* erlaubte Bewegungsarten
RANGES: r_sel_bwasl FOR tabw-bwasl.
* FIELDS-Anweisungen.
* Allgemeine DATA-, TABLES-, ... Anweisungen.
INCLUDE z_rasort_alv04.
*INCLUDE rasort_alv04.
INCLUDE z_rasort_alv_data_fieldcat.
*INCLUDE rasort_alv_data_fieldcat.

FIELD-GROUPS: header, daten, posten.

* Globale Steuerungsparameter.
DATA:
*     Anzahl der im Anforderungsbild erlaubten AfA-Bereiche.
      sav_anzbe(1) TYPE c VALUE '1',
*     Flag: Postenausgabe Ja='1'/Nein='0'.
      flg_postx(1) TYPE c VALUE '1',
*     Summenbericht: Maximale Anzahl Wertfelder/Zeile.
      con_wrtzl(2) TYPE p VALUE 3.
*     ALV: output or hidden field
DATA: flg_hidden TYPE boolean.                              "> 1082238

* Hilfsgroessen.
DATA:
*     Hilfsfeld: Anzahl Posten je Anlage.
      hlp_epost(3) TYPE p,
*     Hilfsfeld: Summe Zugangsbetrag je Anlage.
      hlp_anbtr LIKE anepv-anbtr.

* Hilfsfelder fuer EXTRACT.
DATA:
*     Zaehler: Anzahl Posten je Anlage.
      cnt_epost(3) TYPE p.

DATA: observacion_w(30) TYPE c.

TYPES: BEGIN OF post_type,
        bukrs LIKE anepv-bukrs,
        gjahr LIKE anepv-gjahr,
        belnr LIKE anepv-belnr,
        buzei LIKE anepv-buzei,
        bwasl LIKE anepv-bwasl,
        bzdat LIKE anepv-bzdat,
        btr1  LIKE anepv-anbtr,
        btr2  LIKE anepv-nafab,
        btr3  LIKE anepv-safab,
        sgtxt LIKE bseg-sgtxt,
        menge LIKE bseg-menge,
        meins LIKE bseg-meins,
        budat LIKE bkpf-budat,
        xblnr LIKE bkpf-xblnr,
        xantei LIKE anek-xantei,
        fibelnr LIKE anepv-belnr,
        figjahr LIKE anepv-gjahr,
        origin(30) TYPE c,
        bbs_typ LIKE gd_bbs_typ,
        obart   LIKE anek-obart,
        btr4    LIKE anepv-anbtr,
        btr5    LIKE anepv-anbtr,
        kstar   TYPE kstar,
       END OF post_type.
DATA:  post TYPE TABLE OF post_type WITH HEADER LINE.
TYPES: t_post TYPE TABLE OF post_type.


* Felder fuer Summe je Anlage (fuer EXTRTACT).
DATA: BEGIN OF ganl,
        btr1(8) TYPE p,
        btr2(8) TYPE p,
        btr3(8) TYPE p,
      END OF ganl.

* Felder fuer Summe je Anlage (fuer WRITE).
DATA: BEGIN OF sanl,
        btr1(8) TYPE p,
        btr2(8) TYPE p,
        btr3(8) TYPE p,
      END OF sanl.

* Definition der internen Tabelle für den ALV
DATA: itab_data LIKE zfiaa_salvtab_razuga OCCURS 10 WITH HEADER LINE.

* Zweite Tabelle für den ALV (Hierarchie)
DATA: itab_data2 LIKE zfiaa_salvtab_razuga_2 OCCURS 10 WITH HEADER LINE.

* Schlüssel für die Hierarchie

itab_keyinfo-header01 = 'BUKRS'.
itab_keyinfo-item01   = 'BUKRS'.
itab_keyinfo-header02 = 'ANLN0'.
itab_keyinfo-item02   = 'ANLN0'.
itab_keyinfo-header03 = 'ANLN2'.
itab_keyinfo-item03   = 'ANLN2'.
itab_keyinfo-header04 = ''.
itab_keyinfo-item04   = 'BELNR'.

SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-bl0.
PARAMETERS: p_vari TYPE disvariant-variant,
            p_grid TYPE xgrid.
SELECTION-SCREEN END OF BLOCK bl0.

SELECTION-SCREEN BEGIN OF BLOCK bl1                        "AB
                 WITH FRAME                                "AB
                 TITLE text-bl1.                           "AB

SELECT-OPTIONS:
*               Anlagenbestandskonto.
              so_ktanw FOR anlav-ktansw NO DATABASE SELECTION,
*               Aktivierungsdatum.
              so_aktiv FOR anlav-aktiv,
*               Bewegungsart.
              so_bwasl FOR anepv-bwasl ,
*               Buchungsdatum.
              so_budat FOR anek-budat,
*               Bezugsdatum für RAUSMQ10
              so_bzdat FOR anepv-bzdat NO-DISPLAY.

SELECTION-SCREEN END   OF BLOCK bl1.                       "AB
PARAMETERS: pa_orgep LIKE rarep-xorgep NO-DISPLAY .

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK bl4                       "AB
                 WITH FRAME                                "AB
                 TITLE text-c03.                           "AB
PARAMETERS:

*           Zusatzueberschrift.
          pa_titel LIKE rarep-titel DEFAULT space,

          pa_mikro LIKE bhdgd-miffl.
SELECTION-SCREEN END   OF BLOCK bl4.                       "AB


INITIALIZATION.
* Sortiervariante vorschlagen.
  MOVE: '0003' TO srtvr.
* ALV Grid NICHT als Standard vorschlagen (Hierarchie)
  MOVE: ' '    TO p_grid.

* Report wird nicht von außen aufgerufen. Lesen der PickUp-Informationen
* aus dem Memory d.h. der ursprünglich eingegebenen Programmabgrenzungen
  IMPORT flg_not_first FROM MEMORY ID 'flg'.

* Allgemeine Verarbeitung der PA/SO-Eingaben.
  INCLUDE z_rasort_alv08.
*INCLUDE rasort_alv08.

* Process on value request
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM varianten_auswahl CHANGING p_vari.

AT SELECTION-SCREEN OUTPUT.
* Ausblenden des Feldes XUNTNR und des dazugehörigen Textfeldes
  PERFORM felder_ausblenden USING 'XUNTNR' '%F301122_1000'.
  PERFORM felder_ausblenden USING 'SUMMB' '%F301122_1000'.
*---------------------------------------------------------------------*

START-OF-SELECTION.
  PERFORM prepare_select USING 'ZUG'.
* Wenn BWA nicht durch Eingaben eingeschränkt default in Selection
* aufnehmen.
  IF NOT so_bwasl[] IS INITIAL.
    r_sel_bwasl[] =  so_bwasl[] .
  ENDIF.

  PERFORM free_sel_add(sapdbada) TABLES r_sel_bwasl so_budat.
  PERFORM tabwt_select.

* Steuerungskennzeichen für LDB setzen
   *anla0-xepos  = 'X'.
   *anla0-noanlc = 'X'.

* Setzen der UserStrukturen für die log. Datenbank
* (2 Stück - für Header und Item Tabelle)
   *anla0-selfield_structure1 = 'CI_REPRAZUGA'.
   *anla0-selfield_structure2 = ''.




  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


GET anla0.


GET anlav FIELDS aktiv xanlgr txa50 txt50 deakt zugdt ktogr.

  CHECK SELECT-OPTIONS.
* Nur Anlagen seleketieren, die aktiviert wurden ...
  CHECK NOT anlav-zugdt IS INITIAL.
* ... und zwar vor dem Berichtsdatum.
  CHECK     anlav-zugdt LE berdatum.

* ANLAV-Satz sichern fuer EXTRACT nach GET ANLAV LATE.
  MOVE anlav TO hlp_anlav.

* Zaehler Zugaenge je Anlage auf 0 zuruecksetzen.
  cnt_epost = 0.
* Hilfstabelle zur Sammlung der Posten zuruecksetzen.
  CLEAR:  post,ganl.
  REFRESH post.

* Verarbeitungen ON CHANGE OF ANLAV-XXXXX.
  INCLUDE z_rasort14.
*  INCLUDE rasort14.

* Im VJ deaktivierte Anlagen nicht selektieren.
  IF NOT anlav-deakt IS INITIAL.
    CHECK anlav-deakt GE sav_gjbeg.
  ENDIF.

* Information AfA-Bereich fuer Header.
  ON CHANGE OF anlav-bukrs.
*   Individueller Teil des Report-Headers
    WRITE: '-'       TO head-info1,
           bereich1  TO head-info2,
           sav_afbe1 TO head-info3.
*
    CONDENSE head.
  ENDON.


GET anlb FIELDS anln1 ndjar ndper.

  CHECK SELECT-OPTIONS.

* ANLB-Satz sichern fuer EXTRACT nach GET ANLAV LATE.
  MOVE anlb  TO hlp_anlb.

GET anek.

* check select-options.                          "<<< delete note 79859

GET anepv.
  CHECK SELECT-OPTIONS.
* Nur Bewegungen des Jahres des Berichtsdatums durchlassen.
  CHECK anepv-bzdat GE sav_gjbeg.
  PERFORM save_transaction USING 'ZUG'.

GET anlav LATE.

* sind ueberhaupt zugaenge vorhanden?
  IF cnt_epost GT 0.
    PERFORM extract_daten.      " Daten in die Ausgabeliste stellen
  ENDIF.

END-OF-SELECTION.

************************************************************************
* Ausgabe der internen Tabelle mit dem ALV *****************************
************************************************************************
  PERFORM tcollect_fuellen.

*   Output depreciation on line items
*   - Old calculation: in ALV-listing seeable
*   - New calculation: in ALV-listing as hidden field
  IF hlp_old_afar = con_x.                                  "> 1082238
    flg_hidden = output_on.                                 "> 1082238
  ELSE.                                                     "> 1082238
    flg_hidden = output_off.                                "> 1082238
  ENDIF.                                                    "> 1082238


  PERFORM init_fieldcat.              " normaler Bericht
  PERFORM alv_sub_sort.               " Sortierung für Hierarchie
* Hierarchie nur bei NICHT-Summenbereichten
  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program       = 'Z_RAZUGA_ALV01'
      i_callback_pf_status_set = 'SET_PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      it_fieldcat              = itab_fieldcat
      it_sort                  = t_subsort
      i_save                   = 'A'
      i_tabname_header         = 'ITAB_DATA'
      i_tabname_item           = 'ITAB_DATA2'
      is_keyinfo               = itab_keyinfo
    TABLES
      t_outtab_header          = itab_data[]
      t_outtab_item            = itab_data2[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.


  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.




* CALL FUNCTION 'FIAA_ALV_DISPLAY'
*  EXPORTING
*    hierarchical   = 'X'
*    use_alv_grid   = p_grid
*    variante       = p_vari
*    expand         = 'X'
*    tabname_header = 'ITAB_DATA'
*    tabname_item   = 'ITAB_DATA2'
*    summen_bericht = summb
*    x_t086         = t086
*    tcollect       = tcollect
*  TABLES
*    itab_header    = itab_data[]
*    itab_item      = itab_data2[]
*    bukrs          = bukrs[]
*    sortfeld       = feld[]
*    itab_subsort   = t_subsort[]
*    itab_errors    = gt_anfm[].                             "> 1002552

*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM INIT_FIELDCAT                                            *
*---------------------------------------------------------------------*
*       Feldkatalog für den ABAP Listviewer aufbauen.                 *
*       Dies ist der Default-Feldkatalog, der in der Auslieferung     *
*       vorgegeben wird. Das Aussehen kann speziell mit den Anzeige-  *
*       varianten angepasst werden. Welche Felder überhaupt zur       *
*       Verfügung stehen, _muss_ hier definiert werden.               *
*---------------------------------------------------------------------*
FORM init_fieldcat.

* Es wird nicht mehr der Standard Feldkatalog für die internen
* Tabellen benutzt, sondern dieser selbst aufgebaut!

**********
* S1 bis S5 entsprechen der Sortiervariante. _Immer_ mitnehmen!
*
*  PERFORM fieldcat_s_fields_define USING 'ITAB_DATA'.
*
*
**********


  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'ANLN0'.
  x_fieldcat-tabname       = 'ITAB_DATA'.
  x_fieldcat-ref_tabname   = 'ANLAV'.

  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'ANLN2'.
  x_fieldcat-tabname       = 'ITAB_DATA'.
  x_fieldcat-ref_tabname   = 'ANLAV'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'AKTIV'.
  x_fieldcat-tabname       = 'ITAB_DATA'.
  x_fieldcat-ref_tabname   = 'ANLAV'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'TXT50'.
  x_fieldcat-tabname       = 'ITAB_DATA'.
  x_fieldcat-ref_tabname   = 'ANLAV'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BTR1'.
  x_fieldcat-tabname       = 'ITAB_DATA'.
  x_fieldcat-ref_tabname   = ''.
  x_fieldcat-cfieldname  =  'WAERS'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'WAERS'.
  x_fieldcat-tabname       = 'ITAB_DATA'.
  x_fieldcat-ref_tabname   = 'T093B'.
  APPEND x_fieldcat TO itab_fieldcat.


  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BELNR'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'ANEPV'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BUDAT'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'BKPF'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BWASL'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'ANEPV'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BZDAT'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'ANEPV'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'XBLNR'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'BKPF'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'MENGE'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'BSEG'.
  x_fieldcat-qfieldname    = 'MEINS'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'MEINS'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'BSEG'.
  APPEND x_fieldcat TO itab_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BTR1'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = ''.
  x_fieldcat-cfieldname  =  'WAERS'.
  APPEND x_fieldcat TO itab_fieldcat.
  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'WAERS'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'T093B'.
  APPEND x_fieldcat TO itab_fieldcat.

* \2

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'SGTXT'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'BSEG'.
  APPEND x_fieldcat TO itab_fieldcat.

*

*  PERFORM fieldcat_user_fields_append USING *anla0-selfield_structure1
*                                            'ITAB_DATA'.
* PERFORM fieldcat_user_fields_append USING *anla0-selfield_structure2
*                                            'ITAB_DATA2'.

ENDFORM.                    "init_fieldcat

*---------------------------------------------------------------------*
*       FORM INIT_FIELDCAT_SUM                                        *
*---------------------------------------------------------------------*
*       Feldkatalog für Gruppensummen definieren                      *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ALV_SUB_SORT
*&---------------------------------------------------------------------*
*       Festlegen der Sortierung innerhalb der Unterliste
*----------------------------------------------------------------------*
FORM alv_sub_sort.
  DATA: x_sort LIKE LINE OF t_subsort.

  REFRESH t_subsort.
  CLEAR x_sort.
  x_sort-spos = 1.
* Feldname in der internen Ausgabetabelle (Hier: S1, S2, ...)
  x_sort-fieldname = 'BELNR'.
  x_sort-tabname = 'ITAB_DATA2'.
  x_sort-up = 'X'.
  APPEND x_sort TO t_subsort.
ENDFORM.                               " ALV_SUB_SORT


*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
 rs_selfield TYPE slis_selfield.
  DATA: li_count TYPE i.
  IF r_ucomm EQ 'GRABAR'.
    PERFORM graba.
  ENDIF.
ENDFORM. "User_command

*****************************************
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STATUS01' EXCLUDING rt_extab.
ENDFORM. "Set_pf_status


*&---------------------------------------------------------------------*
*&      Form  graba
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM graba.
  DATA: BEGIN OF uno,
          btr1(15) TYPE p,
          btr2(15) TYPE p,
          btr3(15) TYPE p,
        END OF uno.
  DATA: BEGIN OF dos,
    btr1(15) TYPE p,
    btr2(15) TYPE p,
    btr3(15) TYPE p,
  END OF dos.

  DATA: ano(4)    TYPE n,
        canrep LIKE ekbe-menge,
        dato(2).

  EXEC SQL.
    connect to 'SAPCSC' as 'con'
  ENDEXEC.

  EXEC SQL.
    set connection 'con'
  ENDEXEC.


  EXEC SQL.
    delete from  REPORTE_ALTA_AF_OCOMPRA
  ENDEXEC.
  LOOP AT itab_data.

    LOOP AT itab_data2 WHERE bukrs = itab_data-bukrs
                       AND   anln0 = itab_data-anln0
                       AND   anln1 = itab_data-anln1
                       AND   anln2 = itab_data-anln2.

      uno-btr1 = itab_data-btr1.
      dos-btr1 = itab_data2-btr1 .

      ano =  itab_data2-budat+0(4).

      CLEAR observacion_w.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM  bkpf  WHERE bukrs = itab_data-bukrs
*                                  AND   belnr = itab_data2-belnr
*                                  AND   gjahr = ano.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM  bkpf  WHERE bukrs = itab_data-bukrs
                                  AND   belnr = itab_data2-belnr
                                  AND   gjahr = ano ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF bkpf-dbblg <> '   '.
        CONCATENATE 'ANUL. ' bkpf-dbblg INTO observacion_w.
      ENDIF.

      CLEAR lfa1-stcd1.
      CLEAR lfa1-lifnr.
      CLEAR lfa1-name1.
      CLEAR dato.
      CLEAR ekko-ebeln.
      CLEAR ekko-bedat.
      CLEAR ekpo-ebelp.
      CLEAR ekpo-menge.
      CLEAR canrep.
      CLEAR ekpo-netpr.
      CLEAR ekpo-netwr.
      CLEAR ekko-waers.
      CLEAR ekko-wkurs.
      CLEAR ekpo-banfn.
      CLEAR eban-badat.
      CLEAR ekpo-bnfpo.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM ekkn WHERE anln1 = itab_data-anln1
*                         AND       anln2 = itab_data-anln2.
*
* NEW CODE
      SELECT *
 FROM ekkn WHERE anln1 = itab_data-anln1
                         AND       anln2 = itab_data-anln2 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

        WRITE ekko-wkurs   TO wkurs CURRENCY ekko-waers.
        TRANSLATE wkurs USING '. ' .
        CONDENSE  wkurs NO-GAPS    .


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE  * FROM ekko WHERE ebeln = ekkn-ebeln
*                                   AND   bukrs = itab_data-bukrs.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM ekko WHERE ebeln = ekkn-ebeln
                                   AND   bukrs = itab_data-bukrs ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM ekpo WHERE ebeln = ekkn-ebeln
*                                    AND   ebelp = ekkn-ebelp.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM ekpo WHERE ebeln = ekkn-ebeln
                                    AND   ebelp = ekkn-ebelp ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


          WRITE ekpo-netpr  TO  netpr CURRENCY ekko-waers.
          TRANSLATE netpr USING '. ' .
          CONDENSE  netpr NO-GAPS    .

          WRITE ekpo-netwr  TO  netwr CURRENCY ekko-waers.
          TRANSLATE netwr USING '. ' .
          CONDENSE  netwr NO-GAPS    .


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE  * FROM eban  WHERE banfn = ekpo-banfn
*                                      AND   bnfpo = ekpo-bnfpo.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM eban  WHERE banfn = ekpo-banfn
                                      AND   bnfpo = ekpo-bnfpo ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM lfa1 WHERE lifnr = ekko-lifnr.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM lfa1 WHERE lifnr = ekko-lifnr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


          SELECT SUM( menge ) FROM ekbe INTO canrep   WHERE ebeln  = ekkn-ebeln
                                    AND  ebelp = ekkn-ebelp
                                    AND vgabe = '1'.
        ELSE.
          CONCATENATE observacion_w ' S/ORDEN Comp.' INTO observacion_w.
        ENDIF.


        EXEC SQL.
          INSERT  into  reporte_alta_af_ocompra (sociedad,
          activo,
          subnumero,
          clae_activo,
          descripcion,
          marca,
          modelo,
          division,
          cta_mayor,
          area_valoracion,
          centro_costo,
          numero_serie,
          nro_inventario,
          costo_adqui,
          cantidad_activo,
          unidad_medida,
          fecha_capita,
          fecha_alta,
          numero_cbte,
          ano_cbte,
          fecha_cbte,
          poscicion_cbte,
          monto_contab,
          moneda_cbte,
          numero_factura,
          fecha_factura,
          rut_prov_cbte,
          cod_prov_cbte,
          nom_prov_cbte,
          producto_ctble,
          orden_compra,
          fecha_ocompra,
          posicion_oc,
          cantidad_solici,
          cantidad_recep,
          prec_uneto_oc,
          total_neto_oc,
          moneda_oc,
          tpo_cambio_oc,
          nro_pedido,
          fec_pedido,
          poscicion_ped,
          vutilano_original_activo,
          vutilmes_original_activo
          )
          values(:itab_data-bukrs,
          :itab_data-anln1,
          :itab_data-anln2,
          :itab_data-ANLKL,
          :itab_data-TXT50,
          :itab_data-TXa50,
          :itab_data-ANLHTXT,
          :itab_data-GSBER,
          :itab_data-KTANSW,
          :itab_data-AFABE,
          :itab_data-KOSTL,
          :itab_data-SERNR,
          :itab_data-INVNR,
          :uno-BTR1,
          :itab_data-MENGE,
          :itab_data-MEINS,
          :itab_data-AKTIV,
          :itab_data2-BZDAT,
          :itab_data2-BELNR,
          :ano,
          :itab_data2-BUDAT,
          :itab_data2-BUZEI,
          :dos-BTR1,
          :itab_data2-WAERS,
          :itab_data2-XBLNR,
          :BKPF-BLDAT,
          :lfa1-STCD1,
          :lfa1-lifnr,
          :lfa1-NAME1,
          :dato,
          :ekko-ebeln,
          :ekko-BEDAT,
          :ekpo-ebelp,
          :ekpo-MENGE,
          :canrep,
          :nETPR,
          :NETWR,
          :ekko-waers,
          :wkurs,
          :ekpo-banfn,
          :eban-BADAT,
          :ekpo-bnfpo,
          :itab_data-NDJAR,
          :itab_data-NDPER)
        ENDEXEC.
      ENDSELECT.
    ENDLOOP.
  ENDLOOP.



  EXEC SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.

ENDFORM.                    "graba








INCLUDE z_rapool_alv01.
INCLUDE z_rapool_alv03.
INCLUDE z_rasort_alv_misc.
INCLUDE z_rasort_alv_prepare_table.
INCLUDE z_rasort_alv_tools.
