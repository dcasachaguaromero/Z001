*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
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

  DATA: ls_bkpf   TYPE bkpf,
        ls_bseg   TYPE bseg,
        ls_bset   TYPE bset,
        ls_outtab TYPE ty_s_outtab.
  DATA: ls_stblg TYPE rbkp-stblg. "mod 24.07.2015 PCM descarta anulados MM

  SELECT * FROM bkpf
*    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    INTO CORRESPONDING FIELDS OF ls_bkpf "mod 24.07.2015 PCM descarta anulados MM
    WHERE bukrs EQ p_bukrs
    AND gjahr EQ p_gjahr
    AND belnr IN s_belnr
    AND blart IN gr_blart
    AND monat IN s_monat
    AND xblnr IN s_xblnr
    AND stblg EQ space
    AND bstat EQ space.

    CLEAR ls_stblg.                       "mod 24.07.2015 PCM descarta anulados MM
    SELECT SINGLE stblg INTO ls_stblg     "mod 24.07.2015 PCM descarta anulados MM
      FROM rbkp                           "mod 24.07.2015 PCM descarta anulados MM
      WHERE belnr = ls_bkpf-awkey(10)     "mod 24.07.2015 PCM descarta anulados MM
        AND gjahr = ls_bkpf-awkey+10(4).  "mod 24.07.2015 PCM descarta anulados MM
    IF ls_stblg IS NOT INITIAL.           "mod 24.07.2015 PCM descarta anulados MM
      CONTINUE.                           "mod 24.07.2015 PCM descarta anulados MM
    ELSE.                                 "mod 24.07.2015 PCM descarta anulados MM
      APPEND ls_bkpf TO gt_bkpf.          "mod 24.07.2015 PCM descarta anulados MM
    ENDIF.                                "mod 24.07.2015 PCM descarta anulados MM
  ENDSELECT.                              "mod 24.07.2015 PCM descarta anulados MM

  LOOP AT gt_bkpf INTO ls_bkpf .

* ziclos mayo 2011 obtenemos el procentaje por cada documento por fecha contable
    CLEAR porc_iva.

    LOOP AT  ta_zfiivaprp  WHERE  bukrs = ls_bkpf-bukrs
                     AND    fec_inico  <= ls_bkpf-budat
                     AND    fec_fin    >= ls_bkpf-budat.
    ENDLOOP.
    IF sy-subrc EQ 0.

      porc_iva = 100 - ta_zfiivaprp-iva_prop.


    ENDIF.
SELECT * FROM bseg
INTO CORRESPONDING FIELDS OF TABLE gt_bseg
WHERE bukrs EQ ls_bkpf-bukrs
AND belnr EQ ls_bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND gjahr EQ ls_bkpf-gjahr.
AND GJAHR EQ LS_BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *


    LOOP AT gt_bseg INTO ls_bseg
      WHERE koart EQ 'K'.

      PERFORM get_info_lfa1
                  USING    ls_bseg
                  CHANGING ls_outtab.

    ENDLOOP.
* ziclos mayo 2011  para saber si tiene activo fijo
    LOOP AT gt_bseg INTO ls_bseg
        WHERE koart EQ 'A'.
      MOVE ls_bseg-anln1 TO wa_lce-es_act_fijo.
      EXIT.
    ENDLOOP.


SELECT * FROM bset
INTO CORRESPONDING FIELDS OF TABLE gt_bset
WHERE bukrs EQ ls_bkpf-bukrs
AND belnr EQ ls_bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND gjahr EQ ls_bkpf-gjahr.
AND GJAHR EQ LS_BKPF-GJAHR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

    SORT gt_bset BY mwskz ASCENDING.
    CLEAR: gv_combinada. " Agregado por L_FOUBERT 23.07.2013
    LOOP AT gt_bset INTO ls_bset.
      PERFORM determine_tax
                  USING
                     ls_bset
                     ls_bkpf
                  CHANGING
                     ls_outtab.
    ENDLOOP.

    IF gt_bset[] IS NOT INITIAL AND gt_bseg[] IS NOT INITIAL .
*     TODA NOTA DE CREDITO SE MULPIPLICARA POR -1 PARA EFECTO DE GRILLA
* PYV 16/11/2011 Se Agregan Tipos de Documentos Correspondientes a Notas de Crédito (NO;NA;NB;NC)
      "      IF ls_bkpf-blart EQ 'N1' OR
      "         ls_bkpf-blart EQ 'N2' OR
      "         ls_bkpf-blart EQ 'N3' OR
      "         ls_bkpf-blart EQ 'N4'.
      IF ls_bkpf-blart EQ 'N1' OR
         ls_bkpf-blart EQ 'N2' OR
         ls_bkpf-blart EQ 'N3' OR
         ls_bkpf-blart EQ 'N4' OR
         ls_bkpf-blart EQ 'N0' OR
         ls_bkpf-blart EQ 'NA' OR
         ls_bkpf-blart EQ 'NB' OR
         ls_bkpf-blart EQ 'NC'.
* PYV 16/11/2011 Se Agregan Tipos de Documentos Correspondientes a Notas de Crédito (NO;NA;NB;NC)
        ls_outtab-taxbash1 = ABS( ls_outtab-taxbash1 ) * -1.
        ls_outtab-taxbash2 = ABS( ls_outtab-taxbash2 ) * -1.
        ls_outtab-taxbash3 = ABS( ls_outtab-taxbash3 ) * -1.
        ls_outtab-taxbash4 = ABS( ls_outtab-taxbash4 ) * -1.
        ls_outtab-taxbash5 = ABS( ls_outtab-taxbash5 ) * -1.
        ls_outtab-taxbash6 = ABS( ls_outtab-taxbash6 ) * -1.
        ls_outtab-sum_all  = ABS( ls_outtab-sum_all )  * -1.
* ziclos junio 2011  correcion notas de crédito electrónica
        wa_lce-viva_propor = wa_lce-viva_propor   * - 1.
* ziclos fin de correcion
      ENDIF.

      MOVE-CORRESPONDING ls_bkpf TO ls_outtab.
      COLLECT ls_outtab INTO   gt_outtab.
*ziclos abril 2011 . perform para guardar datos en

      MOVE ls_bkpf-belnr     TO wa_lce-num_doc.
      MOVE ls_bkpf-xreversal TO wa_lce-cod_anul.
*      move bkpf-anln1 to wa_lce-ES_ACT_FIJO.
      MOVE ls_bkpf-monat   TO wa_lce-monat.
      MOVE ls_bkpf-bktxt TO  wa_lce-glosa.
      MOVE ls_bkpf-bldat TO  wa_lce-femis.
*
* V1 RVY INI
      MOVE ls_BKPF-XREF2_HD TO wa_lce-XREF2_HD.
* V1 RVY FIN
*     move:

*          ls_outtab-taxbash1  to wa_lce-afecto, " AFECTO
*          ls_outtab-taxbash2  to wa_lce-exento, " EXCENTO
*          ls_outtab-taxbash3  to wa_lce-viva, " IVA
*          ls_outtab-taxbash4  to wa_lce-viva_nr, " IVA NO RECUPERADO
*          ls_outtab-taxbash5  to wa_lce-VIVA_PROPOR , " OTROS IMPUESTOS
*          ls_outtab-sum_all   to wa_lce-VTOTAL. " VALOR TOTAL
      PERFORM move_campos_lce USING ls_outtab.
    ENDIF.


    CLEAR:ls_outtab-taxbash1,
          ls_outtab-taxbash2,
          ls_outtab-taxbash3,
          ls_outtab-taxbash4,
          ls_outtab-taxbash5,
          ls_outtab-taxbash6,
          ls_outtab-sum_all .
  ENDLOOP.
  SORT gt_outtab BY blart bldat xblnr.
  SORT t_23 BY ndoc.
* ziclos abril 2011
*  SORT ta_lce BY blart bldat xblnr.
ENDFORM.                    " get_documents
*&---------------------------------------------------------------------*
*&      Form  fill_blart
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_blart .
  DATA:lr_balrt TYPE rng_blart.

*  IF P_BRTE_1 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTE_1  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.

  REFRESH gr_blart.
  gr_blart[] = p_brte_1[].
  APPEND LINES OF p_brtn_1 TO gr_blart.

*  IF P_BRTE_2 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTE_2  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTE_3 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTE_3  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTE_4 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTE_4  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTE_5 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTE_5  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTE_6 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTE_6  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTE_7 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTE_7  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.


*  IF P_BRTN_1 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_1  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.

*  IF P_BRTN_2 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_2  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTN_3 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_3  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTN_4 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_4  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTN_5 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_5  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTN_0 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_0  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTN_6 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_6  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTN_7 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_7  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTN_8 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_8  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
*  IF P_BRTN_9 IS NOT INITIAL.
*    MOVE 'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE P_BRTN_9  TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*  ENDIF.
*
**  Modificacion Herman Rosales
**  Inicio
*    MOVE  'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE 'F8' TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*
*    MOVE  'I' TO LR_BALRT-SIGN.
*    MOVE 'EQ' TO LR_BALRT-OPTION.
*    MOVE 'F9' TO LR_BALRT-LOW.
*    APPEND LR_BALRT TO GR_BLART.
*    CLEAR LR_BALRT.
*    Fin
ENDFORM.                    " fill_blart
*&---------------------------------------------------------------------*
*&      Form  INIT_BLART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_blart .

