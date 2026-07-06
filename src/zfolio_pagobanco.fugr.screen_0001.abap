
PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zfolio_pagobanco CURSOR nextline.
    MODULE liste_show_liste.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zfolio_pagobanco-bukrs .
      FIELD zfolio_pagobanco-ubnkl .
      FIELD zfolio_pagobanco-codigo .
      FIELD zfolio_pagobanco-folio .
      FIELD zfolio_pagobanco-folio_propuesta.
      MODULE set_update_flag ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zfolio_pagobanco-bukrs .
      FIELD zfolio_pagobanco-ubnkl .
      FIELD zfolio_pagobanco-codigo .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
