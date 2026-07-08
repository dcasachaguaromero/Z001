class ZCL_IM_BW_EXTRACTOR_BADI definition
  public
  final
  create public .

public section.

  interfaces IF_EX_RSU5_SAPI_BADI .

  methods CONSTRUCTOR .
  class-methods _TEMPLATE_DATASOURCE
    importing
      value(I_DATASOURCE) type RSAOT_OLTPSOURCE
      value(I_UPDMODE) type SBIWA_S_INTERFACE-UPDMODE
      value(I_T_SELECT) type SBIWA_T_SELECT
      value(I_T_FIELDS) type SBIWA_T_FIELDS
    changing
      !C_T_DATA type ANY TABLE
      !C_T_MESSAGES type RSU5_T_MESSAGES optional
    exceptions
      RSAP_BADI_EXIT_ERROR .
  methods CHECK_METHOD_EXISTS
    importing
      value(IV_METHOD) type SEOCMPNAME
    returning
      value(RV_EXIST) type FLAG .
  class-methods FI_GL_4
    importing
      value(I_DATASOURCE) type RSAOT_OLTPSOURCE
      value(I_UPDMODE) type SBIWA_S_INTERFACE-UPDMODE
      value(I_T_SELECT) type SBIWA_T_SELECT
      value(I_T_FIELDS) type SBIWA_T_FIELDS
    changing
      !C_T_DATA type ANY TABLE
      !C_T_MESSAGES type RSU5_T_MESSAGES optional
    exceptions
      RSAP_BADI_EXIT_ERROR .
protected section.
private section.

  data GT_METHODS type ZTT_METHODS .
ENDCLASS.



CLASS ZCL_IM_BW_EXTRACTOR_BADI IMPLEMENTATION.


  METHOD check_method_exists.

*reads global attribute table with all methods and retrieves a flag if a match is found
    READ TABLE gt_methods WITH KEY cmpname = iv_method TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      rv_exist = 'X'. "method found
    ELSE.
      CLEAR rv_exist.
    ENDIF.
  ENDMETHOD.


  METHOD constructor.
    DATA: lo_class          TYPE REF TO   cl_oo_object,
          lt_methods        TYPE          seo_methods,
          ls_methods_global LIKE LINE OF  gt_methods,
          lo_descr_ref      TYPE REF TO   cl_abap_typedescr,
          lv_class          TYPE seoclsname.
    FIELD-SYMBOLS: <fs_methods> LIKE LINE OF lt_methods.
*retrieve description of the class
    lo_descr_ref = cl_abap_classdescr=>describe_by_object_ref( me ).
    lv_class = lo_descr_ref->get_relative_name( ).
    TRY.
        CALL METHOD cl_oo_object=>get_instance
          EXPORTING
            clsname = lv_class
          RECEIVING
            result  = lo_class.
      CATCH cx_class_not_existent.
    ENDTRY.
    IF sy-subrc = 0.
*Read all methods
      CALL METHOD lo_class->get_methods
        EXPORTING
          public_methods_only   = seox_false
          instance_methods_only = seox_false
        RECEIVING
          result                = lt_methods.
      LOOP AT lt_methods ASSIGNING <fs_methods>.
        ls_methods_global-cmpname = <fs_methods>-cmpname.
        INSERT ls_methods_global INTO TABLE gt_methods.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD fi_gl_4.
