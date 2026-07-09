PROCESS BEFORE OUTPUT.
  MODULE elimina_boton.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zv_t042 CURSOR nextline.
    MODULE liste_show_liste.
    MODULE lee_textos.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zv_t042-bukrs .
      FIELD zv_t042-butxt .
      FIELD zv_t042-zbukr .
      MODULE set_update_flag ON CHAIN-REQUEST.
      MODULE complete_zv_t042 ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zv_t042-bukrs .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
