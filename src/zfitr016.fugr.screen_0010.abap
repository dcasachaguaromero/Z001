PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zfitr016 CURSOR nextline.
    MODULE liste_show_liste.
    MODULE lee_texto.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zfitr016-bukrs .
      FIELD zfitr016-convenio .
      FIELD zfitr016-codigo_cca .
      FIELD zfitr016-modo_servicio .
      FIELD zfitr016-contenido_nomina .
      FIELD zfitr016-plantilla_archivo .
      FIELD zfitr016-tipo_pago .
      FIELD zfitr016-tipo_rendicion .
      FIELD zfitr016-tipo_cartola .
      FIELD zfitr016-cta_cte.
      MODULE actuaiza_datos.
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zfitr016-bukrs .
      FIELD zfitr016-convenio .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
