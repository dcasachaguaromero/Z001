
data: ls_key_data type rserob.
*
*   Materialbeleg
ls_key_data-taser   = 'SER03'.
ls_key_data-mblnr   = <TRAPTAB>-mblnr.
ls_key_data-mjahr   = <TRAPTAB>-mjahr.
ls_key_data-zeile   = <TRAPTAB>-zeile.

call function 'GET_SERNOS_OF_DOCUMENT'
exporting
key_data                  = ls_key_data
*   STATUS_PRE_READ           = ' '
*   EQUNR_CORR                = 'X'
tables
sernos                    = lt_sernos
*   SERXX                     =
EXCEPTIONS
KEY_PARAMETER_ERROR       = 1
NO_SUPPORTED_ACCESS       = 2
NO_DATA_FOUND             = 3
OTHERS                    = 4
.

if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
else.
h_sernos = 'x'.
endif.
























