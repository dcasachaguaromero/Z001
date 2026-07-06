*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFILB002_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  get_documents
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_documents .
  DATA: lv_ctab(1) TYPE c.
  DATA: lv_fin(1) TYPE c.

  FIELD-SYMBOLS <f_hex> TYPE x.

  ASSIGN lv_ctab TO <f_hex> CASTING.

  <f_hex> ='0A'.

  ASSIGN lv_fin TO <f_hex> CASTING.

  <f_hex> ='0D'.


  DATA: ls_bkpf   TYPE bkpf,
        ls_bseg   TYPE bseg,
        ls_bset   TYPE bset,
        ls_outtab TYPE ty_s_outtab.
*  Validacion de fecha de contabilizacion y periodo.
  IF s_budat IS NOT INITIAL.
    LOOP AT s_budat.
*      IF s_budat-low IS NOT INITIAL AND s_budat-low(4) <> p_gjahr.
      IF s_budat-low IS NOT INITIAL AND
         s_budat-low(4) < p_gjahr-low.
        MESSAGE 'El periodo es diferente a la fecha de contabilización' TYPE 'E'.
      ENDIF.
*     IF s_budat-high IS NOT INITIAL AND s_budat-high(4) <> p_gjahr.
      IF s_budat-high IS NOT INITIAL AND
         s_budat-high(4) > p_gjahr-high.
        MESSAGE 'El periodo es diferente a la fecha de contabilización' TYPE 'E'.
      ENDIF.
    ENDLOOP.
  ENDIF.

  SELECT
      bukrs
      gjahr
      budat
      blart
      belnr
      bldat
      xblnr
      bktxt
      waers
      stblg
      aedat
      usnam
      xref2_hd
     FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
** INI RVY 10.08.2023
**    WHERE bukrs EQ p_bukrs
**      AND gjahr EQ p_gjahr
    WHERE bukrs IN p_bukrs
      AND gjahr IN p_gjahr
** FIN RVY 10.08.2023
      AND belnr IN s_belnr
      AND blart IN p_brte_1
      AND bldat IN s_bldat
      AND xref2_hd IN s_xref2
      AND budat IN s_budat.
*    AND stblg EQ space
*    AND bstat EQ space.

  LOOP AT gt_bkpf INTO ls_bkpf.

    SELECT
          buzei
          koart
          bschl
          hkont
          shkzg
          mwskz
          qsskz
          wrbtr
          pswbt
          pswsl
          sgtxt
          zuonr
          kunnr
          lifnr
          kostl
          prctr
          zzprestac
          zzunid_pro
          zzdesc_est
          zzmot_emis
          zzrut_terc
          zz_agencia
          augdt
          augbl
          fdtag
          zfbdt
          zterm
          zbd1t
          xref1
          xref2
          xref3
          zlsch
          hbkid
          zlspr
          dmbtr   "V1- Waldo Alarcón - Visionone - 17-03-2022
       FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE gt_bseg
        WHERE  bukrs EQ ls_bkpf-bukrs
           AND belnr EQ ls_bkpf-belnr
           AND gjahr EQ ls_bkpf-gjahr
           AND buzei IN s_buzei
           AND hkont IN s_hkont
           AND kostl IN s_kostl
           AND zzmot_emis IN s_zzmot.

    LOOP AT gt_bseg INTO ls_bseg.

      CLEAR ls_outtab.
      MOVE-CORRESPONDING ls_bseg TO ls_outtab.
*
      IF ls_bseg-shkzg = 'H'.
        MULTIPLY ls_outtab-wrbtr BY -1.
        MULTIPLY ls_outtab-pswbt BY -1.
        MULTIPLY ls_outtab-dmbtr BY -1. "V1- Waldo Alarcón - Visionone - 17-03-2022
      ENDIF.

      SELECT SINGLE  name1 stcd1 FROM lfa1 INTO (ls_outtab-name1, ls_outtab-stcd1)
        WHERE lifnr EQ ls_outtab-lifnr.

      IF ls_bseg-zzrut_terc <> ' '.
         SELECT SINGLE  name1 FROM lfa1 INTO ls_outtab-name3
           WHERE lifnr EQ ls_bseg-zzrut_terc.

         IF sy-subrc <>  0.
            SELECT SINGLE  name1 FROM lfa1 INTO ls_outtab-name3
              WHERE STCD1 EQ ls_bseg-zzrut_terc.
         endif.
      endif.

      SELECT SINGLE txt50 FROM skat INTO ls_outtab-txt50
        WHERE spras = 'S' AND ktopl = 'B100' AND saknr = ls_bseg-hkont.

      MOVE ls_bkpf-bukrs  TO ls_outtab-bukrs.
      MOVE ls_bkpf-gjahr  TO ls_outtab-gjahr.
      MOVE ls_bkpf-budat  TO ls_outtab-budat.
      MOVE ls_bkpf-blart  TO ls_outtab-blart.
      MOVE ls_bkpf-belnr  TO ls_outtab-belnr.
      MOVE ls_bkpf-bldat  TO ls_outtab-bldat.
      MOVE ls_bkpf-xblnr  TO ls_outtab-xblnr.
      MOVE ls_bkpf-bktxt  TO ls_outtab-bktxt.
      MOVE ls_bkpf-waers  TO ls_outtab-waers.
      MOVE ls_bkpf-stblg  TO ls_outtab-stblg.
      MOVE ls_bkpf-xref2_hd  TO ls_outtab-xref2_hd.
      MOVE ls_bkpf-aedat  TO ls_outtab-aedat.
      MOVE ls_bkpf-usnam  TO ls_outtab-usnam.

      READ TABLE ti_sociedad INTO wa_sociedad
      WITH KEY bukrs = ls_bkpf-bukrs BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE wa_sociedad-waers       TO ls_outtab-pswsl.  "V1- Waldo Alarcón - Visionone - 17-03-2022
      ENDIF.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES04 ECDK917080 *
      SELECT SINGLE ltext INTO ls_outtab-ltext
          FROM t003t
            WHERE spras = 'S'
             AND blart = ls_outtab-blart.


      IF ls_outtab-koart = 'D'.
        SELECT SINGLE stcd1 name1 INTO (ls_outtab-stcd2, ls_outtab-name2)
          FROM kna1
            WHERE kunnr = ls_outtab-kunnr.
      ENDIF.

      REPLACE ALL OCCURRENCES OF '#' IN ls_outtab-sgtxt WITH ''.
      REPLACE ALL OCCURRENCES OF '|' IN ls_outtab-sgtxt WITH ''.
      REPLACE ALL OCCURRENCES OF '.' IN ls_outtab-sgtxt WITH ''.
      REPLACE ALL OCCURRENCES OF ';' IN ls_outtab-sgtxt WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN ls_outtab-sgtxt WITH ''.

      REPLACE ALL OCCURRENCES OF '#' IN ls_outtab-bktxt WITH ''.
      REPLACE ALL OCCURRENCES OF '|' IN ls_outtab-bktxt WITH ''.
      REPLACE ALL OCCURRENCES OF '.' IN ls_outtab-bktxt WITH ''.
      REPLACE ALL OCCURRENCES OF ';' IN ls_outtab-bktxt WITH ''.
      REPLACE ALL OCCURRENCES OF ',' IN ls_outtab-bktxt WITH ''.

      REPLACE ALL OCCURRENCES OF lv_ctab IN ls_outtab-sgtxt WITH ' '.
      REPLACE ALL OCCURRENCES OF lv_fin IN ls_outtab-sgtxt WITH ' '.

      REPLACE ALL OCCURRENCES OF lv_ctab IN ls_outtab-bktxt WITH ' '.
      REPLACE ALL OCCURRENCES OF lv_fin IN ls_outtab-bktxt WITH ' '.

