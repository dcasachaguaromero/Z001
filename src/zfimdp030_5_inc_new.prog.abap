*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIMDP005_INC_NEW
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  ZRESERVACHEQUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_TABLSUBM  text
*----------------------------------------------------------------------*
FORM zreserva  USING    p_i_tablsubm.
*  DATA: P_CODIDU  LIKE ZREVERSACHEQUE-IDUSUARIO.

  DATA : p_horap TYPE sy-uzeit.
  DATA : it_bseg LIKE bseg OCCURS 0 WITH HEADER LINE.
*  CONCATENATE SY-UNAME '_' BUKRS '_' HBKID '_'  SY-DATUM  '_' SY-UZEIT INTO P_CODIDU.

  IF p_i_tablsubm IS  INITIAL.
    EXIT.
  ENDIF.

  MOVE sy-uzeit TO p_horap.

  CLEAR it_reversa.
  REFRESH it_reversa.

***  LOOP AT t_ok.
* FCV - 22.04.2010
*    IF T_OK-STATUS EQ '@08@' AND T_OK-CHEK1 EQ 'X'.
  IF t_ok-status EQ '@08@' AND t_ok-box EQ 'X'.
* fin FCV - 22.04.2010
*     SE RESCATA ULTIMO DOCUMENTO REALIZADO
    SELECT * INTO TABLE it_bseg
      FROM bseg
     WHERE bukrs EQ bukrs
       AND belnr EQ t_ok-belnr
       AND gjahr EQ t_ok-gjahr
       AND buzei EQ t_ok-buzei.

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

***  ENDLOOP.

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
*&      Form  MARCA_CHEQUES_ANT
*&---------------------------------------------------------------------*
*       BUSCA Y MARCA LOS CHEQUES TOMADOS ANTERIORMENTE POR OTRO USUARIO
*       O POR OTRO CODIGO ID DE USUARIO, PARA NO SER PROCESADOS
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM marca_cheques_ant .
  IF it_reversa[] IS NOT INITIAL.
    LOOP AT it_reversa.
*      SE BUSCAN LOS CHEQUES EN FORMA ANTERIOR Y EN OTRO ID ANTERIOR HACIA ATRAS

*      UPDATE ZREVERSACHEQUE
*         SET ESTREVER = 'T'
*       WHERE IDUSUARIO NE IT_REVERSA-IDUSUARIO
*         AND BUKRS      EQ IT_REVERSA-BUKRS
*         AND HBKID      EQ IT_REVERSA-HBKID
*         AND HKTID      EQ IT_REVERSA-HKTID
*         AND ESTREVER   EQ 'N'
*         AND FECPROCESO <= IT_REVERSA-FECPROCESO
*         AND CHECT      EQ IT_REVERSA-CHECT.

      IF sy-subrc EQ 0.
      ENDIF.

    ENDLOOP.

  ENDIF.
ENDFORM.                    " MARCA_CHEQUES_ANT
*&---------------------------------------------------------------------*
*&      Form  REVERSO_CH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PSEL  text
*      -->P_T_OK  text
*      -->P_BUKRS  text
*      -->P_HBKID  text
*      -->P_HKTID  text
*      -->P_BKPF_BUDAT  text
*----------------------------------------------------------------------*
FORM zreverso_ch  TABLES   p_psel STRUCTURE psel
                          p_t_ok STRUCTURE t_ok
                 USING    p_bukrs
                          p_hbkid
                          p_hktid
                          p_bkpf_budat.

  DATA: t_payr LIKE payr  OCCURS 0 WITH HEADER LINE.
  DATA: t_bsis LIKE bsis.  "OCCURS 0 WITH HEADER LINE.
  DATA: t_bsas LIKE bsas  OCCURS 0 WITH HEADER LINE.
  DATA: g_hkod LIKE bseg-hkont. "GUARDA CUENTA DE DESTINO"
  DATA: g_hkot LIKE bseg-hkont. "GUARDA CUENTA ACTUAL"
  DATA: g_sgtxt  LIKE bseg-sgtxt. "ALMACENAMOS EL TEXTO PARA LA POSICION.

  SELECT *
   FROM zcta_prescrip
   INTO CORRESPONDING FIELDS OF TABLE ti_zctap.



  SELECT * INTO CORRESPONDING FIELDS OF TABLE t_payr
    FROM payr
     WHERE ichec EQ ''
       AND zbukr EQ bukrs
       AND hbkid EQ hbkid
       AND hktid EQ hktid
       AND chect IN psel
       AND zaldt IN pfepag.

  DATA: vnun TYPE n,
        vnun2(9) TYPE c.

