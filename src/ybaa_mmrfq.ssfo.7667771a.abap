DATA: l_lfa1 LIKE lfa1,
l_lfm1 LIKE lfm1.

IF is_ekko-adrnr IS INITIAL.
* Get address number from table LFA1
SELECT SINGLE * FROM lfa1 INTO l_lfa1
WHERE lifnr = is_ekko-lifnr.
IF sy-subrc = 0.
MOVE l_lfa1-adrnr TO gv_addnr.
ENDIF.
* Get Salesperson data from table LFM1
SELECT SINGLE * FROM lfm1 INTO l_lfm1
WHERE lifnr = is_ekko-lifnr.
IF sy-subrc = 0.
MOVE l_lfm1-verkf TO gv_sales_person.
ENDIF.
ELSE.
MOVE is_ekko-adrnr TO gv_addnr.
ENDIF.




















