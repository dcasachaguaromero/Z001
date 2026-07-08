
PROCESS BEFORE OUTPUT.
  MODULE status_2001.
*
PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  FIELD zdte_fb60-bktxt.
  FIELD zdte_fb60-sgtxt.
  FIELD zdte_fb60-sgtxt_2.

  CHAIN.
    FIELD zdte_fb60-hkont.
    FIELD zdte_fb60-mwskz.
    FIELD zdte_fb60-kostl.
    MODULE check_obli.
  ENDCHAIN.

  MODULE user_command_2001.
