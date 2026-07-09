*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
*&  Include           ZXF01U01
*&---------------------------------------------------------------------*

*break-point.

* rutina para encontrar las partidas abiertas en función de los criteriros de búsqueda
* de las tablas ZCB_ITER_CC.
* debe cumplir con la secuencia y las condiciónes de cada secuencia .
*documento encontrado no debe formar parte de la siguiente busqueda .

* DEFINICIÖN DE DATOS
TABLES: zcb_iter, zcb_iter_cc, bkpf,bseg, bsis,tsad4,bsas,
        t033f,t033g,t001,zcb_iter_suc,t028g,febre, bsak,skb1,
        PAYR.
TYPES: s_iter TYPE zcb_iter_cc.
DATA: wa_iter TYPE s_iter.
DATA: wa_febcl TYPE febcl.
DATA: t_iter TYPE s_iter OCCURS 0.
DATA: t_bsis TYPE bsis OCCURS 0.
DATA: t_bsis_temp TYPE bsis OCCURS 0.
DATA: t_bsis_copy TYPE bsis OCCURS 0.
DATA: t_febre_tmp TYPE STANDARD TABLE OF febre WITH HEADER LINE.
DATA: c_check(13) TYPE c.
DATA: t_payr TYPE STANDARD TABLE OF payr WITH HEADER LINE.

TYPES: BEGIN OF s_belnr,
         belnr LIKE bsis-belnr,
         buzei LIKE bsis-buzei,
       END OF s_belnr.
DATA: t_belnr_excl TYPE s_belnr  OCCURS 0 WITH HEADER LINE.

DATA: wa_bkpf TYPE bkpf.
DATA: wa_bsis TYPE bsis.
DATA: w_lastdate LIKE sy-datum.
DATA: i_monat LIKE bsis-monat.
DATA: i_gjahr LIKE bsis-gjahr.
DATA: o_monat LIKE bsis-monat.
DATA: o_gjahr LIKE bsis-gjahr.
DATA: o_feccont LIKE bapi0002_4-posting_date.
DATA: w_firstdate LIKE sy-datum.
DATA: w_difdias(4) TYPE n.
DATA: w_contador LIKE sy-tabix.
DATA: w_esnum    LIKE sy-tabix.
DATA: w_hkont    LIKE febko-hkont.
DATA: w_ctasymb  LIKE t033f-ktos1.
DATA: w_ctasymb_clave LIKE t033f-bsch1.
DATA: w_dias(4) TYPE n.
DATA: patron VALUE '+'.
DATA: w_komo1 LIKE t033g-komo1.
DATA: w_cheque(13) TYPE n.
DATA: w_cheque_str LIKE bsis-zuonr.
DATA: w_revalida.  "control de revalidacion
DATA: w_control.
DATA: w_budat LIKE bsis-budat.
DATA: w_text1 LIKE  febre-vwezw.
DATA: w_text2 LIKE  febre-vwezw.
DATA: w_lines TYPE i.
DATA: w_lines2 TYPE i.
DATA: w_zuor_n(3) TYPE n.
DATA: wa_concilia TYPE ztconc_manual.
CONSTANTS: w_zeros VALUE '0'.
RANGES: r_fechas FOR sy-datum,
        r_zuonr FOR bsis-zuonr.

* START-OF_SELECTION.
* tenemos que tener en cuenta si el extracto es MANUAL o AUTOMATICO
*ya que necesitamos el plan de cuentas .

*        Modificacion Fecha Contabilizacion Herman Rosales
CALL FUNCTION 'FI_PERIOD_DETERMINE'
  EXPORTING
    i_budat        = i_febep-budat
    i_bukrs        = i_febko-bukrs
*   I_RLDNR        = ' '
*   I_PERIV        = ' '
*   I_GJAHR        = 0000
*   I_MONAT        = 00
*   X_XMO16        = ' '
  IMPORTING
    e_gjahr        = i_gjahr
    e_monat        = i_monat
*   E_POPER        =
  EXCEPTIONS
    fiscal_year    = 1
    period         = 2
    period_version = 3
    posting_period = 4
    special_period = 5
    version        = 6
    posting_date   = 7
    OTHERS         = 8.
