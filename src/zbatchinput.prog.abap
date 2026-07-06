*&---------------------------------------------------------------------*
*&  Include           ZBATCHINPUT
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE ZCRP001                                                *
*----------------------------------------------------------------------*
*** mira tambien informe ZCRP001_TEST
DATA: bdcdata TYPE bdcdata occurs 100 with header line.
DATA: gv_mode   value 'N',
      gv_update value 'A'.

DATA: MODE_BDC    VALUE 'N',
      CALL_TRANSACTION,
      UPDATE_MODE VALUE 'A',
      bdcdata_tabix TYPE sy-tabix.



FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  IMPORT MODE_BDC TO MODE_BDC FROM MEMORY ID 'ZCRP001'.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM =  PROGRAM.
  BDCDATA-DYNPRO  =  DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
  bdcdata_tabix = sy-tabix.

ENDFORM.

FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
  bdcdata_tabix = sy-tabix.

ENDFORM.

FORM BDC_CHANGE_FIELD USING FNAM FVAL.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  MODIFY BDCDATA INDEX bdcdata_tabix.
ENDFORM.

FORM BDC_OPEN_GROUP USING GROUP.
  IF CALL_TRANSACTION IS INITIAL.
    CALL FUNCTION 'BDC_OPEN_GROUP'
         EXPORTING
              GROUP               = GROUP
              USER                = SY-UNAME
         EXCEPTIONS
              OTHERS              = 11.


    IF SY-SUBRC <> 0.
      MESSAGE I000(ZGLOBAL) WITH GROUP.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.
ENDFORM.
FORM BDC_INSERT USING TCODE.

  IF CALL_TRANSACTION IS INITIAL.
    CALL FUNCTION 'BDC_INSERT'
         EXPORTING
              TCODE            = TCODE
         TABLES
              DYNPROTAB        = BDCDATA
         EXCEPTIONS
              INTERNAL_ERROR   = 1
              NOT_OPEN         = 2
              QUEUE_ERROR      = 3
              TCODE_INVALID    = 4
              PRINTING_INVALID = 5
              POSTING_INVALID  = 6
              OTHERS           = 7.

    IF SY-SUBRC <> 0.
      MESSAGE I001(ZGLOBAL) WITH TCODE.
      LEAVE PROGRAM.
    ENDIF.
  ELSE.
  CALL TRANSACTION TCODE USING BDCDATA MODE MODE_BDC UPDATE UPDATE_MODE.
  ENDIF.
ENDFORM.


FORM BDC_CLOSE_GROUP.
  IF CALL_TRANSACTION IS INITIAL.
    CALL FUNCTION 'BDC_CLOSE_GROUP'
         EXCEPTIONS
              OTHERS      = 3.

    IF SY-SUBRC <> 0.
      MESSAGE I002(ZGLOBAL).
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.
ENDFORM.