*  MOVE 'F3' TO  P_BRTE_1.
*  MOVE 'F4' TO  P_BRTE_2.
*  MOVE 'F6' TO  P_BRTE_3.
*  MOVE 'N3' TO  P_BRTE_4.
*  MOVE 'N4' TO  P_BRTE_5.
*  MOVE 'D3' TO  P_BRTE_6.
*  MOVE 'D4' TO  P_BRTE_7.
*  MOVE 'F1' TO  P_BRTN_1.
*  MOVE 'F2' TO  P_BRTN_2.
*  MOVE 'F5' TO  P_BRTN_3.
*  MOVE 'I1' TO  P_BRTN_4.
*  MOVE 'I2' TO  P_BRTN_5.
*  MOVE 'N1' TO  P_BRTN_6.
*  MOVE 'N2' TO  P_BRTN_7.
*  MOVE 'D1' TO  P_BRTN_8.
*  MOVE 'D2' TO  P_BRTN_9 .
*  MOVE 'I3' TO  P_BRTN_0 .

*  MOVE 'D1' TO  p_brtn_8.
*  MOVE 'D2' TO  p_brtn_9 .
*  MOVE 'D3' TO  p_brte_6.
*  MOVE 'D4' TO  p_brte_7.
*  MOVE 'F1' TO  p_brtn_1.
*  MOVE 'F2' TO  p_brtn_2.
*  MOVE 'F3' TO  p_brte_1.
*  MOVE 'F4' TO  p_brte_2.
*  MOVE 'F5' TO  p_brtn_3.
*  MOVE 'F6' TO  p_brte_3.
*
*
*  MOVE 'I1' TO  p_brtn_4.
*  MOVE 'I2' TO  p_brtn_5.
*  MOVE 'I3' TO  p_brtn_0 .
*  MOVE 'N1' TO  p_brtn_6.
*  MOVE 'N2' TO  p_brtn_7.
*  MOVE 'N3' TO  p_brte_4.
*  MOVE 'N4' TO  p_brte_5.

ENDFORM.                    " INIT_BLART
*&---------------------------------------------------------------------*
*&      Form  fieldcat_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM fieldcat_init USING lt_fieldcat TYPE slis_t_fieldcat_alv
                          lt_fieldcat_100 TYPE lvc_t_fcat.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv,
        ls_fieldcat_100 TYPE lvc_s_fcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'BUKRS'.
  ls_fieldcat-seltext_m = 'Sociedad'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
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
  ls_fieldcat-fieldname = 'BUDAT'.
  ls_fieldcat-seltext_m = 'Fec. de Doc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
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
  ls_fieldcat-fieldname = 'BLART'.
  ls_fieldcat-seltext_m = 'Cl Doc.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'STCD1'.
  ls_fieldcat-seltext_m = 'R.U.T'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NAME1'.
  ls_fieldcat-seltext_m = 'Nombre'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 30.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MWSKZ'.
  ls_fieldcat-seltext_m = 'Ind. Impto.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 10.
  APPEND ls_fieldcat TO lt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH1'.
  ls_fieldcat-seltext_m = 'Afecto'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH2'.
  ls_fieldcat-seltext_m = 'Exento'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH3'.
  ls_fieldcat-seltext_m = 'IVA'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH4'.
  ls_fieldcat-seltext_m = 'IVA No Recuperado'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH5'.
  ls_fieldcat-seltext_m = 'Otros Imptos.'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'TAXBASH6'.
  ls_fieldcat-seltext_m = 'Iva Retenido'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SUM_ALL'.
  ls_fieldcat-seltext_m = 'Valor Total'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-do_sum    = 'X'.
  ls_fieldcat-cfieldname = 'WAERS'.
  ls_fieldcat-outputlen = 13.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERS'.
  ls_fieldcat-seltext_m = 'Moneda'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 6.
  APPEND ls_fieldcat TO lt_fieldcat.
*
* V1 RVY INI
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'XREF2_HD'.
  ls_fieldcat-seltext_m = 'Clav.Ref.2'.
  ls_fieldcat-seltext_s = ls_fieldcat-seltext_m.
  ls_fieldcat-seltext_l = ls_fieldcat-seltext_m.
  ls_fieldcat-outputlen = 12.
  APPEND ls_fieldcat TO lt_fieldcat.
* V1 RVY FIN

ENDFORM.                    "fieldcat_init
*&---------------------------------------------------------------------*
*&      Form  show_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_alv.

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
*      i_html_height_end           = 10
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

  DATA: l_title      TYPE sdydo_text_element,
          l_text       TYPE sdydo_text_element,
          l_font       TYPE sdydo_attribute VALUE '1',
          ls_zfigiro   TYPE zfigiro,
          l_month      TYPE fcltx.


  CONCATENATE g_address_value-name1 ''
    INTO l_text SEPARATED BY space.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  l_text = 'Giro'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  LOOP AT gt_zfigiro INTO   ls_zfigiro.
    IF NOT ls_zfigiro-giro_1 IS INITIAL.

      MOVE  ls_zfigiro-giro_1 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->add_gap
        EXPORTING
          width = 10.
      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT  ls_zfigiro-giro_2 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_2 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_3 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_3 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_4 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_4 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_5 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_5 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

    IF NOT ls_zfigiro-giro_6 IS INITIAL.
      ADD 1 TO g_html_height_top .
      MOVE  ls_zfigiro-giro_6 TO l_text.
*      TRANSLATE l_text TO LOWER CASE.
      CALL METHOD document->new_line.
      CALL METHOD document->add_gap
        EXPORTING
          width = 19.

      CALL METHOD document->add_text
        EXPORTING
          text         = l_text
          sap_fontsize = l_font.
    ENDIF.

  ENDLOOP.
***        RUT
  l_text = 'Rut'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.

  MOVE g_paval TO l_text.
  CALL METHOD document->add_gap
    EXPORTING
      width = 11.

  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

***      Direccion
  l_text = 'Dirección'.
  CALL METHOD document->new_line.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
  CONCATENATE g_address_value-street g_address_value-city1
    INTO l_text SEPARATED BY space.
  CALL METHOD document->add_gap
    EXPORTING
      width = 0.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_fontsize = l_font.

  CALL METHOD document->new_line.
  l_title = 'Libro Legal de Compras'.
  CALL METHOD document->add_gap
    EXPORTING
      width = 155.
  CALL METHOD document->add_text
    EXPORTING
      text          = l_title
      sap_style     = 'HEADING'
*      sap_fontsize  = l_font.
      sap_fontstyle = 'C'
      sap_emphasis  = 'C'.
  CALL METHOD document->new_line.
  PERFORM get_month
              USING
                 s_monat-low
              CHANGING
                 l_month.
  CONCATENATE l_month p_gjahr
    INTO l_text SEPARATED BY space.

  CALL METHOD document->add_gap
    EXPORTING
      width = 180.
  CALL METHOD document->add_text
    EXPORTING
      text         = l_text
      sap_emphasis = 'Strong'.
ENDFORM.                    "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  get_month
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MONAT    text
*      -->P_MONTH    text
*----------------------------------------------------------------------*
FORM get_month USING p_monat TYPE monat
               CHANGING p_month     TYPE fcltx.

  DATA: lt_month_names TYPE TABLE OF t247,
        ls_month_names TYPE  t247,
        l_subrc        TYPE sy-subrc.
  CALL FUNCTION 'MONTH_NAMES_GET'
    EXPORTING
      language              = sy-langu
    IMPORTING
      return_code           = l_subrc
    TABLES
      month_names           = lt_month_names
    EXCEPTIONS
      month_names_not_found = 1
      OTHERS                = 2.
  IF l_subrc EQ 0.
    READ TABLE lt_month_names
     INTO ls_month_names
     WITH KEY mnr = p_monat.
    IF sy-subrc EQ 0.
      MOVE ls_month_names-ltx TO p_month .
    ENDIF.
  ENDIF.

ENDFORM.                   "html_top_of_page
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

  SELECT SINGLE name1 stcd1
    FROM lfa1
    INTO (ps_outtab-name1, ps_outtab-stcd1)
    WHERE lifnr EQ ps_bseg-lifnr.

ENDFORM.                    " get_info_lfa1

*&---------------------------------------------------------------------*
*&      Form  determine_tax
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PS_BSET    text
*      -->PS_OUTTAB  text
*----------------------------------------------------------------------*
FORM determine_tax USING ps_bset TYPE bset
                         ps_bkpf TYPE bkpf
                    CHANGING ps_outtab TYPE ty_s_outtab.
  DATA ls_cl_doc TYPE ty_s_cl_doc.
  DATA l_iscombinada TYPE i. " 0  = NO    1 =  SI.
  DATA l_bset TYPE    bset OCCURS 0 WITH HEADER LINE.
  DATA tm_bseg TYPE bseg.
  DATA tm_bseg2 TYPE STANDARD TABLE OF bseg WITH HEADER LINE.
  DATA tm_dmbtr LIKE bseg-dmbtr.
  DATA sum_hwste TYPE hwste.
  DATA conteo TYPE i.
* ziclos abril 2011
  DATA tm_bseg3 TYPE bseg.

* ziclos fin
  CLEAR l_iscombinada.

*  se realiza ejercicio para identificar si el indicador de impuesto C0
*  es combinado o no.
* ziclos abril 2011
  MOVE ps_bset-mwskz TO wa_lce-tip_impto.    " tipo de impuesto

