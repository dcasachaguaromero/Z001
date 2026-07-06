*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <27-12-2019> *
*& Transport Number: < ECDK916978 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report         ZFIMDP020
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT  zfimdp020 MESSAGE-ID z001.

TABLES: zpayr, bkpf, payr, tbtco, zjdatos_edocheq, reguh,regup,
        zcambiocheque.
RANGES: t_cta FOR bseg-hkont.
TYPE-POOLS: slis.
FIELD-SYMBOLS: <f>.

CONSTANTS: cntl_true   TYPE i VALUE 1,
           cntl_false  TYPE i VALUE 0,
           g_desf(51)  TYPE c VALUE 'Fecha Emisión de Cheque Posterior a Fecha Ejecución'.

DATA: return           LIKE bapiret2 OCCURS 0 WITH HEADER LINE.
DATA: t_rpt(1)         TYPE c.
DATA: bukrs_aux        LIKE bkpf-bukrs.
DATA: sw_bi(01)        TYPE c.
DATA: g_little(40)     TYPE c.
DATA: v_xblnr          LIKE bkpf-xblnr.

DATA: h_picture        TYPE REF TO cl_gui_picture,
      h_pic_container  TYPE REF TO cl_gui_custom_container,
      g_datum          LIKE sy-datum,
      v_primera(1),
      v_correlativo(4) TYPE n.

DATA: graphic_size     TYPE i.
DATA: t_radio_01(1)    TYPE c,
      t_radio_02(1)    TYPE c.

DATA: user_command     LIKE sy-ucomm,
      save_code        LIKE sy-ucomm.

DATA: graphic_url(255),
      graphic_refresh(1),
      g_result         LIKE cntl_true.

DATA  des_cta(51)      TYPE c.
DATA  g_exis(1)        TYPE c.
DATA  errorfechacontab(1).
DATA  agencia_aux(4)   TYPE n.
DATA  zzmot_emis_aux   LIKE bseg-zzmot_emis.
DATA: g_valid_cta      TYPE i.

DATA: group(30)        TYPE c,
      lote(12),
      grupo            LIKE apqi-groupid.
DATA: g_voidr          TYPE payr-voidr.
DATA: g_bldat          TYPE bldat.
DATA: g_newbs          TYPE bbseg-newbs.
DATA: p_zmot_emis      TYPE bseg-zzmot_emis,
      motemi           TYPE bseg-zzmot_emis,
      juegodatos       LIKE zjdatos_edocheq-jdatos.

DATA: it_reversa       LIKE zreversacheque OCCURS 0 WITH HEADER LINE.

DATA: aux(1).

DATA: ti_zctap         LIKE zcta_prescrip OCCURS 0 WITH HEADER LINE.

DATA: v_index          LIKE sy-tabix,
      v_errorfechareval(1),
      v_erroragencia(1),
      wa_secuen        LIKE zjdatos_secuen,
      nro_secuencia(6) TYPE n.

DATA: BEGIN OF graphic_table OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table.

DATA: BEGIN OF tab OCCURS 0,
        fcode LIKE rsmpe-func,
      END OF tab.

DATA: BEGIN OF itab,
        field1(5) TYPE c,
        field2(5) TYPE c,
        field3(5) TYPE p DECIMALS 2,
      END OF itab.

DATA: BEGIN OF itab1 OCCURS 0.
        INCLUDE STRUCTURE itab.
DATA: END OF itab1.

DATA: BEGIN OF t_control OCCURS 0,
        juego LIKE tbtco-jobname,
        chect LIKE payr-chect,
      END OF t_control.

*PYV Cambio de Pantalla
*selection-screen begin of screen 0101 as subscreen.
*select-options: psel for zpayr-chect.
*selection-screen end of screen 0101.
*PYV Cambio de Pantalla

