"Name: \PR:SAPMF05A\FO:REF_FUSSZEILE\SE:BEGIN\EI
ENHANCEMENT 0 ZMF05AFRO_REF_FUSSZEILE.
*
  break cv_user1.
  break cv_user2.

  data: begin of it_bseg occurs 0.
           include structure bseg.
  data: end of it_bseg.

  append bseg to it_bseg.

  EXPORT it_bseg = it_bseg TO MEMORY ID 'CREWVALUEBSEG'.
ENDENHANCEMENT.