* ziclos fin
  IF ps_bset-mwskz EQ 'C0'.
    SELECT *
      FROM bset
      INTO TABLE l_bset
     WHERE bukrs EQ ps_bset-bukrs
       AND belnr EQ ps_bset-belnr
       AND gjahr EQ ps_bset-gjahr
       AND mwskz NE 'C0'.

    IF sy-subrc EQ 0.
      LOOP AT l_bset.
        l_iscombinada = 1.
        gv_combinada = l_iscombinada. " Agregado por L_FOUBERT 23.07.2013
      ENDLOOP.
    ELSE.
      l_iscombinada = 0.
      gv_combinada = l_iscombinada.   " Agregado por L_FOUBERT 23.07.2013
    ENDIF.
  ENDIF.


* Ind. Impto.
  MOVE ps_bset-mwskz TO  ps_outtab-mwskz.
  CASE ps_bset-mwskz.
    WHEN 'C0'  .
      tm_dmbtr = ps_bset-hwbas.

      SELECT * FROM bkpf
          WHERE bukrs = ps_bset-bukrs
                AND belnr = ps_bset-belnr
                AND gjahr = ps_bset-gjahr.
        IF bkpf-blart NS 'N' AND ps_bset-shkzg = 'H' .
          tm_dmbtr = tm_dmbtr - tm_dmbtr.
        ELSEIF bkpf-blart CS 'N' AND ps_bset-shkzg <> 'H' .
          tm_dmbtr = tm_dmbtr - tm_dmbtr.
        ELSE.
          SELECT * FROM bseg
          WHERE bukrs = ps_bset-bukrs
                AND belnr = ps_bset-belnr
                AND gjahr = ps_bset-gjahr
                AND shkzg <> ps_bset-shkzg
                AND mwskz = ps_bset-mwskz
                AND txgrp = ps_bset-txgrp.
            tm_dmbtr = tm_dmbtr + bseg-dmbtr.
          ENDSELECT.
        ENDIF.
      ENDSELECT.

      ps_bset-hwbas = tm_dmbtr.

      MOVE ps_bset-hwbas TO ps_outtab-taxbash2. "EXENTO
      IF l_iscombinada = 0.
        ls_cl_doc-descripcion = text-023.
        ls_cl_doc-monto       = ps_bset-hwbas.
        ls_cl_doc-moneda      = ps_bkpf-waers.
        ls_cl_doc-cantidad    = 1.
        ls_cl_doc-orden       = 3.
* ziclos ABril 2011 incluimos las cuenta de iva .
*      read table gt_bseg into  tm_bseg3 with key bukrs = ps_bset-bukrs
*                                                 belnr = ps_bset-belnr
*                                                buzei = ps_bset-buzei.

*        move tm_bseg3-hkont to wa_lce-CTA_IVA .
*        move ps_bset-hkont to wa_lce-CTA_IVA . " cuando es C0 no debe llevar cuenta

*ziclos  fin abril 2011
      ELSE. " ES COMBINADO

        PERFORM determine_tax2 USING l_bset
                                     ps_bset-hwbas
                                     ps_bkpf
                            CHANGING
                                     ps_outtab.


      ENDIF.
      COLLECT ls_cl_doc INTO gt_cl_doc.
    WHEN 'C1' OR 'C5'  OR 'C9' or 'Z2'.
*ziclos Abril 2011
      IF ps_bset-mwskz = 'C1'. " Iva no recuperado
*        move tm_bseg3-hkont to wa_lce-CTA_IVA_NR.
        MOVE ps_bset-hkont TO wa_lce-cta_iva.
      ENDIF.
      IF ps_bset-mwskz = 'C5' OR ps_bset-mwskz = 'C9' . " Iva proporcional
*        move tm_bseg3-hkont to wa_lce-CTA_IVA_PROPOR.
* ziclos mayo 2011 cambio importante , si es C9 o C5 no se incluye en el Valor Iva ni en la cra IVa sino en la proporcional
* pot lo tanto ya no hay que buscarlo en  en la tabla bseg.
*        move ps_bset-hkont to wa_lce-CTA_IVA.
*     select * from bseg
*          where BUKRS = ps_bset-BUKRS
*                and BELNR = ps_bset-belnr
*                and GJAHR = ps_bset-gjahr.
*       if bseg-hkont = '1013310005'.  "IVA PROPORCIONAL
*           move bseg-hkont to wa_lce-CTA_IVA_PROPOR.
*           move bseg-dmbtr to wa_lce-VIVA_PROPOR.
*
*           exit.
*       endif.
*          ENDSELECT.

* tenemos que guardar la información para los casos de que haya dos impuestos ( C1 y C5 )
        MOVE ps_bset-hkont TO wa_lce-cta_iva_propor.
        MOVE ps_bset-hwste TO wa_lce-viva_propor.
      ENDIF.

*ziclos fin
*      Modificacion Herman Libro C9
*      INIcio
      IF ps_bset-shkzg EQ 'S' AND ps_bkpf-blart CS 'F'.
        ps_outtab-taxbash1 = ps_bset-hwbas + ps_outtab-taxbash1. "AFECCTO
        ps_outtab-taxbash3 = ps_bset-hwste + ps_outtab-taxbash3. "IVA
*        MOVE ps_bset-hwbas TO ps_outtab-taxbash1. "AFECCTO
*        MOVE ps_bset-hwste TO ps_outtab-taxbash3. "IVA
      ELSEIF ps_bset-shkzg EQ 'S' AND ps_bkpf-blart CS 'D'.
        ps_outtab-taxbash1 = ps_bset-hwbas + ps_outtab-taxbash1. "AFECCTO
        ps_outtab-taxbash3 = ps_bset-hwste + ps_outtab-taxbash3. "IVA
*        MOVE ps_bset-hwbas TO ps_outtab-taxbash1. "AFECCTO
*        MOVE ps_bset-hwste TO ps_outtab-taxbash3. "IVA
      ELSEIF ps_bset-shkzg EQ 'H' AND ps_bkpf-blart CS 'N'.
        ps_outtab-taxbash1 = ps_bset-hwbas + ps_outtab-taxbash1. "AFECCTO
        ps_outtab-taxbash3 = ps_bset-hwste + ps_outtab-taxbash3. "IVA
*        MOVE ps_bset-hwbas TO ps_outtab-taxbash1. "AFECCTO
*        MOVE ps_bset-hwste TO ps_outtab-taxbash3. "IVA
      ELSEIF ps_bset-shkzg EQ 'S' AND ps_bkpf-blart CS 'I'.
*     Modificado por L_FOUBERT 23.07.2013  Mejora de valores columna Afecto Clase I2 Ind. Imp. C9
        IF ( ps_bkpf-blart EQ 'I1' OR ps_bkpf-blart EQ 'I2' )  AND  ( ps_bset-mwskz EQ 'C9' AND gv_combinada EQ 1 ).
          DATA:  lv_total1 TYPE hwste,
                 lv_total2 TYPE hwste.
          CLEAR: lv_total1, lv_total2.
          " Claculo el +
          LOOP AT gt_bseg INTO ls_bseg2 WHERE mwskz EQ 'C9' AND
                                              shkzg EQ 'S'  AND
                                              buzid NE 'T'.
            ADD ls_bseg2-dmbtr TO lv_total1.  " total Afecto
            CLEAR: ls_bseg2.
          ENDLOOP.
          " Claculo -
          LOOP AT gt_bseg INTO ls_bseg2 WHERE mwskz EQ space  AND
                                              shkzg EQ 'H'.
            ADD ls_bseg2-dmbtr TO lv_total2.  " total Afecto
            CLEAR: ls_bseg2.
          ENDLOOP.
          ps_outtab-taxbash1 = lv_total1 - lv_total2.              "AFECCTO
          ps_outtab-taxbash3 = ps_bset-hwste + ps_outtab-taxbash3. "IVA
        ELSE.
*     END L_FOUBERT 23.07.2013  Mejora de valores columna Afecto Clase I2 Ind. Imp. C9
          ps_outtab-taxbash1 = ps_bset-hwbas + ps_outtab-taxbash1. "AFECCTO
          ps_outtab-taxbash3 = ps_bset-hwste + ps_outtab-taxbash3. "IVA
        ENDIF.
      ENDIF.
*     FIN
      CASE ps_bkpf-blart.
        WHEN 'F3' OR 'F4' OR 'N3' OR 'N4' OR 'D3' OR 'D4'.
          IF ps_bkpf-blart EQ 'N3' OR ps_bkpf-blart EQ 'N4'.
            gs_iva_doc_e-monto_cdc = gs_iva_doc_e-monto_cdc - ps_bset-hwste.
          ELSE.
            gs_iva_doc_e-monto_cdc = gs_iva_doc_e-monto_cdc + ps_bset-hwste.
          ENDIF.
      ENDCASE.
*     Modificacion Herman Rosales
*     INICIO Requerimiento factura F8
      CASE ps_bkpf-blart.
        WHEN 'F8'.
          IF ps_bkpf-bukrs EQ 'CL17'.
            ps_outtab-taxbash4 = ps_outtab-taxbash3.
            CLEAR ps_outtab-taxbash3.
          ENDIF.
      ENDCASE.
*     FIN Modificacion Requerimiento factura F8
      CASE ps_bkpf-blart.
*        WHEN 'F3' OR 'F4' OR 'N3' OR 'N4' OR 'D3' OR 'D4'.
*          GS_IVA_DOC_E-MONTO_CDC = GS_IVA_DOC_E-MONTO_CDC + PS_BSET-HWSTE.

