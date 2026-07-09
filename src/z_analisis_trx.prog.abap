*&---------------------------------------------------------------------*
*& Report  Z_ANALISIS_TRX
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  z_analisis_trx.

TYPES: BEGIN OF yclasif_prog1,
    mandt TYPE mandt,
    progname TYPE progname,
    programtitle TYPE rs38l_ftxt,
    subc TYPE subc,
    solo TYPE xflag,
    transacz TYPE char80,
    transacs TYPE char120,
    alv TYPE xflag,
    xwrite TYPE xflag,
    tty TYPE xflag,
    bi TYPE xflag,
    di TYPE xflag,
    bapi TYPE xflag,
    funcionz TYPE xflag,
    tablaz TYPE xflag,
    tablas TYPE xflag,
    autori TYPE xflag,
    modifz TYPE xflag,
    modifs TYPE xflag,
    query TYPE xflag,
    sube_arch TYPE xflag,
    baja_arch TYPE xflag,
    submit TYPE xflag,
    job TYPE xflag,
    modtablas TYPE ufps_posid,
    modotros TYPE xflag,
  END OF yclasif_prog1.


TYPES: BEGIN OF ty_usertcode,
*        include structure ystadtrx_mes.
        mandt     TYPE 	mandt,
        mes_anio  TYPE  char08,
        dest      TYPE  text10,
        usuario   TYPE 	sapwlutacc,
        v_id      TYPE  char10,
        tcode     TYPE  tcode,
        report    TYPE  program_id,
        prog      TYPE  program_id,
        nom_job   TYPE  program_id,
        des       TYPE  repti,
        ktext     TYPE  appltxt,
        contador  TYPE  int4,
         END OF ty_usertcode.

TYPES: BEGIN OF ty_program,
          report    TYPE program_id,
          prog      TYPE program_id,
          nom_job   TYPE program_id,
          des       TYPE trdirt-text,
          modulo    TYPE ufps_posid,
          contador  TYPE text10,
          ok        TYPE c,
       END OF ty_program,
       BEGIN OF ty_program_t,
          mes_anio  TYPE char8,
          usuario   TYPE sapwlutacc,
          report    TYPE program_id,
          prog      TYPE program_id,
          nom_job   TYPE program_id,
          des       TYPE trdirt-text,
          modulo    TYPE ufps_posid,
          contador  TYPE text10,
          ok        TYPE c,
       END OF ty_program_t.
* Structure for collecting the first date of each month
* of the given year **

TYPES: BEGIN OF ty_year,
          date TYPE sy-datum,
          ok   TYPE c,
       END OF ty_year.

*********** Structure for collecting the title text of Report ******

TYPES: BEGIN OF ty_trdirt,
          name TYPE trdirt-name,
          text TYPE trdirt-text,
       END OF ty_trdirt.

********** Structure for identifying the program name associated with
********** the transaction and the title text of the transaction **

TYPES: BEGIN OF ty_tstc,
          tcode TYPE tstc-tcode,
          pgmna TYPE tstc-pgmna,
          ttext TYPE tstct-ttext,
       END OF ty_tstc.

******************************************************

********* Internal tables and Work area declaration *******

DATA: it_usertcode TYPE STANDARD TABLE OF sapwlustcx,
      wa_usertcode TYPE sapwlustcx,
      it_result    TYPE STANDARD TABLE OF ty_usertcode,
      wa_result    TYPE ty_usertcode,
      it_final     TYPE STANDARD TABLE OF ty_usertcode,
      wa_final     TYPE ty_usertcode,
      it_year      TYPE STANDARD TABLE OF ty_year,
      wa_year      TYPE ty_year,
      it_trdirt    TYPE STANDARD TABLE OF ty_trdirt,
      wa_trdirt    TYPE ty_trdirt,
      it_tstc      TYPE STANDARD TABLE OF ty_tstc,
      wa_tstc      TYPE ty_tstc,
      it_program   TYPE STANDARD TABLE OF ty_program,
      wa_program   TYPE ty_program,
      it_program_t TYPE STANDARD TABLE OF ty_program_t,
      wa_program_t TYPE ty_program_t,
      it_reportes  TYPE yclasif_prog1 OCCURS 0 WITH HEADER LINE. "LIKE yclasif_prog1 OCCURS 0 WITH HEADER LINE.

