FUNCTION zaf_ragitt_alv01_dep_mes.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_ANLCV) TYPE  ANLCV
*"     REFERENCE(I_ANLAV) TYPE  ANLAV
*"     REFERENCE(I_ANLB) TYPE  ANLB
*"     VALUE(I_BERDATUM) TYPE  DATUM
*"  EXPORTING
*"     REFERENCE(ZZ_NAFAZ) TYPE  ZZ_NAFAZ
*"----------------------------------------------------------------------
  DATA : lt_t093d     TYPE TABLE OF t093d,
         lt_anlb      TYPE TABLE OF anlb,
         lt_anfm      TYPE TABLE OF anfm,
         lt_anlc      TYPE TABLE OF anlc,
         lt_anlp      TYPE TABLE OF anlp,
         lt_anlz      TYPE TABLE OF anlz,
         lt_anea      TYPE TABLE OF anea,
         lw_anla      TYPE anla,
         lw_anlp      TYPE anlp,
         lv_cnt_peraf TYPE t093d-afblpe,
         lv_afa_per   TYPE anlp-nafaz.
*
  CLEAR zz_nafaz.
*
* Comentado V1- 03.05.2023
*  lv_cnt_peraf = '001'.

*  SELECT bukrs, gjahr, peraf, afbnr, anln1, anln2, afaber, zujhr, zucod,
*         nafaz, safaz, aafaz, mafaz, aufnz
*         INTO TABLE @DATA(lt_t_anlp)
*         FROM anlp WHERE bukrs  EQ @i_anlcv-bukrs
*                     AND gjahr  EQ @i_anlcv-gjahr
*                     AND peraf  LE @i_berdatum+4(2)
*                     AND afbnr  EQ @i_anlcv-afbanz
*                     AND anln1  EQ @i_anlcv-anln1
*                     AND anln2  EQ @i_anlcv-anln2
*                     AND afaber EQ @i_anlcv-afabe
*                     AND zujhr  EQ @i_anlcv-zujhr
*                     AND zucod  EQ @i_anlcv-zucod.
*
**  IF sy-subrc NE 0.

* Agregado V1 - 03.05.2023
  lv_cnt_peraf = i_berdatum+4(2).
*

  SELECT bukrs gjahr peraf afbnr anln1 anln2 afaber zujhr
         zucod nafaz safaz aafaz mafaz aufnz
* V1- 03.05.2023 Modificado
         FROM anlp
          INTO CORRESPONDING FIELDS OF TABLE lt_anlp
*          INTO TABLE lt_anlp
*         INTO TABLE lt_t_anlp
*         FROM anlp
         WHERE bukrs EQ i_anlcv-bukrs
                     AND gjahr  EQ i_anlcv-gjahr
* V1- 03.05.2023 Modificado
                     AND peraf  EQ lv_cnt_peraf
*                       AND peraf  LE i_berdatum+4(2)
*
                     AND anln1  EQ i_anlcv-anln1
                     AND anln2  EQ i_anlcv-anln2
                     AND afaber EQ i_anlcv-afabe
                     AND zujhr  EQ i_anlcv-zujhr
                     AND zucod  EQ i_anlcv-zucod.

*  ENDIF.  " Comentado V1- 23.05.2023
*
* Agregado V1- 23.05.2023
  LOOP AT lt_anlp INTO DATA(xanlp) WHERE peraf  EQ lv_cnt_peraf  AND
                                                 afaber EQ i_anlcv-afabe.
    lv_afa_per = lv_afa_per
               + xanlp-nafaz  "Amortización normal a contabilizar
               + xanlp-safaz  "Amortización especial a contabilizar
               + xanlp-aafaz  "Amo no planificada a contabilizar
               + xanlp-mafaz  "Amo con reducción VA a contab. en el ejercicio
               + xanlp-aufnz. "Rev.de la Amo normal acumulada a contabilizar
  ENDLOOP.
  zz_nafaz = lv_afa_per.

******

