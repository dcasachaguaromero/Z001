FUNCTION ZFIRFC_B003.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(TI_RUT) TYPE  ZIRUTET
*"  EXPORTING
*"     VALUE(TI_SALIDA) TYPE  ZORUTET
*"----------------------------------------------------------------------

DATA: ZIRUT TYPE ZIRUTE.
data: lifnrtmp like lfa1-lifnr,
      kunnrtmp like kna1-kunnr.
DATA: ZOUT type ZORUTE.
DATA: LIFNR_N(10) TYPE N,
      w_sortl like lfa1-sortl.


LOOP AT TI_RUT INTO ZIRUT.
  CLEAR w_sortl.
  CONDENSE zirut-STCD3 NO-GAPS.
  w_sortl = zirut-stcd3.
  REPLACE ALL OCCURRENCES OF '-' IN w_sortl WITH ''.

  call function 'CONVERSION_EXIT_ALPHA_INPUT'
  exporting
    input         = ZOUT-lifnr
 importing
   output        = ZOUT-lifnr.

  case ZIRUT-gkoar_i.
    when 'K'.
      IF ZIRUT-STCD3 NS '-'.
        LIFNR_N = ZIRUT-STCD3.
        select single lifnr name1 name2 adrnr name3 name4 kunnr
          into (lifnrtmp, ZOUT-name1, ZOUT-name2, ZOUT-adrnr, ZOUT-name3, ZOUT-name4, ZOUT-kunnr)
        from lfa1
          where   sortl = w_sortl
                  and LIFNR = LIFNR_N
                  and land1 = ZIRUT-land1.
      ELSE.
        select single lifnr name1 name2 adrnr name3 name4 kunnr
          into (lifnrtmp, ZOUT-name1, ZOUT-name2, ZOUT-adrnr, ZOUT-name3, ZOUT-name4, ZOUT-kunnr)
        from lfa1
          where  sortl = w_sortl
              and stcd1 = ZIRUT-stcd3
              and land1 = ZIRUT-land1.
      ENDIF.

      if lifnrtmp is initial.
        clear ZOUT.
      else.
        select single lifnr akont lifnr
        into (ZOUT-lifnr, ZOUT-name3, ZOUT-kunnr)
        from lfb1
        where lifnr eq lifnrtmp
              and bukrs eq ZIRUT-bukrs.
        if ZOUT-lifnr is initial.
*          clear ZOUT-name1.
*          clear ZOUT-name2.
*          clear ZOUT-adrnr.
*          clear ZOUT-name3.
          ZOUT-name4 = 'N'.
        else.
          ZOUT-name4 = 'E'.
        endif.
        ZOUT-kunnr = lifnrtmp.
        ZOUT-lifnr = lifnrtmp.
        clear ZOUT-name1.
        clear ZOUT-name2.
        clear ZOUT-adrnr.
        clear ZOUT-name3.
      endif.
    when 'D'.
      IF ZIRUT-STCD3 NS '-'.
        LIFNR_N = ZIRUT-STCD3.
        select single lifnr name1 name2 adrnr name3 name4 kunnr
            into (ZOUT-lifnr, ZOUT-name1, ZOUT-name2, ZOUT-adrnr, ZOUT-name3, ZOUT-name4, kunnrtmp)
        from kna1
          where  sortl = w_sortl
                 and KUNNR = LIFNR_N
                 and land1 = ZIRUT-land1.
      ELSE.
        select single lifnr name1 name2 adrnr name3 name4 kunnr
            into (ZOUT-lifnr, ZOUT-name1, ZOUT-name2, ZOUT-adrnr, ZOUT-name3, ZOUT-name4, kunnrtmp)
        from kna1
          where  sortl = w_sortl
                 and stcd1 = ZIRUT-stcd3
                 and land1 = ZIRUT-land1.
      ENDIF.
                if kunnrtmp is initial.
                  clear ZOUT.
                else.
                  select single kunnr akont kunnr
                  into (ZOUT-lifnr, ZOUT-name3, ZOUT-kunnr)
                  from knb1
                  where kunnr eq kunnrtmp
                        and bukrs eq ZIRUT-bukrs.
                  if ZOUT-lifnr is initial.
*                    clear ZOUT-name1.
*                    clear ZOUT-name2.
*                    clear ZOUT-adrnr.
*                    clear ZOUT-name3.
                    ZOUT-name4 = 'N'.
                  else.
                    ZOUT-name4 = 'E'.
                  endif.
                  ZOUT-kunnr = kunnrtmp.
                  ZOUT-lifnr = kunnrtmp.
                  clear ZOUT-name1.
                  clear ZOUT-name2.
                  clear ZOUT-adrnr.
                  clear ZOUT-name3.
               endif.
    when others.
  endcase.
  CLEAR lifnrtmp.
  CLEAR kunnrtmp.
  ZOUT-name2 = ZIRUT-stcd3.
  APPEND ZOUT TO TI_SALIDA.
ENDLOOP.

ENDFUNCTION.
