FUNCTION zbw_fd_fi_gl_14.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_REQUNR) TYPE  SRSC_S_IF_SIMPLE-REQUNR
*"     VALUE(I_DSOURCE) TYPE  SRSC_S_IF_SIMPLE-DSOURCE OPTIONAL
*"     VALUE(I_MAXSIZE) TYPE  SRSC_S_IF_SIMPLE-MAXSIZE OPTIONAL
*"     VALUE(I_INITFLAG) TYPE  SRSC_S_IF_SIMPLE-INITFLAG OPTIONAL
*"     VALUE(I_READ_ONLY) TYPE  SRSC_S_IF_SIMPLE-READONLY OPTIONAL
*"     VALUE(I_REMOTE_CALL) TYPE  SBIWA_FLAG DEFAULT SBIWA_C_FLAG_OFF
*"  TABLES
*"      I_T_SELECT TYPE  SRSC_S_IF_SIMPLE-T_SELECT OPTIONAL
*"      I_T_FIELDS TYPE  SRSC_S_IF_SIMPLE-T_FIELDS OPTIONAL
*"      E_T_DATA STRUCTURE  ZBW_ES_FI_GL_14 OPTIONAL
*"  EXCEPTIONS
*"      NO_MORE_DATA
*"      ERROR_PASSED_TO_MESS_HANDLER
*"----------------------------------------------------------------------

* Example: DataSource for table SFLIGHT
  TABLES: sflight.

* Auxiliary Selection criteria structure
  DATA: l_s_select TYPE srsc_s_select.

  DATA: wa_data TYPE zbw_es_fi_gl_14.

*  DATA: it_bkpf TYPE STANDARD TABLE OF bkpf,
*        wa_bkpf TYPE bkpf,
*
*        it_bseg TYPE STANDARD TABLE OF bseg,
*        wa_bseg TYPE bseg.

  DATA: it_bkpf     LIKE SORTED TABLE OF bkpf
        WITH UNIQUE KEY bukrs belnr gjahr,

        it_bseg     LIKE SORTED TABLE OF bseg
        WITH UNIQUE KEY bukrs belnr gjahr buzei,

        it_bseg_add LIKE SORTED TABLE OF bseg_add
        WITH UNIQUE KEY bukrs belnr gjahr buzei.

  DATA: wa_bkpf TYPE bkpf,
        wa_bseg TYPE bseg,
        wa_bseg_add TYPE bseg_add.

* Maximum number of lines for DB table
  STATICS: s_s_if              TYPE srsc_s_if_simple,

* counter
           s_counter_datapakid LIKE sy-tabix,

* cursor
           s_cursor            TYPE cursor.
* Select ranges
  RANGES: l_r_ryear  FOR zbw_es_fi_gl_14-ryear,
          l_r_docnr  FOR zbw_es_fi_gl_14-docnr,
          l_r_rldnr  FOR zbw_es_fi_gl_14-rldnr,
          l_r_rbukrs FOR zbw_es_fi_gl_14-rbukrs,
          l_r_budat  FOR zbw_es_fi_gl_14-budat.

* Initialization mode (first call by SAPI) or data transfer mode
* (following calls) ?
  IF i_initflag = sbiwa_c_flag_on.

************************************************************************
* Initialization: check input parameters
*                 buffer input parameters
*                 prepare data selection
************************************************************************

* Check DataSource validity
    CASE i_dsource.
      WHEN 'ZBW_FD_FI_GL_14'.
      WHEN OTHERS.
        IF 1 = 2. MESSAGE e009(r3). ENDIF.
* this is a typical log call. Please write every error message like this
        log_write 'E'                  "message type
                  'R3'                 "message class
                  '009'                "message number
                  i_dsource   "message variable 1
                  ' '.                 "message variable 2
        RAISE error_passed_to_mess_handler.
    ENDCASE.

    APPEND LINES OF i_t_select TO s_s_if-t_select.

* Fill parameter buffer for data extraction calls
    s_s_if-requnr    = i_requnr.
    s_s_if-dsource = i_dsource.
    s_s_if-maxsize   = i_maxsize.

* Fill field list table for an optimized select statement
* (in case that there is no 1:1 relation between InfoSource fields
* and database table fields this may be far from beeing trivial)
    APPEND LINES OF i_t_fields TO s_s_if-t_fields.

  ELSE.                 "Initialization mode or data extraction ?

