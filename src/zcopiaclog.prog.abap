*&---------------------------------------------------------------------*
*& Report  ZCOPIACLOG
*&
*&---------------------------------------------------------------------*
*& Para iniciar poblamiento de nuevas tablas de LOG y FOLIOS x Banco
*&
*&---------------------------------------------------------------------*

REPORT  ZCOPIACLOG.
tables: zlog_bbva_vv,
        zlog_pago_bancos,
        zfolio_pagobanco,
        zfolio_bbva.

delete from zlog_pago_bancos.
select * from zlog_bbva_vv.
 if sy-subrc = 0.
    move-corresponding zlog_bbva_vv to zlog_pago_bancos.
    zlog_pago_bancos-ubnkl = 504.
    SHIFT zlog_pago_bancos-ubnkl LEFT DELETING LEADING space.
    insert zlog_pago_bancos.
endif.
endselect.

delete from zfolio_pagobanco.

select * from zfolio_bbva.
    move-corresponding zfolio_bbva to zfolio_pagobanco.
    zfolio_pagobanco-ubnkl  = 504.
    SHIFT zfolio_pagobanco-ubnkl LEFT DELETING LEADING space.
    zfolio_pagobanco-codigo = '001'.
    insert zfolio_pagobanco.
endselect.
    zfolio_pagobanco-bukrs  = 'CL01'.
    zfolio_pagobanco-ubnkl  = '027'.
    SHIFT zfolio_pagobanco-ubnkl LEFT DELETING LEADING space.
    zfolio_pagobanco-codigo = '001'.
    zfolio_pagobanco-folio  = 1200.
     insert zfolio_pagobanco.

    zfolio_pagobanco-bukrs  = 'CL01'.
    zfolio_pagobanco-ubnkl  = '012'.
    SHIFT zfolio_pagobanco-ubnkl LEFT DELETING LEADING space.
    zfolio_pagobanco-codigo = '001'.
    zfolio_pagobanco-folio  = 1200.
    insert zfolio_pagobanco.

    zfolio_pagobanco-bukrs  = 'CL01'.
    zfolio_pagobanco-ubnkl  = '024'.
    SHIFT zfolio_pagobanco-ubnkl LEFT DELETING LEADING space.
    zfolio_pagobanco-codigo = '001'.
    zfolio_pagobanco-folio  = 1200.
     insert zfolio_pagobanco.


    zfolio_pagobanco-bukrs  = 'CL01'.
    zfolio_pagobanco-ubnkl  = '036'.
    SHIFT zfolio_pagobanco-ubnkl LEFT DELETING LEADING space.
    zfolio_pagobanco-codigo = '001'.
    zfolio_pagobanco-folio  = 1200.
     insert zfolio_pagobanco.

    zfolio_pagobanco-bukrs  = 'CL24'.
    zfolio_pagobanco-ubnkl  = '012'.
    SHIFT zfolio_pagobanco-ubnkl LEFT DELETING LEADING space.
    zfolio_pagobanco-codigo = '001'.
    zfolio_pagobanco-folio  = 1200.
    insert zfolio_pagobanco.

    zfolio_pagobanco-bukrs  = 'CL24'.
    zfolio_pagobanco-ubnkl  = '027'.
    SHIFT zfolio_pagobanco-ubnkl LEFT DELETING LEADING space.
    zfolio_pagobanco-codigo = '001'.
    zfolio_pagobanco-folio  = 1200.
    insert zfolio_pagobanco.
