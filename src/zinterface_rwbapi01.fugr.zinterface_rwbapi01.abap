FUNCTION zinterface_rwbapi01.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      IT_ACCIT STRUCTURE  ACCIT
*"      IT_ACCCR STRUCTURE  ACCCR
*"      RETURN STRUCTURE  BAPIRET2
*"      EXTENSION STRUCTURE  BAPIACEXTC
*"      IT_ACCWT STRUCTURE  ACCIT_WT
*"  CHANGING
*"     VALUE(DOCUMENT_HEADER) LIKE  ACCHD STRUCTURE  ACCHD
*"----------------------------------------------------------------------
  DATA: posnr(3)  TYPE c,
        atributo_1 LIKE zdetalle-zzprestac,
        atributo_2 LIKE zdetalle-zzunid_pro,
        atributo_3 LIKE zdetalle-zzdesc_est,
        atributo_4 LIKE zdetalle-zzmot_emis,
        atributo_5 LIKE zdetalle-zzrut_terc,
        atributo_6 LIKE zdetalle-zz_agencia,
        atributo_7 LIKE zdetalle-fdlev,
        atributo_8 LIKE zdetalle-atributo_8,
        atributo_9 LIKE zcabecera-area_contab,
        atributo_10 LIKE zdetalle-costcenter,
        atributo_11 LIKE it_accit-bschl,
        p_index LIKE  sy-tabix.


  LOOP AT extension.
    SPLIT extension-field1 AT  ';' INTO:  posnr
                              atributo_1
                              atributo_2
                              atributo_3
                              atributo_4
                              atributo_5
                              atributo_6
                              atributo_7
                              atributo_8
                              atributo_9
                              atributo_10
                              atributo_11.
    IF sy-subrc EQ 0.
      READ TABLE it_accit WITH KEY posnr+7(3) =  posnr.
      p_index =  sy-tabix.
      IF sy-subrc EQ 0.
        it_accit-zzprestac  =  atributo_1.
        it_accit-zzunid_pro =  atributo_2.
        it_accit-zzdesc_est =  atributo_3.
        it_accit-zzmot_emis =  atributo_4.
        it_accit-zzrut_terc =  atributo_5.
        it_accit-zz_agencia =  atributo_6.
        it_accit-fdlev      =  atributo_7.
        SELECT SINGLE prefix_txt INTO it_accit-xref2_hd
          FROM tsad4
          WHERE prefix_key = atributo_9.
*      IT_ACCIT-XREF2_HD   =  ATRIBUTO_9.
        IF it_accit-kostl IS INITIAL AND atributo_10 IS NOT INITIAL.
          it_accit-kostl = atributo_10.
        ENDIF.

        IF  atributo_11 IS NOT INITIAL.
          it_accit-bschl = atributo_11.
        ENDIF.

        MODIFY it_accit INDEX p_index.
        CLEAR:posnr, atributo_1, atributo_2, atributo_3, atributo_4, atributo_5, atributo_6,  atributo_7, atributo_8,
              atributo_9,atributo_10,atributo_11.
      ENDIF.

    ELSE.
***Inicio V1 19.02.2013***
***Cambiar clave contable Y CAMPOS Z
      LOOP AT extension.
        READ TABLE it_accit WITH KEY posnr = extension(3).
        IF sy-subrc EQ 0.
          IF extension+3(5) EQ 'BSCHL'.
            it_accit-bschl = extension+8(2).
            MODIFY it_accit INDEX sy-tabix.

          ELSEIF extension+3(9) EQ 'ZZPRESTAC'.
            it_accit-zzprestac = extension+8(10).
            MODIFY it_accit INDEX sy-tabix.

          ELSEIF extension+3(10) EQ 'ZZUNID_PRO'.
            it_accit-zzunid_pro = extension+13(10).
            MODIFY it_accit INDEX sy-tabix.

          ELSEIF extension+3(10) EQ 'ZZDESC_EST'.
            it_accit-zzdesc_est = extension+13(10).
            MODIFY it_accit INDEX sy-tabix.

          ELSEIF extension+3(10) EQ 'ZZMOT_EMIS'.
            it_accit-zzmot_emis = extension+13(10).
            MODIFY it_accit INDEX sy-tabix.

          ELSEIF extension+3(10) EQ 'ZZRUT_TERC'.
            it_accit-zzrut_terc = extension+13(10).
            MODIFY it_accit INDEX sy-tabix.

          ELSEIF extension+3(10) EQ 'ZZ_AGENCIA'.
            it_accit-zz_agencia = extension+13(10).
            MODIFY it_accit INDEX sy-tabix.
          ENDIF.
        ENDIF.
      ENDLOOP.
***Fin V1 19.02.2013***
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