************************************************************************
* Data transfer: First Call      OPEN CURSOR + FETCH
*                Following Calls FETCH only
************************************************************************

* First data package -> OPEN CURSOR
    IF s_counter_datapakid = 0.

* Fill range tables BW will only pass down simple selection criteria
* of the type SIGN = 'I' and OPTION = 'EQ' or OPTION = 'BT'.
      LOOP AT s_s_if-t_select INTO l_s_select WHERE fieldnm = 'RYEAR'.
        MOVE-CORRESPONDING l_s_select TO l_r_ryear.
        APPEND l_r_ryear.
      ENDLOOP.

      LOOP AT s_s_if-t_select INTO l_s_select WHERE fieldnm = 'DOCNR'.
        MOVE-CORRESPONDING l_s_select TO l_r_docnr.
        APPEND l_r_docnr.
      ENDLOOP.

      LOOP AT s_s_if-t_select INTO l_s_select WHERE fieldnm = 'RLDNR'.
        MOVE-CORRESPONDING l_s_select TO l_r_rldnr.
        APPEND l_r_rldnr.
      ENDLOOP.

      LOOP AT s_s_if-t_select INTO l_s_select WHERE fieldnm = 'RBUKRS'.
        MOVE-CORRESPONDING l_s_select TO l_r_rbukrs.
        APPEND l_r_rbukrs.
      ENDLOOP.

      LOOP AT s_s_if-t_select INTO l_s_select WHERE fieldnm = 'BUDAT'.
        MOVE-CORRESPONDING l_s_select TO l_r_budat.
        APPEND l_r_budat.
      ENDLOOP.

* Determine number of database records to be read per FETCH statement
* from input parameter I_MAXSIZE. If there is a one to one relation
* between DataSource table lines and database entries, this is trivial.
* In other cases, it may be impossible and some estimated value has to
* be determined.
      OPEN CURSOR WITH HOLD s_cursor FOR
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT rclnt ryear docnr rldnr rbukrs docln activ rmvct rtcur runit
*             awtyp rrcty rvers logsys racct cost_elem rcntr prctr rfarea
*             rbusa kokrs segment zzprestac zzdesc_est zzmot_emis zzrut_terc
*             zzunid_pro zz_agencia scntr pprctr sfarea sbusa rassc psegment
*             tsl hsl ksl osl msl wsl drcrk poper rwcur gjahr budat belnr
*             buzei bschl bstat linetype xsplitmod timestamp
*        FROM faglflexa
*       WHERE ryear  IN l_r_ryear AND
*             docnr  IN l_r_docnr AND
*             rldnr  IN l_r_rldnr AND
*             rbukrs IN l_r_rbukrs AND
*             budat  IN l_r_budat.
*
* NEW CODE
      SELECT rclnt ryear docnr rldnr rbukrs docln activ rmvct rtcur runit
             awtyp rrcty rvers logsys racct cost_elem rcntr prctr rfarea
             rbusa kokrs segment zzprestac zzdesc_est zzmot_emis zzrut_terc
             zzunid_pro zz_agencia scntr pprctr sfarea sbusa rassc psegment
             tsl hsl ksl osl msl wsl drcrk poper rwcur gjahr budat belnr
             buzei bschl bstat linetype xsplitmod timestamp

        FROM faglflexa
       WHERE ryear  IN l_r_ryear AND
             docnr  IN l_r_docnr AND
             rldnr  IN l_r_rldnr AND
             rbukrs IN l_r_rbukrs AND
             budat  IN l_r_budat ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    ENDIF.                             "First data package ?

* Fetch records into interface table.
*   named E_T_'Name of extract structure'.
    FETCH NEXT CURSOR s_cursor
               APPENDING CORRESPONDING FIELDS
               OF TABLE e_t_data
               PACKAGE SIZE s_s_if-maxsize.

    IF sy-subrc <> 0.
      CLOSE CURSOR s_cursor.
      RAISE no_more_data.

    ELSE.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT *
