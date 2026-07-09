FUNCTION zfiaa015new_extr.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      ZSELOPT STRUCTURE  RSPARAMS
*"      ZDTAB STRUCTURE  ZZFIAAREPORTE
*"  CHANGING
*"     VALUE(ZRTMODE) TYPE  AQLIMODE
*"----------------------------------------------------------------------

  CALL FUNCTION 'RSAQRT_SET_IDENTIFICATION'
    EXPORTING
      iqid        = %iqid
      sscr_report = sy-repid
    CHANGING
      rtmode      = zrtmode.

* if %rtmode-pack_on = space or %rtmode-first_call = 'X'.
  IF zrtmode-pack_on = space OR zrtmode-first_call = 'X'.
    CALL FUNCTION 'RSAQRT_FILL_SELECTIONS'
*         tables   selopt = %selopt
      TABLES
        selopt = zselopt
      CHANGING
        rtmode = zrtmode.
  ENDIF.

  CALL FUNCTION 'RSAQRT_INIT_TEXTHANDLING'
    EXPORTING
      class   = 'CL_TEXT_IDENTIFIER'
      wsid    = ' '
      infoset = 'SYSTQV000000000000000808'.

*  if %rtmode-no_authchk = space
*     and ( %rtmode-pack_on = space or %rtmode-first_call = 'X' ).
  IF zrtmode-no_authchk = space
     AND ( zrtmode-pack_on = space OR zrtmode-first_call = 'X' ).
    REFRESH %auth_tabs.
    APPEND 'LFA1' TO %auth_tabs.
    APPEND 'ANLA' TO %auth_tabs.
    APPEND 'ANLZ' TO %auth_tabs.
    APPEND 'ANEP' TO %auth_tabs.
    APPEND 'T001' TO %auth_tabs.
    APPEND 'T093B' TO %auth_tabs.
    APPEND 'BKPF' TO %auth_tabs.
    CALL FUNCTION 'RSAQRT_AUTHORITY_CHECK'
      EXPORTING
        auth_tabs        = %auth_tabs
        auth_clas        = 'CL_QUERY_TAB_ACCESS_AUTHORITY'
      CHANGING
*       rtmode           = %rtmode
        rtmode           = zrtmode
      EXCEPTIONS
        no_authorization = 1.
    IF sy-subrc = 1.
      RAISE no_authorization.
    ENDIF.
  ENDIF.

  DATA: %l_no_further_fetch TYPE flag, " stop fetching
        %l_hits_cnt         TYPE i.    " cnt for %dbtab entries
  DATA: zdtab-awkey         LIKE bkpf-awkey.

*  if %rtmode-pack_abort = 'X'.
  IF zrtmode-pack_abort = 'X'.
    IF NOT %dbcursor IS INITIAL.
      CLOSE CURSOR %dbcursor.
    ENDIF.
    EXIT.
  ENDIF.


