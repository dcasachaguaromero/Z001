*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <26-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&      Form  HERKUNFT_ERMITTELN
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->F_ANEK     text
*      -->F_ANEPV    text
*      -->F_HKTYP    text
*      -->F_HKOBJ    text
*      -->F_BBSTYP   text
*---------------------------------------------------------------------*
FORM HERKUNFT_ERMITTELN USING    F_ANEK  STRUCTURE ANEK
                                 F_ANEPV STRUCTURE ANEPV
                        CHANGING F_HKTYP
                                 F_HKOBJ
*                                 F_PLAUS
                                 F_BBSTYP.

  TABLES: *BSEG.
  CONSTANTS: CON_VORGN_RMWE  LIKE BSEG-VORGN VALUE 'RMWE'.   "NEWRM
  data: ld_plaus type c.


  DATA: BEGIN OF XBSEG OCCURS 10.
          INCLUDE STRUCTURE BSEG.
  DATA: END   OF XBSEG.

  DATA: L_DMBTR_ANL LIKE BSEG-DMBTR,
        L_TABIX     LIKE SY-TABIX,
        L_FOUND(1)  TYPE C VALUE '0',
        L_COUNT     TYPE I.

  DATA: L_OBJNR     LIKE IONRA-OBJNR,                       " Netzplan
        L_IDENT     LIKE SY-MSGV1.                          " Netzplan

  DATA: LD_ANEPV_NEG_ANBTR   LIKE F_ANEPV-ANBTR.            ">400793

  CLEAR F_BBSTYP.


* Reine Anlagenbewegung?
  IF F_ANEK-BELNR IS INITIAL.
    F_HKTYP = TEXT-T09.
    F_HKOBJ = SPACE.
    L_FOUND = ON.
  ENDIF.

* Umbuchung von AiB/Auftrag/Projekt.
  CHECK L_FOUND EQ OFF.
  IF NOT F_ANEK-OBART IS INITIAL.
    CASE F_ANEK-OBART.
*   Umbuchung von AiB ...
      WHEN 'AN'.
*     ... aber keine Vortragsbuchung.
        IF NOT F_ANEK-ANLU1 IS INITIAL.

          F_HKTYP = TEXT-T02.
          WRITE: F_ANEK-ANLU1 TO F_HKOBJ(12),
                 '-'          TO F_HKOBJ+13(1),
                 F_ANEK-ANLU2 TO F_HKOBJ+15(4).
          CONDENSE F_HKOBJ NO-GAPS.
          L_FOUND = ON.
          F_BBSTYP = CON_AIB.
        ENDIF.

*   Abrechnung von Auftrag.
      WHEN 'OR'.
*     Bist du Inv-Maßnahme?
        SELECT COUNT(*) FROM ANLE
          WHERE BUKRS EQ F_ANEK-BUKRS
          AND   ANLN1 EQ F_ANEK-ANLN1
          AND   ANLN2 EQ F_ANEK-ANLN2
          AND   GJAHR EQ F_ANEK-GJAHR
          AND   LNRAN EQ F_ANEK-LNRAN.
*     Ja.
        IF SY-DBCNT > 0.
          F_HKTYP = TEXT-T11.
*     Nein.
        ELSE.
          F_HKTYP = TEXT-T03.
        ENDIF.
        WRITE  F_ANEK-OBJID TO F_HKOBJ
          USING EDIT MASK '==ALPHA'.
        L_FOUND = ON.
        F_BBSTYP = CON_AUF.

*   Abrechnung von Netzplan.                               " Netzplan
      WHEN 'NP'.                                             " Netzplan
        F_HKTYP = TEXT-T20.                                  " Netzplan
        WRITE  F_ANEK-OBJID TO F_HKOBJ                       " Netzplan
          USING EDIT MASK '==ALPHA'.                         " Netzplan
        L_FOUND  = ON.                                       " Netzplan
        F_BBSTYP = CON_NP.                                   " Netzplan

*   Abrechnung von Netzplanvorgang.                        " Netzplan
      WHEN 'NV'.                                             " Netzplan
        F_HKTYP = TEXT-T21.                                  " Netzplan
        L_OBJNR+0(2)  = 'NV'.                                " Netzplan
        L_OBJNR+2(20) = F_ANEK-OBJID.                        " Netzplan
        CALL FUNCTION 'OBJECT_IDENTIFICATION_GET'            " Netzplan
             EXPORTING                                       " Netzplan
*               DATUM          = SY-DATLO                  " Netzplan
*               LANGU          = SY-LANGU                  " Netzplan
*               NO_BUKRS       = ' '                       " Netzplan
*               NO_KOKRS       = ' '                       " Netzplan
                  OBJNR          = L_OBJNR                   " Netzplan
*               TEXT_WANTED    = ' '                       " Netzplan
             IMPORTING                                       " Netzplan
*               E_IONRA        =                           " Netzplan
*               E_TEXT         =                           " Netzplan
*               IDENTIFICATION =                           " Netzplan
*               IDENT_OBART    =                           " Netzplan
                  IDENT_OBJID    = L_IDENT.                  " Netzplan
        F_HKOBJ  = L_IDENT.                                  " Netzplan
        F_BBSTYP = CON_NV.                                   " Netzplan
        L_FOUND  = ON.                                       " Netzplan


*   Abrechnung von Projekt.
      WHEN 'PR'.
