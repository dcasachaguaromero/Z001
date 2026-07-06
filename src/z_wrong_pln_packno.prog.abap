*&--------------------------------------------------------------------------*
*&                                                                          *
*& WARNING!!!!                                                              *
*& This report must be used very carefully, because if two service lines    *
*& from PO has the same short text, only the first found will be taken      *
*& into account. Also if the short text from service entry sheet was        *
*& changed from that of PO, no service will be found.                       *
*& This report will not correct any other inconsistencies.                  *
*&                                                                          *
*& This report will correct wrong PLN_PACKNO and PLN_INTROW for planned     *
*& services from service entry sheet.                                       *
*&--------------------------------------------------------------------------

REPORT  z_wrong_pln_packno MESSAGE-ID se.

TABLES: ekpo,
        essr,
        esll,
        ml_esll,
        eslh.

DATA: es_esll LIKE TABLE OF esll,
      po_esll LIKE TABLE OF esll,
      temp_esll LIKE TABLE OF esll,
      w_ekpo LIKE ekpo,
      w_ml_esll LIKE ml_esll,
      w_essr LIKE essr,
      w_esll LIKE esll,
      s_esll LIKE esll,
      t_esll LIKE esll.

DATA: sel_lblni LIKE essr-lblni,
      error_found VALUE ' '.

PARAMETER: nr_lblni TYPE essr-lblni,
           test AS CHECKBOX DEFAULT 'X'.



CLEAR: es_esll, po_esll, temp_esll.
REFRESH: es_esll, po_esll, temp_esll.
*Look for document
SELECT SINGLE * FROM essr INTO w_essr
                WHERE lblni = nr_lblni.

IF sy-subrc NE 0.
*If not exists
  MESSAGE i005.
*If found, proceed looking if doc is OK
ELSE.
  PERFORM check_if_ok.
ENDIF.

*---------------------------------------------------------------------*
*       FORM check_if_ok                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM check_if_ok.
*Selection of all services belonging to entry sheet.
  SELECT * FROM ml_esll INTO w_ml_esll
            WHERE hpackno = w_essr-packno
              AND packno NE w_essr-packno.
    IF sy-subrc NE 0.
*     If not found any service line service entry is empty
      MESSAGE e185.
      EXIT.
    ENDIF.
    MOVE-CORRESPONDING w_ml_esll TO s_esll.
    APPEND s_esll TO es_esll.
  ENDSELECT.

*Selection of all services belonging to corr.item from PO.
  SELECT SINGLE * FROM ekpo WHERE ebeln = w_essr-ebeln
                             AND  ebelp = w_essr-ebelp.

  IF sy-subrc NE 0.
*If not found line
    MESSAGE e005.
    EXIT.
  ENDIF.

  CLEAR: w_ml_esll, s_esll.
  SELECT * FROM ml_esll INTO w_ml_esll
            WHERE hpackno = ekpo-packno
              AND packno NE ekpo-packno.

    IF sy-subrc NE 0.
*   If not found any service line in PO
      MESSAGE e185.
      EXIT.
    ENDIF.
    MOVE-CORRESPONDING w_ml_esll TO s_esll.
    APPEND s_esll TO po_esll.
  ENDSELECT.
*Search for corresponding data
  CLEAR s_esll.
  LOOP AT es_esll INTO s_esll.
    LOOP AT po_esll INTO t_esll. " WHERE ktext1 = s_esll-ktext1.
      IF sy-subrc NE 0.
        WRITE: / 'Service ', s_esll-ktext1, 'not in PO'.
      ELSE.
        IF t_esll-packno NE s_esll-pln_packno OR
           t_esll-introw NE s_esll-pln_introw.
          WRITE: / 'Service', s_esll-ktext1, 'has plan packno',
                    s_esll-pln_packno, 'and plan introw',
                    s_esll-pln_introw,
                 /  '                                             ',
                    '       instead of ',
                    t_esll-packno, 'and plan introw', t_esll-introw.
          ULINE.
          s_esll-pln_packno = t_esll-packno.
          s_esll-pln_introw = t_esll-introw.
          APPEND s_esll TO temp_esll.
          error_found = 'X'.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  IF error_found EQ space.
    MESSAGE i714.
  ENDIF.
  IF test EQ space.
    LOOP AT temp_esll INTO w_esll.
      UPDATE esll SET: pln_packno = w_esll-pln_packno
                       pln_introw = w_esll-pln_introw
                  WHERE packno = w_esll-packno AND
                        introw = w_esll-introw.
    ENDLOOP.
    WRITE: / 'Data corrected'.
  ENDIF.

ENDFORM.      "check_if_ok