*V1 23-07-2020
*     CONDENSE ls_outtab-bktxt NO-GAPS. CONDENSE ls_outtab-sgtxt NO-GAPS.
*V1 23-07-2020

      APPEND ls_outtab TO gt_outtab.
    ENDLOOP.

  ENDLOOP.

  SORT gt_outtab BY blart bldat xblnr.
ENDFORM.                    " get_documents

*&---------------------------------------------------------------------*
*&      Form  fieldcat_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_init USING lt_fieldcat TYPE slis_t_fieldcat_alv
                          lt_fieldcat_100 TYPE lvc_t_fcat.
  DATA: ls_fieldcat     TYPE slis_fieldcat_alv,
        ls_fieldcat_100 TYPE lvc_s_fcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-seltext_m = 'Sociedad'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'GJAHR'.
  ls_fieldcat-seltext_m = 'Periodo'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-seltext_m = 'Fec. de Cont.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLART'.
  ls_fieldcat-seltext_m = 'Do.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'LTEXT'.
  ls_fieldcat-seltext_m = 'Desc.Do.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BELNR'.
  ls_fieldcat-seltext_m = 'Documento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME1'.
  ls_fieldcat-seltext_m = 'Nombre Acreedor'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STCD1'.
  ls_fieldcat-seltext_m = 'Identificador Fiscal'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME2'.
  ls_fieldcat-seltext_m = 'Nombre Cliente'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STCD2'.
  ls_fieldcat-seltext_m = 'Rut Cliente'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BLDAT'.
  ls_fieldcat-seltext_m = 'Fec. Fact.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XBLNR'.
  ls_fieldcat-seltext_m = 'N° de Fact'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XREF2_HD'.
  ls_fieldcat-seltext_m = 'Origen'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUZEI'.
  ls_fieldcat-seltext_m = 'Posición'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 3.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOART'.
  ls_fieldcat-seltext_m = 'Cl. Cta.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'HKONT'.
  ls_fieldcat-seltext_m = 'Cl. Cont.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TXT50'.
  ls_fieldcat-seltext_m = 'Nomb. Cta.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SHKZG'.
  ls_fieldcat-seltext_m = 'D / H'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 2.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MWSKZ'.
  ls_fieldcat-seltext_m = 'IVA'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 4.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'QSSKZ'.
  ls_fieldcat-seltext_m = 'retención'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
*  ls_fieldcat-hotspot = 'X'.
  ls_fieldcat-outputlen = 4.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WRBTR'.
  ls_fieldcat-seltext_m = 'Monto MD'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-cfieldname = 'WAERS'.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PSWBT'.
  ls_fieldcat-seltext_m = 'Monto ML'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
** V1 RVY 08-03-2022
* ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-cfieldname = 'PSWSL'.
  ls_fieldcat-tech      = 'X'.  "V1- Waldo Alarcón - Visionone - 17-03-2022
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PSWSL'.
  ls_fieldcat-seltext_m = 'Moneda Loc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  ls_fieldcat-tech      = 'X'. "V1- Waldo Alarcón - Visionone - 17-03-2022
  APPEND ls_fieldcat TO lt_fieldcat.

* INI - V1- Waldo Alarcón - Visionone - 17-03-2022
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname  = 'DMBTR'.
  ls_fieldcat-seltext_m  = 'Monto ML'.
  ls_fieldcat-seltext_s  = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l  = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen  = 10.
  ls_fieldcat-currency   = gv_waers.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname  = 'PSWSL'.
  ls_fieldcat-seltext_m  = 'Moneda ML'.
  ls_fieldcat-seltext_s  = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l  = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen  = 05.
  APPEND ls_fieldcat TO lt_fieldcat.
