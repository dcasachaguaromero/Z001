*&---------------------------------------------------------------------*
*&  Include           ZFI_COMPENSA_INTERCOMPANY_SEL
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE TEXT-t01.
PARAMETERS: p_soc1  TYPE bkpf-bukrs OBLIGATORY,
            p_soc2  TYPE bkpf-bukrs OBLIGATORY,
            p_augdt TYPE augdt OBLIGATORY DEFAULT sy-datum.
SELECT-OPTIONS: s_kunnr FOR kna1-kunnr OBLIGATORY NO INTERVALS NO-EXTENSION,
                s_umskz FOR bsid-umskz NO INTERVALS NO-EXTENSION,
                s_zuonr FOR bsid-zuonr OBLIGATORY.
SELECTION-SCREEN END OF BLOCK a1.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
       ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

AT SELECTION-SCREEN.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
       ID 'BUKRS' FIELD p_soc1.
  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH p_soc1.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
       ID 'BUKRS' FIELD p_soc2.
  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH p_soc2.
  ENDIF.
