*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE ZFIMDP_TABLE_CONTROL .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  F4_MWSKZ  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_mwskz INPUT.
  CALL FUNCTION 'J_1BSA_COMPONENT_ACTIVE'
    EXPORTING
      bukrs     = zacgl_item_tbctr-bukrs
      component = 'AR'
    EXCEPTIONS
      OTHERS    = 1.
  gener = t020-gener.

  CALL FUNCTION 'ZFI_F4_MWSKZ'
    EXPORTING
      i_kalsm = 'TAXCL'
      i_stbuk = zacgl_item_tbctr-bukrs
      i_lstml = g_lstml                              "Note 205413
      i_gener = gener                                "Note 424583
    IMPORTING
      e_mwskz = zacgl_item-mwskz.
ENDMODULE.                 " F4_MWSKZ  INPUT
*&---------------------------------------------------------------------*
*&      Module  ATRIBUTOS_Z  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE atributos_z INPUT.
  IF sy-ucomm NE 'BACK'
 AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.


    IF  zacgl_item_tbctr-anln1  NE space.
      IF zacgl_item_tbctr-anbwa EQ space.
        SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ANBWA' LINE sy-stepl.
        MESSAGE e007(z1).
      ELSE.
        IF rf05a-buscs EQ 'R'.
          IF zacgl_item_tbctr-anbwa NE 100.
            SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ANBWA' LINE sy-stepl.
            MESSAGE e008(z1).
          ENDIF.
        ELSE.
          IF rf05a-buscs EQ 'G'.
            IF zacgl_item_tbctr-anbwa NE 150.
              SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ANBWA' LINE sy-stepl.
              MESSAGE e009(z1).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF  zacgl_item_tbctr-zzprestac  NE space.
      DATA: p_zzprestac TYPE zprestacion-zzprestac.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zacgl_item_tbctr-zzprestac
        IMPORTING
          output = zacgl_item_tbctr-zzprestac.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE zzprestac FROM zprestacion INTO p_zzprestac
*         WHERE zzprestac = zacgl_item_tbctr-zzprestac
*        AND    bukrs     = zacgl_item_tbctr-bukrs.
*
* NEW CODE
      SELECT zzprestac
      UP TO 1 ROWS  FROM zprestacion INTO p_zzprestac
         WHERE zzprestac = zacgl_item_tbctr-zzprestac
        AND    bukrs     = zacgl_item_tbctr-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ZZPRESTAC' LINE sy-stepl.
        MESSAGE e001(z1) WITH zacgl_item_tbctr-zzprestac 'No Es Valido.'.
      ENDIF.
    ENDIF.

    IF   zacgl_item_tbctr-zzunid_pro  NE space.
      DATA: p_zzcod_unidad TYPE zunid_prod-zzcod_unidad.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zacgl_item_tbctr-zzunid_pro
        IMPORTING
          output = zacgl_item_tbctr-zzunid_pro.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  zzcod_unidad FROM zunid_prod INTO  p_zzcod_unidad
*         WHERE zzcod_unidad = zacgl_item_tbctr-zzunid_pro
*        AND    bukrs     = zacgl_item_tbctr-bukrs.
*
* NEW CODE
      SELECT zzcod_unidad
      UP TO 1 ROWS  FROM zunid_prod INTO  p_zzcod_unidad
         WHERE zzcod_unidad = zacgl_item_tbctr-zzunid_pro
        AND    bukrs     = zacgl_item_tbctr-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ZZUNID_PRO' LINE sy-stepl.
        MESSAGE e002(z1) WITH zacgl_item_tbctr-zzunid_pro 'No Es Valido.'.
      ENDIF.
    ENDIF.


    IF  zacgl_item_tbctr-zzdesc_est  NE space.
      DATA: e_zzcod_unidad TYPE zdesc_est-zzcod_unidad.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zacgl_item_tbctr-zzdesc_est
        IMPORTING
          output = zacgl_item_tbctr-zzdesc_est.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  zzcod_unidad FROM zdesc_est INTO  e_zzcod_unidad
*         WHERE zzcod_unidad = zacgl_item_tbctr-zzdesc_est
*        AND    bukrs     = zacgl_item_tbctr-bukrs.
*
* NEW CODE
      SELECT zzcod_unidad
      UP TO 1 ROWS  FROM zdesc_est INTO  e_zzcod_unidad
         WHERE zzcod_unidad = zacgl_item_tbctr-zzdesc_est
        AND    bukrs     = zacgl_item_tbctr-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ZZDESC_EST' LINE sy-stepl.
        MESSAGE e003(z1) WITH zacgl_item_tbctr-zzdesc_est 'No Es Valido.'.
      ENDIF.
    ENDIF.


    IF  zacgl_item_tbctr-zzmot_emis  NE space.
      DATA: ii_zzcod_unidad TYPE zmot_emis-zzmot_emis.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zacgl_item_tbctr-zzmot_emis
        IMPORTING
          output = zacgl_item_tbctr-zzmot_emis.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  zzmot_emis FROM zmot_emis INTO  ii_zzcod_unidad
*         WHERE zzmot_emis =  zacgl_item_tbctr-zzmot_emis
*        AND    bukrs     = zacgl_item_tbctr-bukrs.
*
* NEW CODE
      SELECT zzmot_emis
      UP TO 1 ROWS  FROM zmot_emis INTO  ii_zzcod_unidad
         WHERE zzmot_emis =  zacgl_item_tbctr-zzmot_emis
        AND    bukrs     = zacgl_item_tbctr-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ZZMOT_EMIS' LINE sy-stepl.
        MESSAGE e004(z1) WITH zacgl_item_tbctr-zzmot_emis 'No Es Valido.'.
      ENDIF.
    ENDIF.

    IF   zacgl_item_tbctr-zzrut_terc NE space.
      DATA: aa_zzcod_unidad TYPE lfa1-lifnr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zacgl_item_tbctr-zzrut_terc
        IMPORTING
          output = zacgl_item_tbctr-zzrut_terc.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  lifnr FROM lfb1 INTO  aa_zzcod_unidad
*         WHERE lifnr =  zacgl_item_tbctr-zzrut_terc
*        AND    bukrs     = zacgl_item_tbctr-bukrs.
*
* NEW CODE
      SELECT lifnr
      UP TO 1 ROWS  FROM lfb1 INTO  aa_zzcod_unidad
         WHERE lifnr =  zacgl_item_tbctr-zzrut_terc
        AND    bukrs     = zacgl_item_tbctr-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ZZRUT_TERC' LINE sy-stepl.
        MESSAGE e005(z1) WITH  zacgl_item_tbctr-zzrut_terc 'No Es Valido.'.
      ENDIF.
    ENDIF.

    IF zacgl_item_tbctr-zz_agencia  NE space.
      DATA: rr_zzcod_unidad TYPE zagencia-zzcod_unidad.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = zacgl_item_tbctr-zz_agencia
        IMPORTING
          output = zacgl_item_tbctr-zz_agencia.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  zzcod_unidad FROM zagencia INTO  rr_zzcod_unidad
*         WHERE zzcod_unidad = zacgl_item_tbctr-zz_agencia
*        AND    bukrs     = zacgl_item_tbctr-bukrs.
*
* NEW CODE
      SELECT zzcod_unidad
      UP TO 1 ROWS  FROM zagencia INTO  rr_zzcod_unidad
         WHERE zzcod_unidad = zacgl_item_tbctr-zz_agencia
        AND    bukrs     = zacgl_item_tbctr-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-ZZ_AGENCIA' LINE sy-stepl.
        MESSAGE e006(z1) WITH zacgl_item_tbctr-zz_agencia 'No Es Valido.'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " ATRIBUTOS_Z  INPUT
*&---------------------------------------------------------------------*
*&      Module  VAL_OBJETO_CO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE val_objeto_co INPUT.

  IF sy-ucomm NE 'BACK'
 AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.


    DATA: ed_kokrs TYPE  kokrs,
       v_cskb LIKE  cskbv.

    DATA: aufk LIKE  aufk.

    DATA: id_fin_company TYPE  con_fin_company.
    id_fin_company = zacgl_item_tbctr-bukrs.

    CALL FUNCTION 'CON_FIN_GET_KOKRS_FROM_COMPANY'
      EXPORTING
        id_fin_company = id_fin_company
      IMPORTING
        ed_kokrs       = ed_kokrs.

    CALL FUNCTION 'RK_KSTAR_READ'
      EXPORTING
        datum           = zinvfo-budat
        kokrs           = ed_kokrs
        kstar           = zacgl_item_tbctr-hkont
      IMPORTING
        v_cskb          = v_cskb
      EXCEPTIONS
        kstar_not_found = 1
        OTHERS          = 2.
    IF sy-subrc EQ 0.
      IF zacgl_item_tbctr-kostl EQ space AND zacgl_item_tbctr-aufnr EQ space
        AND zacgl_item_tbctr-prctr  EQ space.
        SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-KOSTL' LINE sy-stepl.
        MESSAGE e235(ki) WITH zacgl_item_tbctr-hkont.
      ELSE.
        IF zacgl_item_tbctr-kostl NE  space.

          CALL FUNCTION 'ITOB_CHECK_COSTCENTER'
            EXPORTING
              kokrs_imp         = ed_kokrs
              kostl_imp         = zacgl_item_tbctr-kostl
              bukrs_imp         = zacgl_item_tbctr-bukrs
              langu             = sy-langu
              dialog_mode       = 'X'
              dialog_cursor     = 'ZACGL_ITEM_TBCTR-KOSTL'
              init_message_data = 'X'
              x_mess_type       = 'E'
              read_text_tables  = 'X'
              check_auth_tcode  = ' '
            EXCEPTIONS
              empty_key         = 1
              application_error = 2
              OTHERS            = 3.
          IF sy-subrc <> 0.
            SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-KOSTL' LINE sy-stepl.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.

        IF zacgl_item_tbctr-aufnr NE space.
          CALL FUNCTION 'K_AUFK_READ'
            EXPORTING
              i_aufnr            = zacgl_item_tbctr-aufnr
              i_no_buffer_read   = ' '
              i_no_database_read = ' '
            IMPORTING
              e_aufk             = aufk
            EXCEPTIONS
              not_found          = 1
              OTHERS             = 2.
          IF sy-subrc > 0.
            SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-AUFNR' LINE sy-stepl.
            MESSAGE e104(ko) WITH zacgl_item_tbctr-aufnr.
          ENDIF.

        ENDIF.

        IF zacgl_item_tbctr-prctr NE space.
          CALL FUNCTION 'KE_PROFIT_CENTER_BUKRS_CHECK'
            EXPORTING
              i_prctr            = zacgl_item_tbctr-prctr
              i_bukrs            = zacgl_item_tbctr-bukrs
              i_kokrs            = ed_kokrs
            EXCEPTIONS
              not_defined        = 1
              no_kokrs_for_bukrs = 2
              OTHERS             = 3.
          IF sy-subrc <> 0.
            SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-PRCTR' LINE sy-stepl.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF zacgl_item_tbctr-aufnr NE space AND zacgl_item_tbctr-kostl NE space.
      SET CURSOR FIELD 'ZACGL_ITEM_TBCTR-KOSTL' LINE sy-stepl.
      MESSAGE e010(z1).
    ENDIF.

  ENDIF.
