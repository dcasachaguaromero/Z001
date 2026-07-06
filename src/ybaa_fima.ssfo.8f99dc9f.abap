
incl_item = 'X'.
IF mhnk-gmvdt IS INITIAL.
IF mhnd-xzalb <> space OR mhnd-mansp <> space.
incl_item = space.
ENDIF.
IF t047b-xpost NE 'X'.
IF mhnd-xfael <> 'X'.            "only overdue items
incl_item = space.
ENDIF.
ENDIF.
ENDIF.





















