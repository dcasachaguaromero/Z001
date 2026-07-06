FUNCTION Z_FIEB_901_ALGORITHM.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_NOTE_TO_PAYEE) TYPE  STRING OPTIONAL
*"     REFERENCE(I_COUNTRY) TYPE  LAND1 OPTIONAL
*"  TABLES
*"      T_AVIP_IN STRUCTURE  AVIP OPTIONAL
*"      T_AVIP_OUT STRUCTURE  AVIP
*"      T_FILTER1 OPTIONAL
*"      T_FILTER2 OPTIONAL
*"----------------------------------------------------------------------
*en esta función se van a incluir los metodos de búsqueda de partidas abiertas
*para la conciliación bancaria
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_NOTE_TO_PAYEE) TYPE  STRING OPTIONAL
*"     REFERENCE(I_COUNTRY) TYPE  LAND1 OPTIONAL
*"  TABLES
*"      T_AVIP_IN STRUCTURE  AVIP OPTIONAL
*"      T_AVIP_OUT STRUCTURE  AVIP
*"      T_FILTER1 OPTIONAL
*"      T_FILTER2 OPTIONAL
*"----------------------------------------------------------------------

* This algorithm searches for numbers that
* are in T_FILTER1 (numeric document number Filter(BELNR)
* and checks then if for theses numbers cleared docuements exist

  TYPES: BEGIN OF s_bkpf,
           bukrs TYPE bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE gjahr,
           blart TYPE bkpf-blart,
         END OF s_bkpf.

  DATA: l_note_to_payee TYPE string,
        l_length TYPE i,
        BEGIN OF belnr_tab OCCURS 10,
           belnr TYPE bkpf-belnr,
        END OF belnr_tab,
        BEGIN OF xblnr_tab OCCURS 10,
           belnr TYPE bkpf-xblnr,
        END OF xblnr_tab,

        l_belnr TYPE bkpf-belnr,
        l_xblnr TYPE bkpf-xblnr,
        r_bukrs TYPE RANGE OF bukrs WITH HEADER LINE,
        lt_bkpf TYPE STANDARD TABLE OF s_bkpf,
        l_t003 TYPE t003,
        l_bsad type bsad,
        l_bsak type bsak.

  FIELD-SYMBOLS: <bkpf> TYPE s_bkpf,
                 <belnr> TYPE belnr.

  LOOP AT t_avip_in WHERE bukrs <> space.
*the company code is passed by a line in t_avip_in
*if not, all company codes are searched
    r_bukrs-sign = 'I'.
    r_bukrs-option = 'EQ'.
    r_bukrs-low = t_avip_in-bukrs.
    APPEND r_bukrs.
    EXIT.
  ENDLOOP.

  l_note_to_payee = i_note_to_payee.

  IF NOT l_note_to_payee IS INITIAL.
*reference information is free form, put it into good shape
    perform separar_campos tables xblnr_tab
                           using l_note_to_payee.                           .
*    CALL FUNCTION 'FIEB_EXTRACT_NUMBERS'
*      EXPORTING
*        i_note_to_payee = l_note_to_payee
*      TABLES
*        e_numbers       = belnr_tab.
    SORT xblnr_tab.
    DELETE ADJACENT DUPLICATES FROM xblnr_tab.
  ENDIF.

  REFRESH t_avip_out.
  LOOP AT belnr_tab.
    CHECK belnr_tab IN t_filter1.
    SELECT bukrs belnr gjahr blart FROM bkpf INTO TABLE lt_bkpf
      WHERE bukrs IN r_bukrs
            AND belnr = belnr_tab-belnr.
    IF sy-subrc = 0.
      SORT lt_bkpf DESCENDING BY gjahr.
      LOOP AT lt_bkpf ASSIGNING <bkpf>.
        SELECT SINGLE * FROM t003  INTO l_t003
                   WHERE blart = <bkpf>-blart.
        EXIT.
      ENDLOOP.
      CASE l_t003-koars.
        WHEN 'S'.
          t_avip_out-koart  = 'S'.
          t_avip_out-sfeld       = 'BELNR'.
          t_avip_out-swert       = <bkpf>-belnr.
          t_avip_out-swert+10(4) = <bkpf>-gjahr.
          APPEND t_avip_out.
        WHEN 'K'.
          t_avip_out-koart  = 'K'.
          SELECT SINGLE * FROM bsak INTO l_bsak
                             WHERE bukrs = <bkpf>-bukrs
                               AND belnr = <bkpf>-belnr
                               AND gjahr = <bkpf>-gjahr.
          IF sy-subrc = 0.
            t_avip_out-koart       = 'K'.
            t_avip_out-konto       = l_bsak-lifnr.
            t_avip_out-sfeld       = 'BELNR'.
            t_avip_out-swert       = <bkpf>-belnr.
            t_avip_out-swert+10(4) = <bkpf>-gjahr.
            APPEND t_avip_out.
          ENDIF.
        WHEN OTHERS.
          SELECT SINGLE * FROM bsad INTO  l_bsad
                            WHERE bukrs =  <bkpf>-bukrs
                              AND belnr =  <bkpf>-belnr
                              AND gjahr =  <bkpf>-gjahr.
          IF sy-subrc = 0.
            t_avip_out-koart       = 'D'.
            t_avip_out-konto       = l_bsad-kunnr.
            t_avip_out-sfeld       = 'BELNR'.
            t_avip_out-swert       = <bkpf>-belnr.
            t_avip_out-swert+10(4) = <bkpf>-gjahr.
            APPEND t_avip_out.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.


ENDFUNCTION.