ENDMODULE.                 " VAL_OBJETO_CO  INPUT
*&---------------------------------------------------------------------*
*&      Module  TABLE_MARK  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE table_mark INPUT.

  IF table-line_sel_mode = 1
  AND zacgl_item_tbctr-spgrg = 'X'.
    LOOP AT g_table_itab INTO g_table_wa
      WHERE marksp = 'X'.
      g_table_wa-marksp = ''.
      MODIFY g_table_itab
        FROM g_table_wa
        TRANSPORTING marksp.
    ENDLOOP.
  ENDIF.
*Begin of change: ReSQ Correction for MODIFY on an unsorted Internal Table 23/12/2019 EY_DES02 ECDK917080 *
SORT G_TABLE_ITAB .
*End of change: ReSQ Correction for MODIFY on an unsorted Internal Table 23/12/2019 EY_DES02 ECDK917080 *
  MODIFY g_table_itab
     FROM g_table_wa
     INDEX table-current_line
     TRANSPORTING marksp.
ENDMODULE.                 " TABLE_MARK  INPUT
*&---------------------------------------------------------------------*
*&      Module  BALANCE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE balance OUTPUT.

  DATA:  total_bseg LIKE zacgl_item-wrbtr.

  rf05a-azsal = total_bseg.
  rf05a-ubazw = zinvfo-waers.
  IF rf05a-ampel IS  INITIAL.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        info   = text-e14
        name   = 'ICON_YELLOW_LIGHT'
      IMPORTING
        RESULT = rf05a-ampel.
  ENDIF.

ENDMODULE.                 " BALANCE  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  BALANCE_SAL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE balance_sal INPUT.

  IF sy-ucomm NE 'BACK'
 AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.



    DATA it_sumula TYPE zacgl_item OCCURS 100 WITH HEADER LINE.
    DATA e_a003 TYPE a003 OCCURS 100 WITH HEADER LINE.


    DATA: total_pos LIKE zacgl_item-wrbtr,
          total_pos_s LIKE zacgl_item-wrbtr,
          total_pos_h LIKE zacgl_item-wrbtr,
          total_iva LIKE zacgl_item-wrbtr,
          total_iva_no_re LIKE zacgl_item-wrbtr,
             iva_prop        LIKE konp-kbetr,
          iva            LIKE zacgl_item-wrbtr,
          iva_no_re       LIKE zacgl_item-wrbtr.

    DATA: total_bseg2 LIKE zacgl_item-wrbtr.
    DATA: t_bseg  TYPE bseg OCCURS 100 WITH HEADER LINE,
          t_bseg2  TYPE bseg OCCURS 100 WITH HEADER LINE,
          t_bkpf  TYPE bkpf OCCURS 100 WITH HEADER LINE,
          t_bkpf2  TYPE bkpf OCCURS 100 WITH HEADER LINE,
          t_erinf  TYPE acerrlog OCCURS 100 WITH HEADER LINE.
    DATA: i_t020  LIKE t020.

    DATA: valor_b1    TYPE bseg-wrbtr,
          tot_por_b1  TYPE bseg-wrbtr,
          rest_por_b1 TYPE bseg-wrbtr.

    DATA: valor2_b2    TYPE bseg-wrbtr,
          tot_por2_b2  TYPE bseg-wrbtr,
          rest_por2_b2 TYPE bseg-wrbtr.
    DATA: pos TYPE i VALUE 1.




    REFRESH: it_t001, t_bseg,t_bseg2,t_bkpf, t_erinf, it_sumula,e_a003.
    CLEAR: it_t001, t_bseg,t_bseg2,t_bkpf, t_erinf,it_sumula,e_a003, pos,
           rest_por2_b2,tot_por2_b2,valor2_b2,rest_por_b1,tot_por_b1,valor_b1,
           i_t020,total_pos,total_pos_s, total_pos_h,total_iva,total_iva_no_re,
            iva,  iva_no_re, total_bseg,total_bseg2, iva_prop.
    DATA: pe_i_konp TYPE  konp.

    DATA:   t_dif TYPE bseg-wrbtr,
            t_debe TYPE bseg-wrbtr,
            t_haber TYPE bseg-wrbtr,
            aa LIKE sy-tabix.

    CLEAR: aa, t_dif, t_debe, t_haber.




    IF rf05a-buscs EQ 'R'.
      LOOP AT   g_table_itab
           INTO g_table_wa WHERE hkont NE space.
        MOVE-CORRESPONDING  g_table_wa TO it_t001.
        APPEND it_t001.
      ENDLOOP.

      CLEAR: total_pos_s.
      LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'S' AND mwskz EQ 'C9'.
        ADD it_t001-wrbtr TO total_pos_s.
        CLEAR: it_t001.
      ENDLOOP.


      CLEAR: total_pos_h.
      LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'H' AND mwskz EQ 'C9'.
        ADD it_t001-wrbtr TO total_pos_h.
        CLEAR: it_t001.
      ENDLOOP.



*      TOTAL_POS = TOTAL_POS_S - TOTAL_POS_H.
*      IF TOTAL_POS > 0.
*        CALL FUNCTION 'RE_KTOSL_TO_MWSKZ_GET'
*          EXPORTING
*            I_MWSKZ                        = ZINVFO-MWSKZ
*            I_BUKRS                        = ZINVFO-BUKRS
*          TABLES
*            E_A003                         = E_A003
*          EXCEPTIONS
*            NO_MWSKZ_IN_T001LAND           = 1
*            NO_KTOSL_FOR_MWSKZ_IN_T001LAND = 2
*            T638S_T007B_INCONSISTENCY      = 3
*            OTHERS                         = 4.
*        IF SY-SUBRC = 0.
*          READ TABLE E_A003 INDEX 1.
*          IF SY-SUBRC EQ 0.
*            CALL FUNCTION 'WV_KONP_GET'
*              EXPORTING
*                PI_KNUMH        = E_A003-KNUMH
*                PI_KAPPL        = E_A003-KAPPL
*                PI_KSCHL        = E_A003-KSCHL
*              IMPORTING
*                PE_I_KONP       = PE_I_KONP
*              EXCEPTIONS
*                NO_RECORD_FOUND = 1
*                OTHERS          = 2.
*            IF SY-SUBRC = 0.
** Calcula IVA.
*              IVA = PE_I_KONP-KBETR / 1000.
*              TOTAL_IVA = TOTAL_POS *  IVA.
** Calcula IVA Proporcional
*              SELECT SINGLE IVA_PROP INTO  IVA_PROP
*                      FROM ZFIIVAPRP
*                    WHERE  BUKRS EQ ZINVFO-BUKRS
*                    AND    FEC_INICO <= ZINVFO-BUDAT
*                    AND    FEC_FIN  >= ZINVFO-BUDAT.
*              IF SY-SUBRC EQ 0.
*                IVA_NO_RE = IVA_PROP / 100.
*                TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_NO_RE.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*      I_T020-TCODE =  'FB60'.
*      I_T020-KOART =    'K'.
*      I_T020-AKTYP =    'H'.
*      I_T020-DYNCL =    'B'.
*      I_T020-FUNCL =    ' '.
*      I_T020-STATU =    'ENJINV'.
*      I_T020-GENER =    '1'.
*
*      MOVE-CORRESPONDING BKPF TO T_BKPF.
*      APPEND T_BKPF.
*
* Posicion de Acreedor
      MOVE-CORRESPONDING zinvfo TO t_bseg.
      t_bseg-bschl = '31'.
      t_bseg-shkzg = 'H'.
      t_bseg-buzei = '1'.
      t_bseg-koart = 'K'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-wrbtr =  t_bseg-wrbtr +  total_iva.
      t_bseg-dmbtr =  t_bseg-wrbtr.
      t_bseg-kokrs = 'BMSA'.
      APPEND t_bseg.
      CLEAR t_bseg.
*
** Posicion de  cuentas de mayor
      LOOP AT it_t001 WHERE hkont NE space.
        ADD 1 TO pos.
        MOVE-CORRESPONDING it_t001 TO t_bseg.
*        IF   IT_T001-SHKZG = 'S'.
*          IF TOTAL_POS_S > 0 AND IT_T001-MWSKZ EQ 'C9'.
*            IT_T001-PORCENTAJE  =  ( ( T_BSEG-WRBTR * 100 ) / TOTAL_POS_S ).
*
*            TOT_POR_B1 = IT_T001-PORCENTAJE + TOT_POR_B1.
*            IF TOT_POR_B1 > 100.
*              REST_POR_B1  =  TOT_POR_B1  - 100.
*              IT_T001-PORCENTAJE =  IT_T001-PORCENTAJE - REST_POR_B1.
*              CLEAR: TOT_POR_B1, REST_POR_B1.
*            ENDIF.
*            VALOR_B1        = TOTAL_IVA_NO_RE * IT_T001-PORCENTAJE / 100.
*            T_BSEG-WRBTR =  T_BSEG-WRBTR +  VALOR_B1.
*          ENDIF.
*        ELSE.
*          IF   IT_T001-SHKZG = 'H' AND IT_T001-MWSKZ EQ 'C9'.
*            IF TOTAL_POS_S > 0.
*              IT_T001-PORCENTAJE2  =  ( ( T_BSEG-WRBTR * 100 ) / TOTAL_POS_S ).
*              TOT_POR2_B2 = IT_T001-PORCENTAJE2 + TOT_POR2_B2.
*              IF TOT_POR2_B2 > 100.
*                REST_POR2_B2  =  TOT_POR2_B2  - 100.
*                IT_T001-PORCENTAJE2 =  IT_T001-PORCENTAJE2 - REST_POR2_B2.
*                CLEAR: TOT_POR2_B2, REST_POR2_B2.
*              ENDIF.
*              VALOR2_B2        = TOTAL_IVA_NO_RE * IT_T001-PORCENTAJE2 / 100.
*              T_BSEG-WRBTR =  T_BSEG-WRBTR +  VALOR2_B2.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
        t_bseg-buzei = pos.
        t_bseg-koart = 'S'.
        t_bseg-pswsl = zinvfo-waers.
        t_bseg-dmbtr =  t_bseg-wrbtr.
        t_bseg-kokrs = 'BMSA'.
        t_bseg-gjahr = zinvfo-gjahr.
        t_bseg-sgtxt = zinvfo-sgtxt.            "Quintec mvm 26.07.2010
        APPEND t_bseg.
        CLEAR t_bseg.
      ENDLOOP.
