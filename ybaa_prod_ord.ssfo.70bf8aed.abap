* loop to see if the standard value texts are different
* this will be used for standard value headers
clear Z_WORK_CENTER.
Z_SAME_STD_VAL_KEY = '1'.
loop at it_rcr01.
if it_rcr01-vgwts <> z_work_center-vgwts
and not z_work_center-vgwts is initial.
Z_SAME_STD_VAL_KEY = '0'.
exit.
endif.
Z_WORK_CENTER = IT_RCR01.
endloop.
























