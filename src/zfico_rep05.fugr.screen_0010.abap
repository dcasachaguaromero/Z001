PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zfico_rep05 CURSOR nextline.
    MODULE liste_show_liste.
    MODULE lee_nombre.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zfico_rep05-clave  module valida_clave.
      FIELD zfico_rep05-nombre .
      FIELD zfico_rep05-bukrs .
      MODULE mueve_datos.
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zfico_rep05-clave .
      FIELD zfico_rep05-nombre .
      FIELD zfico_rep05-bukrs .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