*
*      IF TOTAL_IVA > 0.
** Pos iva Normal
*        ADD 1 TO POS.
*        T_BSEG-BUKRS = ZINVFO-BUKRS.
*        T_BSEG-BSCHL = '40'.
*        T_BSEG-HKONT = '1013310004'.
*        T_BSEG-SHKZG = 'S'.
*        T_BSEG-BUZEI = POS.
*        T_BSEG-KOART = 'S'.
*        T_BSEG-PSWSL = ZINVFO-WAERS.
*        T_BSEG-DMBTR =  TOTAL_IVA.
*        T_BSEG-WRBTR =  TOTAL_IVA.
*        T_BSEG-KOKRS = 'BMSA'.
*        T_BSEG-GJAHR = ZINVFO-GJAHR.
*        APPEND T_BSEG.
*        CLEAR T_BSEG.
*      ENDIF.
*
** Pos Iva Proporcional
*      IF TOTAL_IVA_NO_RE > 0.
*        ADD 1 TO POS.
*        T_BSEG-BUKRS = ZINVFO-BUKRS.
*        T_BSEG-BSCHL = '50'.
*        T_BSEG-HKONT = '1013310005'.
*        T_BSEG-SHKZG = 'H'.
*        T_BSEG-BUZEI = POS.
*        T_BSEG-KOART = 'S'.
*        T_BSEG-PSWSL = ZINVFO-WAERS.
*        T_BSEG-DMBTR = TOTAL_IVA_NO_RE - VALOR2_B2.
*        T_BSEG-WRBTR = TOTAL_IVA_NO_RE - VALOR2_B2.
*        T_BSEG-KOKRS = 'BMSA'.
*        T_BSEG-GJAHR = ZINVFO-GJAHR.
*        APPEND T_BSEG.
*        CLEAR T_BSEG.
*      ENDIF.
*      LOOP AT T_BSEG.
*        IF T_BSEG-SHKZG EQ 'S'.
*          T_DEBE = T_DEBE + T_BSEG-WRBTR.
*        ELSE.
*          T_HABER = T_HABER + T_BSEG-WRBTR.
*        ENDIF.
*      ENDLOOP.
*
*      T_DIF = T_DEBE - T_HABER.
*
*      LOOP AT T_BSEG WHERE MWSKZ EQ 'C9' and KOART ne 'K' AND WRBTR > 0.
*        AA = SY-TABIX.
*      ENDLOOP.
*
*      READ TABLE T_BSEG INDEX  AA.
*      IF SY-SUBRC EQ 0.
*        IF  T_DIF > 0.
*
*          T_BSEG-WRBTR = T_BSEG-WRBTR +  T_DIF.
*        ELSE.
*          IF  T_DIF < 0.
*            T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF.
*          ENDIF.
*        ENDIF.
*        MODIFY T_BSEG INDEX AA.
*      ENDIF.
    ENDIF.
************************************************************
    IF rf05a-buscs EQ 'G'.

      LOOP AT   g_table_itab
           INTO g_table_wa WHERE hkont NE space.
        MOVE-CORRESPONDING  g_table_wa TO it_t001.
        APPEND it_t001.
      ENDLOOP.


      CLEAR: total_pos_s.
      LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'S' AND mwskz EQ 'C9'.
        ADD it_t001-wrbtr TO total_pos_s.
        CLEAR: it_t001.
      ENDLOOP.


      CLEAR: total_pos_h.
      LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'H' AND mwskz EQ 'C9'.
        ADD it_t001-wrbtr TO total_pos_h.
        CLEAR: it_t001.
      ENDLOOP.

      total_pos = total_pos_h - total_pos_s.


*      IF TOTAL_POS > 0.
*        CALL FUNCTION 'RE_KTOSL_TO_MWSKZ_GET'
*          EXPORTING
*            I_MWSKZ                        = ZINVFO-MWSKZ
*            I_BUKRS                        = ZINVFO-BUKRS
*          TABLES
*            E_A003                         = E_A003
*          EXCEPTIONS
*            NO_MWSKZ_IN_T001LAND           = 1
*            NO_KTOSL_FOR_MWSKZ_IN_T001LAND = 2
*            T638S_T007B_INCONSISTENCY      = 3
*            OTHERS                         = 4.
*        IF SY-SUBRC = 0.
*          READ TABLE E_A003 INDEX 1.
*          IF SY-SUBRC EQ 0.
*
*            CALL FUNCTION 'WV_KONP_GET'
*              EXPORTING
*                PI_KNUMH        = E_A003-KNUMH
*                PI_KAPPL        = E_A003-KAPPL
*                PI_KSCHL        = E_A003-KSCHL
*              IMPORTING
*                PE_I_KONP       = PE_I_KONP
*              EXCEPTIONS
*                NO_RECORD_FOUND = 1
*                OTHERS          = 2.
*            IF SY-SUBRC = 0.
** Calcula IVA.
*              IVA = PE_I_KONP-KBETR / 1000.
*              TOTAL_IVA = TOTAL_POS *  IVA.
** Calcula IVA Proporcional
*              SELECT SINGLE IVA_PROP INTO  IVA_PROP
*                      FROM ZFIIVAPRP
*                    WHERE  BUKRS EQ ZINVFO-BUKRS
*                    AND    FEC_INICO <= ZINVFO-BUDAT
*                    AND    FEC_FIN  >= ZINVFO-BUDAT.
*              IF SY-SUBRC EQ 0.
*                IVA_NO_RE = IVA_PROP / 100.
*                TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_NO_RE.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*
*      I_T020-TCODE =  'FB60'.
*      I_T020-KOART =    'K'.
*      I_T020-AKTYP =    'H'.
*      I_T020-DYNCL =    'B'.
*      I_T020-FUNCL =    ' '.
*      I_T020-STATU =    'ENJINV'.
*      I_T020-GENER =    '1'.
*
*      MOVE-CORRESPONDING BKPF TO T_BKPF.
*      APPEND T_BKPF.
*
* Posicion de Acreedor
      MOVE-CORRESPONDING zinvfo TO t_bseg.
      t_bseg-bschl = '31'.
      t_bseg-shkzg = 'S'.
      t_bseg-buzei = '1'.
      t_bseg-koart = 'K'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-wrbtr =  t_bseg-wrbtr +  total_iva.
      t_bseg-dmbtr =  t_bseg-wrbtr.
      t_bseg-kokrs = 'BMSA'.
      APPEND t_bseg.
      CLEAR t_bseg.
*
** Posicion de  cuentas de mayor
      LOOP AT it_t001 WHERE hkont NE space.
*        ADD 1 TO POS.
        MOVE-CORRESPONDING it_t001 TO t_bseg.
*        IF   IT_T001-SHKZG = 'H'.
*          IF TOTAL_POS_H > 0 AND IT_T001-MWSKZ EQ 'C9'.
*            IT_T001-PORCENTAJE  =  ( ( T_BSEG-WRBTR * 100 ) / TOTAL_POS_H ).
*
*            TOT_POR_B1 = IT_T001-PORCENTAJE + TOT_POR_B1.
*            IF TOT_POR_B1 > 100.
*              REST_POR_B1  =  TOT_POR_B1  - 100.
*              IT_T001-PORCENTAJE =  IT_T001-PORCENTAJE - REST_POR_B1.
*              CLEAR: TOT_POR_B1, REST_POR_B1.
*            ENDIF.
*            VALOR_B1        = TOTAL_IVA_NO_RE * IT_T001-PORCENTAJE / 100.
*            T_BSEG-WRBTR =  T_BSEG-WRBTR +  VALOR_B1.
*          ENDIF.
*        ELSE.
*          IF   IT_T001-SHKZG = 'S' AND IT_T001-MWSKZ EQ 'C9'.
*            IF TOTAL_POS_H > 0.
*              IT_T001-PORCENTAJE2  =  ( ( T_BSEG-WRBTR * 100 ) / TOTAL_POS_H ).
*              TOT_POR2_B2 = IT_T001-PORCENTAJE2 + TOT_POR2_B2.
*              IF TOT_POR2_B2 > 100.
*                REST_POR2_B2  =  TOT_POR2_B2  - 100.
*                IT_T001-PORCENTAJE2 =  IT_T001-PORCENTAJE2 - REST_POR2_B2.
*                CLEAR: TOT_POR2_B2, REST_POR2_B2.
*              ENDIF.
*              VALOR2_B2        = TOTAL_IVA_NO_RE * IT_T001-PORCENTAJE2 / 100.
*              T_BSEG-WRBTR =  T_BSEG-WRBTR +  VALOR2_B2.
*            ENDIF.
*          ENDIF.
*        ENDIF.
*
        t_bseg-buzei = pos.
        t_bseg-koart = 'S'.
        t_bseg-pswsl = zinvfo-waers.
        t_bseg-dmbtr =  t_bseg-wrbtr.
        t_bseg-kokrs = 'BMSA'.
        t_bseg-gjahr = zinvfo-gjahr.
        t_bseg-sgtxt = zinvfo-sgtxt.            "Quintec mvm 26.07.2010
        APPEND t_bseg.
        CLEAR t_bseg.
      ENDLOOP.