* FIN V1- Waldo Alarcón - Visionone - 17-03-2022

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SGTXT'.
  ls_fieldcat-seltext_m = 'Glo. Cont.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZUONR'.
  ls_fieldcat-seltext_m = 'Asignación'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KUNNR'.
  ls_fieldcat-seltext_m = 'Deudor'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'LIFNR'.
  ls_fieldcat-seltext_m = 'Acreedor'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'KOSTL'.
  ls_fieldcat-seltext_m = 'C. Costo'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'PRCTR'.
  ls_fieldcat-seltext_m = 'C. Benef'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZZPRESTAC'.
  ls_fieldcat-seltext_m = 'Prestación'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZZUNID_PRO'.
  ls_fieldcat-seltext_m = 'Producto'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZZDESC_EST'.
  ls_fieldcat-seltext_m = 'Desc. Estam.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZZMOT_EMIS'.
  ls_fieldcat-seltext_m = 'Mot. Emisión'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZZRUT_TERC'.
  ls_fieldcat-seltext_m = 'Rut Terceros'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME3'.
  ls_fieldcat-seltext_m = 'Nomb.Rut.Terc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZZ_AGENCIA'.
  ls_fieldcat-seltext_m = 'Agencia'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGDT'.
  ls_fieldcat-seltext_m = 'fecha Comp.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AUGBL'.
  ls_fieldcat-seltext_m = 'Docto. Comp.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'FDTAG'.
  ls_fieldcat-seltext_m = 'Fech. Venc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZFBDT'.
  ls_fieldcat-seltext_m = 'Fecha base'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZTERM'.
  ls_fieldcat-seltext_m = 'Cond. Pago'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZBD1T'.
  ls_fieldcat-seltext_m = 'Dias'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-seltext_m = 'Moneda Doc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STBLG'.
  ls_fieldcat-seltext_m = 'Docto. Anulac.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'AEDAT'.
  ls_fieldcat-seltext_m = 'Ult. Modif.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'USNAM'.
  ls_fieldcat-seltext_m = 'Usuario'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XREF1'.
  ls_fieldcat-seltext_m = 'Referencia 1'.
  ls_fieldcat-seltext_s = 'Ref. 1'.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XREF2'.
  ls_fieldcat-seltext_m = 'Referencia 2'.
  ls_fieldcat-seltext_s = 'Ref. 2'.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XREF3'.
  ls_fieldcat-seltext_m = 'Referencia 3'.
  ls_fieldcat-seltext_s = 'Ref. 3'.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 20.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZLSCH'.
  ls_fieldcat-seltext_m = 'Via pago'.
  ls_fieldcat-seltext_s = 'V.P.'.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 1.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'HBKID'.
  ls_fieldcat-seltext_m = 'Banco Propio'.
  ls_fieldcat-seltext_s = 'B.P.'.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 5.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ZLSPR'.
  ls_fieldcat-seltext_m = 'Bloqueo Pago'.
  ls_fieldcat-seltext_s = 'B.Pago'.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 1.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BKTXT'.
  ls_fieldcat-seltext_m = 'Texto Cab.'.
  ls_fieldcat-seltext_s = 'T.Cab.'.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 1.
  APPEND ls_fieldcat TO lt_fieldcat.

  REFRESH t_titulo[].
  t_titulo-titulo = 'Sociedad'.        APPEND t_titulo.
  t_titulo-titulo = 'Periodo'.         APPEND t_titulo.
  t_titulo-titulo = 'Fec. de Cont.'.   APPEND t_titulo.
  t_titulo-titulo = 'Do.'.             APPEND t_titulo.
  t_titulo-titulo = 'Desc.Do.'.        APPEND t_titulo.
  t_titulo-titulo = 'Documento'.       APPEND t_titulo.
  t_titulo-titulo = 'Nombre Cliente'.  APPEND t_titulo.
  t_titulo-titulo = 'Rut Cliente'.     APPEND t_titulo.
  t_titulo-titulo = 'Nombre Acreedor'. APPEND t_titulo.
  t_titulo-titulo = 'Identificador Fiscal'. APPEND t_titulo.
  t_titulo-titulo = 'Fec. Fact.'. APPEND t_titulo.
  t_titulo-titulo = 'N° de Fact'. APPEND t_titulo.
  t_titulo-titulo = 'Texto.Cab.'. APPEND t_titulo.
  t_titulo-titulo = 'Posición'. APPEND t_titulo.
  t_titulo-titulo = 'Cl. Cta.'. APPEND t_titulo.
  t_titulo-titulo = 'Cl. Contb'. APPEND t_titulo.
  t_titulo-titulo = 'Cl. Cont.'. APPEND t_titulo.
  t_titulo-titulo = 'Nomb. Cta.'. APPEND t_titulo.
  t_titulo-titulo =  ls_fieldcat-seltext_m = 'D / H'. APPEND t_titulo.
  t_titulo-titulo = 'IVA'. APPEND t_titulo.
  t_titulo-titulo = 'retención'. APPEND t_titulo.
  t_titulo-titulo = 'Monto'. APPEND t_titulo.
  t_titulo-titulo = 'Monto'. APPEND t_titulo.
  t_titulo-titulo = 'Moneda'. APPEND t_titulo.
  t_titulo-titulo = 'Glo. Cont.'. APPEND t_titulo.
  t_titulo-titulo = 'Asignación'. APPEND t_titulo.
  t_titulo-titulo = 'Deudor'. APPEND t_titulo.
  t_titulo-titulo = 'Acreedor'. APPEND t_titulo.
  t_titulo-titulo = 'c. costo'. APPEND t_titulo.
  t_titulo-titulo = 'c. benef'. APPEND t_titulo.
  t_titulo-titulo = 'Prestación'. APPEND t_titulo.
  t_titulo-titulo = 'Producto'. APPEND t_titulo.
  t_titulo-titulo = 'Desc. Estam.'. APPEND t_titulo.
  t_titulo-titulo = 'Mot. Emisión'. APPEND t_titulo.
  t_titulo-titulo = 'Rut Terceros'. APPEND t_titulo.
  t_titulo-titulo = 'Nomb.Rut.Terc.'. APPEND t_titulo.
  t_titulo-titulo = 'Agencia'. APPEND t_titulo.
  t_titulo-titulo = 'fecha Comp.'. APPEND t_titulo.
  t_titulo-titulo = 'Docto. Comp.'. APPEND t_titulo.
  t_titulo-titulo = 'Fech. Venc.'. APPEND t_titulo.
  t_titulo-titulo = 'Fecha base'. APPEND t_titulo.
  t_titulo-titulo = 'Cond. Pago'. APPEND t_titulo.
  t_titulo-titulo = 'Docto. Comp.'. APPEND t_titulo.
  t_titulo-titulo = 'Docto. Comp.'. APPEND t_titulo.
  t_titulo-titulo = 'Docto. Anulac.'. APPEND t_titulo.
  t_titulo-titulo = 'Ult. Modif.'. APPEND t_titulo.
  t_titulo-titulo = 'Usuario'. APPEND t_titulo.
  t_titulo-titulo = 'Origen'. APPEND t_titulo.
  t_titulo-titulo = 'Referencia 1'. APPEND t_titulo.
  t_titulo-titulo = 'Referencia 2'. APPEND t_titulo.
  t_titulo-titulo = 'Referencia 3'. APPEND t_titulo.
  t_titulo-titulo = 'Via pago'. APPEND t_titulo.
  t_titulo-titulo = 'Banco Propio'. APPEND t_titulo.
  t_titulo-titulo = 'Bloqueo Pago'. APPEND t_titulo.
  t_titulo-titulo = 'Texto Cabecera'. APPEND t_titulo.

ENDFORM.                    "fieldcat_init
*&---------------------------------------------------------------------*
*&      Form  show_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_alv.
  DATA ls_outtab TYPE ty_s_outtab.
  DATA itab TYPE TABLE OF zfi_mov_ctbles WITH HEADER LINE.
  DATA lv_mensaje(50) TYPE c.
  DATA lv_reg(5) TYPE n.

  gs_variant-report   = sy-repid.
  gs_variant-username = sy-uname.
  gs_variant-variant  = pa_vari.