*  if %rtmode-pack_on = space or %rtmode-first_call = 'X'.
  IF zrtmode-pack_on = space OR zrtmode-first_call = 'X'.
    IF NOT %dbcursor IS INITIAL.
      CLOSE CURSOR %dbcursor.
    ENDIF.
    OPEN CURSOR WITH HOLD %dbcursor FOR
    SELECT anla~bukrs anla~anln1 anla~anln2 anla~txt50 anla~anlkl anla~ktogr anla~anltp anla~aktiv anla~anlue
           anla~izwek anla~lifnr anla~liefe anla~urwrt anla~eaufn anla~zujhr anla~zuper anla~zugdt anla~aibdt anla~urjhr anla~lblnr
           anlz~kostl anlz~anln1 anlz~anln2 anlz~bukrs anep~afabe anep~bzdat anep~bwasl anep~anbtr anep~peraf anep~belnr anep~buzei
           anep~gjahr anep~zujhr anep~anln1 anep~anln2 anep~bukrs
    FROM ( anla
           INNER JOIN anlz
           ON  anlz~anln1 = anla~anln1
           AND anlz~anln2 = anla~anln2
           AND anlz~bukrs = anla~bukrs
           INNER JOIN anep
           ON  anep~anln1 = anlz~anln1
           AND anep~anln2 = anlz~anln2
           AND anep~bukrs = anlz~bukrs
           AND anep~lnsan = '00000' )
         WHERE anla~bukrs IN sp$00001
           AND anla~anln1 IN sp$00002
           AND anla~anln2 IN sp$00003
           AND anla~anlkl IN sp$00004
           AND anla~anlue IN sp$00006
           AND anep~bwasl IN sp$00007
           AND anep~afabe IN sp$00008
           AND anep~bzdat IN sp$00010
           AND anep~gjahr IN sp$00012.
  ENDIF.

  IF %dbcursor IS INITIAL.
    RAISE cursor_not_open.
  ENDIF.

  WHILE %l_no_further_fetch = space.
    FETCH NEXT CURSOR %dbcursor
    INTO ( anla-bukrs , anla-anln1 , anla-anln2 , anla-txt50 , anla-anlkl , anla-ktogr , anla-anltp
        , anla-aktiv , anla-anlue , anla-izwek , anla-lifnr , anla-liefe , anla-urwrt , anla-eaufn , anla-zujhr , anla-zuper
        , anla-zugdt , anla-aibdt , anla-urjhr , anla-lblnr , anlz-kostl , anlz-anln1 , anlz-anln2 , anlz-bukrs , anep-afabe
        , anep-bzdat , anep-bwasl , anep-anbtr , anep-peraf , anep-belnr , anep-buzei , anep-gjahr , anep-zujhr , anep-anln1
        , anep-anln2 , anep-bukrs ).
    IF ( ( zrtmode-acc_check = 'X' AND
           sy-dbcnt > zrtmode-acc_number )
        OR sy-subrc <> 0 ).
      %l_no_further_fetch = 'X'.
    ELSE.
      CHECK sp$00001.
      CHECK sp$00002.
      CHECK sp$00003.
      CHECK sp$00004.
      CHECK sp$00006.
      CHECK sp$00007.
      CHECK sp$00008.
      CHECK sp$00010.
      CHECK sp$00012.
      CALL FUNCTION 'RSAQRT_TEXTFIELD_REFRESH'.

**Traemos los datos del proveedor
      IF NOT anla-lifnr IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE stcd1 name1
*          INTO (lfa1-stcd1, lfa1-name1)
*          FROM lfa1
*          WHERE lifnr = anla-lifnr.
*
* NEW CODE
        SELECT stcd1 name1
        UP TO 1 ROWS 
          INTO (lfa1-stcd1, lfa1-name1)
          FROM lfa1
          WHERE lifnr = anla-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ENDIF.

      zdtab-bukrs = anla-bukrs .
      zdtab-anln1 = anla-anln1 .
      zdtab-anln2 = anla-anln2 .
      zdtab-txt50 = anla-txt50 .
      zdtab-anlkl = anla-anlkl .
      zdtab-ktogr = anla-ktogr .
      zdtab-anltp = anla-anltp .
      zdtab-aktiv = anla-aktiv .
      zdtab-anlue = anla-anlue .
      zdtab-izwek = anla-izwek .
      zdtab-lifnr = anla-lifnr .
      zdtab-stcd1 = lfa1-stcd1 .
      zdtab-liefe = anla-liefe .
      zdtab-name1 = lfa1-name1 .
      zdtab-urwrt = anla-urwrt .
      zdtab-kostl = anlz-kostl .
      zdtab-eaufn = anla-eaufn .
      zdtab-zujhr = anla-zujhr .
      zdtab-zuper = anla-zuper .
      zdtab-zugdt = anla-zugdt .
      zdtab-aibdt = anla-aibdt .
      zdtab-urjhr = anla-urjhr .
      zdtab-afabe = anep-afabe .
      zdtab-bzdat = anep-bzdat .
      zdtab-bwasl = anep-bwasl .
      zdtab-anbtr = anep-anbtr .
      zdtab-waers = t093b-waers .
      zdtab-peraf = anep-peraf .
      zdtab-belnr = anep-belnr .
      zdtab-buzei = anep-buzei .
      zdtab-gjahr = anep-gjahr .
      zdtab-zujhr001 = anep-zujhr .
      zdtab-lblnr = anla-lblnr .

*****
      IF sp$00008 <> ' '.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE waers
