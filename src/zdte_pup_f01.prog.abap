*----------------------------------------------------------------------*
*   INCLUDE ZDTE_PUP_F01                                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OUTPUT_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM OUTPUT_PDF USING RETURN_CODE US_SCREEN.

  DATA: BEGIN OF IT_URL OCCURS 10.
          INCLUDE STRUCTURE TLINE.
  DATA: END OF IT_URL.
  DATA NAME LIKE THEAD-TDNAME.

  CLEAR NAME.
  NAME = NAST-OBJKY.

  CALL FUNCTION 'READ_TEXT'
       EXPORTING
            ID                      = '0002'
            LANGUAGE                = SY-LANGU
            NAME                    = NAME
            OBJECT                  = 'VBBK'
       TABLES
            LINES                   = IT_URL
       EXCEPTIONS
            ID                      = 1
            LANGUAGE                = 2
            NAME                    = 3
            NOT_FOUND               = 4
            OBJECT                  = 5
            REFERENCE_CHECK         = 6
            WRONG_ACCESS_TO_ARCHIVE = 7
            OTHERS                  = 8.

  IF SY-SUBRC EQ 0.
    READ TABLE IT_URL INDEX 1.
    CLEAR URL.
    LOOP AT IT_URL.
      CONCATENATE URL IT_URL-TDLINE INTO URL.
    ENDLOOP.
    CALL FUNCTION 'ZHOW_PDF_URL'
         EXPORTING
              I_URL = URL.

    RETURN_CODE = 0.

  ENDIF.

ENDFORM.                    " OUTPUT_PDF