*  IF p_check = 'X' AND NOT gt_outtab[] IS INITIAL .
*    DELETE FROM zfi_mov_ctbles .
*    LOOP AT gt_outtab INTO ls_outtab.
*      MOVE-CORRESPONDING ls_outtab TO itab. APPEND itab.CLEAR itab.
*    ENDLOOP.
*    INSERT zfi_mov_ctbles FROM TABLE itab.
*
*    IF sy-subrc = 0.
*      DESCRIBE TABLE itab LINES lv_reg.
*      CONCATENATE 'Se insertaron -> ' lv_reg ' en tabla ZFI_MOV_CTBLE' INTO lv_mensaje.
*      MESSAGE lv_mensaje TYPE 'S'.
*    ENDIF.
*  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active             = 'X'
      i_callback_program          = g_repid
      i_callback_user_command     = 'USER_COMMAND'
      i_callback_html_top_of_page = g_callback_html_top_of_page
      i_callback_pf_status_set    = 'SET_STATUS'
      is_layout                   = gs_layout
      it_sort                     = gt_sort[]
      it_fieldcat                 = gt_fieldcat[]
      is_variant                  = gs_variant
      i_html_height_top           = g_html_height_top
      i_save                      = 'A'
*     i_html_height_end           = 10
    TABLES
      t_outtab                    = gt_outtab.



ENDFORM.                    "show_alv
*&---------------------------------------------------------------------*
*&      Form  html_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DOCUMENT   text
*----------------------------------------------------------------------*
FORM html_top_of_page USING document
                            TYPE REF TO cl_dd_document.     "#EC CALLED

  DATA: l_title    TYPE sdydo_text_element,
        l_text     TYPE sdydo_text_element,
        l_font     TYPE sdydo_attribute VALUE '1',
        ls_zfigiro TYPE zfigiro,
        l_month    TYPE fcltx.

  READ TABLE ti_sociedad INTO wa_sociedad INDEX 1.
*  CONCATENATE g_address_value-name1 ''
  CONCATENATE wa_sociedad-name1 ''
   INTO l_text SEPARATED BY space.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
  CALL METHOD document->new_line.
  l_text = 'Fecha:'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  CALL METHOD document->add_gap
    EXPORTING
      width = 8.
  CONCATENATE sy-datum+6 sy-datum+4(2) sy-datum(4) INTO l_text SEPARATED BY '/'.

  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

  CALL METHOD document->new_line.
  l_text = 'Hora:'.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 9.
  CONCATENATE sy-timlo(2) sy-timlo+2(2) sy-timlo+4(2) INTO l_text SEPARATED BY ':'.

  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.


  CALL METHOD document->new_line.
  l_text = 'Registros:'.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 1.

  DESCRIBE TABLE gt_outtab LINES l_text.

  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

  CALL METHOD document->new_line.
  l_title = 'Reporte de Movimientos Contables'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 155.
  CALL METHOD document->add_text
    EXPORTING
      text          = l_title
      sap_style     = 'HEADING'
*     sap_fontsize  = l_font.
      sap_fontstyle = 'C'
      sap_emphasis  = 'C'.



ENDFORM.                    "html_top_of_page

*&---------------------------------------------------------------------*
*&      Form  get_info_lfa1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PS_BSEG    text
*      -->PS_OUTTAB  text
*----------------------------------------------------------------------*
FORM get_info_lfa1 USING ps_bseg TYPE bseg
                   CHANGING ps_outtab TYPE ty_s_outtab.

*  SELECT SINGLE name1 stcd1
*    FROM lfa1
*    INTO (ps_outtab-name1, ps_outtab-stcd1)
*    WHERE lifnr EQ ps_bseg-lifnr.

ENDFORM.                    " get_info_lfa1


*&---------------------------------------------------------------------*
*&      Form  layout_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.

  rs_layout-colwidth_optimize      = 'X'.
  rs_layout-zebra = 'X'.
ENDFORM.                    "layout_init
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                      rs_selfield TYPE slis_selfield.       "#EC *
  DATA ls_outtab TYPE ty_s_outtab.
  rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN '&F05'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN '&IC1'.
      READ TABLE gt_outtab
        INTO ls_outtab
        INDEX rs_selfield-tabindex .
      CASE rs_selfield-fieldname.
        WHEN 'BELNR'.
          CHECK   rs_selfield-value IS NOT INITIAL.
          SET PARAMETER ID: 'BLN' FIELD ls_outtab-belnr,
                            'BUK' FIELD ls_outtab-bukrs,
                            'GJR' FIELD ls_outtab-gjahr.

          CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
      ENDCASE.
    WHEN '&EXCEL'.
      DATA: wl_file TYPE string.

      PERFORM refresca_cat.
      PERFORM get_filename  CHANGING wl_file.
      PERFORM download_to_exc  USING wl_file gt_outtab.

  ENDCASE.
ENDFORM.                    "user_comma
*&---------------------------------------------------------------------*
*&      Form  set_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_status  USING rt_extab TYPE slis_t_extab .         "#EC *
  SET PF-STATUS 'STATUS' EXCLUDING rt_extab.
ENDFORM.                    "set_statusnd

*&---------------------------------------------------------------------*
*&      Form  get_description_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS    text
*      -->P_BUTXT    text
*----------------------------------------------------------------------*
FORM get_description_bukrs. "USING p_bukrs TYPE bukrs
*                           CHANGING p_butxt TYPE butxt.
  DATA : l_adrnr             TYPE adrnr,
         l_address_selection TYPE addr1_sel,
         l_zgiro             TYPE zfigiro.

  SELECT bukrs butxt adrnr waers
    FROM t001
    INTO CORRESPONDING FIELDS OF TABLE ti_sociedad
*    (p_butxt, l_adrnr, gv_waers)  "V1- Waldo Alarcon - Visionone - 17-03-2022
** INI RVY 10.08.2023
*    WHERE bukrs EQ p_bukrs
    WHERE bukrs IN p_bukrs
** FIN RVY 10.08.2023
    AND spras EQ sy-langu.
  SORT ti_sociedad BY bukrs.

  LOOP AT ti_sociedad ASSIGNING FIELD-SYMBOL(<fs>).
    CLEAR l_address_selection.
    MOVE <fs>-adrnr TO  l_address_selection-addrnumber.
** V1 RVY 02-11-2023
    MOVE <fs>-waers TO  gv_waers.
** V1 RVY 02-11-2023

    CALL FUNCTION 'ADDR_GET'
      EXPORTING
        address_selection = l_address_selection
      IMPORTING
        address_value     = g_address_value
      EXCEPTIONS
        parameter_error   = 1
        address_not_exist = 2
        version_not_exist = 3
        internal_error    = 4
        OTHERS            = 5.

    <fs>-name1 = g_address_value-name1.

**ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES04 ECDK917080 *
    SELECT SINGLE paval
      FROM t001z
      INTO <fs>-paval
** INI RVY 10.08.2023
*  WHERE bukrs EQ p_bukrs
    WHERE bukrs = <fs>-bukrs