DATA: BEGIN OF t_ok OCCURS 0,
  box(1),
  bukrs        LIKE  bseg-bukrs,
  belnr        LIKE  bseg-belnr,
  buzei        LIKE  bseg-buzei,
  gjahr        LIKE  bseg-gjahr,
  hkont        LIKE  bseg-hkont,
  status       LIKE  icon-id,
  chek1(1)     TYPE  c,
  wrbtr        LIKE  bseg-wrbtr,
  waers        LIKE  bkpf-waers,
  chect        LIKE  payr-chect,
  hkontd       LIKE  bseg-hkont, " se deja cuenta de destino.
  sgtxt        LIKE  bseg-sgtxt, " TEXTO
  datev        TYPE  i,
  estado(51)   TYPE  c,
  vblnr        LIKE  payr-vblnr,
  bldat        LIKE  bkpf-bldat,
  lifnr        LIKE  payr-lifnr,
  budat        LIKE  bkpf-budat,
  zaldt        LIKE  payr-zaldt,
  znme1        LIKE  payr-znme1,
  zmote        LIKE  bseg-zzmot_emis,
  sortl        LIKE  lfa1-sortl,
  jdatos(16)   TYPE  c,
  nro(6)       TYPE  n,
  zagencia     LIKE  bseg-zz_agencia,
  zzdescr      LIKE  zagencia-zzdescr,
  secuencia(6) TYPE  n,
  lote(16)     TYPE  c,
END OF t_ok.

DATA : p_mes    TYPE t001b-frpe1,
        p_gjahr  TYPE t001b-frye1,
        t_e_oper  TYPE t001b-frpe1.

*DATA  hbkid        TYPE hbkid.
*DATA  bukrs        TYPE bukrs.
*DATA  hktid        TYPE hktid.
*DATA  chect        TYPE chect.

*- Tabla de parámetros pa' "submitir" el RSBDCSUB. -*
DATA: BEGIN OF i_tablsubm OCCURS 0.
        INCLUDE STRUCTURE rsparams.
DATA: END OF i_tablsubm.


*PYV Pantalla
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
SELECTION-SCREEN SKIP.
PARAMETERS: bukrs TYPE bukrs OBLIGATORY.
PARAMETERS: hbkid TYPE t012-hbkid OBLIGATORY.
PARAMETERS: hktid TYPE t012k-hktid OBLIGATORY.
PARAMETERS: budat TYPE bkpf-budat OBLIGATORY DEFAULT sy-datum.
SELECT-OPTIONS: psel FOR zpayr-chect.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN END OF BLOCK block1.
*PYV Pantalla

AT SELECTION-SCREEN ON bukrs.
  PERFORM tcc_modify_bukrs.

AT SELECTION-SCREEN ON hbkid.
  PERFORM tcc_modify_hbkid.

AT SELECTION-SCREEN ON hktid.
  PERFORM tcc_modify_hktid.

AT SELECTION-SCREEN ON budat.
  PERFORM tcc_modify_budat.

AT SELECTION-SCREEN ON psel.
  PERFORM tcc_modify_psel.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR hktid.
  PERFORM module_match1.

START-OF-SELECTION.

  t_rpt = 'C'.
  g_newbs = '50'.
*  bkpf-budat = sy-datum.
  bkpf-budat = budat.

  p_gjahr = bkpf-budat+0(4).
  p_mes  =   bkpf-budat+4(2).



  CALL FUNCTION 'FI_PERIOD_CHECK'
    EXPORTING
      i_bukrs          = bukrs
      i_gjahr          = p_gjahr
      i_koart          = '+'
      i_konto          = '+'
      i_monat          = p_mes
    IMPORTING
      e_oper           = t_e_oper
    EXCEPTIONS
      error_period     = 1
      error_period_acc = 2
      invalid_input    = 3
      OTHERS           = 4.

  IF sy-subrc <> 0.

    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.




    REFRESH: t_ok.
    CLEAR: t_ok.
    PERFORM caduca_elec_indiv TABLES psel
                                     t_ok
                              USING  bukrs hbkid hktid bkpf-budat.
    PERFORM reporte.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  ZRESERVACHEQUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_TABLSUBM  text
*----------------------------------------------------------------------*
FORM zreserva  USING    p_i_tablsubm.

*PYV

  DATA : p_horap TYPE sy-uzeit.
  DATA : it_bseg LIKE bseg OCCURS 0 WITH HEADER LINE.

  IF p_i_tablsubm IS  INITIAL.
    EXIT.
  ENDIF.

  MOVE sy-uzeit TO p_horap.

  CLEAR it_reversa.
  REFRESH it_reversa.

  IF t_ok-status EQ '@08@' AND t_ok-box EQ 'X'.

*     SE RESCATA ULTIMO DOCUMENTO REALIZADO
    SELECT * INTO TABLE it_bseg
      FROM bseg
     WHERE bukrs EQ bukrs
       AND belnr EQ t_ok-belnr
       AND gjahr EQ t_ok-gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916978*
