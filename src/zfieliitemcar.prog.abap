*&---------------------------------------------------------------------*
*& Report  ZFIELIITEMCAR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFIELIITEMCAR.

tables: febvw,                      " Verwaltungssätze Elektronik Bankin
        febko, "*febko,              " Kopfsätze des Elektronischen Konto
        febep,                      " Einzelposten des Elektronischen Ko
        febre,                      " Referenzsatz zu einem Einzelposten
        febcl,                      " Clearing-Daten zu einem Einzelpost
        febkey.                     " Kurzschlüsselverwaltung
TYPES: BEGIN OF feb_struc,
         ANWND TYPE ANWND_EBKO,
         ABSND TYPE ABSND_EB,
         AZIDT TYPE AZIDT_EB,
         EMKEY TYPE EMKEY_EB,
         KUKEY TYPE KUKEY_EB,
         SUMSO TYPE SUMSO_EB,
         SUMHA TYPE SUMHA_EB,
         ESBTR TYPE ESBTR_EB,
         ANZES TYPE ANZES_EB,
      END OF feb_struc.

*---------------------------------------------------------------*
*  Parameters                                                   *
*---------------------------------------------------------------*
*------- Dateiangaben -------------------------------------------------
selection-screen  begin of block 1 with frame title text-177.
*SELECT-OPTIONS: S_ANWND FOR FEBKO-ANWND,
PARAMETERS:
                p_bukrs like febko-bukrs OBLIGATORY,                                  "note 620244
                p_hbkid like febko-hbkid OBLIGATORY,
                p_hktid like febko-hktid OBLIGATORY,
*                s_azdat for febko-azdat,
                p_aznum like febko-aznum OBLIGATORY,
                p_gjahr type gjahr.
*                s_ktonr FOR febko-ktonr,
*                s_waers like febko-waers.

select-options : s_esnum for febep-esnum no-extension obligatory.

PARAMETERS:
            p_sumso like febko-sumso,
            p_sumha like febko-sumha,
            p_esbtr like febko-esbtr.
selection-screen  end of block 1.
DATA: w_lines like sy-tabix.
data: it_febko TYPE STANDARD TABLE OF febko,
      it_febre TYPE STANDARD TABLE OF febre,
      it_febcl TYPE STANDARD TABLE OF febcl,
      wa_febko TYPE febko,
      it_febep TYPE STANDARD TABLE OF febep.
*      wa_febep type febep.
data: gjahr_n(4) type n,
      aznum_n(5) type n,
      w_azidt like febko-azidt,
      W_salini TYPE SSBTR_EB,
      W_debe TYPE SUMSO_EB,
      W_haber TYPE SUMHA_EB,
      W_salfin TYPE p,
      W_salfin2 TYPE p.

AT SELECTION-SCREEN.
  move: p_gjahr to gjahr_n,
        p_aznum to aznum_n.

  CONCATENATE gjahr_n aznum_n INTO w_azidt.
  SELECT * FROM febko CLIENT SPECIFIED INTO TABLE it_febko
      WHERE mandt = sy-mandt
            AND ANWND = '0001'
            AND azidt = w_azidt
            and aznum = p_aznum
            AND bukrs = p_bukrs
            AND hbkid = p_hbkid
            AND hktid = p_hktid.

    DESCRIBE TABLE it_febko LINES w_lines.
    IF w_lines = 1.
      LOOP AT it_febko INTO  wa_febko.
        check ( s_esnum-low eq wa_febko-ANZES AND s_esnum-high is INITIAL ) or ( s_esnum-high eq wa_febko-ANZES ).
        CLEAR: w_debe, w_haber, w_salini, w_salfin, w_lines.
        SELECT * FROM febep CLIENT SPECIFIED
          WHERE mandt = WA_FEBKO-MANDT
                AND KUKEY = WA_FEBKO-KUKEY
                AND esnum NOT IN s_esnum.

             IF febep-vozei = 'D'.
               w_debe = w_debe + febep-kwbtr * 100.
             ELSE.
               w_haber = w_haber + febep-kwbtr * 100.
             ENDIF.
             w_lines = w_lines + 1.
        ENDSELECT.
        IF wa_febko-ssvoz = 'H'.
          w_salfin = w_haber + wa_febko-ssbtr * 100 - w_debe.
        else.
          w_salfin = w_haber - wa_febko-ssbtr * 100 - w_debe.
        ENDIF.

        w_salfin2 = p_esbtr.
        IF w_salfin eq w_salfin2.
          w_salfin = w_salfin / 100.
          IF w_salfin < 0 .
            move 'D' TO wa_febko-ESVOZ.
            w_salfin = w_salfin * -1.
          ELSE.
            move 'C' TO wa_febko-ESVOZ.
          ENDIF.
          move w_salfin to wa_febko-ESBTR.
          move w_debe to wa_febko-SUMSO.
          move w_haber to wa_febko-SUMHA.
*          w_lines = wa_febko-ANZES - w_lines.
          move w_lines to wa_febko-ANZES.

          SELECT * FROM febep CLIENT SPECIFIED INTO TABLE it_febep
          WHERE mandt = WA_FEBKO-MANDT
                AND KUKEY = WA_FEBKO-KUKEY
                AND esnum IN s_esnum.

          SELECT * FROM febre CLIENT SPECIFIED INTO TABLE it_febre
          WHERE mandt = WA_FEBKO-MANDT
                AND KUKEY = WA_FEBKO-KUKEY
                AND esnum IN s_esnum.

          SELECT * FROM febcl CLIENT SPECIFIED INTO TABLE it_febcl
          WHERE mandt = WA_FEBKO-MANDT
                AND KUKEY = WA_FEBKO-KUKEY
                AND esnum IN s_esnum.

            DELETE febre FROM TABLE it_febre.
            DELETE febcl FROM TABLE it_febcl.
            DELETE febep FROM TABLE it_febep.
            MODIFY febko FROM wa_febko.
        ENDIF.
      ENDLOOP.
*      BREAK-POINT.
      message id '00' type 'S' number '398' with text-m01.
    ENDIF.
