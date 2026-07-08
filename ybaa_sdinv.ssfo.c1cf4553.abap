
clear gv_stawn.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single stawn from eipo into gv_stawn
*                    where exnum = IS_BIL_INVOICE-HD_GEN-EXNUM
*                    and   expos = GS_IT_GEN-ITM_NUMBER.
*
* NEW CODE
SELECT stawn
UP TO 1 ROWS  from eipo into gv_stawn
                    where exnum = IS_BIL_INVOICE-HD_GEN-EXNUM
                    and   expos = GS_IT_GEN-ITM_NUMBER ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
if sy-subrc ne 0.
   clear gv_stawn.
endif.























