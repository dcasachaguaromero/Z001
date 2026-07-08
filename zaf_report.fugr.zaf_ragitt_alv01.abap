FUNCTION zaf_ragitt_alv01.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_BERDATUM) TYPE  DATUM
*"  TABLES
*"      ITAB_HEADER
*"      ITAB_DATA
*"----------------------------------------------------------------------
*
  TYPES : BEGIN OF ty_zz_alv01,
            bukrs    TYPE anlav-bukrs,
            anln1    TYPE anlav-anln1,
            anln2    TYPE anlav-anln2,
            anlkl    TYPE anlav-anlkl,
            afabg    TYPE anlb-afabg,
            gjahr    TYPE anlcv-gjahr,
            afabe    TYPE anlcv-afabe,
            zujhr    TYPE anlcv-zujhr,
            zucod    TYPE anlcv-zucod,
            berdatum TYPE brdatu,
            peraf    TYPE t093d-afblpe,
          END OF ty_zz_alv01,
          BEGIN OF ty_anla,
            bukrs  TYPE anla-bukrs,
            anln1  TYPE anla-anln1,
            anln2  TYPE anla-anln2,
            ord41  TYPE anla-ord41,
            ord42  TYPE anla-ord42,
            ord43  TYPE anla-ord43,
            ord44  TYPE anla-ord44,
            gdlgrp TYPE anla-gdlgrp,
            sernr  TYPE anla-sernr,
            anlue  TYPE anla-anlue,
            izwek  TYPE anla-izwek,
            lifnr  TYPE anla-lifnr,
          END OF ty_anla,
          BEGIN OF ty_anek,
            bukrs TYPE anek-bukrs,
            anln1 TYPE anek-anln1,
            anln2 TYPE anek-anln2,
            gjahr TYPE anek-gjahr,
            lnran TYPE anek-lnran,
            bldat TYPE anek-bldat,
            budat TYPE anek-budat,
            belnr TYPE anek-belnr,
            xblnr TYPE anek-xblnr,
          END OF ty_anek,
          BEGIN OF ty_anlp,
            bukrs  TYPE anlp-bukrs,
            gjahr  TYPE anlp-gjahr,
            peraf  TYPE anlp-peraf,
            afbnr  TYPE anlp-afbnr,
            anln1  TYPE anlp-anln1,
            anln2  TYPE anlp-anln2,
            afaber TYPE anlp-afaber,
            zujhr  TYPE anlp-zujhr,
            zucod  TYPE anlp-zucod,
            nafaz  TYPE anlp-nafaz,
            safaz  TYPE anlp-safaz,
            aafaz  TYPE anlp-aafaz,
            mafaz  TYPE anlp-mafaz,
            aufnz  TYPE anlp-aufnz,
          END OF ty_anlp.

  TYPES : BEGIN OF ty_lifnr,
            lifnr TYPE lifnr,
          END OF ty_lifnr,
          BEGIN OF ty_key_anla,
            bukrs TYPE anla-bukrs,
            anln1 TYPE anla-anln1,
            anln2 TYPE anla-anln2,
          END OF ty_key_anla.
*
  DATA : lt_zz_alv01 TYPE SORTED TABLE OF ty_zz_alv01 WITH UNIQUE KEY bukrs anln1 anln2,
         tt_zz_alv01 TYPE TABLE OF ty_zz_alv01,
         wa_zz_alv01 TYPE ty_zz_alv01.
  DATA : lt_lifnr   TYPE TABLE OF ty_lifnr,
         lt_anlav   TYPE SORTED TABLE OF ty_anla WITH UNIQUE KEY bukrs anln1 anln2,
         lt_anek    TYPE SORTED TABLE OF ty_anek WITH UNIQUE KEY bukrs anln1 anln2 gjahr lnran,
         lt_anlp    TYPE SORTED TABLE OF ty_anlp WITH NON-UNIQUE KEY bukrs gjahr peraf anln1 anln2 afaber zujhr zucod,
         lw_key     TYPE ty_key_anla,
         lw_datos   TYPE ci_repragitt,
         lv_afa_per TYPE anlp-nafaz.
