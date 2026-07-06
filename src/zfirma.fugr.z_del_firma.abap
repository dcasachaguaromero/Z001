FUNCTION Z_DEL_FIRMA.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(DESTINATION) TYPE  CHAR50
*"  EXPORTING
*"     REFERENCE(RESP) TYPE  CHAR50
*"----------------------------------------------------------------------
data: file type RLGRAP-FILENAME.
file = DESTINATION.
CALL FUNCTION 'GUI_DELETE_FILE'
  EXPORTING
    FILE_NAME       = file
 EXCEPTIONS
   FAILED          = 1
   OTHERS          = 2
          .
IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.



ENDFUNCTION.
