*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
PROGRAM  zfich001 MESSAGE-ID z001.


TABLES: zjdatos_edocheq,
        zfich001,
        zfich002,
        apqd,
        apql,
        tst01,
        bapiret2,
        t100,
        bdclm,
        payr,
        bseg.

DATA: BEGIN OF logtable OCCURS 50,   " plain log information in TemSe
         enterdate LIKE btctle-enterdate,
         entertime LIKE btctle-entertime,
         logmessage(400) TYPE c,
       END OF logtable.
DATA: l_logtable LIKE logtable.
DATA: i_apql LIKE apql OCCURS 100 WITH HEADER LINE.

DATA:
  digits(10)  TYPE c VALUE '0123456789',
  mtext(124)  TYPE c,                  "Messagetext
  mtext1(124) TYPE c,                  "Messagetext
  mtext2(273) TYPE c,                  "Messagetext
  do_condense TYPE c,
  mtvaroff    TYPE i,
  parcnt      TYPE i,
  mparcnt     TYPE i,
  x(1)        TYPE c VALUE 'X',
  numero      LIKE bkpf-belnr,
  agencia     LIKE bseg-zz_agencia.
*
DATA:                                  "Aufbereitung Messagetext
  BEGIN OF mttab  OCCURS 4,
   off(02) TYPE n,
   len(02) TYPE n,
   text(99),
 END OF mttab.
*
DATA:                                  "ParameterAufbereitung
  BEGIN OF par,
   len(02) TYPE n,
   text(254),
 END OF par.

FIELD-SYMBOLS:
  <mtxt>,
  <vtxt>.


START-OF-SELECTION.
 SELECT * FROM zjdatos_edocheq  WHERE   ( estado = 'P' or estado = 'E' )
                                and fecha > 00000000
                      ORDER BY fecha.

    PERFORM  busca_resultado.

  ENDSELECT.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  BUSCA_RESULTADO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_resultado.
data subrc like sy-subrc.
  subrc = 4.
  SELECT  *  FROM apql
           WHERE   mandant = sy-mandt
           AND     groupid = zjdatos_edocheq-jdatos
           order by CREDATE CRETIME.
    subrc = 0.
   ENDSELECT. "

  IF subrc = 0.
    REFRESH logtable.
    FREE logtable.
    PERFORM read_bdc_log_plain(rsbdc_protocol)
      TABLES
        logtable
      USING
        apql-temseid apql-mandant.

    LOOP AT logtable.
      bdclm = logtable.


      IF bdclm-mart  = 'E' OR
         bdclm-mnr = '312' AND
         bdclm-mid = 'F5'.

        IF bdclm-mcnt > 0.
          bdclm-mcnt = bdclm-mcnt - 1.
        ENDIF.

        CLEAR numero.
        PERFORM get_text.


        IF  bdclm-mnr = '312' AND
            bdclm-mid = 'F5'.

          CLEAR zfich001.
          IF zjdatos_edocheq-jdatos+0(2) = 'CE'.
            zfich001-estado = '10'.
          ENDIF.
          IF zjdatos_edocheq-jdatos+0(2) = 'CF'.
            zfich001-estado = '11'.
          ENDIF.

          IF zjdatos_edocheq-jdatos+0(2) = 'AN'.
            zfich001-estado = '12'.
          ENDIF.
          IF zjdatos_edocheq-jdatos+0(2) = 'PR'.
            zfich001-estado = '13'.
          ENDIF.
          IF zjdatos_edocheq-jdatos+0(2) = 'RE'.
            zfich001-estado = '14'.
          ENDIF.

          IF zjdatos_edocheq-jdatos+0(2) = 'CC'.
            zfich001-estado = '15'.
          ENDIF.
**mod ini
          SELECT SINGLE * FROM   zfich002 WHERE estado = zfich001-estado
                                          AND   bukrs = zfich001-bukrs.