*Begin of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 23/12/2019 EY_DES02 ECDK917080 *
SORT T_CTA .
*End of change: ReSQ Correction for DELETE ADJACENT DUPLICATE 23/12/2019 EY_DES02 ECDK917080 *
  LOOP AT t_payr.
    g_valid_cta = 0.
    REFRESH t_cta.
    vnun = 2.
    DO 7 TIMES.
      ADD 1 TO vnun.
      vnun2 = vnun.
      CONCATENATE t_payr-ubhkt+0(9) vnun2 INTO t_cta-low.
      t_cta-sign = 'I'.
      t_cta-option = 'EQ'.
      APPEND t_cta.
    ENDDO.
    PERFORM ctas_zcta_prescrip.
    DELETE ADJACENT DUPLICATES FROM t_cta.


*    ASIGNA VALOR A G_HKOD ******************************
    CONCATENATE t_payr-ubhkt+0(9) '7' INTO g_hkod.
********************************************************
    CONCATENATE 'Reversa Cheques'  ' - '  sy-datum INTO g_sgtxt.
    g_little = 'Reversa Cheques'.

    IF t_payr-ubhkt EQ space.
      CLEAR: t_ok.
      PERFORM desc_cta USING '99' CHANGING des_cta.
      IF t_payr-voidr GT 0. " causa de anulacion
        des_cta = 'CHEQUE ANULADO'.
        g_hkot ='ANULACION'.
      ENDIF.

      MOVE: t_payr-vblnr TO t_ok-belnr,
            '@08@'       TO t_ok-status,
            t_payr-zbukr TO t_ok-bukrs,
            t_payr-gjahr  TO t_ok-gjahr,
            t_payr-chect  TO t_ok-chect,
            g_hkot        TO t_ok-hkont,
            g_hkod        TO t_ok-hkontd,
            g_sgtxt       TO t_ok-sgtxt,
            t_payr-vblnr  TO t_ok-vblnr,
            des_cta       TO t_ok-estado,
            '--'          TO t_ok-bldat,
            t_payr-zaldt  TO t_ok-zaldt,
            t_payr-znme1  TO t_ok-znme1,
            '--'           TO t_ok-zmote.
      APPEND t_ok.
    ENDIF.

    SELECT SINGLE * INTO CORRESPONDING FIELDS OF  t_bsis
      FROM bsis
       WHERE bukrs EQ t_payr-zbukr
         AND hkont EQ t_payr-ubhkt
         AND gjahr EQ t_payr-gjahr
         AND belnr EQ t_payr-vblnr.
    IF sy-subrc EQ 0.
      PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta .

      LOOP AT ti_zctap WHERE cuenta_p EQ t_bsis-hkont.
        des_cta = ti_zctap-descripcion.
      ENDLOOP.
      CLEAR: t_ok.

******** SE RESCATA BLDAT *****************************.
      CLEAR g_bldat.
      PERFORM  resc_bldat USING bukrs t_payr-vblnr t_bsis-gjahr
                          CHANGING g_bldat.
******** Validacion de cuenta **************************
      PERFORM valid_cta  USING t_bsis-hkont+9(1)  save_code
                         CHANGING g_valid_cta.
***************************************************************************
      PERFORM  zmot_emis USING bukrs  t_bsis-belnr t_bsis-gjahr
                         CHANGING p_zmot_emis.
**************************************************************************
      PERFORM desc_cta USING t_bsis-hkont+9(1) CHANGING des_cta .
      IF g_voidr GT 0. " causa de anulacion
        des_cta = 'CHEQUE ANULADO'.
      ENDIF.
      LOOP AT ti_zctap WHERE cuenta_p EQ t_bsis-hkont.
        des_cta = ti_zctap-descripcion.
      ENDLOOP.

      IF des_cta  = 'CHEQUE ANULADO'.
        g_hkot ='ANULACION'.
      ELSE.
        g_hkot = t_bsis-hkont.
      ENDIF.
