clear Z_include_section.
loop at it_afdld.
if not it_afdld-doknr is initial.
Z_INCLUDE_SECTION
= '1'.
exit.
endif.
endloop.
