***************************************************************
********* Internal table declaration for ALV ****************

DATA: it_field_catalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      it_sort TYPE slis_t_sortinfo_alv WITH HEADER LINE.
*****************************************************************

**************** Data Declaration ***************************
DATA: v_pos TYPE i,
      v_appl        TYPE taplp-appl,
      v_ktext       TYPE taplt-atext,
      v_host        TYPE sy-host,
      v_apserver    TYPE tpfid-apserver,
      v_name        TYPE sapwlserv-name,
      v_name1       TYPE sapwlserv-name,
      month         TYPE dats,
      mes(2)        TYPE n,
      l_tabix       LIKE sy-tabix,
      wa_prog_name  TYPE program_id,
      it_usertcode1 TYPE TABLE OF swncaggusertcode,
      v_sysid       TYPE swncsysid.

*****************************************************************

*************** Selection Screen ****************************

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-003.

************* Object selection (Standard/Custom) ************

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
PARAMETERS: p_all RADIOBUTTON GROUP g2.
PARAMETERS: p_custom RADIOBUTTON GROUP g2 DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b4.

*****************************************************************
************* Year selection ********************************

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.
PARAMETER: year(4) TYPE n OBLIGATORY DEFAULT sy-datum(4).
PARAMETER: mesp(2) TYPE n OBLIGATORY DEFAULT sy-datum+4(2).
PARAMETER: dest(10) TYPE c DEFAULT sy-sysid. "OBLIGATORY DEFAULT 'PRD_UPT'.
*PARAMETERS type_p   TYPE sapwlaccpt OBLIGATORY DEFAULT 'M'.
SELECTION-SCREEN END OF BLOCK b2.

*****************************************************************
************* Instance selection ****************************

*SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-002.
*PARAMETERS: p_appl RADIOBUTTON GROUP g1.
*PARAMETERS: p_total RADIOBUTTON GROUP g1 DEFAULT 'X'.
*SELECTION-SCREEN END OF BLOCK b3.

*****************************************************************
************* Instance selection ****************************

SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE text-003.
PARAMETERS: p_rep01 RADIOBUTTON GROUP g5 DEFAULT 'X'.
PARAMETERS: p_rep02 RADIOBUTTON GROUP g5 .
PARAMETERS: p_rep03 RADIOBUTTON GROUP g5 .
SELECTION-SCREEN END OF BLOCK b5.
*****************************************************************
SELECTION-SCREEN END OF BLOCK b1.

*****************************************************************

**************** Start of Selection Event *******************

START-OF-SELECTION.
  IF sy-batch EQ 'X'.
    year = sy-datum(4).
    mesp = sy-datum+4(2).
  ENDIF.
*** Calling a subroutine to collect the first date of each month
  PERFORM month TABLES it_year USING year.
****************** Finding the instance name
  v_host = sy-host.
  v_name = 'TOTAL'.
  mes    = mesp - 1.

*********** Finding all transactions and reports executed
****  LOOP AT it_year INTO wa_year WHERE date+4(2) LT mes.
****    MOVE sy-tabix TO l_tabix.
****    CONCATENATE wa_year-date+4(2) '-' wa_year-date(4)
****                                         INTO wa_result-mes_anio.
****    SELECT * APPENDING TABLE it_final
****           FROM ystadtrx_mes WHERE mes_anio EQ wa_result-mes_anio AND
****                                   dest     EQ dest.
****    CHECK sy-subrc EQ 0.
****    wa_year-ok = 'X'.
****    MODIFY it_year FROM wa_year INDEX l_tabix.
****  ENDLOOP.
**********  in the given year *****************
  CLEAR : wa_year.
  LOOP AT it_year INTO wa_year WHERE ok IS INITIAL.
