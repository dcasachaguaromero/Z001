*----------------------------------------------------------------------*
***INCLUDE ZFIMDP010 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  KONTIERUNG_PRUEFEN_0100
*&---------------------------------------------------------------------*
*       modifizierte Version der routine KONTIERUNG_PRUEFEN
* Falls der Feldstatus auf '-' sitzt (Feld dunkel), muß in der
* Schnellerfassung überprüft werden, ob der Wert mit dem entsprechenden
* cobl-Feld übereinstimmt, d.h. ob die abgeleitete Information aus dem
* Kontierungsblock nicht überschrieben wurde.
*----------------------------------------------------------------------*
*      -->P_SCREEN_GROUP1  text
*----------------------------------------------------------------------*
* (del) form kontierung_pruefen_0100 using kon_group.      "Note 302988
FORM KONTIERUNG_PRUEFEN_0100                               "Note 302988
         USING                                             "Note 302988
            VALUE(KON_GROUP) LIKE SCREEN-GROUP1            "Note 302988
            VALUE(P_CLEARMODE) TYPE XFELD                  "Note 302988
            VALUE(P_WARN) TYPE XFELD.                      "Note 302988
  FIELD-SYMBOLS: <L_CLEARFIELD> TYPE SIMPLE.               "Note 302988
  FIELD-SYMBOLS: <_COBLFIELD> TYPE SIMPLE.
  FIELD-SYMBOLS: <L_BSEGFIELD> TYPE SIMPLE.                "Note 361453
  DATA: _SCREENNAME(20),
        L_CLEARNAME(20),                                   "Note 302988
        *TAB_FSKB LIKE TAB_FSKB.
  DATA: L_TABNAME(4).                                       "Note426808
  DATA: L_RC TYPE SYSUBRC.                                  "Note426808

  CHECK KON_GROUP GE '001' AND KON_GROUP LE '050'
     OR KON_GROUP GE '091' AND KON_GROUP LE '140'.        "#EC PORTABLE

*  READ TABLE G_TABLE_ITAB INDEX table-current_line.         "Note 568934

  CASE KON_GROUP.

*------- Zuordnung -----------------------------------------------------
    WHEN '001'.
      IF  ZACGL_ITEM_TBCTR-ZUONR        EQ SPACE
      AND P_CLEARMODE       IS INITIAL                     "Note 317969
      AND FELDAUSWAHL(1)    EQ '+'.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.        "Note 353450
        MESSAGE E393 WITH TEXT-ZUO ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.
      IF FELDAUSWAHL(1) EQ '-'.
         *TAB_FSKB = TAB_FSKB.
*        READ TABLE tab_fskb INDEX table-current_line.
* Begin of Note 568934
        IF G_KOMU = 'X' AND ZACGL_ITEM_TBCTR-ZUONR = ZACGL_ITEM_TBCTR-ZUONR
          AND NOT ZACGL_ITEM_TBCTR-ZUONR IS INITIAL.
          CALL FUNCTION 'CUSTOMIZED_MESSAGE'
            EXPORTING
              I_ARBGB = 'F5A'
              I_DTYPE = 'W'
              I_MSGNR = '374'
              I_VAR01 = TEXT-ZUO
              I_VAR02 = ZACGL_ITEM_TBCTR-ZUONR.
          IF 1 = 2.                      "to find where message is used.
            MESSAGE W374(F5A) WITH TEXT-ZUO ZACGL_ITEM_TBCTR-ZUONR.
          ENDIF.
          CLEAR: ZACGL_ITEM_TBCTR-ZUONR, ZACGL_ITEM_TBCTR-ZUONR.
        ELSEIF
          ZACGL_ITEM_TBCTR-ZUONR NE ZACGL_ITEM_TBCTR-ZUONR
          AND NOT ZACGL_ITEM_TBCTR-ZUONR IS INITIAL.   "error dial
*          tab_fskb = *tab_fskb.
          IF P_CLEARMODE IS INITIAL.                       "Note 302988
            SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.    "Note 353450
            MESSAGE E394 WITH TEXT-ZUO ZACGL_ITEM_TBCTR-HKONT.
          ELSE.                                            "Note 302988
            IF P_WARN = CHAR_X.                            "Note 302988
              MESSAGE W196(F5A) WITH TEXT-ZUO ZACGL_ITEM_TBCTR-HKONT.  "Note 302988
            ENDIF.                                         "Note 302988
*            CLEAR: acgl_item-zuonr, bseg-zuonr.            "Note 302988
          ENDIF.                                           "Note 302988
        ENDIF.
*        tab_fskb = *tab_fskb.
      ENDIF.