*     Bist du Inv-Maßnahme?
        SELECT COUNT(*) FROM ANLE
          WHERE BUKRS EQ F_ANEK-BUKRS
          AND   ANLN1 EQ F_ANEK-ANLN1
          AND   ANLN2 EQ F_ANEK-ANLN2
          AND   GJAHR EQ F_ANEK-GJAHR
          AND   LNRAN EQ F_ANEK-LNRAN.
*     Ja.
        IF SY-DBCNT > 0.
          F_HKTYP = TEXT-T12.
*     Nein.
        ELSE.
          F_HKTYP = TEXT-T04.
        ENDIF.
        WRITE  F_ANEK-OBJID TO F_HKOBJ
          USING EDIT MASK '==KONPR'.
        L_FOUND = ON.
        F_BBSTYP = CON_PRJ.
    ENDCASE.
  ENDIF.

* Umbuchung von Anlage?
  CHECK L_FOUND EQ OFF.
  IF NOT F_ANEK-ANLU1 IS INITIAL.
    F_HKTYP = TEXT-T01.
    WRITE: F_ANEK-ANLU1 TO F_HKOBJ(12),
           '-'          TO F_HKOBJ+13(1),
           F_ANEK-ANLU2 TO F_HKOBJ+15(4).
    CONDENSE F_HKOBJ NO-GAPS.
    L_FOUND = ON.
    F_BBSTYP = CON_AIB.
  ENDIF.

* FI-Beleg vorhanden, dann einlesen.
  CHECK L_FOUND EQ OFF.
  SELECT * FROM BSEG INTO TABLE XBSEG
    WHERE BUKRS EQ F_ANEK-BUKRS
    AND   BELNR EQ F_ANEK-BELNR
    AND   GJAHR EQ F_ANEK-GJAHR
    ORDER BY PRIMARY KEY.
* 1. Fall: Genau eine Gegenbuchungszeile.
  IF SY-DBCNT EQ 2.
    LOOP AT XBSEG
      WHERE BUZEI NE F_ANEPV-BUZEI.
      L_FOUND = ON.
      EXIT.
    ENDLOOP.
* 2. Fall: Mehrere Gegenbuchungszeilen.
  ELSE.
* begin of deletion                                            "> 400793
*   Buchungszeile die zum ANEPV gehört in *BSEG bereitstellen ...
*    LOOP AT XBSEG
*      WHERE BUZEI EQ F_ANEPV-BUZEI.
*      MOVE XBSEG TO *BSEG.
*      EXIT.
*    ENDLOOP.
* end of deletion                                              "> 400793
* begin of insertion                                           "> 400793
*   BUZEI nicht mehr sinnvoll nach 4.0 Releasen, deshalb jetzt nach
*   ANLN1, ANLN2 und ANBTR suchen
    IF F_ANEPV-ANBTR GE 0.
      LOOP AT XBSEG
        WHERE ANLN1 EQ F_ANEPV-ANLN1
        AND   ANLN2 EQ F_ANEPV-ANLN2
        AND   DMBTR EQ F_ANEPV-ANBTR.
        MOVE XBSEG TO *BSEG.
        EXIT.
      ENDLOOP.
    ELSE.
      LD_ANEPV_NEG_ANBTR = F_ANEPV-ANBTR * -1.
      LOOP AT XBSEG
        WHERE ANLN1 EQ F_ANEPV-ANLN1
        AND   ANLN2 EQ F_ANEPV-ANLN2
        AND   DMBTR EQ LD_ANEPV_NEG_ANBTR.
        MOVE XBSEG TO *BSEG.
        EXIT.
      ENDLOOP.
      CLEAR LD_ANEPV_NEG_ANBTR.
    ENDIF.
* end of insertion                                             "> 400793

*   Bist Du etwa Anzahlung? Dann ermittle die              "anz
*   korrespondierende Kreditorenzeile!                     "anz
    LOOP AT XBSEG                                          "anz
      WHERE     KOART EQ 'K'           " Kreditor.         "anz
      AND   NOT UMSKZ IS INITIAL       " Sonder-Hauptbuch. "anz
      AND       ANLN1 EQ *BSEG-ANLN1                       "anz
      AND       ANLN2 EQ *BSEG-ANLN2.                      "anz
      F_HKTYP = TEXT-T06.                               "anz
      WRITE XBSEG-LIFNR TO f_HKOBJ.                     "anz
*       USING EDIT-MASK '==ALPHA'.                         "anz
      L_FOUND = ON.                                        "anz
      F_BBSTYP = CON_KRED.
    ENDLOOP.                                               "anz
*   Ansonsten ...                                          "anz
    CHECK L_FOUND EQ OFF.                                  "anz
    L_DMBTR_ANL = *BSEG-DMBTR + *BSEG-MWSTS.
*   ... Kreditoren-/Debitorenzeilen verdichten und ...     " n. 438435
    perform gegenbuchungen_verdichten tables xbseg.         " n. 438435
*   ... "passendste" Gegenbuchungszeile aus FI-Beleg ermitteln.
*   IF *BSEG-SHKZG EQ 'S'.                     " n. 308379 " n. 400793
    IF L_DMBTR_ANL GE 0.                                    " n. 400793
      SORT XBSEG BY DMBTR ASCENDING.                        " n. 308379
    ELSE.                                                   " n. 308379
      SORT XBSEG BY DMBTR DESCENDING.                       " n. 308379
    ENDIF.                                                  " n. 308379
    LOOP AT XBSEG
      WHERE SHKZG NE *BSEG-SHKZG.
      L_COUNT = L_COUNT + 1.
