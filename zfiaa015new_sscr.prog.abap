*&---------------------------------------------------------------------*
*&  Include  ZFIAA015NEW_SSCR.
*&---------------------------------------------------------------------*
selection-screen begin of block qsel
                          with frame title text-s02.
select-options SP$00001 for ANLA-BUKRS memory id BUK.
select-options SP$00002 for ANLA-ANLN1 memory id AN1.
select-options SP$00003 for ANLA-ANLN2 memory id AN2.
select-options SP$00004 for ANLA-ANLKL memory id ANK.
select-options SP$00006 for ANLA-ANLUE.
select-options SP$00007 for ANEP-BWASL memory id BWA.
select-options SP$00008 for ANEP-AFABE memory id AFB.
select-options SP$00010 for ANEP-BZDAT.
SELECT-OPTIONS SP$00011 for BKPF-bldat MEMORY ID bld.
select-options SP$00012 for ANEP-GJAHR memory id GJR.
selection-screen end of block qsel.
selection-screen begin of block stdsel with frame title text-s03.
parameters %layout type slis_vari modif id lay.
selection-screen end of block stdsel.