*** Retrieving the workload user statistics for each month
    v_sysid      = sy-sysid.


    CALL FUNCTION 'SAPWL_WORKLOAD_GET_STATISTIC' DESTINATION dest
      EXPORTING
        periodtype            = 'M'
        startdate             = wa_year-date
        instance              = v_name
      TABLES
        application_statistic = it_usertcode
      EXCEPTIONS
        unknown_periodtype    = 1
        no_data_found         = 2
        no_server_given       = 3
        OTHERS                = 4.

    IF p_all = 'X'.
*** Retrieving the 'Dialog' (Reports and Transactions) task type
*** details (Both standard and custom objects)
      CLEAR : wa_usertcode, wa_result.
      LOOP AT it_usertcode INTO wa_usertcode.      "WHERE ttype = 1.
*** Retrieving the user who executed the object
        wa_result-usuario = wa_usertcode-account.
*** Checking if the Object is a Transaction or a Report
        IF wa_usertcode-entry_id+72 = 'T'.
          wa_result-v_id = 'TCODE'.
          wa_result-tcode = wa_usertcode-entry_id.
        ELSE.
          wa_result-v_id = 'REPORT'.
          wa_result-report = wa_usertcode-entry_id.
        ENDIF.
*** Retrieving the dialog count of the object execution
        wa_result-contador = wa_usertcode-dcount.
        CONCATENATE wa_year-date+4(2) '-' wa_year-date(4)
                                             INTO wa_result-mes_anio.
        COLLECT wa_result INTO it_result.
        CLEAR : wa_usertcode, wa_result.
      ENDLOOP.
    ELSEIF p_custom = 'X'.
*** Retrieving the 'Dialog' (Reports and Transactions) task type
*** details (Only Custom objects (Y and Z))
      CLEAR : wa_usertcode, wa_result.
      LOOP AT it_usertcode INTO wa_usertcode
                         WHERE ( ttype = 1 OR ttype = 4 ) AND
                               ( entry_id CP 'Y*' OR entry_id CP 'Z*' ).
*** Retrieving the user who executed the object
        wa_result-usuario = wa_usertcode-account.
*** Checking if the Object is a Transaction or Report
        CASE wa_usertcode-ttype.
          WHEN 1.
            IF wa_usertcode-entry_id+72 = 'T'.
              wa_result-v_id  = 'TCODE'.
              wa_result-tcode = wa_usertcode-entry_id.
            ELSE.
              wa_result-v_id   = 'REPORT'.
              wa_result-report = wa_usertcode-entry_id.
            ENDIF.
          WHEN 4.
            wa_result-v_id     = 'JOB_REPORT'.
            wa_result-report   = wa_usertcode-entry_id(40).
            wa_result-prog     = wa_usertcode-entry_id(40).
            wa_result-nom_job  = wa_usertcode-entry_id+40(31).
            CHECK  wa_result-nom_job CP 'Y*' OR
                   wa_result-nom_job CP 'Z*'.
        ENDCASE.
*** Retrieving the dialog count of the object execution
        wa_result-contador = wa_usertcode-dcount.
        CONCATENATE wa_year-date+4(2) '-' wa_year-date(4)
                                             INTO wa_result-mes_anio.
        COLLECT wa_result INTO it_result.
        CLEAR : wa_usertcode, wa_result.
      ENDLOOP.
    ENDIF.
    REFRESH it_usertcode.
    CLEAR : wa_year.
  ENDLOOP.
*** Retrieving the title text of Report
  IF NOT it_result[] IS INITIAL.
    REFRESH : it_trdirt.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT name text INTO TABLE it_trdirt