*     Schon mehr als eine passende Gegenbuchungszeile ...
      IF L_COUNT GT 1.
*       ... dann Gegenbuchungszeile nicht mehr eindeutig.
*        F_PLAUS = TEXT-T98.
        ld_plaus = TEXT-T98.
      ENDIF.
*     Gegenbuchungsbetrag groesser oder gleich
*     Anlagenbuchungsbetrag + MWSt ...
      IF L_FOUND EQ OFF.
*       ... (positive Betraege) ...
*       IF *BSEG-SHKZG EQ 'S'.                 " n. 308379 " n. 400793
        IF L_DMBTR_ANL GE 0.                                " n. 400793
          CHECK XBSEG-DMBTR GE L_DMBTR_ANL.
*       ... (negative Betraege) ...
        ELSE.
          CHECK XBSEG-DMBTR LE L_DMBTR_ANL.
        ENDIF.
*       ... dann nimm diese Buchungszeile!!
        L_FOUND = ON.
        L_TABIX = SY-TABIX.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Gefundene Buchungszeile XBSEG auswerten.
  IF L_FOUND EQ ON.
    READ TABLE XBSEG INDEX L_TABIX.
*   Kontoart abfragen.
    CASE XBSEG-KOART.
*   Anlage ...
      WHEN 'A'.
*     ... kann eigentlich nur Gegenbuchung zur Vortragsbuchung sein,
*     aber lieber nochmal abpruefen!
        IF F_ANEK-ANLU1 IS INITIAL.
          F_HKTYP = TEXT-T10.
          WRITE: XBSEG-ANLN1 TO F_HKOBJ(12),
                 '-'         TO F_HKOBJ+13(1),
                 XBSEG-ANLN2 TO F_HKOBJ+15(4).
          CONDENSE F_HKOBJ NO-GAPS.
*        Gegenbuchungszeile/Eindeutigkeit nicht sinnvoll.
*         F_PLAUS = SPACE.
          ld_plaus = TEXT-T98.

        ELSE.
          L_FOUND = OFF.
        ENDIF.
*   Debitor.
      WHEN 'D'.
        F_HKTYP = TEXT-T05.
        WRITE XBSEG-KUNNR TO F_HKOBJ.
        F_BBSTYP = CON_DEB.
*       USING EDIT-MASK '==ALPHA'.
*   Kreditor.
      WHEN 'K'.
        F_HKTYP = TEXT-T06.
        WRITE XBSEG-LIFNR TO F_HKOBJ.
        F_BBSTYP = CON_KRED.
*       USING EDIT-MASK '==ALPHA'.
*   Material.
      WHEN 'M'.
        F_HKTYP = TEXT-T07.
        WRITE XBSEG-MATNR TO F_HKOBJ.
*       USING EDIT-MASK '==MATN1'.
*   Sachkonto.
      WHEN 'S'.
*     Wareneingang ...                                "RMNEW
        IF XBSEG-VORGN EQ CON_VORGN_RMWE.               "NEWRM
*        ... dann Herkunft = Kreditor aus Bestellung.
          F_HKTYP = TEXT-T06.
          WRITE XBSEG-LIFNR TO F_HKOBJ.
          F_BBSTYP = CON_KRED.
*     Sachkonto.
        ELSE.
          F_HKTYP = TEXT-T08.
          WRITE XBSEG-HKONT TO F_HKOBJ.
*          USING EDIT-MASK '==ALPHA'.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                    "HERKUNFT_ERMITTELN





*&--------------------------------------------------------------------*
*&      Form  gegenbuchungen_verdichten
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->IT_BSEG    text
*---------------------------------------------------------------------*
form gegenbuchungen_verdichten                   " begin   " n. 438435
     tables it_bseg structure bseg.

* Ist die Gegenbuchung zur Anlagenbewegung
* eine Debitoren- oder Kreditorenbuchung,
* so könnte es statt einer mehrere
* Debitoren-/Kreditorenbuchungszeilen geben.
* Dies kann "einfach so" der Fall sein, wenn
* der entsprechende Beleg so erfasst wurde,
* dies kann aber insbesondere in dem Falle vorkommen,
* wenn Debitoren-/Kreditorenbuchungen teilweise
* auf ein anderes (Sonder-)Hauptbuchkonto gehen,
* z.B. für Kreditoren auf das Sonderhauptbuchkonto
* für Sicherheitseinbehalte (BSEG-UMSKZ = H).
* In jedem Falle sollten dann mehrere
* Debitoren-/Kreditorenbuchungszeilen in eine
* verdichtet werden.

  data: l_buzei like bseg-buzei,
        l_dmbtr like bseg-dmbtr,
        l_mwsts like bseg-mwsts.

  data: l_bseg  like bseg.

*********************************************************************
* 1. Kreditoren                                                     *
*********************************************************************
  data: begin of t_trigger_k occurs 10,
          shkzg     like bseg-shkzg,
          lifnr     like bseg-lifnr,
          sum_dmbtr like bseg-dmbtr,
          sum_mwsts like bseg-mwsts,
          items     type i,
        end   of t_trigger_k.