*       AND buzei EQ t_ok-buzei.
       AND buzei EQ t_ok-buzei ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 27/12/2019 EY_DES01 ECDK916978*

    IF aux = 'X'.
      SELECT SINGLE xblnr INTO zcambiocheque-xblnr
        FROM zcambiocheque
        WHERE xblnr = v_xblnr.

      IF sy-subrc EQ 0.
        SELECT SINGLE belnr INTO bkpf-belnr
        FROM bkpf
        WHERE bukrs = t_ok-bukrs
          AND gjahr = t_ok-gjahr
          AND xblnr = zcambiocheque-xblnr.

        IF sy-subrc EQ 0.
          it_reversa-belnract = bkpf-belnr.
        ENDIF.
      ENDIF.
    ELSE.
      IF sy-subrc EQ 0.
        LOOP AT it_bseg.
          MOVE  it_bseg-augbl TO  it_reversa-belnract.
        ENDLOOP.
      ENDIF.
    ENDIF.

    MOVE :
      sy-uname    TO it_reversa-codusuario,
      bukrs       TO it_reversa-bukrs,
      hbkid       TO it_reversa-hbkid,
      hktid       TO it_reversa-hktid,
      bkpf-budat  TO it_reversa-budat,
      'N'         TO it_reversa-estrever,
      sy-datum    TO it_reversa-fecproceso,
      p_horap     TO it_reversa-horaproceso,
      t_ok-belnr  TO it_reversa-belnr,
      t_ok-buzei  TO it_reversa-buzei,
      t_ok-gjahr  TO it_reversa-gjahr,
      t_ok-hkont  TO it_reversa-hkont,
      t_ok-wrbtr  TO it_reversa-wrbtr,
      t_ok-waers  TO it_reversa-waers,
      t_ok-chect  TO it_reversa-chect,
      t_ok-hkontd TO it_reversa-hkontd,
      t_ok-estado TO it_reversa-estado,
      t_ok-vblnr  TO it_reversa-vblnr,
      t_ok-bldat  TO it_reversa-bldat,
      t_ok-lifnr  TO it_reversa-lifnr,
      t_ok-zaldt  TO it_reversa-zaldt,
      t_ok-zmote  TO it_reversa-zmote.

    APPEND it_reversa.
  ENDIF.

  IF it_reversa[] IS NOT INITIAL.
*   SE BUSCAN LOS CHEQUES PARA PINTAR LOS CHEQUES PROCESADOS ANTERIORMENTE
*    PERFORM MARCA_CHEQUES_ANT.
*   SE INSERTA EN ZREVERSACHEQUE *****************************************
    LOOP AT it_reversa.
      INSERT into zreversacheque
       values it_reversa.
*      IF SY-SUBRC eq 0.
**        MESSAGE 'Problemas al Guardar registros en Tabla : ZREVERSACHEQUE' TYPE 'W'.
*
*      ENDIF.
      COMMIT WORK AND WAIT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " ZRESERVACHEQUE

*&---------------------------------------------------------------------*
*&      Form  tcc_modify_bukrs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM tcc_modify_bukrs.

*PYV

  DATA: e_record  LIKE  t001,
        e_valid(1) TYPE c.

  IF bukrs NE space.
    CALL FUNCTION 'VALIDATE_COMPANY_CODE'
      EXPORTING
        i_company  = bukrs
      IMPORTING
        e_record   = e_record
        e_valid    = e_valid
      EXCEPTIONS
        incomplete = 1
        OTHERS     = 2.
    IF e_valid = 0.
      MESSAGE e001 WITH bukrs.
    ENDIF.
  ENDIF.

ENDFORM.                    "tcc_modify_bukrs

*&---------------------------------------------------------------------*
*&      Form  tcc_modify_hbkid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM tcc_modify_hbkid.

*PYV

  DATA: gt_t012k TYPE STANDARD TABLE OF t012k.

  IF hbkid NE space AND bukrs NE space.
    SELECT * FROM t012k INTO TABLE gt_t012k
            WHERE bukrs = bukrs
            AND   hbkid = hbkid.
    IF sy-subrc NE 0.
      MESSAGE e002 WITH hbkid bukrs.
    ENDIF.
  ENDIF.

ENDFORM.                    "tcc_modify_hbkid

*&---------------------------------------------------------------------*
*&      Form  tcc_modify_hktid
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM tcc_modify_hktid.