**------- Text ----------------------------------------------------------
*    WHEN '002'.
*      IF  bseg-sgtxt        EQ space
*      AND p_clearmode       IS INITIAL                     "Note 317969
*      AND feldauswahl+01(1) EQ '+'.
*        SET CURSOR FIELD screen-name LINE sy-stepl.        "Note 353450
*        MESSAGE e393 WITH text-txt bseg-hkont.
*      ENDIF.
*      IF feldauswahl+1(1) EQ '-'.
*         *tab_fskb = tab_fskb.
*        READ TABLE tab_fskb INDEX table-current_line.
** Begin of Note 568934
*        IF g_komu = 'X' AND acgl_item-sgtxt = lt_tab_fskb-sgtxt
*          AND NOT acgl_item-sgtxt IS INITIAL.
*          CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*            EXPORTING
*              i_arbgb = 'F5A'
*              i_dtype = 'W'
*              i_msgnr = '374'
*              i_var01 = text-txt
*              i_var02 = acgl_item-sgtxt.
*          IF 1 = 2.                      "to find where message is used.
*            MESSAGE w374(f5a) WITH text-txt acgl_item-sgtxt.
*          ENDIF.
*          CLEAR: acgl_item-sgtxt, bseg-sgtxt.
*        ELSEIF
*          acgl_item-sgtxt NE tab_fskb-sgtxt
*         AND NOT acgl_item-sgtxt IS INITIAL.   "error dial
*          tab_fskb = *tab_fskb.
*          IF p_clearmode IS INITIAL.                       "Note 302988
*            SET CURSOR FIELD screen-name LINE sy-stepl.    "Note 353450
*            MESSAGE e394 WITH text-txt bseg-hkont.
*          ELSE.                                            "Note 302988
*            IF p_warn = char_x.                            "Note 302988
*              MESSAGE w196(f5a) WITH text-txt bseg-hkont.  "Note 302988
*            ENDIF.                                         "Note 302988
*            CLEAR: acgl_item-sgtxt, bseg-sgtxt.            "Note 302988
*          ENDIF.                                           "Note 302988
*        ENDIF.
*        tab_fskb = *tab_fskb.
*      ENDIF.
*
*
*
**------- Valutadatum ---------------------------------------------------
    WHEN '006'.

*------------- Valutadatum evtl. vorschlagen ---------------------------
*      IF  t001-xvalv NE space
*      AND
*    IF ZACGL_ITEM_TBCTR-valut IS INITIAL
**     AND AKT-TYP = 'H'
** Only replace empty value if line item status is empty.
**    AND acgl_item-state IS INITIAL                         "Note  524274
*      AND feldauswahl+5(1) NE '-'.
*        ZACGL_ITEM_TBCTR-valut = sy-datlo.
**        IF g_mm_glvor = 'RMRP'.                      "Note 603154/829687
**          valut_proposal-buzei = ZACGL_ITEM_TBCTR-buzei.
**          valut_proposal-valut = ZACGL_ITEM_TBCTR-valut.
**          APPEND valut_proposal.
**        ENDIF.
*      ENDIF.
*      IF  ZACGL_ITEM_TBCTR-valut        EQ 0
*      AND p_clearmode       IS INITIAL                     "Note 317969
*      AND feldauswahl+05(1) EQ '+'
*      AND sy-dynnr          NE 123.
**        IF g_mm_glvor NE 'RMRP'                             "Note829687
**        OR ( g_mm_glvor EQ 'RMRP' AND t001-xvalv EQ space )."Note829687
**          SET CURSOR FIELD screen-name LINE sy-stepl.        "Note 353450
**          MESSAGE e393 WITH text-val bseg-hkont.
**        ENDIF.
*      ENDIF.
      "Note 302988
      IF FELDAUSWAHL+5(1) EQ '-'.
         *TAB_FSKB = TAB_FSKB.
*        READ TABLE tab_fskb INDEX table-current_line.
* Begin of Note 568934
        IF  ZACGL_ITEM_TBCTR-VALUT IS INITIAL.
          CALL FUNCTION 'CUSTOMIZED_MESSAGE'
            EXPORTING
              I_ARBGB = 'F5A'
              I_DTYPE = 'W'
              I_MSGNR = '374'
              I_VAR01 = TEXT-VAL
              I_VAR02 = ZACGL_ITEM_TBCTR-VALUT.
          IF 1 = 2.                      "to find where message is used.
            MESSAGE W374(F5A) WITH TEXT-VAL ZACGL_ITEM_TBCTR-VALUT.
          ENDIF.
*          CLEAR: acgl_item-valut, bseg-valut.
        ELSEIF
          ZACGL_ITEM_TBCTR-VALUT NE ZACGL_ITEM_TBCTR-VALUT
         AND NOT ZACGL_ITEM_TBCTR-VALUT IS INITIAL.   "error dial
          TAB_FSKB = *TAB_FSKB.
          IF P_CLEARMODE IS INITIAL.                       "Note 302988
            SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.    "Note 353450
            MESSAGE E394 WITH TEXT-VAL ZACGL_ITEM_TBCTR-HKONT.
          ELSE.                                            "Note 302988
            IF P_WARN = CHAR_X.                            "Note 302988
              MESSAGE W196(F5A) WITH TEXT-VAL ZACGL_ITEM_TBCTR-HKONT.  "Note 302988
            ENDIF.                                         "Note 302988
*            CLEAR: acgl_item-valut, bseg-valut.            "Note 302988
          ENDIF.                                           "Note 302988
        ENDIF.
        TAB_FSKB = *TAB_FSKB.
      ENDIF.
