tables t040a.
t040a = 'test'.
select single * from t040a into h_t040a
where spras = LANGU
and   mschl = mhnd-mschl.
if sy-subrc ne 0.
fimsg-msgid = 'FM'.
fimsg-msgty = 'S'.
fimsg-msgno =  '221'.
fimsg-msgv1 = mhnd-mschl.  condense fimsg-msgv1.
fimsg-msgv2 = langu. condense fimsg-msgv2.
append fimsg to et_fimsg.
if LANGU <> lang2.
select single * from t040a into h_t040a
where spras = lang2
and   mschl = mhnd-mschl.
endif.
if sy-subrc <> 0 or LANGU = lang2.
select single * from t040a into h_t040a
where spras = lang2
and   mschl = sy-langu.
endif.
endif.