*            FROM trdirt  FOR ALL ENTRIES IN it_result
*               WHERE name  = it_result-report AND
*                     sprsl = sy-langu.
*
* NEW CODE
    SELECT name text
 INTO TABLE it_trdirt
            FROM trdirt  FOR ALL ENTRIES IN it_result
               WHERE name  = it_result-report AND
                     sprsl = sy-langu ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDIF.
*** Identifying the program name associated with the transaction and the title text of the Transaction
  IF NOT it_result[] IS INITIAL.
    REFRESH : it_tstc.
    SELECT a~tcode a~pgmna b~ttext INTO TABLE it_tstc
         FROM tstc AS a INNER JOIN tstct AS b
                 ON a~tcode = b~tcode FOR ALL ENTRIES IN it_result
              WHERE a~tcode = it_result-tcode AND
                    b~sprsl = sy-langu.
  ENDIF.
*** Appending all the details into the internal table
  CLEAR : wa_result, wa_final, wa_prog_name, wa_trdirt, v_appl, v_ktext, wa_tstc.
  LOOP AT it_result INTO wa_result.
    CLEAR wa_final.
    wa_final-mes_anio   = wa_result-mes_anio.
    wa_final-usuario    = wa_result-usuario.
    wa_final-v_id       = wa_result-v_id.
    wa_final-contador   = wa_result-contador.
    CLEAR wa_final-nom_job.
    CASE wa_result-v_id.
      WHEN 'REPORT'.
        wa_final-prog = wa_result-report.
*** Moving the program title text into the internal table
        READ TABLE it_trdirt INTO wa_trdirt WITH KEY name = wa_result-report.
        IF sy-subrc = 0.
          SELECT SINGLE a~tcode b~ttext INTO (wa_final-report, wa_final-des )
            FROM tstc AS a INNER JOIN tstct AS b
                    ON a~tcode = b~tcode
                 WHERE a~pgmna = wa_result-report AND
                       b~sprsl = sy-langu.
          IF sy-subrc NE 0.
            wa_final-des = wa_trdirt-text.
          ELSEIF wa_final-report IS NOT INITIAL.
            wa_final-v_id = 'TCODE'.
          ENDIF.
        ENDIF.
        wa_prog_name = wa_result-report.
      WHEN 'JOB_REPORT'.
        wa_final-prog     = wa_result-prog.
        wa_final-nom_job  = wa_result-nom_job.
        READ TABLE it_trdirt INTO wa_trdirt WITH KEY name = wa_result-prog.
        IF sy-subrc = 0.
          SELECT SINGLE a~tcode b~ttext INTO (wa_final-report, wa_final-des )
            FROM tstc AS a INNER JOIN tstct AS b
                    ON a~tcode = b~tcode
                 WHERE a~pgmna = wa_final-prog  AND
                       b~sprsl = sy-langu.
          IF sy-subrc NE 0.
            wa_final-des = wa_trdirt-text.
          ELSEIF wa_final-report IS NOT INITIAL.
            wa_final-v_id = 'TCODE'.
          ENDIF.
        ENDIF.
        wa_prog_name = wa_result-report.
      WHEN 'TCODE'.
        wa_final-report = wa_result-tcode.
*** Finding the program name associated with the transaction and its text and moving them into the internal table
        READ TABLE it_tstc INTO wa_tstc WITH KEY tcode = wa_result-tcode.
        IF sy-subrc = 0.
          wa_final-prog = wa_tstc-pgmna.
          wa_final-des  = wa_tstc-ttext.
        ENDIF.
        wa_prog_name = wa_tstc-pgmna.
    ENDCASE.
*** Retrieving the application type (Module) of the Report
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE appl INTO v_appl
*          FROM trdir WHERE name = wa_prog_name.
*
* NEW CODE
    SELECT appl
    UP TO 1 ROWS  INTO v_appl
          FROM trdir WHERE name = wa_prog_name ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*** Retrieving the long text of the module
    IF NOT v_appl IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE atext INTO v_ktext