*       notade credito y debito

        WHEN 'F6' OR 'F5'.
          ls_cl_doc-descripcion = text-021.
          ls_cl_doc-monto       = ps_bset-hwbas.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 1.
          COLLECT ls_cl_doc INTO gt_cl_doc.
        WHEN 'F1' OR 'F3'.

          WRITE ps_bset-hwste TO t_23-tot CURRENCY 'CLP'.
*          MOVE  (PS_BSET-HWSTE * 10) TO T_23-TOT.
          MOVE  ps_bset-belnr TO t_23-ndoc.
          APPEND t_23.
          ls_cl_doc-descripcion = text-024.
          ls_cl_doc-monto       = ps_bset-hwste.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 4.
          COLLECT ls_cl_doc INTO gt_cl_doc.

        WHEN 'F2' OR 'F4'.
          ls_cl_doc-descripcion = text-025.
          ls_cl_doc-monto       = ps_bset-hwste.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 5.
          COLLECT ls_cl_doc INTO gt_cl_doc.

        WHEN 'N1' OR 'N2' OR 'N3' OR 'N4'.
          ls_cl_doc-descripcion = text-026.
          ls_cl_doc-monto       = ps_bset-hwste.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 6.
          COLLECT ls_cl_doc INTO gt_cl_doc.

        WHEN 'D1' OR 'D2' OR 'D3' OR 'D4'.
          ls_cl_doc-descripcion = text-027.
          ls_cl_doc-monto       = ps_bset-hwste.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 7.
          COLLECT ls_cl_doc INTO gt_cl_doc.

        WHEN 'I1'.
          ls_cl_doc-descripcion = text-028.
          ls_cl_doc-monto       = ps_bset-hwste.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 8.
          COLLECT ls_cl_doc INTO gt_cl_doc.

        WHEN 'I2'.
          ls_cl_doc-descripcion = text-029.
          ls_cl_doc-monto       = ps_bset-hwste.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 9.
          COLLECT ls_cl_doc INTO gt_cl_doc.
      ENDCASE.


    WHEN 'C4' OR 'C6' OR 'C8'.
      MOVE ps_bset-hwste TO ps_outtab-taxbash4. "IVA no retenido
      MOVE ps_bset-hwbas TO ps_outtab-taxbash1. "AFECCTO
* ziclos ABril 2011 incluimos las cuenta de iva .
*      read table gt_bseg into  tm_bseg3 with key bukrs = ps_bset-bukrs
*                                                belnr = ps_bset-belnr
*                                                buzei = ps_bset-buzei.
      IF ps_bset-mwskz = 'C4' OR ps_bset-mwskz = 'C8'. " Iva no recuperado
*        move tm_bseg3-hkont to wa_lce-CTA_IVA_NR.
        MOVE ps_bset-hkont TO wa_lce-cta_iva_nr .
      ENDIF.
      IF ps_bset-mwskz = 'C6'. " Iva proporcional
*        move tm_bseg3-hkont to wa_lce-CTA_IVA_PROPOR.
        MOVE ps_bset-hkont TO wa_lce-cta_iva_propor.
      ENDIF.
      CASE ps_bkpf-blart.
        WHEN 'F6'.
          gs_iva_doc_e-monto_sdc = gs_iva_doc_e-monto_sdc + ps_bset-hwste.
      ENDCASE.

      CASE ps_bkpf-blart.

*        WHEN 'F6'.
*          GS_IVA_DOC_E-MONTO_SDC = GS_IVA_DOC_E-MONTO_SDC + PS_BSET-HWSTE.

        WHEN  'F1' OR 'F3' OR 'F6' OR 'F5'.
*          GS_IVA_DOC_E-MONTO_SDC = GS_IVA_DOC_E-MONTO_SDC + PS_BSET-HWSTE.

*          Modificacion libro compras
*F5
          CLEAR tm_bseg2-wrbtr.
          SELECT * INTO TABLE tm_bseg2 FROM bseg
            WHERE bukrs = ps_bset-bukrs
                  AND belnr = ps_bset-belnr
                  AND gjahr = ps_bset-gjahr
                  AND shkzg = ps_bset-shkzg
                  AND mwskz = ps_bset-mwskz
                  AND txgrp = ps_bset-txgrp.

          SORT tm_bseg2 BY wrbtr ASCENDING.
          LOOP AT tm_bseg2.
            IF sy-tabix = 1.
              MOVE tm_bseg2-wrbtr TO ps_outtab-taxbash4.
              sum_hwste = sum_hwste + tm_bseg2-wrbtr.
            ELSEIF sy-tabix = 2.
              MOVE tm_bseg2-wrbtr TO ps_outtab-taxbash1.
              sum_hwste = sum_hwste + tm_bseg2-wrbtr.
            ENDIF.
          ENDLOOP.
*         MOVE ps_bset-hwste TO ps_outtab-taxbash4. "IVA no retenido
*         MOVE ps_bset-hwbas TO ps_outtab-taxbash1. "AFECCTO
          DESCRIBE TABLE tm_bseg2 LINES conteo.
          IF ps_bset-hwbas NE sum_hwste OR conteo < 2.
            MOVE ps_bset-hwste TO ps_outtab-taxbash4. "IVA no retenido
            MOVE ps_bset-hwbas TO ps_outtab-taxbash1. "AFECCTO
          ENDIF.

*            fin modificacion
          ls_cl_doc-descripcion = text-021.
          ls_cl_doc-monto       = ps_bset-hwbas.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 1.
          COLLECT ls_cl_doc INTO gt_cl_doc.

        WHEN 'I3'.
          ls_cl_doc-descripcion = text-022.
          ls_cl_doc-monto       = ps_bset-hwbas.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 2.
          COLLECT ls_cl_doc INTO gt_cl_doc.
      ENDCASE.
    WHEN 'C7'.
*ziclos abril 2011
      MOVE ps_bset-hkont TO wa_lce-cta_iva.
*ziclos fin abril 2011
      MOVE ps_bset-hwbas TO ps_outtab-taxbash5. "OTROS IMPTOS.
      CASE ps_bkpf-blart.
        WHEN 'F1' OR 'F3' OR 'I1' OR 'N1' OR 'N3' OR 'D1' OR 'D3'.
          ls_cl_doc-descripcion = text-030.
          ls_cl_doc-monto       = ps_bset-hwbas.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 10.
          COLLECT ls_cl_doc INTO gt_cl_doc.
      ENDCASE.
  ENDCASE.

  CLEAR ps_outtab-taxbash6.

  SELECT SINGLE wt_qbshh INTO ps_outtab-taxbash6
    FROM with_item
      WHERE bukrs = ps_bkpf-bukrs
        AND belnr = ps_bkpf-belnr
        AND gjahr = ps_bkpf-gjahr
        AND witht = 'Q4'
        AND wt_withcd = 'B4'.

*  ps_outtab-taxbash6 = ABS( ps_outtab-taxbash6 ).


*  PATCH Herman Rosales
  ps_outtab-taxbash1 = ABS( ps_outtab-taxbash1 ).
  ps_outtab-taxbash2 = ABS( ps_outtab-taxbash2 ).
  ps_outtab-taxbash3 = ABS( ps_outtab-taxbash3 ).
  ps_outtab-taxbash4 = ABS( ps_outtab-taxbash4 ).
  ps_outtab-taxbash5 = ABS( ps_outtab-taxbash5 ).
*  ps_outtab-taxbash6 = ABS( ps_outtab-taxbash6 ).

*  end PATCH
  ps_outtab-sum_all =   ps_outtab-taxbash1 + ps_outtab-taxbash2 +
                        ps_outtab-taxbash3 + ps_outtab-taxbash4 +
                        ps_outtab-taxbash5 + ps_outtab-taxbash6 .
ENDFORM.                    " DETERMINE_TAX

*&---------------------------------------------------------------------*
*&      Form  layout_init
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RS_LAYOUT  text
*----------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.

*  rs_layout-detail_popup      = 'X'.
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
  DATA: v_error.
  CLEAR v_error.
  CASE r_ucomm.
    WHEN '&F05'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'LINE'.
      CALL SCREEN 0100
        STARTING AT 20 1.
    WHEN 'DOWN'.

      PERFORM fill_file
                  USING
                     gt_outtab
                  CHANGING
                     gt_download.
      PERFORM fill_total
                  USING
                     gt_cl_doc
                  CHANGING
                     gt_download.


      PERFORM download_txt
                  USING
                     gt_download.

*
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
* ziclos abril 2011  tratamiento del Libro de compras electrónico
    WHEN  'DLCE' .
* tenemos que chequear si tiene proveedor de LCE y si es por procedimiento o por archivo en el pc del usuario
      SELECT SINGLE * FROM zprov_lce_buk WHERE bukrs = p_bukrs.
      IF sy-subrc EQ 0.
        SELECT SINGLE * FROM zprov_lce WHERE codprov = zprov_lce_buk-codprov.
        IF sy-subrc EQ 0.

          IF zprov_lce-modo = 'P'.
* acá van los procedimiento para los distintos proveedore.


            CASE zprov_lce-codprov.
              WHEN '0001'   .  "DBNET
                PERFORM openconnection.
                "Elimino registros por sociedad
*loop at s_bukrs.
                TRY.
                    EXEC SQL.
                      execute procedure PKG_SAP_LIBRO_ELECTRONICO.GEN_ELIMINA_DOCUMENTOS(
                                        IN :p_bukrs,
                                        IN :s_MONAT-low,
                                        IN :p_gjahr)
                    ENDEXEC.
                  CATCH cx_sy_native_sql_error.
                    MESSAGE `Error borrar tabla sap_anadoc` TYPE 'I'.
                    v_error = 'X'.
                ENDTRY.