*
*      IF TOTAL_IVA > 0.
** Pos iva Normal
*        ADD 1 TO POS.
*        T_BSEG-BUKRS = ZINVFO-BUKRS.
*        T_BSEG-BSCHL = '50'.
*        T_BSEG-HKONT = '1013310004'.
*        T_BSEG-SHKZG = 'H'.
*        T_BSEG-BUZEI = POS.
*        T_BSEG-KOART = 'S'.
*        T_BSEG-PSWSL = ZINVFO-WAERS.
*        T_BSEG-DMBTR =  TOTAL_IVA.
*        T_BSEG-WRBTR =  TOTAL_IVA.
*        T_BSEG-KOKRS = 'BMSA'.
*        T_BSEG-GJAHR = ZINVFO-GJAHR.
*        APPEND T_BSEG.
*        CLEAR T_BSEG.
*      ENDIF.
*
** Pos Iva Proporcional
*      IF TOTAL_IVA_NO_RE > 0.
*        ADD 1 TO POS.
*        T_BSEG-BUKRS = ZINVFO-BUKRS.
*        T_BSEG-BSCHL = '40'.
*        T_BSEG-HKONT = '1013310005'.
*        T_BSEG-SHKZG = 'S'.
*        T_BSEG-BUZEI = POS.
*        T_BSEG-KOART = 'S'.
*        T_BSEG-PSWSL = ZINVFO-WAERS.
*        T_BSEG-DMBTR = TOTAL_IVA_NO_RE - VALOR2_B2.
*        T_BSEG-WRBTR = TOTAL_IVA_NO_RE - VALOR2_B2.
*        T_BSEG-KOKRS = 'BMSA'.
*        T_BSEG-GJAHR = ZINVFO-GJAHR.
*        APPEND T_BSEG.
*        CLEAR T_BSEG.
*      ENDIF.
*      LOOP AT T_BSEG.
*        IF T_BSEG-SHKZG EQ 'S'.
*          T_DEBE = T_DEBE + T_BSEG-WRBTR.
*        ELSE.
*          T_HABER = T_HABER + T_BSEG-WRBTR.
*        ENDIF.
*      ENDLOOP.
*
*      T_DIF = T_DEBE - T_HABER.
*
*      LOOP AT T_BSEG WHERE MWSKZ EQ 'C9' and KOART ne 'K' AND WRBTR > 0.
*        AA = SY-TABIX.
*      ENDLOOP.
*
*      READ TABLE T_BSEG INDEX  AA.
*      IF SY-SUBRC EQ 0.
*        IF  T_DIF > 0.
*
*          T_BSEG-WRBTR = T_BSEG-WRBTR +  T_DIF.
*        ELSE.
*          IF  T_DIF < 0.
*            T_BSEG-WRBTR = T_BSEG-WRBTR -  T_DIF.
*          ENDIF.
*        ENDIF.
*        MODIFY T_BSEG INDEX AA.
*
*      ENDIF.



    ENDIF.
*************************************************************+
    REFRESH: t_bseg2.
    CALL FUNCTION 'ZACC_SIMULATED_DOC_DISPLAY'
      EXPORTING
        i_t020     = i_t020
        tip_salida = 'S'
      TABLES
        t_bkpf     = t_bkpf
        t_bseg     = t_bseg
        t_erinf    = t_erinf
        xxbseg     = t_bseg2
        xxbkpf     = t_bkpf2.

*
    CLEAR: total_bseg.
    LOOP AT t_bseg2.
      ADD t_bseg2-wrbtr   TO total_bseg.
    ENDLOOP.

    rf05a-azsal = total_bseg.
    rf05a-ubazw = zinvfo-waers.

    IF total_bseg <  0 OR total_bseg > 0.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          info   = text-e12
          name   = 'ICON_RED_LIGHT'
        IMPORTING
          RESULT = rf05a-ampel.
      MESSAGE s060(f5).
    ENDIF.


    IF total_bseg EQ 0.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          info   = text-e13
          name   = 'ICON_GREEN_LIGHT'
        IMPORTING
          RESULT = rf05a-ampel.
    ENDIF.
  ENDIF.
ENDMODULE.                 " BALANCE_SAL  INPUT
*&---------------------------------------------------------------------*
*&      Form  GRABA_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM graba_doc .
  DATA:
   t_bseg_conta   TYPE bseg OCCURS 1000 WITH HEADER LINE,
   t_bkpf_conta   TYPE bkpf OCCURS 1000 WITH HEADER LINE,
   ti_cabecera    TYPE zcabecera  OCCURS 1000 WITH HEADER LINE,
   ti_detalle     TYPE zdetalle  OCCURS 10000 WITH HEADER LINE,
   ti_tlogcaberr  TYPE  ztlogcaberr OCCURS 10000 WITH HEADER LINE,
   ti_tlogdeterr  TYPE  ztlogdeterr OCCURS 10000 WITH HEADER LINE,
   ti_resumen     TYPE  zresumen OCCURS 10000 WITH HEADER LINE,
   return         TYPE  bapiret2  OCCURS 10000 WITH HEADER LINE.
  DATA: tip_conta(1) TYPE c.

* Definicion de varibles Globales.
  DATA: t_error TYPE sy-subrc.
  DATA: t_waers TYPE waers.

  PERFORM pantalla.

  PERFORM valida_doc TABLES t_bseg_conta
                            t_bkpf_conta
                  CHANGING  t_error.
  IF t_error EQ 0.
    PERFORM gen_cab_doc TABLES  t_bkpf_conta
                                 ti_cabecera
                     CHANGING   t_waers.

    PERFORM gen_det_doc TABLES  t_bseg_conta
                                 ti_detalle
                        USING   t_waers.

    LOOP AT t_bseg_conta.
      IF t_bseg_conta-anln1 NE space.
        tip_conta = '1'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF tip_conta = space.
*      BREAK-POINT.
*      break lsaavedra.
      CALL FUNCTION 'ZFIRFC001'
        TABLES
          ti_cabecera   = ti_cabecera
          ti_detalle    = ti_detalle
          ti_tlogcaberr = ti_tlogcaberr
          ti_tlogdeterr = ti_tlogdeterr
          ti_resumen    = ti_resumen
          return        = return.

      REFRESH i_errores.
      CLEAR:  i_errores, p_error_p.



      IF ti_tlogcaberr[] IS NOT INITIAL.
        LOOP AT ti_tlogcaberr.
          MOVE: 'E' TO i_errores-type,
           ti_tlogcaberr-descripcion TO i_errores-message_v1.
          i_errores-id     = 'Z1'.
          i_errores-number = '011'.
          APPEND i_errores.
          p_error_p = 4.
        ENDLOOP.
      ENDIF.

      IF ti_tlogdeterr[] IS NOT INITIAL.
        LOOP AT ti_tlogdeterr.
          MOVE: 'E' TO i_errores-type,
*          TI_TLOGDETERR-POSIC TO  I_ERRORES-MESSAGE_V1,
          ti_tlogdeterr-descripcion TO i_errores-message_v1.
          i_errores-id     = 'Z1'.
          i_errores-number = '011'.
          APPEND i_errores.
          p_error_p = 4.
        ENDLOOP.
      ENDIF.

      IF return[] IS NOT INITIAL.
        LOOP AT return.
          IF return-type EQ 'S' AND  return-id EQ 'RW' AND return-number EQ 605.
            MOVE:
            return-type          TO i_errores-type,
            return-id            TO i_errores-id,
            return-number        TO i_errores-number,
            return-message+0(48) TO i_errores-message,
            return-message_v2+0(10)  TO i_errores-message_v1.
            APPEND i_errores.
            p_error_p = 0.
            SET PARAMETER ID 'BLN' FIELD return-message_v2+0(10).
          ELSE.
            IF return-type EQ 'E'.
              MOVE-CORRESPONDING return TO i_errores.
              APPEND i_errores.
              IF return-type EQ 'E'.
                p_error_p = 4.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

      PERFORM log_ejecucion  TABLES i_errores
                                  USING p_auto
                                        p_popup
                                        p_titulo.

      IF p_error_p EQ 0.
        LEAVE TO TRANSACTION 'ZFITR006'.
      ENDIF.
    ELSE.
      REFRESH:   i_errores.
      CLEAR:     i_errores.

*      Se lee el archivo plano con los datos de la interfaz
*      PERFORM LEER_ARCH_PLANO.
      juego_datos = 'CARGA'.
      OPEN DATASET juego_datos FOR OUTPUT IN TEXT MODE
                                 ENCODING DEFAULT.
*      Inicializa las estructuras del batch-input con '/' (nodata)
      PERFORM inicializa_jd USING bbseg.
      PERFORM inicializa_jd USING bwith.
      PERFORM inicializa_jd USING bbkpf.
*      Se genera la estructura de datos
      PERFORM crear_juego_datos TABLES t_bkpf_conta
                                       t_bseg_conta.
      CLOSE DATASET juego_datos.
      DATA y_list_tab TYPE TABLE OF abaplist.
*      Se llama al programa estandar que genera el batch input.
*      PERFORM EJECUTA_FB01 USING   JUEGO_DATOS.


      SUBMIT zrfbibl01 WITH ds_name  = juego_datos
      WITH callmode = 'C'
      WITH max_comm = '1000'
      WITH xlog = 'X' AND RETURN.

      IMPORT i_errores  FROM MEMORY ID '001'.

      LOOP AT i_errores WHERE type EQ 'I'.

        IF   i_errores-number EQ '012' OR  i_errores-number EQ '007'
             OR i_errores-number EQ '008'.
          DELETE  i_errores INDEX sy-tabix.
        ELSE.
          i_errores-type = 'S'.
          MODIFY  i_errores INDEX sy-tabix.
        ENDIF.
      ENDLOOP.


      LOOP AT i_errores.

        IF i_errores-id NE 'F5' AND i_errores-number  NE  '312'.
          i_errores-type = 'E'.
          MODIFY  i_errores INDEX sy-tabix.
        ENDIF.

      ENDLOOP.

      READ TABLE i_errores WITH KEY type = 'E'.
      IF sy-subrc  EQ 0.
        p_error_p = 4.
      ELSE.
        p_error_p = 0.
      ENDIF.

      PERFORM log_ejecucion  TABLES i_errores
                                  USING p_auto
                                        p_popup
                                        p_titulo.

      IF p_error_p EQ 0.
        LEAVE TO TRANSACTION 'ZFITR006'.
      ENDIF.
    ENDIF.

  ELSE.
    MESSAGE s060(f5).
  ENDIF.
