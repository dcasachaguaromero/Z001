PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zfitr031 CURSOR nextline.
    MODULE liste_show_liste.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zfitr031-bukrs .
      FIELD zfitr031-hkont .
      FIELD zfitr031-zvalor .
      FIELD zfitr031-zzrut_terc .
      FIELD zfitr031-xref1 .
      FIELD zfitr031-zzprestac .
      FIELD zfitr031-zzdesc_est .
      FIELD zfitr031-xref2 .
      FIELD zfitr031-zzunid_pro .
      FIELD zfitr031-zlsch .
      FIELD zfitr031-zz_agencia .
      FIELD zfitr031-zzmot_emis .
      FIELD zfitr031-hbkid .
      FIELD zfitr031-zfpago .
      FIELD zfitr031-zgposi .
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zfitr031-bukrs .
      FIELD zfitr031-hkont .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