*
  lt_zz_alv01[] = itab_data[].
  SELECT bukrs, anln1, anln2, ord41, ord42, ord43, ord44,
         gdlgrp, sernr, anlue, izwek, lifnr
         INTO TABLE @lt_anlav
         FROM anla FOR ALL ENTRIES IN @lt_zz_alv01
                   WHERE bukrs EQ @lt_zz_alv01-bukrs
                    AND  anln1 EQ @lt_zz_alv01-anln1
                    AND  anln2 EQ @lt_zz_alv01-anln2.
*
  IF lt_anlav[] IS NOT INITIAL.
**Mod ini
*Commet
*    lt_lifnr = VALUE #( FOR ly_detalle IN lt_anlav
*                                     WHERE ( lifnr NE space )
*                                     ( CORRESPONDING #( ly_detalle ) ) ).
    LOOP AT lt_anlav INTO DATA(ly_detalle).
     IF ly_detalle-lifnr IS NOT INITIAL.
      APPEND VALUE #( lifnr = ly_detalle-lifnr ) TO lt_lifnr.
     ENDIF.
    ENDLOOP.

    SORT lt_lifnr BY lifnr.
***Mod Fin
    IF lt_lifnr[] IS NOT INITIAL.
      SORT lt_lifnr.
      DELETE ADJACENT DUPLICATES FROM lt_lifnr COMPARING ALL FIELDS.
      SELECT lifnr, name1, stcd1 INTO TABLE @DATA(lt_lfa1)
             FROM lfa1 FOR ALL ENTRIES IN @lt_lifnr
                       WHERE lifnr EQ @lt_lifnr-lifnr.
    ENDIF.
  ENDIF.
*
  SELECT anlkl, txk50 INTO TABLE @DATA(lt_ankt)
         FROM ankt WHERE spras EQ @sy-langu.
*
** V1 - PGR : 23-07-2025
* Cambia lectura de datos a Vista que contiene datos de anulación
* Solo se seleccionan Documentos NO anulados.
  SELECT bukrs, anln1, anln2, gjahr, lnran, bldat, budat, belnr, xblnr
       INTO TABLE @lt_anek
* Remplaza lectura de tabla ANEK por Vista V_ANEPK
*      FROM anek    FOR ALL ENTRIES IN @lt_zz_alv01
       FROM v_anepk FOR ALL ENTRIES IN @lt_zz_alv01
                  WHERE bukrs  EQ @lt_zz_alv01-bukrs
                  AND   anln1  EQ @lt_zz_alv01-anln1
                  AND   anln2  EQ @lt_zz_alv01-anln2
                  AND   gjahr  LE @lt_zz_alv01-berdatum(4)
                  AND   xblnr  NE @space
                  AND   awtyp  EQ 'BKPF'
* Agregado a Logica de selección
                  AND   afabe EQ  '01'    "Área Financiera
                  AND   lnsan EQ  @space. "Pos. NO Anulada

*
  SELECT bukrs, gjahr, peraf, afbnr, anln1, anln2, afaber, zujhr, zucod,
         nafaz, safaz, aafaz, mafaz, aufnz
         INTO TABLE @lt_anlp
         FROM anlp FOR ALL ENTRIES IN @lt_zz_alv01
                   WHERE bukrs  EQ @lt_zz_alv01-bukrs
                     AND gjahr  EQ @lt_zz_alv01-gjahr
                     AND peraf  EQ @lt_zz_alv01-peraf
                     AND anln1  EQ @lt_zz_alv01-anln1
                     AND anln2  EQ @lt_zz_alv01-anln2
                     AND afaber EQ @lt_zz_alv01-afabe
                     AND zujhr  EQ @lt_zz_alv01-zujhr
                     AND zucod  EQ @lt_zz_alv01-zucod.
*
  LOOP AT itab_header ASSIGNING FIELD-SYMBOL(<itab_line>).
    CLEAR : lw_datos, lw_key.
    MOVE-CORRESPONDING <itab_line> TO lw_key.
    MOVE-CORRESPONDING <itab_line> TO lw_datos.
    DATA(lv_index0) = line_index( lt_zz_alv01[ bukrs = lw_key-bukrs
                                               anln1 = lw_key-anln1
                                               anln2 = lw_key-anln2 ] ).
    CHECK lv_index0 GT 0.
    wa_zz_alv01    = lt_zz_alv01[ lv_index0 ].
    DATA(lv_index) = line_index( lt_anlav[ bukrs = lw_key-bukrs
                                           anln1 = lw_key-anln1
                                           anln2 = lw_key-anln2 ] ).
    IF lv_index GT 0.
      DATA(lw_anlav) = lt_anlav[ lv_index ].
      lw_datos-zz_ord41  = lw_anlav-ord41.
      lw_datos-zz_ord42  = lw_anlav-ord42.
      lw_datos-zz_ord43  = lw_anlav-ord43.
      lw_datos-zz_ord44  = lw_anlav-ord44.
      lw_datos-zz_anlue  = lw_anlav-anlue.
      lw_datos-zz_izwek  = lw_anlav-izwek.
      lw_datos-zz_gdlgrp = lw_anlav-gdlgrp.
      lw_datos-zz_sernr  = lw_anlav-sernr.
*
      IF lw_anlav-lifnr IS NOT INITIAL.
        lv_index = line_index( lt_lfa1[ lifnr = lw_anlav-lifnr ] ).
        IF lv_index GT 0.
          DATA(lw_lfa1) = lt_lfa1[ lv_index ].
          lw_datos-zz_stcd1 = lw_lfa1-stcd1.
          lw_datos-zz_name1 = lw_lfa1-name1.
        ENDIF.
      ENDIF.
    ENDIF.
*
    lv_index = line_index( lt_ankt[ anlkl = wa_zz_alv01-anlkl ] ).
    IF lv_index GT 0.
      lw_datos-zz_txk50  = lt_ankt[ lv_index ]-txk50.
    ENDIF.
*
    lv_index = line_index( lt_anek[ bukrs = wa_zz_alv01-bukrs
                                    anln1 = wa_zz_alv01-anln1
                                    anln2 = wa_zz_alv01-anln2 ] ).
    IF lv_index GT 0.
      DATA(lw_anek)  = lt_anek[ lv_index ].
      lw_datos-zz_bldat = lw_anek-bldat.
      lw_datos-zz_budat = lw_anek-budat.
      lw_datos-zz_belnr = lw_anek-belnr.
      lw_datos-zz_gjahr = lw_anek-gjahr.
      lw_datos-zz_xblnr = lw_anek-xblnr.
    ENDIF.
*
    CLEAR lv_afa_per.
    lv_afa_per = REDUCE #( INIT lv_neto TYPE nafaz
                            FOR ls_anlp IN
                            FILTER #( lt_anlp WHERE bukrs  EQ wa_zz_alv01-bukrs
                                                AND gjahr  EQ wa_zz_alv01-gjahr
                                                AND peraf  EQ wa_zz_alv01-peraf
                                                AND anln1  EQ wa_zz_alv01-anln1
                                                AND anln2  EQ wa_zz_alv01-anln2
                                                AND afaber EQ wa_zz_alv01-afabe
                                                AND zujhr  EQ wa_zz_alv01-zujhr
                                                AND zucod  EQ wa_zz_alv01-zucod )
                             NEXT lv_neto = lv_neto + ls_anlp-nafaz +
                                                      ls_anlp-safaz +
                                                      ls_anlp-aafaz +
                                                      ls_anlp-mafaz +
                                                      ls_anlp-aufnz ).
    lw_datos-zz_nafaz = lv_afa_per.
*
    MOVE-CORRESPONDING lw_datos TO <itab_line>.
  ENDLOOP.

ENDFUNCTION.
