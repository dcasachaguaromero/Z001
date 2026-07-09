clear Z_include_section.
loop at it_resbd.
if it_resbd-KZKUP = ' ' and it_resbd-SHKZG ='S'.
Z_include_section = '1'.
exit.
endif.
endloop.
