IF sy-subrc EQ 0.
  CALL FUNCTION 'ZFI_FIRST_PERIOD_CHECK'
    EXPORTING
      ibukrs = i_febko-bukrs
      igjahr = i_gjahr
      imonat = i_monat
    IMPORTING
      ogjahr = o_gjahr
      omonat = o_monat.

  IF o_gjahr <> ' ' AND o_gjahr IS NOT INITIAL.
    CALL FUNCTION 'BAPI_CCODE_GET_FIRSTDAY_PERIOD'
      EXPORTING
        companycodeid       = i_febko-bukrs
        fiscal_period       = o_monat
        fiscal_year         = o_gjahr
      IMPORTING
        first_day_of_period = o_feccont
*       RETURN              =
      .
    IF i_febep-budat < o_feccont.
      i_febep-budat = o_feccont.
    ENDIF.

  ENDIF.
ENDIF.

*        Fin Modificacion

IF i_febko-ktopl IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE        * FROM  t001
*         WHERE  bukrs  = i_febko-bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  t001
         WHERE  bukrs  = i_febko-bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  MOVE t001-ktopl TO  i_febko-ktopl.
  MOVE-CORRESPONDING i_febko TO e_febko.
ENDIF.



*para todas las operaciones.
*incluir el texto de la operación que está en la tabla FEBRE.
*puede estar en cualquier linea por lo que hay que ver si contiene letras.
* partimos de la base de que los registros entran con status erróneo.
*If sy-tcode ne 'FEBAN'.
*ziclos octubre eliminamos considerarlo como error
*move 'C' to i_febep-B1ERR.

IF i_febep-intag EQ '011'.
  MOVE i_febep-chect TO i_febep-zuonr.
ENDIF.

MOVE-CORRESPONDING i_febep TO e_febep.

DESCRIBE TABLE t_febre LINES w_lines.
IF w_lines = 0.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM  febre INTO TABLE t_febre_tmp
*   WHERE  kukey       = i_febep-kukey
*   AND    esnum       = i_febep-esnum.
*
* NEW CODE
  SELECT *
 FROM  febre INTO TABLE t_febre_tmp
   WHERE  kukey       = i_febep-kukey
   AND    esnum       = i_febep-esnum ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
ELSE.
  LOOP AT t_febre.
    MOVE-CORRESPONDING t_febre TO t_febre_tmp.
    APPEND t_febre_tmp.
  ENDLOOP.
ENDIF.

DESCRIBE TABLE t_febre_tmp LINES w_lines.
IF w_lines > 0.
  CLEAR e_febep-texts.
  LOOP AT t_febre_tmp.
    IF t_febre_tmp-vwezw  CA 'abcdefeghijklmnopqrstuvxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.
      IF w_text1 IS INITIAL.
        MOVE t_febre_tmp-vwezw TO w_text1.
      ELSE.
        MOVE t_febre_tmp-vwezw TO w_text2.
      ENDIF.
    ENDIF.
    IF strlen( t_febre_tmp-vwezw ) < 5 AND e_febep-texts IS INITIAL .
      e_febep-texts = t_febre_tmp-vwezw+0(16).
    ENDIF.
  ENDLOOP.
  IF i_febko-efart = 'E'.  "solo para los electrónicos.
    CONCATENATE w_text1 w_text2 INTO  e_febep-sgtxt.
    CONDENSE e_febep-sgtxt .
  ENDIF.
  IF w_lines >= 3.
    IF i_febep-intag = '011'.  " movemos el numero de cheque al campo asignacion.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
      SORT t_febre_tmp .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
      READ TABLE t_febre_tmp INDEX 1.  "lugar donde está el numero de cheque
      MOVE t_febre_tmp-vwezw+0(13) TO c_check.
      SHIFT c_check RIGHT DELETING TRAILING space. " If U want leading 0s
      OVERLAY c_check WITH '0000000000000'.
      MOVE c_check TO e_febep-zuonr.
** V1 RVY 11-05-2021
      MOVE c_check TO e_febep-chect.
** V1 RVY 11-05-2021
    ENDIF.
  ENDIF.
ENDIF.

MOVE e_febep-sgtxt TO e_febep-butxt. "porque hicieron el campo obligatorio en FI
*leemos los documentos que ya se compensaron
* la primnera vez estará vacia.
MOVE '+' TO w_komo1.
IMPORT  t_belnr_excl FROM MEMORY ID 'ZCBAN'.


*if w_contador ne 1.  "el cheque no encontró la partida para compensar .
* o el apunte no corresponde a un cheque . es otra operación bancaria

