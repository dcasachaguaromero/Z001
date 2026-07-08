*&---------------------------------------------------------------------*
*&  Include           ZFI_ADD_RECORDS_FAGL_SPLIT_CLS
*&---------------------------------------------------------------------*

CLASS lcl_app DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF gty_bseg,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
             awtyp TYPE awtyp,
             buzei TYPE buzei,
             shkzg TYPE shkzg,
             bschl TYPE bschl,
             mwskz TYPE mwskz,
             hkont TYPE hkont,
             pswsl TYPE pswsl,
             pswbt TYPE pswbt,
             dmbe2 TYPE dmbe2,
           END OF gty_bseg,

           gtt_bseg TYPE STANDARD TABLE OF gty_bseg.

    TYPES: gtt_fagl_splinfo     TYPE STANDARD TABLE OF fagl_splinfo,
           gtt_fagl_splinfo_val TYPE STANDARD TABLE OF fagl_splinfo_val.

    DATA: gt_fagl_splinfo     TYPE gtt_fagl_splinfo,
          gt_fagl_splinfo_val TYPE gtt_fagl_splinfo_val,
          gt_bseg             TYPE gtt_bseg.

    METHODS:
      get_db_tables IMPORTING iv_bukrs TYPE bukrs
                              iv_gjahr TYPE gjahr
                              ir_belnr TYPE gtr_belnr,

      manage_updates,

      upd_db_tables IMPORTING it_fagl_splinfo     TYPE gtt_fagl_splinfo
                              it_bseg             TYPE gtt_bseg
                              it_fagl_splinfo_val TYPE gtt_fagl_splinfo_val,

      del_db_table  IMPORTING iv_bukrs TYPE bukrs
                              iv_belnr TYPE belnr_d
                              iv_gjahr TYPE gjahr
                              iv_buzei TYPE buzei,

      show_log.

ENDCLASS.

CLASS lcl_app IMPLEMENTATION.

  METHOD get_db_tables.

    gv_reg1 = 0.
    gv_reg2 = 0.
    gv_reg3 = 0.

    SELECT FROM fagl_splinfo FIELDS *
      WHERE bukrs  = @iv_bukrs
        AND belnr IN @ir_belnr
        AND gjahr  = @iv_gjahr
      INTO TABLE @gt_fagl_splinfo.

    IF sy-subrc <> 0.
       move 1 to gv_reg1.
    endif.

    SELECT FROM fagl_splinfo_val FIELDS *
      WHERE bukrs = @iv_bukrs
        AND belnr IN @ir_belnr
        AND gjahr = @iv_gjahr
      INTO TABLE @gt_fagl_splinfo_val.

    IF sy-subrc <> 0.
       move 1 to gv_reg2.
    endif.

    SELECT FROM bkpf AS k
      INNER JOIN bseg AS p ON k~bukrs = p~bukrs AND
                              k~belnr = p~belnr AND
                              k~gjahr = p~gjahr
      FIELDS k~bukrs, k~belnr, k~gjahr, k~awtyp,
             p~buzei, p~shkzg, p~bschl, p~mwskz, p~hkont, p~pswsl, p~pswbt, p~dmbe2
      WHERE k~bukrs  = @iv_bukrs
        AND k~belnr IN @ir_belnr
        AND k~gjahr  = @iv_gjahr
      ORDER BY k~bukrs, k~belnr, k~gjahr
      INTO TABLE @gt_bseg.

    IF sy-subrc <> 0.
       move 1 to gv_reg3.
    endif.

  ENDMETHOD.

  METHOD manage_updates.

    TYPES: BEGIN OF lty_bkpf,
             bukrs TYPE bukrs,
             belnr TYPE belnr_d,
             gjahr TYPE gjahr,
           END OF lty_bkpf,

           ltt_bkpf TYPE STANDARD TABLE OF lty_bkpf.

    DATA: lt_bkpf TYPE ltt_bkpf.

    DATA: lt_fagl_splinfo     TYPE STANDARD TABLE OF fagl_splinfo,
          lt_fagl_splinfo_val TYPE STANDARD TABLE OF fagl_splinfo_val,
          lt_bseg             TYPE gtt_bseg.

*   Determinar documentos diferentes
    LOOP AT gt_bseg INTO DATA(ls_bseg).
      AT NEW gjahr.
        APPEND INITIAL LINE TO lt_bkpf ASSIGNING FIELD-SYMBOL(<fs_bkpf>).
        MOVE-CORRESPONDING ls_bseg TO <fs_bkpf>.
      ENDAT.
    ENDLOOP.