*********     Se revisa y el cheque tiene historia ***********************
      PERFORM sestchqrever USING bukrs
                                 p_hbkid
                                 p_hktid
                                 g_hkot
                                 t_payr-chect
                                 CHANGING p_ctareversa p_belnrant.


      IF p_ctareversa EQ '--'. " al no poseer una cta para reversar Su estado Sera Girado
        des_cta = 'CHEQUE GIRADO'.
        g_valid_cta = 1.
      ENDIF.

      MOVE: t_bsis-belnr TO t_ok-belnr.
      IF g_valid_cta EQ 1.
        MOVE '@0A@'    TO t_ok-status. " ICONO MAL
      ELSE.
        MOVE '@08@'    TO t_ok-status. " ICONO BIEN
      ENDIF.

      MOVE: t_bsis-bukrs TO t_ok-bukrs,
       t_bsis-buzei  TO t_ok-buzei,
       t_bsis-gjahr  TO t_ok-gjahr,
       g_hkot        TO t_ok-hkont,
       t_bsis-wrbtr  TO t_ok-wrbtr,
       t_payr-chect  TO t_ok-chect,
       g_hkod        TO t_ok-hkontd,
       g_sgtxt       TO t_ok-sgtxt,
*           DATEDIFF      TO T_OK-DATEV,
       des_cta       TO t_ok-estado,
       t_payr-vblnr  TO t_ok-vblnr,
       g_bldat       TO t_ok-bldat,
       t_bsis-bldat  TO t_ok-bldat,
       t_payr-zaldt  TO t_ok-zaldt,
       t_payr-znme1  TO t_ok-znme1,
       p_zmot_emis   TO t_ok-zmote.

      APPEND t_ok.

    ELSE.
* Si registro no existe, buscarlo en tabla de compensados (BSAS)
      SELECT * INTO CORRESPONDING FIELDS OF TABLE t_bsas
        FROM bsas
         WHERE bukrs EQ t_payr-zbukr
           AND hkont EQ t_payr-ubhkt
           AND gjahr EQ t_payr-gjahr
           AND belnr EQ t_payr-vblnr.

      LOOP AT t_bsas.
        CLEAR t_ok.
        PERFORM busca_compen  TABLES t_cta
                                      t_ok
                               USING  t_bsas-bukrs  t_bsas-augbl g_hkod g_sgtxt t_payr-voidr
                                      t_payr-vblnr t_payr-lifnr t_payr-gjahr t_payr-chect t_payr-zaldt
                                      t_payr-znme1.
      ENDLOOP.
    ENDIF.
  ENDLOOP.


ENDFORM.                    " REVERSO_CH
*&---------------------------------------------------------------------*
*&      Form  REVERSA_CHEQUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_HBKID  text
*      -->P_HKTID  text
*----------------------------------------------------------------------*
FORM reversa_cheques  USING    p_bukrs
                               p_hbkid
                               p_hktid.



  DATA: p_porcheque(1) TYPE c.


  DATA p_texto3(50) TYPE c.
  CLEAR p_ctareversa.
  CLEAR p_porcheque.
  p_porcheque = 'N'.
  LOOP AT  t_ok.
* FCV - 22.04.2010
*    IF T_OK-STATUS EQ '@08@' AND T_OK-CHEK1 EQ 'X'.
    IF t_ok-status EQ '@08@' AND t_ok-box EQ 'X'.
* fin FCV - 22.04.2010

*     primero buscar cual es el estado actual.
*      T_OK-hkont

*     buscar cual sera el estado en que quedara. ()
*     select a la nueva tabla ZREVERSACHEQUE
      PERFORM sestchqrever USING p_bukrs
                                 p_hbkid
                                 p_hktid
                                 t_ok-hkont
                                 t_ok-chect
                        CHANGING p_ctareversa p_belnrant.


      IF p_ctareversa EQ '--'.
        CONCATENATE 'El Cheque : '  t_ok-chect ' .-' 'Esta Girado' INTO p_texto3.
        MESSAGE p_texto3 TYPE 'W'.
      ENDIF.

* se elegiran las cuentas que se debe reversar el cheque
* estas son :  revalidado CHEQUE NUEVO, ANULADO, PRESCRITOS
* P_PORCHEQUE DEBE ESTAR EN 'S'
      DATA: p_ctarevalidado TYPE zcta_prescrip-cuenta_p.

      SELECT SINGLE cuenta_p
        FROM zcta_prescrip
        INTO p_ctarevalidado
       WHERE t_cuenta EQ 6.

      IF sy-subrc EQ 0.
      ENDIF.