ENDFORM.                    " GRABA_DOC
*&---------------------------------------------------------------------*
*&      Form  VALIDA_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BSEG_CONTA  text
*      -->P_T_BKPF_CONTA  text
*----------------------------------------------------------------------*
FORM valida_doc  TABLES   t_bseg_conta STRUCTURE bseg
                          t_bkpf_conta STRUCTURE bkpf
                CHANGING  t_error.


  DATA: total_pos LIKE zacgl_item-wrbtr,
        total_pos_s LIKE zacgl_item-wrbtr,
        total_pos_h LIKE zacgl_item-wrbtr,
        total_iva LIKE zacgl_item-wrbtr,
        total_iva_no_re LIKE zacgl_item-wrbtr,
        iva_prop        LIKE konp-kbetr,
        iva            LIKE zacgl_item-wrbtr,
        iva_no_re       LIKE zacgl_item-wrbtr.


  DATA: t_bseg  TYPE bseg OCCURS 100 WITH HEADER LINE,
        t_bseg2  TYPE bseg OCCURS 100 WITH HEADER LINE,
        t_bkpf2  TYPE bkpf OCCURS 100 WITH HEADER LINE,
        t_bkpf  TYPE bkpf OCCURS 100 WITH HEADER LINE,
       t_erinf  TYPE acerrlog OCCURS 100 WITH HEADER LINE.
  DATA: i_t020  LIKE t020.

  DATA: valor TYPE bseg-wrbtr,
         tot_por TYPE bseg-wrbtr,
         rest_por TYPE bseg-wrbtr.
  DATA: valor2 TYPE bseg-wrbtr,
        tot_por2 TYPE bseg-wrbtr,
        rest_por2 TYPE bseg-wrbtr.
  DATA: pe_i_konp TYPE  konp.
  DATA: pos TYPE i VALUE 1.

  DATA:   t_dif TYPE bseg-wrbtr,
          t_debe TYPE bseg-wrbtr,
          t_haber TYPE bseg-wrbtr,
          aa LIKE sy-tabix.



  REFRESH: it_t001.
  CLEAR: it_t001.

  IF rf05a-buscs EQ 'R'.

    LOOP AT   g_table_itab
          INTO g_table_wa WHERE hkont NE space.
      MOVE-CORRESPONDING  g_table_wa TO it_t001.
      APPEND it_t001.
    ENDLOOP.


    CLEAR: total_pos_s.
    LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'S' AND mwskz EQ 'C9'.
      ADD it_t001-wrbtr TO total_pos_s.
      CLEAR: it_t001.
    ENDLOOP.


    CLEAR: total_pos_h.
    LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'H' AND mwskz EQ 'C9'.
      ADD it_t001-wrbtr TO total_pos_h.
      CLEAR: it_t001.
    ENDLOOP.


    total_pos = total_pos_s - total_pos_h.
    IF total_pos > 0.
      CALL FUNCTION 'RE_KTOSL_TO_MWSKZ_GET'
        EXPORTING
          i_mwskz                        = zinvfo-mwskz
          i_bukrs                        = zinvfo-bukrs
        TABLES
          e_a003                         = e_a003
        EXCEPTIONS
          no_mwskz_in_t001land           = 1
          no_ktosl_for_mwskz_in_t001land = 2
          t638s_t007b_inconsistency      = 3
          OTHERS                         = 4.
      IF sy-subrc = 0.
        READ TABLE e_a003 INDEX 1.
        IF sy-subrc EQ 0.

          CALL FUNCTION 'WV_KONP_GET'
            EXPORTING
              pi_knumh        = e_a003-knumh
              pi_kappl        = e_a003-kappl
              pi_kschl        = e_a003-kschl
            IMPORTING
              pe_i_konp       = pe_i_konp
            EXCEPTIONS
              no_record_found = 1
              OTHERS          = 2.
          IF sy-subrc = 0.
* Calcula IVA.
            iva = pe_i_konp-kbetr / 1000.
            total_iva = total_pos *  iva.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE iva_prop INTO  iva_prop
*                FROM zfiivaprp
*              WHERE  bukrs EQ zinvfo-bukrs
*              AND    fec_inico <= zinvfo-budat
*              AND    fec_fin  >= zinvfo-budat.
*
* NEW CODE
            SELECT iva_prop
            UP TO 1 ROWS  INTO  iva_prop
                FROM zfiivaprp
              WHERE  bukrs EQ zinvfo-bukrs
              AND    fec_inico <= zinvfo-budat
              AND    fec_fin  >= zinvfo-budat ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc EQ 0.
*              IVA_NO_RE = IVA_PROP / 100.
*              TOTAL_IVA_NO_RE = TOTAL_IVA * IVA_NO_RE.
              total_iva_no_re = total_iva * iva_prop / 100.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    i_t020-tcode =  'FB60'.
    i_t020-koart =    'K'.
    i_t020-aktyp =    'H'.
    i_t020-dyncl =    'B'.
    i_t020-funcl =    ' '.
    i_t020-statu =    'ENJINV'.
    i_t020-gener =    '1'.


    MOVE-CORRESPONDING bkpf TO t_bkpf.
    APPEND t_bkpf.
* Posicion de Acreedor
    MOVE-CORRESPONDING zinvfo TO t_bseg.
    t_bseg-bschl = '31'.
    t_bseg-shkzg = 'H'.
    t_bseg-buzei = '1'.
    t_bseg-koart = 'K'.
    t_bseg-pswsl = zinvfo-waers.
    t_bseg-wrbtr =  t_bseg-wrbtr +  total_iva.
    t_bseg-dmbtr =  t_bseg-wrbtr.
    t_bseg-kokrs = 'BMSA'.
    APPEND t_bseg.
    CLEAR t_bseg.

* Posicion de  cuentas de mayor
    LOOP AT it_t001 WHERE hkont NE space.
      ADD 1 TO pos.
      MOVE-CORRESPONDING it_t001 TO t_bseg.
      IF   it_t001-shkzg = 'S'.
        IF total_pos_s > 0 AND it_t001-mwskz EQ 'C9'.
          it_t001-porcentaje  =  ( ( t_bseg-wrbtr * 100 ) / total_pos_s ).

          tot_por = it_t001-porcentaje + tot_por.
          IF tot_por > 100.
            rest_por  =  tot_por  - 100.
            it_t001-porcentaje =  it_t001-porcentaje - rest_por.
            CLEAR: tot_por, rest_por.
          ENDIF.

          IF tot_por = '99.99'.
            rest_por  =  100 - tot_por.  ""
            it_t001-porcentaje =  it_t001-porcentaje + rest_por.
            CLEAR: tot_por, rest_por.
          ENDIF.


          valor        = total_iva_no_re * it_t001-porcentaje / 100.
          t_bseg-wrbtr =  t_bseg-wrbtr +  valor.
        ENDIF.
      ELSE.
        IF   it_t001-shkzg = 'H' AND it_t001-mwskz EQ 'C9'.
          IF total_pos_s > 0.
            it_t001-porcentaje2  =  ( ( t_bseg-wrbtr * 100 ) / total_pos_s ).
            tot_por2 = it_t001-porcentaje2 + tot_por2.
            IF tot_por2 > 100.
              rest_por2  =  tot_por2  - 100.
              it_t001-porcentaje2 =  it_t001-porcentaje2 - rest_por2.
              CLEAR: tot_por, rest_por2.
            ENDIF.

            IF tot_por2 = '99.99'.
              rest_por2  =  100 - tot_por.  ""
              it_t001-porcentaje2 =  it_t001-porcentaje2 + rest_por2.
              CLEAR: tot_por2, rest_por2.
            ENDIF.


            valor2        = total_iva_no_re * it_t001-porcentaje2 / 100.
            t_bseg-wrbtr =  t_bseg-wrbtr +  valor2.
          ENDIF.
        ENDIF.
      ENDIF.

      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-dmbtr =  t_bseg-wrbtr.
      t_bseg-gjahr = zinvfo-gjahr.
      t_bseg-sgtxt = zinvfo-sgtxt.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDLOOP.

    IF total_iva > 0.
* Pos iva Normal
      ADD 1 TO pos.
      t_bseg-bukrs = zinvfo-bukrs.
      t_bseg-bschl = '40'.
      t_bseg-hkont = '1013310004'.
      t_bseg-shkzg = 'S'.
      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-dmbtr =  total_iva.
      t_bseg-wrbtr =  total_iva.
      t_bseg-kokrs = 'BMSA'.
      t_bseg-gjahr = zinvfo-gjahr.
      t_bseg-mwskz = zinvfo-mwskz.
      t_bseg-kontt = 'X'.
*      t_bseg-sgtxt = 'IVA Credito Fiscal'.
*      BREAK-POINT.
      t_bseg-sgtxt = zinvfo-sgtxt.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDIF.

* Pos Iva Proporcional
    IF total_iva_no_re > 0.
      ADD 1 TO pos.
      t_bseg-bukrs = zinvfo-bukrs.
      t_bseg-bschl = '50'.
      t_bseg-hkont = '1013310005'.
      t_bseg-shkzg = 'H'.
      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-wrbtr = total_iva_no_re - valor2.
      t_bseg-dmbtr = t_bseg-wrbtr.
      t_bseg-kokrs = 'BMSA'.
*      t_bseg-sgtxt = 'IVA Proporcional'.
      t_bseg-sgtxt = zinvfo-sgtxt.
      t_bseg-gjahr = zinvfo-gjahr.
*      T_BSEG-MWSKZ = ZINVFO-MWSKZ.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDIF.

    LOOP AT t_bseg.
      IF t_bseg-shkzg EQ 'S'.
        t_debe = t_debe + t_bseg-wrbtr.
      ELSE.
        t_haber = t_haber + t_bseg-wrbtr.
      ENDIF.
    ENDLOOP.

    t_dif = t_debe - t_haber.

    LOOP AT t_bseg WHERE mwskz EQ 'C9'.
      aa = sy-tabix.
    ENDLOOP.

    READ TABLE t_bseg INDEX  aa.
    IF sy-subrc EQ 0.
      IF  t_dif > 0.
        IF t_bseg-shkzg = 'H'.
          t_bseg-wrbtr = t_bseg-wrbtr -  t_dif.  "Valor al haber esta en negativo, se le suma la diferencia positiva.
        ELSE.
          t_bseg-wrbtr = t_bseg-wrbtr -  t_dif.  "Valor al debe esta en positivo, se le resta la diferencia positiva.
        ENDIF.
      ELSE.
        IF  t_dif < 0.
          IF t_bseg-shkzg = 'H'.
            t_bseg-wrbtr = t_bseg-wrbtr -  t_dif. "Valor al haber esta negativo, se le resta la diferencia negativa.
          ELSE.
            t_bseg-wrbtr = t_bseg-wrbtr -  t_dif. "Valor al debe esta positivo, se le suma la diferencia negativa.
          ENDIF.
        ENDIF.
      ENDIF.
      MODIFY t_bseg INDEX aa.

    ENDIF.

    LOOP  AT t_bseg.
      IF   t_bseg-mwskz EQ zinvfo-mwskz.
        t_bseg-mwskz = zinvfo-mwskz.
        MODIFY t_bseg INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.
