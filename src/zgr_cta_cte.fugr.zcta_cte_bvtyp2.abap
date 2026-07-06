FUNCTION ZCTA_CTE_BVTYP2.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(LAND1) TYPE  LAND1
*"     VALUE(STCD3) TYPE  STCD3
*"     VALUE(GKOAR) TYPE  GKOAR
*"     VALUE(BANKN2) TYPE  BANKN
*"     VALUE(BANKL2) TYPE  BANKL
*"  EXPORTING
*"     VALUE(KUNNR) TYPE  KUNNR
*"     VALUE(LIFNR) TYPE  LIFNR
*"     VALUE(BANKS) TYPE  BANKS
*"     VALUE(BANKL) TYPE  BANKK
*"     VALUE(BANKN) TYPE  BANKN
*"     VALUE(BKONT) TYPE  BKONT
*"     VALUE(BVTYP) TYPE  BVTYP
*"     VALUE(XEZER) TYPE  XEZER
*"     VALUE(BKREF) TYPE  BKREF
*"     VALUE(KOINH) TYPE  KOINH_FI
*"     VALUE(EBPP_ACCNAME) TYPE  EBPP_ACCNAME
*"     VALUE(EBPP_BVSTATUS) TYPE  EBPP_BVSTATUS
*"     VALUE(KOVON) TYPE  KOVON
*"     VALUE(KOBIS) TYPE  KOBIS
*"----------------------------------------------------------------------
  DATA: lv_sortl  TYPE lfa1-sortl,
        lv_ok     TYPE c.
  RANGES: lr_sortl FOR lfa1-sortl.

  CLEAR: lv_ok.

  CONDENSE stcd3 NO-GAPS.
  lv_sortl = stcd3.
  REPLACE ALL OCCURRENCES OF '-' IN lv_sortl WITH ''.

  lr_sortl-sign   = 'I'.
  lr_sortl-option = 'EQ'.
  lr_sortl-low    = stcd3.
*    lr_sortl-high   = .

  APPEND lr_sortl.
  lr_sortl-sign   = 'I'.
  lr_sortl-option = 'EQ'.
  lr_sortl-low    = lv_sortl.
*    lr_sortl-high   = .
  APPEND lr_sortl.

  CASE gkoar.
    WHEN 'D'. " Deudores
      SELECT SINGLE kunnr lifnr
          INTO (kunnr, lifnr)
          FROM kna1 CLIENT SPECIFIED
          WHERE  mandt EQ sy-mandt AND
                 sortl IN lr_sortl AND
                 stcd1 EQ stcd3    AND
                 land1 EQ land1.

      IF sy-subrc EQ 0.
        lv_ok = 'X'.
      ELSE.
        CLEAR: lv_ok.
      ENDIF.

    WHEN 'K'. " Acreedores
      SELECT SINGLE kunnr lifnr
        INTO (kunnr, lifnr)
       FROM lfa1 CLIENT SPECIFIED
       WHERE  mandt = sy-mandt  AND
              sortl IN lr_sortl AND
              stcd1 EQ stcd3    AND
              land1 EQ land1.

      IF sy-subrc EQ 0.
        lv_ok = 'X'.
      ELSE.
        CLEAR: lv_ok.
      ENDIF.
  ENDCASE.

  IF lv_ok IS NOT INITIAL.
    SELECT SINGLE  lifnr banks bankl bankn bkont bvtyp xezer bkref
                    koinh ebpp_accname  ebpp_bvstatus kovon kobis
             INTO (lifnr,  banks,  bankl,  bankn,  bkont,  bvtyp,  xezer, bkref,
                   koinh,  ebpp_accname, ebpp_bvstatus,  kovon,  kobis)
             FROM lfbk CLIENT SPECIFIED
             WHERE  mandt EQ sy-mandt
               AND  lifnr EQ lifnr
               AND  bankl EQ bankl2
               AND  bankn EQ bankn2
                  .
  ELSE.

  ENDIF.

ENDFUNCTION.
