PROCESS BEFORE OUTPUT.
  MODULE status.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zvfi_ob52_t001b CURSOR nextline.
    MODULE liste_show_liste.
    MODULE verifica_pantalla.
  ENDLOOP.
  MODULE fill_substflds.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zvfi_ob52_t001b-mkoar .
      FIELD zvfi_ob52_t001b-bkont .
      FIELD zvfi_ob52_t001b-vkont .
      FIELD zvfi_ob52_t001b-frye1 .
      FIELD zvfi_ob52_t001b-frpe1 .
      FIELD zvfi_ob52_t001b-toye1 .
      FIELD zvfi_ob52_t001b-tope1 .
      FIELD zvfi_ob52_t001b-frye2 .
      FIELD zvfi_ob52_t001b-frpe2 .
      FIELD zvfi_ob52_t001b-toye2 .
      FIELD zvfi_ob52_t001b-brgru .
      FIELD zvfi_ob52_t001b-tope2 .
      MODULE fagl_exit_t001bb ON CHAIN-REQUEST.
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zvfi_ob52_t001b-mkoar .
      FIELD zvfi_ob52_t001b-bkont .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.

PROCESS ON VALUE-REQUEST.                                   "1993365
*   Field V_t001bb-Mkoar module F4_mkoar_b.
                                                            "1993365
  FIELD zvfi_ob52_t001b-mkoar MODULE f4_mkoar_b.
