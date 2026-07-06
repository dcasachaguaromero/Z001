PROCESS BEFORE OUTPUT.
  MODULE detail_init.
*
PROCESS AFTER INPUT.
  MODULE detail_exit_command AT EXIT-COMMAND.
  MODULE detail_set_pfstatus.
  CHAIN.
    FIELD zfolio_pagobanco-bukrs .
    FIELD zfolio_pagobanco-ubnkl .
    FIELD zfolio_pagobanco-codigo .
    FIELD zfolio_pagobanco-folio .
    FIELD zfolio_pagobanco-folio_propuesta.
    MODULE set_update_flag ON CHAIN-REQUEST.
  ENDCHAIN.
  CHAIN.
    FIELD zfolio_pagobanco-bukrs .
    FIELD zfolio_pagobanco-ubnkl .
    FIELD zfolio_pagobanco-codigo .
    MODULE detail_pai.
  ENDCHAIN.
