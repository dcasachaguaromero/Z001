
clear Z_include_section.
loop at it_resbd where
AUFPL =	<OPS>-AUFPL
and  APLZL	=      <OPS>-APLZL
and  beikz = space.
Z_include_section = '1'.
exit.
endloop.

























