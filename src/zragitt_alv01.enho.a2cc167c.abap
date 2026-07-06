"Name: \PR:RAGITT_ALV01\IC:RASORT_ALV04\SE:END\EI
ENHANCEMENT 0 ZRAGITT_ALV01.
 TYPES : begin of ty_zz_alv01,
           bukrs    type anlav-bukrs,
           anln1    type anlav-anln1,
           anln2    type anlav-anln2,
           anlkl    type anlav-anlkl,
           afabg    type anlb-afabg,
           gjahr    type anlcv-bukrs,
           afabe    type anlcv-afabe,
           zujhr    type anlcv-zujhr,
           zucod    type anlcv-zucod,
           berdatum type BRDATU,
           peraf    TYPE t093d-afblpe,
         end of ty_zz_alv01.

  DATA : gt_zz_alv01 TYPE TABLE OF ty_zz_alv01,
         wa_zz_alv01 TYPE ty_zz_alv01.
ENDENHANCEMENT.
