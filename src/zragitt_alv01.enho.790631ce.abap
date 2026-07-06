"Name: \PR:RAGITT_ALV01\FO:TCOLLECT_FUELLEN\SE:END\EI
ENHANCEMENT 0 ZRAGITT_ALV01.

  IF ( t086-srtvar EQ 'ZBAN' OR t086-srtvar EQ 'ZCRV' ) and
       gt_zz_alv01[] is not INITIAL.
     CALL FUNCTION 'ZAF_RAGITT_ALV01'
         EXPORTING
            i_berdatum        = berdatum
         tables
            itab_header       = <itab_data>[]
            itab_data         = gt_zz_alv01[].

     clear gt_zz_alv01[].
  ENDIF.
ENDENHANCEMENT.