*   Por cada documento ejecutar el UPDATE
    LOOP AT lt_bkpf ASSIGNING <fs_bkpf>.
      CLEAR: lt_bseg, lt_fagl_splinfo, lt_fagl_splinfo_val.

      lt_fagl_splinfo = VALUE #( FOR ls_line IN gt_fagl_splinfo
                                 WHERE ( bukrs = <fs_bkpf>-bukrs AND
                                         belnr = <fs_bkpf>-belnr AND
                                         gjahr = <fs_bkpf>-gjahr
                                        )
                                 ( ls_line )
                                ).

      lt_bseg = VALUE #( FOR ls_xbseg IN gt_bseg
                                 WHERE ( bukrs = <fs_bkpf>-bukrs AND
                                         belnr = <fs_bkpf>-belnr AND
                                         gjahr = <fs_bkpf>-gjahr
                                        )
                                 ( ls_xbseg )
                                ).


      lt_fagl_splinfo_val = VALUE #( FOR ls_linex IN gt_fagl_splinfo_val
                                 WHERE ( bukrs = <fs_bkpf>-bukrs AND
                                         belnr = <fs_bkpf>-belnr AND
                                         gjahr = <fs_bkpf>-gjahr
                                        )
                                 ( ls_linex )
                                ).

      upd_db_tables( EXPORTING it_fagl_splinfo     = lt_fagl_splinfo
                               it_bseg             = lt_bseg
                               it_fagl_splinfo_val = lt_fagl_splinfo_val
                    ).

    ENDLOOP.

  ENDMETHOD.

  METHOD upd_db_tables.

    DATA: lt_upd_fagl_splinfo     TYPE STANDARD TABLE OF fagl_splinfo,
          lt_upd_fagl_splinfo_val TYPE STANDARD TABLE OF fagl_splinfo_val.

    DATA: lv_buzei_old TYPE buzei,
          lv_CURTP     TYPE CURTP.

    READ TABLE it_fagl_splinfo INTO DATA(ls_fagl_splinfo) INDEX 1.

    IF sy-subrc <> 0.
*     No se encontraron registros en tabla &
      MESSAGE i028 WITH 'FAGL_SPLINFO'.
    ENDIF.

    CLEAR: lv_buzei_old.

    SELECT FROM fagl_splinfo_val FIELDS *
      WHERE bukrs EQ @p_bukrs1
        AND belnr EQ @p_belnr1
        AND gjahr EQ @p_gjahr1
        INTO TABLE @gt_fagl_splinfo_val.