*             FROM taplt  WHERE appl  = v_appl AND
*                               sprsl = sy-langu.
*
* NEW CODE
      SELECT atext
      UP TO 1 ROWS  INTO v_ktext
             FROM taplt  WHERE appl  = v_appl AND
                               sprsl = sy-langu ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.
    wa_final-ktext = v_ktext.
    APPEND wa_final TO it_final.
    CLEAR: wa_result, wa_final, v_appl, v_ktext, wa_trdirt,
           wa_prog_name, wa_tstc.
  ENDLOOP.
*
  LOOP AT it_year INTO wa_year WHERE ok IS INITIAL.
    CONCATENATE wa_year-date+4(2) '-' wa_year-date(4)
                                         INTO wa_result-mes_anio.
    LOOP AT it_final INTO wa_final WHERE mes_anio EQ wa_result-mes_anio.
      wa_final-tcode = wa_final-report.
      wa_final-dest  = dest.
****      MODIFY ystadtrx_mes FROM wa_final.
    ENDLOOP.
  ENDLOOP.
*** Calling a subroutine for forming field catalog
  CASE 'X'.
    WHEN p_rep01.
*** Sorting the internal table
      SORT it_final BY mes_anio usuario report DESCENDING.
      PERFORM field_catalog
              TABLES it_field_catalog
              USING:
              'IT_FINAL' 'MES_ANIO' ' ' v_pos 'Mes-Año'            '10' '',
              'IT_FINAL' 'USUARIO' ' '  v_pos 'User Id'            '20' '',
              'IT_FINAL' 'V_ID' ' '     v_pos 'Object'             ''   '',
              'IT_FINAL' 'REPORT' ' '   v_pos 'Transacción o Prorama'
                                                                   '40' '',
              'IT_FINAL' 'PROG' ' '     v_pos 'Nombre Programa'    '40' '',
              'IT_FINAL' 'NOM_JOB' ' '  v_pos 'Nombre Job'         '40' '',
              'IT_FINAL' 'DES' ' '      v_pos 'Descripcion Objeto' '50' '',
*          'IT_FINAL' 'KTEXT' ' '    v_pos 'Module'             '30' '',
              'IT_FINAL' 'CONTADOR' ' ' v_pos 'pasos de Dialogo'   '15' 'X'.
*** Calling a subroutine for sorting the ALV output
      PERFORM sort.
    WHEN p_rep02.
*** Sorting the internal table
      SORT it_program BY report.
      PERFORM field_catalog
              TABLES it_field_catalog
              USING:
              'IT_PROGRAM' 'REPORT' ' '   v_pos 'Transacción'        '40' '',
              'IT_PROGRAM' 'PROG' ' '     v_pos 'Nombre Programa'    '40' '',
              'IT_PROGRAM' 'DES' ' '      v_pos 'Descripcion Objeto' '50' '',
              'IT_PROGRAM' 'NOM_JOB' ' '  v_pos 'Nombre Job'         '40' '',
              'IT_PROGRAM' 'MODULO' ' '   v_pos 'Módulo'             '15' '',
              'IT_PROGRAM' 'OK' ' '       v_pos 'Usado'              '05' '',
              'IT_PROGRAM' 'CONTADOR' ' ' v_pos 'Pasos Dialogo'      '13' ''.
    WHEN p_rep03.
*** Sorting the internal table
      SORT it_program BY report.
      PERFORM field_catalog
              TABLES it_field_catalog
              USING:
              'IT_PROGRAM_T' 'MES_ANIO' ' ' v_pos 'Mes-Año'            '10' '',
              'IT_PROGRAM_T' 'USUARIO' ' '  v_pos 'User Id'            '20' '',
              'IT_PROGRAM_T' 'REPORT' ' '   v_pos 'Transacción'        '40' '',
              'IT_PROGRAM_T' 'PROG' ' '     v_pos 'Nombre Programa'    '40' '',
              'IT_PROGRAM_T' 'DES' ' '      v_pos 'Descripcion Objeto' '50' '',
              'IT_PROGRAM_T' 'NOM_JOB' ' '  v_pos 'Nombre Job'         '40' '',
              'IT_PROGRAM_T' 'MODULO' ' '   v_pos 'Módulo'             '15' '',
              'IT_PROGRAM_T' 'OK' ' '       v_pos 'Usado'              '05' '',
              'IT_PROGRAM_T' 'CONTADOR' ' ' v_pos 'Pasos Dialogo'      '13' ''.
  ENDCASE.