**************************************************************************
  IF rf05a-buscs EQ 'G'.
    LOOP AT   g_table_itab
          INTO g_table_wa WHERE hkont NE space.
      MOVE-CORRESPONDING  g_table_wa TO it_t001.
      APPEND it_t001.
    ENDLOOP.


    CLEAR: total_pos_s.
    LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'S' AND mwskz EQ 'C9'.
      ADD it_t001-wrbtr TO total_pos_s.
      CLEAR: it_t001.
    ENDLOOP.


    CLEAR: total_pos_h.
    LOOP AT it_t001 WHERE hkont NE space AND  shkzg EQ 'H' AND mwskz EQ 'C9'.
      ADD it_t001-wrbtr TO total_pos_h.
      CLEAR: it_t001.
    ENDLOOP.


    total_pos =  total_pos_h - total_pos_s.
    IF total_pos > 0.
      CALL FUNCTION 'RE_KTOSL_TO_MWSKZ_GET'
        EXPORTING
          i_mwskz                        = zinvfo-mwskz
          i_bukrs                        = zinvfo-bukrs
        TABLES
          e_a003                         = e_a003
        EXCEPTIONS
          no_mwskz_in_t001land           = 1
          no_ktosl_for_mwskz_in_t001land = 2
          t638s_t007b_inconsistency      = 3
          OTHERS                         = 4.
      IF sy-subrc = 0.
        READ TABLE e_a003 INDEX 1.
        IF sy-subrc EQ 0.

          CALL FUNCTION 'WV_KONP_GET'
            EXPORTING
              pi_knumh        = e_a003-knumh
              pi_kappl        = e_a003-kappl
              pi_kschl        = e_a003-kschl
            IMPORTING
              pe_i_konp       = pe_i_konp
            EXCEPTIONS
              no_record_found = 1
              OTHERS          = 2.
          IF sy-subrc = 0.
* Calcula IVA.
            iva = pe_i_konp-kbetr / 1000.
            total_iva = total_pos *  iva.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE iva_prop INTO  iva_prop
*                FROM zfiivaprp
*              WHERE  bukrs EQ zinvfo-bukrs
*              AND    fec_inico <= zinvfo-budat
*              AND    fec_fin  >= zinvfo-budat.
*
* NEW CODE
            SELECT iva_prop
            UP TO 1 ROWS  INTO  iva_prop
                FROM zfiivaprp
              WHERE  bukrs EQ zinvfo-bukrs
              AND    fec_inico <= zinvfo-budat
              AND    fec_fin  >= zinvfo-budat ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc EQ 0.
              total_iva_no_re = total_iva * iva_prop / 100.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    i_t020-tcode =  'FB60'.
    i_t020-koart =    'K'.
    i_t020-aktyp =    'H'.
    i_t020-dyncl =    'B'.
    i_t020-funcl =    ' '.
    i_t020-statu =    'ENJINV'.
    i_t020-gener =    '1'.


    MOVE-CORRESPONDING bkpf TO t_bkpf.
    APPEND t_bkpf.
* Posicion de Acreedor
    MOVE-CORRESPONDING zinvfo TO t_bseg.
    t_bseg-bschl = '31'.
    t_bseg-shkzg = 'S'.
    t_bseg-buzei = '1'.
    t_bseg-koart = 'K'.
    t_bseg-pswsl = zinvfo-waers.
    t_bseg-wrbtr =  t_bseg-wrbtr +  total_iva.
    t_bseg-dmbtr =  t_bseg-wrbtr.
    t_bseg-kokrs = 'BMSA'.
    APPEND t_bseg.
    CLEAR t_bseg.

* Posicion de  cuentas de mayor

    LOOP AT it_t001 WHERE hkont NE space.
      ADD 1 TO pos.
      MOVE-CORRESPONDING it_t001 TO t_bseg.
      IF   it_t001-shkzg = 'H'.
        IF total_pos_h > 0 AND it_t001-mwskz EQ 'C9'.
          it_t001-porcentaje  =  ( ( t_bseg-wrbtr * 100 ) / total_pos_h ).

          tot_por = it_t001-porcentaje + tot_por.
          IF tot_por > 100.
            rest_por  =  tot_por  - 100.
            it_t001-porcentaje =  it_t001-porcentaje - rest_por.
            CLEAR: tot_por, rest_por.
          ENDIF.

          IF tot_por = '99.99'.
            rest_por  =  100 - tot_por.  ""
            it_t001-porcentaje =  it_t001-porcentaje + rest_por.
            CLEAR: tot_por, rest_por.
          ENDIF.


          valor        = total_iva_no_re * it_t001-porcentaje / 100.
          t_bseg-wrbtr =  t_bseg-wrbtr +  valor.
        ENDIF.
      ELSE.
        IF   it_t001-shkzg = 'S' AND it_t001-mwskz EQ 'C9'.
          IF total_pos_s > 0.
            it_t001-porcentaje2  =  ( ( t_bseg-wrbtr * 100 ) / total_pos_h ).
            tot_por2 = it_t001-porcentaje2 + tot_por2.
            IF tot_por2 > 100.
              rest_por2  =  tot_por2  - 100.
              it_t001-porcentaje2 =  it_t001-porcentaje2 - rest_por2.
              CLEAR: tot_por, rest_por2.
            ENDIF.

            IF tot_por2 = '99.99'.
              rest_por2  =  100 - tot_por.  ""
              it_t001-porcentaje2 =  it_t001-porcentaje2 + rest_por2.
              CLEAR: tot_por2, rest_por2.
            ENDIF.

            valor2        = total_iva_no_re * it_t001-porcentaje2 / 100.
            t_bseg-wrbtr =  t_bseg-wrbtr +  valor2.
          ENDIF.
        ENDIF.
      ENDIF.

      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-dmbtr = t_bseg-wrbtr.
      t_bseg-gjahr = zinvfo-gjahr.
      t_bseg-sgtxt = zinvfo-sgtxt.            "Quintec mvm 26.07.2010
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDLOOP.

    IF total_iva > 0.
* Pos iva Normal
      ADD 1 TO pos.
      t_bseg-bukrs = zinvfo-bukrs.
      t_bseg-bschl = '50'.
      t_bseg-hkont = '1013310004'.
      t_bseg-shkzg = 'H'.
      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-dmbtr =  total_iva.
      t_bseg-wrbtr =  total_iva.
      t_bseg-kokrs = 'BMSA'.
      t_bseg-gjahr = zinvfo-gjahr.
      t_bseg-mwskz = zinvfo-mwskz.
      t_bseg-kontt = 'X'.
*      t_bseg-sgtxt = 'IVA Credito Fiscal'.
      t_bseg-sgtxt = zinvfo-sgtxt.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDIF.

* Pos Iva Proporcional
    IF total_iva_no_re > 0.
      ADD 1 TO pos.
      t_bseg-bukrs = zinvfo-bukrs.
      t_bseg-bschl = '00'.
      t_bseg-hkont = '1013310005'.
      t_bseg-shkzg = 'S'.
      t_bseg-buzei = pos.
      t_bseg-koart = 'S'.
      t_bseg-pswsl = zinvfo-waers.
      t_bseg-wrbtr = total_iva_no_re - valor2.
      t_bseg-dmbtr = t_bseg-wrbtr.
      t_bseg-kokrs = 'BMSA'.
*      t_bseg-sgtxt = 'IVA Proporcional'.
      t_bseg-sgtxt = zinvfo-sgtxt.
      t_bseg-gjahr = zinvfo-gjahr.
*      T_BSEG-MWSKZ = ZINVFO-MWSKZ.
      APPEND t_bseg.
      CLEAR t_bseg.
    ENDIF.

    LOOP AT t_bseg.
      IF t_bseg-shkzg EQ 'S'.
        t_debe = t_debe + t_bseg-wrbtr.
      ELSE.
        t_haber = t_haber + t_bseg-wrbtr.
      ENDIF.
    ENDLOOP.

    t_dif = t_debe - t_haber.

    LOOP AT t_bseg WHERE mwskz EQ 'C9'.

      IF t_bseg-shkzg EQ 'S'.
        aa = sy-tabix.
      ENDIF.
    ENDLOOP.

    READ TABLE t_bseg INDEX  aa.

    IF sy-subrc EQ 0.
      IF  t_dif > 0.
        IF t_bseg-shkzg = 'H'.
          t_bseg-wrbtr = t_bseg-wrbtr -  t_dif.   "Valor al haber esta en negativo, se le suma la diferencia positiva.
        ELSE.
          t_bseg-wrbtr = t_bseg-wrbtr -  t_dif.   "Valor al debe esta en positivo, se le resta la diferencia positiva.
        ENDIF.
      ELSE.
        IF  t_dif < 0.
          IF t_bseg-shkzg = 'H'.
            t_bseg-wrbtr = t_bseg-wrbtr -  t_dif. "Valor al haber esta negativo, se le resta la diferencia negativa.
          ELSE.
            t_bseg-wrbtr = t_bseg-wrbtr -  t_dif. "Valor al debe esta positivo, se le suma la diferencia negativa.
          ENDIF.
        ENDIF.
      ENDIF.
      MODIFY t_bseg INDEX aa.

    ENDIF.

    LOOP  AT t_bseg.
      IF   t_bseg-mwskz EQ zinvfo-mwskz.
        t_bseg-mwskz = zinvfo-mwskz.
        MODIFY t_bseg INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

  ENDIF.


  CALL FUNCTION 'ZACC_SIMULATED_DOC_DISPLAY'
    EXPORTING
      i_t020     = i_t020
      tip_salida = 'S'
    TABLES
      t_bkpf     = t_bkpf
      t_bseg     = t_bseg
      t_erinf    = t_erinf
      xxbseg     = t_bseg_conta
      xxbkpf     = t_bkpf_conta.


  DATA: total_bseg_conta LIKE zacgl_item-wrbtr.
  LOOP AT t_bseg_conta.
    ADD t_bseg_conta-wrbtr   TO total_bseg_conta.
  ENDLOOP.

  rf05a-azsal = total_bseg_conta.
  rf05a-ubazw = zinvfo-waers.

  IF t_bseg_conta[] IS INITIAL.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        info   = text-e14
        name   = 'ICON_YELLOW_LIGHT'
      IMPORTING
        RESULT = rf05a-ampel.
    t_error = 4.
  ENDIF.

  IF total_bseg_conta <  0 OR total_bseg_conta > 0.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        info   = text-e12
        name   = 'ICON_RED_LIGHT'
      IMPORTING
        RESULT = rf05a-ampel.
    t_error = 4.
  ENDIF.
  IF total_bseg_conta EQ 0.
    CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        info   = text-e13
        name   = 'ICON_GREEN_LIGHT'
      IMPORTING
        RESULT = rf05a-ampel.
    t_error = 0.
  ENDIF.
