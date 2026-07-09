************************************************************************
*                         UPTIMIZER 2.0 : TOOLKIT                      *
*          COPYRIGHT (C)  2002 BY INTELLIGROUP INC. CONSULTING         *
************************************************************************
*    SAP  AG DOES NOT BEAR ANY RESPONSIBILITY FOR THE FUNCTIONALITY    *
*    PROVIDED BY THIS PRODUCT.                                         *
************************************************************************
*    NO PART OF THIS PROGRAM MAY BE COPIED/REPRODUCED OR TRANSLATED    *
*    INTO ANY OTHER LANGUAGE BY ANY FORM OR MEANS WITHOUT THE PRIOR    *
*    WRITTEN CONSENT OF INTELLIGROUP INC.                              *
************************************************************************
REPORT Y2PUCOD0
       MESSAGE-ID Y2
       NO STANDARD PAGE HEADING.
**--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--**
**     AUTHOR           :                                             **
**     CREATED          :                                             **
**--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--*--**

*----------------------------------------------------------------------*
*   DECLARATION FOR DATA-TYPES
*----------------------------------------------------------------------*
DATA : V_CANCEL(1) TYPE C,
       V_FILENAME LIKE RLGRAP-FILENAME.

*----------------------------------------------------------------------*
*   DECLARATION OF INTERNAL TABLES
*----------------------------------------------------------------------*
DATA : ITAB(256) TYPE C OCCURS 0 WITH HEADER LINE.

*----------------------------------------------------------------------*
* SELECTION-SCREEN
*----------------------------------------------------------------------*
PARAMETER : P_PROG LIKE D010SINF-PROG.

*----------------------------------------------------------------------*
*   START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  CALL FUNCTION 'UPLOAD'
       EXPORTING
            FILENAME            = V_FILENAME
            FILETYPE            = 'ASC'
       IMPORTING
            CANCEL              = V_CANCEL
       TABLES
            DATA_TAB            = ITAB
       EXCEPTIONS
            CONVERSION_ERROR    = 1
            INVALID_TABLE_WIDTH = 2
            INVALID_TYPE        = 3
            NO_BATCH            = 4
            UNKNOWN_ERROR       = 5
            OTHERS              = 7.
  TRANSLATE V_CANCEL TO UPPER CASE.
  IF V_CANCEL EQ SPACE.
    INSERT REPORT P_PROG FROM ITAB.
    WRITE SY-SUBRC.
  ELSEIF V_CANCEL = 'X'.
    MESSAGE S000 WITH 'OPERATION CANCELLED.'.
  ENDIF.