* Sammle alle betroffenen Kreditoren/SHKZGs im Beleg
* und verdichte die relevanten Beträge.
* Merke je Kreditor/SHKZG wie viele Zeilen hierzu
* im Beleg vorkommen.
  refresh t_trigger_k.
  free    t_trigger_k.
  loop at it_bseg
    where koart = 'K'.
    clear t_trigger_k.
    t_trigger_k-shkzg     = it_bseg-shkzg.
    t_trigger_k-lifnr     = it_bseg-lifnr.
    t_trigger_k-sum_dmbtr = it_bseg-dmbtr.
    t_trigger_k-sum_mwsts = it_bseg-mwsts.
    t_trigger_k-items     = 1.
    collect t_trigger_k.
  endloop.

* Es muss nur der Fall bearbeitet werden, in dem
* zu einem Kreditor/SHKZG mehrere Zeilen im Beleg
* existieren.
  delete t_trigger_k
    where items = 1.

* Je Kreditor/SHKZG die BUZEI derjenigen Zeile in XBSEG
* ermitteln, in die hinein verdichtet werden soll.
  loop at t_trigger_k.
    clear l_buzei.
*   Zeile ohne Sonderhauptbuchvorgang
*   zu Kreditor/SHKZG vorhanden?
    loop at it_bseg
      where koart = 'K'
      and   shkzg = t_trigger_k-shkzg
      and   lifnr = t_trigger_k-lifnr
      and   umskz is initial.
      l_buzei = it_bseg-buzei.
      exit.
    endloop.
*   Nein, ...
    if sy-subrc <> 0.
*      ... dann nimm die erste Zeile zu Kreditor/SHKZG.
      loop at it_bseg
        where koart = 'K'
        and   shkzg = t_trigger_k-shkzg
        and   lifnr = t_trigger_k-lifnr.
        l_buzei = it_bseg-buzei.
        exit.
      endloop.
    endif.
*   Jetzt Buchungszeilen zu Kreditor/SHKZG verdichten.
    if not l_buzei is initial.
      loop at it_bseg
        where koart = 'K'
        and   shkzg = t_trigger_k-shkzg
        and   lifnr = t_trigger_k-lifnr.
        if it_bseg-buzei = l_buzei.
          it_bseg-dmbtr = t_trigger_k-sum_dmbtr.
          it_bseg-mwsts = t_trigger_k-sum_mwsts.
          modify it_bseg transporting dmbtr mwsts.
        else.
          delete it_bseg.
        endif.
      endloop.
    endif.
  endloop.

*********************************************************************
* 2. Debitoren                                                      *
*********************************************************************
  data: begin of t_trigger_d occurs 10,
          shkzg     like bseg-shkzg,
          kunnr     like bseg-kunnr,
          sum_dmbtr like bseg-dmbtr,
          sum_mwsts like bseg-mwsts,
          items     type i,
        end   of t_trigger_d.

* Sammle alle betroffenen Debitoren/SHKZGs im Beleg
* und verdichte die relevanten Beträge.
* Merke je Debitor/SHKZG wie viele Zeilen hierzu
* im Beleg vorkommen.
  refresh t_trigger_d.
  free    t_trigger_d.
  loop at it_bseg
    where koart = 'D'.
    clear t_trigger_d.
    t_trigger_d-shkzg     = it_bseg-shkzg.
    t_trigger_d-kunnr     = it_bseg-kunnr.
    t_trigger_d-sum_dmbtr = it_bseg-dmbtr.
    t_trigger_d-sum_mwsts = it_bseg-mwsts.
    t_trigger_d-items     = 1.
    collect t_trigger_d.
  endloop.

* Es muss nur der Fall bearbeitet werden, in dem
* zu einem Debitor/SHKZG mehrere Zeilen im Beleg
* existieren.
  delete t_trigger_d
    where items = 1.

* Je Debitor/SHKZG die BUZEI derjenigen Zeile in XBSEG
* ermitteln, in die hinein verdichtet werden soll.
  loop at t_trigger_d.
    clear l_buzei.
*   Zeile ohne Sonderhauptbuchvorgang
*   zu Debitor/SHKZG vorhanden?
    loop at it_bseg
      where koart = 'D'
      and   shkzg = t_trigger_d-shkzg
      and   kunnr = t_trigger_d-kunnr
      and   umskz is initial.
      l_buzei = it_bseg-buzei.
      exit.
    endloop.
*   Nein, ...
    if sy-subrc <> 0.
*      ... dann nimm die erste Zeile zu Debitor/SHKZG.
      loop at it_bseg
        where koart = 'D'
        and   shkzg = t_trigger_d-shkzg
        and   kunnr = t_trigger_d-kunnr.
        l_buzei = it_bseg-buzei.
        exit.
      endloop.
    endif.
*   Jetzt Buchungszeilen zu Debitor/SHKZG verdichten.
    if not l_buzei is initial.
      loop at it_bseg
        where koart = 'D'
        and   shkzg = t_trigger_d-shkzg
        and   kunnr = t_trigger_d-kunnr.
        if it_bseg-buzei = l_buzei.
          it_bseg-dmbtr = t_trigger_d-sum_dmbtr.
          it_bseg-mwsts = t_trigger_d-sum_mwsts.
          modify it_bseg transporting dmbtr mwsts.
        else.
          delete it_bseg.
        endif.
      endloop.
    endif.
  endloop.

endform.                                         " end     " n. 438435