*endloop.
*
                EXEC SQL.
                  commit
                ENDEXEC.
* grabo los datos
                IF v_error IS INITIAL.
                  LOOP AT ta_lce INTO wa_lce.

                    TRY.
                        EXEC SQL.
                          execute procedure PKG_SAP_LIBRO_ELECTRONICO.SAP_CARGA_DOCUMENTOS_VENTA_V2(
                                            in :wa_lce-bukrs,
                                            in :wa_lce-CORR_DOC,
                                            in :wa_lce-RUT_PROV,
                                            in :wa_lce-FEMIS,
                                            in :wa_lce-GLOSA,
                                            in :wa_lce-AFECTO,
                                            in :wa_lce-EXENTO,
                                            in :wa_lce-VIVA,
                                            in :wa_lce-VTOTAL,
                                            in :wa_lce-NUM_DOC,
                                            in :wa_lce-TIP_FAC_SAP,
                                            in :wa_lce-TIP_FAC_SII,
                                            in :wa_lce-ES_ACT_FIJO,
                                            in :wa_lce-TIP_IMPTO,
                                            in :wa_lce-VIVA_NR,
                                            in :wa_lce-MONAT,
                                            in :wa_lce-GJAHR,
                                            in :wa_lce-COD_ANUL,
                                            in :wa_lce-NOMBRE_PROV,
                                            in :wa_lce-VIVA_PROPOR,
                                            in :wa_lce-CTA_IVA_PROPOR,
                                            in :wa_lce-CTA_IVA_NR,
                                            in :wa_lce-CTA_IVA,
                                            in :wa_lce-PORC_IVA_NR)

                        ENDEXEC.
                      CATCH cx_sy_native_sql_error.
                        MESSAGE `Error insert tabla SAP_DOCUMENTO` TYPE 'I'.
                        v_error = 'X'.
                    ENDTRY.
                    IF v_error = 'X'.  " al menos hay un error
                      EXIT.
                    ENDIF.


                  ENDLOOP.
                ENDIF.
                IF v_error IS INITIAL.
                  TRY.
                      EXEC SQL.
                        EXECUTE PROCEDURE PKG_SAP_LIBRO_ELECTRONICO.GEN_LIB_COMPRA_ELE_DBNET(
                                        IN :p_bukrs  ,
                                        IN :p_GJAHR  ,
                                        IN :s_MONAT-low,
                                        IN :ZPROV_LCE_BUK-stcd1)
                      ENDEXEC.
                    CATCH cx_sy_native_sql_error.
                      MESSAGE `Error Proced. GEN_LIB_COMPRA_ELE_DBNET` TYPE 'I'.
                      v_error = 'X'.
                  ENDTRY.
                ELSE.
                  MESSAGE 'Error al intentar insertar en tabla SAP_DOCUMENTO.'  TYPE 'I'.
                ENDIF.
                PERFORM closeconnection.
                IF v_error IS INITIAL.
                  MESSAGE 'El Libro de Compras fué grabado exitosamente  .'  TYPE 'I'.

                ENDIF.
*    exec sql.
*        set connection default
*    endexec.
*
*    exec sql.
*        set connection 'con'
*    endexec.
              WHEN '0002'   .  "TISAL
                PERFORM openconnection.
                "Elimino registros por sociedad
*loop at s_bukrs.
                TRY.
                    EXEC SQL.
                      execute procedure PKG_SAP_LIBRO_ELECTRONICO.GEN_ELIMINA_DOCUMENTOS(
                                        IN :p_bukrs,
                                        IN :s_MONAT-low,
                                        IN :p_gjahr)
                    ENDEXEC.
                  CATCH cx_sy_native_sql_error.
                    MESSAGE `Error borrar tabla sap_anadoc` TYPE 'I'.
                    v_error = 'X'.
                ENDTRY.
*endloop.
*
                EXEC SQL.
                  commit
                ENDEXEC.
* grabo los datos
                IF v_error IS INITIAL.
                  LOOP AT ta_lce INTO wa_lce.

                    TRY.
                        EXEC SQL.
                          execute procedure PKG_SAP_LIBRO_ELECTRONICO.SAP_CARGA_DOCUMENTOS_VENTA_V2(
                                            in :wa_lce-bukrs,
                                            in :wa_lce-CORR_DOC,
                                            in :wa_lce-RUT_PROV,
                                            in :wa_lce-FEMIS,
                                            in :wa_lce-GLOSA,
                                            in :wa_lce-AFECTO,
                                            in :wa_lce-EXENTO,
                                            in :wa_lce-VIVA,
                                            in :wa_lce-VTOTAL,
                                            in :wa_lce-NUM_DOC,
                                            in :wa_lce-TIP_FAC_SAP,
                                            in :wa_lce-TIP_FAC_SII,
                                            in :wa_lce-ES_ACT_FIJO,
                                            in :wa_lce-TIP_IMPTO,
                                            in :wa_lce-VIVA_NR,
                                            in :wa_lce-MONAT,
                                            in :wa_lce-GJAHR,
                                            in :wa_lce-COD_ANUL,
                                            in :wa_lce-NOMBRE_PROV,
                                            in :wa_lce-VIVA_PROPOR,
                                            in :wa_lce-CTA_IVA_PROPOR,
                                            in :wa_lce-CTA_IVA_NR,
                                            in :wa_lce-CTA_IVA,
                                            in :wa_lce-PORC_IVA_NR)

                        ENDEXEC.
                      CATCH cx_sy_native_sql_error.
                        MESSAGE `Error insert tabla SAP_DOCUMENTO` TYPE 'I'.
                        v_error = 'X'.
                    ENDTRY.
                    IF v_error = 'X'.  " al menos hay un error
                      EXIT.
                    ENDIF.

                  ENDLOOP.
                ENDIF.
                IF v_error IS INITIAL.
                  TRY.
                      EXEC SQL.
                        EXECUTE PROCEDURE PKG_SAP_LIBRO_ELECTRONICO.GEN_LIB_COMPRA_ELE_TISAL(
                                        IN :p_bukrs  ,
                                        IN :p_GJAHR  ,
                                        IN :s_MONAT-low,
                                        IN :ZPROV_LCE_BUK-stcd1)
                      ENDEXEC.
                    CATCH cx_sy_native_sql_error.
                      MESSAGE `Error Proced. GEN_LIB_COMPRA_ELE_TISAL` TYPE 'I'.
                      v_error = 'X'.
                  ENDTRY.
                  PERFORM closeconnection.
                ELSE.
                  MESSAGE 'Error al intentar insertar en tabla SAP_DOCUMENTO.'  TYPE 'I'.
                ENDIF.
                IF v_error IS INITIAL.
                  MESSAGE 'El Libro de Compras fué grabado exitosamente  .'  TYPE 'I'.

                ENDIF.
            ENDCASE.
          ENDIF.
          IF zprov_lce-modo = 'A'.
            v_title = 'Ingrese solo Ruta Archivo'.

            CALL SELECTION-SCREEN '0500' STARTING AT 10 10.
            IF sy-subrc EQ 0.
*proceso para cargar el archivo plano en el directorio del usuario
              PERFORM openconnection.
              "Elimino registros por sociedad
*loop at s_bukrs.
              TRY.
                  EXEC SQL.
                    execute procedure PKG_SAP_LIBRO_ELECTRONICO.GEN_ELIMINA_DOCUMENTOS(
                                      IN :p_bukrs,
                                      IN :s_MONAT-low,
                                      IN :p_gjahr)
                  ENDEXEC.
                CATCH cx_sy_native_sql_error.
                  MESSAGE `Error borrar tabla sap_anadoc` TYPE 'I'.
              ENDTRY.
*endloop.
*
              EXEC SQL.
                commit
              ENDEXEC.
* grabo los datos
              LOOP AT ta_lce INTO wa_lce.

                TRY.
                    EXEC SQL.
                      execute procedure PKG_SAP_LIBRO_ELECTRONICO.SAP_CARGA_DOCUMENTOS_VENTA_V2(
                                        in :wa_lce-bukrs,
                                        in :wa_lce-CORR_DOC,
                                        in :wa_lce-RUT_PROV,
                                        in :wa_lce-FEMIS,
                                        in :wa_lce-GLOSA,
                                        in :wa_lce-AFECTO,
                                        in :wa_lce-EXENTO,
                                        in :wa_lce-VIVA,
                                        in :wa_lce-VTOTAL,
                                        in :wa_lce-NUM_DOC,
                                        in :wa_lce-TIP_FAC_SAP,
                                        in :wa_lce-TIP_FAC_SII,
                                        in :wa_lce-ES_ACT_FIJO,
                                        in :wa_lce-TIP_IMPTO,
                                        in :wa_lce-VIVA_NR,
                                        in :wa_lce-MONAT,
                                        in :wa_lce-GJAHR,
                                        in :wa_lce-COD_ANUL,
                                        in :wa_lce-NOMBRE_PROV,
                                        in :wa_lce-VIVA_PROPOR,
                                        in :wa_lce-CTA_IVA_PROPOR,
                                        in :wa_lce-CTA_IVA_NR,
                                        in :wa_lce-CTA_IVA,
                                        in :wa_lce-PORC_IVA_NR)

                    ENDEXEC.
                  CATCH cx_sy_native_sql_error.
                    MESSAGE `Error insert tabla SAP_DOCUMENTO` TYPE 'I'.
                ENDTRY.


              ENDLOOP.
              EXEC SQL.
                EXECUTE PROCEDURE PKG_SAP_LIBRO_ELECTRONICO.generar_archivo_plano(
                                IN :p_bukrs,
                                IN :p_GJAHR,
                                IN :s_MONAT-low,
                                IN :ZPROV_LCE_BUK-stcd1)
              ENDEXEC.
              EXEC SQL.
                OPEN c1 FOR
                 select linea from SAP_LIBRO_ELECTRONICO
                  where  sociedad          = :p_bukrs
                           and ano         =   :P_GJAHR
                           and periodo     = :s_MONAT-low
                           order by secuencia asc

              ENDEXEC.