*

    LOOP AT it_bseg INTO DATA(ls_bseg).
      READ TABLE it_fagl_splinfo ASSIGNING FIELD-SYMBOL(<fs_fagl_splinfo>)
        WITH KEY belnr = ls_bseg-belnr
                 gjahr = ls_bseg-gjahr
                 bukrs = ls_bseg-bukrs
                 buzei = ls_bseg-buzei.

      IF sy-subrc <> 0.
        APPEND INITIAL LINE TO lt_upd_fagl_splinfo ASSIGNING <fs_fagl_splinfo>.
        MOVE-CORRESPONDING ls_fagl_splinfo TO <fs_fagl_splinfo>.
        <fs_fagl_splinfo>-belnr   = ls_bseg-belnr.
        <fs_fagl_splinfo>-spl_no  = ls_bseg-buzei.
        <fs_fagl_splinfo>-gjahr   = ls_bseg-gjahr.
        <fs_fagl_splinfo>-bukrs   = ls_bseg-bukrs.
        <fs_fagl_splinfo>-buzei   = ls_bseg-buzei.
        <fs_fagl_splinfo>-awref   = ls_bseg-belnr.
        <fs_fagl_splinfo>-aworg   = |{ ls_bseg-bukrs }{ ls_bseg-gjahr }|.
        <fs_fagl_splinfo>-segment = '1000_C'.
        <fs_fagl_splinfo>-shkzg   = ls_bseg-shkzg.
        <fs_fagl_splinfo>-bschl   = ls_bseg-bschl.
        <fs_fagl_splinfo>-mwskz   = ls_bseg-mwskz.
        <fs_fagl_splinfo>-hkont   = ls_bseg-hkont.
        <fs_fagl_splinfo>-pswsl   = ls_bseg-pswsl.
        IF ls_bseg-shkzg = 'H'.
          <fs_fagl_splinfo>-pswbt = 0 - ls_bseg-pswbt.
        ELSE.
          <fs_fagl_splinfo>-pswbt = ls_bseg-pswbt.
        ENDIF.

        IF lv_buzei_old IS INITIAL.
          READ TABLE it_fagl_splinfo_val INTO DATA(ls_fagl_splinfo_val) INDEX 1.
          lv_buzei_old = ls_fagl_splinfo_val-buzei.
        ENDIF.

        lv_buzei_old = 001.
        lv_CURTP     = '00'.

        IF NOT lv_buzei_old IS INITIAL.
          LOOP AT gt_fagl_splinfo_val INTO ls_fagl_splinfo_val
            WHERE belnr EQ p_belnr1
              AND gjahr EQ p_gjahr1
              AND bukrs EQ p_bukrs1
              AND buzei = lv_buzei_old.
            IF lv_buzei_old < 5.
               IF lv_buzei_old = 001.
                  ls_fagl_splinfo_val-curtp = '00'.
               else.
               IF lv_buzei_old = 002.
                  ls_fagl_splinfo_val-curtp = '10'.
               else.
               IF lv_buzei_old = 003.
                  ls_fagl_splinfo_val-curtp = '30'.
               else.
                  ls_fagl_splinfo_val-curtp = '40'.
               endif.
               endif.
               endif.

               APPEND INITIAL LINE TO lt_upd_fagl_splinfo_val ASSIGNING FIELD-SYMBOL(<fs_fagl_splinfo_val>).
               <fs_fagl_splinfo_val>-belnr   = ls_bseg-belnr.
               <fs_fagl_splinfo_val>-gjahr   = ls_bseg-gjahr.
               <fs_fagl_splinfo_val>-bukrs   = ls_bseg-bukrs.
               <fs_fagl_splinfo_val>-buzei   = ls_bseg-buzei.
               <fs_fagl_splinfo_val>-spl_no  = ls_bseg-buzei.
               <fs_fagl_splinfo_val>-curtp   = ls_fagl_splinfo_val-curtp.
               <fs_fagl_splinfo_val>-waers   = 'CLP'.
               <fs_fagl_splinfo_val>-wrbtr   = <fs_fagl_splinfo>-pswbt.
*               IF ls_fagl_splinfo_val-curtp = '40'.
                IF lv_buzei_old = '004'.
                  <fs_fagl_splinfo_val>-waers = 'USD'.
                  IF ls_bseg-shkzg = 'H'.
                     <fs_fagl_splinfo_val>-wrbtr = 0 - ls_bseg-dmbe2.
                  ELSE.
                     <fs_fagl_splinfo_val>-wrbtr = ls_bseg-dmbe2.
                  endif.
               ENDIF.
               lv_buzei_old = lv_buzei_old + 1.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ELSE.
        lv_buzei_old = ls_bseg-buzei.
      ENDIF.

    ENDLOOP.

    IF NOT lt_upd_fagl_splinfo[] IS INITIAL.
      MODIFY fagl_splinfo FROM TABLE lt_upd_fagl_splinfo.
    ENDIF.

    IF NOT lt_upd_fagl_splinfo_val[] IS INITIAL.
      MODIFY fagl_splinfo_val FROM TABLE lt_upd_fagl_splinfo_val.
    ENDIF.

    COMMIT WORK.

  ENDMETHOD.

  METHOD del_db_table.

    CHECK NOT iv_bukrs IS INITIAL AND
          NOT iv_belnr IS INITIAL.

    DELETE FROM fagl_splinfo
      WHERE belnr = @iv_belnr
        AND gjahr = @iv_gjahr
        AND bukrs = @iv_bukrs
        AND buzei = @iv_buzei.

    DELETE FROM fagl_splinfo_val
      WHERE belnr = @iv_belnr
        AND gjahr = @iv_gjahr
        AND bukrs = @iv_bukrs
        AND buzei = @iv_buzei.

    COMMIT WORK.

  ENDMETHOD.

  METHOD show_log.

    WRITE: /01 'Programa: ', sy-repid,
           /01 'Fecha   : ', sy-datum, ' Hora: ', sy-uzeit,
           /01 'Usuario : ', sy-uname.
    SKIP 2.

    WRITE: /02 'Tablas actualizadas'.

  ENDMETHOD.

ENDCLASS.