*** Displaying the output table in ALV format
  IF NOT it_final[] IS INITIAL.
    CASE 'X'.
      WHEN p_rep01.
        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            i_callback_program = sy-repid
            it_fieldcat        = it_field_catalog[]
            it_sort            = it_sort[]
          TABLES
            t_outtab           = it_final
          EXCEPTIONS
            program_error      = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      WHEN p_rep02.
        LOOP AT it_final INTO wa_result WHERE prog IS NOT INITIAL.
          CHECK wa_result-prog CP 'Y*' OR wa_result-prog CP 'Z*'.
          MOVE-CORRESPONDING wa_result TO wa_program.
          COLLECT wa_program INTO it_program.
        ENDLOOP.
*
        SORT  it_program BY prog.
        DELETE ADJACENT DUPLICATES FROM it_program COMPARING prog.
****        SELECT * INTO TABLE it_reportes
****                      FROM yclasif_prog1 WHERE subc IN ('1','M').
*
****        LOOP AT it_program INTO wa_program.
****          MOVE sy-tabix TO l_tabix.
****          READ TABLE it_reportes WITH KEY progname = wa_program-prog.
****          CHECK sy-subrc NE 0.
****          DELETE it_program INDEX l_tabix.
****        ENDLOOP.
*
        LOOP AT it_reportes.
          READ TABLE it_program INTO wa_program
                                WITH KEY prog = it_reportes-progname.
          IF sy-subrc EQ 0.
            MOVE sy-tabix TO l_tabix.
            wa_program-ok     = 'X'.
            wa_program-modulo = it_reportes-modtablas.
            MODIFY it_program FROM wa_program INDEX l_tabix.
          ELSE.
            wa_program-report   = it_reportes-transacz.
            wa_program-prog     = it_reportes-progname.
            wa_program-des      = it_reportes-programtitle.
            wa_program-nom_job  = ' '.
            wa_program-ok       = ' '.
            wa_program-modulo   = it_reportes-modtablas.
            wa_program-contador = '0'.
            APPEND wa_program  TO it_program.
          ENDIF.
        ENDLOOP.
*
        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            i_callback_program = sy-repid
            it_fieldcat        = it_field_catalog[]
            it_sort            = it_sort[]
          TABLES
            t_outtab           = it_program
          EXCEPTIONS
            program_error      = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      WHEN p_rep03.
        LOOP AT it_final INTO wa_result WHERE prog IS NOT INITIAL.
          CHECK wa_result-prog CP 'Y*' OR wa_result-prog CP 'Z*'.
          MOVE-CORRESPONDING wa_result TO wa_program_t.
          COLLECT wa_program_t INTO it_program_t.
        ENDLOOP.
*
****        SELECT * INTO TABLE it_reportes
****                      FROM yclasif_prog1 WHERE subc IN ('1','M').
*
****        LOOP AT  it_program_t INTO wa_program_t.
****          MOVE sy-tabix TO l_tabix.
****          READ TABLE it_reportes WITH KEY progname = wa_final-prog.
****          CHECK sy-subrc NE 0.
****          DELETE it_program_t INDEX l_tabix.
****        ENDLOOP.
*
        LOOP AT it_reportes.
          READ TABLE it_program_t INTO wa_program_t
                                WITH KEY prog = it_reportes-progname.
          IF sy-subrc EQ 0.
            MOVE sy-tabix TO l_tabix.
            wa_program_t-ok     = 'X'.
            wa_program_t-modulo = it_reportes-modtablas.
            MODIFY it_program_t FROM wa_program_t INDEX l_tabix.
          ELSE.
            wa_program_t-report   = it_reportes-transacz.
            wa_program_t-prog     = it_reportes-progname.
            wa_program_t-des      = it_reportes-programtitle.
            wa_program_t-nom_job  = ' '.
            wa_program_t-ok       = ' '.
            wa_program_t-modulo   = it_reportes-modtablas.
            wa_program_t-contador = '0'.
            APPEND wa_program_t  TO it_program_t.
          ENDIF.
        ENDLOOP.