* determinamos la cuenta de mayor transitoria  a conciliar .

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE       * FROM  t033f
*       WHERE  anwnd  = '0001'
*       AND    eigr1  = i_febep-vgint.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM  t033f
       WHERE  anwnd  = '0001'
       AND    eigr1  = i_febep-vgint ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc EQ 0.

  IF t033f-ktos1 NE 'BANK'.
    MOVE t033f-ktos1 TO w_ctasymb.
    MOVE t033f-bsch2 TO w_ctasymb_clave. "la clave contraria

  ELSE.
    MOVE t033f-ktos2 TO w_ctasymb.
    MOVE t033f-bsch1 TO w_ctasymb_clave.

  ENDIF.
ENDIF.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT  SINGLE      * FROM  t033g
*       WHERE  anwnd  = '0001'
*       AND    ktopl  = i_febko-ktopl
*       AND    ktosy  = w_ctasymb AND
*              komo1  = w_komo1.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM  t033g
       WHERE  anwnd  = '0001'
       AND    ktopl  = i_febko-ktopl
       AND    ktosy  = w_ctasymb AND
              komo1  = w_komo1 ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
IF sy-subrc EQ 0.

  MOVE t033g-konto TO w_hkont.
ENDIF.

*encontramos la cuenta bancaria transitoria que hay que compensar
OVERLAY w_hkont WITH i_febko-hkont ONLY patron.   "patron.
* tratamiento de cheques revalidados.
* primero chequeamos que el documento contable no esté ya compensado
*en la cuenta que le corresponde .
CLEAR w_contador.
CLEAR w_revalida.
IF i_febep-intag = '011' AND i_febep-vgint = 'ZZ02'. "algoritmo de interpretación de los cheques .
*  describe table t_febcl lines w_contador.
*     if w_contador eq 1. "hay que buscar en revalidados porque
* aunque esté compensado no lo identifica como tal .
  LOOP AT  t_febcl INTO wa_febcl WHERE
  selvon NE '*' . "para saber si encontró un documento en concreto

    CLEAR e_febep-b1err. " no tiene error.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT   * FROM bsas CLIENT SPECIFIED
*             WHERE
*             mandt  = sy-mandt AND
*             bukrs  = i_febko-bukrs AND
*             belnr  = wa_febcl-selvon+0(10) AND
*             gjahr  = wa_febcl-selvon+10(04).
*
* NEW CODE
    SELECT *
 FROM bsas CLIENT SPECIFIED
             WHERE
             mandt  = sy-mandt AND
             bukrs  = i_febko-bukrs AND
             belnr  = wa_febcl-selvon+0(10) AND
             gjahr  = wa_febcl-selvon+10(04) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      IF bsas-hkont EQ w_hkont AND bsas-wrbtr = i_febep-kwbtr AND
         bsas-bschl EQ w_ctasymb_clave. "ya se compensó.
        MOVE 'REV' TO  w_komo1.  " REV siginifica revalidado
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT  SINGLE      * FROM  t033g
*         WHERE  anwnd  = '0001'
*         AND    ktopl  = i_febko-ktopl
*         AND    ktosy  = w_ctasymb AND
*                komo1  = w_komo1.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM  t033g
         WHERE  anwnd  = '0001'
         AND    ktopl  = i_febko-ktopl
         AND    ktosy  = w_ctasymb AND
                komo1  = w_komo1 ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc EQ 0.

          MOVE t033g-konto TO w_hkont.
*encontramos la cuenta bancaria transitoria que hay que compensar
          OVERLAY w_hkont WITH i_febko-hkont ONLY patron.   "patron.
          MOVE-CORRESPONDING i_febep TO e_febep.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM skb1
*          WHERE bukrs = i_febko-bukrs
*            AND saknr EQ w_hkont.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM skb1
          WHERE bukrs = i_febko-bukrs
            AND saknr EQ w_hkont ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF skb1-xspeb NE 'X'.
            MOVE 'REV' TO e_febep-kfmod.
            MOVE 'X' TO w_revalida.  "indica que tenenmos que buscar en la otra cuenta
          ELSE.
            CLEAR: e_febep-kfmod, w_revalida.
          ENDIF.
        ENDIF.
        EXIT.
      ENDIF.
    ENDSELECT.

  ENDLOOP.
*     endif.
  IF e_febep-kfmod = 'REV'.
*    clear e_febep-B1ERR. " no tiene error.
    w_revalida = 'X'.
    w_komo1 = 'REV'.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT  SINGLE      * FROM  t033g
