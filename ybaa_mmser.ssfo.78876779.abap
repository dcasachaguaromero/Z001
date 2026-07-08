*************************************************
* If partner number is specified in the import
* parameter IN_NAST, use it to get vender address
* and sale person data, otherwise use header
* vender number to get address and sale person
*************************************************

DATA l_lfa1 LIKE lfa1.
DATA l_lfm1 LIKE lfm1.

IF is_ekko-adrnr IS INITIAL.
IF  is_nast-parnr NE space AND
is_nast-parnr NE is_ekko-lifnr.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM lfa1 INTO l_lfa1
*WHERE lifnr = is_nast-parnr.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM lfa1 INTO l_lfa1
WHERE lifnr = is_nast-parnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
IF sy-subrc = 0.
MOVE l_lfa1-adrnr TO gv_addnr_vendor.
ENDIF.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM  lfm1 INTO l_lfm1
*WHERE
*lifnr  = is_nast-parnr
*AND    ekorg  = is_ekko-ekorg.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM  lfm1 INTO l_lfm1
WHERE
lifnr  = is_nast-parnr
AND    ekorg  = is_ekko-ekorg ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
IF sy-subrc = 0.
MOVE l_lfm1-verkf TO gv_sales_person.
ENDIF.
ELSE.
"--Get address number from table LFA1--
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM lfa1 INTO l_lfa1
*WHERE lifnr = is_ekko-lifnr.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM lfa1 INTO l_lfa1
WHERE lifnr = is_ekko-lifnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
IF sy-subrc = 0.
MOVE l_lfa1-adrnr TO gv_addnr_vendor.

ENDIF.
"--Get Salesperson data from table LFM1--
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM lfm1 INTO l_lfm1
*WHERE lifnr = is_ekko-lifnr.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM lfm1 INTO l_lfm1
WHERE lifnr = is_ekko-lifnr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
IF sy-subrc = 0.
MOVE l_lfm1-verkf TO gv_sales_person.
ENDIF.
ENDIF.
ELSE.
MOVE is_ekko-adrnr TO gv_addnr_vendor.
ENDIF.