*PYV

  DATA: gt_t012k TYPE STANDARD TABLE OF t012k.

  IF hbkid NE space AND  hktid NE space AND bukrs NE space.
    SELECT * FROM t012k INTO TABLE gt_t012k
           WHERE bukrs = bukrs
           AND   hbkid = hbkid
           AND   hktid = hktid.
    IF sy-subrc NE 0.
      MESSAGE e003 WITH bukrs hbkid hktid.
    ENDIF.
  ENDIF.

ENDFORM.                    "tcc_modify_hktid

*&---------------------------------------------------------------------*
*&      Form  tcc_modify_budat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM tcc_modify_budat.

*PYV

  IF budat IS INITIAL.
    MESSAGE e005.
  ENDIF.

ENDFORM.                    "tcc_modify_budat

*&---------------------------------------------------------------------*
*&      Form  tcc_modify_psel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM tcc_modify_psel.

*PYV

  IF psel[] IS INITIAL.
    MESSAGE e006.
  ENDIF.

ENDFORM.                    "tcc_modify_psel

*&---------------------------------------------------------------------*
*&      Form  module_match1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM module_match1.

*PYV

  DATA:  dyfields LIKE dynpread OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF list_of_fields1 OCCURS 10,
  fieldname LIKE dd03l-fieldname,
  END OF list_of_fields1.

  DATA : indice1 LIKE sy-tabix,
  fieldname1 LIKE dd03l-fieldname,
  fields1 LIKE help_value OCCURS 10 WITH HEADER LINE,
  shrinkfields1 LIKE dynpread OCCURS 0 WITH HEADER LINE,
  dynpfields1 LIKE dynpread OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF ti_cta_cte OCCURS 0,
  bukrs LIKE t012k-bukrs,
  hbkid LIKE t012k-hbkid,
  hktid LIKE t012k-hktid,
  END OF ti_cta_cte.

  REFRESH: dyfields, list_of_fields1,fields1, shrinkfields1,dynpfields1.

  dyfields-fieldname = 'BUKRS'.
  APPEND dyfields.
  dyfields-fieldname = 'HBKID'.
  APPEND dyfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = sy-cprog
      dynumb     = sy-dynnr
    TABLES
      dynpfields = dyfields.

  IF sy-subrc = 0.
    READ TABLE dyfields WITH KEY fieldname = 'BUKRS'.
    IF sy-subrc EQ 0.
      bukrs = dyfields-fieldvalue.
    ENDIF.
    READ TABLE dyfields WITH KEY fieldname = 'HBKID'.
    IF sy-subrc EQ 0.
      hbkid = dyfields-fieldvalue.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
    TABLES
      dynpfields           = dyfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      undefind_error       = 7
      OTHERS               = 8.
  IF sy-subrc <> 0.
  ENDIF.

  TRANSLATE bukrs TO UPPER CASE.
  TRANSLATE hbkid TO UPPER CASE.

  SELECT bukrs hbkid hktid
    INTO CORRESPONDING FIELDS OF TABLE ti_cta_cte
    FROM t012k
    WHERE bukrs EQ bukrs
      AND hbkid EQ hbkid.

  list_of_fields1-fieldname = 'T012K-BUKRS'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'T012K-HBKID'.
  APPEND list_of_fields1.
  list_of_fields1-fieldname = 'T012K-HKTID'.
  APPEND list_of_fields1.

  fieldname1 = 'HKTID'.

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
      titel                        = 'Cuenta Corriente'
      use_user_selections          = 'S'
    IMPORTING
      ind                          = indice1
    TABLES
      fields                       = fields1
      full_table                   = ti_cta_cte
      user_sel_fields              = shrinkfields1
    EXCEPTIONS
      full_table_empty             = 01
      no_tablestructure_given      = 02
      no_tablefields_in_dictionary = 03
      more_than_one_selectfield    = 04
      no_electfield                = 05.
  IF sy-subrc = 0.
    READ TABLE ti_cta_cte INDEX indice1.
    MOVE ti_cta_cte-hktid TO hktid.

    SET PARAMETER ID '01' FIELD  ti_cta_cte-bukrs.
    SET PARAMETER ID '02' FIELD  ti_cta_cte-hbkid.
    SET PARAMETER ID '03' FIELD  ti_cta_cte-hktid.
  ENDIF.

ENDFORM.                    "module_match1

INCLUDE zfimdp0020_2.

INCLUDE zfimdp0020_4_new.
