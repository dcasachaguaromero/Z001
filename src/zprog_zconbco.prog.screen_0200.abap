
PROCESS BEFORE OUTPUT.

  MODULE status_0200.

  MODULE proteje_0200.

PROCESS AFTER INPUT.
  CHAIN.
    FIELD ZCB_ITER_CC_EST-CODITER.
*    FIELD zfipg001_est-descr.
    MODULE valido-pantalla_0200.
  ENDCHAIN.

  MODULE user_command_0200.
