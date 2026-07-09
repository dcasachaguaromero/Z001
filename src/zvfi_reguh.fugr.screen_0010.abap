PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zvfi_reguh CURSOR nextline.
    MODULE liste_show_liste.
    MODULE oculta.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zvfi_reguh-laufd .
      FIELD zvfi_reguh-laufi .
      FIELD zvfi_reguh-xvorl .
      FIELD zvfi_reguh-zbukr .
      FIELD zvfi_reguh-lifnr .
      FIELD zvfi_reguh-kunnr .
      FIELD zvfi_reguh-empfg .
      FIELD zvfi_reguh-vblnr .
      FIELD zvfi_reguh-identif_pago.
      FIELD zvfi_reguh-ind_pago .
      FIELD zvfi_reguh-fecha_pago .
      FIELD zvfi_reguh-ind_devuelto .
      FIELD zvfi_reguh-fecha_devuelto .
      FIELD zvfi_reguh-ind_rechazo .
      FIELD zvfi_reguh-fecha_rechazo .
      FIELD zvfi_reguh-belnr_dev .
      FIELD zvfi_reguh-gjahr_dev .
      FIELD zvfi_reguh-ind_custodia .
      FIELD zvfi_reguh-fecha_custodia .
      FIELD zvfi_reguh-motivo_rechazo .
      FIELD zvfi_reguh-ind_entregado .
      FIELD zvfi_reguh-fecha_entregado .
      FIELD zvfi_reguh-ind_rescatado .
      FIELD zvfi_reguh-fecha_rescatado .
      FIELD zvfi_reguh-ind_redepo .
      FIELD zvfi_reguh-fecha_redepo .
      FIELD zvfi_reguh-glosa_redepo .
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zvfi_reguh-laufd .
      FIELD zvfi_reguh-laufi .
      FIELD zvfi_reguh-xvorl .
      FIELD zvfi_reguh-zbukr .
      FIELD zvfi_reguh-lifnr .
      FIELD zvfi_reguh-kunnr .
      FIELD zvfi_reguh-empfg .
      FIELD zvfi_reguh-vblnr .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.

  MODULE user_command.
