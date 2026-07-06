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


Select single * from skb1 where bukrs = soc and
                                saknr = cta.


if sy-subrc = 0.
move PI to skb1-XOPVW.
update skb1.
endif.
