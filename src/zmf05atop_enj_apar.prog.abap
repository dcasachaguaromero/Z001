*----------------------------------------------------------------------*
*   INCLUDE MF05ATOP_ENJ_APAR                                          *
*----------------------------------------------------------------------*

*---- Tabstrip for APAR Dialog Component -------------------------------
  CONTROLS ts TYPE TABSTRIP.        " Tabstrip

*---------- Communication with tax dialog ------------------------------
  DATA: ttaxes LIKE rtax1u12 OCCURS 5 WITH HEADER LINE.
  DATA: staxes LIKE rtax1u10.

*----------- Screentransport zum/vom Dynpro ----------------------------
  DATA: tdynpread LIKE dynpread OCCURS 1 WITH HEADER LINE.

*------------- Splitting information -----------------------------------
  DATA: splttab LIKE acsplt OCCURS 10 WITH HEADER LINE.
  DATA: spltwt LIKE with_itemx OCCURS 0 WITH HEADER LINE.

*-------------- Screen attributes --------------------------------------
  DATA: BEGIN OF iacscr OCCURS 0.       " Table to change screen
          INCLUDE STRUCTURE acscr.  " attributes of dialog component
  DATA: END OF iacscr.

*-------------- System table contents T020A ----------------------------
  DATA: it020a LIKE t020a OCCURS 0 WITH HEADER LINE.

*-----------------------------------------------------------------------
  DATA: activetab(4),              " Active Tab in Tabstrip
        dynnra    LIKE sy-dynnr,   " Subscreen number for adress
        dynnrd    LIKE sy-dynnr,   " Subscreen number for tab strip
        no_balance,                " Hide balance field
        old_buscs LIKE rf05a-buscs," Old Business Case
        prognr    LIKE sy-cprog,   " Program for Subscreen
        old_lstml LIKE t007a-lstml.
