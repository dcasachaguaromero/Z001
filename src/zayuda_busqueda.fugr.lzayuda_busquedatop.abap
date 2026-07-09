FUNCTION-POOL ZAYUDA_BUSQUEDA.              "MESSAGE-ID ..


type-pools: shlp.                      " for f4 function-exit parameters

include auth2top.
include rsebasis.

tables: edk13_sel.

constants: on(1)             type c                value 'X',
           off(1)            type c                value ' '.

data: ok_code     like sy-ucomm.
