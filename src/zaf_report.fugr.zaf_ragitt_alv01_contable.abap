FUNCTION ZAF_RAGITT_ALV01_CONTABLE.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_ANLAV) TYPE  ANLAV
*"     VALUE(I_BERDATUM) TYPE  DATUM
*"  EXPORTING
*"     REFERENCE(ZZ_BLDAT) TYPE  BLDAT
*"     REFERENCE(ZZ_BUDAT) TYPE  BUDAT
*"     REFERENCE(ZZ_BELNR) TYPE  BELNR_D
*"     REFERENCE(ZZ_GJAHR) TYPE  GJAHR
*"     REFERENCE(ZZ_XBLNR) TYPE  ZZ_XBLNR
*"--------------------------------------------------------------------
*
  CLEAR : zz_bldat ,
          zz_budat ,
          zz_belnr ,
          zz_gjahr ,
          zz_xblnr .
*
  SELECT SINGLE bldat, budat, belnr, gjahr, xblnr INTO @DATA(lw_anek)
       FROM anek  WHERE bukrs  EQ @i_anlav-bukrs
                  AND   anln1  EQ @i_anlav-anln1
                  AND   anln2  EQ @i_anlav-anln2
                  AND   gjahr  LE @i_berdatum(4)
                  AND   xblnr  NE @space
                  AND   awtyp  EQ 'BKPF'.
  CHECK sy-subrc EQ 0.
  zz_bldat = lw_anek-bldat.
  zz_budat = lw_anek-budat.
  zz_belnr = lw_anek-belnr.
  zz_gjahr = lw_anek-gjahr.
  zz_xblnr = lw_anek-xblnr.

ENDFUNCTION.
