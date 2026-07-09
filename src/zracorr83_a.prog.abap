*&---------------------------------------------------------------------*
*& Report  ZRACORR83_A
*&---------------------------------------------------------------------*
*& Report provided from SAP Note 86801
*&---------------------------------------------------------------------*
REPORT  zracorr83_a.

TABLES: anek, bkpf.
DATA: xanek    LIKE anek OCCURS 0 WITH HEADER LINE.
DATA: ld_awkey LIKE bkpf-awkey.
DATA: ld_xblnr LIKE anek-xblnr.
PARAMETERS: pa_awtyp LIKE anek-awtyp DEFAULT 'BKPF'.
PARAMETERS: pa_bukrs LIKE anek-bukrs DEFAULT '0001'.
PARAMETERS: pa_gjahr LIKE anek-gjahr DEFAULT '2003'.
PARAMETERS: pa_test  DEFAULT 'X'.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*SELECT * FROM anek INTO TABLE xanek
*  WHERE  awtyp  = pa_awtyp
*    AND  gjahr  = pa_gjahr
*    AND  bukrs  = pa_bukrs
*    AND  xantei < '5'.
*
* NEW CODE
SELECT *
 FROM anek INTO TABLE xanek
  WHERE  awtyp  = pa_awtyp
    AND  gjahr  = pa_gjahr
    AND  bukrs  = pa_bukrs
    AND  xantei < '5' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

LOOP AT xanek.
  ld_awkey+00(10) = xanek-belnr.
  ld_awkey+10(10) = xanek-aworg.
  ld_xblnr = xanek-xblnr.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT xblnr FROM bkpf INTO xanek-xblnr
*    WHERE awtyp = xanek-awtyp
*      AND ( awsys = xanek-awsys
*            OR awsys = '          ' )
*      AND awkey = ld_awkey.
*
* NEW CODE
  SELECT xblnr
 FROM bkpf INTO xanek-xblnr
    WHERE awtyp = xanek-awtyp
      AND ( awsys = xanek-awsys
            OR awsys = '          ' )
      AND awkey = ld_awkey ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDSELECT.
  IF sy-subrc = 0.
    IF ld_xblnr = xanek-xblnr.
      DELETE xanek.
    ELSE.
      MODIFY xanek.
    ENDIF.
  ELSE.
    DELETE xanek.
  ENDIF.
ENDLOOP.
IF pa_test IS INITIAL.
  WRITE:/ 'Production run:'.
  WRITE:/ 'System will change XBLNR for the following assets:'.
  WRITE:/ '=================================================='.
ELSE.
  WRITE:/ 'Test run:'.
  WRITE:/ 'System would change XBLNR for the following assets:'.
  WRITE:/ '==================================================='.
ENDIF.

LOOP AT xanek
     WHERE NOT xblnr IS INITIAL.
  WRITE:/ xanek-bukrs, xanek-anln1, xanek-anln2, xanek-gjahr.
  WRITE:  xanek-lnran, xanek-belnr, 'XBLNR changed to: '.
  WRITE:  xanek-xblnr.
  IF pa_test IS INITIAL.
    UPDATE anek
      SET xblnr = xanek-xblnr
    WHERE bukrs = xanek-bukrs
      AND anln1 = xanek-anln1
      AND anln2 = xanek-anln2
      AND gjahr = xanek-gjahr
      AND lnran = xanek-lnran.
  ENDIF.
ENDLOOP.
COMMIT WORK.