ENDFORM.                    " VALIDA_DOC
*&---------------------------------------------------------------------*
*&      Form  GEN_CAB_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BKPF_CONTA  text
*      -->P_TI_CABECERA  text
*----------------------------------------------------------------------*
FORM gen_cab_doc  TABLES   p_t_bkpf_conta STRUCTURE bkpf
                           p_ti_cabecera STRUCTURE zcabecera
                           CHANGING   t_waers.


  LOOP AT   p_t_bkpf_conta.
    SELECT SINGLE tsad4~prefix_key
      INTO p_ti_cabecera-area_contab
      FROM usr21 INNER JOIN adrp ON ( usr21~persnumber = adrp~persnumber )
                 INNER JOIN tsad4 ON ( adrp~prefix2 = tsad4~prefix_key )
      WHERE usr21~bname = sy-uname.

    MOVE:
        '1'                      TO p_ti_cabecera-key,
    sy-uname                     TO p_ti_cabecera-username,
    p_t_bkpf_conta-bktxt         TO p_ti_cabecera-header_txt,
    p_t_bkpf_conta-bukrs         TO p_ti_cabecera-comp_code,
    p_t_bkpf_conta-bldat         TO p_ti_cabecera-doc_date,
    p_t_bkpf_conta-budat         TO p_ti_cabecera-pstng_date,
    p_t_bkpf_conta-gjahr         TO p_ti_cabecera-fisc_year,
    p_t_bkpf_conta-monat         TO p_ti_cabecera-fis_period,
    p_t_bkpf_conta-blart         TO p_ti_cabecera-doc_type,
    p_t_bkpf_conta-xblnr         TO p_ti_cabecera-ref_doc_no,
    p_t_bkpf_conta-belnr         TO p_ti_cabecera-ac_doc_no,
    p_t_bkpf_conta-waers         TO t_waers.
    APPEND p_ti_cabecera.
  ENDLOOP.

ENDFORM.                    " GEN_CAB_DOC
*&---------------------------------------------------------------------*
*&      Form  GEN_DET_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_BSEG_CONTA  text
*      -->P_TI_DETALLE  text
*----------------------------------------------------------------------*
FORM gen_det_doc  TABLES   p_t_bseg_conta STRUCTURE bseg
                           p_ti_detalle   STRUCTURE zdetalle
                           USING   t_waers.

  LOOP AT p_t_bseg_conta.

    p_t_bseg_conta-wrbtr = p_t_bseg_conta-wrbtr * 100.
    MOVE:   '1'  TO p_ti_detalle-key,
            p_t_bseg_conta-buzei  TO p_ti_detalle-itemno_acc,
            p_t_bseg_conta-lifnr  TO p_ti_detalle-vendor_no,
            p_t_bseg_conta-hkont  TO p_ti_detalle-hkont,
            p_t_bseg_conta-sgtxt  TO p_ti_detalle-sgtxt,
            p_t_bseg_conta-mwskz  TO p_ti_detalle-tax_code,
            p_t_bseg_conta-kostl  TO p_ti_detalle-costcenter,
            p_t_bseg_conta-prctr  TO p_ti_detalle-profit_ctr,
            p_t_bseg_conta-zterm  TO p_ti_detalle-pmnttrms,
            p_t_bseg_conta-zfbdt  TO p_ti_detalle-bline_date,
            p_t_bseg_conta-zlsch  TO p_ti_detalle-pymt_meth,
            p_t_bseg_conta-zlspr  TO p_ti_detalle-pmnt_block,
            p_t_bseg_conta-zuonr  TO p_ti_detalle-alloc_nmbr,
            p_t_bseg_conta-xref1  TO p_ti_detalle-ref_key_1,
            p_t_bseg_conta-xref2  TO p_ti_detalle-ref_key_2,
            p_t_bseg_conta-xref3  TO p_ti_detalle-ref_key_3,
            p_t_bseg_conta-wrbtr  TO p_ti_detalle-amt_doccur,
            p_t_bseg_conta-fwbas  TO p_ti_detalle-amt_base,
            p_t_bseg_conta-zzprestac  TO p_ti_detalle-zzprestac,
            p_t_bseg_conta-zzunid_pro  TO p_ti_detalle-zzunid_pro,
            p_t_bseg_conta-zzdesc_est  TO p_ti_detalle-zzdesc_est,
            p_t_bseg_conta-zzmot_emis  TO p_ti_detalle-zzmot_emis,
            p_t_bseg_conta-zzrut_terc  TO p_ti_detalle-zzrut_terc,
            p_t_bseg_conta-zz_agencia  TO p_ti_detalle-zz_agencia,
            p_t_bseg_conta-fdlev  TO p_ti_detalle-fdlev,
            p_t_bseg_conta-empfb  TO p_ti_detalle-alt_payee,
            t_waers               TO p_ti_detalle-currency,
            p_t_bseg_conta-kontt  TO p_ti_detalle-iva,
            p_t_bseg_conta-hbkid  TO p_ti_detalle-bank_id,
            p_t_bseg_conta-hktid  TO p_ti_detalle-hktid,
            p_t_bseg_conta-aufnr  TO p_ti_detalle-aufnr.
    APPEND p_ti_detalle.
  ENDLOOP.
ENDFORM.                    " GEN_DET_DOC
*&---------------------------------------------------------------------*
*&      Form  popup_log_errores_bapiret2
*&---------------------------------------------------------------------*
*       En el caso de que tengamos un programa que recoja errores en una
*  tabla interna de tipo BAPIRET2 este perform mostraría el log completo
*  con funcionalidad estandar de SAP para errores.
*----------------------------------------------------------------------*
*      -->P_ERRORES  Tabla con los errores de tipo BAPIRET2
*      -->P_AUTO     Con 'X' si la tabla esta vacia no la muestra, si
*                    solo tiene un mensaje muestra el mensaje y si tiene
*                    más de uno muestra el log. Con ' ' sólo mostraria
*                    el popup tenga lo que tenga.
*      -->P_POPUP    Con 'X' el log se lanza embebido en un POPUP
*      -->P_TITULO   Cabecera del popup
*----------------------------------------------------------------------*
FORM log_ejecucion                                          "#EC CALLED
                                 TABLES i_errores STRUCTURE bapiret2
                                  USING p_auto              "#EC *
                                        p_popup             "#EC *
                                        p_titulo.           "#EC *

  DATA i_log_handle TYPE balloghndl.
  DATA l_bal_s_log TYPE bal_s_log.
  DATA i_bal_s_msg TYPE bal_s_msg.

  DESCRIBE TABLE i_errores LINES sy-index.

  IF NOT p_auto IS INITIAL
  AND sy-index IS INITIAL.

  ELSEIF NOT p_auto IS INITIAL
         AND sy-index = 1.
    READ TABLE i_errores INDEX 1.
    MESSAGE ID i_errores-id
          TYPE i_errores-type
        NUMBER i_errores-number
          WITH i_errores-message_v1
               i_errores-message_v2
               i_errores-message_v3
               i_errores-message_v4.
  ELSE.
    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = l_bal_s_log
      IMPORTING
        e_log_handle            = i_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    LOOP AT i_errores.
      i_bal_s_msg-msgty = i_errores-type.
      i_bal_s_msg-msgid = i_errores-id.
      i_bal_s_msg-msgno = i_errores-number.
      i_bal_s_msg-msgv1 = i_errores-message_v1.
      i_bal_s_msg-msgv2 = i_errores-message_v2.
      i_bal_s_msg-msgv3 = i_errores-message_v3.
      i_bal_s_msg-msgv4 = i_errores-message_v4.
      i_bal_s_msg-msgv1_src = '3'.
      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle              = i_log_handle
          i_s_msg                   = i_bal_s_msg
*       IMPORTING
*         E_S_MSG_HANDLE            =
*         E_MSG_WAS_LOGGED          =
*         E_MSG_WAS_DISPLAYED       =
       EXCEPTIONS
         log_not_found             = 1
         msg_inconsistent          = 2
         log_is_full               = 3
         OTHERS                    = 4
                .
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDLOOP.

    DATA i_bal_s_prof TYPE bal_s_prof.

    CALL FUNCTION 'BAL_DSP_PROFILE_NO_TREE_GET'
      IMPORTING
        e_s_display_profile = i_bal_s_prof.

    i_bal_s_prof-disvariant-report = sy-repid.
    i_bal_s_prof-use_grid = 'X'.
    i_bal_s_prof-title = p_titulo.

    IF NOT p_popup IS INITIAL.
      i_bal_s_prof-start_col = 10.
      i_bal_s_prof-start_row = 2.
      i_bal_s_prof-end_col   = 100.
      i_bal_s_prof-end_row   = 15.
      i_bal_s_prof-pop_adjst = 'X'.
    ENDIF.

    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile          = i_bal_s_prof
*       i_t_log_handle               = t_log_handle[]
*       I_T_MSG_HANDLE               =
*       I_S_LOG_FILTER               =
*       I_S_MSG_FILTER               =
*       I_T_LOG_CONTEXT_FILTER       =
*       I_T_MSG_CONTEXT_FILTER       =
        i_amodal                     = 'X'
*     IMPORTING
*       E_S_EXIT_COMMAND             =
      EXCEPTIONS
        profile_inconsistent         = 1
        internal_error               = 2
        no_data_available            = 3
        no_authority                 = 4
        OTHERS                       = 5
              .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'BAL_LOG_REFRESH'
      EXPORTING
        i_log_handle  = i_log_handle
      EXCEPTIONS
        log_not_found = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

  ENDIF.

