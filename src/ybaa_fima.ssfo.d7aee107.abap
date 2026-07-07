tables t040a.
t040a = 'test'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single * from t040a into h_t040a
*where spras = LANGU
*and   mschl = mhnd-mschl.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  from t040a into h_t040a
where spras = LANGU
and   mschl = mhnd-mschl ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
if sy-subrc ne 0.
fimsg-msgid = 'FM'.
fimsg-msgty = 'S'.
fimsg-msgno =  '221'.
fimsg-msgv1 = mhnd-mschl.  condense fimsg-msgv1.
fimsg-msgv2 = langu. condense fimsg-msgv2.
append fimsg to et_fimsg.
if LANGU <> lang2.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single * from t040a into h_t040a
*where spras = lang2
*and   mschl = mhnd-mschl.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  from t040a into h_t040a
where spras = lang2
and   mschl = mhnd-mschl ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
endif.
if sy-subrc <> 0 or LANGU = lang2.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single * from t040a into h_t040a
*where spras = lang2
*and   mschl = sy-langu.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  from t040a into h_t040a
where spras = lang2
and   mschl = sy-langu ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
endif.
endif.