** FIN RVY 10.08.2023
      AND party EQ 'TAXNR' .

  ENDLOOP.

**ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES04 ECDK917080 *
*  SELECT SINGLE paval
*    FROM t001z
*    INTO g_paval
*** INI RVY 10.08.2023
**  WHERE bukrs EQ p_bukrs
*  WHERE bukrs IN p_bukrs
*** FIN RVY 10.08.2023
*    AND party EQ 'TAXNR' .

  SELECT * FROM zfigiro
    INTO TABLE gt_zfigiro
** INI RVY 10.08.2023
*    WHERE bukrs = p_bukrs.
    WHERE bukrs IN p_bukrs.
** FIN RVY 10.08.2023
  IF sy-subrc EQ 0.
    READ TABLE gt_zfigiro INTO l_zgiro INDEX 1.
    IF sy-subrc EQ 0.
      IF l_zgiro-giro_1 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_2 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_3 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_4 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_5 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_6 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.
      IF l_zgiro-giro_7 IS NOT INITIAL.
        ADD 1 TO g_html_height_top.
      ENDIF.

    ENDIF.
  ENDIF.
ENDFORM.                    "get_description_bu

*&---------------------------------------------------------------------*
*&      Form  init_global_values.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_global_values .
  DATA: ls_cl_doc   TYPE ty_s_cl_doc,
        ls_download TYPE ty_s_download.


  g_repid = sy-repid.
  gs_iva_doc_e-descripcion = TEXT-020.

  ls_cl_doc-descripcion = TEXT-021.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 1.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.


  REFRESH: s_buzei.
  s_buzei-sign = 'I'.
  s_buzei-option = 'BT'.
  s_buzei-low = '001'.
  s_buzei-high = '999'.
  APPEND s_buzei.
ENDFORM.                    " init_global_values.
*&---------------------------------------------------------------------*
*&      Form  BUSCAR_MOTIVO_EMIS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM buscar_motivo_emis CHANGING motivo.

  DATA:  dyfields LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF list_of_fields1 OCCURS 10,
           fieldname LIKE dd03l-fieldname,
         END OF list_of_fields1.

  DATA : indice1       LIKE sy-tabix,
         fieldname1    LIKE dd03l-fieldname,
         fields1       LIKE help_value OCCURS 10 WITH HEADER LINE,
         shrinkfields1 LIKE dynpread OCCURS 0 WITH HEADER LINE,
         dynpfields1   LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF t_zmot_emis OCCURS 0.
          INCLUDE STRUCTURE zmot_emis.
        DATA: END OF t_zmot_emis.

**comment
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_zmot_emis
*    FROM zmot_emis.
**Add ini
SELECT *
  INTO CORRESPONDING FIELDS OF TABLE @t_zmot_emis
  FROM zmot_emis."#EC CI_NOWHERE
**add fin

  list_of_fields1-fieldname = 'ZMOT_EMIS-MANDT'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'ZMOT_EMIS-BUKRS'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'ZMOT_EMIS-ZZMOT_EMIS'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'ZMOT_EMIS-ZZDESCR'.
  APPEND list_of_fields1.

  fieldname1 = 'ZZMOT_EMIS'.

  CALL FUNCTION 'TRANSFER_NAMES_TO_FIELDS'
    EXPORTING
      selectfield        = fieldname1
    TABLES
      fields             = fields1
      namelist           = list_of_fields1
    EXCEPTIONS
      wrong_format_given = 01.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = fieldname1
    IMPORTING
      ind                          = indice1
    TABLES
      fields                       = fields1
      full_table                   = t_zmot_emis
    EXCEPTIONS
      full_table_empty             = 01
      no_tablestructure_given      = 02
      no_tablefields_in_dictionary = 03
      more_than_one_selectfield    = 04
      no_electfield                = 05.
  IF sy-subrc = 0.
    READ TABLE t_zmot_emis INDEX indice1.
    MOVE t_zmot_emis-zzmot_emis TO motivo.


  ENDIF.

ENDFORM.                    " BUSCAR_MOTIVO_EMIS

*&---------------------------------------------------------------------*
*&      Form  alv_variant_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PA_VARI    text
*----------------------------------------------------------------------*
FORM alv_variant_f4 CHANGING pa_vari.
  DATA: rs_variant LIKE disvariant.
  DATA nof4 TYPE c.

  CLEAR nof4.
  LOOP AT SCREEN.
    IF screen-name = 'PA_VARI'.
      IF screen-input = 0.
        nof4 = 'X'.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DATA: l_tabname TYPE slis_tabname.
  DATA: l_tabname_item TYPE slis_tabname.

  rs_variant-report   = g_repid.
  rs_variant-username = sy-uname.
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant          = rs_variant
      i_save              = 'A'
      i_display_via_grid  = 'X'
      i_tabname_header    = l_tabname
      i_tabname_item      = l_tabname_item
      it_default_fieldcat = gt_fieldcat
    IMPORTING
      es_variant          = rs_variant
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc = 0 AND nof4 EQ space.
    pa_vari = rs_variant-variant.
  ENDIF.
ENDFORM.                               " ALV_VARIANT_F4

*&---------------------------------------------------------------------*
*&      Form  get_filename
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FILE     text
*----------------------------------------------------------------------*
FORM get_filename  CHANGING p_file TYPE string.

  DATA w_file LIKE rlgrap-filename.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      mask          = '*.xls'
    CHANGING
      file_name     = w_file
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.

  p_file = w_file.

ENDFORM.                      "GET_FILENAME