*
***------- Zahlungsbedingungsschlüssel -----------------------------------
**    WHEN '007'.
**      IF  bseg-zterm        EQ space
**      AND p_clearmode       IS INITIAL                     "Note 317969
**      AND feldauswahl+06(1) EQ '+'.
**        SET CURSOR FIELD screen-name LINE sy-stepl.        "Note 353450
**        MESSAGE e393 WITH text-zbd bseg-hkont.
**      ENDIF.
**      IF feldauswahl+6(1) EQ '-'.
**         *tab_fskb = tab_fskb.
**        READ TABLE tab_fskb INDEX table-current_line.
*** Begin of Note 568934
**        IF g_komu = 'X' AND acgl_item-zterm = lt_tab_fskb-zterm
**          AND NOT acgl_item-zterm IS INITIAL.
**          CALL FUNCTION 'CUSTOMIZED_MESSAGE'
**            EXPORTING
**              i_arbgb = 'F5A'
**              i_dtype = 'W'
**              i_msgnr = '374'
**              i_var01 = text-zbd
**              i_var02 = acgl_item-zterm.
**          IF 1 = 2.                      "to find where message is used.
**            MESSAGE w374(f5a) WITH text-zbd acgl_item-zterm.
**          ENDIF.
**          CLEAR: acgl_item-zterm, bseg-zterm.
**        ELSEIF
**          acgl_item-zterm NE tab_fskb-zterm
*** End of Note 568934
***(del)  if acgl_item-zterm ne tab_fskb-zterm   "user input, not derived
***(del)  IF ( acgl_item-zterm NE tab_fskb-zterm "Note 536015 Note 568934
***(del)       OR g_komu = 'X' )                 "Note 536015 Note 568934
**          AND NOT acgl_item-zterm IS INITIAL.   "error dial
**          tab_fskb = *tab_fskb.
**          IF p_clearmode IS INITIAL.                       "Note 302988
**            SET CURSOR FIELD screen-name LINE sy-stepl.    "Note 353450
**            MESSAGE e394 WITH text-zbd bseg-hkont.
**          ELSE.                                            "Note 302988
**            IF p_warn = char_x.                            "Note 302988
**              MESSAGE w196(f5a) WITH text-zbd bseg-hkont.  "Note 302988
**            ENDIF.                                         "Note 302988
**            CLEAR: acgl_item-zterm, bseg-zterm.            "Note 302988
**          ENDIF.                                           "Note 302988
**        ENDIF.
**        tab_fskb = *tab_fskb.
**      ENDIF.
*
*
*
*
*
**------- Kostenstelle --------------------------------------------------
*    WHEN '010'.
*      IF  bseg-kostl        EQ space
*      AND p_clearmode       IS INITIAL                     "Note 317969
*      AND feldauswahl+09(1) EQ '+'.
*        SET CURSOR FIELD screen-name LINE sy-stepl.        "Note 353450
*        MESSAGE e393 WITH text-kst bseg-hkont.
*      ENDIF.
*      IF feldauswahl+9(1) EQ '-'.
*         *tab_fskb = tab_fskb.
*        READ TABLE tab_fskb INDEX table-current_line.
** Begin of Note 568934
*        IF g_komu = 'X' AND acgl_item-kostl = lt_tab_fskb-kostl
*          AND NOT acgl_item-kostl IS INITIAL.
*          CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*            EXPORTING
*              i_arbgb = 'F5A'
*              i_dtype = 'W'
*              i_msgnr = '374'
*              i_var01 = text-kst
*              i_var02 = acgl_item-kostl.
*          IF 1 = 2.                      "to find where message is used.
*            MESSAGE w374(f5a) WITH text-kst acgl_item-kostl.
*          ENDIF.
*          CLEAR: acgl_item-kostl, bseg-kostl.
*        ELSEIF
*          acgl_item-kostl NE tab_fskb-kostl
** End of Note 568934
**(del)  if acgl_item-kostl ne tab_fskb-kostl   "user input, not derived
**(del)  IF ( acgl_item-kostl NE tab_fskb-kostl "Note 536015 Note 568934
**(del)       OR g_komu = 'X' )                 "Note 536015 Note 568934
*           AND NOT acgl_item-kostl IS INITIAL.       "error dialog
*          tab_fskb = *tab_fskb.
*          IF p_clearmode IS INITIAL.                       "Note 302988
*            SET CURSOR FIELD screen-name LINE sy-stepl.    "Note 353450
*            MESSAGE e394 WITH text-kst bseg-hkont.
*          ELSE.                                            "Note 302988
*            IF p_warn = char_x.                            "Note 302988
*              MESSAGE w196(f5a) WITH text-kst bseg-hkont.  "Note 302988
*            ENDIF.                                         "Note 302988
*            CLEAR: acgl_item-kostl, bseg-kostl.            "Note 302988
*          ENDIF.                                           "Note 302988
*        ENDIF.
*        tab_fskb = *tab_fskb.
*      ENDIF.
**------- Auftrag -------------------------------------------------------
*    WHEN '011'.
*      IF  bseg-aufnr        EQ space
*      AND p_clearmode       IS INITIAL                     "Note 317969
*      AND feldauswahl+10(1) EQ '+'.
*        SET CURSOR FIELD screen-name LINE sy-stepl.        "Note 353450
*        MESSAGE e393 WITH text-auf bseg-hkont.
*      ENDIF.
*      IF feldauswahl+10(1) EQ '-'.
*         *tab_fskb = tab_fskb.
*        READ TABLE tab_fskb INDEX table-current_line.
** Begin of Note 568934
*        IF g_komu = 'X' AND acgl_item-aufnr = lt_tab_fskb-aufnr
*          AND NOT acgl_item-aufnr IS INITIAL.
*          CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*            EXPORTING
*              i_arbgb = 'F5A'
*              i_dtype = 'W'
*              i_msgnr = '374'
*              i_var01 = text-auf
*              i_var02 = acgl_item-aufnr.
*          IF 1 = 2.                      "to find where message is used.
*            MESSAGE w374(f5a) WITH text-auf acgl_item-aufnr.
*          ENDIF.
*          CLEAR: acgl_item-aufnr, bseg-aufnr.
*        ELSEIF
*          acgl_item-aufnr NE tab_fskb-aufnr
** End of Note 568934
**(del)  if acgl_item-aufnr ne tab_fskb-aufnr   "user input, not derived
**(del)  IF ( acgl_item-aufnr NE tab_fskb-aufnr "Note 536015 Note 568934
**(del)       OR g_komu = 'X' )                 "Note 536015 Note 568934
*          AND NOT acgl_item-aufnr IS INITIAL.   "error dial
*          tab_fskb = *tab_fskb.
*          IF p_clearmode IS INITIAL.                       "Note 302988
*            SET CURSOR FIELD screen-name LINE sy-stepl.    "Note 353450
*            MESSAGE e394 WITH text-auf bseg-hkont.
*          ELSE.                                            "Note 302988
*            IF p_warn = char_x.                            "Note 302988
*              MESSAGE w196(f5a) WITH text-auf bseg-hkont.  "Note 302988
*            ENDIF.                                         "Note 302988
*            CLEAR: acgl_item-aufnr, bseg-aufnr.            "Note 302988
*          ENDIF.                                           "Note 302988
*        ENDIF.
*        tab_fskb = *tab_fskb.
*      ENDIF.
**------- Profit-Center -------------------------------------------------
*    WHEN '042'.
*      IF  bseg-prctr        EQ space
*      AND p_clearmode       IS INITIAL                     "Note 317969
*      AND feldauswahl+41(1) EQ '+'.
*        SET CURSOR FIELD screen-name LINE sy-stepl.        "Note 353450
*        MESSAGE e393 WITH text-prc bseg-hkont.
*      ENDIF.
*      IF feldauswahl+41(1) EQ '-'.
*         *tab_fskb = tab_fskb.
*        READ TABLE tab_fskb INDEX table-current_line.
** Begin of Note 568934
*        IF g_komu = 'X' AND acgl_item-prctr = lt_tab_fskb-prctr
*          AND NOT acgl_item-prctr IS INITIAL.
*          CALL FUNCTION 'CUSTOMIZED_MESSAGE'
*            EXPORTING
*              i_arbgb = 'F5A'
*              i_dtype = 'W'
*              i_msgnr = '374'
*              i_var01 = text-prc
*              i_var02 = acgl_item-prctr.
*          IF 1 = 2.                      "to find where message is used.
*            MESSAGE w374(f5a) WITH text-prc acgl_item-prctr.
*          ENDIF.
*          CLEAR: acgl_item-prctr, bseg-prctr.
*        ELSEIF
*          acgl_item-prctr NE tab_fskb-prctr
** End of Note 568934
**(del)  if acgl_item-prctr ne tab_fskb-prctr   "user input, not derived
**(del)  IF ( acgl_item-prctr NE tab_fskb-prctr "Note 536015 Note 568934
**(del)       OR g_komu = 'X' )                 "Note 536015 Note 568934
*          AND NOT acgl_item-prctr IS INITIAL.   "error dial
*          tab_fskb = *tab_fskb.
*          IF p_clearmode IS INITIAL.                       "Note 302988
*            SET CURSOR FIELD screen-name LINE sy-stepl.    "Note 353450
*            MESSAGE e394 WITH text-prc bseg-hkont.
*          ELSE.                                            "Note 302988
*            IF p_warn = char_x.                            "Note 302988
*              MESSAGE w196(f5a) WITH text-prc bseg-hkont.  "Note 302988
*            ENDIF.                                         "Note 302988
*            CLEAR: acgl_item-prctr, bseg-prctr.            "Note 302988
*          ENDIF.                                           "Note 302988
*        ENDIF.
*        tab_fskb = *tab_fskb.
*      ENDIF.
*
*
*** Immo-Felder: Sonderlocke
**    WHEN '046'.
**      char(20) = screen-name.
**      ASSIGN (screen-name) TO <field>.                     "Note 302988
**      IF  bseg-imkey        EQ space
**      AND p_clearmode       IS INITIAL                     "Note 317969
**      AND feldauswahl+45(1) EQ '+'.
**        SET CURSOR FIELD screen-name LINE sy-stepl.        "Note 353450
**        MESSAGE e138(f5a) WITH bseg-hkont.
**      ENDIF.
**      IF feldauswahl+45(1) EQ '-'
**      AND NOT bseg-imkey IS INITIAL.
**        IF p_clearmode IS INITIAL.                         "Note 302988
**          SET CURSOR FIELD screen-name LINE sy-stepl.      "Note 353450
**          MESSAGE e139(f5a) WITH bseg-hkont.
**        ELSE.                                              "Note 302988
**          IF p_warn = char_x.                              "Note 302988
**            MESSAGE w197(f5a) WITH bseg-hkont.             "Note 302988
**          ENDIF.                                           "Note 302988
**          CLEAR bseg-imkey.                                "Note 302988
**        ENDIF.                                             "Note 302988
**      ENDIF.
**      IF feldauswahl+45(1) EQ '-' AND                      "Note 302988
**         p_clearmode = char_x           .                  "Note 302988
**        ASSIGN (screen-name) TO <l_clearfield>.            "Note 302988
**        CLEAR <l_clearfield>.                              "Note 302988
**      ENDIF.                                               "Note 302988
*
*
*
***------- Sonstige über ASSIGN-Technik ----------------------------------
**    WHEN OTHERS.
**      DATA: ld_name(132).
*** (del) if last_assgn ne screen-name.                      "Note 330469
*** (del)   last_assgn = screen-name.                        "Note 330469
**      ASSIGN (screen-name) TO <field>.
**      CASE screen-name.                                     "Note426808
**        WHEN 'ACGL_ITEM-ERLKZ'.                             "Note426808
**          l_tabname = 'BSEZ'.                               "Note426808
**        WHEN OTHERS.                                        "Note426808
**          l_tabname = 'BSEG'.                               "Note426808
**      ENDCASE.                                              "Note426808
**      IF kon_group LE '050'.                              "#EC PORTABLE
**        i = kon_group - 1.
**        ASSIGN feldauswahl+i(1) TO <fausw>.
**      ELSE.
**        i = kon_group - 91.
**        ASSIGN feldauswahl2+i(1) TO <fausw>.
**      ENDIF.
*** (del) endif.                                             "Note 330469
**
**      CLEAR char.                                          "Note 361453
*** ERP05 save fieldname
**      IF screen-name(13) = 'ACGL_ITEM_GEN'.
**        PERFORM gen_get_fieldname USING screen-name
**                                        CHANGING char.
**        CONCATENATE 'ACGL_ITEM-' char INTO ld_name.
**      ELSE.
**        ld_name = screen-name.
**      ENDIF.
*** fieldname
**      char = ld_name+9(20).
***      SHIFT char UP TO '-'.                                "Note 361453
*** (del) concatenate 'BSEG' char(16) into char.  "Note 361453 Note426808
**      CONCATENATE l_tabname char(16) INTO char.             "Note426808
**      ASSIGN (char) TO <l_bsegfield>.                      "Note 361453
***  PRODPER (IS-OIL) only in BSEG-APPEND available
**      IF sy-subrc = 0.                                      "ERP05
*** (del) if  <field> is initial                             "Note 361453
**        IF  <l_bsegfield> IS INITIAL                         "Note 361453
**        AND p_clearmode IS INITIAL                           "Note 317969
**        AND <fausw> EQ '+'.
**          PERFORM ueberschrift_lesen(sapfs003) USING ld_name char(20).
**          IF char IS INITIAL.                               "Note426808
**            PERFORM schluesselwort_lesen1(sapfs003)         "Note426808
***                   USING screen-name                       "Note426808
**                    USING ld_name                           "ERP05
**                          char                              "Note426808
**                          l_rc.                             "Note426808
**          ENDIF.                                            "Note426808
**          SET CURSOR FIELD screen-name LINE sy-stepl.        "Note 353450
**          MESSAGE e393 WITH char(20) bseg-hkont.
**        ENDIF.
**      ENDIF.                                                "ERP05
***      IF  NOT <FIELD> IS INITIAL
***      AND <FAUSW> EQ '-'.
***        CONCATENATE 'COBL_CHECKED-' SCREEN-NAME+10 INTO _SCREENNAME.
***        ASSIGN (_SCREENNAME) TO <_COBLFIELD>.
***        IF <FIELD> NE <_COBLFIELD>.
***          PERFORM UEBERSCHRIFT_LESEN(SAPFS003) USING
***                                              SCREEN-NAME CHAR(20).
***          MESSAGE E394 WITH CHAR(20) BSEG-HKONT.
***        ENDIF.
***      ENDIF.
**
**      IF <fausw> EQ '-'.
**         *tab_fskb = tab_fskb.
**        READ TABLE tab_fskb INDEX table-current_line.
**        IF screen-name(10) = 'ACGL_ITEM-'.
**          CONCATENATE 'TAB_FSKB-' screen-name+10 INTO _screenname.
**        ELSEIF screen-name(13) = 'ACGL_ITEM_GEN'.
**          DATA: ls_match TYPE fagl_tcmatch.
**          READ TABLE gt_match INTO ls_match INDEX screen-name+22(1).
**          IF sy-subrc = 0.
**            CONCATENATE 'TAB_FSKB-' ls_match-ori_field+10 INTO _screenname.
**          ENDIF.
**        ENDIF.
**        ASSIGN (_screenname) TO <_coblfield>.
***  PRODPER (IS-OIL) only in BSEG-APPEND available
**        IF sy-subrc = 0.                                    "ERP05
**          IF <field> NE <_coblfield>     "user input, not derived
**            AND NOT <field> IS INITIAL.  "error dialog
**            tab_fskb = *tab_fskb.
**            IF screen-name(10) = 'ACGL_ITEM-'.
**              ld_name = screen-name.
**            ELSEIF screen-name(13) ='ACGL_ITEM_GEN'.
**              ld_name = ls_match-ori_field.
**            ENDIF.
**            PERFORM ueberschrift_lesen(sapfs003) USING
**                                          ld_name char(20). "ERP05
**            IF char IS INITIAL.                             "Note426808
**              PERFORM schluesselwort_lesen1(sapfs003)       "Note426808
**                       USING ld_name                        "ERP05
**                            char                            "Note426808
**                            l_rc.                           "Note426808
**            ENDIF.                                          "Note426808
**            IF p_clearmode IS INITIAL.                       "Note 302988
**              SET CURSOR FIELD screen-name LINE sy-stepl.    "Note 353450
**              MESSAGE e394 WITH char(20) bseg-hkont.
**            ELSE.                                            "Note 302988
*** (del)     concatenate 'BSEG-' screen-name+10  "Note 302988 Note426808
*** (del)       into l_clearname.                 "Note 302988 Note426808
**              CONCATENATE l_tabname '-' ld_name+10          "ERP05
**               INTO l_clearname.                            "Note426808
**              ASSIGN (l_clearname) TO <l_clearfield>.        "Note 302988
**              IF sy-subrc = 0.                               "Note 302988
**                IF p_warn = char_x.                          "Note 302988
**                  MESSAGE w196(f5a) WITH char(20) bseg-hkont."Note 302988
**                ENDIF.                                       "Note 302988
**                CLEAR <l_clearfield>.                        "Note 302988
*** (del)         replace 'BSEG' with 'ACGL_ITEM' "Note 302988 Note426808
**                REPLACE l_tabname WITH 'ACGL_ITEM'          "Note426808
**                 INTO l_clearname.                          "Note 302988
**                ASSIGN (l_clearname) TO <l_clearfield>.      "Note 302988
**                CLEAR <l_clearfield>.                        "Note 302988
**              ELSE.                                          "Note 302988
**                SET CURSOR FIELD screen-name LINE sy-stepl.  "Note 353450
**                MESSAGE e394 WITH char(20) bseg-hkont.       "Note 302988
**              ENDIF.                                         "Note 302988
**            ENDIF.                                           "Note 302988
**          ENDIF.
*        ENDIF.                                              "ERP05
*        tab_fskb = *tab_fskb.
*      ENDIF.


  ENDCASE.