**mod fin
          IF sy-subrc = 0 AND zfich002-tipo_est = 'C'.
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
            SELECT SINGLE  * FROM bseg WHERE bukrs = zjdatos_edocheq-bukrs
                                      AND   belnr =  numero
                                      AND   gjahr =  zjdatos_edocheq-fecha+0(4)
                                      AND   shkzg =  zfich002-shkzg.
            IF sy-subrc = 0.
              zfich001-agencia = bseg-zz_agencia.
              zfich001-hkont   = bseg-hkont.

            ENDIF.
          ENDIF.
          SELECT SINGLE * FROM payr WHERE zbukr = zjdatos_edocheq-bukrs
                                    AND   hbkid = zjdatos_edocheq-hbkid
                                    AND   hktid = zjdatos_edocheq-hktid
                                    AND   rzawe = 'C'
                                    AND   chect = zjdatos_edocheq-chect.

         IF sy-subrc <> 0.
            SELECT SINGLE * FROM payr WHERE zbukr = zjdatos_edocheq-bukrs
                                    AND   hbkid = zjdatos_edocheq-hbkid
                                    AND   hktid = zjdatos_edocheq-hktid
                                    AND   rzawe = ''
                                    AND   chect = zjdatos_edocheq-chect.
          endif.

          IF sy-subrc = 0.
            zfich001-bukrs     = zjdatos_edocheq-bukrs.
            zfich001-lifnr     = payr-lifnr.
            zfich001-hbkid     = zjdatos_edocheq-hbkid.
            zfich001-hktid     = zjdatos_edocheq-hktid.
            zfich001-chect     = zjdatos_edocheq-chect.
            zfich001-fecha_reg = logtable-enterdate.
            zfich001-hora_reg  = logtable-entertime.
            zfich001-belnr     = numero.
            zfich001-gjahr     =  zjdatos_edocheq-fecha+0(4).


            IF zjdatos_edocheq-jdatos+0(2) = 'CE'.
              zfich001-estado = '10'.
            ENDIF.

            zfich001-usuario   = apql-creator.

            INSERT zfich001.
            zjdatos_edocheq-estado = 'F'.

            payr-zzestado_ult = zjdatos_edocheq-ultimo_estado.
            payr-zzfecha_reg = logtable-enterdate.
            payr-zzhora_reg  = logtable-entertime.
            MODIFY payr.
          ENDIF.
        ELSE.
          zjdatos_edocheq-estado = 'E'.
        ENDIF.

        zjdatos_edocheq-observacion = mtext.
        MODIFY  zjdatos_edocheq.

      ENDIF.

    ENDLOOP.
  ENDIF.
ENDFORM.                   "BUSCA_RESULTADO
*&---------------------------------------------------------------------*
*&      Form  get_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_text.
*
*** Aufbereiten des Messagetextes
*
  DATA: shiftln TYPE i,
        vartcnt TYPE i,
        fdpos LIKE sy-fdpos.

  IF bdclm-mparcnt CN digits.          "Korrupter Datensatz:
    bdclm-mparcnt = 0.                 "z.B. Hexnullen
  ENDIF.

  SELECT SINGLE * FROM t100
   WHERE sprsl = sy-langu
   AND  arbgb  = bdclm-mid
   AND  msgnr  = bdclm-mnr.
*
  IF sy-subrc EQ 0.
    CLEAR: mtext,
           parcnt,
           mparcnt,
           sy-fdpos.
*
    MOVE bdclm-mparcnt TO mparcnt.
*
    IF t100-text CA '$&'.              "Kennung fuer parameter:
      MOVE t100-text TO mtext1.        " alt '$' --- neu '&'
    ELSE.
      MOVE t100-text TO mtext.
      EXIT.
    ENDIF.
* variable teile aus batch-input protokoll in mttab bringen.
    REFRESH mttab.
    CLEAR shiftln.
    DO mparcnt TIMES.
      CLEAR: par, mttab.
      MOVE bdclm-mpar TO par.
      IF par-len CN digits OR par-len EQ 0.        "convert_no_number
        par-len  = 1.                              "entschärfen
        par-text = ' '.
        shiftln  = 2.
      ELSE.
        shiftln = par-len + 2.
      ENDIF.
      WRITE par-text TO mttab-text(par-len).
      MOVE par-len  TO mttab-len.
      MOVE mparcnt  TO mttab-off.
      APPEND mttab.
      IF bdclm-mnr = '312' AND
         bdclm-mid = 'F5'  AND
        sy-tabix   = 1.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = mttab-text
          IMPORTING
            output = numero.






      ENDIF.
      SHIFT bdclm-mpar BY shiftln PLACES.
    ENDDO.