*&---------------------------------------------------------------------*
*&      Form  download_to_exc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PI_FILE    text
*      -->TI_SPFLI   text
*----------------------------------------------------------------------*
FORM download_to_exc  USING pi_file  TYPE string
                            ti_datos TYPE ty_t_outtab.

  TYPES: BEGIN OF ty_s_outtab2,
           bukrs      TYPE bukrs,
           gjahr      TYPE gjahr,
           budat      TYPE budat,
           blart      TYPE blart,
           ltext      TYPE ltext_003t,
           belnr      TYPE belnr_d,
           name2      LIKE kna1-name1,
           stcd2      LIKE kna1-stcd1,
           name1      LIKE lfa1-name1,
           stcd1      LIKE lfa1-stcd1,
           bldat      TYPE bldat,
           xblnr      TYPE xblnr,
           bktxt      LIKE bkpf-bktxt,
           buzei      LIKE bseg-buzei,
           koart      LIKE bseg-koart,
           bschl      LIKE bseg-bschl,
           hkont      LIKE bseg-hkont,
           txt50      LIKE skat-txt50,
           shkzg      LIKE bseg-shkzg,
           mwskz      LIKE bseg-mwskz,
           qsskz      LIKE bseg-qsskz,
           wrbtr(15)  TYPE c,
           pswbt(15)  TYPE c,
           pswsl      LIKE bseg-pswsl,
           sgtxt      LIKE bseg-sgtxt,
           zuonr      LIKE bseg-zuonr,
           kunnr      LIKE bseg-kunnr,
           lifnr      LIKE bseg-lifnr,
           kostl      LIKE bseg-kostl,
           prctr      LIKE bseg-prctr,
           zzprestac  LIKE bseg-zzprestac,
           zzunid_pro LIKE bseg-zzunid_pro,
           zzdesc_est LIKE bseg-zzdesc_est,
           zzmot_emis LIKE bseg-zzmot_emis,
           zzrut_terc LIKE bseg-zzrut_terc,
           zz_agencia LIKE bseg-zz_agencia,
           augdt      LIKE bseg-augdt,
           augbl      LIKE bseg-augbl,
           fdtag      LIKE bseg-fdtag,
           zfbdt      LIKE bseg-zfbdt,
           zterm      LIKE bseg-zterm,
           zbd1t      LIKE bseg-zbd1t,
           waers      LIKE bkpf-waers,
           stblg      LIKE bkpf-stblg,
           aedat      LIKE bkpf-aedat,
           usnam      LIKE bkpf-usnam,
           xref2_hd   LIKE bkpf-xref2_hd,
           xref1      LIKE bseg-xref1,
           xref2      LIKE bseg-xref2,
           xref3      LIKE bseg-xref3,
           zlsch      LIKE bseg-zlsch,
           hbkid      LIKE bseg-hbkid,
           zlspr      LIKE bseg-zlspr,
         END OF ty_s_outtab2,
         ty_t_outtab2 TYPE TABLE OF ty_s_outtab2.

  DATA: wl_file TYPE  rlgrap-filename.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  DATA: tt_datos TYPE ty_s_outtab2 OCCURS 0 WITH HEADER LINE.

  DATA ls_outtab TYPE ty_s_outtab.
  LOOP AT gt_outtab INTO ls_outtab.
    tt_datos-bukrs = ls_outtab-bukrs.
    tt_datos-gjahr = ls_outtab-gjahr.
    tt_datos-budat = ls_outtab-budat.
    tt_datos-blart = ls_outtab-blart.
    tt_datos-ltext = ls_outtab-ltext.
    tt_datos-belnr = ls_outtab-belnr.
    tt_datos-name2 = ls_outtab-name2.
    tt_datos-stcd2 = ls_outtab-stcd2.
    tt_datos-name1 = ls_outtab-name1.
    tt_datos-stcd1 = ls_outtab-stcd1.
    tt_datos-bldat = ls_outtab-bldat.
    tt_datos-xblnr = ls_outtab-xblnr.
    tt_datos-bktxt = ls_outtab-bktxt.
    tt_datos-buzei = ls_outtab-buzei.
    tt_datos-koart = ls_outtab-koart.
    tt_datos-bschl = ls_outtab-bschl.
    tt_datos-hkont = ls_outtab-hkont.
    tt_datos-txt50 = ls_outtab-txt50.
    tt_datos-shkzg = ls_outtab-shkzg.
    tt_datos-mwskz = ls_outtab-mwskz.
    tt_datos-qsskz = ls_outtab-qsskz.
    WRITE ls_outtab-wrbtr TO tt_datos-wrbtr CURRENCY ls_outtab-waers.
    WRITE ls_outtab-pswbt TO tt_datos-pswbt CURRENCY ls_outtab-pswsl.
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value = tt_datos-wrbtr.

    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value = tt_datos-pswbt.

    tt_datos-pswsl = ls_outtab-pswsl.
    tt_datos-sgtxt = ls_outtab-sgtxt.
    tt_datos-zuonr = ls_outtab-zuonr.
    tt_datos-kunnr = ls_outtab-kunnr.
    tt_datos-lifnr = ls_outtab-lifnr.
    tt_datos-kostl = ls_outtab-kostl.
    tt_datos-prctr = ls_outtab-prctr.
    tt_datos-zzprestac    = ls_outtab-zzprestac.
    tt_datos-zzunid_pro    = ls_outtab-zzunid_pro.
    tt_datos-zzdesc_est    = ls_outtab-zzdesc_est.
    tt_datos-zzmot_emis    = ls_outtab-zzmot_emis.
    tt_datos-zzrut_terc    = ls_outtab-zzrut_terc.
    tt_datos-zz_agencia    = ls_outtab-zz_agencia.
    tt_datos-augdt    = ls_outtab-augdt.
    tt_datos-augbl    = ls_outtab-augbl.
    tt_datos-fdtag    = ls_outtab-fdtag.
    tt_datos-zfbdt    = ls_outtab-zfbdt.
    tt_datos-zterm    = ls_outtab-zterm.
    tt_datos-zbd1t    = ls_outtab-zbd1t.
    tt_datos-waers    = ls_outtab-waers.
    tt_datos-stblg    = ls_outtab-stblg.
    tt_datos-aedat    = ls_outtab-aedat.
    tt_datos-usnam    = ls_outtab-usnam.
    tt_datos-xref2_hd    = ls_outtab-xref2_hd.
    tt_datos-xref1     = ls_outtab-xref1.
    tt_datos-xref2     = ls_outtab-xref2.
    tt_datos-xref3     = ls_outtab-xref3.
    tt_datos-zlsch     = ls_outtab-zlsch.
    tt_datos-hbkid    = ls_outtab-hbkid.
    tt_datos-zlspr    = ls_outtab-zlspr.
    APPEND tt_datos. CLEAR tt_datos.
  ENDLOOP.
*  tt_datos[] = [].

*  FIELD-SYMBOLS:  <fl> TYPE tl_name.

  wl_file = pi_file.

*  LOOP AT gt_fieldcat INTO ls_fieldcat .
*    APPEND INITIAL LINE TO tl_name ASSIGNING <fl>.
*    <fl>-fldname =  ls_fieldcat-seltext_s.
*  ENDLOOP.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = pi_file
      write_field_separator   = 'X'
    TABLES
      data_tab                = tt_datos
      fieldnames              = t_titulo
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21.