ENDFORM.                               " KONTIERUNG_PRUEFEN_0100



*&---------------------------------------------------------------------*
*&      Form  gen_get_modif1
*&---------------------------------------------------------------------*
FORM GEN_GET_MODIF1  USING    I_NAME    TYPE C
                     CHANGING C_GROUP1  TYPE C.
  DATA: LS_MATCH TYPE FAGL_TCMATCH,
        LD_INDEX TYPE I,
        LD_TABNAME(30),
        LD_FIELDNAME(30).

* read sorted table gt_match
  IF I_NAME+22(1) CA '12345'.
    LD_INDEX = I_NAME+22(1).
    READ TABLE GT_MATCH INDEX LD_INDEX INTO LS_MATCH.
    IF SY-SUBRC = 0.
      C_GROUP1 = LS_MATCH-MODIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " gen_get_modif1

*&---------------------------------------------------------------------*
*&      Module  SCHNELLERFASSUNG_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SCHNELLERFASSUNG_0100 INPUT.
  IF SY-UCOMM NE 'BACK'
 AND SY-UCOMM NE 'CANCEL'
   AND SY-UCOMM NE 'EXIT'
   AND SY-UCOMM NE 'SOC_01'
    AND SY-UCOMM NE 'B03'
    AND SY-UCOMM NE 'EBR2'.
    PERFORM CHECK_ACCOUNT_CHANGED.
  ENDIF.