*         WHERE  anwnd  = '0001'
*         AND    ktopl  = i_febko-ktopl
*         AND    ktosy  = w_ctasymb AND
*                komo1  = w_komo1.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  t033g
         WHERE  anwnd  = '0001'
         AND    ktopl  = i_febko-ktopl
         AND    ktosy  = w_ctasymb AND
                komo1  = w_komo1 ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc EQ 0.

      MOVE t033g-konto TO w_hkont.
    ENDIF.
    OVERLAY w_hkont WITH i_febko-hkont ONLY patron.   "patron.
  ENDIF.
ENDIF.

* hacemos una primera selección por cuenta contable o por asignación si es cheque revalidado.
IF i_febep-intag = '011' AND i_febep-vgint = 'ZZ02'. "
  IF w_revalida = 'X'.  "es cheque encontró el documento pero este esta compensado. Puede que esté revalidado
*como la partida que se iba a compensar ya  está compensada la borramos
    REFRESH t_febcl.
    CLEAR   t_febcl.

    MOVE i_febep-chect TO w_cheque.  "caracter pero solo numeros
    MOVE i_febep-chect TO w_cheque_str.  "para que
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT        * FROM  bsis INTO TABLE t_bsis
*         WHERE  bukrs  = i_febko-bukrs
*          AND    hkont  = w_hkont  "cuenta ya es otra
*          AND    zuonr  = w_cheque_str
*          AND    bschl  EQ w_ctasymb_clave.
*
* NEW CODE
    SELECT *
 FROM  bsis INTO TABLE t_bsis
         WHERE  bukrs  = i_febko-bukrs
          AND    hkont  = w_hkont  "cuenta ya es otra
          AND    zuonr  = w_cheque_str
          AND    bschl  EQ w_ctasymb_clave ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    DESCRIBE TABLE t_bsis LINES w_contador.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t028g WHERE vgtyp = i_febko-vgtyp
*                                   AND vgext = i_febep-vgext    "Unallocated
*                                   AND vozpm = '-'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t028g WHERE vgtyp = i_febko-vgtyp
                                   AND vgext = i_febep-vgext    "Unallocated
                                   AND vozpm = '-' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
*        move 'X' to e_using_default.     "Default used
**       MOVE g_vgext     TO e_vgext.     "external transaction
    MOVE t028g-vgint TO e_febep-vgint.     "posting rule
    MOVE t028g-intag TO e_febep-intag.     "int. algor.
*        move t028g-pform to e_pform.     "Special rule
*        move t028g-vgsap to e_vgsap.     "SAP bank transaction
  ENDIF.

**  Modificación Herman Rosales Cheques Protestados
**  Inicio
*  IF e_febep-vgext eq '99999'.
*    if e_febep-vgint eq 'ZZ02'.
*      move '011' to e_febep-intag.
*    ELSEIF e_febep-vgint eq 'ZZ03'.
*      move '000' to e_febep-intag.
*    endif.
*  ENDIF.
**  Fin
ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT        * FROM  bsis INTO TABLE t_bsis
*        WHERE  bukrs  = i_febko-bukrs
*         AND    hkont  = w_hkont
*         AND    bschl  EQ w_ctasymb_clave.
*
* NEW CODE
  SELECT *
 FROM  bsis INTO TABLE t_bsis
        WHERE  bukrs  = i_febko-bukrs
         AND    hkont  = w_hkont
         AND    bschl  EQ w_ctasymb_clave ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
ENDIF.
*excluimos los que ya se han leido en posiciones del extracto anterior
*y los que tienen importes distintos.
t_bsis_temp[] = t_bsis[].
REFRESH t_bsis. CLEAR t_bsis.
LOOP AT t_bsis_temp INTO wa_bsis.
  IF wa_bsis-wrbtr NE i_febep-kwbtr.
    CONTINUE.
  ENDIF.

  READ TABLE t_belnr_excl WITH KEY belnr = wa_bsis-belnr
                                   buzei = wa_bsis-buzei.
  IF sy-subrc NE 0.
    APPEND wa_bsis TO t_bsis.
  ELSEIF i_febko-efart = 'M' .
    APPEND wa_bsis TO t_bsis.
  ENDIF.
ENDLOOP.
DESCRIBE TABLE t_bsis LINES w_contador. "para los cheques

