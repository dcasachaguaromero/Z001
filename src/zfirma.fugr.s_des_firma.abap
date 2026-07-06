FUNCTION S_DES_FIRMA.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(SOURCE) TYPE  CHAR50
*"     VALUE(DESTINATION) TYPE  CHAR50
*"     VALUE(PWD) TYPE  CHAR50
*"     VALUE(RFCDEST) TYPE  RFCDES-RFCDEST
*"  EXPORTING
*"     REFERENCE(RESP) TYPE  CHAR50
*"----------------------------------------------------------------------

data: service_dest type rfcdes-rfcdest VALUE 'FIRMA_BM',
       worker_dest type rfcdes-rfcdest.

service_dest = RFCDEST.

call function 'BEGIN_COM_SESSION'

 exporting service_dest = service_dest

 importing worker_dest = worker_dest

 exceptions connect_to_com_service_failed = 1

 connect_to_com_worker_failed = 2

 others = 3.
 if sy-subrc eq 0.
 TRY.

 call function 'des_image_new' destination worker_dest

 exporting ori  = source

 des = Destination

 psw = pwd

 importing %RETURN = resp

EXCEPTIONs
com4abap_invoke_failure = 1.
IF sy-subrc = 1.
ENDIF.


 CATCH CX_SY_NO_HANDLER.


ENDTRY.
RESP = resp.
 call function 'END_COM_SESSION'

 exporting destination = worker_dest

 exceptions others = 1.
else.
  RESP = 'ERROR'.
endif.


ENDFUNCTION.