ENDMODULE.                 " SCHNELLERFASSUNG_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  CHECK_ACCOUNT_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_ACCOUNT_CHANGED .

  READ TABLE G_TABLE_ITAB INDEX TABLE-CURRENT_LINE
       INTO G_TABLE_WA.
*Processing
  PERFORM CHECK_ACTIVI_FIJO_CHANGED.
  IF RF05A-BUSCS EQ 'R'.
    IF  G_TABLE_WA-ANLN1 EQ SPACE AND G_TABLE_WA-SHKZG = 'S'.
      G_TABLE_WA-BSCHL = '40'.
    ELSE.
      IF  G_TABLE_WA-ANLN1 NE SPACE AND G_TABLE_WA-SHKZG = 'S'.
        G_TABLE_WA-BSCHL = '70'.
      ELSE.
        IF  G_TABLE_WA-ANLN1 EQ SPACE AND G_TABLE_WA-SHKZG = 'H'.
          G_TABLE_WA-BSCHL = '50'.
        ELSE.
          IF  G_TABLE_WA-ANLN1 NE SPACE AND G_TABLE_WA-SHKZG = 'H'.
            G_TABLE_WA-BSCHL = '75'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF RF05A-BUSCS EQ 'G'.
      IF  G_TABLE_WA-ANLN1 EQ SPACE AND G_TABLE_WA-SHKZG = 'S'.
        G_TABLE_WA-BSCHL = '40'.
      ELSE.
        IF  G_TABLE_WA-ANLN1 NE SPACE AND G_TABLE_WA-SHKZG = 'S'.
          G_TABLE_WA-BSCHL = '70'.
        ELSE.
          IF  G_TABLE_WA-ANLN1 EQ SPACE AND G_TABLE_WA-SHKZG = 'H'.
            G_TABLE_WA-BSCHL = '50'.
          ELSE.
            IF  G_TABLE_WA-ANLN1 NE SPACE AND G_TABLE_WA-SHKZG = 'H'.
              G_TABLE_WA-BSCHL = '75'.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF G_TABLE_WA-HKONT IS NOT INITIAL.
    CLEAR: FAUS1, FAUS2, FAUS, ZSTATUS_CAMPO.
    REFRESH ZSTATUS_CAMPO.
    CALL FUNCTION 'FI_FIELD_SELECTION_DETERMINE'
      EXPORTING
        I_BUKRS = G_TABLE_WA-BUKRS
        I_SAKNR = G_TABLE_WA-HKONT
        I_BSCHL = G_TABLE_WA-BSCHL
      IMPORTING
        E_FAUS1 = FAUS1
        E_FAUS2 = FAUS2.
    FAUS = FAUS1.
    FAUS+90(50) = FAUS2.
    CALL FUNCTION 'ZREPARE_FIELD_SELECT_STRING'
      EXPORTING
        INCOMING_STRING = FAUS
        STRING_ID       = 'SKB1-FAUS1 '
        TEXT1           = TEXT1
        TEXT2           = FSTTX
        XNODISP         = 'X'
        XCHANGE         = SPACE
      TABLES
        ZSTATUS_CAMPO   = ZSTATUS_CAMPO.
    IF ZSTATUS_CAMPO[] IS NOT INITIAL.
      LOOP AT SCREEN.
        CHECK SCREEN-GROUP4 = '001'.
        READ TABLE ZSTATUS_CAMPO WITH  KEY FELDN = SCREEN-NAME+17(10).
        IF SY-SUBRC EQ 0.