t_bsis_copy[] = t_bsis[].
* se leen las tablas de los codigos de iteración y su asignación a la cuenta corriente.
IF i_febep-intag NE '011' OR ( i_febep-intag = '011' AND i_febep-vgint NE 'ZZ02' ). "no es cheque.
  IF i_febko-efart = 'M' .
    i_febep-pipre = ' '.
    i_febep-b1err = 'C'.
  ENDIF.
  IF e_febep-vgint EQ 'ZZ04'.
    MOVE 'ZZ01' TO e_febep-vgint.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT        * FROM  zcb_iter_cc INTO TABLE t_iter
*         WHERE  bukrs      = i_febko-bukrs
*         AND    hbkid      = i_febko-hbkid
*         AND    hktid      = i_febko-hktid.
*
* NEW CODE
  SELECT *
 FROM  zcb_iter_cc INTO TABLE t_iter
         WHERE  bukrs      = i_febko-bukrs
         AND    hbkid      = i_febko-hbkid
         AND    hktid      = i_febko-hktid ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*Begin of change: ReSQ Correction for DELETE on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  SORT t_iter .
*End of change: ReSQ Correction for DELETE on an unsorted Internal Table 20/12/2019 EY_DES02 ECDK917080 *
  LOOP AT t_iter INTO wa_iter WHERE enabled = ' '.
    DELETE t_iter INDEX sy-tabix.
  ENDLOOP.
* tenemos que recorrer por secuencia y orden los criterios de busqueda
* si algunos de ellos no se cumple , la partida se descarta .
  IF w_contador NE 0 AND w_revalida <> 'X'. "no hay registros  no tiene que meterse
    SORT t_iter BY secuencia orden.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
    SORT t_bsis_temp .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
    LOOP AT t_iter INTO wa_iter WHERE enabled = 'X'.
      CLEAR wa_bsis.
      CASE wa_iter-coditer.

        WHEN '0001'.    " Seleción por numero de dias a partir de la fecha que se ejecuta el proceso hasta fin de mes

* necesitamos las funciones de calcula de dias de un mes .
          MOVE wa_iter-desde TO w_dias.

          w_firstdate = sy-datum - w_dias.

          CALL FUNCTION 'LAST_DAY_OF_MONTHS'
            EXPORTING
              day_in            = sy-datum
            IMPORTING
              last_day_of_month = w_lastdate.
*         EXCEPTIONS
*           DAY_IN_NO_DATE          = 1
*           OTHERS                  = 2
          .
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ELSE.
            MOVE 'I' TO r_fechas-sign.
            MOVE 'BT' TO r_fechas-option.
            MOVE w_firstdate TO r_fechas-low.
            MOVE w_lastdate  TO r_fechas-high.
            APPEND r_fechas.

          ENDIF.
          t_bsis_temp[] = t_bsis[].
          REFRESH t_bsis. CLEAR t_bsis.
          LOOP AT t_bsis_temp INTO wa_bsis WHERE bukrs = i_febko-bukrs
                                               AND ( budat IN r_fechas  OR
*ziclos octubre 2010 añadir fecha valor
                                                     valut IN r_fechas ).
            APPEND wa_bsis TO t_bsis.

          ENDLOOP.

        WHEN  '0002'.     " por origen  blanco =  no busca nada


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE  * FROM  tsad4
*                 WHERE  prefix_key  = wa_iter-desde.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM  tsad4
                 WHERE  prefix_key  = wa_iter-desde ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc EQ 0.
            t_bsis_temp[] = t_bsis[].
            REFRESH t_bsis. CLEAR t_bsis.
            LOOP AT t_bsis_temp INTO wa_bsis WHERE bukrs = i_febko-bukrs.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * FROM bkpf CLIENT SPECIFIED    "into table t_bkpf
*                  WHERE  mandt = sy-mandt
*                    AND  bukrs = wa_bsis-bukrs
*                    AND  belnr = wa_bsis-belnr
*                    AND gjahr  = wa_bsis-gjahr.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM bkpf CLIENT SPECIFIED    "into table t_bkpf
                  WHERE  mandt = sy-mandt
                    AND  bukrs = wa_bsis-bukrs
                    AND  belnr = wa_bsis-belnr
                    AND gjahr  = wa_bsis-gjahr ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc EQ 0 AND
                  bkpf-bstat = ' '
               AND  bkpf-xref2_hd =  tsad4-prefix_txt.

                APPEND wa_bsis TO t_bsis.
              ENDIF.
*                endselect.
            ENDLOOP.

          ENDIF.