*
    mtext2 = mtext1.
    do_condense = x.
    CLEAR: vartcnt, mtvaroff.
    WHILE vartcnt LE 3.
      vartcnt = vartcnt + 1.
      IF mtext1 CA '$&'.
        parcnt = parcnt + 1.
        IF sy-fdpos GT 0.
          fdpos = sy-fdpos - 1.        " neu sy-fdpos -1
        ELSE.
          fdpos = sy-fdpos.
        ENDIF.
        SHIFT mtext1 BY sy-fdpos PLACES.
        IF mtext1(1) EQ '&'.
          SHIFT mtext1 BY 1 PLACES.
          CASE mtext1(1).
            WHEN ' '.                  "'& '
              PERFORM replace_var USING '& ' parcnt fdpos.
            WHEN '$'.                  "'&&'
              PERFORM replace_var USING '&&' 0      fdpos.
            WHEN '1'.                                       "'&1'
              PERFORM replace_var USING '&1' 1      fdpos.
            WHEN '2'.                                       "'&2'
              PERFORM replace_var USING '&2' 2      fdpos.
            WHEN '3'.                                       "'&3'
              PERFORM replace_var USING '&3' 3      fdpos.
            WHEN '4'.                                       "'&4'
              PERFORM replace_var USING '&4' 4      fdpos.
            WHEN OTHERS.               "'&'
              PERFORM replace_var USING '&<' parcnt fdpos.
          ENDCASE.
        ENDIF.
        IF mtext1(1) EQ '$'.
          SHIFT mtext1 BY 1 PLACES.
          CASE mtext1(1).
            WHEN ' '.                  "'$ '
              PERFORM replace_var USING '$ ' parcnt  fdpos.
            WHEN '$'.                  "'$$'
              PERFORM replace_var USING '$$' 0       fdpos.
            WHEN '1'.                                       "'$1'
              PERFORM replace_var USING '$1' 1       fdpos.
            WHEN '2'.                                       "'$2'
              PERFORM replace_var USING '$2' 2       fdpos.
            WHEN '3'.                                       "'$3'
              PERFORM replace_var USING '$3' 3       fdpos.
            WHEN '4'.                                       "'$4'
              PERFORM replace_var USING '$4' 4       fdpos.
            WHEN OTHERS.               "'$'
              PERFORM replace_var USING '$<' parcnt  fdpos.
          ENDCASE.
        ENDIF.
      ENDIF.
    ENDWHILE.
*
    IF mtext2 CA '%%_D_%%'.
      REPLACE '%%_D_%%' WITH '$' INTO mtext2.
    ENDIF.
    IF mtext2 CA '%%_A_%%'.
      REPLACE '%%_A_%%' WITH '&' INTO mtext2.
    ENDIF.
    IF do_condense EQ space.
      mtext = mtext2.
    ELSE.
      CONDENSE mtext2 .
      mtext = mtext2.
    ENDIF.
  ELSE.
    mtext = '???????????????????????????????????????????????????'.
  ENDIF.
*
ENDFORM.                               " get_text

*&---------------------------------------------------------------------*
*&      Form  replace_var
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VARK       text
*      -->VARI       text
*      -->VARPOS     text
*----------------------------------------------------------------------*
FORM replace_var USING vark
                       vari TYPE i
                       varpos.
*
*   ersetzen der variablen teile einer fehlermeldung
*
  DATA: var(02),
        var1,
        moff TYPE i.