*&--------------------------------------------------------------------*
*&      Form  ORGINALPOSTEN_AUSGEBEN
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->F_ANEK     text
*      -->F_ANEPV    text
*      -->ET_POST    text
*---------------------------------------------------------------------*
FORM ORGINALPOSTEN_AUSGEBEN

          USING F_ANEK  STRUCTURE ANEK
                F_ANEPV STRUCTURE ANEPV
          changing ET_POST type t_post.

  TABLES:ANEP, ANLE, COKEY, AUAK, AUAS, AUAA.

  data: ls_post like line of et_post.

  DATA: L_OPER(1)   TYPE C VALUE '=',
        L_DUMMY     TYPE C,
        L_TFILL     LIKE SY-TFILL,
        L_INVBT     LIKE ANEP-ANBTR,
        L_AUGLN     LIKE ANEPV-AUGLN,
        L_OBJNR     LIKE AUAK-OBJNR,
        L_CPUDT1    LIKE ANEK-CPUDT,
        L_CPUDT2    LIKE ANEK-CPUDT,
        L_CPU1(6)   TYPE N,
        L_CPU2(6)   TYPE N.

  DATA: BEGIN OF L_ANEP.
          INCLUDE STRUCTURE ANEP.
  DATA: END OF L_ANEP.

  DATA: BEGIN OF XANEP OCCURS 10.
          INCLUDE STRUCTURE ANEP.
  DATA: END OF XANEP.

  DATA: BEGIN OF YORG OCCURS 10,
          BELNR      LIKE BKPF-BELNR,
          WTGBTR(15) TYPE C,
          ANBTR(15)  TYPE C,
        END OF YORG.

  DATA: BEGIN OF YORGEP OCCURS 10,
          FIBELNR    LIKE ANLE-FIBELNR,
          FIGJAHR    LIKE ANLE-FIGJAHR,
*         BUDAT      LIKE ANEK-BUDAT,
*         BWASL      LIKE ANEP-BWASL,
*         BZDAT      LIKE ANEP-BZDAT,
          HKTYP(10)  TYPE C,
          HKOBJ(24)  TYPE C,
          KSTAR      LIKE ANLE-KSTAR,
          WBGBTR     LIKE ANLE-WBGBTR,
          WBABTR     LIKE ANLE-WBGBTR,
        END   OF YORGEP.

* Erstmal kucken, ob du InvMaßnahme bist.
  IF F_ANEK-OBART EQ 'OR' OR
     F_ANEK-OBART EQ 'PR' .

    SELECT * FROM ANLE
      WHERE BUKRS EQ F_ANEPV-BUKRS
      AND   ANLN1 EQ F_ANEPV-ANLN1
      AND   ANLN2 EQ F_ANEPV-ANLN2
      AND   GJAHR EQ F_ANEPV-GJAHR
      AND   LNRAN EQ F_ANEPV-LNRAN.
*
      CLEAR YORGEP.
      MOVE: ANLE-FIBELNR  TO YORGEP-FIBELNR,
            ANLE-FIGJAHR  TO YORGEP-FIGJAHR,
            ANLE-GKONT    TO YORGEP-HKOBJ,
            ANLE-KSTAR    TO YORGEP-KSTAR,
            ANLE-WBGBTR   TO YORGEP-WBGBTR,
            ANLE-WBABTR   TO YORGEP-WBABTR.
*      Sonderbehandlung Material.
      IF NOT ANLE-HRKFT IS INITIAL.
        SELECT SINGLE * FROM COKEY
          WHERE HRKFT EQ ANLE-HRKFT.
        IF SY-SUBRC EQ 0.
          WRITE COKEY-MATNR TO YORGEP-HKOBJ.
          MOVE TEXT-T07     TO YORGEP-HKTYP.
        ELSE.
          CLEAR YORGEP-HKOBJ.
        ENDIF.
      ENDIF.
*      Text Herkunftstyp bestimmen.
      CASE  ANLE-GKOAR.
        WHEN 'A'.
          MOVE TEXT-T01     TO YORGEP-HKTYP.
        WHEN 'D'.
          MOVE TEXT-T05     TO YORGEP-HKTYP.
        WHEN 'K'.
          MOVE TEXT-T06     TO YORGEP-HKTYP.
*      WHEN 'M'.
*        MOVE TEXT-T07     TO YORGEP-HKTYP.
        WHEN 'S'.
          MOVE TEXT-T08     TO YORGEP-HKTYP.
      ENDCASE.
      APPEND YORGEP.
    ENDSELECT.

  ENDIF.

* Keine InvMaßnahme aber Abrechnung von AiB.
  IF     F_ANEK-OBART EQ 'AN'    AND
     NOT F_ANEK-ANLU1 IS INITIAL .

*    "Gegenbewegung" auf AiB bestimmen die zu EP gehoert.
*Begin of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 26/12/2019 EY_DES02 ECDK917080 *
SORT XABW BY BWASL.
*End of change: ReSQ Correction for READ STATEMENT WITH BINARY AND WITHOUT SORTING 26/12/2019 EY_DES02 ECDK917080 *
    READ TABLE XABW WITH KEY POST-BWASL BINARY SEARCH.
*    Nochmal ANEP lesen, da die RW-Belegnummer ANEP-BELNR gebraucht
*    wird, die jedoch bei GET ANEK/GET ANEPV von der logischen
*    Datenbank in die FI-Belegnummer umgeswitcht wurde!
    SELECT * FROM ANEP INTO L_ANEP
      WHERE BUKRS EQ F_ANEK-BUKRS
      AND   ANLN1 EQ F_ANEK-ANLN1
      AND   ANLN2 EQ F_ANEK-ANLN2
      AND   GJAHR EQ F_ANEK-GJAHR
      AND   LNRAN EQ F_ANEK-LNRAN
      AND   AFABE EQ BEREICH1.
      EXIT.
    ENDSELECT.