*      SACANMOS CUENTA DE PRESCRITOS
      DATA: p_ctaprescritos TYPE zcta_prescrip-cuenta_p.
      SELECT SINGLE cuenta_p
        FROM zcta_prescrip
        INTO p_ctaprescritos
       WHERE t_cuenta EQ 4.

      IF sy-subrc EQ 0.
      ENDIF.


*      IF T_OK-ESTADO EQ 'ANULADO'  OR P_CTAREVERSA EQ P_CTAREVALIDADO OR P_CTAREVERSA EQ P_CTAPRESCRITOS.
*        P_PORCHEQUE = 'S'.
*      ENDIF.

      IF t_ok-estado EQ 'CHEQUE ANULADO'  OR t_ok-hkont EQ p_ctarevalidado OR t_ok-hkont EQ p_ctaprescritos.
        p_porcheque = 'S'.
      ENDIF.

      IF p_porcheque EQ 'S'.
*          RUTINA DE CHEQUES
*      ************  PERFORM **************************************
*      RFCHKD30
        PERFORM ch_rfchkd30 USING p_bukrs p_hbkid p_hktid t_ok-hkont t_ok-chect.
      ENDIF.

* TODOS LOS CHEQUES DEBEN PASAR POR ESTA RUTINA DE ANULACION DE DOCUMENTOS.
********* PERFORM PARA ANULACION DE DOCUMENTOS ********************.
      PERFORM adoc_fbra USING bukrs t_ok-belnr t_ok-gjahr
                        CHANGING it_rf05r_acct.

      PERFORM upd_sestchqrever  USING p_bukrs
                                      p_hbkid
                                      p_hktid
                                      t_ok-hkont
                                      t_ok-chect
                                      p_belnrant
                                      t_ok-belnr
                                      t_ok-gjahr.


    ENDIF.
  ENDLOOP.


***********************************************************************
***********  Actualiza ***********

  CLEAR t_ok.
  REFRESH t_ok.
  PERFORM  zreverso_ch  TABLES psel
                               t_ok
                         USING bukrs hbkid hktid bkpf-budat.



ENDFORM.                    " REVERSA_CHEQUES
*&---------------------------------------------------------------------*
*&      Form  SESTCHQREVER
*&---------------------------------------------------------------------*
*       SE BUSCA EL ULTIMO ESTADO
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_HBKID  text
*      -->P_P_HKTID  text
*      -->P_T_OK_HKONT  text
*      -->P_T_OK_CHECT  text
*      <--P_P_ESTREVERSA  text
*----------------------------------------------------------------------*
FORM sestchqrever  USING    p_bukrs
                            p_hbkid
                            p_hktid
                            p_hkont
                            p_chect
                CHANGING p_ctareversa p_belrant.

  CLEAR p_ctareversa.

*  DATA TI_ZREVER TYPE ZREVERSACHEQUE OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF ti_zrever OCCURS 0,
    codusuario  TYPE zcodusuario,
    bukrs	      TYPE bukrs,
    hbkid	      TYPE hbkid,
    hktid	      TYPE hktid,
    budat	      TYPE budat,
    estrever    TYPE zestrever,
    vblnr	      TYPE vblnr,
    belnr	      TYPE zbelnr,
    buzei	      TYPE buzei,
    gjahr	      TYPE gjahr,
    fecproceso  TYPE zfecproceso,
    horaproceso	TYPE zuzeit,
    hkont	      TYPE hkont,
    wrbtr	      TYPE wrbtr,
    waers	      TYPE wrbtr,
    chect	      TYPE chect,
    hkontd      TYPE zhkontd,
    estado      TYPE zestadoch,
    bldat	      TYPE zbldat,
    lifnr	      TYPE lifnr,
    zaldt	      TYPE dzaldt,
    zmote	      TYPE zzmot_emis,
    END OF ti_zrever.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE  ti_zrever
    FROM zreversacheque
   WHERE bukrs  EQ p_bukrs
     AND hbkid  EQ p_hbkid
     AND hktid  EQ p_hktid
     AND estrever EQ 'N'
     AND chect  EQ  p_chect
     AND hkontd EQ  p_hkont.
* se rrescata la cuenta a la que se debe reversar

  IF sy-subrc EQ 0.
