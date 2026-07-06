
PROCESS BEFORE OUTPUT.
  MODULE table_init.
  MODULE status_0100.
  MODULE dynpro_modification_1100.
  MODULE t_001_active_tab_set.
  MODULE balance.

  CALL SUBSCREEN t_001_sca
    INCLUDING g_t_001-prog g_t_001-subscreen.

  LOOP AT   g_table_itab
       INTO g_table_wa
       WITH CONTROL table
       CURSOR table-top_line.
    MODULE table_get_lines.
  ENDLOOP.

PROCESS AFTER INPUT.
  CALL SUBSCREEN t_001_sca.


  LOOP AT g_table_itab.
    CHAIN.
      FIELD zacgl_item_tbctr-state.
      FIELD zacgl_item_tbctr-bukrs.
      FIELD zacgl_item_tbctr-shkzg.
      FIELD zacgl_item_tbctr-mwskz.
      FIELD zacgl_item_tbctr-wrbtr.
      FIELD zacgl_item_tbctr-valut.
      FIELD zacgl_item_tbctr-zuonr.
      FIELD zacgl_item_tbctr-sgtxt.
      FIELD zacgl_item_tbctr-kokrs.
      FIELD zacgl_item_tbctr-kostl.
      FIELD zacgl_item_tbctr-aufnr.
      FIELD zacgl_item_tbctr-anbwa.
      FIELD zacgl_item_tbctr-hkont.
      FIELD zacgl_item_tbctr-prctr.
      FIELD zacgl_item_tbctr-konto_txt.
      FIELD zacgl_item_tbctr-zzprestac.
      FIELD zacgl_item_tbctr-zzunid_pro.
      FIELD zacgl_item_tbctr-zzdesc_est.
      FIELD zacgl_item_tbctr-zzmot_emis.
      FIELD zacgl_item_tbctr-zzrut_terc.
      FIELD zacgl_item_tbctr-zz_agencia.
      FIELD zacgl_item_tbctr-anln1.
      FIELD zacgl_item_tbctr-anln2.
      FIELD zacgl_item_tbctr-bschl.
      FIELD zacgl_item_tbctr-marksp.
      MODULE table_modify ON CHAIN-REQUEST.
    ENDCHAIN.

    CHAIN.
      FIELD zacgl_item_tbctr-state.
      FIELD zacgl_item_tbctr-bukrs.
      FIELD zacgl_item_tbctr-shkzg.
      FIELD zacgl_item_tbctr-mwskz.
      FIELD zacgl_item_tbctr-wrbtr.
      FIELD zacgl_item_tbctr-valut.
      FIELD zacgl_item_tbctr-zuonr.
      FIELD zacgl_item_tbctr-sgtxt.
      FIELD zacgl_item_tbctr-kokrs.
      FIELD zacgl_item_tbctr-kostl.
      FIELD zacgl_item_tbctr-aufnr.
      FIELD zacgl_item_tbctr-anbwa.
      FIELD zacgl_item_tbctr-hkont.
      FIELD zacgl_item_tbctr-prctr.
      FIELD zacgl_item_tbctr-konto_txt.
      FIELD zacgl_item_tbctr-zzprestac.
      FIELD zacgl_item_tbctr-zzunid_pro.
      FIELD zacgl_item_tbctr-zzdesc_est.
      FIELD zacgl_item_tbctr-zzmot_emis.
      FIELD zacgl_item_tbctr-zzrut_terc.
      FIELD zacgl_item_tbctr-zz_agencia.
      FIELD zacgl_item_tbctr-anln1.
      FIELD zacgl_item_tbctr-anln2.
      FIELD zacgl_item_tbctr-bschl.
      FIELD zacgl_item_tbctr-marksp.
      MODULE schnellerfassung_0100    ON CHAIN-INPUT.
      MODULE atributos_z              ON CHAIN-INPUT.
      MODULE val_objeto_co            ON CHAIN-INPUT.
      MODULE limpia_objet             ON CHAIN-INPUT.

    ENDCHAIN.
    FIELD zacgl_item_tbctr-marksp
    MODULE table_mark ON REQUEST.
  ENDLOOP.
  MODULE table_user_command.

  MODULE t_001_active_tab_get.
  MODULE balance_sal.
  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD zacgl_item_tbctr-sgtxt MODULE f4_sgtxt.
  FIELD zacgl_item_tbctr-mwskz MODULE f4_mwskz.
