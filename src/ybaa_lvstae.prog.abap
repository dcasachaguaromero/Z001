*&---------------------------------------------------------------------*
*& Report  /SMB15/ZZLVSTAE
*&
*&---------------------------------------------------------------------*
*&
*& Damit das Standarddruckprogramm RLVSDR40 nicht verändert werden muß,
*& werden hier zusätliche Daten beschafft.
*& SapScipt Formular ..AA_LVSTAE Transportauftrag Einzelpositionen
*&---------------------------------------------------------------------*

REPORT  YBAA_LVSTAE.

data: h_matnr like mard-matnr,
      h_WERKS like mard-werks,
      h_LGORT like mard-lgort,
      h_lgpbe like mard-lgpbe.


*&---------------------------------------------------------------------*
*&      Form  read_mard
*&---------------------------------------------------------------------*
*       Lagerplatz nachlesen
*----------------------------------------------------------------------*
*      -->IN_TAB     text
*      -->OUT_TAB    text
*----------------------------------------------------------------------*
form read_mard tables in_tab structure itcsy
                     out_tab structure itcsy.

  read table in_tab with key 'MATNR'.
  if sy-subrc = 0.
       h_matnr = in_tab-value.
  endif.

  read table in_tab with key 'WERKS'.
  if sy-subrc = 0.
       h_werks = in_tab-value.
  endif.

  read table in_tab with key 'LGORT'.
  if sy-subrc = 0.
       h_lgort = in_tab-value.
  endif.

  select single lgpbe from mard
   into h_lgpbe
   where  matnr = h_MATNR
   and    werks = h_WERKS
   and    lgort = h_LGORT.
*
  read table out_tab with key 'LGPBE'.
  if sy-subrc = 0.
    out_tab-value = h_lgpbe.
    modify out_tab index sy-tabix.
  endif.

endform.                              "read_mard