*          ENDSELECT.

        WHEN '0003'.     "por referencia

          t_bsis_temp[] = t_bsis[].
          REFRESH t_bsis. CLEAR t_bsis.

          IF wa_iter-desde = 'SUC'.   "Sucursal en el campo asignación
            CLEAR r_zuonr.
            SELECT * FROM zcb_iter_suc
                WHERE bukrs = i_febko-bukrs
                      AND hbkid = i_febko-hbkid
                      AND hktid = i_febko-hktid
                      AND refcar = e_febep-texts
                ORDER BY secuencia ASCENDING.

              MOVE 'I' TO r_zuonr-sign.
              MOVE 'EQ' TO r_zuonr-option.
              MOVE zcb_iter_suc-refcont TO r_zuonr-low.
              APPEND r_zuonr.
            ENDSELECT.
            IF r_zuonr IS NOT INITIAL.
              LOOP AT t_bsis_temp INTO wa_bsis WHERE bukrs = i_febko-bukrs.
                w_zuor_n = wa_bsis-zuonr.
                IF w_zuor_n IN r_zuonr.
                  APPEND wa_bsis TO t_bsis.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.

          IF wa_iter-desde = 'DEP'.   "DEPOSITO
            SHIFT i_febep-vgref  LEFT DELETING LEADING   w_zeros.
            LOOP AT t_bsis_temp INTO wa_bsis WHERE bukrs = i_febko-bukrs
                                                 AND  xblnr = i_febep-vgref+0(16).
              APPEND wa_bsis TO t_bsis.

            ENDLOOP.
          ENDIF.
** V1 RVY 12-11-2020
          IF wa_iter-desde = 'ASIG'.   "ASignacion
            LOOP AT t_bsis_temp INTO wa_bsis WHERE bukrs = i_febko-bukrs
                                              AND  zuonr = i_febep-zuonr.
              APPEND wa_bsis TO t_bsis.

            ENDLOOP.
          ENDIF.
** V1 RVY 12-11-2020

        WHEN '0004'.  "Diferencia de Días ( entre fecha extracto y fecha contable )
* se trabaja en conjunto con la condición 0005 FECHA MENOR

*
          MOVE wa_iter-desde TO w_dias.

        WHEN '0005'.     " por Fecha Menor en combinanción con condicion 0004

          IF wa_iter-desde = 'COMP'.   "fecha contable < Fecha Cartola

            t_bsis_temp[] = t_bsis[].
            REFRESH t_bsis. CLEAR t_bsis.
            LOOP AT t_bsis_temp INTO wa_bsis WHERE bukrs = i_febko-bukrs
                                                 AND ( budat < i_febep-budat OR
*ziclos octubre 2010 añadir fecha valor
                                                     valut < i_febep-budat ).
              w_difdias =  i_febep-budat - wa_bsis-budat.
              IF w_difdias <= w_dias.
                APPEND wa_bsis TO t_bsis.
                CONTINUE.
              ENDIF.

              w_difdias =  i_febep-budat - wa_bsis-valut.
              IF w_difdias <= w_dias.
                APPEND wa_bsis TO t_bsis.
                CONTINUE.
              ENDIF.
            ENDLOOP.

          ENDIF.

          IF wa_iter-desde = 'CART'.   "fecha cartola <  Fecha comprobant

            t_bsis_temp[] = t_bsis[].
            REFRESH t_bsis. CLEAR t_bsis.
            LOOP AT t_bsis_temp INTO wa_bsis WHERE bukrs = i_febko-bukrs
                                                 AND ( budat > i_febep-budat OR
*ziclos octubre 2010 añadir fecha valor
                                                     valut > i_febep-budat ).
              w_difdias = wa_bsis-budat - i_febep-budat .
              IF w_difdias <= w_dias.
                APPEND wa_bsis TO t_bsis.
                CONTINUE.
              ENDIF.

              w_difdias = wa_bsis-valut - i_febep-budat .
              IF w_difdias <= w_dias.
                APPEND wa_bsis TO t_bsis.
                CONTINUE.
              ENDIF.
            ENDLOOP.


          ENDIF.

        WHEN '0006'.     " Igual fecha contable e igual valor se toma el primer registro
          "simepre y cuando la fecha contable coincida con la fecha contable
          "del extracto


          t_bsis_temp[] = t_bsis[].
          REFRESH t_bsis. CLEAR t_bsis.
          CLEAR w_control.

          LOOP AT t_bsis_temp INTO wa_bsis WHERE bukrs = i_febko-bukrs AND
                                                ( budat = i_febep-budat OR
*ziclos octubre 2010 añadir fecha valor
                                                     valut = i_febep-budat ).
            APPEND wa_bsis TO t_bsis.  "solo un registro
            EXIT.

          ENDLOOP.

        WHEN '0007'. "Obliga compensacion primer registro
          DESCRIBE TABLE t_bsis LINES w_lines2.
          IF w_lines2 > 0.
            t_bsis_temp[] = t_bsis[].
            REFRESH t_bsis. CLEAR t_bsis.
            MOVE 'X' TO w_control.

            IF w_control = 'X'.  "todas las fechas iguales.
              READ TABLE t_bsis_temp INTO wa_bsis INDEX 1.
              APPEND wa_bsis TO t_bsis.  "solo un registro
            ENDIF.
          ENDIF.
      ENDCASE.

      AT END OF secuencia.
        CLEAR r_fechas. REFRESH r_fechas.
        DESCRIBE TABLE t_bsis LINES w_contador.

        IF w_contador EQ 1.  "¿ tengo 1 registro  ? si , no me hace falta seguir .

          EXIT.
        ELSE.  "pero sino tengo que pasar a la siguiente secuencia.

          t_bsis[] = t_bsis_copy.
        ENDIF.
      ENDAT.

    ENDLOOP.
  ENDIF.