* Valida Campo Abligatoio.
          IF ZSTATUS_CAMPO-XOBLG EQ 'X'.
            PERFORM VALIDA_CAMPO_ABLIGATORIO USING SCREEN-GROUP1.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  MODIFY G_TABLE_ITAB
     FROM G_TABLE_WA
     INDEX TABLE-CURRENT_LINE.
  IF SY-SUBRC NE 0.
    APPEND G_TABLE_WA TO G_TABLE_ITAB.
  ENDIF.
ENDFORM.                    "CHECK_ACCOUNT_CHANGED
" CHECK_ACCOUNT_CHANGED
*&---------------------------------------------------------------------*
*&      Module  PRUEBA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PRUEBA OUTPUT.
*  PERFORM CHECK_ACCOUNT_CHANGED.
*  PERFORM CHECK_ACCOUNT_CHANGED.

ENDMODULE.                 " PRUEBA  OUTPUT
*&---------------------------------------------------------------------*
*&      Form  VALIDA_CAMPO_ABLIGATORIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SCREEN_NAME  text
*----------------------------------------------------------------------*
FORM VALIDA_CAMPO_ABLIGATORIO  USING   P_SCREEN_GROUP4.
  CASE P_SCREEN_GROUP4.
    WHEN '5'.
      IF ZINVFO-SGTXT EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME.
        MESSAGE E393 WITH 'Texto posición del Acreedor' ZINVFO-LIFNR.
      ENDIF.
    WHEN '6'.
      IF ZINVFO-ZZMOT_EMIS EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME.
        MESSAGE E393 WITH 'Motivos de emisión' ZINVFO-LIFNR.
      ENDIF.

    WHEN '7'.
      IF ZINVFO-ZZRUT_TERC EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME.
        MESSAGE E393 WITH 'RUT de Terceros (Gestión)' ZINVFO-LIFNR.
      ENDIF.

    WHEN '8'.
      IF ZINVFO-ZZ_AGENCIA EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME.
        MESSAGE E393 WITH 'Códigos de Agencia' ZINVFO-LIFNR.
      ENDIF.
    WHEN '100'.
      IF ZACGL_ITEM_TBCTR-VALUT EQ '00000000'.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Fecha Valor' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '101'.
      IF ZACGL_ITEM_TBCTR-ZUONR EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Número de asignación' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '102'.
      IF ZACGL_ITEM_TBCTR-SGTXT EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Texto posición' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '103'.
      IF ZACGL_ITEM_TBCTR-KOSTL EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Centro de Costo' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '104'.
      IF ZACGL_ITEM_TBCTR-AUFNR EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Número de orden' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '105'.
      IF ZACGL_ITEM_TBCTR-ANBWA EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Clase de movimiento' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '106'.
      IF ZACGL_ITEM_TBCTR-ANLN1 EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Número principal de activo fijo' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '107'.
      IF ZACGL_ITEM_TBCTR-ANLN2 EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Subnúmero de activo fijo' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '108'.
      IF ZACGL_ITEM_TBCTR-PRCTR EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Centro de beneficio' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '109'.
      IF ZACGL_ITEM_TBCTR-ZZPRESTAC EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Prestación' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '110'.
      IF ZACGL_ITEM_TBCTR-ZZUNID_PRO EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Códigos de Unidad y Códigos de Producto' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '111'.
      IF ZACGL_ITEM_TBCTR-ZZDESC_EST EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Códigos de Descuento y Códigos de Estamento' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '112'.
      IF ZACGL_ITEM_TBCTR-ZZMOT_EMIS EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Motivos de emisión' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '113'.
      IF ZACGL_ITEM_TBCTR-ZZRUT_TERC EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'RUT de Terceros (Gestión)' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.

    WHEN '114'.
      IF ZACGL_ITEM_TBCTR-ZZ_AGENCIA EQ SPACE.
        SET CURSOR FIELD SCREEN-NAME LINE SY-STEPL.
        MESSAGE E393 WITH 'Códigos de Agencia' ZACGL_ITEM_TBCTR-HKONT.
      ENDIF.







  ENDCASE.
