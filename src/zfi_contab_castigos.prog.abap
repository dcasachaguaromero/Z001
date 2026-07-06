*&---------------------------------------------------------------------*
*& Report  ZFI_CONTAB_CASTIGOS
*&
*&---------------------------------------------------------------------*
*& Descripción: Contabilizacion de castigos
*& Autor      : Elias Sobarzo M.  (Visionone)
*& Fecha      : 21.11.2011
*&**********************************************************************
*& Modificaciones:
*& Autor      : Ramón Vasquez.    (Visionone)
*& Fecha      : 10.09.2014
*&
*&---------------------------------------------------------------------*
REPORT  zfi_contab_castigos.
TYPE-POOLS rsds.

*V1 10-09-2014
*CONSTANTS: c_period_prev(3) VALUE '-21'.
TABLES bseg.

DATA: trange               TYPE rsds_trange,
      trange_line          LIKE LINE OF trange,
      trange_frange_t_line LIKE LINE OF trange_line-frange_t,
      trange_frange_t_selopt_t_line
        LIKE LINE OF trange_frange_t_line-selopt_t,
      texpr TYPE rsds_texpr.

DATA l_fechini LIKE bseg-ZFBDT.
DATA l_gjahr_i TYPE gjahr.
DATA l_gjahr_f TYPE gjahr.

TYPES: BEGIN OF ty_bsid,
bukrs LIKE bsid-bukrs,
gjahr LIKE bsid-gjahr,
belnr LIKE bsid-belnr,
vertn LIKE bsid-vertn.
TYPES: END OF ty_bsid.

TYPES: BEGIN OF ty_contrat,
vertn LIKE bseg-vertn,
kunnr LIKE bseg-kunnr.
TYPES: END OF ty_contrat.

DATA gt_contrat TYPE STANDARD TABLE OF ty_contrat.
DATA gt_bsid TYPE STANDARD TABLE OF ty_bsid.
FIELD-SYMBOLS <fs_contrat> TYPE ty_contrat.
DATA r_kunnr  TYPE RANGE OF kunnr.
DATA r_kunnr_line  LIKE LINE OF r_kunnr.
DATA r_bukrs  TYPE RANGE OF bukrs.
DATA r_bukrs_line  LIKE LINE OF r_bukrs.
**--
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS:p_bukrs LIKE bseg-bukrs OBLIGATORY,
           p_ZFBDT LIKE bseg-ZFBDT OBLIGATORY,
*V1 10-09-2014
           P_dias  LIKE bseg-ZBD1T OBLIGATORY.
**-Parametrso ocultos.
PARAMETERS:
 p_bschl LIKE bseg-bschl DEFAULT '01' NO-DISPLAY,
 p_koart LIKE bseg-koart DEFAULT 'D' NO-DISPLAY,
 p_augbl LIKE bseg-augbl DEFAULT space NO-DISPLAY,
 p_vertn LIKE bseg-vertn DEFAULT space NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON p_ZFBDT.
  IF NOT ( p_ZFBDT LE sy-datum ).
    MESSAGE 'Fecha selección debe ser menor o igual a hoy'(003) TYPE 'E'.
  ENDIF.

START-OF-SELECTION.
*
  l_gjahr_f = sy-datum(4).
  l_gjahr_i = l_gjahr_f - 3.
  SELECT DISTINCT bukrs gjahr  belnr vertn
    FROM bsid
    INTO  CORRESPONDING FIELDS OF TABLE gt_bsid
    WHERE bukrs EQ p_bukrs
     AND gjahr BETWEEN l_gjahr_i AND l_gjahr_f
     AND zumsk EQ space
     AND vertn NE p_vertn.
*
  if p_dias > 0.
     p_dias = p_dias * -1.
  Endif.
*
  IF sy-subrc NE 0.
    MESSAGE 'No existen registros para los parametros ingresados'(002) TYPE 'I'.
  ELSE.
    CALL FUNCTION 'SG_PS_ADD_MONTH_TO_DATE'
      EXPORTING
        months  = P_dias
        olddate = p_ZFBDT
      IMPORTING
        newdate = l_fechini.

    SELECT vertn kunnr
      INTO CORRESPONDING FIELDS OF TABLE gt_contrat
      FROM bseg
      FOR ALL ENTRIES IN gt_bsid
      WHERE bukrs EQ gt_bsid-bukrs AND
            gjahr EQ gt_bsid-gjahr AND
            belnr EQ gt_bsid-belnr AND
            bschl EQ p_bschl AND
            koart EQ p_koart AND
            augbl EQ p_augbl AND
            vertn EQ gt_bsid-vertn AND
*           FDTAG LE l_fechini.
            ZFBDT LE l_fechini.
*
    IF sy-subrc NE 0.
      MESSAGE 'No existen registros para los parametros ingresados'(002) TYPE 'I'.
    ELSE.
      DELETE ADJACENT DUPLICATES FROM gt_contrat COMPARING vertn .
*
      trange_line-tablename                = 'BSID'.
      trange_frange_t_line-fieldname       = 'VERTN'.
      trange_frange_t_selopt_t_line-sign   = 'I'.
      trange_frange_t_selopt_t_line-option = 'EQ'.
      LOOP AT gt_contrat ASSIGNING <fs_contrat>.
        trange_frange_t_selopt_t_line-low    = <fs_contrat>-vertn.
        APPEND trange_frange_t_selopt_t_line  TO trange_frange_t_line-selopt_t.
      ENDLOOP.
      APPEND trange_frange_t_line           TO trange_line-frange_t.
*
      REFRESH trange_frange_t_line-selopt_t[].
      trange_frange_t_line-fieldname       = 'AUGBL'.
      trange_frange_t_selopt_t_line-sign   = 'I'.
      trange_frange_t_selopt_t_line-option = 'EQ'.
      trange_frange_t_selopt_t_line-low    = space.
      APPEND trange_frange_t_selopt_t_line  TO trange_frange_t_line-selopt_t.
      APPEND trange_frange_t_line           TO trange_line-frange_t.
*
*
      APPEND trange_line                    TO trange.
**-
      CALL FUNCTION 'FREE_SELECTIONS_RANGE_2_EX'
        EXPORTING
          field_ranges = trange
        IMPORTING
          expressions  = texpr.

**-
      REFRESH r_bukrs .CLEAR r_bukrs.
      r_bukrs_line-sign   = 'I'.
      r_bukrs_line-option = 'EQ'.
      r_bukrs_line-low    = p_bukrs.
      APPEND r_bukrs_line TO r_bukrs.

    REFRESH r_kunnr .CLEAR r_kunnr.
    SORT gt_contrat BY kunnr.
    DELETE ADJACENT DUPLICATES FROM gt_contrat COMPARING kunnr .
    LOOP AT gt_contrat ASSIGNING <fs_contrat>.
      r_kunnr_line-sign   = 'I'.
      r_kunnr_line-option = 'EQ'.
      r_kunnr_line-low    = <fs_contrat>-kunnr.
      APPEND r_kunnr_line TO r_kunnr.
    ENDLOOP.
*
    SUBMIT rfitemar                                      "#EC CI_SUBMIT
         WITH FREE SELECTIONS texpr
         WITH dd_bukrs   IN r_bukrs
         WITH  dd_kunnr IN r_kunnr
    AND RETURN.
  ENDIF.
ENDIF.

END-OF-SELECTION.