*
        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
          EXPORTING
            i_callback_program = sy-repid
            it_fieldcat        = it_field_catalog[]
            it_sort            = it_sort[]
          TABLES
            t_outtab           = it_program_t
          EXCEPTIONS
            program_error      = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
    ENDCASE.
  ELSE.
    WRITE:/ 'No Record Found for the year', year.
  ENDIF.
*&------------------------------------------------------------------------*
*& Subroutine for collecting the first date of each month
*&------------------------------------------------------------------------*
FORM month TABLES p_it_year STRUCTURE wa_year
           USING  p_year.
  DATA : cha(2) TYPE c VALUE '1',
         fin(2) TYPE n.
*
*  MOVE sy-datum+4(2) TO fin.
  MOVE mesp          TO fin.
  WHILE cha LE fin.
    IF cha LE 9.
      CONCATENATE p_year '0' cha '01' INTO p_it_year-date.
    ELSE.
      CONCATENATE p_year cha '01'     INTO p_it_year-date.
    ENDIF.
    cha = cha + 1.
    APPEND p_it_year.
    CLEAR p_it_year.
  ENDWHILE.
ENDFORM. " month
*&--------------------------------------------------------------------*
*& Subroutine for forming the field catalog for ALV output
*&---------------------------------------------------------------------*
FORM field_catalog TABLES i_field_catalog STRUCTURE it_field_catalog
      USING v_tabname TYPE any
            v_fieldname TYPE any
            v_key TYPE any
            v_pos TYPE any
            v_text TYPE any
            v_len TYPE any
            v_sum TYPE any.

  CLEAR i_field_catalog.

  i_field_catalog-tabname   = v_tabname.
  i_field_catalog-fieldname = v_fieldname.
  i_field_catalog-key       = v_key.
  i_field_catalog-col_pos   = v_pos.
  i_field_catalog-seltext_l = v_text.
  i_field_catalog-outputlen = v_len.
  i_field_catalog-do_sum    = v_sum.
  APPEND i_field_catalog.

  v_pos = v_pos + 1.
ENDFORM. "field_catalog
*&-----------------------------------------------------------------------------------*
*& Subroutine for sorting the ALV output based on the object type (Transaction/Report)
*&-----------------------------------------------------------------------------------*
FORM sort.

  CLEAR it_sort.
  it_sort-fieldname = 'MES_ANIO' .
  it_sort-up        = 'X' .
*  it_sort-subtot    = 'X'.
  APPEND it_sort.
*
  it_sort-fieldname = 'USUARIO' .
  it_sort-up        = 'X' .
*  it_sort-subtot    = 'X'.
  APPEND it_sort.
*
*  it_sort-fieldname = 'V_ID' .
*  it_sort-down      = 'X' .
*  it_sort-subtot    = 'X'.
*  APPEND it_sort.
ENDFORM. "sort
********************************************************************************************************


*Selection texts
*----------------------------------------------------------
* DEST         Lectura de mandante
* MESP         Haste el mes a verificar
* P_ALL         Lee todos los programas
* P_CUSTOM         Solo programas Z* e Y*
* P_REP01         Información Total
* P_REP02         Información Resumida
* P_REP03         Inf. Resumida Mes-Usuario
* YEAR         Tipo Periodo
