*---------------------------------------------------------------------*
*       FORM GET_TEXTNAME                                             *
*---------------------------------------------------------------------*
*       get adress textnames
*---------------------------------------------------------------------*
FORM GET_TEXTNAME using    GF_TDNAME
IS_VKORG
CHANGING EF_TXNAM_ADR TYPE TXNAM_ADR
EF_TXNAM_KOP TYPE TXNAM_KOP
EF_TXNAM_FUS TYPE TXNAM_FUS
EF_TXNAM_GRU TYPE TXNAM_GRU
EF_TXNAM_SDB TYPE TXNAM_SDB.

DATA: IS_INVOICE TYPE VBRKVB.
DATA: LF_TEXT_ORG.

* object text name
*GF_TDNAME = IS_BIL_INVOICE-HD_GEN-BIL_NU


* clear textnames
CLEAR: EF_TXNAM_ADR,
EF_TXNAM_KOP,
EF_TXNAM_FUS,
EF_TXNAM_GRU,
EF_TXNAM_SDB.
* invoice number
*  IS_INVOICE-VBELN = IS_BIL_INVOICE-HD_GEN-BIL_NUMBER.
IS_INVOICE-VBELN = GF_TDNAME.

* organisational data
*  IS_INVOICE-VKORG = IS_BIL_INVOICE-HD_ORG-SALESORG.
IS_INVOICE-VKORG = is_vkorg.


* Valid numbers for IF_TABLE:   1     text from sales organisation
*                               2     text from shipping point
*                               3     text from sales office
* default: read text from sales org
LF_TEXT_ORG = '1'.

CALL FUNCTION 'LB_BIL_INVOUTP_TEXT_SELECT'
EXPORTING
IS_INVOICE            = IS_INVOICE
IF_TABLE              = LF_TEXT_ORG
IMPORTING
EF_TDNAME_ADR         = EF_TXNAM_ADR
EF_TDNAME_KOP         = EF_TXNAM_KOP
EF_TDNAME_FUS         = EF_TXNAM_FUS
EF_TDNAME_GRU         = EF_TXNAM_GRU
EF_TDNAME_SDB         = EF_TXNAM_SDB
EXCEPTIONS
RECORDS_NOT_FOUND     = 1
RECORDS_NOT_REQUESTED = 2
OTHERS                = 3.
IF SY-SUBRC <> 0.
ENDIF.

ENDFORM.




*---------------------------------------------------------------------*
*       FORM JUDGE_DIFFS                                             *
*---------------------------------------------------------------------*
*       judge the Difference of Order, Delivery, PO of all items
*---------------------------------------------------------------------*
FORM judge_diff
USING IS_BIL_INVOICE      TYPE LBBIL_INVOICE
CHANGING GV_REFORD_DIFF   TYPE C
GV_REFDLV_DIFF   TYPE C
GV_REFPURORD_DIFF TYPE C.
* initialize some data
DATA WA_IT_REFORD		TYPE LBBIL_IT_REFORD.
DATA WA_IT_GEN			TYPE LBBIL_IT_GEN.
DATA WA_IT_REFDLV		TYPE LBBIL_IT_REFDLV.
DATA WA_IT_REFPURORD      TYPE LBBIL_IT_REFPURORD.
DATA WA_HD_REF            TYPE LBBIL_HD_REF.

IF IS_BIL_INVOICE-HD_GEN-BIL_VBTYPE EQ 'M'
OR IS_BIL_INVOICE-HD_GEN-BIL_VBTYPE EQ 'N'
OR IS_BIL_INVOICE-HD_GEN-BIL_VBTYPE EQ 'U'.
*  initialize wa_hd_ref
MOVE-CORRESPONDING IS_BIL_INVOICE-HD_REF TO WA_HD_REF.

* LOOP
LOOP AT IS_BIL_INVOICE-IT_GEN INTO WA_IT_GEN.
* read order data
CLEAR WA_IT_REFORD.
READ TABLE IS_BIL_INVOICE-IT_REFORD INTO WA_IT_REFORD
WITH KEY BIL_NUMBER = WA_IT_GEN-BIL_NUMBER
ITM_NUMBER = WA_IT_GEN-ITM_NUMBER
BINARY SEARCH.
* read purchase order data
CLEAR WA_IT_REFPURORD.
READ TABLE IS_BIL_INVOICE-IT_REFPURORD INTO WA_IT_REFPURORD
WITH KEY BIL_NUMBER = WA_IT_GEN-BIL_NUMBER
ITM_NUMBER = WA_IT_GEN-ITM_NUMBER
BINARY SEARCH.
* read delivery data
CLEAR WA_IT_REFDLV.
READ TABLE IS_BIL_INVOICE-IT_REFDLV INTO WA_IT_REFDLV
WITH KEY BIL_NUMBER = WA_IT_GEN-BIL_NUMBER
ITM_NUMBER = WA_IT_GEN-ITM_NUMBER
BINARY SEARCH.
* If the reference order's number is not identical
* then GV_REFORD_DIFF = 'X'
IF WA_IT_REFORD-ORDER_NUMB NE WA_HD_REF-ORDER_NUMB.
GV_REFORD_DIFF = 'X'.
ENDIF.
* If the delivery's number is not identical
* then GV_REFDLV_DIFF = 'X'
IF WA_IT_REFDLV-DELIV_NUMB NE WA_HD_REF-DELIV_NUMB.
GV_REFDLV_DIFF = 'X'.
ENDIF.
* If the purord's number is not identical
* then GV_REFPURORD_DIFF = 'X'
IF WA_IT_REFPURORD-PURCH_NO_C NE WA_HD_REF-PURCH_NO.
GV_REFPURORD_DIFF = 'X'.
ENDIF.
* if every flag is 'x' terminate the loop.

IF GV_REFORD_DIFF EQ 'X'
AND GV_REFDLV_DIFF EQ 'X'
AND GV_REFPURORD_DIFF EQ 'X'.
EXIT.
ENDIF.

ENDLOOP.	"END LOOP

ENDIF.	"END IF

ENDFORM.