*endif.  "no es cheque intag = '013'
*endif. "w_contador pero de cheques .

  IF w_contador EQ 1. "encontró un solo registro , por lo tanto puede compensar
    CLEAR e_febep-b1err. " no tiene error.
    LOOP  AT t_bsis INTO wa_bsis.
      AT FIRST.
        SUM.
        IF wa_bsis-wrbtr NE i_febep-kwbtr.
          EXIT.
        ENDIF.

      ENDAT.
      CLEAR: t_febcl. REFRESH : t_febcl.

      MOVE-CORRESPONDING i_febep TO t_febcl.
      ADD 1 TO t_febcl-csnum.
      MOVE:
       wa_bsis-bukrs TO t_febcl-agbuk,
       'S'           TO t_febcl-koart,
       wa_bsis-hkont TO t_febcl-agkon,
       'BELNR'       TO t_febcl-selfd,
       wa_bsis-belnr TO t_febcl-selvon+0(10),
       wa_bsis-gjahr TO t_febcl-selvon+10(4),
       wa_bsis-buzei TO t_febcl-selvon+14(3).
      APPEND t_febcl.
      MOVE : wa_bsis-belnr TO t_belnr_excl-belnr,
             wa_bsis-buzei TO t_belnr_excl-buzei.
      APPEND  t_belnr_excl.
    ENDLOOP.
  ELSE.
* para el caso de un solo registro que no cumple
* con las condiciones , y que no debe compensar por importe
* tenemos que conseguir que no compense
* mediante un numero de documento "dummy" Ej: 9999999999
*  describe table t_bsis lines w_contador.
*  if w_contador eq 1.  "¿ tengo 1 registro  pero no cumple con las condiciones
*    loop  at t_bsis into wa_bsis.

*      if wa_bsis-wrbtr eq i_febep-KWBTR.

    IF i_febep-vgint = 'ZC07' AND sy-tcode = 'FEBAN'.  " es anulacion compensacion"
      CLEAR e_febep-b1err. " no tiene error.
      CLEAR: t_febcl. REFRESH : t_febcl.
      MOVE-CORRESPONDING i_febep TO t_febcl.
      IF NOT i_febep-zuonr IS INITIAL.
        MOVE i_febep-zuonr+0(10) TO t_febcl-selvon+0(10).
      ELSE.
        MOVE  '9999999999'  TO t_febcl-selvon+0(10).
      ENDIF.

      ADD 1 TO t_febcl-csnum.
      MOVE:
      wa_bsis-bukrs TO t_febcl-agbuk,
      'S'           TO t_febcl-koart,
      wa_bsis-hkont TO t_febcl-agkon,
      'BELNR'       TO t_febcl-selfd,
*        '9999999999'  to t_febcl-selvon+0(10).
      wa_bsis-gjahr TO t_febcl-selvon+10(4).