*               FROM t093b
*               INTO zdtab-waers
*               WHERE bukrs = zdtab-bukrs AND
*                     afabe = '01'.
*
* NEW CODE
        SELECT waers
        UP TO 1 ROWS 
               FROM t093b
               INTO zdtab-waers
               WHERE bukrs = zdtab-bukrs AND
                     afabe = '01' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      ELSE.
        SELECT SINGLE waers
               FROM t093b
               INTO zdtab-waers
               WHERE bukrs = zdtab-bukrs AND
                     afabe = sp$00008.
      ENDIF.
****
      SELECT SINGLE blart budat usnam xblnr
             FROM bkpf
             INTO (zdtab-blart, zdtab-budat,
                   zdtab-usnam, zdtab-xblnr)
             WHERE belnr = zdtab-belnr
               AND bukrs = zdtab-bukrs
               AND gjahr = zdtab-gjahr
               AND budat IN sp$00011.
      IF sy-subrc <> 0.
        CONCATENATE zdtab-belnr zdtab-gjahr INTO zdtab-awkey.
        SELECT SINGLE blart budat usnam xblnr belnr
            FROM bkpf
            INTO (zdtab-blart, zdtab-budat, zdtab-usnam,
                  zdtab-xblnr, zdtab-belnr)
            WHERE awkey = zdtab-awkey
              AND bukrs = zdtab-bukrs
              AND budat IN sp$00011.
        IF sy-subrc <> 0.
          CLEAR zdtab-awkey.
          CONCATENATE zdtab-belnr zdtab-bukrs zdtab-gjahr INTO zdtab-awkey.
          SELECT SINGLE blart budat usnam xblnr belnr
             FROM bkpf
             INTO (zdtab-blart, zdtab-budat, zdtab-usnam,
                   zdtab-xblnr, zdtab-belnr)
             WHERE awkey = zdtab-awkey
               AND bukrs = zdtab-bukrs
               AND budat IN sp$00011.
        ENDIF.
      ENDIF.
      IF sy-subrc EQ 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE lifnr sgtxt
*               FROM bseg
*               INTO (zdtab-lifnr, zdtab-name1)
*              WHERE belnr = zdtab-belnr
*                AND bukrs = zdtab-bukrs
*                AND gjahr = zdtab-gjahr
*                AND koart = 'K'.
*
* NEW CODE
        SELECT lifnr sgtxt
        UP TO 1 ROWS 
               FROM bseg
               INTO (zdtab-lifnr, zdtab-name1)
              WHERE belnr = zdtab-belnr
                AND bukrs = zdtab-bukrs
                AND gjahr = zdtab-gjahr
                AND koart = 'K' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE hkont
*               FROM bseg
*               INTO zdtab-hkont
*              WHERE belnr = zdtab-belnr
*                AND bukrs = zdtab-bukrs
*                AND gjahr = zdtab-gjahr
** V1 RVY 31.08.2022
*                AND anln1 = zdtab-anln1
** V1 RVY 31.08.2022
*                AND ( bschl = '70' OR bschl = '75' ).
*
* NEW CODE
        SELECT hkont
        UP TO 1 ROWS 
               FROM bseg
               INTO zdtab-hkont
              WHERE belnr = zdtab-belnr
                AND bukrs = zdtab-bukrs
                AND gjahr = zdtab-gjahr
* V1 RVY 31.08.2022
                AND anln1 = zdtab-anln1
* V1 RVY 31.08.2022
                AND ( bschl = '70' OR bschl = '75' ) ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        APPEND zdtab.
      ENDIF.

      %l_hits_cnt = %l_hits_cnt + 1.
*      if %rtmode-pack_on = 'X'
*         and %l_hits_cnt >= %rtmode-pack_size.
      IF zrtmode-pack_on = 'X'
         AND %l_hits_cnt >= zrtmode-pack_size.
        %l_no_further_fetch = 'X'.
      ENDIF.
    ENDIF.
  ENDWHILE.

  IF %l_hits_cnt = 0.
    IF NOT %dbcursor IS INITIAL.
      CLOSE CURSOR %dbcursor.
    ENDIF.
    RAISE no_data.
  ENDIF.

*  if %rtmode-pack_on <> 'X'.
  IF zrtmode-pack_on <> 'X'.
    CLOSE CURSOR %dbcursor.
  ENDIF.
* read table %dtab index 1 transporting no fields.
  READ TABLE zdtab INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc NE 0.
    RAISE no_data.
  ENDIF.

ENDFUNCTION.
