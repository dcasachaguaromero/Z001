DATA: ls_sernr LIKE riserls.
DATA: BEGIN OF lt_sernr OCCURS 5.
        INCLUDE STRUCTURE riserls.
DATA: END   OF lt_sernr.

REFRESH gt_sernr_prt.

LOOP AT is_dlv_delnote-it_sernr INTO gs_it_sernr
              WHERE deliv_numb = gs_it_gen-deliv_numb
              AND   itm_number = gs_it_gen-itm_number.
  CLEAR ls_sernr.
  ls_sernr-vbeln = gs_it_sernr-deliv_numb.
  ls_sernr-posnr = gs_it_sernr-itm_number.
  ls_sernr-sernr = gs_it_sernr-serial_num.
  APPEND ls_sernr TO lt_sernr.
ENDLOOP.

if sy-subrc ne 0.
  if not gs_it_gen_batch is initial.
    LOOP AT is_dlv_delnote-it_sernr INTO gs_it_sernr
                                    WHERE deliv_numb = gs_it_gen_batch-deliv_numb
                                      AND itm_number = gs_it_gen_batch-itm_number.
      CLEAR ls_sernr.
      ls_sernr-vbeln = gs_it_sernr-deliv_numb.
      ls_sernr-posnr = gs_it_sernr-itm_number.
      ls_sernr-sernr = gs_it_sernr-serial_num.
      APPEND ls_sernr TO lt_sernr.
    ENDLOOP.
  endif.
endif.


* Process the stringtable for Printing.
CALL FUNCTION 'PROCESS_SERIALS_FOR_PRINT'
  EXPORTING
    i_boundary_left             = '(_'
    i_boundary_right            = '_)'
    i_sep_char_strings          = ',_'
    i_sep_char_interval         = '_-_'
    i_use_interval              = 'X'
    i_boundary_method           = 'C'
    i_line_length               = 50
    i_no_zero                   = 'X'
    i_alphabet                  = sy-abcde
    i_digits                    = '0123456789'
    i_special_chars             = '-'
    i_with_second_digit         = ' '
  TABLES
    serials                     = lt_sernr
    serials_print               = gt_sernr_prt
  EXCEPTIONS
    boundary_missing            = 01
    interval_separation_missing = 02
    length_to_small             = 03
    internal_error              = 04
    wrong_method                = 05
    wrong_serial                = 06
    two_equal_serials           = 07
    serial_with_wrong_char      = 08
    serial_separation_missing   = 09.