*  CALL FUNCTION 'MS_EXCEL_OLE_STANDARD_DAT'
*    EXPORTING
*      file_name                 = wl_file
*      data_sheet_name           = 'Mov.Contables'
*    TABLES
*      data_tab                  = tt_datos
*      fieldnames                = tl_name
*    EXCEPTIONS
*      file_not_exist            = 1
*      filename_expected         = 2
*      communication_error       = 3
*      ole_object_method_error   = 4
*      ole_object_property_error = 5
*      invalid_filename          = 6
*      invalid_pivot_fields      = 7
*      download_problem          = 8
*      OTHERS                    = 9.
  IF sy-subrc <> 0.

    FORMAT COLOR COL_BACKGROUND INTENSIFIED.
    WRITE:/ 'Error cargando el archivo'.
    EXIT.
  ENDIF.

  CASE sy-subrc.
    WHEN 1.
      MESSAGE e000(yv01) WITH 'File does not exist'.
    WHEN 2.
      MESSAGE e000(yv01) WITH 'Filename expected'.
    WHEN 3.
      MESSAGE e000(yv01) WITH 'Communication error'.
    WHEN 4.
      MESSAGE e000(yv01) WITH 'OLE object method error'.
    WHEN 5.
      MESSAGE e000(yv01) WITH 'OLE object property error'.
    WHEN 6.
      MESSAGE e000(yv01) WITH 'Invalid filename'.
    WHEN 7.
      MESSAGE e000(yv01) WITH 'Invalid pivot fields'.
    WHEN 8.
      MESSAGE e000(yv01) WITH 'Download problem'.
    WHEN 9.
      MESSAGE e000(yv01) WITH 'Other problem'.
  ENDCASE.


ENDFORM.                    " DOWNLOAD_TO_EXC
*&---------------------------------------------------------------------*
*&      Form  REFRESCA_CAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresca_cat .
*  DATA lv_ref_grid TYPE REF TO cl_gui_alv_grid.
*  IF lv_ref_grid IS INITIAL.
*    CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
*      IMPORTING
*        e_grid = lv_ref_grid.
*  ENDIF.
*  IF NOT lv_ref_grid IS INITIAL.
*    CALL METHOD lv_ref_grid->set_frontend_fieldcatalog
*      EXPORTING
*        it_fieldcatalog = gt_fieldcat.
*  ENDIF.
*  ps_selfield-refresh = abap_true.
ENDFORM.                    " REFRESCA_CAT
*&---------------------------------------------------------------------*
*&      Form  LLENA_TABLAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM llena_tablas .
  REFRESH: gt_lfa1[], gt_lfb1[], gt_kna1[], gt_knb1[], gt_skat[], gt_t003t[].

  SELECT a~lifnr a~name1 a~stcd1 INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
      FROM lfa1 AS a INNER JOIN lfb1 AS b
       ON a~lifnr = b~lifnr
** INI RVY 10.08.2023
*      WHERE b~bukrs = p_bukrs
       WHERE b~bukrs IN p_bukrs
** FIN RVY 10.08.2023
        AND a~land1 = 'CL'.

  SELECT a~kunnr a~name1 a~stcd1 INTO CORRESPONDING FIELDS OF TABLE gt_kna1
      FROM kna1 AS a INNER JOIN knb1 AS b
       ON a~kunnr = b~kunnr
** INI RVY 10.08.2023
*      WHERE b~bukrs = p_bukrs
      WHERE b~bukrs IN p_bukrs
** FIN RVY 10.08.2023
        AND a~land1 = 'CL'.

  SELECT spras ktopl saknr txt50 INTO CORRESPONDING FIELDS OF TABLE gt_skat
    FROM skat
       WHERE spras = 'S'
         AND ktopl = 'B100'.

  SELECT spras blart ltext INTO CORRESPONDING FIELDS OF TABLE gt_t003t
      FROM t003t
    WHERE spras = 'S'.


ENDFORM.                    " LLENA_TABLAS

*&---------------------------------------------------------------------*
*&      Form  append_user_dirs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM append_user_dirs.
  DATA:
    lt_user_dir TYPE STANDARD TABLE OF user_dir,
    ls_user_dir TYPE user_dir,
    ls_entry    TYPE cst_rswatch01_alv.

*  get the name of the current server.
  CALL 'C_SAPGPARAM' ID 'NAME' FIELD 'rdisp/myname'
                     ID 'VALUE' FIELD my_name.

* get the name and aliases of ALL userdefined directories
*add comment
  SELECT DIRNAME,ALIASS,SVRNAME,SP_NAME,SP_CS
     FROM user_dir INTO TABLE @lt_user_dir
      WHERE svrname IN (@my_name, @all_server)
      ORDER BY aliass.

  LOOP AT lt_user_dir INTO ls_user_dir.
    ls_entry-sap_dir = ls_user_dir-aliass.
    ls_entry-dirname = ls_user_dir-dirname.
    APPEND ls_entry TO gt_outt.
  ENDLOOP.
ENDFORM.                    " APPEND_USER_DIRS

*&---------------------------------------------------------------------*
*&      Form  append_dir_from_profile_param
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PARAM    text
*----------------------------------------------------------------------*
FORM append_dir_from_profile_param USING p_param TYPE text60.
  DATA:
    ls_entry TYPE cst_rswatch01_alv.

  CALL 'C_SAPGPARAM' ID 'NAME'  FIELD p_param
                     ID 'VALUE' FIELD ls_entry-dirname.
  CHECK sy-subrc = 0.
  IF ls_entry-dirname IS INITIAL. RETURN. ENDIF.
  IF p_param = 'DIR_GLOBAL'.
    globaldirectory = ls_entry-dirname.
  ENDIF.

  ls_entry-sap_dir = p_param.
  APPEND ls_entry TO gt_outt.
ENDFORM.                    "append_dir_from_profile_param

*&---------------------------------------------------------------------*
*&      Form  append_db_home
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM append_db_home.
  CASE sy-dbsys(3).
    WHEN 'ORA'.
      PERFORM append_dir_from_profile_param USING 'DIR_ORAHOME'.
    WHEN 'ADA'.
      PERFORM append_dir_from_env USING 'DBROOT' 'DIR_ADA_DBROOT'.
    WHEN 'DB6'.
      PERFORM append_dir_from_env USING 'INSTHOME' 'DIR_DB2_HOME'.
    WHEN OTHERS.
      RETURN.
  ENDCASE.
ENDFORM.                    " APPEND_DB_HOME

*&---------------------------------------------------------------------*
*&      Form  append_dir_from_env
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ENV      text
*      -->P_ALIAS    text
*----------------------------------------------------------------------*
FORM append_dir_from_env USING p_env   TYPE text60
                               p_alias TYPE text60.
  DATA:
    ls_entry TYPE cst_rswatch01_alv.

  CALL 'C_GETENV' ID 'NAME'  FIELD p_env
                  ID 'VALUE' FIELD ls_entry-dirname.
  CHECK sy-subrc = 0.
  IF ls_entry-dirname IS INITIAL. RETURN. ENDIF.

  ls_entry-sap_dir = p_alias.
  APPEND ls_entry TO gt_outt.