*        FROM bkpf
*        INTO CORRESPONDING FIELDS OF TABLE it_bkpf
*        FOR ALL ENTRIES IN e_t_data
*       WHERE bukrs = e_t_data-rbukrs AND
*             belnr = e_t_data-docnr  AND
*             gjahr = e_t_data-ryear.
*
* NEW CODE
      SELECT *

        FROM bkpf
        INTO CORRESPONDING FIELDS OF TABLE it_bkpf
        FOR ALL ENTRIES IN e_t_data
       WHERE bukrs = e_t_data-rbukrs AND
             belnr = e_t_data-docnr  AND
             gjahr = e_t_data-ryear ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT *
*        FROM bseg
*        INTO CORRESPONDING FIELDS OF TABLE it_bseg
*        FOR ALL ENTRIES IN e_t_data
*       WHERE bukrs = e_t_data-rbukrs AND
*             belnr = e_t_data-docnr  AND
*             gjahr = e_t_data-ryear  AND
*             buzei = e_t_data-buzei.
*
* NEW CODE
      SELECT *

        FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE it_bseg
        FOR ALL ENTRIES IN e_t_data
       WHERE bukrs = e_t_data-rbukrs AND
             belnr = e_t_data-docnr  AND
             gjahr = e_t_data-ryear  AND
             buzei = e_t_data-buzei ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT *
*        FROM bseg_add
*        INTO CORRESPONDING FIELDS OF TABLE it_bseg_add
*        FOR ALL ENTRIES IN e_t_data
*       WHERE bukrs = e_t_data-rbukrs AND
*             belnr = e_t_data-docnr  AND
*             gjahr = e_t_data-ryear.
*
* NEW CODE
      SELECT *

        FROM bseg_add
        INTO CORRESPONDING FIELDS OF TABLE it_bseg_add
        FOR ALL ENTRIES IN e_t_data
       WHERE bukrs = e_t_data-rbukrs AND
             belnr = e_t_data-docnr  AND
             gjahr = e_t_data-ryear ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*          AND buzei = e_t_data-buzei.

      LOOP AT e_t_data INTO wa_data.

        READ TABLE it_bkpf INTO wa_bkpf
          WITH KEY bukrs = wa_data-rbukrs
                   belnr = wa_data-docnr
                   gjahr = wa_data-ryear.
        IF sy-subrc = 0.
          wa_data-usnam = wa_bkpf-usnam.
          wa_data-tcode = wa_bkpf-tcode.
          wa_data-bvorg = wa_bkpf-bvorg.
          wa_data-stblg = wa_bkpf-stblg.
          wa_data-xref2_hd = wa_bkpf-xref2_hd.
          wa_data-bktxt = wa_bkpf-bktxt.
          wa_data-blart = wa_bkpf-blart.
          wa_data-bldat = wa_bkpf-bldat.
          wa_data-monat = wa_bkpf-monat.
          wa_data-waers = wa_bkpf-waers.
          wa_data-hwaer = wa_bkpf-hwaer.
          wa_data-hwae2 = wa_bkpf-hwae2.
          wa_data-hwae3 = wa_bkpf-hwae3.
          wa_data-xblnr = wa_bkpf-xblnr.
          wa_data-glvor = wa_bkpf-glvor.
          wa_data-awkey = wa_bkpf-awkey.
          wa_data-curt2 = wa_bkpf-curt2.
          wa_data-curt3 = wa_bkpf-curt3.
          wa_data-cpudt = wa_bkpf-cpudt.
          wa_data-ldgrp = wa_bkpf-ldgrp.

          MODIFY e_t_data FROM wa_data.
        ENDIF.

        READ TABLE it_bseg INTO wa_bseg
          WITH KEY bukrs = wa_data-rbukrs
                   belnr = wa_data-docnr
                   gjahr = wa_data-ryear
                   buzei = wa_data-buzei.
        IF sy-subrc = 0.
          wa_data-fdtag =  wa_bseg-fdtag.
          wa_data-anbwa =  wa_bseg-anbwa.
          wa_data-augbl =  wa_bseg-augbl.
          wa_data-augdt =  wa_bseg-augdt.
          wa_data-koart =  wa_bseg-koart.
          wa_data-sgtxt =  wa_bseg-sgtxt.
          wa_data-umsks =  wa_bseg-umsks.
          wa_data-umskz =  wa_bseg-umskz.
          wa_data-zfbdt =  wa_bseg-zfbdt.
          wa_data-zuonr =  wa_bseg-zuonr.
          wa_data-xref1 =  wa_bseg-xref1.
          wa_data-xref2 =  wa_bseg-xref2.
          wa_data-xref3 =  wa_bseg-xref3.
          wa_data-werks =  wa_bseg-werks.
          wa_data-vbund =  wa_bseg-vbund.
          wa_data-pargb =  wa_bseg-pargb.
          wa_data-aufnr =  wa_bseg-aufnr.
          wa_data-projk =  wa_bseg-projk.
          wa_data-anln1 =  wa_bseg-anln1.
          wa_data-anln2 =  wa_bseg-anln2.
          wa_data-auggj =  wa_bseg-auggj.
          wa_data-zzprestac  =  wa_bseg-zzprestac.
          wa_data-zzdesc_est =  wa_bseg-zzdesc_est.
          wa_data-zzmot_emis =  wa_bseg-zzmot_emis.
          wa_data-zzrut_terc =  wa_bseg-zzrut_terc.
          wa_data-zzunid_pro =  wa_bseg-zzunid_pro.
          wa_data-zz_agencia =  wa_bseg-zz_agencia.
          wa_data-gsber      =  wa_bseg-gsber.
          wa_data-lifnr      =  wa_bseg-lifnr.
          wa_data-kunnr      =  wa_bseg-kunnr.
          wa_data-kostl      =  wa_bseg-kostl.
          wa_data-prctr      =  wa_bseg-prctr.

          MODIFY e_t_data FROM wa_data.
        ENDIF.

        READ TABLE it_bseg_add INTO wa_bseg_add
          WITH KEY bukrs = wa_data-rbukrs
                   belnr = wa_data-docnr
                   gjahr = wa_data-ryear
                   buzei = wa_data-buzei.
        IF sy-subrc = 0.
