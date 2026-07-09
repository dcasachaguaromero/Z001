*&---------------------------------------------------------------------*
*& Report  ZFIU0013
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFIU0013.

tables: skb1.

Parameters: soc like skb1-bukrs,
            cta like skb1-SAKNR,
            PI like skb1-XOPVW.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*Select single * from skb1 where bukrs = soc and
*                                saknr = cta.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  from skb1 where bukrs = soc and
                                saknr = cta ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


if sy-subrc = 0.
move PI to skb1-XOPVW.
update skb1.
endif.