*
  CLEAR: mttab , moff.
  var = vark.
  SHIFT var BY 1 PLACES.
  CASE var.
    WHEN ' '.                          "'& '
      READ TABLE mttab INDEX vari.
      IF sy-subrc EQ 0.
        moff = varpos + mtvaroff.                           "neu
        ASSIGN mtext2+moff(*) TO <mtxt>.                    "neu
        ASSIGN mttab-text(mttab-len) TO <vtxt>.
        var1 = vark.
        REPLACE var1 WITH <vtxt>     INTO <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      ELSE.
        IF vari GT mparcnt.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '  ' INTO <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        ELSE.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '%%_Z_%%' INTO <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        ENDIF.
      ENDIF.
    WHEN '$'.                          "'&&'
      moff = varpos + mtvaroff.                             "neu
      ASSIGN mtext2+moff(*) TO <mtxt>.                      "neu
      REPLACE vark WITH '%%_D_%%' INTO <mtxt>.              "neu
      mtvaroff = 7.                                         "neu
    WHEN '&'.                          "'&&'
      moff = varpos + mtvaroff.                             "neu
      ASSIGN mtext2+moff(*) TO <mtxt>.                      "neu
      REPLACE vark WITH '%%_A_%%' INTO <mtxt>.              "neu
      mtvaroff = 7.                                         "neu
    WHEN '<'.                                               "'&1'
      READ TABLE mttab INDEX vari.
      IF sy-subrc EQ 0.
        IF vark EQ '&<'.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          ASSIGN mttab-text(mttab-len) TO <vtxt>.
          REPLACE '&' WITH <vtxt>     INTO <mtxt>.          "neu
          mtvaroff = mttab-len.                             "neu
        ENDIF.
        IF vark EQ '$<'.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          ASSIGN mttab-text(mttab-len) TO <vtxt>.
          REPLACE '$' WITH <vtxt>     INTO <mtxt>.          "neu
          mtvaroff = mttab-len.                             "neu
        ENDIF.
      ELSE.
        IF vark EQ '&<'.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE '&' WITH ' ' INTO <mtxt>.                 "neu
          mtvaroff = 1.                                     "neu
        ENDIF.
        IF vark EQ '$<'.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE '$' WITH ' ' INTO <mtxt>.                 "neu
          mtvaroff = 1.                                     "neu
        ENDIF.
      ENDIF.
    WHEN '1'.                                               "'&1'
      READ TABLE mttab INDEX 1.
      IF sy-subrc EQ 0.
        moff = varpos + mtvaroff.                           "neu
        ASSIGN mtext2+moff(*) TO <mtxt>.                    "neu
        ASSIGN mttab-text(mttab-len) TO <vtxt>.
        REPLACE vark WITH <vtxt>     INTO <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      ELSE.
        IF vari GT mparcnt.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '  ' INTO <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        ELSE.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '%%_Z_%%' INTO <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        ENDIF.
      ENDIF.
    WHEN '2'.                                               "'&2'
      READ TABLE mttab INDEX 2.
      IF sy-subrc EQ 0.
        moff = varpos + mtvaroff.                           "neu
        ASSIGN mtext2+moff(*) TO <mtxt>.                    "neu
        ASSIGN mttab-text(mttab-len) TO <vtxt>.
        REPLACE vark WITH <vtxt>     INTO <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      ELSE.
        IF vari GT mparcnt.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '  ' INTO <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        ELSE.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '%%_Z_%%' INTO <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        ENDIF.
      ENDIF.
    WHEN '3'.                                               "'&3'
      READ TABLE mttab INDEX 3.
      IF sy-subrc EQ 0.
        moff = varpos + mtvaroff.                           "neu
        ASSIGN mtext2+moff(*) TO <mtxt>.                    "neu
        ASSIGN mttab-text(mttab-len) TO <vtxt>.
        REPLACE vark WITH <vtxt>     INTO <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      ELSE.
        IF vari GT mparcnt.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '  ' INTO <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        ELSE.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '%%_Z_%%' INTO <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        ENDIF.
      ENDIF.
    WHEN '4'.                                               "'&4'
      READ TABLE mttab INDEX 4.
      IF sy-subrc EQ 0.
        moff = varpos + mtvaroff.                           "neu
        ASSIGN mtext2+moff(*) TO <mtxt>.                    "neu
        ASSIGN mttab-text(mttab-len) TO <vtxt>.
        REPLACE vark WITH <vtxt>     INTO <mtxt>.           "neu
        mtvaroff = mttab-len.                               "neu
      ELSE.
        IF vari GT mparcnt.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '  ' INTO <mtxt>.               "neu
          mtvaroff = 2.                                     "neu
        ELSE.
          moff = varpos + mtvaroff.                         "neu
          ASSIGN mtext2+moff(*) TO <mtxt>.                  "neu
          REPLACE vark WITH '%%_Z_%%' INTO <mtxt>.          "neu
          mtvaroff = 7.                                     "neu
        ENDIF.
      ENDIF.
*
  ENDCASE.
*
  do_condense = space.
*
ENDFORM.                    "replace_var