*          wa_data-fdtag =  wa_bseg_add-fdtag.
          wa_data-anbwa =  wa_bseg_add-anbwa.
          wa_data-augbl =  wa_bseg_add-augbl.
          wa_data-augdt =  wa_bseg_add-augdt.
          wa_data-koart =  wa_bseg_add-koart.
          wa_data-sgtxt =  wa_bseg_add-sgtxt.
*          wa_data-umsks =  wa_bseg_add-umsks.
*          wa_data-umskz =  wa_bseg_add-umskz.
          wa_data-zfbdt =  wa_bseg_add-zfbdt.
          wa_data-zuonr =  wa_bseg_add-zuonr.
          wa_data-xref1 =  wa_bseg_add-xref1.
          wa_data-xref2 =  wa_bseg_add-xref2.
          wa_data-xref3 =  wa_bseg_add-xref3.
          wa_data-werks =  wa_bseg_add-werks.
          wa_data-vbund =  wa_bseg_add-vbund.
          wa_data-pargb =  wa_bseg_add-pargb.
          wa_data-aufnr =  wa_bseg_add-aufnr.
          wa_data-projk =  wa_bseg_add-projk.
          wa_data-anln1 =  wa_bseg_add-anln1.
          wa_data-anln2 =  wa_bseg_add-anln2.
          wa_data-auggj =  wa_bseg_add-auggj.
          wa_data-zzprestac  =  wa_bseg_add-zzprestac.
          wa_data-zzdesc_est =  wa_bseg_add-zzdesc_est.
          wa_data-zzmot_emis =  wa_bseg_add-zzmot_emis.
          wa_data-zzrut_terc =  wa_bseg_add-zzrut_terc.
          wa_data-zzunid_pro =  wa_bseg_add-zzunid_pro.
          wa_data-zz_agencia =  wa_bseg_add-zz_agencia.
          wa_data-gsber      =  wa_bseg_add-gsber.
*          wa_data-lifnr      =  wa_bseg_add-lifnr.
*          wa_data-kunnr      =  wa_bseg_add-kunnr.
          wa_data-kostl      =  wa_bseg_add-kostl.
          wa_data-prctr      =  wa_bseg_add-prctr.

          MODIFY e_t_data FROM wa_data.
        ENDIF.
      ENDLOOP.

    ENDIF.

    s_counter_datapakid = s_counter_datapakid + 1.

  ENDIF.              "Initialization mode or data extraction ?

ENDFUNCTION.
