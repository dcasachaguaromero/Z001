
PROCESS BEFORE OUTPUT.

  MODULE %_init_pbo.

  MODULE pf_status.

  MODULE busca_folio.


PROCESS AFTER INPUT.

CHAIN.
  FIELD p_num.

  MODULE validacion.
ENDCHAIN.

  MODULE %_back AT EXIT-COMMAND.

  MODULE BOTON.
