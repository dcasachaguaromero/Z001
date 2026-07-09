PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zvfi_ob52_user CURSOR nextline.
    MODULE liste_show_liste.
  ENDLOOP.
  MODULE fill_substflds.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zvfi_ob52_user-bname .
      FIELD zvfi_ob52_user-modificar .
      FIELD zvfi_ob52_user-aprobar   MODULE verifica_aprob.
      FIELD zvfi_ob52_user-reporte.
      MODULE actualiza_campos.
      MODULE set_update_flag ON CHAIN-REQUEST.
      MODULE complete_zvfi_ob52_user ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zvfi_ob52_user-bname .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