*CONTADOR = 0.
* Agrego limpiar la variable que genera el archivo plano

              CLEAR ta_i1.

              DO.
                EXEC SQL.
                  FETCH NEXT c1 INTO  :I2-LINEA

                ENDEXEC.
                IF sy-subrc <> 0.
                  EXIT.
                ELSE.
                  APPEND i2 TO ta_i1.
                ENDIF.
              ENDDO.
              EXEC SQL.
                CLOSE c1
              ENDEXEC.
              PERFORM closeconnection.
              PERFORM download_lce_txt
                      USING
                      ta_i1.      " ta_lce.
            ENDIF.
*                        PERFORM value_request_path_down CHANGING  p_plce.

          ENDIF.

        ENDIF.
      ELSE.  " la sociedad no está en la tabla de proveedores de LCE
        MESSAGE 'La sociedad no tiene asignado un Proveedor de LC Electr.'  TYPE 'I'.
      ENDIF.
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
*&      Form  download_txt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LT_DOWNLOAD  text
*----------------------------------------------------------------------*
FORM download_txt USING lt_download TYPE ty_t_download.

  DATA: l_path TYPE string.


  CONCATENATE p_path '/libro_compras_' p_bukrs
              '_' sy-datum '_'
              sy-uzeit '.TXT' INTO l_path.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*      WRITE_FIELD_SEPARATOR  = '  '
      filename                = l_path
      filetype                = 'ASC'
    TABLES
      data_tab                = lt_download
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
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc NE 0.
    MESSAGE 'Error al descargar  archivo.' TYPE 'S'.
  ELSE.
*    MOVE l_path TO p_path.
  ENDIF.


ENDFORM.                    "download_
*&---------------------------------------------------------------------*
*&      Form  download_lce_txt
*&---------------------------------------------------------------------*
*       Ziclos Bajar Libro de Compras Electrónico a Archivo de texto
*     en carpeta del usuario
*----------------------------------------------------------------------*
*      -->LT_DOWNLOAD  text
*----------------------------------------------------------------------*
FORM download_lce_txt USING lt_download TYPE ty_i1.  "ty_lce.

  DATA: l_path TYPE string.


  CONCATENATE p_plce '/lce_' p_bukrs
              '_' sy-datum '_'
              sy-uzeit '.TXT' INTO l_path.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
*      WRITE_FIELD_SEPARATOR  = '  '
      filename                = l_path
      filetype                = 'ASC'
    TABLES
      data_tab                = lt_download
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
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc NE 0.
    MESSAGE 'Error al descargar  archivo.' TYPE 'S'.
  ELSE.
*    MOVE l_path TO p_path.
  ENDIF.


ENDFORM.                    "download_
*&---------------------------------------------------------------------*
*&      Form  value_request_path_down
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PATH     text
*----------------------------------------------------------------------*
FORM value_request_path_down  CHANGING p_path.

  DATA: l_path TYPE string.

  MOVE p_path TO l_path.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    CHANGING
      selected_folder      = l_path
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  MOVE l_path TO p_path.

ENDFORM.                    "value_request_path_down
*&---------------------------------------------------------------------*
*&      Form  fill_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_header  CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download,
        l_date TYPE char20,
        l_month TYPE fcltx .
  PERFORM get_month
              USING
                 s_monat-low
              CHANGING
                 l_month.

  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+3(20) = g_butxt.
  ls_download-data+80(25) = 'Libro Legal de Compras'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  CONCATENATE l_month p_gjahr
    INTO ls_download-data+84(20) SEPARATED BY space.
  APPEND ls_download TO t_download .
  CLEAR ls_download.
  ls_download-data = space.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+2(10)   = 'Fec. Fac'.
  ls_download-data+14(10)  = 'Nro. Fac.'.
  ls_download-data+26(10)  = 'Fec. Doc.'.
  ls_download-data+38(10)  = 'Nro. Doc.'.
  ls_download-data+50(10)  = 'R.U.T'.
  ls_download-data+62(30)  = 'Nombre'.
  ls_download-data+98(10)  = 'Ind. Impto'.
  ls_download-data+115(11)  = 'Afecto'.
  ls_download-data+130(11) = 'Exento'.
  ls_download-data+148(9)  = 'IVA'.
  ls_download-data+154(11) = 'IVA No Rec.'.
  ls_download-data+169(11) = 'Otros Imptos'.
  ls_download-data+184(11) = 'Iva Retenido'.
  ls_download-data+199(11) = 'Valor Total'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data = c_line.
  APPEND ls_download TO t_download .CLEAR ls_download.
ENDFORM.                    "fill_header
*&---------------------------------------------------------------------*
*&      Form  fill_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_OUTTAB   text
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_file USING t_outtab       TYPE  ty_t_outtab
               CHANGING t_download TYPE ty_t_download.
  DATA: ls_outtab TYPE ty_s_outtab,
        ls_outtab_tot TYPE ty_s_outtab,
        ls_download TYPE ty_s_download,
        l_saldo  TYPE dmbtr,
        l_blart  TYPE blart,
        l_num TYPE i,
        l_mod TYPE i.
  CLEAR: g_num.
  REFRESH t_download.
  PERFORM fill_header
              CHANGING
                 gt_download.

  LOOP AT t_outtab  INTO ls_outtab .

    ADD 1 TO g_num.
    IF g_num EQ 1.
***      Imprimir encabezado clase Doc.
      MOVE ls_outtab-blart TO l_blart.

      PERFORM get_blart_description
            USING
               l_blart
            CHANGING
               ls_download-data+2(38).
      APPEND ls_download TO t_download .CLEAR ls_download.
      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.
      ADD 2 TO g_num.
    ENDIF.
***
***    Imprimir totales por clase de Doc.
    IF ls_outtab-blart NE l_blart .
      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.

      ls_download-data+42(10) = 'Total'.
      PERFORM get_blart_description
                  USING
                     l_blart
                  CHANGING
                     ls_download-data+50(38).

      WRITE ls_outtab_tot-taxbash1 TO ls_download-data+110(12)  CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-taxbash2 TO ls_download-data+125(12) CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-taxbash3 TO ls_download-data+140(12) CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-taxbash4 TO ls_download-data+154(12) CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-taxbash5 TO ls_download-data+169(12) CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-taxbash6 TO ls_download-data+184(12) CURRENCY ls_outtab-waers.
      WRITE ls_outtab_tot-sum_all  TO ls_download-data+199(12) CURRENCY ls_outtab-waers.

      CLEAR ls_outtab_tot.
      APPEND ls_download TO t_download .
      CLEAR ls_download.
      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.
      MOVE ls_outtab-blart TO l_blart.


      PERFORM get_blart_description
                            USING
                               l_blart
                            CHANGING
       ls_download-data+2(38).
      APPEND ls_download TO t_download .CLEAR ls_download.
      ls_download-data = c_line.
      APPEND ls_download TO t_download .CLEAR ls_download.
      ADD 4 TO g_num.
    ENDIF.
