
clear gv_stawn.

select single stawn from eipo into gv_stawn
                    where exnum = IS_BIL_INVOICE-HD_GEN-EXNUM
                    and   expos = GS_IT_GEN-ITM_NUMBER.
if sy-subrc ne 0.
   clear gv_stawn.
endif.























