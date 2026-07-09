*&---------------------------------------------------------------------*
*& Report ZSD_AJUSTA_XBLNR
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zsd_ajusta_xblnr.
TABLES : bkpf,
         vbrk.
*
TYPE-POOLS: slis.
*
DATA :BEGIN OF ty_vbrk,
        vbeln    LIKE bkpf-awkey,
        xblnr    LIKE vbrk-xblnr,
        fkart    LIKE vbrk-fkart,
*
        bukrs    LIKE bkpf-bukrs,
        belnr    LIKE bkpf-belnr,
        gjahr    LIKE bkpf-gjahr,
        blart    LIKE bkpf-blart,
        xblnr_fi LIKE bkpf-xblnr,
        selec    LIKE af61r-flg01,
      END OF ty_vbrk,
*
      BEGIN OF ty_bkpf,
        bukrs TYPE bkpf-bukrs,
        belnr TYPE bkpf-belnr,
        gjahr TYPE bkpf-gjahr,
        blart TYPE bkpf-blart,
        xblnr TYPE bkpf-xblnr,
        awkey TYPE bkpf-awkey,
      END OF ty_bkpf.
*
DATA : ti_vbrk LIKE TABLE OF ty_vbrk,
       ti_bkpf LIKE TABLE OF ty_bkpf,
       wa_vbrk LIKE ty_vbrk,
       wa_bkpf LIKE ty_bkpf,
       g_repid TYPE syrepid,
       g_land1 TYPE land1.
*
CONSTANTS : c_x   TYPE c LENGTH 01 VALUE 'X'.
*
SELECTION-SCREEN BEGIN OF BLOCK uno WITH FRAME TITLE TEXT-s01.
SELECT-OPTIONS : s_bukrs FOR bkpf-bukrs NO INTERVALS NO-EXTENSION
                                        OBLIGATORY,
                 s_vbeln FOR vbrk-vbeln .
SELECTION-SCREEN END   OF BLOCK uno.
*
INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.
*
AT SELECTION-SCREEN ON BLOCK uno.
  SELECT bukrs INTO TABLE @DATA(lt_bukrs)
         FROM t001 WHERE bukrs IN @s_bukrs.
  LOOP AT lt_bukrs INTO DATA(lw_bukrs).
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
       ID 'BUKRS' FIELD lw_bukrs.
    IF sy-subrc <> 0.
      MESSAGE e526(icc_tr) WITH lw_bukrs.
    ENDIF.
  ENDLOOP.
*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE land1 INTO g_land1
*         FROM t001 WHERE bukrs IN s_bukrs.
*
* NEW CODE
  SELECT land1
  UP TO 1 ROWS  INTO g_land1
         FROM t001 WHERE bukrs IN s_bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
  IF s_vbeln[] IS INITIAL.
    MESSAGE e899(sd) WITH 'Ingrese Factura(s)'.
  ENDIF.
*

START-OF-SELECTION.
  PERFORM lee_datos.
  PERFORM mostrar_datos.


*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA : lv_offnrel TYPE j_1aoffnrel,
         lv_blart   TYPE blart,
         lv_tabix1  TYPE sytabix,
         lv_tabix2  TYPE sytabix.
*
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT vbeln xblnr fkart INTO TABLE ti_vbrk
*         FROM vbrk WHERE vbeln IN s_vbeln AND
*                         xblnr EQ '0000000000000000'.
*
* NEW CODE
  SELECT vbeln xblnr fkart
 INTO TABLE ti_vbrk
         FROM vbrk WHERE vbeln IN s_vbeln AND
                         xblnr EQ '0000000000000000' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  IF ti_vbrk[] IS NOT INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT bukrs belnr gjahr blart xblnr awkey INTO TABLE ti_bkpf
*           FROM bkpf FOR ALL ENTRIES IN ti_vbrk
*                     WHERE bukrs IN s_bukrs AND
*                           awtyp EQ 'VBRK'  AND
*                           awkey EQ ti_vbrk-vbeln.
*
* NEW CODE
    SELECT bukrs belnr gjahr blart xblnr awkey
 INTO TABLE ti_bkpf
           FROM bkpf FOR ALL ENTRIES IN ti_vbrk
                     WHERE bukrs IN s_bukrs AND
                           awtyp EQ 'VBRK'  AND
                           awkey EQ ti_vbrk-vbeln ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*
    LOOP AT ti_vbrk INTO wa_vbrk.
      MOVE sy-tabix TO lv_tabix1.
* verifica si documento contable fue creado.
      READ TABLE ti_bkpf INTO wa_bkpf WITH KEY awkey = wa_vbrk-vbeln.
      IF sy-subrc EQ 0.
        MOVE sy-tabix TO lv_tabix2.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE blart INTO lv_blart
*               FROM tvfk WHERE fkart = wa_vbrk-fkart.
*
* NEW CODE
        SELECT blart
        UP TO 1 ROWS  INTO lv_blart
               FROM tvfk WHERE fkart = wa_vbrk-fkart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE offnrel INTO lv_offnrel