ENDFORM.                    " VALIDA_CAMPO_ABLIGATORIO

*&---------------------------------------------------------------------*
*&      Module  SATUS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SATUS INPUT.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      INFO   = TEXT-E14
      NAME   = 'ICON_CHECKED'
    IMPORTING
      RESULT = ZACGL_ITEM_TBCTR-STATE.
ENDMODULE.                 " SATUS  INPUT
*&---------------------------------------------------------------------*
*&      Form  GET_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_FIELD .
  IF G_TABLE_WA-HKONT IS NOT INITIAL.
*   AND G_TABLE_WA-STATE IS NOT  INITIAL

    CLEAR: FAUS1, FAUS2, FAUS, ZSTATUS_CAMPO.
    REFRESH ZSTATUS_CAMPO.
    CALL FUNCTION 'FI_FIELD_SELECTION_DETERMINE'
      EXPORTING
        I_BUKRS = G_TABLE_WA-BUKRS
        I_SAKNR = G_TABLE_WA-HKONT
        I_BSCHL = G_TABLE_WA-BSCHL
      IMPORTING
        E_FAUS1 = FAUS1
        E_FAUS2 = FAUS2.
    FAUS = FAUS1.
    FAUS+90(50) = FAUS2.
    CALL FUNCTION 'ZREPARE_FIELD_SELECT_STRING'
      EXPORTING
        INCOMING_STRING = FAUS
        STRING_ID       = 'SKB1-FAUS1 '
        TEXT1           = TEXT1
        TEXT2           = FSTTX
        XNODISP         = 'X'
        XCHANGE         = SPACE
      TABLES
        ZSTATUS_CAMPO   = ZSTATUS_CAMPO.
    IF ZSTATUS_CAMPO[] IS NOT INITIAL.
      LOOP AT SCREEN.
        READ TABLE ZSTATUS_CAMPO WITH  KEY FELDN = SCREEN-NAME+17(10).
        IF SY-SUBRC EQ 0.
          IF ZSTATUS_CAMPO-XNODI EQ 'X'.
            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT SCREEN.
      IF SCREEN-NAME+17(10) EQ 'HKONT'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-NAME+17(10) EQ 'ANBWA'.
        READ TABLE ZSTATUS_CAMPO WITH  KEY FELDN = 'ANLN1'.
        IF SY-SUBRC EQ 0.
          IF ZSTATUS_CAMPO-XNODI EQ 'X'.
            SCREEN-INPUT = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " GET_FIELD