*    99%-Fall: RW-Belegnummer existiert
*    (ist so bei allen Belegen >= 3.0 und bei den alten Belegen,
*    die keine reine Anlagenbewegung waren).
    IF NOT POST-BELNR IS INITIAL.
      SELECT * FROM ANEP INTO TABLE XANEP
        WHERE BUKRS EQ F_ANEK-BUKRS
        AND   ANLN1 EQ F_ANEK-ANLU1
        AND   ANLN2 EQ F_ANEK-ANLU2
        AND   GJAHR EQ F_ANEK-GJAHR
        AND   AFABE EQ BEREICH1
        AND   BWASL EQ XABW-BWASLG
        AND   BELNR EQ L_ANEP-BELNR
              ORDER BY PRIMARY KEY.
*    1%-Fall: RW-Belegnummer existiert nicht
*    (ist so bei allen Belegen < 3.0, die eine reine Anlagenbewegung
*    waren, z.B. Umbuchung rein kalkulatorisch).
*    In diesem Fall kann im folgenden XANEP theoretisch mehr als
*    einen Eintrag haben: Z.B. wenn von einer AIB mehrere
*    rein kalkulatorische Aktivierungen gelaufen sind!
    ELSE.
      SELECT * FROM ANEP INTO TABLE XANEP
        WHERE BUKRS EQ F_ANEK-BUKRS
        AND   ANLN1 EQ F_ANEK-ANLU1
        AND   ANLN2 EQ F_ANEK-ANLU2
        AND   GJAHR EQ F_ANEK-GJAHR
        AND   AFABE EQ BEREICH1
        AND   BWASL EQ XABW-BWASLG
              ORDER BY PRIMARY KEY.
*      Gegenbewegung eindeutig?
      DESCRIBE TABLE XANEP LINES L_TFILL.
*      Nein ...
      IF L_TFILL GT 1.
*        ... dann weiter einschraenken.
        LOOP AT XANEP.
*          Zunaechst zugehoerigen ANEK besorgen ...
          SELECT SINGLE * FROM ANEK
            WHERE BUKRS EQ XANEP-BUKRS
            AND   ANLN1 EQ XANEP-ANLN1
            AND   ANLN2 EQ XANEP-ANLN2
            AND   GJAHR EQ XANEP-GJAHR
            AND   LNRAN EQ XANEP-LNRAN.
*          ... und mit Ausgangs-ANEK vergleichen und bei Ungleichheit
*          verwerfen.
          IF NOT ( ANEK-BLDAT EQ F_ANEK-BLDAT AND
                   ANEK-BUDAT EQ F_ANEK-BUDAT ).
            DELETE XANEP.
          ENDIF.
        ENDLOOP.
*        Gegenbewegung jetzt eindeutig?
        DESCRIBE TABLE XANEP LINES L_TFILL.
*        Nein ...
        IF L_TFILL GT 1.
*          ... dann weiter einschraenken.
          LOOP AT XANEP.
*             Zunaechst zugehoerigen ANEK besorgen ...
            SELECT SINGLE * FROM ANEK
             WHERE BUKRS EQ XANEP-BUKRS
             AND   ANLN1 EQ XANEP-ANLN1
             AND   ANLN2 EQ XANEP-ANLN2
             AND   GJAHR EQ XANEP-GJAHR
             AND   LNRAN EQ XANEP-LNRAN.
*            ... und CPU-Zeiten vergleichen.
*            Unterschiedliche CPU-Datuemer ...
            IF ANEK-CPUDT NE F_ANEK-CPUDT.
*              ... dann kann es hoechstens noch sein, daß ein ANEP
*              um 23.59.xx und der andere um 00.00.yy am Folgetag
*              geschrieben wurde (wenn schon, dann richtig!!!).
              L_CPUDT1 = ANEK-CPUDT + 1.
              L_CPUDT2 = F_ANEK-CPUDT + 1.
              IF     L_CPUDT1 EQ F_ANEK-CPUDT.
                MOVE: ANEK-CPUTM TO L_CPU1,
                      F_ANEK-CPUTM TO L_CPU2.
                L_CPU1 = L_CPU1 - L_CPU2.
                IF L_CPU1 LT 235950.
                  DELETE XANEP.
                ENDIF.
              ELSEIF L_CPUDT2 EQ ANEK-CPUDT.
                MOVE: ANEK-CPUTM TO L_CPU1,
                      F_ANEK-CPUTM TO L_CPU2.
                L_CPU1 = L_CPU2 - L_CPU1.
                IF L_CPU1 LT 235950.
                  DELETE XANEP.
                ENDIF.
              ELSE.
                DELETE XANEP.
              ENDIF.
*            Gleiche CPU-Datuemer ...
            ELSE.
              MOVE: ANEK-CPUTM TO L_CPU1,
                    F_ANEK-CPUTM TO L_CPU2.
              IF L_CPU1 GE L_CPU2.
                L_CPU1 = L_CPU1 - L_CPU2.
              ELSE.
                L_CPU1 = L_CPU2 - L_CPU1.
              ENDIF.
*              CPU-Zeiten mehr als 10 Sekunden ausdeinander ...
              IF L_CPU1 GT 10.