ENDFORM.                    "append_dir_from_env

*&---------------------------------------------------------------------*
*&      Form  append_dir_saphostagent
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM append_dir_saphostagent.
  DATA:
    ls_entry TYPE cst_rswatch01_alv.

* calculate directory for saphostagent (no sapparam available...)
  IF ( sy-opsys(3) = 'WIN' ) OR ( sy-opsys(3) = 'Win' ).
    DATA: windir_path(64),  programfiles_path(64).
*   hoping that ProgramFiles is set in service user environment
    CALL 'C_GETENV' ID 'NAME'  FIELD 'ProgramFiles'
                    ID 'VALUE' FIELD programfiles_path.

    IF programfiles_path IS INITIAL.
*     %ProgramFiles% not available. guess from windir
      CALL 'C_GETENV' ID 'NAME'  FIELD 'windir'
                      ID 'VALUE' FIELD windir_path.
*     e.g. S:\WINDOWS ==> S:\Program Files
      CONCATENATE windir_path(3) 'Program Files' INTO programfiles_path. "#EC NOTEXT
    ENDIF.

    CONCATENATE programfiles_path '\SAP\hostctrl'
      INTO ls_entry-dirname.
  ELSE.
*   on UNIX, the path is hard coded
    ls_entry-dirname = '/usr/sap/hostctrl'.
  ENDIF.

  ls_entry-sap_dir = 'DIR_SAPHOSTAGENT'.
  APPEND ls_entry TO gt_outt.
ENDFORM.                              " append_dir_saphostagent


*&---------------------------------------------------------------------*
*&      Form  genera_txt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM genera_txt .
  DATA: gv_filestatus1 TYPE c LENGTH 256,
        gv_filestatus2 TYPE c LENGTH 256.

  DATA : p_nombre LIKE epsf-epsfilnam,
         p_ruta   LIKE epsf-epsdirnam.


  p_ruta = p_fdir.

  CONCATENATE p_fdir '/Mov.Contables_' sy-datum '_' sy-uzeit '.csv' INTO  p_nombre .

*  p_ruta = p_fdir.

  OPEN DATASET p_nombre  FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.


  CONCATENATE
 'Sociedad'
 'Periodo'
    'Fec. de Cont.'
    'Do.'
    'Desc.Do.'
    'Documento'
    'Nombre Cliente'
    'Rut Cliente'
    'Nombre Acreedor'
    'Identificador Fiscal'
    'Fec. Fact.'
    'N° de Fact'
    'Texto.Cab.'
    'Posición'
    'Cl. Cta.'
    'Cl. Contb'
    'Cl. Cont.'
    'Nomb. Cta.'
    'D / H'
    'IVA'
    'retención'
    'Monto'
    'Monto'
    'Moneda'
    'Glo. Cont.'
    'Asignación'
    'Deudor'
    'Acreedor'
    'c. costo'
    'c. benef'
    'Prestación'
    'Producto'
    'Desc. Estam.'
    'Mot. Emisión'
    'Rut Terceros'
    'Agencia'
    'fecha Comp.'
    'Docto. Comp.'
    'Fech. Venc.'
    'Fecha base'
    'Cond. Pago'
    'Docto. Comp.'
    'Docto. Comp.'
    'Docto. Anulac.'
    'Ult. Modif.'
    'Usuario'
    'Origen'
    'Referencia 1'
    'Referencia 2'
    'Referencia 3'
    'Via pago'
    'Banco Propio'
    'Bloqueo Pago'
    INTO t_salida-linea RESPECTING BLANKS SEPARATED BY ';'.
  TRANSFER  t_salida  TO p_nombre.

  DATA: x_wrbtr(15) TYPE c.
  DATA: x_pswbt(15) TYPE c.
  DATA: x_zbd1t(10) TYPE c.

  DATA ls_outtab TYPE ty_s_outtab.
  LOOP AT gt_outtab INTO ls_outtab.
    WRITE ls_outtab-wrbtr TO x_wrbtr CURRENCY ls_outtab-waers. CONDENSE x_wrbtr NO-GAPS.
    WRITE ls_outtab-pswbt TO x_pswbt CURRENCY ls_outtab-pswsl. CONDENSE x_pswbt NO-GAPS.
    WRITE ls_outtab-zbd1t TO x_zbd1t. CONDENSE x_zbd1t NO-GAPS.

    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value = x_wrbtr.

    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value = x_pswbt.


    CONCATENATE
             ls_outtab-bukrs
             ls_outtab-gjahr
             ls_outtab-budat
             ls_outtab-blart
             ls_outtab-ltext
             ls_outtab-belnr
             ls_outtab-name2
             ls_outtab-stcd2
             ls_outtab-name1
             ls_outtab-stcd1
             ls_outtab-bldat
             ls_outtab-xblnr
             ls_outtab-bktxt
             ls_outtab-buzei
             ls_outtab-koart
             ls_outtab-bschl
             ls_outtab-hkont
             ls_outtab-txt50
             ls_outtab-shkzg
             ls_outtab-mwskz
             ls_outtab-qsskz
             x_wrbtr
             x_pswbt
             ls_outtab-pswsl
             ls_outtab-sgtxt
             ls_outtab-zuonr
             ls_outtab-kunnr
             ls_outtab-lifnr
             ls_outtab-kostl
             ls_outtab-prctr
             ls_outtab-zzprestac
             ls_outtab-zzunid_pro
             ls_outtab-zzdesc_est
             ls_outtab-zzmot_emis
             ls_outtab-zzrut_terc
             ls_outtab-zz_agencia
             ls_outtab-augdt
             ls_outtab-augbl
             ls_outtab-fdtag
             ls_outtab-zfbdt
             ls_outtab-zterm
             x_zbd1t
             ls_outtab-waers
             ls_outtab-stblg
             ls_outtab-aedat
             ls_outtab-usnam
             ls_outtab-xref2_hd
             ls_outtab-xref1
             ls_outtab-xref2
             ls_outtab-xref3
             ls_outtab-zlsch
             ls_outtab-hbkid
             ls_outtab-zlspr
    INTO t_salida-linea RESPECTING BLANKS SEPARATED BY ';'.
    TRANSFER  t_salida  TO p_nombre.
  ENDLOOP.
*  PERFORM datos.


  MESSAGE 'Archivo Generado' TYPE 'I'.



ENDFORM.                    " GENERA_TXT

*&---------------------------------------------------------------------*
*&      Form  datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM datos .


  CONCATENATE eps_txtbuf-line ';' INTO eps_txtbuf-line.

  eps_txtbuf-length = 505.
  APPEND eps_txtbuf. CLEAR eps_txtbuf.

***********************************************************************



ENDFORM.                    " DATOS