***
***    Imprimir Linea
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_outtab-bldat
      IMPORTING
        date_external            = ls_download-data+2(10)
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.

    ls_download-data+14(10)  = ls_outtab-xblnr.
    CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
      EXPORTING
        date_internal            = ls_outtab-budat
      IMPORTING
        date_external            = ls_download-data+26(10)
      EXCEPTIONS
        date_internal_is_invalid = 1
        OTHERS                   = 2.
    ls_download-data+38(10)   = ls_outtab-belnr.
    ls_download-data+50(10)   = ls_outtab-stcd1.
    ls_download-data+62(30)   = ls_outtab-name1.

    ls_outtab_tot-taxbash1 =  ls_outtab_tot-taxbash1 + ls_outtab-taxbash1.
    ls_outtab_tot-taxbash2 =  ls_outtab_tot-taxbash2 + ls_outtab-taxbash2.
    ls_outtab_tot-taxbash3 =  ls_outtab_tot-taxbash3 + ls_outtab-taxbash3.
    ls_outtab_tot-taxbash4 =  ls_outtab_tot-taxbash4 + ls_outtab-taxbash4.
    ls_outtab_tot-taxbash5 =  ls_outtab_tot-taxbash5 + ls_outtab-taxbash5.
    ls_outtab_tot-taxbash6 =  ls_outtab_tot-taxbash6 + ls_outtab-taxbash6.

    ls_outtab_tot-sum_all  =  ls_outtab_tot-taxbash1  + ls_outtab_tot-taxbash2 + ls_outtab_tot-taxbash3 + ls_outtab_tot-taxbash4 + ls_outtab_tot-taxbash5.
    ls_outtab_tot-sum_all   = ls_outtab_tot-sum_all + ls_outtab_tot-taxbash6.

    sumxreg = ls_outtab-taxbash1  + ls_outtab-taxbash2 + ls_outtab-taxbash3 + ls_outtab-taxbash4 + ls_outtab-taxbash5.
    sumxreg = sumxreg + ls_outtab-taxbash6.

    WRITE ls_outtab-mwskz TO ls_download-data+98(12).
    WRITE ls_outtab-taxbash1 TO ls_download-data+110(12)  CURRENCY ls_outtab-waers.
    WRITE ls_outtab-taxbash2 TO ls_download-data+125(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab-taxbash3 TO ls_download-data+140(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab-taxbash4 TO ls_download-data+154(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab-taxbash5 TO ls_download-data+169(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab-taxbash6 TO ls_download-data+184(12) CURRENCY ls_outtab-waers.
    WRITE sumxreg  TO ls_download-data+199(12) CURRENCY ls_outtab-waers.


    APPEND ls_download TO t_download .
    CLEAR ls_download.

    l_mod =  g_num MOD g_line.
*    AT LAST.
*      l_mod =  g_num MOD g_line.
*    ENDAT.
***   cada g_num Lines imprime pie y encabezado
    IF l_mod EQ 0.

      PERFORM fill_foot
                  CHANGING
                     gt_download.

      PERFORM fill_header
                  CHANGING
                     gt_download.

    ENDIF.

  ENDLOOP.

  IF ls_outtab_tot IS NOT INITIAL.
    ls_download-data = c_line.
    APPEND ls_download TO t_download .CLEAR ls_download.

    ls_download-data+42(10) = 'Total'.
    PERFORM get_blart_description
                USING
                   l_blart
                CHANGING
                   ls_download-data+50(38).

    WRITE ls_outtab_tot-taxbash1 TO ls_download-data+110(12)  CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-taxbash2 TO ls_download-data+125(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-taxbash3 TO ls_download-data+140(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-taxbash4 TO ls_download-data+154(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-taxbash5 TO ls_download-data+169(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-taxbash6 TO ls_download-data+184(12) CURRENCY ls_outtab-waers.
    WRITE ls_outtab_tot-sum_all  TO ls_download-data+199(12) CURRENCY ls_outtab-waers.
    CLEAR ls_outtab_tot.
    APPEND ls_download TO t_download .
    CLEAR ls_download.
    ls_download-data = c_line.
    APPEND ls_download TO t_download .CLEAR ls_download.
  ENDIF.
ENDFORM.                    "fill_file
*&---------------------------------------------------------------------*
*&      Form  fill_foot
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_foot  CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download.

  ls_download-data = space.
  APPEND ls_download TO t_download .
  ls_download-data = space.
  APPEND ls_download TO t_download .


ENDFORM.                    "fill_foot
*&---------------------------------------------------------------------*
*&      Form  get_description_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS    text
*      -->P_BUTXT    text
*----------------------------------------------------------------------*
FORM get_description_bukrs USING p_bukrs TYPE bukrs
                           CHANGING p_butxt TYPE butxt.
  DATA : l_adrnr TYPE adrnr,
         l_address_selection TYPE addr1_sel,
         l_zgiro TYPE zfigiro.

  SELECT SINGLE butxt adrnr
    FROM t001
    INTO (p_butxt, l_adrnr)
    WHERE bukrs EQ p_bukrs
    AND spras EQ sy-langu.

  MOVE l_adrnr TO  l_address_selection-addrnumber.

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

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
  SELECT SINGLE paval
    FROM t001z
    INTO g_paval
    WHERE bukrs EQ p_bukrs
    AND party EQ 'TAXNR' .

  SELECT * FROM zfigiro
    INTO TABLE gt_zfigiro
    WHERE bukrs = p_bukrs.
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
*&      Form  fill_total
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_CL_DOC   text
*      -->T_DOWNLOAD text
*----------------------------------------------------------------------*
FORM fill_total USING t_cl_doc TYPE ty_t_cl_doc
                CHANGING t_download TYPE ty_t_download.
  DATA: ls_download TYPE ty_s_download,
        ls_cl_doc   TYPE ty_s_cl_doc.

  ls_download-data = space.
  APPEND ls_download TO t_download .

  ls_download-data+76(100) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+79(60)  = 'Período'.
  ls_download-data+158(10)  = s_monat-low.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+79(60)  = 'Compras y/o Servicios Utilizados'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+76(100) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+150(15)  = 'Con derecho'.
  ls_download-data+165(15)  = 'Sin derecho '.
  APPEND ls_download TO t_download .CLEAR ls_download.
  ls_download-data+151(15)  = 'a Crédito'.
  ls_download-data+166(15)  = 'a Crédito'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+76(100) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.



  ls_download-data+79(60)  = gs_iva_doc_e-descripcion.
  WRITE gs_iva_doc_e-monto_cdc TO ls_download-data+151(10) CURRENCY 'CLP'.
  WRITE gs_iva_doc_e-monto_sdc TO ls_download-data+166(10) CURRENCY 'CLP'.
  APPEND ls_download TO t_download .CLEAR ls_download.

  ls_download-data+76(100) = c_line_2.
  APPEND ls_download TO t_download .CLEAR ls_download.

  LOOP AT t_cl_doc INTO ls_cl_doc.
    CASE ls_cl_doc-orden.
      WHEN '1'.
        ls_download-data+79(60)  = 'Sin Derecho a Crédito Fiscal'.
        ls_download-data+150(15)  = 'Cantidad Doc.'.
        ls_download-data+166(15)  = 'Monto Neto'.
        APPEND ls_download TO t_download .CLEAR ls_download.
        ls_download-data+76(100) = c_line_2.
        APPEND ls_download TO t_download .CLEAR ls_download.
      WHEN '4'.
        ls_download-data+79(60)  = 'Con Derecho a Crédito Fiscal Internas'.
        ls_download-data+150(15)  = 'Cantidad Doc.'.
        ls_download-data+166(15)  = 'Monto IVA'.
        APPEND ls_download TO t_download .CLEAR ls_download.
        ls_download-data+76(100) = c_line_2.
        APPEND ls_download TO t_download .CLEAR ls_download.
      WHEN '8'.
        ls_download-data+79(60)  = 'Con Derecho a Crédito Importación'.
        ls_download-data+150(15)  = 'Cantidad Doc.'.
        ls_download-data+166(15)  = 'Monto IVA'.
        APPEND ls_download TO t_download .CLEAR ls_download.
        ls_download-data+76(100) = c_line_2.
        APPEND ls_download TO t_download .CLEAR ls_download.
      WHEN '10'.
*        ls_download-data+79(60)  = 'Recuperación del Impuesto Específico'.
        ls_download-data+150(15)  = 'Cantidad Doc.'.
        ls_download-data+165(15)  = 'Con derecho '.
        APPEND ls_download TO t_download .CLEAR ls_download.
        ls_download-data+166(15)  = 'a Crédito'.
        APPEND ls_download TO t_download .CLEAR ls_download.
        ls_download-data+76(100) = c_line_2.
        APPEND ls_download TO t_download .CLEAR ls_download.
    ENDCASE.
    ls_download-data+81(60)  = ls_cl_doc-descripcion.
    ls_download-data+151(10)  = ls_cl_doc-cantidad.
    WRITE ls_cl_doc-monto TO ls_download-data+163(13) CURRENCY ls_cl_doc-moneda.
    APPEND ls_download TO t_download .CLEAR ls_download.
    ls_download-data+76(100) = c_line_2.
    APPEND ls_download TO t_download .CLEAR ls_download.
  ENDLOOP.
ENDFORM.                    "fill_total
*&---------------------------------------------------------------------*
*&      Form  get_blart_description
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_blart_description  USING p_blart TYPE blart
      CHANGING p_ltext TYPE char38.

  SELECT  SINGLE ltext FROM t003t
    INTO p_ltext
    WHERE spras EQ sy-langu
    AND blart EQ p_blart..
ENDFORM.                    " get_blart_description
*&---------------------------------------------------------------------*
*&      Form  init_global_values.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM init_global_values .
  DATA: ls_cl_doc TYPE ty_s_cl_doc,
         ls_download TYPE ty_s_download.
  opt-dynnr = '1001'.
  opt-activetab = 'USER1'.
  tab1 = text-200.
  tab2 = text-210.
  tab3 = text-220.
  g_repid = sy-repid.
  gs_iva_doc_e-descripcion = text-020.

  ls_cl_doc-descripcion = text-021.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 1.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = text-022.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 2.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.
  ls_cl_doc-descripcion = text-023.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 3.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = text-024.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 4.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = text-025.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 5.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = text-026.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 6.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = text-027.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 7.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = text-028.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 8.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = text-029.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 9.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.

  ls_cl_doc-descripcion = text-030.
  ls_cl_doc-moneda     = 'CLP'.
  ls_cl_doc-orden      = 10.
  APPEND ls_cl_doc  TO gt_cl_doc.CLEAR ls_cl_doc.
  PERFORM init_blart.
ENDFORM.                    " init_global_values.
*&---------------------------------------------------------------------*
*&      Form  DETERMINE_TAX2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_BSET  text
*      -->P_PS_BKPF  text
*      <--P_LS_OUTTAB  text
*----------------------------------------------------------------------*
FORM determine_tax2  USING ps_bset TYPE bset
                           p_hwbas
                           ps_bkpf TYPE bkpf
                    CHANGING ps_outtab TYPE ty_s_outtab.

  DATA ls_cl_doc TYPE ty_s_cl_doc.

* Ind. Impto.
  MOVE ps_bset-mwskz TO  ps_outtab-mwskz.
  CASE ps_bset-mwskz.
    WHEN 'C1' OR 'C5' OR 'C9' OR 'C4' or 'Z2'.
* AGRREGO C4 12.06.2014
*      MOVE ps_bset-hwbas TO ps_outtab-taxbash1. "AFECCTO
*      MOVE ps_bset-hwste TO ps_outtab-taxbash3. "IVA

      ls_cl_doc-descripcion = text-023.
      ls_cl_doc-monto       = p_hwbas.
      ls_cl_doc-moneda      = ps_bkpf-waers.
*          LS_CL_DOC-CANTIDAD    = 1.
      ls_cl_doc-orden       = 3.
      COLLECT ls_cl_doc INTO gt_cl_doc.


*      CASE PS_BKPF-BLART.
**        WHEN 'F3' OR 'F4' OR 'N3' OR 'N4' OR 'D3' OR 'D4'.
**          GS_IVA_DOC_E-MONTO_CDC = GS_IVA_DOC_E-MONTO_CDC + PS_BSET-HWSTE.
*
*        WHEN 'F6' OR 'F5'.
*          LS_CL_DOC-DESCRIPCION = TEXT-021.
*          LS_CL_DOC-MONTO       = PS_BSET-HWBAS.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 1.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*        WHEN 'F1' OR 'F3'.
*          LS_CL_DOC-DESCRIPCION = TEXT-023.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
**          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 4.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'F2' OR 'F4'.
*          LS_CL_DOC-DESCRIPCION = TEXT-025.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 5.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'N1' OR 'N2' OR 'N3' OR 'N4'.
*          LS_CL_DOC-DESCRIPCION = TEXT-026.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 6.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'D1' OR 'D2' OR 'D3' OR 'D4'.
*          LS_CL_DOC-DESCRIPCION = TEXT-027.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 7.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'I1'.
*          LS_CL_DOC-DESCRIPCION = TEXT-028.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 8.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*
*        WHEN 'I2'.
*          LS_CL_DOC-DESCRIPCION = TEXT-029.
*          LS_CL_DOC-MONTO       = PS_BSET-HWSTE.
*          LS_CL_DOC-MONEDA      = PS_BKPF-WAERS.
*          LS_CL_DOC-CANTIDAD    = 1.
*          LS_CL_DOC-ORDEN       = 9.
*          COLLECT LS_CL_DOC INTO GT_CL_DOC.
*      ENDCASE.


*    WHEN 'C4' OR 'C6'. ELIMINO C4 12.06.2014
    WHEN  'C6' OR 'C8'.
      MOVE ps_bset-hwste TO ps_outtab-taxbash4. "IVA no retenido
      MOVE ps_bset-hwbas TO ps_outtab-taxbash1. "AFECCTO
* ziclos Abril 2011  cuenta iVA no retenido y IVA proporcional

      IF ps_bset-mwskz = 'C8'. " Iva no recuperado
        MOVE ps_bset-hkont TO wa_lce-cta_iva_nr.
      ENDIF.
      IF ps_bset-mwskz = 'C6'. " Iva no recuperado
        MOVE ps_bset-hkont TO wa_lce-cta_iva_propor.
      ENDIF.
      CASE ps_bkpf-blart.

        WHEN 'F6'.
          gs_iva_doc_e-monto_sdc = gs_iva_doc_e-monto_sdc + ps_bset-hwbas.
        WHEN 'F5'.
          ls_cl_doc-descripcion = text-021.
          ls_cl_doc-monto       = ps_bset-hwbas.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 1.
          COLLECT ls_cl_doc INTO gt_cl_doc.
        WHEN 'I3'.
          ls_cl_doc-descripcion = text-022.
          ls_cl_doc-monto       = ps_bset-hwbas.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 2.
          COLLECT ls_cl_doc INTO gt_cl_doc.
      ENDCASE.
    WHEN 'C7'.
      MOVE ps_bset-hwbas TO ps_outtab-taxbash5. "OTROS IMPTOS.
      CASE ps_bkpf-blart.
        WHEN 'F1' OR 'F3' OR 'I1' OR 'N1' OR 'N3' OR 'D1' OR 'D3'.
          ls_cl_doc-descripcion = text-030.
          ls_cl_doc-monto       = ps_bset-hwbas.
          ls_cl_doc-moneda      = ps_bkpf-waers.
          ls_cl_doc-cantidad    = 1.
          ls_cl_doc-orden       = 10.
          COLLECT ls_cl_doc INTO gt_cl_doc.
      ENDCASE.
  ENDCASE.

*  PS_OUTTAB-SUM_ALL = PS_OUTTAB-TAXBASH1 + PS_OUTTAB-TAXBASH2 +
*                      PS_OUTTAB-TAXBASH3 + PS_OUTTAB-TAXBASH4 +
*                      PS_OUTTAB-TAXBASH5.
ENDFORM.                    " DETERMINE_TAX2
*&---------------------------------------------------------------------*
*&      Form  MOVE_CAMPOS_LCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM move_campos_lce USING ls_outtab TYPE ty_s_outtab.
  DATA: amount_display LIKE wmto_s-amount,
        amount_sap LIKE wmto_s-amount.
  READ TABLE ta_zlce_sii INTO wa_zlce_sii WITH KEY bukrs = ls_outtab-bukrs
                                 blart = ls_outtab-blart .

  MOVE:

         ls_outtab-bukrs  TO wa_lce-bukrs,
         ls_outtab-budat+4(2) TO wa_lce-monat,
         ls_outtab-gjahr  TO wa_lce-gjahr,
         ls_outtab-belnr  TO wa_lce-corr_doc,
         ls_outtab-xblnr  TO wa_lce-num_doc,

*          budat    TYPE budat,
*          bldat    TYPE bldat,
*          blart    TYPE blart,
         ls_outtab-blart   TO  wa_lce-tip_fac_sap,

         wa_zlce_sii-doc_sii   TO  wa_lce-tip_fac_sii,
         ls_outtab-name1   TO  wa_lce-nombre_prov,
         ls_outtab-stcd1  TO wa_lce-rut_prov.

  IF ls_outtab-mwskz <> 'C0' AND wa_lce-tip_impto = 'C0'.
    wa_lce-tip_impto =  ls_outtab-mwskz.
  ENDIF.

  MOVE: ls_outtab-taxbash1 TO amount_sap.

  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      currency        = ls_outtab-waers
      amount_internal = amount_sap
    IMPORTING
      amount_display  = wa_lce-afecto.     "afecto.
  MOVE: ls_outtab-taxbash2 TO amount_sap.
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      currency        = ls_outtab-waers
      amount_internal = amount_sap
    IMPORTING
      amount_display  = wa_lce-exento.     "exento
  MOVE: ls_outtab-taxbash3 TO amount_sap.
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      currency        = ls_outtab-waers
      amount_internal = amount_sap
    IMPORTING
      amount_display  = wa_lce-viva.     "valor IVA
*ziclos mayo 2011 se mueve el valor del IVA al IVA proporcional
  IF wa_lce-tip_impto = 'C9' OR wa_lce-tip_impto = 'C5'.
    MOVE wa_lce-viva_propor TO amount_sap.
    CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
      EXPORTING
        currency        = ls_outtab-waers
        amount_internal = amount_sap
      IMPORTING
        amount_display  = wa_lce-viva_propor.     "#EC NO_INCOMP
    IF wa_lce-viva = wa_lce-viva_propor.
      MOVE wa_lce-viva TO wa_lce-viva_propor.
      CLEAR wa_lce-viva.
      MOVE porc_iva     TO wa_lce-porc_iva_nr.  " es el iva porporcional no recuperado
    ELSE.
      wa_lce-viva  =  wa_lce-viva - wa_lce-viva_propor.
      MOVE porc_iva     TO wa_lce-porc_iva_nr.  " es el iva porporcional no recuperado

    ENDIF.
  ENDIF.
  MOVE: ls_outtab-taxbash4 TO amount_sap.
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      currency        = ls_outtab-waers
      amount_internal = amount_sap
    IMPORTING
      amount_display  = wa_lce-viva_nr. " IVA NO RECUPERADO
  MOVE: ls_outtab-sum_all TO amount_sap.
  CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
    EXPORTING
      currency        = ls_outtab-waers
      amount_internal = amount_sap
    IMPORTING
      amount_display  = wa_lce-vtotal. " VALOR TOTAL

  MOVE:
           ls_outtab-waers         TO  wa_lce-waers, " MONEDA

           ls_outtab-mwskz        TO  wa_lce-tip_impto. " Ind. Impto.

  COLLECT wa_lce INTO   ta_lce.
  CLEAR wa_zlce_sii.
  CLEAR wa_lce.

ENDFORM.                    " MOVE_CAMPOS_LCE
*&---------------------------------------------------------------------*
*&      Form  CARGAR_TABLA_DOC_SII
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM cargar_tabla_doc_sii .
  SELECT * FROM zlce_sii INTO TABLE ta_zlce_sii.
ENDFORM.                    " CARGAR_TABLA_DOC_SII

*----------------------------------------------------------------------*
* RUTINAS DE CONEXION  *
*----------------------------------------------------------------------*
FORM openconnection.
  EXEC SQL.
    connect to 'SAPCSC' as 'CON'
  ENDEXEC.
  EXEC SQL.
    set connection 'CON'
  ENDEXEC.
ENDFORM.                    "openconnection
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM closeconnection.
  EXEC SQL.
    SET CONNECTION DEFAULT
  ENDEXEC.
ENDFORM.                    "closeconnection
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