*                ... die gehoeren nie und nimmer zusammen!
                DELETE XANEP.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

*    Jetzt steht in XANEP genau die eine "Gegenbewegung".
    READ TABLE XANEP INDEX 1.
*    Wir brauchen die Ausgleichsziffer zum aktuellen Abrechnungsvorgang!
    L_AUGLN = XANEP-AUGLN.

    MOVE: 'AN'       TO L_OBJNR(2),
          F_ANEK-BUKRS TO L_OBJNR+2(4),
          F_ANEK-ANLU1 TO L_OBJNR+6(12),
          F_ANEK-ANLU2 TO L_OBJNR+18(4).
*    Alle Abrechnungsvorgaenge zur aktuellen AiB absuchen.
    SELECT * FROM AUAK
      WHERE OBJNR EQ L_OBJNR.
SELECT * FROM AUAS
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 26/12/2019 EY_DES02 ECDK917080 *
*WHERE BELNR EQ AUAK-BELNR.
WHERE BELNR EQ AUAK-BELNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 26/12/2019 EY_DES02 ECDK917080 *
*        Gehoerst du zum richtigen AfA-Bereich?
        CHECK AUAS-KEY01+32(2) EQ BEREICH1.
*        Gehoerst du zur richtigen BWA?
        CHECK AUAS-BWASL EQ POST-BWASL.
*        Ursprünglich aufgeteilten ANEP lesen ...
        SELECT SINGLE * FROM ANEP
          WHERE BUKRS EQ AUAS-KEY01+3(4)
          AND   ANLN1 EQ AUAS-KEY01+7(12)
          AND   ANLN2 EQ AUAS-KEY01+19(4)
          AND   GJAHR EQ AUAS-KEY01+23(4)
          AND   LNRAN EQ AUAS-KEY01+27(5)
          AND   AFABE EQ AUAS-KEY01+32(2)
          AND   ZUJHR EQ AUAS-KEY01+34(4)
          AND   ZUCOD EQ AUAS-KEY01+38(4).
*        ... plus zugehörigen ANEK.
        SELECT SINGLE * FROM ANEK
          WHERE BUKRS EQ ANEP-BUKRS
          AND   ANLN1 EQ ANEP-ANLN1
          AND   ANLN2 EQ ANEP-ANLN2
          AND   GJAHR EQ ANEP-GJAHR
          AND   LNRAN EQ ANEP-LNRAN.
*        Gehoerst du zum aktuellen Abrechnungsvorgang?
        CHECK ANEP-AUGLN EQ L_AUGLN.
*        Gehoerst du zum Empfaenger ANLAV-ANLN1 ANLAV-ANLN2 ?
SELECT * FROM AUAA
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 26/12/2019 EY_DES02 ECDK917080 *
*WHERE BELNR EQ AUAS-BELNR.
WHERE BELNR EQ AUAS-BELNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 26/12/2019 EY_DES02 ECDK917080 *
          CHECK AUAA-ANLN1 EQ ANLAV-ANLN1 AND
                AUAA-ANLN2 EQ ANLAV-ANLN2.
          EXIT.
        ENDSELECT.
        CHECK AUAS-PLFNR EQ AUAA-LFDNR.

*        YORGEP füllen.
        CLEAR YORGEP.
*        FI-Belegnummer ermitteln.
        PERFORM GET_FI_BELNR USING    ANEK
                             CHANGING YORGEP-FIBELNR.
        MOVE YORGEP-FIBELNR  TO ANEK-BELNR.
        CLEAR ANEPV.
        MOVE-CORRESPONDING ANEP TO ANEPV.
        PERFORM HERKUNFT_ERMITTELN
                USING    ANEK ANEPV
                CHANGING YORGEP-HKTYP YORGEP-HKOBJ "L_DUMMY
                GD_BBS_TYP.

        MOVE: ANEK-GJAHR     TO YORGEP-FIGJAHR,
*              ANEK-BUDAT     TO YORGEP-BUDAT,
*              ANEP-BWASL     TO YORGEP-BWASL,
*              ANEP-BZDAT     TO YORGEP-BZDAT,
              ANEP-ANBTR     TO YORGEP-WBGBTR,
              AUAS-WTGBTR    TO YORGEP-WBABTR.
        APPEND YORGEP.
*
      ENDSELECT.
    ENDSELECT.

*    Anteilige Investitionszuschuesse vorhanden?
    IF NOT F_ANEPV-INVZV IS INITIAL OR
       NOT F_ANEPV-INVZL IS INITIAL.
      L_INVBT = F_ANEPV-INVZV + F_ANEPV-INVZL.
      CLEAR YORGEP.
      MOVE:  L_INVBT     TO YORGEP-WBABTR,
             TEXT-030    TO YORGEP-HKOBJ.
      APPEND YORGEP.
    ENDIF.

  ENDIF.

* Orginal-EPs ausgeben
  LOOP AT YORGEP.
*    IF SY-TABIX GT 1.
*      L_OPER = '+'.
*    ENDIF.

