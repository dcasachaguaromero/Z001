*---------------------------------------------------------------------*
*       FORM GET_TEXTNAME                                             *
*-------------------------------------------
*                                           --------------------------*
*       get adress textnames
*---------------------------------------------------------------------*
FORM GET_TEXTNAME USING    IS_DLV_DELNOTE TYPE LEDLV_DELNOTE
CHANGING EF_TXNAM_ADR   TYPE TXNAM_ADR
EF_TXNAM_KOP   TYPE TXNAM_KOP
EF_TXNAM_FUS   TYPE TXNAM_FUS
EF_TXNAM_GRU   TYPE TXNAM_GRU
EF_TXNAM_SDB   TYPE TXNAM_SDB.

DATA: LS_DELIVERY TYPE LIKPVB.
DATA: LF_TEXT_ORG.

* clear textnames
CLEAR: EF_TXNAM_ADR,
EF_TXNAM_KOP,
EF_TXNAM_FUS,
EF_TXNAM_GRU,
EF_TXNAM_SDB.

* delivery number
LS_DELIVERY-VBELN = IS_DLV_DELNOTE-HD_GEN-DELIV_NUMB.
* organisational data
LS_DELIVERY-VSTEL = IS_DLV_DELNOTE-HD_ORG-SHIP_POINT.
LS_DELIVERY-VKORG = IS_DLV_DELNOTE-HD_ORG-SALESORG.
LS_DELIVERY-VKBUR = IS_DLV_DELNOTE-HD_ORG-SALES_OFF.

* Valid numbers for IF_TABLE:   1     text from sales organisation
*                               2     text from shipping point
*                               3     text from sales office
* default: read text from sales org
LF_TEXT_ORG = '1'.

CALL FUNCTION 'LE_SHP_DLVOUTP_TEXT_SELECT'
EXPORTING
IS_DELIVERY           = LS_DELIVERY
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