*            wa_bsis-buzei to t_febcl-selvon+14(3).
      APPEND t_febcl.
    ELSE.
      CLEAR: t_febcl. REFRESH : t_febcl.
      MOVE-CORRESPONDING i_febep TO t_febcl.
      ADD 1 TO t_febcl-csnum.
      MOVE:
      wa_bsis-bukrs TO t_febcl-agbuk,
      'S'           TO t_febcl-koart,
      wa_bsis-hkont TO t_febcl-agkon,
      'BELNR'       TO t_febcl-selfd,
      '9999999999'  TO t_febcl-selvon+0(10).
*          wa_bsis-gjahr to t_febcl-selvon+10(4),
*          wa_bsis-buzei to t_febcl-selvon+14(3).
      APPEND t_febcl.
    ENDIF.

*   endloop.
* endif.
  ENDIF.
  EXPORT t_belnr_excl TO MEMORY ID 'ZCBAN'.
ELSEIF w_revalida = 'X'.
  IF w_contador EQ 1. "encontró un solo registro, por lo tanto puede compensar
    CLEAR e_febep-b1err. " no tiene error.
    LOOP  AT t_bsis INTO wa_bsis.
      AT FIRST.
        SUM.
        IF wa_bsis-wrbtr NE i_febep-kwbtr.
          EXIT.
        ENDIF.

      ENDAT.
      CLEAR: t_febcl. REFRESH : t_febcl.

      MOVE-CORRESPONDING i_febep TO t_febcl.
      ADD 1 TO t_febcl-csnum.
      MOVE:
       wa_bsis-bukrs TO t_febcl-agbuk,
       'S'           TO t_febcl-koart,
       wa_bsis-hkont TO t_febcl-agkon,
       'BELNR'       TO t_febcl-selfd,
       wa_bsis-belnr TO t_febcl-selvon+0(10),
       wa_bsis-gjahr TO t_febcl-selvon+10(4),
       wa_bsis-buzei TO t_febcl-selvon+14(3).
      APPEND t_febcl.
      MOVE : wa_bsis-belnr TO t_belnr_excl-belnr,
             wa_bsis-buzei TO t_belnr_excl-buzei.
      APPEND  t_belnr_excl.
    ENDLOOP.
  ELSE.
    CLEAR: t_febcl. REFRESH : t_febcl.
    MOVE-CORRESPONDING i_febep TO t_febcl.
    ADD 1 TO t_febcl-csnum.
    MOVE:
    wa_bsis-bukrs TO t_febcl-agbuk,
    'S'           TO t_febcl-koart,
    wa_bsis-hkont TO t_febcl-agkon,
    'BELNR'       TO t_febcl-selfd,
    '9999999999'  TO t_febcl-selvon+0(10).
*          wa_bsis-gjahr to t_febcl-selvon+10(4),
*          wa_bsis-buzei to t_febcl-selvon+14(3).
    APPEND t_febcl.
  ENDIF.
  EXPORT t_belnr_excl TO MEMORY ID 'ZCBAN'.
ENDIF.
*else.
*  move 'C' to i_febep-B1ERR.
*  move-corresponding i_febep to e_febep.
*endif. "si la trransaccion es distinta de FEBAN

IF i_febko-efart = 'M'.
  i_febko-efart = 'E'.
  MOVE-CORRESPONDING i_febko TO e_febko.
ENDIF.

*V1 RVY para Cheques con Sociedad Emisora Distinta de Sociadad pagadora.
*
IF i_febep-intag = '011' AND i_febep-vgint = 'ZZ02'.
  describe table t_febcl lines w_contador.
  if t_febcl-selvon+0(1) EQ '*'.
     IF w_contador EQ 1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM PAYR INTO t_payr
*                 WHERE  zbukr = I_FEBKO-bukrs
*                    AND  HBKID = I_FEBKO-HBKID
*                    and  HKTID = I_FEBKO-HKTID
*                    AND  RZAWE = 'C'
*                    AND  CHECT = c_check.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM PAYR INTO t_payr
                 WHERE  zbukr = I_FEBKO-bukrs
                    AND  HBKID = I_FEBKO-HBKID
                    and  HKTID = I_FEBKO-HKTID
                    AND  RZAWE = 'C'
                    AND  CHECT = c_check ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc EQ 0.
           t_febcl-selvon+0(10)  = t_payr-vblnr.
           t_febcl-selvon+10(04) = t_payr-gjahr.
           w_esnum               = t_febcl-esnum.
           MODIFY t_febcl INDEX w_esnum.
        endif.
     endif.
  endif.
 ENDIF.