*    FORMAT          COLOR COL_NORMAL INTENSIFIED ON INVERSE.
*    WRITE: /001     SY-VLINE,
*            002(02) SPACE NO-GAP,
*            004(10) YORGEP-FIBELNR,
*            014(01) SPACE NO-GAP,
*            015(04) YORGEP-FIGJAHR NO-ZERO,
*            019     SY-VLINE,
*            020(31) SPACE NO-GAP,
**           020(10) YORGEP-BUDAT NO-ZERO,
**           030(01) SPACE NO-GAP,
**           031(03) YORGEP-BWASL,
**           034(01) SPACE NO-GAP,
**           035(10) YORGEP-BZDAT NO-ZERO,
**           045(06) SPACE NO-GAP,
*            051(15) YORGEP-WBGBTR CURRENCY SAV_WAER1 NO-ZERO,
*"<<!!!!!!!
*            066     SY-VLINE NO-GAP,
*            067(01) L_OPER NO-GAP,
*            068(01) SPACE NO-GAP,
*            069(15) YORGEP-WBABTR CURRENCY SAV_WAER1,   "<<<<<!!!!!!!
*            084     SY-VLINE NO-GAP,
*            085(10) YORGEP-HKTYP NO-GAP,
*            095(01) SPACE NO-GAP,
*            096(24) YORGEP-HKOBJ,
*            120(01) SPACE NO-GAP,
*            121(10) YORGEP-KSTAR,
*            131     SY-VLINE NO-GAP.
*    FORMAT  RESET.
*
**   Informationen fuer PickUp.
*    FLG_PICK_UP = 'X'.
*    MOVE: POST-BUKRS      TO ANEPV-BUKRS,
*          YORGEP-FIGJAHR  TO ANEPV-GJAHR,
*          YORGEP-FIBELNR  TO ANEPV-BELNR.
*    HIDE:                    ANEPV-BUKRS,
*                             ANEPV-GJAHR,
*                             ANEPV-BELNR,
*                             FLG_PICK_UP,
*                             RANGE.
*     CLEAR FLG_PICK_UP.
    ls_post-bukrs =  post-bukrs.
    ls_post-belnr =  post-belnr.
    ls_post-gjahr =  post-gjahr.
*  if not yorgep-fibelnr is initial.
*    ls_post-belnr_org = yorgep-fibelnr.
*    ls_post-gjahr_org = yorgep-figjahr.
*  endif.
    ls_post-btr4 = YORGEP-WBGBTR.
    ls_post-btr5 = YORGEP-WBABTR.
    concatenate YORGEP-hktyp YORGEP-hkobj
         into ls_post-origin separated by space.

    move-corresponding YORGEP to ls_post.
    append ls_post to et_post.
  ENDLOOP.

ENDFORM.                    "ORGINALPOSTEN_AUSGEBEN

*&--------------------------------------------------------------------*
*&      Form  GET_FI_BELNR
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->F_ANEK     text
*      -->F_FI_BELNR text
*---------------------------------------------------------------------*
FORM GET_FI_BELNR USING    F_ANEK STRUCTURE ANEK
                  CHANGING F_FI_BELNR.

  DATA: BEGIN OF T_ACCDN OCCURS 1.
          INCLUDE STRUCTURE ACCDN.
  DATA: END   OF T_ACCDN.

  DATA: BEGIN OF T_ANEK  OCCURS 1.
          INCLUDE STRUCTURE ANEK.
  DATA: END   OF T_ANEK.

  MOVE F_ANEK TO T_ANEK.
  APPEND T_ANEK.

  CALL FUNCTION 'GET_FI_BELNR_TO_ANEK'
    TABLES
      T_ANEK  = T_ANEK
      T_ACCDN = T_ACCDN.

  READ TABLE T_ACCDN INDEX 1.
  F_FI_BELNR = T_ACCDN-BELNR.

ENDFORM.                    "GET_FI_BELNR


*&--------------------------------------------------------------------*
*&      Form  init_fieldcat_RAHERK
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
FORM init_fieldcat_RAHERK.


*******************************************************************
****                 ITEM TABELLE  RAHERK                      ****

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BELNR'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'ANEPV'.
  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BUDAT'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'BKPF'.
  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'BWASL'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'ANEPV'.
  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'SGTXT'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'BSEG'.
  x_fieldcat-outputlen     = 25.
  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'FIBELNR'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'ANLE'.
  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'FIGJAHR'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'ANLE'.
  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.

  CALL FUNCTION 'FIAA_FIELDCAT_ADD_BTR'
    EXPORTING
      num     = 1
      text    = text-w01
      tabname = 'ITAB_DATA2'.


  CALL FUNCTION 'FIAA_FIELDCAT_ADD_BTR'
    EXPORTING
      num     = 5
      text    = text-w14
      tabname = 'ITAB_DATA2'.

  CALL FUNCTION 'FIAA_FIELDCAT_ADD_BTR'
    EXPORTING
      num     = 4
      text    = text-w11
      tabname = 'ITAB_DATA2'.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'WAERS'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'T093B'.
  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.


  CLEAR x_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'ORIGIN'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-seltext_l     =  text-w15.
  x_fieldcat-seltext_m     =  text-w15.
  x_fieldcat-seltext_s     =  text-w15.
  x_fieldcat-reptext_ddic  =  text-w15.

  x_fieldcat-outputlen     = 30.

  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.

  CLEAR x_fieldcat.
  x_fieldcat-fieldname     = 'KSTAR'.
  x_fieldcat-tabname       = 'ITAB_DATA2'.
  x_fieldcat-ref_tabname   = 'ANLE'.

  CALL FUNCTION 'FIAA_FIELDCAT_ADD_FIELD'
    EXPORTING
      fieldcat_line = x_fieldcat.


ENDFORM.                    "init_fieldcat_RAHERK
