PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zvfi_ob52 CURSOR nextline.
    MODULE liste_show_liste.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zvfi_ob52-bukrs .
      FIELD zvfi_ob52-opvtx .
      MODULE actualiza_campos.
      MODULE set_update_flag ON CHAIN-REQUEST.
      MODULE complete_zvfi_ob52 ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zvfi_ob52-bukrs .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