ENDFORM.                    " popups_log_errores_bapiret2
*&---------------------------------------------------------------------*
*&      Module  F4_SGTXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_sgtxt INPUT.
  PERFORM f4_sgtxt USING zacgl_item_tbctr-sgtxt.
ENDMODULE.                 " F4_SGTXT  INPUT
*&---------------------------------------------------------------------*
*&      Form  F4_SGTXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ZACGL_ITEM_TBCTR_SGTXT  text
*----------------------------------------------------------------------*
FORM f4_sgtxt  USING    zacgl_item_tbctr-sgtxt.
  TABLES: rfcu3.
  DATA:   help_sgtxt LIKE bseg-sgtxt.

*------- Feld BSEG-SGTXT Eingabe- oder Anzeigefeld? --------------------
  rfcu3-xshow = space.
  LOOP AT SCREEN.
    CHECK screen-name = 'ZACGL_ITEM_TBCTR-SGTXT'.
    IF screen-input = 0.
      rfcu3-xshow = 'X'.
    ENDIF.
    EXIT.
  ENDLOOP.

*------- Werte aus T053 ( + Sondereinträge) anzeigen -------------------
  CALL FUNCTION 'F_VALUES_SGTXT'
    EXPORTING
      i_xshow          = rfcu3-xshow
    IMPORTING
      e_sgtxt          = help_sgtxt
    EXCEPTIONS
      nothing_selected = 1.
  CHECK sy-subrc = 0.
  zacgl_item_tbctr-sgtxt = help_sgtxt.
ENDFORM.                                                    " F4_SGTXT
*&---------------------------------------------------------------------*
*&      Form  PANTALLA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pantalla .

ENDFORM.                    " PANTALLA
*&---------------------------------------------------------------------*
*&      Module  SET_PANTALLA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_pantalla INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.
    IF pantalla1 EQ space.
      g_t_001-pressed_tab = 'T_001_FC2'.
      pantalla1 = 'X'.
    ENDIF.
  ENDIF.
ENDMODULE.                 " SET_PANTALLA  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_PANTALLA2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_pantalla2 INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.
    IF pantalla2 EQ space.
      g_t_001-pressed_tab = 'T_001_FC3'.

      pantalla2 = 'X'.

    ENDIF.
  ENDIF.
ENDMODULE.                 " SET_PANTALLA2  INPUT
*&---------------------------------------------------------------------*
*&      Module  SET_PANTALLA3  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_pantalla3 INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.
    IF pantalla3 EQ space.
      g_t_001-pressed_tab = 'T_001_FC1'.
      pantalla3 = 'X'.
    ENDIF.
  ENDIF.
ENDMODULE.                 " SET_PANTALLA3  INPUT
*&---------------------------------------------------------------------*
*&      Module  INVOICE_REFERENCE  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE invoice_reference INPUT.
  IF sy-ucomm NE 'BACK'
   AND sy-ucomm NE 'CANCEL'
   AND sy-ucomm NE 'EXIT'
   AND sy-ucomm NE 'SOC_01'
    AND sy-ucomm NE 'B03'
    AND sy-ucomm NE 'EBR2'.
    IF zinvfo-rebzg NE space AND zinvfo-rebzz EQ space AND  zinvfo-rebzj EQ space.
      PERFORM invoice_reference.
    ENDIF.
  ENDIF.
ENDMODULE.                 " INVOICE_REFERENCE  INPUT
*&---------------------------------------------------------------------*
*&      Form  INVOICE_REFERENCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM invoice_reference .
  REFRESH: lt_bseg, lt_bkpf.
  CLEAR  : mbkpf,  lt_bseg, lt_bkpf.
  CALL FUNCTION 'READ_DOCUMENT_HEADER'
    EXPORTING
      belnr  = zinvfo-rebzg
      bukrs  = zinvfo-bukrs
      gjahr  = zinvfo-gjahr             " can be = '0000'
    IMPORTING
      e_bkpf = mbkpf
    EXCEPTIONS
      OTHERS = 4.
  IF sy-subrc NE 0.
    MESSAGE e346.
  ELSE.
    APPEND mbkpf TO lt_bkpf.

SELECT * FROM bseg INTO TABLE lt_bseg
WHERE bukrs = mbkpf-bukrs
AND belnr = mbkpf-belnr
AND gjahr = mbkpf-gjahr
AND koart = koart
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
*AND lifnr = zinvfo-lifnr.
AND LIFNR = ZINVFO-LIFNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 23/12/2019 EY_DES02 ECDK917080 *
    IF sy-subrc  NE 0.
      MESSAGE e347 WITH zinvfo-rebzg.
    ELSE.
*
      READ TABLE lt_bseg INDEX 1 INTO mbseg.
      IF sy-subrc EQ 0.
        zinvfo-hbkid = mbseg-hbkid.
        zinvfo-bvtyp = mbseg-bvtyp.
        zinvfo-zlsch = mbseg-zlsch.
        zinvfo-uzawe = mbseg-uzawe.
        zinvfo-dtws1 = mbseg-dtws1.
        zinvfo-dtws2 = mbseg-dtws2.
        zinvfo-dtws3 = mbseg-dtws3.
        zinvfo-dtws4 = mbseg-dtws4.
        zinvfo-empfb = mbseg-empfb.
        zinvfo-kidno = mbseg-kidno.
        zinvfo-zlspr = mbseg-zlspr.
        zinvfo-diekz = mbseg-diekz.
        zinvfo-lzbkz = mbseg-lzbkz.
        zinvfo-landl = mbseg-landl.
        zinvfo-zollt = mbseg-zollt.
        zinvfo-zolld = mbseg-zolld.
        zinvfo-maber = mbseg-maber.
        zinvfo-rebzz = mbseg-buzei.
        zinvfo-cession_kz = mbseg-cession_kz.
        IF mbseg-zuonr NE space.
          zinvfo-zuonr = mbseg-zuonr.
        ENDIF.
        IF zinvfo-xzahl = space.
          zinvfo-zfbdt = mbseg-zfbdt.
          zinvfo-zterm = mbseg-zterm.
          zinvfo-zbd1t = mbseg-zbd1t.
          zinvfo-zbd2t = mbseg-zbd2t.
          zinvfo-zbd3t = mbseg-zbd3t.
          zinvfo-zbd1p = mbseg-zbd1p.
          zinvfo-zbd2p = mbseg-zbd2p.
        ENDIF.
        zinvfo-rebzz = mbseg-buzei.
        zinvfo-rebzj = mbkpf-gjahr.
        IF zinvfo-bktxt EQ space.
          zinvfo-bktxt = mbkpf-bktxt.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.
ENDFORM.                    " INVOICE_REFERENCE
*&---------------------------------------------------------------------*
*&      Module  LIMPIA_OBJET  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE limpia_objet INPUT.
  IF sy-ucomm NE 'BACK'
AND sy-ucomm NE 'CANCEL'
  AND sy-ucomm NE 'EXIT'
  AND sy-ucomm NE 'SOC_01'
   AND sy-ucomm NE 'B03'
   AND sy-ucomm NE 'EBR2'.

    IF g_table_wa-hkont IS NOT INITIAL.
*ReSQ: No Need Of Change Internal Table G_TABLE_ITAB Already Sorted
      READ TABLE g_table_itab INDEX table-current_line
   INTO g_table_wa.



      CLEAR: faus1, faus2, faus, zstatus_campo.
      REFRESH zstatus_campo.
      CALL FUNCTION 'FI_FIELD_SELECTION_DETERMINE'
        EXPORTING
          i_bukrs = g_table_wa-bukrs
          i_saknr = g_table_wa-hkont
          i_bschl = g_table_wa-bschl
        IMPORTING
          e_faus1 = faus1
          e_faus2 = faus2.
      faus = faus1.
      faus+90(50) = faus2.
      CALL FUNCTION 'ZREPARE_FIELD_SELECT_STRING'
        EXPORTING
          incoming_string = faus
          string_id       = 'SKB1-FAUS1 '
          text1           = text1
          text2           = fsttx
          xnodisp         = 'X'
          xchange         = space
        TABLES
          zstatus_campo   = zstatus_campo.
      IF zstatus_campo[] IS NOT INITIAL.
        LOOP AT SCREEN.
          READ TABLE zstatus_campo WITH  KEY feldn = screen-name+17(10).
          IF sy-subrc EQ 0.
            IF zstatus_campo-xnodi EQ 'X'.
              CASE screen-name+17(10).

                WHEN 'VALUT'.
                  CLEAR: g_table_wa-valut.
                WHEN 'ZUONR'.
                  CLEAR: g_table_wa-zuonr.
                WHEN 'SGTXT'.
                  CLEAR: g_table_wa-sgtxt.
                WHEN 'KOSTL'.
                  CLEAR: g_table_wa-kostl.
                WHEN 'AUFNR'.
                  CLEAR: g_table_wa-aufnr.
                WHEN 'PRCTR'.
                  CLEAR: g_table_wa-prctr.
                WHEN 'ZZPRESTAC'.
                  CLEAR: g_table_wa-zzprestac.
                WHEN 'ZZUNID_PRO'.
                  CLEAR: g_table_wa-zzunid_pro.
                WHEN 'ZZDESC_EST'.
                  CLEAR: g_table_wa-zzdesc_est.
                WHEN 'ZZMOT_EMIS'.
                  CLEAR: g_table_wa-zzmot_emis.
                WHEN 'ZZRUT_TERC'.
                  CLEAR: g_table_wa-zzrut_terc.
                WHEN 'ZZ_AGENCIA'.
                  CLEAR: g_table_wa-zz_agencia.
                WHEN 'ZZ_AGENCIA'.
                  CLEAR: g_table_wa-anbwa.
                WHEN 'ANLN2'.
                  CLEAR: g_table_wa-anln2.
                WHEN 'BSCHL'.
                  CLEAR: g_table_wa-bschl.
              ENDCASE.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.

      LOOP AT SCREEN.
        IF screen-name+17(10) EQ 'ANBWA'.
          READ TABLE zstatus_campo WITH  KEY feldn = 'ANLN1'.
          IF sy-subrc EQ 0.
            IF zstatus_campo-xnodi EQ 'X'.
              CLEAR: g_table_wa-anbwa.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

*ReSQ: No Need Of Change Internal Table G_TABLE_ITAB Already Sorted
      MODIFY g_table_itab
        FROM g_table_wa
        INDEX table-current_line.
      IF sy-subrc NE 0.
        APPEND g_table_wa TO g_table_itab.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " LIMPIA_OBJET  INPUT
