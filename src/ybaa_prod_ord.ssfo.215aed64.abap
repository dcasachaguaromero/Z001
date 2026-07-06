clear Z_include_section.
loop at it_resbd.
if it_resbd-KZKUP = 'X'.
Z_include_section = '1'.
exit.
endif.
endloop.
























