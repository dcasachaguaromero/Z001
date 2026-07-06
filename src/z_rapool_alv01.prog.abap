***INCLUDE RAPOOL_ALV01.
INCLUDE rapool_alv02.
*---------------------------------------------------------------------*
*       FORM PREPARE_SELECT                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM prepare_select USING value(v_listtyp).

* Sichern der Selektionsoptionen bzw. Einlesen der Sortierwerte bei
* PickUp.
  PERFORM info_pick_up.

*

* Bestimmung der Sortierfelder fuer Posten (je Anlage).
  ASSIGN post-belnr TO <p>.
  ASSIGN post-bwasl TO <q>.

* Allgemeines Coding nach START-OF-SELECTION. Aufbau des HEADERs.
  INCLUDE z_rasort_alv10.


  PERFORM bwasl_select TABLES r_sel_bwasl
                       USING v_listtyp.

ENDFORM.                    "PREPARE_SELECT
*
FORM tabwt_select.
* Arbeitstabelle XABWT aus TABWT fuellen.
  CLEAR xabwt.
  REFRESH xabwt.
  SELECT * FROM tabwt
    WHERE spras EQ sy-langu
      AND bwasl IN r_sel_bwasl ORDER BY PRIMARY KEY.
    MOVE-CORRESPONDING tabwt TO xabwt.
    COLLECT xabwt.
  ENDSELECT.
ENDFORM.                    "TABWT_SELECT

*---------------------------------------------------------------------*
*       FORM SAVE_TRANSACTION                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(V_LISTTYP)                                              *
*---------------------------------------------------------------------*
FORM save_transaction USING value(v_listtyp).

  DATA: lt_orgpost TYPE t_post.
  DATA: ld_hktyp(10) TYPE c,
        ld_hkobj(24) TYPE c.

* Nur gewünschte Bewegungen durch lassen
  CHECK anepv-bwasl IN r_sel_bwasl.
  CLEAR post.
* Felder an Tabelle fuer EXTRACT uebergeben.
  MOVE: anek-budat  TO post-budat,
        anek-xblnr  TO post-xblnr,
        anek-sgtxt  TO post-sgtxt,
        anek-menge  TO post-menge,
        anek-meins  TO post-meins,
        anek-xantei TO post-xantei.
  MOVE: anepv-bukrs TO post-bukrs,
        anepv-gjahr TO post-gjahr,
        anepv-belnr TO post-belnr,
        anepv-buzei TO post-buzei,
        anepv-bwasl TO post-bwasl,
        anepv-bzdat TO post-bzdat.
  CASE v_listtyp.
    WHEN 'ZUG'.
      post-btr1 = anepv-anbtr.
      post-btr2 = anepv-nafab.
      post-btr3 = anepv-safab.
    WHEN 'UMB'.
      post-btr1   = anepv-anbtr  + anepv-aufwv  + anepv-aufwl.
      post-btr2   = anepv-nafav  + anepv-aufnv
                  + anepv-nafal  + anepv-aufnl.
      post-btr3   = anepv-safav  + anepv-safal
                  + anepv-mafav  + anepv-mafal
                  + anepv-aafav  + anepv-aafal.
    WHEN 'ALL'.
      post-btr1   = anepv-anbtr  + anepv-aufwv  + anepv-aufwl.
      post-btr2   = anepv-nafav  + anepv-nafal
                  + anepv-safav  + anepv-safal
                  + anepv-aafav  + anepv-aafal
                  + anepv-mafav  + anepv-mafal
                  + anepv-aufnv  + anepv-aufnl.
      post-btr3   = anepv-nafab  + anepv-safab.
  ENDCASE.
  IF NOT pa_orgep IS INITIAL.
    PERFORM herkunft_ermitteln USING    anek anepv
                             CHANGING ld_hktyp ld_hkobj "POST-PLAUS
                                      post-bbs_typ.
    CONCATENATE ld_hktyp ld_hkobj
    INTO post-origin SEPARATED BY space.

*      IF  POST-LNSAN IS INITIAL.
    IF anepv-lnsan IS INITIAL.
*        ... dann auch Orginal-Eps der besorgen.
      PERFORM orginalposten_ausgeben
                                     USING     anek anepv
                                     CHANGING  lt_orgpost.
    ENDIF.

  ENDIF.

* Zaehler Zugaenge je Anlage hochzaehlen.
  cnt_epost = cnt_epost + 1.
* Gesamtsummen je Anlage hochzaehlen.
  ADD-CORRESPONDING post TO ganl.

  APPEND post.
  APPEND LINES OF lt_orgpost TO post.
  CLEAR lt_orgpost[].
ENDFORM.                    "SAVE_TRANSACTION

*---------------------------------------------------------------------*
*       FORM EXTRACT_DATEN                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM extract_daten.
* Gesicherten ANLAV-Satz zurueckholen.
  MOVE hlp_anlav TO anlav.
  MOVE hlp_anlb  TO anlb.

  PERFORM store_errors.                                     "> 1002552

* Daten gegen Sortierwerte beim PickUp checken.
  PERFORM sort_check.
* DATEN extrahieren.
* EXTRACT daten.

  PERFORM sort_felder_vorbereiten.

  MOVE-CORRESPONDING anlb TO itab_data.                     "no 456965
  MOVE-CORRESPONDING anlav TO itab_data.
  MOVE-CORRESPONDING ganl  TO itab_data.    " Summen der Einzelposten
*  itab_data-cnt_epost = cnt_epost.         "DEL MM - IMHO nicht nötig
  itab_data-waers = sav_waer1.
* PickUp ist erlaubt
  itab_data-flg_pick_up = 'X'.
* Daten zur Anlage haben Rang '1'.
  itab_data-range = '1'.
* Die Datenzeilen sind immer in der vollen Sortierung
  itab_data-hlp_level = con_srtst.      " == Anzahl Summenstufen

* Bestand für Summenbericht aufbereiten

*   ITAB_DATA nur dann aufbauen, wenn KEIN Summenbericht
  APPEND itab_data.

*   Merktabelle POST der Zugaenge abloopen.
  LOOP AT post.
*     POSTEN extrahieren.
*     mal alles aus der Headertabelle mitnehmen
    MOVE-CORRESPONDING itab_data TO itab_data2.
*     alles aus der POST mitnehmen
    MOVE-CORRESPONDING post TO itab_data2.
    itab_data2-waers = sav_waer1.
*     PickUp ist erlaubt
    itab_data2-flg_pick_up = 'X'.
*     Posten haben Rang '3'.
    itab_data2-range = '3'.

    APPEND itab_data2.
  ENDLOOP.

ENDFORM.                    "EXTRACT_DATEN