*    LOOP AT TI_ZREVER.
*      MOVE TI_ZREVER-HKONT  TO P_CTAREVERSA.
*      MOVE TI_ZREVER-BELNR  TO P_BELRANT.
*    ENDLOOP.
  ELSE.
    MOVE '--' TO p_ctareversa.
  ENDIF.
  IF ti_zrever[] IS NOT INITIAL.
    LOOP AT ti_zrever.
      MOVE ti_zrever-hkont  TO p_ctareversa.
      MOVE ti_zrever-belnr  TO p_belrant.
    ENDLOOP.
  ELSE.
    MOVE '--' TO p_ctareversa.
  ENDIF.

ENDFORM.                    " SESTCHQREVER
*&---------------------------------------------------------------------*
*&      Form  ADOC_FBRA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_BUKRS  text
*      -->P_T_OK_BELNR  text
*      -->P_T_OK_GJAHR  text
*      <--P_IT_RF05R_ACCT  text
*----------------------------------------------------------------------*
FORM adoc_fbra  USING    p_bukrs
                         p_belnr
                         p_gjahr
                CHANGING p_it_rf05r_acct.

  DATA it_bsis LIKE bsis.

  DATA p_e_xstor TYPE c.

  CALL FUNCTION 'CALL_FBRA'
    EXPORTING
      i_bukrs            = p_bukrs
      i_augbl            = p_belnr
      i_gjahr            = p_gjahr
*   I_XSIMU            = ' '
*   I_XERLK            = 'X'
*   I_AUGDT            = '00000000'
*   I_STODT            = '00000000'
*   I_STOMO            =
*   I_RFZEI            =
*   I_UPDATE           = 'S'
*   I_MODE             = 'N'
*   I_NO_AUTH          = ' '
   IMPORTING
     e_xstor            =  p_e_xstor
* TABLES
*   T_ACCNT            =
* EXCEPTIONS
*   NOT_POSSIBLE       = 1
*   OTHERS             = 2
            .


  IF sy-subrc EQ 0.
    PERFORM c_bapi_acc_document_rev_post
       USING p_bukrs p_belnr p_gjahr.
  ENDIF.
* COMMIT WORK AND WAIT.
*  WAIT UP TO 2 SECONDS.

ENDFORM.                    " ADOC_FBRA
*&---------------------------------------------------------------------*
*&      Form  UPD_SESTCHQREVER
*&---------------------------------------------------------------------*
*       SE REALIZA UPDATE PARA MARCAR CON UNA 'R' EL ESTADO DE REGISTRO REVERSADO
*       PARA DESCARTAR EL ULTIMO ESTADO.
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_HBKID  text
*      -->P_P_HKTID  text
*      -->P_T_OK_HKONT  text
*      -->P_T_OK_CHECT  text
*----------------------------------------------------------------------*
FORM upd_sestchqrever  USING    p_bukrs
                                p_hbkid
                                p_hktid
                                p_hkont
                                p_chect
                                p_belnr
                                p_belnr2
                                p_gjahr.


  DATA :  it_bkpf LIKE bkpf OCCURS 0 WITH HEADER LINE.
  DATA : p_zdocrev TYPE bkpf-stblg.
*P_BELNR2 ES EL DOCUEMTO ACTUAL DEL ULTIMPO ESTADO
*P_BELNR  ES EL DOCUMENTO DEL ESTO ANTERIOR.

* P_BELNR2 SOLO PARA SACAR EL DOCUMENTO DE REVERSA Y COLOCARLO EN TABLA ZREVERSACHEQUE
  SELECT *  INTO TABLE it_bkpf
    FROM bkpf
    WHERE bukrs EQ p_bukrs
      AND belnr EQ p_belnr2
      AND gjahr EQ p_gjahr.

  IF sy-subrc EQ 0.
    IF it_bkpf[] IS NOT INITIAL.
      LOOP AT it_bkpf.
        MOVE it_bkpf-stblg TO p_zdocrev.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF p_zdocrev IS NOT INITIAL.
    UPDATE zreversacheque
       SET estrever = 'R'
           zdocrev  = p_zdocrev
     WHERE bukrs  EQ p_bukrs
       AND hbkid  EQ p_hbkid
       AND hktid  EQ p_hktid
       AND estrever EQ 'N'
       AND chect  EQ  p_chect
       AND hkontd EQ  p_hkont
       AND belnr  EQ  p_belnr.
  ELSE.
    UPDATE zreversacheque
       SET estrever = 'R'
           zdocrev  = p_zdocrev
     WHERE bukrs  EQ p_bukrs
       AND hbkid  EQ p_hbkid
       AND hktid  EQ p_hktid
       AND estrever EQ 'N'
       AND chect  EQ  p_chect
       AND hkontd EQ  p_hkont
       AND belnr  EQ  p_belnr.
  ENDIF.

  COMMIT WORK AND WAIT.
