***INCLUDE BDCRECXY


*----------------------------------------------------------------------*
TABLES: zcambiocheque, bsak, zjdatos_secuen, zbloqueo_estados, zprescribe_fecha.

*       Batchinputdata of single transaction
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       Nodata-Character
DATA:   nodata_character VALUE '/'.

DATA: v_check(1),
      v_agencia LIKE bsak-zz_agencia,
      v_primeravez(1),
      v_index LIKE sy-tabix,
      v_puntero LIKE sy-tabix,
      p_budat LIKE bkpf-budat,
      p_budat1 LIKE bkpf-budat,
      v_errorfechareval(1),
      v_erroragencia(1),
      wa_secuen LIKE zjdatos_secuen,
      wa_texto(60),
      wa_bloqueo LIKE zbloqueo_estados,
      v_empezando(1) VALUE ' ',
      nro_secuencia(6) TYPE n,
      v_comienzo(1),
      v_revalida(1).


DATA: BEGIN OF t_ftpost OCCURS 0.
        INCLUDE STRUCTURE ftpost.
DATA: END OF t_ftpost.

DATA: wa_payr LIKE payr  OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF t_blntab OCCURS 0.
        INCLUDE STRUCTURE blntab.
DATA: END OF t_blntab.
DATA: BEGIN OF t_fttax OCCURS 0.
        INCLUDE STRUCTURE fttax.
DATA: END OF t_fttax.
DATA: BEGIN OF t_ftclear OCCURS 0.
        INCLUDE STRUCTURE ftclear.
DATA: END OF t_ftclear.

DATA: e_subrc LIKE  sy-subrc.

DATA: BEGIN OF wa_xblnr.
        INCLUDE STRUCTURE zcambiocheque.
DATA: END OF wa_xblnr.

*----------------------------------------------------------------------*
*   create batchinput session                                          *
*----------------------------------------------------------------------*
FORM open_group
     USING p_group    LIKE apqi-groupid
           p_user     LIKE apqi-userid
           p_keep     LIKE apqi-qerase
           p_holddate LIKE apqi-startdate
           p_ctu      LIKE apqi-putactive.

  IF p_ctu <> 'X'.
    CALL FUNCTION 'BDC_OPEN_GROUP'
      EXPORTING
        client   = sy-mandt
        group    = p_group
        user     = p_user
        keep     = p_keep
        holddate = p_holddate.
  ENDIF.
ENDFORM.                    "OPEN_GROUP

*----------------------------------------------------------------------*
*   end batchinput session                                             *
*----------------------------------------------------------------------*
FORM close_group USING p_ctu LIKE apqi-putactive.
  IF p_ctu <> 'X'.
* close batchinput group
    CALL FUNCTION 'BDC_CLOSE_GROUP'.
  ENDIF.
ENDFORM.                    "CLOSE_GROUP

*----------------------------------------------------------------------*
*        Start new transaction according to parameters                 *
*----------------------------------------------------------------------*
FORM bdc_transaction TABLES p_messtab
                     USING  p_tcode
                            p_ctu
                            p_mode
                            p_update.
  DATA: l_subrc LIKE sy-subrc.

  IF p_ctu <> 'X'.
    CALL FUNCTION 'BDC_INSERT'
      EXPORTING
        tcode     = p_tcode
      TABLES
        dynprotab = bdcdata
      EXCEPTIONS
        OTHERS    = 1.
  ELSE.
    CALL TRANSACTION p_tcode USING bdcdata
                     MODE   p_mode
                     UPDATE p_update
                     MESSAGES INTO p_messtab.
  ENDIF.
  l_subrc = sy-subrc.
  REFRESH bdcdata.
  sy-subrc = l_subrc.
ENDFORM.                    "BDC_TRANSACTION

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> space.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.                    "BDC_FIELD

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_nodata USING p_nodata.
  nodata_character = p_nodata.
ENDFORM.                    "BDC_NODATA

* FCV - 24.06.2010
DATA: BEGIN OF t_bdctab OCCURS 0.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF t_bdctab.

* Estrutura de mensagens
DATA: BEGIN OF tabmess OCCURS 0.
        INCLUDE STRUCTURE bdcmsgcoll.
DATA: END OF tabmess.
*&---------------------------------------------------------------------
*&      Form  DYNPRO
*&---------------------------------------------------------------------
FORM dynpro USING dynbegin name value.
  IF dynbegin = 'X'.
    CLEAR t_bdctab.
    MOVE: name  TO t_bdctab-program,
          value TO t_bdctab-dynpro,
          'X'   TO t_bdctab-dynbegin.
    APPEND t_bdctab.
  ELSE.
    CLEAR t_bdctab.
    MOVE: name   TO t_bdctab-fnam,
          value  TO t_bdctab-fval.
    APPEND t_bdctab.
  ENDIF.
ENDFORM.                               "'DYNPRO'.

*&---------------------------------------------------------------------*
*&      Form  carga_ftpost
*&---------------------------------------------------------------------*
FORM carga_ftpost USING campo valor.
  CHECK valor NE space.
  t_ftpost-fnam = campo.
  t_ftpost-fval = valor.
  APPEND  t_ftpost.
ENDFORM.                    " CARGA_ftpost
* fin FCV - 24.06.2010
