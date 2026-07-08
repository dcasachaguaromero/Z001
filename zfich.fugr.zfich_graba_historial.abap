FUNCTION ZFICH_GRABA_HISTORIAL.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(BUKRS) TYPE  BUKRS
*"     VALUE(RUT) TYPE  STCD1
*"     VALUE(HBKID) TYPE  HBKID
*"     VALUE(HKTID) TYPE  HKTID
*"     VALUE(CHECT) TYPE  CHECT
*"     VALUE(FECHA) TYPE  BUDAT
*"     VALUE(HORA) TYPE  TIME_
*"     VALUE(ESTADO) TYPE  ZFICH001-ESTADO
*"     VALUE(USUARIO) TYPE  UNAME
*"  EXPORTING
*"     VALUE(RESULTADO) TYPE  RESULT
*"----------------------------------------------------------------------

clear zfich001.
Resultado = '0'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single lifnr into zfich001-lifnr from VF_KRED
*                                        where  bukrs = bukrs
*                                        and    stcd1 = rut.
*
* NEW CODE
SELECT lifnr
UP TO 1 ROWS  into zfich001-lifnr from VF_KRED
                                        where  bukrs = bukrs
                                        and    stcd1 = rut ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
zfich001-bukrs     = bukrs.
zfich001-hbkid     = hbkid.
zfich001-hktid     = hktid.
zfich001-chect     = chect.
zfich001-fecha_reg = FECHA.
zfich001-hora_reg  = HORA.
zfich001-estado    = ESTADO.
zfich001-usuario   = USUARIO.
insert zfich001.

if sy-subrc = '0'.
  Resultado = '1'.
endif.

ENDFUNCTION.