* Comentado V1 - 03.05.2023
*  SELECT bukrs afaber afbrhy afblpe afblgj afbanz xbafas afslbe status
*         INTO CORRESPONDING FIELDS OF TABLE lt_t093d
*         FROM t093d WHERE bukrs  EQ i_anlcv-bukrs
*                      AND afaber EQ i_anlcv-afabe.
*
*  SELECT * INTO TABLE lt_anlc
*         FROM anlc WHERE bukrs EQ i_anlcv-bukrs
*                    AND  anln1 EQ i_anlcv-anln1
*                    AND  anln2 EQ i_anlcv-anln2
*                    AND  gjahr EQ i_anlcv-gjahr
*                    AND  afabe EQ i_anlcv-afabe
*                    AND  zujhr EQ i_anlcv-zujhr
*                    AND  zucod EQ i_anlcv-zucod.
*
*  SELECT * INTO TABLE lt_anea
*         FROM anea WHERE bukrs EQ i_anlcv-bukrs
*                    AND  anln1 EQ i_anlcv-anln1
*                    AND  anln2 EQ i_anlcv-anln2
*                    AND  gjahr EQ i_anlcv-gjahr
*                    AND  afabe EQ i_anlcv-afabe
*                    AND  zujhr EQ i_anlcv-zujhr
*                    AND  zucod EQ i_anlcv-zucod.
*
*  SELECT * INTO TABLE lt_anlz
*         FROM anlz WHERE bukrs EQ i_anlcv-bukrs
*                    AND  anln1 EQ i_anlcv-anln1
*                    AND  anln2 EQ i_anlcv-anln2
*                    AND  bdatu BETWEEN '1900010' AND '99991231'.
**
*  APPEND i_anlb TO  lt_anlb.
**
*  MOVE-CORRESPONDING i_anlav TO lw_anla.
**
*  WHILE lv_cnt_peraf LE i_berdatum+4(2).
*    CLEAR lv_afa_per.
**
*    IF lv_cnt_peraf GT i_anlcv-afblpe.
*      LOOP AT lt_t093d ASSIGNING FIELD-SYMBOL(<lw_t093d>).
**        <lw_t093d>-xrestv =  l_xrestv.
*        <lw_t093d>-afbrhy  = '001'.
*        IF lv_cnt_peraf GT '001'.
*          <lw_t093d>-afblgj = i_berdatum(4).
*          <lw_t093d>-afblpe = lv_cnt_peraf - '001'.
*          <lw_t093d>-afbanz = '01'.
*          <lw_t093d>-status = '2'.
*        ELSE.
*          <lw_t093d>-afblgj = '0000'.
*          <lw_t093d>-afblpe = '000'.
*          <lw_t093d>-afbanz = '00'.
*          <lw_t093d>-status = '0'.
*        ENDIF.
*      ENDLOOP.
*
*      CALL FUNCTION 'RA_AFABUCHEN'
*        EXPORTING
*          i_afbgjr                 = i_berdatum(4)
*          i_afbper                 = lv_cnt_peraf
*          i_anla                   = lw_anla
*          i_fehler                 = 'X'
*          i_next                   = 'X'
*          i_nocheck                = 'X'
*          i_plansatz               = 'X'
*          i_refresh                = 'X'
*        TABLES
*          t_093d                   = lt_t093d
*          t_anfm                   = lt_anfm
*          t_anlb                   = lt_anlb
*          t_anlc                   = lt_anlc
*          t_anlp                   = lt_anlp
*          t_anea                   = lt_anea
*          t_anlz                   = lt_anlz
*        EXCEPTIONS
*          diff_years               = 1
*          no_assets_computed       = 2
*          no_posting_period        = 3
*          period_already_posted    = 4
*          period_false             = 5
*          posting_period_forgotten = 6
*          post_not_posible         = 7
*          OTHERS                   = 8.
*      IF sy-subrc <> 0.
** Implement suitable error handling here
*      ENDIF.
**
*      READ TABLE lt_anlp INTO lw_anlp WITH KEY afaber = i_anlcv-afabe.
*      IF sy-subrc EQ 0.
*        lv_afa_per = lw_anlp-nafaz
*                   + lw_anlp-safaz
*                   + lw_anlp-aafaz
*                   + lw_anlp-mafaz
*                   + lw_anlp-aufnz.
*      ENDIF.
*    ELSE.
*
*      LOOP AT lt_t_anlp INTO DATA(xanlp) WHERE peraf  EQ lv_cnt_peraf  AND
*                                               afaber EQ i_anlcv-afabe.
*        lv_afa_per = xanlp-nafaz
*                   + xanlp-safaz
*                   + xanlp-aafaz
*                   + xanlp-mafaz
*                   + xanlp-aufnz.
*      ENDLOOP.
*
*    ENDIF.
*
*    ADD 1 TO lv_cnt_peraf.
*
*  ENDWHILE.
**
*  zz_nafaz = lv_afa_per.
* Fin Comentado V1 - 03.05.2023
ENDFUNCTION.