* se rrescata la cuenta a la que se debe reversar
  IF sy-subrc EQ 0.
  ENDIF.


ENDFORM.                    " UPD_SESTCHQREVER
*&---------------------------------------------------------------------*
*&      Form  CH_RFCHKD30
*&---------------------------------------------------------------------*
*       ANULA CHEQUES
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_HBKID  text
*      -->P_P_HKTID  text
*      -->P_T_OK_HKONT  text
*      -->P_T_OK_CHECT  text
*----------------------------------------------------------------------*
FORM ch_rfchkd30  USING    p_bukrs
                           p_hbkid
                           p_hktid
                           p_hkont
                           p_chect.

  DATA : namejob(32) TYPE c.
  PERFORM ejec_submit USING save_code  p_chect CHANGING namejob.
  WAIT UP TO 3 SECONDS.

ENDFORM.                    " CH_RFCHKD30
*&---------------------------------------------------------------------*
*&      Form  C_BAPI_ACC_DOCUMENT_REV_POST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_BUKRS  text
*      -->P_P_BELNR  text
*      -->P_P_GJAHR  text
*----------------------------------------------------------------------*
FORM c_bapi_acc_document_rev_post  USING    z_bukrs
                                            z_belnr
                                            z_gjahr.
  DATA :it_reversal LIKE bapiacrev OCCURS 0 WITH HEADER LINE .
  DATA : g_logsys  TYPE  logsys.
  DATA : it_bapiret2 LIKE  bapiret2 OCCURS 0 WITH HEADER LINE .
  DATA : it_bkpf LIKE bkpf.
* TABLA TBDLS  LOGSYS

  SELECT SINGLE logsys
           FROM tbdls
           INTO g_logsys.


  IF sy-subrc EQ 0.
  ENDIF.

  SELECT SINGLE *
    FROM bkpf
    INTO it_bkpf
   WHERE bukrs EQ z_bukrs
     AND belnr EQ z_belnr
     AND gjahr EQ z_gjahr
    .

  IF sy-subrc EQ 0.
    MOVE  'BKPF'         TO it_reversal-obj_type.
    MOVE  it_bkpf-awkey  TO it_reversal-obj_key.
    MOVE  g_logsys       TO it_reversal-obj_sys. " 'ECDCLNT100'
    MOVE  it_bkpf-awkey  TO it_reversal-obj_key_r.
    MOVE  z_bukrs        TO it_reversal-comp_code.
    MOVE  '02'           TO it_reversal-reason_rev. " Motivo de anulación o contabilización inversa
    MOVE  bkpf-budat     TO it_reversal-pstng_date.
    MOVE  z_belnr        TO it_reversal-ac_doc_no.
*  MOVE  12             TO IT_REVERSAL-FIS_PERIOD.
  ENDIF.

  APPEND it_reversal.

  CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
    EXPORTING
      reversal       = it_reversal
      bus_act        = 'RFBU'
* IMPORTING
*   OBJ_TYPE       =
*   OBJ_KEY        =
*   OBJ_SYS        =
    TABLES
      return         = it_bapiret2
            .

  IF sy-subrc EQ 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     wait          = 'X'
*   IMPORTING
*     RETURN        =
              .

  ENDIF.


ENDFORM.                    " C_BAPI_ACC_DOCUMENT_REV_POST
*&---------------------------------------------------------------------*
*&      Form  CALL_ZFIMRP001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_zfimrp001 USING p_bukrs p_hbkid p_hktid p_chect.


  SUBMIT zfimrp001
          WITH sbukrs EQ p_bukrs
          WITH schect EQ p_chect
          WITH shbkid EQ p_hbkid
          WITH shktid EQ p_hktid
          AND RETURN.



ENDFORM.                    " CALL_ZFIMRP001