*&---------------------------------------------------------------------*
*&      Form  CHECK_ACTIVI_FIJO_CHANGED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_ACTIVI_FIJO_CHANGED.
  DATA: ANLKL LIKE ANLA-ANLKL,
        KTOGR LIKE ANKA-KTOGR.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE ANLKL  INTO  ANLKL
*    FROM ANLA
*  WHERE BUKRS EQ  G_TABLE_WA-BUKRS
*  AND      ANLN1 EQ  G_TABLE_WA-ANLN1
*  AND       ANLN2 EQ  G_TABLE_WA-ANLN2.
*
* NEW CODE
  SELECT ANLKL
  UP TO 1 ROWS   INTO  ANLKL
    FROM ANLA
  WHERE BUKRS EQ  G_TABLE_WA-BUKRS
  AND      ANLN1 EQ  G_TABLE_WA-ANLN1
  AND       ANLN2 EQ  G_TABLE_WA-ANLN2 ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF SY-SUBRC EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE KTOGR  INTO KTOGR
*      FROM ANKA
*    WHERE  ANLKL = ANLKL.
*
* NEW CODE
    SELECT KTOGR
    UP TO 1 ROWS   INTO KTOGR
      FROM ANKA
    WHERE  ANLKL = ANLKL ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  KTANSW  INTO G_TABLE_WA-HKONT
*        FROM  T095
*        WHERE KTOPL EQ 'B100'
*        AND   KTOGR EQ  KTOGR
*        AND   AFABE EQ  '01'.
*
* NEW CODE
      SELECT KTANSW
      UP TO 1 ROWS   INTO G_TABLE_WA-HKONT
        FROM  T095
        WHERE KTOPL EQ 'B100'
        AND   KTOGR EQ  KTOGR
        AND   AFABE EQ  '01' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.
  ELSE.
*DESPUES LA PROGRAMA
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE ANLKL  INTO  ANLKL
*       FROM ANLA
*     WHERE BUKRS EQ  G_TABLE_WA-BUKRS
*     AND      ANLN1 EQ  G_TABLE_WA-ANLN1.
*
* NEW CODE
    SELECT ANLKL
    UP TO 1 ROWS   INTO  ANLKL
       FROM ANLA
     WHERE BUKRS EQ  G_TABLE_WA-BUKRS
     AND      ANLN1 EQ  G_TABLE_WA-ANLN1 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF SY-SUBRC EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE KTOGR  INTO KTOGR
*        FROM ANKA
*      WHERE  ANLKL = ANLKL.
*
* NEW CODE
      SELECT KTOGR
      UP TO 1 ROWS   INTO KTOGR
        FROM ANKA
      WHERE  ANLKL = ANLKL ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF SY-SUBRC EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE  KTANSW  INTO G_TABLE_WA-HKONT
*          FROM  T095
*          WHERE KTOPL EQ 'B100'
*          AND   KTOGR EQ  KTOGR
*          AND   AFABE EQ  '01'.
*
* NEW CODE
        SELECT KTANSW
        UP TO 1 ROWS   INTO G_TABLE_WA-HKONT
          FROM  T095
          WHERE KTOPL EQ 'B100'
          AND   KTOGR EQ  KTOGR
          AND   AFABE EQ  '01' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.
    ENDIF.
  ENDIF.
  MODIFY G_TABLE_ITAB
    FROM G_TABLE_WA
    INDEX TABLE-CURRENT_LINE.


ENDFORM.                    " CHECK_ACTIVI_FIJO_CHANGED