*               FROM t003_i WHERE land1 EQ g_land1 AND
*                                 blart EQ lv_blart.
*
* NEW CODE
        SELECT offnrel
        UP TO 1 ROWS  INTO lv_offnrel
               FROM t003_i WHERE land1 EQ g_land1 AND
                                 blart EQ lv_blart ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        CHECK lv_offnrel EQ 'P' AND wa_bkpf-xblnr EQ '0000000000000000'.
        wa_bkpf-xblnr = wa_vbrk-vbeln.
        MODIFY ti_bkpf FROM wa_bkpf INDEX lv_tabix2.
*
        MOVE-CORRESPONDING wa_bkpf TO wa_vbrk.
        MOVE wa_bkpf-xblnr TO wa_vbrk-xblnr_fi.
      ENDIF.
* actualiza referencia de la factura
      wa_vbrk-xblnr =  wa_vbrk-vbeln.
      MODIFY ti_vbrk FROM wa_vbrk INDEX lv_tabix1.
    ENDLOOP.
*
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MOSTRAR_DATOS
*&---------------------------------------------------------------------*
FORM mostrar_datos .
  DATA: wa_layout   TYPE slis_layout_alv,
        lt_fieldcat TYPE slis_t_fieldcat_alv.
*
  MOVE sy-repid           TO g_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM fieldcat        USING lt_fieldcat.
*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = g_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = wa_layout
      it_fieldcat              = lt_fieldcat[]
      i_save                   = 'A'
    TABLES
      t_outtab                 = ti_vbrk
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm    LIKE sy-ucomm            "#EC NEEDED
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
  DATA : itab       TYPE TABLE OF bdcmsgcoll,
         bdcdata    TYPE TABLE OF bdcdata,
         wa_bdcdata TYPE bdcdata,
         l_vbeln    TYPE vbeln.
*
  CASE r_ucomm.
    WHEN 'FC01'.
      PERFORM actualiza_xblnr.
    WHEN OTHERS.
      CASE rs_selfield-fieldname.
        WHEN 'VBELN'.
          SET PARAMETER ID 'VF' FIELD rs_selfield-value.
          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.
  rs_selfield-refresh = 'X'.
ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE,
        l_procesado      TYPE char50.
*
  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
* function: participation-list
  fcode_attrib_tab-text      = TEXT-b01.
  fcode_attrib_tab-icon_id   = '@01@'.
  fcode_attrib_tab-icon_text = TEXT-b01.
  fcode_attrib_tab-quickinfo = space.
  fcode_attrib_tab-path      = space.
  APPEND fcode_attrib_tab.
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.

ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.
  CLEAR rs_layout.
  rs_layout-zebra                = c_x.
  rs_layout-colwidth_optimize    = c_x.
  rs_layout-box_fieldname        = 'SELEC'.
ENDFORM.                    " LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT
*&---------------------------------------------------------------------*
FORM fieldcat  USING    p_lt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA : it_fieldcat_t TYPE slis_t_fieldcat_alv,
         is_fieldcat   TYPE slis_fieldcat_alv,
         l_pos         TYPE i.
*
  CLEAR p_lt_fieldcat[].
*
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = g_repid
      i_internal_tabname     = 'TY_VBRK'
      i_inclname             = g_repid
    CHANGING
      ct_fieldcat            = it_fieldcat_t
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
*
  LOOP AT it_fieldcat_t INTO is_fieldcat.
    CASE is_fieldcat-fieldname.
      WHEN 'VBELN'.
        is_fieldcat-key_sel    = c_x.
        is_fieldcat-hotspot    = c_x.
        is_fieldcat-seltext_m  = 'Factura'.
      WHEN 'XBLNR_FI'.
        is_fieldcat-seltext_m  = 'Referncia FI'.
      WHEN 'SELEC'.
        is_fieldcat-no_out     = c_x.
      WHEN OTHERS.
*
    ENDCASE.
*
    is_fieldcat-ddictxt         = 'M'.
    ADD 1 TO l_pos.
    is_fieldcat-col_pos   = l_pos.
    APPEND is_fieldcat TO p_lt_fieldcat.
  ENDLOOP.
ENDFORM.                    " FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  ACTUALIZA_XBLNR
*&---------------------------------------------------------------------*
FORM actualiza_xblnr .

  LOOP AT ti_vbrk INTO wa_vbrk WHERE selec EQ c_x AND
                                     xblnr NE '0000000000000000'.

    READ TABLE ti_bkpf INTO wa_bkpf WITH KEY awkey = wa_vbrk-vbeln.
* actualiza cabecera del documento FI
    IF sy-subrc EQ 0.
      UPDATE bkpf SET xblnr = wa_bkpf-xblnr
               WHERE bukrs EQ wa_bkpf-bukrs AND
                     belnr EQ wa_bkpf-belnr AND
                     gjahr EQ wa_bkpf-gjahr.
    ENDIF.
*
    UPDATE vbrk SET xblnr = wa_vbrk-xblnr
              WHERE vbeln EQ wa_vbrk-vbeln.
  ENDLOOP.
  COMMIT WORK AND WAIT.
ENDFORM.