**********************************************************
* To implement an exit for a
* datasource create your own method by copying the
* method _TEMPLATE_DATASOURCE and rename it to the name
* of your datasource. In case you enhance a Business
* Content datasource skip the 0 at the beginning (e.g.
* Datasource 0FI_GL_4 -> Method FI_GL_4
* The method is then called by the Exit Framework
*********************************************************
    CONSTANTS:
     c_spras TYPE sy-langu VALUE 'S'.
* Data Definition
    DATA: lt_sourcepackage TYPE TABLE OF dtfigl_4.
    DATA: lt_c_t_data      TYPE TABLE OF dtfigl_4.
    data: ls_sourcepackage TYPE dtfigl_4.
    FIELD-SYMBOLS: <fs_c_t_data>      TYPE dtfigl_4.

    lt_c_t_data[] = c_t_data[].

    SELECT a~bukrs a~belnr a~gjahr a~aedat a~bvorg a~cputm
           a~ldgrp a~stblg a~upddt b~buzei b~anbwa a~tcode
           a~xref2_hd b~pswbt b~hwbas " b~hwste
           b~zzprestac b~zzunid_pro b~zzdesc_est
           b~zzmot_emis b~zzrut_terc
      INTO CORRESPONDING FIELDS OF TABLE lt_sourcepackage
      FROM bkpf AS a LEFT OUTER
      JOIN bseg AS b ON
           a~bukrs = b~bukrs AND
           a~belnr = b~belnr AND
           a~gjahr = b~gjahr
      FOR ALL ENTRIES IN lt_c_t_data
      WHERE a~bukrs = lt_c_t_data-bukrs
        AND a~belnr = lt_c_t_data-belnr
        AND a~gjahr = lt_c_t_data-gjahr.
    IF sy-subrc = 0.
      LOOP AT c_t_data ASSIGNING <fs_c_t_data>.
        READ TABLE lt_sourcepackage INTO ls_sourcepackage
              WITH KEY bukrs = ls_sourcepackage-bukrs
                       belnr = ls_sourcepackage-belnr
                       gjahr = ls_sourcepackage-gjahr
                       buzei = ls_sourcepackage-buzei.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING ls_sourcepackage TO <fs_c_t_data>.
        ENDIF.
      ENDLOOP.

    ELSE.
      "Error handling
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_rsu5_sapi_badi~data_transform.
**********************************************************
* To implement an exit for a
* datasource create your own method by copying the
* method _TEMPLATE_DATASOURCE and rename it to the name
* of your datasource. In case you enhance a Business
* Content datasource skip the 0 at the beginning (e.g.
* Datasource 0FI_AR_3 -> Method FI_AR_3
* The method is then called by the Exit Framework
*********************************************************
    DATA: ls_oltpsource TYPE rsaot_s_osource,
          lo_data       TYPE REF TO data,
          lv_method     TYPE seocmpname.
    FIELD-SYMBOLS: <lt_data>       TYPE STANDARD TABLE.
* check if any data is extracted
    CHECK c_t_data IS NOT INITIAL.
*retrieve information about the Datasource
    CALL FUNCTION 'RSA1_SINGLE_OLTPSOURCE_GET'
      EXPORTING
        i_oltpsource   = i_datasource
        i_objvers      = 'A'
      IMPORTING
        e_s_oltpsource = ls_oltpsource
      EXCEPTIONS
        no_authority   = 1
        not_exist      = 2
        inconsistent   = 3
        OTHERS         = 4.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
* create data for Extract Structure
    CREATE DATA lo_data TYPE TABLE OF (ls_oltpsource-exstruct).
    ASSIGN lo_data->* TO <lt_data>.
    ASSIGN c_t_data TO <lt_data>.
* get method name for datasource
    lv_method = i_datasource.
    CASE lv_method(1).
      WHEN '0' OR '2'.
* shift by one character as methods can't start with a number
        SHIFT lv_method.
      WHEN OTHERS.
        "Do nothing
    ENDCASE.
* check method is implemented
    CHECK check_method_exists( lv_method ) = 'X'.
*execute the Datasource enhancement
    CALL METHOD (lv_method)
      EXPORTING
        i_datasource = i_datasource
        i_updmode    = i_updmode
        i_t_select   = i_t_select
        i_t_fields   = i_t_fields
      CHANGING
        c_t_data     = <lt_data>
        c_t_messages = c_t_messages.
  ENDMETHOD.


  method IF_EX_RSU5_SAPI_BADI~HIER_TRANSFORM.
  endmethod.


  METHOD _TEMPLATE_DATASOURCE.
**********************************************************
* To implement an exit for a
* datasource create your own method by copying the
* method _TEMPLATE_DATASOURCE and rename it to the name
* of your datasource. In case you enhance a Business
* Content datasource skip the 0 at the beginning (e.g.
* Datasource 0FI_AR_3 -> Method FI_AR_3
* The method is then called by the Exit Framework
*********************************************************
** Data Definition
*  DATA: lt_sourcepackage TYPE TABLE OF zoxnsp0107. "change the structure according to DS
*
*  FIELD-SYMBOLS: <fs_sourcepackage> TYPE zoxnsp0107.
*
*  lt_sourcepackage[] = c_t_data[].
*
**Custom coding starts from here.
*  CLEAR c_t_data.
*
*  DELETE lt_sourcepackage WHERE carrid(1) NE 'A'.
*
*  SELECT a~carrid
*  a~carrname
*  a~currcode
*  a~url
*  b~connid
*    INTO CORRESPONDING FIELDS OF TABLE c_t_data
*    FROM scarr AS a LEFT OUTER JOIN spfli AS b ON
*    a~carrid = b~carrid
*    FOR ALL ENTRIES IN lt_sourcepackage WHERE
*    a~carrid = lt_sourcepackage-carrid.
*  IF sy-subrc = 0.
*
*  ELSE.
*    "Error handling
*  ENDIF.
  ENDMETHOD.
ENDCLASS.
