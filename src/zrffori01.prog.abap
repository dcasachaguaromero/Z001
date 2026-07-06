*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
************************************************************************
*                                                                      *
* Include RFFORI01, used in the payment print programs RFFOxxxz        *
* with subroutines for printing checks                                 *
* and subroutines for prenumbered checks (see below)                   *
*                                                                      *
************************************************************************

*----------------------------------------------------------------------*
* FORM SCHECK                                                          *
*----------------------------------------------------------------------*
* Druck des Avises mit Allongeteil                                     *
* (Beispiel Scheck)                                                    *
* Gerufen von END-OF-SELECTION (RFFOxxxz)                              *
*----------------------------------------------------------------------*
* prints a remittance advice with a check                              *
* called by END-OF-SELECTION (RFFOxxxz)                                *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
********************** scheck *************************
* Imprime cheques individuales                        *
*                                                     *
********************** scheck *************************



********************** scheck *************************
* Imprime cheques individuales                        *
*                                                     *
********************** scheck *************************

FORM scheck_new.


  DATA: BEGIN OF datos OCCURS 30.
          INCLUDE STRUCTURE zform2016cheq_c05_est.
  DATA: END OF datos.



  DATA: ii(3)        TYPE n,
        zz(3)        TYPE n,
        zmonto1(22)  TYPE c,
        nchq(1)      TYPE n,
        escrito(140) TYPE c,
        linea1(70)   TYPE c,
        linea2(70)   TYPE c,
        v_amount,
        zncorr(5)    TYPE n,
        primer(1)    TYPE c,
        zbanco(30)  TYPE c,
        zsociedad(30) TYPE c,
        fechafcheq(40)  TYPE c,
        XCIUDAD(15) TYPE C.

*----------------------------------------------------------------------*
* Abarbeiten der extrahierten Daten                                    *
* loop at extracted data                                               *
*----------------------------------------------------------------------*
  IF flg_sort NE 2.
    SORT BY avis.
    flg_sort = 2.
  ENDIF.

  REFRESH: datos, datos_det.
  zncorr = 0.
  nchq   = 0.

  LOOP.


    AT NEW reguh-zbukr.
      PERFORM buchungskreis_daten_lesen.                  .
    ENDAT.

*-- Neuer Zahlweg ------------------------------------------------------
*-- new payment method -------------------------------------------------
    AT NEW reguh-rzawe.

      flg_probedruck = 0.              "fÃ¼r diesen Zahlweg wurde noch

      PERFORM zahlweg_daten_lesen.


*************** Descripcion banco ************************************

      DATA :p_bankl TYPE t012-bankl.

      SELECT SINGLE bankl
           FROM  t012
           INTO  p_bankl
          WHERE  bukrs EQ reguh-zbukr
            AND  hbkid EQ reguh-hbkid.

      IF sy-subrc EQ 0.
        SELECT SINGLE banka
             FROM  bnka
             INTO  reguh-name4
            WHERE  banks EQ reguh-land1
              AND  bankl EQ p_bankl.
      ENDIF.
      CLEAR v_nomban.
      v_nomban = reguh-name4.

    ENDAT.


*-- Neue Hausbank ------------------------------------------------------
*-- new house bank -----------------------------------------------------
    AT NEW reguh-ubnkl.

      PERFORM hausbank_daten_lesen.

*     Felder fÃ¼r FormularabschluÃŸ initialisieren
*     initialize fields for summary
      cnt_formulare = 0.
      cnt_hinweise  = 0.
      sum_abschluss = 0.

      flg_druckmodus = 0.
*     Vornumerierte Schecks: erste Schecknummer ermitteln
*     prenumbered checks: find out first check number
      IF flg_schecknum NE 0.
        PERFORM schecknummer_ermitteln USING 1.
      ENDIF.

    ENDAT.


*-- Neue Kontonummer bei der Hausbank ----------------------------------
*-- new account number with house bank ---------------------------------
    AT NEW reguh-ubknt.


      regud-obknt = reguh-ubknt.

    ENDAT.


*-- Neue EmpfÃ¤ngerbank -------------------------------------------------
*-- new bank of payee --------------------------------------------------
    AT NEW reguh-zbnkl.
      CLEAR reguh1.
      CLEAR regud1.
      CLEAR spell1.
      REFRESH spell1.
      REFRESH reguh1.
      REFRESH regud1.

      PERFORM empfbank_daten_lesen.

    ENDAT.


*-- Neue Zahlungsbelegnummer -------------------------------------------
*-- new payment document number ----------------------------------------
    AT NEW reguh-vblnr.

*     Angabentabelle und KontowÃ¤hrung fÃ¼r die OeNB-Meldung (Ã–sterreich)
*     Austria only
      IF t042e-xausl EQ 'X' AND        "nur Auslandsscheck
        hlp_laufk NE 'P'.              "kein HR
        REFRESH up_oenb_angaben.
        CLEAR up_oenb_kontowae.
        READ TABLE up_oenb_kontowae WITH KEY reguh-ubhkt.
        IF sy-subrc NE 0.
          PERFORM hausbank_konto_lesen.
          up_oenb_kontowae-ubhkt = reguh-ubhkt.
          PERFORM isocode_umsetzen
            USING t012k-waers up_oenb_kontowae-uwaer.
          APPEND up_oenb_kontowae.
        ENDIF.
      ENDIF.

*     Lesen der Referenzangaben (Schweiz)
*     Switzerland only
      PERFORM hausbank_konto_lesen.

*     Kein Druck falls FremdwÃ¤hrung, aber kein FremdwÃ¤hrungsscheck
*     no print if foreign currency, but global &REGUD-WAERS& is missing
      flg_kein_druck = 0.
      IF reguh-waers NE t001-waers AND flg_fw_scheck EQ 0.
        err_fw_scheck-fname = t042e-zforn.
        MOVE-CORRESPONDING reguh TO err_fw_scheck.
        COLLECT err_fw_scheck.
        flg_kein_druck = 1.            "kein Druck mÃ¶glich
      ENDIF.                           "no print

      IF flg_kein_druck EQ 0.

        PERFORM zahlungs_daten_lesen.

        PERFORM summenfelder_initialisieren.

        IF flg_schecknum NE 0.
          PERFORM schecknummer_ermitteln USING 2.
        ENDIF.
      ENDIF.
    ENDAT.

*sbuchungskreis ---------------------------------------
*-- New invoice company code -------------------------------------------
    AT NEW regup-bukrs.

      IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
        IF ( regup-bukrs NE reguh-zbukr OR flg_diff_bukrs EQ 1 ) AND
           ( reguh-absbu EQ space OR reguh-absbu EQ reguh-zbukr ).
          flg_diff_bukrs = 1.
          SELECT SINGLE * FROM t001 INTO *t001
            WHERE bukrs EQ regup-bukrs.
          regud-abstx = *t001-butxt.
          regud-absor = *t001-ort01.
        ENDIF.
      ENDIF.
    ENDAT.


*******************************************************************
*LSS AMVC 29-OCT- 2009
    SELECT SINGLE sgtxt INTO t_bseg-sgtxt
            FROM  bsak
           WHERE  bukrs  EQ regup-bukrs
             AND  lifnr  EQ regup-lifnr
             AND  gjahr  EQ regup-gjahr
             AND  belnr  EQ regup-belnr
             AND  buzei  EQ regup-buzei.


    AT daten.
*   perfom f_for_voucher.



    ENDAT.


*-- Ende der Zahlungsbelegnummer ---------------------------------------
*-- end of payment document number -------------------------------------
    AT END OF reguh-vblnr.

      IF flg_kein_druck EQ 0.

*       Zahlbetrag ohne Aufbereitungszeichen fÃ¼r Codierzeile speichern
*       store numerical payment amount for code line
        IF reguh-waers EQ t001-waers.
          regud-socra = regud-swnes.
        ELSE.
          regud-socra = 0.
          PERFORM laender_lesen USING t001-land1.
          IF t005-intca EQ 'DE'.
            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
            IF hlp_waers EQ 'DEM' OR hlp_waers EQ 'EUR'.
              regud-socra = regud-swnes.
            ENDIF.
          ENDIF.
          IF t005-intca EQ 'AT'.
            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
            IF hlp_waers EQ 'ATS' OR hlp_waers EQ 'EUR'.
              regud-socra = regud-swnes.
            ENDIF.
          ENDIF.
        ENDIF.
        IF reguh-waers EQ t012k-waers.
          regud-socrb = regud-swnes.
        ELSE.
          regud-socrb = 0.
        ENDIF.

        PERFORM ziffern_in_worten.

*       Summenfelder hochzÃ¤hlen und aufbereiten
*       add up total amount fields
        ADD 1            TO cnt_formulare.
        ADD reguh-rbetr  TO sum_abschluss.
        WRITE:
          cnt_hinweise   TO regud-avish,
          cnt_formulare  TO regud-zahlt,
          sum_abschluss  TO regud-summe CURRENCY t001-waers.
        TRANSLATE:
          regud-avish USING ' *',
          regud-zahlt USING ' *',
          regud-summe USING ' *'.

        IF hlp_xhrfo EQ space.

* Nur fÃ¼r Brasilien (Check auf Land liegt in Funktionsbaustein)
* Only Brazil (Check on country within the function module)

          CALL FUNCTION 'BOLETO_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.

          CALL FUNCTION 'KOREA_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.
        ENDIF.



        IF reguh-rwbtr NE 0.
*Imprime última línea de detalle acumulada.
          IF v_acumula EQ 'X'  .
            v_xblnr = regup-xblnr.
            regup-xblnr = space.
            t_bseg-hkont = regup-hkont.
            t_bseg-stcd1 = reguh-zstc1.
            CLEAR reguh-rbetr.
            t_bseg-zfbdt = regup-zfbdt.
            WRITE v_totlin TO   t_bseg-debe CURRENCY regud-waers.
            regup-xblnr = v_xblnr.

*Imprime documentos acumulados. Máximo 2 líneas agrupadas.
            IF v_group = 'X'.
              v_largo = STRLEN( v_doctos ).
              IF v_largo > 1.
                v_largo = v_largo - 1.
                v_doctos = v_doctos+0(v_largo).
                CALL FUNCTION 'WRITE_FORM'
                  EXPORTING
                    element  = '777'
                    function = 'APPEND'
                  EXCEPTIONS
                    window   = 1
                    element  = 2.
              ENDIF.
              CLEAR: v_group, v_doctos, v_largo, v_cont.
            ENDIF.
          ENDIF.
*----------------------------------------------------------------------
**Alvaro Vergara Madrid Alynea MVC Amercias
*Monto Total y Descripción del Monto Total.
*Monto en Texto.. Control de Despliegue para pagos Masivos.
*----------------------------------------------------------------------


          IF v_acumula = 'X'.
            CLEAR: v_totlin, v_acumula.
          ENDIF.

          CALL FUNCTION 'SPELL_AMOUNT'
           EXPORTING
             amount          = reguh-rwbtr
             currency        = 'CLP'
*   FILLER          = ' '
             language        = sy-langu
           IMPORTING
             in_words        = spell
           EXCEPTIONS
             not_found       = 1
             too_large       = 2
             OTHERS          = 3.

          TRANSLATE spell-word TO UPPER CASE.

*                     Modificacion 17-01-2017 se omiten asteriscos iniciales y largo 66
*         CONCATENATE '***' spell-word  '***' INTO escrito SEPARATED BY space.
          CONCATENATE spell-word  '***' INTO escrito SEPARATED BY space.

*Dejamos Siempre en mayuscula el nombre.

          CLEAR: v_znm1s.
          IF NOT regud-znm2s IS INITIAL.
            TRANSLATE regud-znm1s USING '* '.
          ENDIF.
          CONCATENATE regud-znm1s regud-znm2s INTO v_znm1s.
          CONDENSE  v_znm1s.
          CONCATENATE v_znm1s  '***' INTO v_znm1s.
          TRANSLATE v_znm1s USING '# '.
          TRANSLATE v_znm1s USING '  '.
*Fin Cambio

          TRANSLATE v_znm1s TO UPPER CASE.
          TRANSLATE regud-znm1s TO UPPER CASE.

********** Fin Cambio

          CLEAR: t_bseg-debe, t_bseg-haber.
          v_znm2s = regud-znm2s.
          TRANSLATE v_znm2s TO UPPER CASE.
          regud-znm2s = v_znm2s.
          CLEAR: t_bseg-debe, t_bseg-haber.

******************************************************************
*Recuperamos nombre que debe ir en el cheque.
          DATA: v_adrnr LIKE lfa1-adrnr,
                x TYPE i,
                y TYPE i,
                v_cadena(10).

          IF reguh-empfg IS INITIAL.
            SELECT SINGLE adrnr
            INTO v_adrnr
            FROM lfa1
            WHERE lifnr = reguh-lifnr.
            IF sy-subrc = 0.
* Modificación 23.02.2010
              CLEAR: v_znm1s.
* FIN Modificación 23.02.2010
              SELECT SINGLE name1 name2
              INTO (v_znm1s, v_znm2s)
              FROM adrc
              WHERE addrnumber = v_adrnr.
            ENDIF.
          ELSE.
            CLEAR: x, y.
            x = STRLEN( reguh-empfg ).
            DO x TIMES.
              IF reguh-empfg+y(1) CA '0123456789'.
                CONCATENATE v_cadena reguh-empfg+y(1) INTO v_cadena.
              ENDIF.
              y = y + 1.
            ENDDO.

            SELECT SINGLE adrnr
            INTO v_adrnr
            FROM lfa1
            WHERE lifnr = v_cadena.
            IF sy-subrc = 0.
* Modificación 23.02.2010
              CLEAR:  v_znm1s, v_znm2s.
* FIN Modificación 23.02.2010
              SELECT SINGLE name1 name2
              INTO (v_znm1s, v_znm2s)
              FROM adrc
              WHERE addrnumber = v_adrnr.
            ENDIF.
          ENDIF.

          TRANSLATE v_znm1s TO UPPER CASE.
          TRANSLATE v_znm2s TO UPPER CASE.
          CONCATENATE v_znm1s v_znm2s INTO v_znm1s.
          CONCATENATE v_znm1s '***' INTO v_znm1s.
          CONDENSE v_znm1s.
          TRANSLATE v_znm1s USING '# '.
          TRANSLATE v_znm1s USING '  '.
        call function 'SCP_REPLACE_STRANGE_CHARS'
          exporting
          intext = v_znm1s
          importing
          outtext = v_znm1s.

*Fin Cambio

* FIN Modificación 23.02.2010
******************************************************************
*Eliminamos caracteres especiales.
          PERFORM revisa_string USING regud-znm1s.
          PERFORM revisa_string USING regud-znm2s.
          PERFORM revisa_string USING reguh-name1.

          reguh-name2 = reguh-name2+0(13).
          CONDENSE reguh-name2.
          PERFORM revisa_string USING reguh-name2.
          PERFORM revisa_string USING v_znm1s.
          CLEAR f_largo.
          f_largo = STRLEN( v_znm1s ).

          PERFORM revisa_string USING reguh-znme1.
          reguh-znme2 = reguh-znme2+0(13).
          CONDENSE reguh-znme2.
          PERFORM revisa_string USING reguh-znme2.

          PERFORM revisa_string USING spell-word.

******************************************************************
          MOVE spell TO spell1.
          MOVE reguh TO reguh1.
          MOVE regud TO regud1.
******************************************************************
* Se rescata  nombre de cheque por sociedad.

          SELECT SINGLE tdname
             FROM zfirmadigital
             INTO fm1
            WHERE bukrs EQ regup-zbukr
              AND orden EQ 1.

          SELECT SINGLE tdname
             FROM zfirmadigital
             INTO fm2
            WHERE bukrs EQ regup-zbukr
              AND orden EQ 2.

********************************************************************
* Modificación 24.02.2010
* Se revisa si corresponde inmprimir con cheque cruzado o normal.
* Si campo BSEG-XREF3 = 'X' ==> cheque cruzado
          CLEAR v_cruzado.
          CLEAR v_desc_mot.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
          SELECT SINGLE * FROM bseg
            WHERE bukrs = regup-bukrs
              AND belnr = regup-belnr
              AND gjahr = regup-gjahr
              AND buzei = regup-buzei.

          IF sy-subrc EQ 0 AND bseg-xref3 = 'X'.
            v_cruzado = '| |'.
          ENDIF.

          SELECT SINGLE zzdescr FROM zagencia
            INTO v_desc_agen WHERE zzcod_unidad = bseg-zz_agencia.


          SELECT SINGLE zzdescr FROM zmot_emis
             INTO v_desc_mot WHERE zzmot_emis = bseg-zzmot_emis.

* FIN Modificación 24.02.2010

*ARVM 30102008.
          CLEAR v_banco.



          IF  zsociedad = 'CL01' OR zsociedad = 'CL12' OR zsociedad = 'CL24' OR
              zsociedad = 'CL35' OR zsociedad = 'CL51' OR zsociedad = 'CL17' OR
              zsociedad = 'CL13' OR zsociedad = 'CL06' OR zsociedad = 'CL02' OR
              zsociedad = 'CL52' OR zsociedad = 'CL05' OR zsociedad = 'CL50' OR
              zsociedad = 'CL57' OR zsociedad = 'CL54' OR zsociedad = 'CL27'.
              xciudad = 'SANTIAGO'.
          ELSE.
            IF zsociedad = 'CL39'.
               XCIUDAD = 'CONCEPCION'.
            ELSE.
              IF zsociedad = 'CL29' OR zsociedad = 'CL91'.
                XCIUDAD = 'VIÑA DEL MAR'.
              ELSE.
                xciudad = 'SANTIAGO'.
              ENDIF.
            ENDIF.
          ENDIF.



          IF t042z-xeinz EQ space.

*    Modificacion 17-01-2017 se acorta largo de 70 a 66 y omiten aster. iniciales
            CALL FUNCTION 'RKD_WORD_WRAP'
              EXPORTING
                textline  = escrito
                outputlen = 66
              IMPORTING
                out_line1 = linea1
                out_line2 = linea2.

            zmonto1   = '* * * * * * * * * * *'.

            ii = 0.
            zz = 0.
            primer = 'S'.
            DO 11 TIMES.

              IF regud-socra+ii(1) > 0 OR primer = 'N'  .
                zmonto1+zz(1) = regud-socra+ii(1).
                zz = zz + 2.
                primer = 'N'.
              ENDIF.
              ii = ii + 1.

            ENDDO.

            SELECT SINGLE butxt FROM t001
              INTO zsociedad WHERE bukrs = reguh-zbukr.

            SELECT SINGLE text1 FROM t012t
              INTO zbanco WHERE spras = sy-langu
                          AND   bukrs = reguh-zbukr
              AND   hbkid   =  reguh-hbkid
              AND hktid     =  reguh-hktid.

* Usa formulario alternativo a ZFORMCHE02 para evitar salto de cheques
            IF ncheques = 1 AND it_zconfchk-smartform = 'ZFORMCHE02'.
              it_zconfchk-smartform = 'ZFORMCHE12'.
            ENDIF.

            IF it_zconfchk-cantchk > 1 AND  par_vari+13(1) <> '1'.
              nchq = nchq + 1.
              IF nchq = 1.
                datos-zncheq1        = regud-chect.
                PERFORM f_form_fecha_new USING fechafcheq.
                datos-zfecha1 = fechafcheq.
                datos-zciudad1  = xciudad.
                datos-znombre1  = v_znm1s.
                datos-zmonto1   = zmonto1.
                datos-zmontxta1 = linea1.
                datos-zmontxtb1 = linea2.
                datos-zcolrut1 = reguh-stcd1.
                datos-zcolmotemi1 = v_desc_mot.
                datos-zcolmonto1 = regud-swnes.
                CONCATENATE  reguh-zaldt+06(2) '/' reguh-zaldt+4(2) '/' reguh-zaldt+0(4) INTO datos-zcolfecha1.
                datos-zcolagen1 = v_desc_agen.
                datos-zcolnomprov1 = v_znm1s+0(20).
                datos-zcolnombenef1 = v_znm1s+0(20).
                datos-zbanco = zbanco.
                datos-zmoneda = reguh-waers.
                datos-zsociedad = zsociedad.
              ENDIF.

              IF nchq = 2.
                datos-zncheq2   = regud-chect.
                PERFORM f_form_fecha_new USING fechafcheq.
                datos-zfecha2 = fechafcheq.
                datos-zciudad2  =  xciudad.
                datos-znombre2  = v_znm1s.
                datos-zmonto2   = zmonto1.
                datos-zmontxta2 = linea1.
                datos-zmontxtb2 = linea2.
                datos-zcolrut2  = reguh-stcd1.
                datos-zcolmotemi2 = v_desc_mot.
                datos-zcolmonto2 = regud-swnes.
                CONCATENATE  reguh-zaldt+06(2) '/' reguh-zaldt+4(2) '/' reguh-zaldt+0(4) INTO datos-zcolfecha2.
                datos-zcolagen2 = v_desc_agen.
                datos-zcolnomprov2 = v_znm1s+0(20).
                datos-zcolnombenef2 = v_znm1s+0(20).
                datos-zbanco = zbanco.
                datos-zmoneda = reguh-waers.
                datos-zsociedad = zsociedad.
              ENDIF.

              IF nchq = 3.
                datos-zncheq3   = regud-chect.
                PERFORM f_form_fecha_new USING fechafcheq.
                datos-zfecha3 = fechafcheq.
                datos-zciudad3  =  xciudad.
                datos-znombre3  = v_znm1s.
                datos-zmonto3   = zmonto1.
                datos-zmontxta3 = linea1.
                datos-zmontxtb3 = linea2.
                datos-zcolrut3  = reguh-stcd1.
                datos-zcolmotemi3 = v_desc_mot.
                datos-zcolmonto3 = regud-swnes.
                CONCATENATE  reguh-zaldt+06(2) '/' reguh-zaldt+4(2) '/' reguh-zaldt+0(4) INTO datos-zcolfecha3.
                datos-zcolagen3 = v_desc_agen.
                datos-zcolnomprov3 = v_znm1s+0(20).
                datos-zcolnombenef3 = v_znm1s+0(20).
                datos-zbanco = zbanco.
                datos-zmoneda = reguh-waers.
                datos-zsociedad = zsociedad.
              ENDIF.
              IF nchq = 4.
                datos-zncheq4   = regud-chect.
                PERFORM f_form_fecha_new USING fechafcheq.
                datos-zfecha4 = fechafcheq.
                datos-zciudad4  =  xciudad.
                datos-znombre4  = v_znm1s.
                datos-zmonto4   = zmonto1.
                datos-zmontxta4 = linea1.
                datos-zmontxtb4 = linea2.
                datos-zcolrut4  = reguh-stcd1.
                datos-zcolmotemi4 = v_desc_mot.
                datos-zcolmonto4 = regud-swnes.
                CONCATENATE  reguh-zaldt+06(2) '/' reguh-zaldt+4(2) '/' reguh-zaldt+0(4) INTO datos-zcolfecha4.
                datos-zcolagen4 = v_desc_agen.
                datos-zcolnomprov4 = v_znm1s+0(20).
                datos-zcolnombenef4 = v_znm1s+0(20).
                datos-zbanco = zbanco.
                datos-zmoneda = reguh-waers.
                datos-zsociedad = zsociedad.
              ENDIF.




              IF nchq = it_zconfchk-cantchk.
                zncorr = zncorr + 1.
                datos-zncorr = zncorr.
                APPEND datos.
                CLEAR datos.
                CLEAR nchq.
              ENDIF.
            ENDIF.


            IF it_zconfchk-cantchk = 1 OR   par_vari+13(1) = '1'.

              datos-zncheq1        = regud-chect.
              PERFORM f_form_fecha_new USING fechafcheq.
              datos-zfecha1 = fechafcheq.
              datos-zciudad1  =  xciudad.
              datos-znombre1  = v_znm1s.
              datos-zmonto1   = zmonto1.
              datos-zmontxta1 = linea1.
              datos-zmontxtb1 = linea2.
              datos-zcolrutprov1  =   reguh-stcd1.
              datos-zcolmotemi1 = v_desc_mot.
              datos-zcolmonto1 = regud-swnes.
              CONCATENATE  reguh-zaldt+06(2) '/' reguh-zaldt+4(2) '/' reguh-zaldt+0(4) INTO datos-zcolfecha1.
              datos-zcolagen1 = v_desc_agen.
              datos-zcolnomprov1 = v_znm1s+0(20).
              datos-zcolnombenef1 = v_znm1s+0(20).
              datos-zbanco = zbanco.
              datos-zmoneda = reguh-waers.
              datos-zsociedad = zsociedad.
              zncorr = zncorr + 1.
              datos-zncorr = zncorr.
              APPEND datos.
              CLEAR datos.
              IF it_zconfchk-cantlin > 0.
                PERFORM f_for_voucher_new.
              ENDIF.
            ENDIF.
          ENDIF.

        ENDIF.

*       Angabenteil fÃ¼r die OeNB-Meldung (Ã–sterreich)
*       Austria only
        IF t042e-xausl NE space        "Auslandsscheck, nicht PfÃ¤ndung
        AND NOT ( hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' ).
          CLEAR:
            regud-x08, regud-x10, regud-x11, regud-x12, regud-x13,
            regud-text1, regud-zwck1, regud-zwck2.
          IF up_oenb_kontowae-uwaer EQ 'ATS'.
            regud-x08   = 'X'.
          ELSE.
            regud-text1 = up_oenb_kontowae-uwaer.
          ENDIF.
          SORT up_oenb_angaben BY summe DESCENDING.
          READ TABLE up_oenb_angaben INDEX 1.
          CASE up_oenb_angaben-diekz.
            WHEN space.
              regud-x10 = 'X'.
            WHEN 'I'.
              regud-x10 = 'X'.
            WHEN 'R'.
              regud-x11 = 'X'.
            WHEN 'K'.
              regud-x12 = 'X'.
            WHEN OTHERS.
              regud-x13 = 'X'.
              PERFORM read_scb_indicator USING up_oenb_angaben-lzbkz.
              regud-zwck1 = t015l-zwck1.
              regud-zwck2 = t015l-zwck2.
          ENDCASE.


        ENDIF.

*       Formular beenden
*
        IF flg_schecknum EQ 1.
          cnt_seiten = 1.  "FÃ¼r vornumerierte Schecks
        ELSE.                          "For prenumbered checks
          cnt_seiten = 1.
        ENDIF.
        IF flg_schecknum NE 0 AND cnt_seiten GT 0.
          PERFORM scheckinfo_speichern USING 2.
        ENDIF.

      ENDIF.
    ENDAT.


*-- Ende der Hausbank --------------------------------------------------
*-- end of house bank --------------------------------------------------
    AT END OF reguh-ubnkl.

      IF cnt_formulare NE 0.           "FormularabschluÃŸ erforderlich


        IF it_zconfchk-cantchk > 1.
          IF nchq > 0.
            zncorr = zncorr + 1.
            datos-zncorr = zncorr.
            APPEND datos.
            CLEAR datos.
            CLEAR nchq.
          ENDIF.
        ENDIF.



        CLEAR flg_druckmodus.


        TABLES: nast,                          "Messages
                tnapr,                         "Programs & Forms
                addr_key.                      "Adressnumber for ADDRESS


        DATA: lf_fm_name            TYPE rs38l_fnam.
        DATA: ls_control_param      TYPE ssfctrlop.
        DATA: ls_composer_param     TYPE ssfcompop.
        DATA: ls_recipient          TYPE swotobjid.
        DATA: ls_sender             TYPE swotobjid.
        DATA: lf_formname           TYPE tdsfname.
        DATA: ls_addr_key           LIKE addr_key.

* Imprimir smart Form

        IF  par_vari+13(1) = '1'.
          CONCATENATE 'Cheques Individual'  sel_hbki-low   INTO titulo SEPARATED BY space.
          lf_formname = it_zconfchk-smartform_ind.
        ELSE.
          CONCATENATE 'Cheques'  sel_hbki-low   INTO titulo SEPARATED BY space.
          lf_formname = it_zconfchk-smartform.

        ENDIF.


        SELECT SINGLE * FROM zfipg003 WHERE bukrs = zw_zbukr-low.

        IF sy-subrc <> 0.
          CLEAR zfipg003.
        ENDIF.






        ls_composer_param-tdnewid = 'X'.
        ls_composer_param-tdimmed = ''.
        ls_composer_param-tddelete = 'X'.
        ls_composer_param-tdcovtitle = titulo.
        ls_composer_param-bcs_langu = sy-langu.

        ls_composer_param-tddest = par_priz.
        SELECT SINGLE * FROM tsp03
                 WHERE padest EQ par_priz.

        ls_composer_param-tdprinter = tsp03-patype.
        ls_control_param-no_dialog = 'X'.


        CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
          EXPORTING
            formname           = lf_formname
          IMPORTING
            fm_name            = lf_fm_name
          EXCEPTIONS
            no_form            = 1
            no_function_module = 2
            OTHERS             = 3.

        CALL FUNCTION lf_fm_name
          EXPORTING
            archive_index      = toa_dara
            archive_parameters = arc_params
            control_parameters = ls_control_param
            mail_recipient     = ls_recipient
            mail_sender        = ls_sender
            output_options     = ls_composer_param
            user_settings      = ''
            cantidad           = zncorr
            firma1             = zfipg003-nfirma1
            firma2             = zfipg003-nfirma2
          TABLES
            datos              = datos[]
            datosdet           = datos_det[]
          EXCEPTIONS
            formatting_error   = 1
            internal_error     = 2
            send_error         = 3
            user_canceled      = 4
            OTHERS             = 5.
      ENDIF.
    ENDAT.
  ENDLOOP.


ENDFORM.                               "Scheck

*&---------------------------------------------------------------------*
*&      Form  f_for_voucher_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_for_voucher_new.

  DATA : nlineas(3) TYPE n.
  DATA : total(14) TYPE p DECIMALS 2.
  DATA : descacum(100) TYPE c.
  nlineas = 1.
  total = 0.
  descacum = ''.

SELECT * FROM regup WHERE laufd = reguh-laufd
AND laufi = reguh-laufi
AND xvorl = ''
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*AND vblnr = reguh-vblnr.
AND VBLNR = REGUH-VBLNR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *

    IF nlineas <  it_zconfchk-cantlin.
      datos_det-zdv_fec_docum =  regup-bldat.
      datos_det-zdv_num_fact = regup-xblnr.
      datos_det-zdv_descrip = regup-sgtxt.
      datos_det-zdv_tip_fact = regup-blart.
      WRITE  regup-dmbtr TO datos_det-zdv_mon_fact CURRENCY 'CLP'.
      datos_det-zdv_num_cheq = regud-chect.
      APPEND datos_det.
      nlineas = nlineas + 1.
    ELSE.
      total  = total + regup-dmbtr.
      descacum = descacum + regup-xblnr + ' '.
    ENDIF.

  ENDSELECT.

  IF total > 0.
    datos_det-zdv_fec_docum = ''.
    datos_det-zdv_num_fact = '+ resto detalle'.
    datos_det-zdv_descrip = descacum.
    datos_det-zdv_tip_fact = ''.
    datos_det-zdv_mon_fact = total.
    datos_det-zdv_num_cheq = regud-chect.
    APPEND datos_det.
  ENDIF.




ENDFORM.                    " f_for_voucher


*&---------------------------------------------------------------------*
*&      Form  f_for_voucher_new
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_form_fecha_new USING p_string.

  CLEAR p_string.

  IF it_zconfchk-laser EQ space.

    p_string+2(1)   = reguh-zaldt+6(1).
    p_string+5(1)   = reguh-zaldt+7(1).

    p_string+10(1)   = reguh-zaldt+4(1).
    p_string+13(1)   = reguh-zaldt+5(1).

    IF it_zconfchk-fmtoanno EQ 4.
      p_string+18(1)   = reguh-zaldt+0(1).
      p_string+21(1)   = reguh-zaldt+1(1).
    ENDIF.
    p_string+24(1)   = reguh-zaldt+2(1).
    p_string+27(1)   = reguh-zaldt+3(1).

  ELSE.
    p_string+1(1)   = reguh-zaldt+6(1).
    p_string+6(1)   = reguh-zaldt+7(1).

    p_string+12(1)   = reguh-zaldt+4(1).
    p_string+17(1)   = reguh-zaldt+5(1).

    IF it_zconfchk-fmtoanno EQ 4.
      p_string+23(1)   = reguh-zaldt+0(1).
      p_string+28(1)   = reguh-zaldt+1(1).
    ENDIF.
    p_string+33(1)   = reguh-zaldt+2(1).
    p_string+38(1)   = reguh-zaldt+3(1).

  ENDIF.

ENDFORM.                    " f_form_fecha_new
*&---------------------------------------------------------------------*
*&      Form  scheck
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM scheck.

*----------------------------------------------------------------------*
* Abarbeiten der extrahierten Daten                                    *
* loop at extracted data                                               *
*----------------------------------------------------------------------*
  IF flg_sort NE 2.
    SORT BY avis.
    flg_sort = 2.
  ENDIF.

  hlp_ep_element = '525'.

  LOOP.

*-- Neuer zahlender Buchungskreis --------------------------------------
*-- new paying company code --------------------------------------------
    AT NEW reguh-zbukr.
      PERFORM buchungskreis_daten_lesen.                  .
    ENDAT.

*-- Neuer Zahlweg ------------------------------------------------------
*-- new payment method -------------------------------------------------
    AT NEW reguh-rzawe.

      flg_probedruck = 0.              "fÃ¼r diesen Zahlweg wurde noch
      "kein Probedruck durchgefÃ¼hrt
      "test print for this payment
      "method not yet done
      PERFORM zahlweg_daten_lesen.

*     Spoolparameter zur Ausgabe des Schecks angeben
*     specify spool parameters for check print
      PERFORM fill_itcpo USING par_priz
                               t042z-zlstn
                               space   "par_sofz via tab_ausgabe!
                               hlp_auth.
      IF NOT titulo IS INITIAL.
        itcpo-tdcovtitle = titulo.
      ENDIF.
      IF flg_schecknum NE 0.
        itcpo-tddelete  = 'X'.         "delete after print
      ENDIF.
      EXPORT itcpo TO MEMORY ID 'RFFORI01_ITCPO'.

*************** Descripcion banco ************************************

      DATA :p_bankl TYPE t012-bankl.

      SELECT SINGLE bankl
           FROM  t012
           INTO  p_bankl
          WHERE  bukrs EQ reguh-zbukr
            AND  hbkid EQ reguh-hbkid.

      IF sy-subrc EQ 0.
        SELECT SINGLE banka
             FROM  bnka
             INTO  reguh-name4
            WHERE  banks EQ reguh-land1
              AND  bankl EQ p_bankl.
      ENDIF.
      CLEAR v_nomban.
      v_nomban = reguh-name4.

**********************************************************************
      CALL FUNCTION 'OPEN_FORM'
        EXPORTING
          archive_index  = toa_dara
          archive_params = arc_params
          form           = t042e-zforn
          device         = 'PRINTER'
          language       = t001-spras
          OPTIONS        = itcpo
          dialog         = flg_dialog
        IMPORTING
          RESULT         = itcpp
        EXCEPTIONS
          form           = 1.
      IF sy-subrc EQ 1.              "abend:
        IF sy-batch EQ space.        "form is not active
          MESSAGE a069 WITH t042e-zforn.
        ELSE.
          MESSAGE s069 WITH t042e-zforn.
          MESSAGE s094.
          STOP.
        ENDIF.
      ENDIF.

*     Formular auf Segmenttext (Global &REGUP-SGTXT) untersuchen
*     examine whether segment text is to be printed
      IF t042e-xavis NE space AND t042e-anzpo NE 99.
        flg_sgtxt = 0.
        CALL FUNCTION 'READ_FORM_LINES'
          EXPORTING
            element = hlp_ep_element
          TABLES
            lines   = tab_element
          EXCEPTIONS
            element = 1.
        IF sy-subrc EQ 0.
          LOOP AT tab_element.
            IF    tab_element-tdline   CS 'REGUP-SGTXT'
              AND tab_element-tdformat NE '/*'.
              flg_sgtxt = 1.           "Global fÃ¼r Segmenttext existiert
              EXIT.                    "global for segment text exists
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

*     Scheck auf WÃ¤hrungsschlÃ¼ssel (Global &REGUD-WAERS&) und Maximal-
*     betrag fÃ¼r die Umsetzung der Ziffern in Worten untersuchen
*     currency code &REGUD-WAERS& has to exist in window CHECK for
*     foreign currency checks, compute maximal amount 'in words'
      flg_fw_scheck = 0.
      IF t042z-xeinz EQ space.
        hlp_element = '545'.
      ELSE.
        hlp_element = '546'.
      ENDIF.
      CALL FUNCTION 'READ_FORM_LINES'
        EXPORTING
          window  = 'CHECK'
          element = hlp_element
        TABLES
          lines   = tab_element
        EXCEPTIONS
          element = 2.
      CALL FUNCTION 'READ_FORM_LINES'
        EXPORTING
          window  = 'CHECKSPL'
          element = hlp_element
        TABLES
          lines   = tab_element2
        EXCEPTIONS
          element = 2.
      APPEND LINES OF tab_element2 TO tab_element.

      hlp_maxstellen = 0.              "der Maximalbetrag wird nur
      hlp_maxbetrag  = 10000000000000. "berechnet, wenn die Globals
      "SPELL-DIGnn verwendet wurden
      IF sy-tabix NE 0.                "max. amount only computed if
        LOOP AT tab_element.           "globals SPELL-DIGnn are used
          IF tab_element-tdformat NE '/*'.
*           WÃ¤hrungsschlÃ¼ssel
*           currency code
            IF tab_element-tdline CP '*REGU+-WAERS*'.
              flg_fw_scheck = 1.
            ENDIF.
*           Maximal umsetzbare Stellen ermitteln
*           find out maximal number of places which can be transformed
            WHILE tab_element-tdline CS '&SPELL-DIG'.
              SHIFT tab_element-tdline BY sy-fdpos PLACES.
              SHIFT tab_element-tdline BY 10 PLACES.
              IF tab_element-tdline(2) CO '0123456789'.
                IF hlp_maxstellen LT tab_element-tdline(2). "#EC PORTABLE
                  hlp_maxstellen = tab_element-tdline(2).
                ENDIF.
              ENDIF.
            ENDWHILE.
          ENDIF.
        ENDLOOP.
*       Maximalbetrag ermitteln
*       compute maximal amount for transformation 'in words'
        IF hlp_maxstellen NE 0.
          hlp_maxbetrag = 1.
          DO hlp_maxstellen TIMES.
            hlp_maxbetrag = hlp_maxbetrag * 10.
          ENDDO.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'CLOSE_FORM'.

    ENDAT.


*-- Neue Hausbank ------------------------------------------------------
*-- new house bank -----------------------------------------------------
    AT NEW reguh-ubnkl.

      PERFORM hausbank_daten_lesen.

*     Felder fÃ¼r FormularabschluÃŸ initialisieren
*     initialize fields for summary
      cnt_formulare = 0.
      cnt_hinweise  = 0.
      sum_abschluss = 0.

      flg_druckmodus = 0.
*     Vornumerierte Schecks: erste Schecknummer ermitteln
*     prenumbered checks: find out first check number
      IF flg_schecknum NE 0.
        PERFORM schecknummer_ermitteln USING 1.
      ENDIF.

    ENDAT.


*-- Neue Kontonummer bei der Hausbank ----------------------------------
*-- new account number with house bank ---------------------------------
    AT NEW reguh-ubknt.

*     Kontonummer ohne Aufbereitungszeichen fÃ¼r OCRA-Zeile speichern
*     store numerical account number for code line
      regud-obknt = reguh-ubknt.

    ENDAT.


*-- Neue EmpfÃ¤ngerbank -------------------------------------------------
*-- new bank of payee --------------------------------------------------
    AT NEW reguh-zbnkl.
      CLEAR reguh1.
      CLEAR regud1.
      CLEAR spell1.
      REFRESH spell1.
      REFRESH reguh1.
      REFRESH regud1.

      PERFORM empfbank_daten_lesen.

    ENDAT.


*-- Neue Zahlungsbelegnummer -------------------------------------------
*-- new payment document number ----------------------------------------
    AT NEW reguh-vblnr.

*     Angabentabelle und KontowÃ¤hrung fÃ¼r die OeNB-Meldung (Ã–sterreich)
*     Austria only
      IF t042e-xausl EQ 'X' AND        "nur Auslandsscheck
        hlp_laufk NE 'P'.              "kein HR
        REFRESH up_oenb_angaben.
        CLEAR up_oenb_kontowae.
        READ TABLE up_oenb_kontowae WITH KEY reguh-ubhkt.
        IF sy-subrc NE 0.
          PERFORM hausbank_konto_lesen.
          up_oenb_kontowae-ubhkt = reguh-ubhkt.
          PERFORM isocode_umsetzen
            USING t012k-waers up_oenb_kontowae-uwaer.
          APPEND up_oenb_kontowae.
        ENDIF.
      ENDIF.

*     Lesen der Referenzangaben (Schweiz)
*     Switzerland only
      PERFORM hausbank_konto_lesen.

*     Kein Druck falls FremdwÃ¤hrung, aber kein FremdwÃ¤hrungsscheck
*     no print if foreign currency, but global &REGUD-WAERS& is missing
      flg_kein_druck = 0.
      IF reguh-waers NE t001-waers AND flg_fw_scheck EQ 0.
        err_fw_scheck-fname = t042e-zforn.
        MOVE-CORRESPONDING reguh TO err_fw_scheck.
        COLLECT err_fw_scheck.
        flg_kein_druck = 1.            "kein Druck mÃ¶glich
      ENDIF.                           "no print

      IF flg_kein_druck EQ 0.

        PERFORM zahlungs_daten_lesen.

*       Tag der Zahlung in Worten (Spanien)
*       day of payment in words (Spain)
        CLEAR t015z.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
        SELECT SINGLE * FROM t015z
          WHERE spras EQ hlp_sprache
            AND einh  EQ reguh-zaldt+6(1)
            AND ziff  EQ reguh-zaldt+7(1).
        IF sy-subrc EQ 0.
          regud-text2 = t015z-wort.
          TRANSLATE regud-text2 TO LOWER CASE.           "#EC TRANSLANG
          TRANSLATE regud-text2 USING '; '.
        ELSE.
          CLEAR err_t015z.
          err_t015z-spras = hlp_sprache.
          err_t015z-einh  = reguh-zaldt+6(1).
          err_t015z-ziff  = reguh-zaldt+7(1).
          COLLECT err_t015z.
        ENDIF.

*       Elementname fÃ¼r die Einzelposteninformation ermitteln
*       determine element name for item list
        IF hlp_laufk EQ 'P' OR
           hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN'.
          hlp_ep_element = '525-HR'.
        ELSE.
          hlp_ep_element = '525'.
        ENDIF.

*       Name des Fensters mit dem Anschreiben zusammensetzen
*       specify name of the window with the check text
        hlp_element   = '510-'.
        hlp_element+4 = reguh-rzawe.
        hlp_eletext   = text_510.
        REPLACE '&ZAHLWEG' WITH reguh-rzawe INTO hlp_eletext.

*       Druckvorgaben modifizieren lassen
*       modification of print parameters
        IMPORT itcpo FROM MEMORY ID 'RFFORI01_ITCPO'.
        PERFORM modify_itcpo.

*       open form only at first time or when optical archiving is active
        IF flg_druckmodus NE 1 OR itcpo-tdarmod NE '1'.
*         Scheckformular Ã¶ffnen
*         open check form
          IF cnt_formulare EQ 0.
            itcpo-tdnewid = 'X'.
          ELSE.
            itcpo-tdnewid = space.
          ENDIF.
          IF par_priz EQ space.
            flg_dialog = 'X'.
          ELSE.
            flg_dialog = space.
          ENDIF.

*         close last form
          IF flg_druckmodus NE 0.
            CALL FUNCTION 'CLOSE_FORM'
              IMPORTING
                RESULT = itcpp.

            IF itcpp-tdspoolid NE 0.
              CLEAR tab_ausgabe.
              tab_ausgabe-name    = t042z-text1.
              tab_ausgabe-dataset = itcpp-tddataset.
              tab_ausgabe-spoolnr = itcpp-tdspoolid.
              tab_ausgabe-immed   = par_sofz.
              COLLECT tab_ausgabe.
            ENDIF.
          ENDIF.


          flg_druckmodus = itcpo-tdarmod.

          CALL FUNCTION 'OPEN_FORM'
            EXPORTING
              archive_index  = toa_dara
              archive_params = arc_params
              form           = t042e-zforn
              device         = 'PRINTER'
              language       = t001-spras
              OPTIONS        = itcpo
              dialog         = flg_dialog
            IMPORTING
              RESULT         = itcpp
            EXCEPTIONS
              form           = 1.
          IF sy-subrc EQ 1.              "abend:
            IF sy-batch EQ space.        "form is not active
              MESSAGE a069 WITH t042e-zforn.
            ELSE.
              MESSAGE s069 WITH t042e-zforn.
              MESSAGE s094.
              STOP.
            ENDIF.
          ENDIF.


          par_priz = itcpp-tddest.
          PERFORM fill_itcpo_from_itcpp.
          EXPORT itcpo TO MEMORY ID 'RFFORI01_ITCPO'.
        ENDIF. "flg_druckmodus NE 1 OR itcpo-tdarmod NE '1'

*       Probedruck
*       test print
        IF flg_probedruck EQ 0.        "Probedruck noch nicht erledigt
          PERFORM daten_sichern.       "test print not yet done
          IF flg_schecknum EQ 2.
            regud-chect = xxx_regud-chect.
            regud-checf = xxx_regud-checf.
          ENDIF.
          cnt_seiten = 0.
          DO par_anzp TIMES.
*           Vornumerierte Schecks: Schecknummer hochzÃ¤hlen ab 2.Seite
*           prenumbered checks: add 1 to check number
            IF flg_schecknum EQ 1 AND sy-index GT 1.
              hlp_page = sy-index.
              PERFORM schecknummer_addieren.
            ENDIF.
*           Probedruck-Formular starten
*           start test print form
            CALL FUNCTION 'START_FORM'
              EXPORTING
                language = hlp_sprache.
*           Fenster mit Probedruck schreiben
*           write windows with test print
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window   = 'INFO'
                element  = '505'
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
*            CALL FUNCTION 'WRITE_FORM'
*              EXPORTING
*                window  = 'CHECK'
*                element = '540'
*              EXCEPTIONS
*                window  = 1
*                element = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = hlp_element
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc NE 0.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  element = '510'
                EXCEPTIONS
                  window  = 1
                  element = 2.
            ENDIF.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '514'
              EXCEPTIONS
                window  = 1
                element = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '515'
              EXCEPTIONS
                window  = 1
                element = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = hlp_ep_element
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
*            CALL FUNCTION 'WRITE_FORM'
*              EXPORTING
*                ELEMENT  = '530'
*                FUNCTION = 'APPEND'
*              EXCEPTIONS
*                WINDOW   = 1
*                ELEMENT  = 2.
*            CALL FUNCTION 'WRITE_FORM'
*              EXPORTING
*                WINDOW  = 'TOTAL'
*                ELEMENT = '530'
*              EXCEPTIONS
*                WINDOW  = 1
*                ELEMENT = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window   = 'INFO'
                element  = '505'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1
                element  = 2.
*           Probedruck-Formular beenden
*           End test print
            CALL FUNCTION 'END_FORM'
              IMPORTING
                RESULT = itcpp.
            IF itcpp-tdpages EQ 0.     "Print via RDI
              itcpp-tdpages = 1.
            ENDIF.
            ADD itcpp-tdpages TO cnt_seiten.
          ENDDO.
          IF flg_schecknum EQ 1 AND cnt_seiten GT 0.
            PERFORM scheckinfo_speichern USING 1.
          ENDIF.
          PERFORM daten_zurueck.
          flg_probedruck = 1.          "Probedruck erledigt
        ENDIF.                         "Test print done

        PERFORM summenfelder_initialisieren.

*       PrÃ¼fe, ob HR-Formular zu verwenden ist
*       Check if HR-form is to be used
        IF ( hlp_laufk EQ 'P' OR
             hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' )
         AND hrxblnr-xhrfo NE space.
          hlp_xhrfo = 'X'.
        ELSE.
          hlp_xhrfo = space.
        ENDIF.

*       Formular starten
*       start check form
        CALL FUNCTION 'START_FORM'
          EXPORTING
            archive_index = toa_dara
            language      = hlp_sprache.

*       Vornumerierte Schecks: nÃ¤chste Schecknummer ermitteln
*       prenumbered checks: compute next check number
        IF flg_schecknum NE 0.
          PERFORM schecknummer_ermitteln USING 2.
        ENDIF.

*       Fenster Check, Element Entwerteter Scheck
*       window check, element voided check
*        CALL FUNCTION 'WRITE_FORM'
*          EXPORTING
*            window  = 'CHECK'
*            element = '540'
*          EXCEPTIONS
*            window  = 1
*            element = 2.
        IF sy-subrc EQ 2.
          err_element-fname = t042e-zforn.
          err_element-fenst = 'CHECK'.
          err_element-elemt = '540'.
          err_element-text  = text_540.
          COLLECT err_element.
        ENDIF.

        IF hlp_xhrfo EQ space.

*         Fenster Info, Element Unsere Nummer (falls diese gefÃ¼llt ist)
*         window info, element our number (if filled)
          IF reguh-eikto NE space.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window   = 'INFO'
                element  = '505'
                function = 'APPEND'
              EXCEPTIONS
                window   = 1
                element  = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'INFO'.
              err_element-elemt = '505'.
              err_element-text  = text_505.
              COLLECT err_element.
            ENDIF.
          ENDIF.

*         Fenster Carry Forward, Element Ãœbertrag (auÃŸer letzte Seite)
*         window carryfwd, element carry forward below (not last page)
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              window  = 'CARRYFWD'
              element = '535'
            EXCEPTIONS
              window  = 1
              element = 2.
          IF sy-subrc EQ 2.
            err_element-fname = t042e-zforn.
            err_element-fenst = 'CARRYFWD'.
            err_element-elemt = '535'.
            err_element-text  = text_535.
            COLLECT err_element.
          ENDIF.

*         Hauptfenster, Element Anschreiben (nur auf der ersten Seite)
*         main window, element check text (only on first page)
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = hlp_element
            EXCEPTIONS
              window  = 1
              element = 2.
          IF sy-subrc EQ 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '510'
              EXCEPTIONS
                window  = 1
                element = 2.
            err_element-fname = t042e-zforn.
            err_element-fenst = 'MAIN'.
            err_element-elemt = hlp_element.
            err_element-text  = hlp_eletext.
            COLLECT err_element.
          ENDIF.

*         Hauptfenster, Element Zahlung erfolgt im Auftrag von
*         main window, element payment by order of
          IF reguh-absbu NE reguh-zbukr.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '513'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'MAIN'.
              err_element-elemt = '513'.
              err_element-text  = text_513.
              COLLECT err_element.
            ENDIF.
          ENDIF.

*         Hauptfenster, Element Abweichender ZahlungsemfÃ¤nger
*         main window, element different payee
          IF regud-xabwz EQ 'X'.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '512'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'MAIN'.
              err_element-elemt = '512'.
              err_element-text  = text_512.
              COLLECT err_element.
            ENDIF.
          ENDIF.

*         Hauptfenster, Element GruÃŸ und Unterschrift
*         main window, element regards and signature
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = '514'
            EXCEPTIONS
              window  = 1
              element = 2.

*         Hauptfenster, Element Ãœberschrift (nur auf der ersten Seite)
*         main window, element title (only on first page)
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = '515'
            EXCEPTIONS
              window  = 1
              element = 2.
          IF sy-subrc EQ 2.
            err_element-fname = t042e-zforn.
            err_element-fenst = 'MAIN'.
            err_element-elemt = '515'.
            err_element-text  = text_515.
            COLLECT err_element.
          ENDIF.

*         Hauptfenster, Element Ãœberschrift (ab der zweiten Seite oben)
*         main window, element title (2nd and following pages)
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = '515'
              type    = 'TOP'
            EXCEPTIONS
              window  = 1        "Fehler bereits oben gemerkt
              element = 2.       "error already noted

*         Hauptfenster, Element Ãœbertrag (ab der zweiten Seite oben)
*         main window, element carry forward above (2nd and following p)
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element  = '520'
              type     = 'TOP'
              function = 'APPEND'
            EXCEPTIONS
              window   = 1
              element  = 2.
          IF sy-subrc EQ 2.
            err_element-fname = t042e-zforn.
            err_element-fenst = 'MAIN'.
            err_element-elemt = '520'.
            err_element-text  = text_520.
            COLLECT err_element.
          ENDIF.

        ELSE.

          PERFORM hr_formular_lesen.

        ENDIF.

*       PrÃ¼fung, ob Avishinweis erforderlich
*       check if advice note is necessary
        cnt_zeilen = 0.
        IF t042e-xavis NE space AND t042e-anzpo NE 99.
          IF hlp_xhrfo EQ space.
            IF flg_sgtxt = 1.
              cnt_zeilen = reguh-rpost + reguh-rtext.
            ELSE.
              cnt_zeilen = reguh-rpost.
            ENDIF.
          ELSE.
            DESCRIBE TABLE pform LINES cnt_zeilen.
          ENDIF.
          IF cnt_zeilen GT t042e-anzpo.
            IF hlp_xhrfo EQ space.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  element  = '526'
                  function = 'APPEND'
                EXCEPTIONS
                  window   = 1
                  element  = 2.
              IF sy-subrc EQ 2.
                err_element-fname = t042e-zforn.
                err_element-fenst = 'MAIN'.
                err_element-elemt = '526'.
                err_element-text  = text_526.
                COLLECT err_element.
              ENDIF.
            ENDIF.
            ADD 1 TO cnt_hinweise.
          ENDIF.
        ENDIF.

*       HR-Formular ausgeben
*       write HR form
        IF hlp_xhrfo NE space.
          LOOP AT pform.
            IF cnt_zeilen GT t042e-anzpo AND sy-tabix GT t042e-anzpo.
              EXIT.
            ENDIF.
            regud-txthr = pform-linda.
            PERFORM scheckavis_zeile.
          ENDLOOP.
        ENDIF.
        flg_diff_bukrs = 0.

      ENDIF.

    ENDAT.

*-- Neuer Rechnungsbuchungskreis ---------------------------------------
*-- New invoice company code -------------------------------------------
    AT NEW regup-bukrs.

      IF cnt_zeilen LE t042e-anzpo AND hlp_xhrfo EQ space.
        IF ( regup-bukrs NE reguh-zbukr OR flg_diff_bukrs EQ 1 ) AND
           ( reguh-absbu EQ space OR reguh-absbu EQ reguh-zbukr ).
          flg_diff_bukrs = 1.
          SELECT SINGLE * FROM t001 INTO *t001
            WHERE bukrs EQ regup-bukrs.
          regud-abstx = *t001-butxt.
          regud-absor = *t001-ort01.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = '513'
            EXCEPTIONS
              window  = 1
              element = 2.
          IF sy-subrc EQ 2.
            err_element-fname = t042e-zforn.
            err_element-fenst = 'MAIN'.
            err_element-elemt = '513'.
            err_element-text  = text_513.
            COLLECT err_element.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDAT.


*******************************************************************
*LSS AMVC 29-OCT- 2009
    SELECT SINGLE sgtxt INTO t_bseg-sgtxt
            FROM  bsak
           WHERE  bukrs  EQ regup-bukrs
             AND  lifnr  EQ regup-lifnr
             AND  gjahr  EQ regup-gjahr
             AND  belnr  EQ regup-belnr
             AND  buzei  EQ regup-buzei.
****************************************************
*-- Verarbeitung der Einzelposten-Informationen ------------------------
*-- single item information --------------------------------------------
    AT daten.
      IF t042e-zforn(13) EQ 'ZFO_FI001_AVI' OR t042e-zforn(13) EQ 'ZFO_BSEC_01'  OR t042e-zforn(13) EQ it_zconfchk-formulario.
        PERFORM f_for_voucher.
      ELSEIF t042e-zforn(13) EQ 'ZFO_FI001_CHQ' .
        PERFORM f_for_cheque.
      ENDIF.
    ENDAT.


*-- Ende der Zahlungsbelegnummer ---------------------------------------
*-- end of payment document number -------------------------------------
    AT END OF reguh-vblnr.

      IF flg_kein_druck EQ 0.

*       Zahlbetrag ohne Aufbereitungszeichen fÃ¼r Codierzeile speichern
*       store numerical payment amount for code line
        IF reguh-waers EQ t001-waers.
          regud-socra = regud-swnes.
        ELSE.
          regud-socra = 0.
          PERFORM laender_lesen USING t001-land1.
          IF t005-intca EQ 'DE'.
            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
            IF hlp_waers EQ 'DEM' OR hlp_waers EQ 'EUR'.
              regud-socra = regud-swnes.
            ENDIF.
          ENDIF.
          IF t005-intca EQ 'AT'.
            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
            IF hlp_waers EQ 'ATS' OR hlp_waers EQ 'EUR'.
              regud-socra = regud-swnes.
            ENDIF.
          ENDIF.
        ENDIF.
        IF reguh-waers EQ t012k-waers.
          regud-socrb = regud-swnes.
        ELSE.
          regud-socrb = 0.
        ENDIF.

        PERFORM ziffern_in_worten.

*       Summenfelder hochzÃ¤hlen und aufbereiten
*       add up total amount fields
        ADD 1            TO cnt_formulare.
        ADD reguh-rbetr  TO sum_abschluss.
        WRITE:
          cnt_hinweise   TO regud-avish,
          cnt_formulare  TO regud-zahlt,
          sum_abschluss  TO regud-summe CURRENCY t001-waers.
        TRANSLATE:
          regud-avish USING ' *',
          regud-zahlt USING ' *',
          regud-summe USING ' *'.

        IF hlp_xhrfo EQ space.

* Nur fÃ¼r Brasilien (Check auf Land liegt in Funktionsbaustein)
* Only Brazil (Check on country within the function module)

          CALL FUNCTION 'BOLETO_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.

          CALL FUNCTION 'KOREA_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.


*         Hauptfenster, Element Gesamtsumme (nur auf der letzten Seite)
*         main window, element total (only last page)
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              ELEMENT  = '530'
*              FUNCTION = 'APPEND'
*            EXCEPTIONS
*              WINDOW   = 1
*              ELEMENT  = 2.
          IF t042e-zforn EQ 'ZFO_FI001_AVISO' OR t042e-zforn(13) EQ 'ZFO_FI001_AVI' OR t042e-zforn(13) EQ 'ZFO_BSEC_01' OR t042e-zforn(13) EQ it_zconfchk-formulario.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'MAIN'.
              err_element-elemt = '530'.
              err_element-text  = text_530.
              COLLECT err_element.
            ENDIF.
          ENDIF.

*         Vornumerierte Schecks: Schecknummer hochzÃ¤hlen ab 2.Seite
*         prenumbered checks: add 1 to check number
          IF t042e-zforn EQ 'ZFO_FI001_AVISO' OR t042e-zforn(13) EQ 'ZFO_FI001_AVI' OR t042e-zforn(13) EQ 'ZFO_BSEC_01' OR t042e-zforn(13) EQ it_zconfchk-formulario.
            IF flg_schecknum EQ 1.
              CALL FUNCTION 'GET_TEXTSYMBOL'
                EXPORTING
                  line         = '&PAGE&'
                  start_offset = 0
                IMPORTING
                  value        = hlp_page.
              IF hlp_page NE hlp_seite.
                hlp_seite = hlp_page.
                PERFORM schecknummer_addieren.
              ENDIF.
            ENDIF.
          ENDIF.

*         Alternativ: Fenster Total, Element Gesamtsumme
*         alternatively: window total, element total
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              WINDOW  = 'TOTAL'
*              ELEMENT = '530'
*            EXCEPTIONS
*              WINDOW  = 1
*              ELEMENT = 2.
          IF t042e-zforn EQ 'ZFO_FI001_AVISO' OR t042e-zforn(13) EQ 'ZFO_FI001_AVI' OR t042e-zforn(13) EQ 'ZFO_BSEC_01' OR t042e-zforn(13) EQ it_zconfchk-formulario.
            IF sy-subrc EQ 2 AND
              (  err_element-fname NE t042e-zforn
              OR err_element-fenst NE 'MAIN'
              OR err_element-elemt NE '530' ).
              err_element-fname = t042e-zforn.
              err_element-fenst = 'TOTAL'.
              err_element-elemt = '530'.
              err_element-text  = text_530.
              COLLECT err_element.
            ENDIF.
          ENDIF.

*         Fenster Carry Forward, Element Ãœbertrag lÃ¶schen
*         window carryfwd, delete element carry forward below
          IF t042e-zforn EQ 'ZFO_FI001_AVISO' OR t042e-zforn(13) EQ 'ZFO_FI001_AVI' OR t042e-zforn(13) EQ 'ZFO_BSEC_01' OR t042e-zforn(13) EQ it_zconfchk-formulario.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window   = 'CARRYFWD'
                element  = '535'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1       "Fehler bereits oben gemerkt
                element  = 2.      "error already noted

*         Hauptfenster, Element Ãœberschrift lÃ¶schen
*         main window, delete element title
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = '515'
                type     = 'TOP'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1       "Fehler bereits oben gemerkt
                element  = 2.      "error already noted

*         Hauptfenster, Element Ãœbertrag lÃ¶schen
*         main window, delete element carry forward above
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element  = '520'
                type     = 'TOP'
                function = 'DELETE'
              EXCEPTIONS
                window   = 1       "Fehler bereits oben gemerkt
                element  = 2.      "error already noted

          ENDIF.
        ENDIF.
*       Fenster Check, Element Entwerteter Scheck lÃ¶schen
*       window check, delete element voided check
        IF reguh-rwbtr NE 0.           "zero net check has to be voided
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              window   = 'CHECK'
*              element  = '540'
*              function = 'DELETE'
*            EXCEPTIONS
*              window   = 1       "Fehler bereits oben gemerkt
*              element  = 2.      "error already noted

*         Fenster Check, Element Echter Scheck (nur auf letzte Seite)
*         window check, element genuine check (only last page)


*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
*Imprime última línea de detalle acumulada.
          IF v_acumula EQ 'X'  .
            v_xblnr = regup-xblnr.

            regup-xblnr = space.
            t_bseg-hkont = regup-hkont.
            t_bseg-stcd1 = reguh-zstc1.
            CLEAR reguh-rbetr.
            t_bseg-zfbdt = regup-zfbdt.


            WRITE v_totlin TO   t_bseg-debe CURRENCY regud-waers.

*            CALL FUNCTION 'WRITE_FORM'
*              EXPORTING
*                element  = hlp_ep_element
*                function = 'APPEND'
*              EXCEPTIONS
*                window   = 1
*                element  = 2.
*
*            CALL FUNCTION 'WRITE_FORM'
*              EXPORTING
*                element  = '525-TX'
*                function = 'APPEND'
*              EXCEPTIONS
*                window   = 1
*                element  = 2.

            regup-xblnr = v_xblnr.

*----------------------------------------------------------
*            DATA y TYPE i.
*
*            DO.
*              IF y = 1.
*                EXIT.
*              ENDIF.
*            ENDDO.

*----------------------------------------------------------
*Imprime documentos acumulados. Máximo 2 líneas agrupadas.
            IF v_group = 'X'.
              v_largo = STRLEN( v_doctos ).
              IF v_largo > 1.
                v_largo = v_largo - 1.
                v_doctos = v_doctos+0(v_largo).
                CALL FUNCTION 'WRITE_FORM'
                  EXPORTING
                    element  = '777'
                    function = 'APPEND'
                  EXCEPTIONS
                    window   = 1
                    element  = 2.
              ENDIF.
              CLEAR: v_group, v_doctos, v_largo, v_cont.
            ENDIF.
          ENDIF.
*----------------------------------------------------------------------
**Alvaro Vergara Madrid Alynea MVC Amercias
*Monto Total y Descripción del Monto Total.
*Monto en Texto.. Control de Despliegue para pagos Masivos.
          DATA v_amount.

*V_AMOUNT = REGUH-RWBTR.

*DATA: v_reguh LIKE reguh-rwbtr.

          IF v_acumula = 'X'.
*v_reguh = reguh-rwbtr.
*reguh-rwbtr = v_totlin.
            CLEAR: v_totlin, v_acumula.
          ENDIF.

          CALL FUNCTION 'SPELL_AMOUNT'
           EXPORTING
             amount          = reguh-rwbtr
             currency        = 'CLP'
*   FILLER          = ' '
             language        = sy-langu
           IMPORTING
             in_words        = spell
           EXCEPTIONS
             not_found       = 1
             too_large       = 2
             OTHERS          = 3.

          TRANSLATE spell-word TO UPPER CASE.

*ARVM 30102008.
*Imprimimos el Total solo una vez.
          t_bseg-debe  = v_debe.
          t_bseg-haber = v_haber.
          IF t042e-zforn EQ 'ZFO_FI001_AVISO' OR t042e-zforn(13) EQ 'ZFO_FI001_AVI' OR t042e-zforn(13) EQ 'ZFO_BSEC_01' OR t042e-zforn(13) EQ it_zconfchk-formulario.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                element = '555'
              EXCEPTIONS
                window  = 1
                element = 2.
          ENDIF.
*Dejamos Siempre en mayuscula el nombre.

          CLEAR: v_znm1s.

********** Cambio para contatenar nombres en la variable de salida.
********** Cristian Infante 29/01/2010.
*          v_znm1s = regud-znm1s.
*          translate v_znm1s to upper case.
*          regud-znm1s = v_znm1s.

* Modificación 23.02.2010
* Se revisa que no exista el nombre 2, de lo contrario se omiten '*' del primer nombre.
          IF NOT regud-znm2s IS INITIAL.
            TRANSLATE regud-znm1s USING '* '.
          ENDIF.
* FIN Modificación 23.02.2010
          CONCATENATE regud-znm1s regud-znm2s INTO v_znm1s.
* Agrego condense HCD 13 Marzo 2012
          CONDENSE  v_znm1s.
          CONCATENATE v_znm1s  '***' INTO v_znm1s.
*JFY 22/06/2010
          TRANSLATE v_znm1s USING '# '.
*Herman 22/06/2010
          TRANSLATE v_znm1s USING '  '.
*Fin Cambio

          TRANSLATE v_znm1s TO UPPER CASE.
          TRANSLATE regud-znm1s TO UPPER CASE.

********** Fin Cambio

          CLEAR: t_bseg-debe, t_bseg-haber.
          v_znm2s = regud-znm2s.
          TRANSLATE v_znm2s TO UPPER CASE.
          regud-znm2s = v_znm2s.
          CLEAR: t_bseg-debe, t_bseg-haber.

******************************************************************
*Recuperamos nombre que debe ir en el cheque.
          DATA: v_adrnr LIKE lfa1-adrnr,
                x TYPE i,
                y TYPE i,
                v_cadena(10).

          IF reguh-empfg IS INITIAL.
            SELECT SINGLE adrnr
            INTO v_adrnr
            FROM lfa1
            WHERE lifnr = reguh-lifnr.
            IF sy-subrc = 0.

* Modificación 23.02.2010
              CLEAR: v_znm1s.
* FIN Modificación 23.02.2010
              SELECT SINGLE name1 name2
              INTO (v_znm1s, v_znm2s)
              FROM adrc
              WHERE addrnumber = v_adrnr.
            ENDIF.
          ELSE.
            CLEAR: x, y.
            x = STRLEN( reguh-empfg ).
            DO x TIMES.
              IF reguh-empfg+y(1) CA '0123456789'.
                CONCATENATE v_cadena reguh-empfg+y(1) INTO v_cadena.
              ENDIF.
              y = y + 1.
            ENDDO.

            SELECT SINGLE adrnr
            INTO v_adrnr
            FROM lfa1
            WHERE lifnr = v_cadena.
            IF sy-subrc = 0.
* Modificación 23.02.2010
              CLEAR:  v_znm1s, v_znm2s.
* FIN Modificación 23.02.2010
              SELECT SINGLE name1 name2
              INTO (v_znm1s, v_znm2s)
              FROM adrc
              WHERE addrnumber = v_adrnr.
            ENDIF.
          ENDIF.

          TRANSLATE v_znm1s TO UPPER CASE.
          TRANSLATE v_znm2s TO UPPER CASE.

* Modificación 23.02.2010

* 19-03-2012           IF v_znm2s IS INITIAL.
* 19-03-2012             CONCATENATE v_znm1s '***' INTO v_znm1s.
* 19-03-2012           ENDIF.
* FIN Modificación 23.02.2010
* 19-03-2012           CONCATENATE v_znm2s '***' INTO v_znm2s.


* Modificación 23.02.2010
          CONCATENATE v_znm1s v_znm2s INTO v_znm1s.
          CONCATENATE v_znm1s '***' INTO v_znm1s.
* AGREGIO LINEA CONDENSE 13 Marzo 2012 HCD

          CONDENSE v_znm1s.

*JFY 22/06/2010
          TRANSLATE v_znm1s USING '# '.
*Herman 22/06/2010
          TRANSLATE v_znm1s USING '  '.
*Fin Cambio

* FIN Modificación 23.02.2010
******************************************************************
*Eliminamos caracteres especiales.
          PERFORM revisa_string USING regud-znm1s.
          PERFORM revisa_string USING regud-znm2s.
          PERFORM revisa_string USING reguh-name1.

          reguh-name2 = reguh-name2+0(13).
          CONDENSE reguh-name2.
          PERFORM revisa_string USING reguh-name2.
          PERFORM revisa_string USING v_znm1s.
          CLEAR f_largo.
          f_largo = STRLEN( v_znm1s ).

          PERFORM revisa_string USING reguh-znme1.
          reguh-znme2 = reguh-znme2+0(13).
          CONDENSE reguh-znme2.
          PERFORM revisa_string USING reguh-znme2.

          PERFORM revisa_string USING spell-word.

******************************************************************
          MOVE spell TO spell1.
          MOVE reguh TO reguh1.
          MOVE regud TO regud1.
******************************************************************
* Se rescata  nombre de cheque por sociedad.

          SELECT SINGLE tdname
             FROM zfirmadigital
             INTO fm1
            WHERE bukrs EQ regup-zbukr
              AND orden EQ 1.

          SELECT SINGLE tdname
             FROM zfirmadigital
             INTO fm2
            WHERE bukrs EQ regup-zbukr
              AND orden EQ 2.

********************************************************************
* Modificación 24.02.2010
* Se revisa si corresponde inmprimir con cheque cruzado o normal.
* Si campo BSEG-XREF3 = 'X' ==> cheque cruzado
          CLEAR v_cruzado.
          CLEAR v_desc_mot.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
          SELECT SINGLE * FROM bseg
            WHERE bukrs = regup-bukrs
              AND belnr = regup-belnr
              AND gjahr = regup-gjahr
              AND buzei = regup-buzei.

          IF sy-subrc EQ 0 AND bseg-xref3 = 'X'.
            v_cruzado = '| |'.
          ENDIF.

          SELECT SINGLE zzdescr FROM zagencia
            INTO v_desc_agen WHERE zzcod_unidad = bseg-zz_agencia.


          SELECT SINGLE zzdescr FROM zmot_emis
             INTO v_desc_mot WHERE zzmot_emis = bseg-zzmot_emis.

* FIN Modificación 24.02.2010

*ARVM 30102008.
          CLEAR v_banco.
          IF t042z-xeinz EQ space.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'CHECKSPL'
                element = '545'
              EXCEPTIONS
                window  = 1
                element = 2.

            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'CHECK'
                element = '545'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'CHECK'.
              err_element-elemt = '545'.
              err_element-text  = text_545.
              COLLECT err_element.
            ENDIF.
          ELSE.                        "debitorische Wechsel Frankreich
            CALL FUNCTION 'WRITE_FORM' "bills of exchange to debitors
                 EXPORTING             "(France)
                      window  = 'CHECKSPL'
                      element = '546'
                 EXCEPTIONS
                      window  = 1
                      element = 2.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'CHECK'
                element = '546'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = 'CHECK'.
              err_element-elemt = '546'.
              err_element-text  = text_546.
              COLLECT err_element.
            ENDIF.
          ENDIF.
        ENDIF.

*       Angabenteil fÃ¼r die OeNB-Meldung (Ã–sterreich)
*       Austria only
        IF t042e-xausl NE space        "Auslandsscheck, nicht PfÃ¤ndung
        AND NOT ( hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' ).
          CLEAR:
            regud-x08, regud-x10, regud-x11, regud-x12, regud-x13,
            regud-text1, regud-zwck1, regud-zwck2.
          IF up_oenb_kontowae-uwaer EQ 'ATS'.
            regud-x08   = 'X'.
          ELSE.
            regud-text1 = up_oenb_kontowae-uwaer.
          ENDIF.
          SORT up_oenb_angaben BY summe DESCENDING.
          READ TABLE up_oenb_angaben INDEX 1.
          CASE up_oenb_angaben-diekz.
            WHEN space.
              regud-x10 = 'X'.
            WHEN 'I'.
              regud-x10 = 'X'.
            WHEN 'R'.
              regud-x11 = 'X'.
            WHEN 'K'.
              regud-x12 = 'X'.
            WHEN OTHERS.
              regud-x13 = 'X'.
              PERFORM read_scb_indicator USING up_oenb_angaben-lzbkz.
              regud-zwck1 = t015l-zwck1.
              regud-zwck2 = t015l-zwck2.
          ENDCASE.

          IF t042e-zforn EQ 'ZFO_FI001_AVISO' OR t042e-zforn(13) EQ 'ZFO_FI001_AVI' OR t042e-zforn(13) EQ 'ZFO_BSEC_01' OR t042e-zforn(13) EQ it_zconfchk-formulario.
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = 'ORDERS'
                element = '550'
              EXCEPTIONS
                window  = 1
                element = 2.
          ENDIF.
        ENDIF.

*       Formular beenden
*       End check form
        CALL FUNCTION 'END_FORM'
          IMPORTING
            RESULT = itcpp.
        IF itcpp-tdpages EQ 0.         "Print via RDI
          itcpp-tdpages = 1.
        ENDIF.
        IF flg_schecknum EQ 1.
          cnt_seiten = itcpp-tdpages.  "FÃ¼r vornumerierte Schecks
        ELSE.                          "For prenumbered checks
          cnt_seiten = 1.
        ENDIF.
        IF flg_schecknum NE 0 AND cnt_seiten GT 0.
          PERFORM scheckinfo_speichern USING 2.
        ENDIF.

***********************************************************
*         CALL FUNCTION 'OPEN_FORM'
*        EXPORTING
*          archive_index  = toa_dara
*          archive_params = arc_params
*          form           = t042e-zforn
*          device         = 'PRINTER'
*          language       = t001-spras
*          OPTIONS        = itcpo
**          dialog         = flg_dialog
*        IMPORTING
*          RESULT         = itcpp
*        EXCEPTIONS
*          form           = 1.
***********************************************************
      ENDIF.
    ENDAT.


*-- Ende der Hausbank --------------------------------------------------
*-- end of house bank --------------------------------------------------
    AT END OF reguh-ubnkl.

      IF cnt_formulare NE 0.           "FormularabschluÃŸ erforderlich
        "summary necessary

*       close last check
        CALL FUNCTION 'CLOSE_FORM'
          IMPORTING
            RESULT = itcpp.

        IF itcpp-tdspoolid NE 0.
          CLEAR tab_ausgabe.
          tab_ausgabe-name    = t042z-text1.
          tab_ausgabe-dataset = itcpp-tddataset.
          tab_ausgabe-spoolnr = itcpp-tdspoolid.
          tab_ausgabe-immed   = par_sofz.
          COLLECT tab_ausgabe.
        ENDIF.
        CLEAR flg_druckmodus.
*ini test
*        IF hlp_laufk NE '*'            "kein Onlinedruck
*                                       "no online check print
*          AND par_nosu EQ space.       "FormularabschluÃŸ gewÃ¼nscht
*          "summary requested
**         Formular fÃ¼r den AbschluÃŸ starten
**         start form for summary
*          SET COUNTRY space.
*          IMPORT itcpo FROM MEMORY ID 'RFFORI01_ITCPO'.
*          itcpo-tdnewid = space.
*
*
*          CALL FUNCTION 'OPEN_FORM'
*            EXPORTING
*              form     = t042e-zforn
*              device   = 'PRINTER'
*              language = t001-spras
*              options  = itcpo
*              dialog   = space.
*          CALL FUNCTION 'START_FORM'
*            EXPORTING
*              startpage = 'LAST'
*              language  = t001-spras.
*
**         Vornumerierte Schecks: letzte Schecknummer ermitteln
**         prenumbered checks: compute last check number
*          IF flg_schecknum EQ 1.
*            PERFORM schecknummer_ermitteln USING 3.
*          ENDIF.
*
**         Ausgabe des Formularabschlusses
**         print summary
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              window = 'SUMMARY'
*            EXCEPTIONS
*              window = 1.
*          IF sy-subrc EQ 1.
*            err_element-fname = t042e-zforn.
*            err_element-fenst = 'SUMMARY'.
*            err_element-elemt = space.
*            err_element-text  = space.
*            COLLECT err_element.
*          ENDIF.
*
**         Fenster Scheck, Element Entwertet
**         window check, element voided check
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              window  = 'CHECK'
*              element = '540'
*            EXCEPTIONS
*              window  = 1        "Fehler bereits oben gemerkt
*              element = 2.       "error already noted
*
**         Formular fÃ¼r den AbschluÃŸ beenden
**         end form for summary
*          CALL FUNCTION 'END_FORM'
*            IMPORTING
*              RESULT = itcpp.
*          IF itcpp-tdpages EQ 0.       "Print via RDI
*            itcpp-tdpages = 1.
*          ENDIF.
*          cnt_seiten = itcpp-tdpages.  "FÃ¼r vornumerierte Schecks
*          "For prenumbered checks
*          IF flg_schecknum EQ 1 AND cnt_seiten GT 0.
*            PERFORM scheckinfo_speichern USING 3.
*          ENDIF.
*
**         AbschluÃŸ des Formulars
**         close form
*          CALL FUNCTION 'CLOSE_FORM'
*            IMPORTING
*              RESULT = itcpp.
*
*          IF itcpp-tdspoolid NE 0.
*            CLEAR tab_ausgabe.
*            tab_ausgabe-name    = t042z-text1.
*            tab_ausgabe-dataset = itcpp-tddataset.
*            tab_ausgabe-spoolnr = itcpp-tdspoolid.
*            tab_ausgabe-immed   = par_sofz.
*            COLLECT tab_ausgabe.
*          ENDIF.
*
*        ENDIF.
*fin test
        IF NOT itcpp-tdspoolid IS INITIAL.
          CALL FUNCTION 'RSPO_FINAL_SPOOLJOB'
            EXPORTING
              rqident = itcpp-tdspoolid
              set     = 'X'
              force   = 'X'
            EXCEPTIONS
              OTHERS  = 4.
          IF sy-subrc NE 0.
            MOVE-CORRESPONDING syst TO fimsg.
            PERFORM message USING fimsg-msgno.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDAT.
  ENDLOOP.

***********************************************************************************
***********************************************************************************
  DATA: v_flag.

*Ciudad del Proveedor.
*      t_bseg-stcd1 = ti_aviso-stcd1det.

  SELECT SINGLE ort01
  INTO t_bseg-ort01
  FROM lfa1
  WHERE lifnr = reguh-lifnr.

  IF v_aviso = 'X'.
    t042e-zforn     = 'ZFO_FI001_AVISOC'.
    itcpo-tddest    = 'ZTES'.
    itcpo-tdsuffix1 = 'ZTES'.

    CALL FUNCTION 'OPEN_FORM'
      EXPORTING
        archive_index  = toa_dara
        archive_params = arc_params
        form           = t042e-zforn
        device         = 'PRINTER'
        language       = t001-spras
        OPTIONS        = itcpo
        dialog         = space
      IMPORTING
        RESULT         = itcpp
      EXCEPTIONS
        form           = 1.

*    WHILE a <> 9.
*      a = a.
*    ENDWHILE.

    DATA: v_tabix LIKE sy-tabix.
    DATA: v_avpag VALUE 1.
    DATA: v_lineas TYPE i.

    DESCRIBE TABLE ti_aviso LINES v_lineas.

    LOOP AT ti_aviso.
      v_tabix = sy-tabix + 1.

      IF v_avpag = 1.
*Comprobante Egreso
        reguh-vblnr = ti_aviso-vblnr.
        reguh-zaldt = ti_aviso-zaldt.
*Ventana ADRESS
        reguh-lifnr = ti_aviso-lifnr.
        reguh-znme1 = ti_aviso-znme1.
        reguh-znme2 = ti_aviso-znme2.

        PERFORM revisa_string USING reguh-znme1.
        PERFORM revisa_string USING reguh-znme2.

        regud-chect = ti_aviso-chect.
        reguh-zaldt = ti_aviso-zaldt.
*Ventana INFO
        regup-hkont = ti_aviso-hkontcab.
        reguh-ubknt = ti_aviso-ubknt.
        regud-ubnka = ti_aviso-ubnka.

*Titulos de la lista.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = '515'
          EXCEPTIONS
            window  = 1
            element = 2.
      ENDIF.

*Detalle
      reguh-rwbtr  = ti_aviso-rwbtr.
      reguh-rbetr  = ti_aviso-rbetrhab.
      t_bseg-hkont = ti_aviso-hkontdet.
      t_bseg-sgtxt = ti_aviso-sgtxt.
      t_bseg-debe  = ti_aviso-dmbtrdeb.

* Banco
      reguh-name4 = v_nomban.

*Ciudad del Proveedor.
      t_bseg-stcd1 = ti_aviso-stcd1det.

      SELECT SINGLE ort01
      INTO t_bseg-ort01
      FROM lfa1
      WHERE lifnr = reguh-lifnr.

      regup-xblnr  = ti_aviso-xblnr.
      regup-zfbdt  = ti_aviso-zfbdt.
      CLEAR v_avpag.
      CALL FUNCTION 'WRITE_FORM'
        EXPORTING
          element = '525'
        EXCEPTIONS
          window  = 1
          element = 2.
      READ TABLE ti_aviso INDEX v_tabix.
      IF sy-subrc = 0.
*        IF v_lineas = v_tabix.
**Totales.
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              element = '555'
*            EXCEPTIONS
*              window  = 1
*              element = 2.
**Avance de PÃ¡gina.
*          CALL FUNCTION 'WRITE_FORM'
*            EXPORTING
*              element = 'NEW-PAGE'
*            EXCEPTIONS
*              window  = 1.
*          v_avpag = 1.
*        ELSE.
        IF ti_aviso-rbetrhab <> space.
*Totales.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = '555'
            EXCEPTIONS
              window  = 1
              element = 2.
*Avance de PÃ¡gina.
          CALL FUNCTION 'WRITE_FORM'
            EXPORTING
              element = 'NEW-PAGE'
            EXCEPTIONS
              window  = 1.
          v_avpag = 1.
        ENDIF.
      ELSE.
*         *totales.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = '555'
          EXCEPTIONS
            window  = 1
            element = 2.
*Avance de PÃ¡gina.
        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element = 'NEW-PAGE'
          EXCEPTIONS
            window  = 1.
        v_avpag = 1.

      ENDIF.
*      ENDIF.
    ENDLOOP.
  ENDIF.
  hlp_ep_element = '525'.
ENDFORM.                               "Scheck

************************************** scheck4 *************************
* Imprime cheques de a 4 por hoja                                      *
*                                                                      *
************************************** scheck4 *************************

*  --------------------------------------------------------------------*
FORM scheck4.
  DATA aa(4).
*----------------------------------------------------------------------*
* Abarbeiten der extrahierten Daten                                    *
* loop at extracted data                                               *
*----------------------------------------------------------------------*
  IF flg_sort NE 2.
    SORT BY avis.
    flg_sort = 2.
  ENDIF.

  hlp_ep_element = '525'.

  DATA cambiop TYPE n. " CAMBIO PAGINA "0 = NO . 1 = SI  "

  LOOP.

*-- Neuer zahlender Buchungskreis --------------------------------------
*-- new paying company code --------------------------------------------
    AT NEW reguh-zbukr.
      PERFORM buchungskreis_daten_lesen.
    ENDAT.

*-- Neuer Zahlweg ------------------------------------------------------
*-- new payment method -------------------------------------------------
    AT NEW reguh-rzawe.

      flg_probedruck = 0.              "fÃ¼r diesen Zahlweg wurde noch
      "kein Probedruck durchgefÃ¼hrt
      "test print for this payment
      "method not yet done
      PERFORM zahlweg_daten_lesen.

*     Spoolparameter zur Ausgabe des Schecks angeben
*     specify spool parameters for check print
      PERFORM fill_itcpo USING par_priz
                               t042z-zlstn
                               space   "par_sofz via tab_ausgabe!
                               hlp_auth.

      IF NOT titulo IS INITIAL.
        itcpo-tdcovtitle = titulo.
      ENDIF.

      IF flg_schecknum NE 0.
        itcpo-tddelete  = 'X'.         "delete after print
      ENDIF.
      EXPORT itcpo TO MEMORY ID 'RFFORI01_ITCPO'.
    ENDAT.

*-- Neue Zahlungsbelegnummer -------------------------------------------
*-- new payment document number ----------------------------------------
    AT NEW reguh-vblnr.
      v_cheque = v_cheque + 1.
      cambiop = 0.
      IF v_cheque EQ 5.
        CLEAR reguh1.
        CLEAR regud1.
        CLEAR reguh2.
        CLEAR regud2.
        CLEAR reguh3.
        CLEAR regud3.
        CLEAR reguh4.
        CLEAR regud4.
        CLEAR spell1. CLEAR spell2. CLEAR spell3.CLEAR spell4.
        REFRESH spell1. REFRESH spell2. REFRESH spell3. REFRESH spell4.
        REFRESH reguh1.
        REFRESH regud1.
        REFRESH reguh2.
        REFRESH regud2.
        REFRESH reguh3.
        REFRESH regud3.
        REFRESH reguh4.
        REFRESH regud4.
        v_cheque = 1.
        CLEAR: v1_cruzado, v2_cruzado, v3_cruzado, v4_cruzado.
      ENDIF.

      IF v_cheque EQ 1.
        v_scheque = 'CHECK'.
      ELSEIF v_cheque EQ 2.
        v_scheque = 'CHECK2'.
      ELSEIF v_cheque EQ 3.
        v_scheque = 'CHECK3'.
      ELSEIF v_cheque EQ 4.
        v_scheque = 'CHECK4'.
      ENDIF.

*     FIN  LSS   ---
*     Angabentabelle und KontowÃ¤hrung fÃ¼r die OeNB-Meldung (Ã–sterreich)
*     Austria only
      IF t042e-xausl EQ 'X' AND        "nur Auslandsscheck
        hlp_laufk NE 'P'.              "kein HR
        REFRESH up_oenb_angaben.
        CLEAR up_oenb_kontowae.
        READ TABLE up_oenb_kontowae WITH KEY reguh-ubhkt.
        IF sy-subrc NE 0.
          PERFORM hausbank_konto_lesen.
          up_oenb_kontowae-ubhkt = reguh-ubhkt.
          PERFORM isocode_umsetzen
            USING t012k-waers up_oenb_kontowae-uwaer.
          APPEND up_oenb_kontowae.
        ENDIF.
      ENDIF.

*     Lesen der Referenzangaben (Schweiz)
*     Switzerland only
      PERFORM hausbank_konto_lesen.

*     Kein Druck falls FremdwÃ¤hrung, aber kein FremdwÃ¤hrungsscheck
*     no print if foreign currency, but global &REGUD-WAERS& is missing
      flg_kein_druck = 0.
      IF reguh-waers NE t001-waers AND flg_fw_scheck EQ 0.
        err_fw_scheck-fname = t042e-zforn.
        MOVE-CORRESPONDING reguh TO err_fw_scheck.
        COLLECT err_fw_scheck.
        flg_kein_druck = 1.            "kein Druck mÃ¶glich
      ENDIF.                           "no print

      IF flg_kein_druck EQ 0.

        PERFORM zahlungs_daten_lesen.

*       Tag der Zahlung in Worten (Spanien)
*       day of payment in words (Spain)
        CLEAR t015z.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
        SELECT SINGLE * FROM t015z
          WHERE spras EQ hlp_sprache
            AND einh  EQ reguh-zaldt+6(1)
            AND ziff  EQ reguh-zaldt+7(1).
        IF sy-subrc EQ 0.
          regud-text2 = t015z-wort.
          TRANSLATE regud-text2 TO LOWER CASE.           "#EC TRANSLANG
          TRANSLATE regud-text2 USING '; '.
        ELSE.
          CLEAR err_t015z.
          err_t015z-spras = hlp_sprache.
          err_t015z-einh  = reguh-zaldt+6(1).
          err_t015z-ziff  = reguh-zaldt+7(1).
          COLLECT err_t015z.
        ENDIF.


*       Name des Fensters mit dem Anschreiben zusammensetzen
*       specify name of the window with the check text
        hlp_element   = '510-'.
        hlp_element+4 = reguh-rzawe.
        hlp_eletext   = text_510.
        REPLACE '&ZAHLWEG' WITH reguh-rzawe INTO hlp_eletext.

*       Druckvorgaben modifizieren lassen
*       modification of print parameters
        IMPORT itcpo FROM MEMORY ID 'RFFORI01_ITCPO'.
        PERFORM modify_itcpo.

*       open form only at first time or when optical archiving is active
        IF flg_druckmodus NE 1 OR itcpo-tdarmod NE '1'.
*         Scheckformular Ã¶ffnen
*         open check form
          IF cnt_formulare EQ 0.
            itcpo-tdnewid = 'X'.
          ELSE.
            itcpo-tdnewid = space.
          ENDIF.
          IF par_priz EQ space.
            flg_dialog = 'X'.
          ELSE.
            flg_dialog = space.
          ENDIF.

*         close last form
          IF flg_druckmodus NE 0.
            CALL FUNCTION 'CLOSE_FORM'
              IMPORTING
                RESULT = itcpp.

            IF itcpp-tdspoolid NE 0.
              CLEAR tab_ausgabe.
              tab_ausgabe-name    = t042z-text1.
              tab_ausgabe-dataset = itcpp-tddataset.
              tab_ausgabe-spoolnr = itcpp-tdspoolid.
              tab_ausgabe-immed   = par_sofz.
              COLLECT tab_ausgabe.
            ENDIF.
          ENDIF.

          flg_druckmodus = itcpo-tdarmod.
          IF v_cheque EQ 1.
            CALL FUNCTION 'OPEN_FORM'
              EXPORTING
                archive_index  = toa_dara
                archive_params = arc_params
                form           = t042e-zforn
                device         = 'PRINTER'
                language       = t001-spras
                OPTIONS        = itcpo
                dialog         = flg_dialog
              IMPORTING
                RESULT         = itcpp
              EXCEPTIONS
                form           = 1.
            IF sy-subrc EQ 1.              "abend:
              IF sy-batch EQ space.        "form is not active
                MESSAGE a069 WITH t042e-zforn.
              ELSE.
                MESSAGE s069 WITH t042e-zforn.
                MESSAGE s094.
                STOP.
              ENDIF.
            ENDIF.
          ENDIF." if v_cheque eq 1.

          par_priz = itcpp-tddest.
          PERFORM fill_itcpo_from_itcpp.
          EXPORT itcpo TO MEMORY ID 'RFFORI01_ITCPO'.
        ENDIF. "flg_druckmodus NE 1 OR itcpo-tdarmod NE '1'

        PERFORM summenfelder_initialisieren.

*       PrÃ¼fe, ob HR-Formular zu verwenden ist
*       Check if HR-form is to be used
        IF ( hlp_laufk EQ 'P' OR
             hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' )
         AND hrxblnr-xhrfo NE space.
          hlp_xhrfo = 'X'.
        ELSE.
          hlp_xhrfo = space.
        ENDIF.

        IF v_cheque EQ 1.
*       Formular starten
*       start check form
          CALL FUNCTION 'START_FORM'
            EXPORTING
              archive_index = toa_dara
              language      = hlp_sprache.
        ENDIF.

*       Vornumerierte Schecks: nÃ¤chste Schecknummer ermitteln
*       prenumbered checks: compute next check number
        IF flg_schecknum NE 0.
          PERFORM schecknummer_ermitteln USING 2.
        ENDIF.

*       Fenster Check, Element Entwerteter Scheck
*       window check, element voided check
*        CALL FUNCTION 'WRITE_FORM'
*          EXPORTING
*            window  = 'CHECK'
*            element = '540'
*          EXCEPTIONS
*            window  = 1
*            element = 2.
        IF sy-subrc EQ 2.
          err_element-fname = t042e-zforn.
          err_element-fenst = v_scheque.
          err_element-elemt = '540'.
          err_element-text  = text_540.
          COLLECT err_element.
        ENDIF.


*       HR-Formular ausgeben
*       write HR form
        IF hlp_xhrfo NE space.
          LOOP AT pform.
            IF cnt_zeilen GT t042e-anzpo AND sy-tabix GT t042e-anzpo.
              EXIT.
            ENDIF.
            regud-txthr = pform-linda.
            PERFORM scheckavis_zeile.
          ENDLOOP.
        ENDIF.
        flg_diff_bukrs = 0.

      ENDIF.

    ENDAT.

*-- Neuer Rechnungsbuchungskreis ---------------------------------------


*-- Ende der Zahlungsbelegnummer ---------------------------------------
*-- end of payment document number -------------------------------------
    AT END OF reguh-vblnr.

      IF flg_kein_druck EQ 0.

**      Zahlbetrag ohne Aufbereitungszeichen fÃ¼r Codierzeile speichern
*       store numerical payment amount for code line
        IF reguh-waers EQ t001-waers.
          regud-socra = regud-swnes.
        ELSE.
          regud-socra = 0.
          PERFORM laender_lesen USING t001-land1.
          IF t005-intca EQ 'DE'.
            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
            IF hlp_waers EQ 'DEM' OR hlp_waers EQ 'EUR'.
              regud-socra = regud-swnes.
            ENDIF.
          ENDIF.
          IF t005-intca EQ 'AT'.
            PERFORM isocode_umsetzen USING reguh-waers hlp_waers.
            IF hlp_waers EQ 'ATS' OR hlp_waers EQ 'EUR'.
              regud-socra = regud-swnes.
            ENDIF.
          ENDIF.
        ENDIF.
        IF reguh-waers EQ t012k-waers.
          regud-socrb = regud-swnes.
        ELSE.
          regud-socrb = 0.
        ENDIF.

        PERFORM ziffern_in_worten.

*       Summenfelder hochzÃ¤hlen und aufbereiten
*       add up total amount fields
        ADD 1            TO cnt_formulare.
        ADD reguh-rbetr  TO sum_abschluss.
        WRITE:
          cnt_hinweise   TO regud-avish,
          cnt_formulare  TO regud-zahlt,
          sum_abschluss  TO regud-summe CURRENCY t001-waers.
        TRANSLATE:
          regud-avish USING ' *',
          regud-zahlt USING ' *',
          regud-summe USING ' *'.

        IF hlp_xhrfo EQ space.

* Nur fÃ¼r Brasilien (Check auf Land liegt in Funktionsbaustein)
* Only Brazil (Check on country within the function module)

          CALL FUNCTION 'BOLETO_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.

          CALL FUNCTION 'KOREA_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.

        ENDIF.
*       Fenster Check, Element Entwerteter Scheck lÃ¶schen
*       window check, delete element voided check
        IF reguh-rwbtr NE 0.           "zero net check has to be voided
*------------------------------------------------------------------------------------

**Alvaro Vergara Madrid Alynea MVC Amercias
*Monto Total y Descripción del Monto Total.
*Monto en Texto.. Control de Despliegue para pagos Masivos.
          DATA v_amount.

*V_AMOUNT = REGUH-RWBTR.

*DATA: v_reguh LIKE reguh-rwbtr.

          IF v_acumula = 'X'.
*v_reguh = reguh-rwbtr.
*reguh-rwbtr = v_totlin.
            CLEAR: v_totlin, v_acumula.
          ENDIF.

          CALL FUNCTION 'SPELL_AMOUNT'
           EXPORTING
             amount          = reguh-rwbtr
             currency        = 'CLP'
*   FILLER          = ' '
             language        = sy-langu
           IMPORTING
             in_words        = spell
           EXCEPTIONS
             not_found       = 1
             too_large       = 2
             OTHERS          = 3.


          TRANSLATE spell-word TO UPPER CASE.
*          reguh-rwbtr = v_reguh.


*ARVM 30102008.
*Imprimimos el Total solo una vez.
          t_bseg-debe  = v_debe.
          t_bseg-haber = v_haber.

*Limpieza de variales de nombre.
*          CLEAR: v_znm1s, v_znm2s.


********* Cambio para concatenar los nombres
********* Cristian Infante 29/01/2010

          CONCATENATE regud-znm1s  regud-znm2s INTO v_znm1s.
*JFY 22/06/2010
          TRANSLATE v_znm1s USING '# '.
*Herman 22/06/2010
          TRANSLATE v_znm1s USING '  '.
*Fin Cambio
          TRANSLATE v_znm1s TO UPPER CASE.
          TRANSLATE regud-znm1s TO UPPER CASE.

********* Fin del cambio

          CLEAR: t_bseg-debe, t_bseg-haber.

          v_znm2s = regud-znm2s.
          TRANSLATE v_znm2s TO UPPER CASE.
          regud-znm2s = v_znm2s.
          CLEAR: t_bseg-debe, t_bseg-haber.

******************************************************************
*Recuperamos nombre que debe ir en el cheque.
          DATA: v_adrnr LIKE lfa1-adrnr,
                x TYPE i,
                y TYPE i,
                v_cadena(10).

          IF reguh-empfg IS INITIAL.
            SELECT SINGLE adrnr
            INTO v_adrnr
            FROM lfa1
            WHERE lifnr = reguh-lifnr.
            IF sy-subrc = 0.
              SELECT SINGLE name1 name2
              INTO (v_znm1s, v_znm2s)
              FROM adrc
              WHERE addrnumber = v_adrnr.
            ENDIF.
          ELSE.
            CLEAR: x, y.
            x = STRLEN( reguh-empfg ).
            DO x TIMES.
              IF reguh-empfg+y(1) CA '0123456789'.
                CONCATENATE v_cadena reguh-empfg+y(1) INTO v_cadena.
              ENDIF.
              y = y + 1.
            ENDDO.
            SELECT SINGLE adrnr
            INTO v_adrnr
            FROM lfa1
            WHERE lifnr = v_cadena.
            IF sy-subrc = 0.
              SELECT SINGLE name1 name2
              INTO (v_znm1s, v_znm2s)
              FROM adrc
              WHERE addrnumber = v_adrnr.
            ENDIF.
          ENDIF.

          TRANSLATE v_znm1s TO UPPER CASE.
          TRANSLATE v_znm2s TO UPPER CASE.

          CONCATENATE v_znm1s '***' INTO v_znm1s.
          CONCATENATE v_znm2s '***' INTO v_znm2s.
******************************************************************
*Loop para Debbug
*          DATA: var(1) VALUE 'X'.
*          WHILE var = 'X'.
*          ENDWHILE.

*jfy 08032010
          IF regud-znm2s EQ '***********************************'.
            CLEAR: regud-znm2s.
          ENDIF.

          PERFORM revisa_string USING regud-znm1s.
          PERFORM revisa_string USING regud-znm2s.
          PERFORM revisa_string USING spell-word.

* Modificaciones 13 marzo 2012 HCD

* Concatena nombre a 70 caracteres
* COMENTARIO 1
*          IF NOT regud-znm2s IS INITIAL.
*            TRANSLATE regud-znm1s USING '* '.
*          ELSE.
*            TRANSLATE regud-znm2s USING '* '.
*          ENDIF.
* COMENTARIO 1
          CONCATENATE regud-znm1s regud-znm2s INTO v_znm1s.
          TRANSLATE v_znm1s USING '* '.
* AGREGO HCD
          CONDENSE v_znm1s.
          CONCATENATE v_znm1s  '***' INTO v_znm1s.
* FIN AGREGO HCD
* FIN Modificaciones 13 marzo 2012 HCD
*JFY 22/06/2010
          TRANSLATE v_znm1s USING '# '.
*Herman 22/06/2010
          TRANSLATE v_znm1s USING '  '.
*Fin Cambio
          TRANSLATE v_znm1s TO UPPER CASE.
          f_largo = STRLEN( v_znm1s ).

* Se revisa si corresponde inmprimir con cheque cruzado o normal.
* Si campo BSEG-XREF3 = 'X' ==> cheque cruzado
          CLEAR v_cruzado.

*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES02 ECDK917080 *
          SELECT SINGLE * FROM bseg
            WHERE bukrs = regup-bukrs
              AND belnr = regup-belnr
              AND gjahr = regup-gjahr
              AND buzei = regup-buzei.

          IF sy-subrc EQ 0 AND bseg-xref3 = 'X'.
            v_cruzado = '| |'.
          ENDIF.
*         CLEAR: v1_cruzado, v2_cruzado, v3_cruzado, v4_cruzado.

* Se revisa si corresponde inmprimir con cheque cruzado o normal.
* Si campo BSEG-XREF3 = 'X' ==> cheque cruzado.



          SELECT SINGLE zzdescr FROM zagencia
            INTO v_desc_agen WHERE zzcod_unidad = bseg-zz_agencia.

          SELECT SINGLE zzdescr FROM zmot_emis
             INTO v_desc_mot WHERE zzmot_emis = bseg-zzmot_emis.



*Fin jfy 08032010
******************************************************************
          IF v_cheque EQ 1.
            MOVE spell     TO spell1.
            MOVE reguh     TO reguh1.
            MOVE regud     TO regud1.
            MOVE v_znm1s   TO v1_znm1s.
            f1_largo = f_largo.
            MOVE v_cruzado TO v1_cruzado.
            MOVE v_desc_agen TO v1_desc_agen.
            MOVE v_desc_mot TO v1_desc_mot.
          ELSEIF v_cheque EQ 2.
            MOVE spell TO spell2.
            MOVE reguh TO reguh2.
            MOVE regud TO regud2.
            MOVE v_znm1s TO v2_znm1s.
            f2_largo = f_largo.
            MOVE v_cruzado TO v2_cruzado.
            MOVE v_desc_agen TO v2_desc_agen.
            MOVE v_desc_mot TO v2_desc_mot.
          ELSEIF v_cheque EQ 3.
            MOVE spell TO spell3.
            MOVE reguh TO reguh3.
            MOVE regud TO regud3.
            MOVE v_znm1s TO v3_znm1s.
            f3_largo = f_largo.
            MOVE v_cruzado TO v3_cruzado.
            MOVE v_desc_agen TO v3_desc_agen.
            MOVE v_desc_mot TO v3_desc_mot.
          ELSEIF v_cheque EQ 4.
            MOVE spell TO spell4.
            MOVE reguh TO reguh4.
            MOVE regud TO regud4.
            MOVE v_znm1s TO v4_znm1s.
            f4_largo = f_largo.
            MOVE v_cruzado TO v4_cruzado.
            MOVE v_desc_agen TO v4_desc_agen.
            MOVE v_desc_mot TO v4_desc_mot.
          ENDIF.

*********************************************************************+
* Se rescata  nombre de cheque por sociedad.
          SELECT SINGLE tdname
             FROM zfirmadigital
             INTO fm1
            WHERE bukrs EQ regup-zbukr
              AND orden EQ 1.

          SELECT SINGLE tdname
             FROM zfirmadigital
             INTO fm2
            WHERE bukrs EQ regup-zbukr
              AND orden EQ 2.
********************************************************************
*ARVM 30102008.
          CLEAR v_banco.
          IF t042z-xeinz EQ space.
            IF v_cheque = 2.

              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  window  = v_scheque
                  element = '545'
                EXCEPTIONS
                  window  = 1
                  element = 2.
            ELSE.
              CALL FUNCTION 'WRITE_FORM'
                EXPORTING
                  window  = v_scheque
                  element = '545'
                EXCEPTIONS
                  window  = 1
                  element = 2.
            ENDIF.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = v_scheque.
              err_element-elemt = '545'.
              err_element-text  = text_545.
              COLLECT err_element.
            ENDIF.
          ELSE.                        "debitorische Wechsel Frankreich
            CALL FUNCTION 'WRITE_FORM'
              EXPORTING
                window  = v_scheque
                element = '546'
              EXCEPTIONS
                window  = 1
                element = 2.
            IF sy-subrc EQ 2.
              err_element-fname = t042e-zforn.
              err_element-fenst = v_scheque.
              err_element-elemt = '546'.
              err_element-text  = text_546.
              COLLECT err_element.
            ENDIF.
          ENDIF.
        ENDIF.
*       Formular beenden
*       End check form
        IF v_cheque = 4.
          CALL FUNCTION 'END_FORM'
            IMPORTING
              RESULT = itcpp.
*      clear estructuras 2,3,4
        ENDIF.


*       Angabenteil fÃ¼r die OeNB-Meldung (Ã–sterreich)
*       Austria only
        IF t042e-xausl NE space        "Auslandsscheck, nicht PfÃ¤ndung
        AND NOT ( hrxblnr-txtsl EQ 'HR' AND hrxblnr-txerg EQ 'GRN' ).
          CLEAR:
            regud-x08, regud-x10, regud-x11, regud-x12, regud-x13,
            regud-text1, regud-zwck1, regud-zwck2.
          IF up_oenb_kontowae-uwaer EQ 'ATS'.
            regud-x08   = 'X'.
          ELSE.
            regud-text1 = up_oenb_kontowae-uwaer.
          ENDIF.
          SORT up_oenb_angaben BY summe DESCENDING.
          READ TABLE up_oenb_angaben INDEX 1.
          CASE up_oenb_angaben-diekz.
            WHEN space.
              regud-x10 = 'X'.
            WHEN 'I'.
              regud-x10 = 'X'.
            WHEN 'R'.
              regud-x11 = 'X'.
            WHEN 'K'.
              regud-x12 = 'X'.
            WHEN OTHERS.
              regud-x13 = 'X'.
              PERFORM read_scb_indicator USING up_oenb_angaben-lzbkz.
              regud-zwck1 = t015l-zwck1.
              regud-zwck2 = t015l-zwck2.
          ENDCASE.

        ENDIF.

**       Formular beenden
**       End check form
*        CALL FUNCTION 'END_FORM'
*          IMPORTING
*            RESULT = itcpp.
        IF itcpp-tdpages EQ 0.         "Print via RDI
          itcpp-tdpages = 1.
        ENDIF.
        IF flg_schecknum EQ 1.
          cnt_seiten = itcpp-tdpages.  "FÃ¼r vornumerierte Schecks
        ELSE.                          "For prenumbered checks
          cnt_seiten = 1.
        ENDIF.
        IF flg_schecknum NE 0 AND cnt_seiten GT 0.
          PERFORM scheckinfo_speichern USING 2.
        ENDIF.

      ENDIF.
    ENDAT.


*-- Ende der Hausbank --------------------------------------------------
*-- end of house bank --------------------------------------------------
    AT END OF reguh-ubnkl.

      IF cnt_formulare NE 0.           "FormularabschluÃŸ erforderlich
*       Formular beenden
*       End check form
        CALL FUNCTION 'END_FORM'
          IMPORTING
            RESULT = itcpp.
        IF itcpp-tdpages EQ 0.         "Print via RDI
          itcpp-tdpages = 1.
        ENDIF.
        IF flg_schecknum EQ 1.
          cnt_seiten = itcpp-tdpages.  "FÃ¼r vornumerierte Schecks
        ELSE.                          "For prenumbered checks
          cnt_seiten = 1.
        ENDIF.
*        IF flg_schecknum NE 0 AND cnt_seiten GT 0.
*          PERFORM scheckinfo_speichern USING 2.
*        ENDIF.

        "summary necessary
*       close last check
        CALL FUNCTION 'CLOSE_FORM'
          IMPORTING
            RESULT = itcpp.

        IF itcpp-tdspoolid NE 0.
          CLEAR tab_ausgabe.
          tab_ausgabe-name    = t042z-text1.
          tab_ausgabe-dataset = itcpp-tddataset.
          tab_ausgabe-spoolnr = itcpp-tdspoolid.
          tab_ausgabe-immed   = par_sofz.
          COLLECT tab_ausgabe.
        ENDIF.
        CLEAR flg_druckmodus.

        IF NOT itcpp-tdspoolid IS INITIAL.
          CALL FUNCTION 'RSPO_FINAL_SPOOLJOB'
            EXPORTING
              rqident = itcpp-tdspoolid
              set     = 'X'
              force   = 'X'
            EXCEPTIONS
              OTHERS  = 4.
          IF sy-subrc NE 0.
            MOVE-CORRESPONDING syst TO fimsg.
            PERFORM message USING fimsg-msgno.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDAT.
*   ENDIF. "  IF REGUD-NAME1.
  ENDLOOP.

  hlp_ep_element = '525'.
ENDFORM.                               "

************************************************************************
*                                                                      *
*  subroutines for prenumbered checks                                  *
*                                                                      *
*  subroutine                                called by / in subroutine *
*  ------------------------------------------------------------------- *
*  SCHECKDATEN_EINGABE (check data input on screen)   SELECTION-SCREEN *
*  SCHECKDATEN_PRUEFEN (check data before start)    START-OF-SELECTION *
*  SCHECKINFO_PRUEFEN (test of check information)            GET REGUH *
*  SCHECKNUMMERN_SPERREN (enqueue check numbers)      END-OF-SELECTION *
*  SCHECKNUMMER_ERMITTELN (find out check number)               SCHECK *
*  SCHECKAVIS_ZEILE (one line on the check advice)              SCHECK *
*  SCHECKS_ADDIEREN (add 1 to check number)    SCHECKAVIS_ZEILE,SCHECK *
*  SCHECKS_UMNUMERIEREN (renumber checks)       SCHECKNUMMER_ERMITTELN *
*  SCHECKINFO_SPEICHERN (store check information)               SCHECK *
*  SCHECK_ENTWERTEN (void check in restart mode)  SCHECKINFO_SPEICHERN *
*  SCHECKNUMMERN_ENTSPERREN (dequeue check numbers)   END-OF-SELECTION *
*  SCHECKDRUCK_MAIL (send mail) SCHECKNUMMERN_SPERREN,SELECTION-SCREEN *
*                                                                      *
************************************************************************


*----------------------------------------------------------------------*
* FORM SCHECKDATEN_EINGABE                                             *
*----------------------------------------------------------------------*
* PrÃ¼fen der Eingabedaten auf dem Selektionsbild                       *
* Check the input data on the selection screen                         *
*----------------------------------------------------------------------*
* P_RCHK  Restart-Schecknummer                                         *
* P_STAP  Stapel                                                       *
* P_INFO  Info zum Stapel                                              *
*----------------------------------------------------------------------*
FORM scheckdaten_eingabe USING p_rchk LIKE pcec-checl
                               p_stap LIKE pcec-stapl
                               p_info TYPE c.

  DESCRIBE TABLE zw_zbukr LINES hlp_zeilen.
  IF hlp_zeilen NE 1.                  "genau ein Buchungskreis
    SET CURSOR FIELD 'ZW_ZBUKR-LOW'.   "exactly one company code
    MESSAGE e543(fs).
  ELSE.
    READ TABLE zw_zbukr INDEX 1.
    IF zw_zbukr-option NE 'EQ' OR zw_zbukr-sign NE 'I'.
      SET CURSOR FIELD 'ZW_ZBUKR-LOW'.
      MESSAGE e543(fs).
    ENDIF.
  ENDIF.
  "genau eine Hausbank
  READ TABLE sel_hbki INDEX 1.         "exactly one house bank
  IF sy-subrc NE 0 OR sel_hbki-option NE 'EQ' OR sel_hbki-sign NE 'I'.
    SET CURSOR FIELD 'SEL_HBKI-LOW'.
    MESSAGE e544(fs).
  ENDIF.
  "genau eine Kontenverbindung
  READ TABLE sel_hkti INDEX 1.         "exactly one bank account
  IF sy-subrc NE 0 OR sel_hkti-option NE 'EQ' OR sel_hkti-sign NE 'I'.
    SET CURSOR FIELD 'SEL_HKTI-LOW'.
    MESSAGE e545(fs).
  ENDIF.

  IF zw_xvorl EQ space.                "Echtlauf
    "production run
    IF p_rchk NE space.                "Restartfall
      p_stap = 0.                      "restart mode
      p_info = space.
      SELECT * FROM payr               "Restartnummer muÃŸ vorhanden sein
        WHERE zbukr EQ zw_zbukr-low    "und zum angegebenen Zahllauf
          AND hbkid EQ sel_hbki-low    "gehÃ¶ren
          AND hktid EQ sel_hkti-low    "restart number has to exist in
          AND rzawe IN sel_zawe        "PAYR and has to belong to this
          AND chect GE p_rchk          "payment run
          AND checf EQ p_rchk.                            "#EC PORTABLE
      ENDSELECT.
      IF sy-subrc NE 0.
        SET CURSOR FIELD 'PAR_RCHK'.
        MESSAGE e562(fs).
      ENDIF.
      IF ( zw_laufd NE payr-laufd OR zw_laufi NE payr-laufi )
        AND zw_laufi+5(1) NE '*'.
        SET CURSOR FIELD 'PAR_RCHK'.
        MESSAGE e563(fs).
      ENDIF.
      IF payr-checv NE space.          "gab es beim Restartscheck einen
        SELECT SINGLE * FROM payr      "SeitenÃ¼berlauf?
          WHERE zbukr EQ payr-zbukr    "was there an overflow with the
            AND hbkid EQ payr-hbkid    "first restart check?
            AND hktid EQ payr-hktid
            AND rzawe EQ payr-rzawe
            AND chect EQ payr-checv.
        IF payr-voidr EQ 2.
          p_rchk = payr-checf.      "Parameter korrigieren
        ENDIF.                       "correct parameter
      ENDIF.
      IF payr-voidr EQ 3.              "FormularabschluÃŸ, also nichts
        SET CURSOR FIELD 'PAR_RCHK'.   "summary => nothing to be printed
        MESSAGE e571(fs).
      ENDIF.
    ELSE.                              "neue Schecks
      IF par_zdru NE space.            "new checks
        IF p_stap IS INITIAL.
          p_info = space.
          SET CURSOR FIELD 'PAR_STAP'.
          IF zw_laufi+5(1) EQ '*'.
            PERFORM scheckdruck_mail.
            MESSAGE a577(fs) WITH '546' space.
          ELSE.
            MESSAGE e546(fs).
          ENDIF.                       "Stapelnummer muÃŸ angegeben
        ELSE.                          "werden, vorhanden sein und eine
          CALL FUNCTION 'LOT_CHECK'    "gÃ¼ltige letzte vergebene Nummer
            EXPORTING                  "haben (ggf. in Folgestapel)
              i_zbukr = zw_zbukr-low   "lot number has to be filled, has
              i_hbkid = sel_hbki-low   "to exist and must have a valid
              i_hktid = sel_hkti-low   "last number, perhaps in next lot
              i_stapl = p_stap
            IMPORTING
              e_stapl = p_stap
              e_stapi = pcec-stapi
              e_zwels = pcec-zwels
            EXCEPTIONS
              OTHERS  = 4.
          p_info = pcec-stapi.
          IF sy-subrc NE 0.
            p_info = space.
            SET CURSOR FIELD 'PAR_STAP'.
            IF zw_laufi+5(1) EQ '*'.
              PERFORM scheckdruck_mail.
              fimsg-msgno = sy-msgno.
              fimsg-msgv1 = sy-msgv1.
              MESSAGE a577(fs) WITH fimsg-msgno fimsg-msgv1.
            ELSE.
              MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1.
            ENDIF.
          ELSE.
            IF pcec-zwels NE space.
              SELECT SINGLE * FROM t001 WHERE bukrs EQ zw_zbukr-low.
              SELECT * FROM t042z WHERE land1 EQ t001-land1
                                  AND   zlsch IN sel_zawe
                                  AND   progn EQ sy-repid.
                IF pcec-zwels NA t042z-zlsch.
                  MESSAGE e665(fs) WITH t042z-zlsch p_stap pcec-zwels.
                ENDIF.
              ENDSELECT.
            ENDIF.
            p_info = pcec-stapi.
          ENDIF.
        ENDIF.
      ELSE.
        p_stap = 0.
        p_info = space.
      ENDIF.
    ENDIF.

  ELSE.                                "Vorschlagslauf
    "proposal run
    IF p_rchk NE space.
      SET CURSOR FIELD 'ZW_XVORL'.
      MESSAGE e561(fs).                "kein Restart bei Vorschlagslauf
    ENDIF.                             "no restart mode if proposal run
    p_stap = 0.
    p_info = space.

  ENDIF.

ENDFORM.                               "Scheckdaten Eingabe



*----------------------------------------------------------------------*
* FORM SCHECKDATEN_PRUEFEN                                             *
*----------------------------------------------------------------------*
* PrÃ¼fen der Eingabedaten vor der Datenselektion                       *
* Check the input data before the selection of data                    *
*----------------------------------------------------------------------*
* P_RCHK  Restart-Schecknummer                                         *
* P_STAP  Stapel                                                       *
*----------------------------------------------------------------------*
FORM scheckdaten_pruefen USING p_rchk LIKE pcec-checl
                               p_stap LIKE pcec-stapl.

  REFRESH tab_check.
  flg_schecknum = 1.
  flg_pruefung  = 1.                   "Scheckinfo i.a. prÃ¼fen
  "check check info (in general)
  IF zw_xvorl EQ space AND par_zdru NE space. "Scheckdruck fÃ¼r Echtlauf
    "check print for a productive run
    IF p_rchk NE space.                "Restartfall
      flg_restart = 1.                 "restart mode
      SELECT * FROM payr
        WHERE zbukr EQ zw_zbukr-low
          AND hbkid EQ sel_hbki-low
          AND hktid EQ sel_hkti-low
          AND rzawe IN sel_zawe
          AND chect GE p_rchk
          AND checf EQ p_rchk.                            "#EC PORTABLE
      ENDSELECT.
      CASE payr-voidr.
        WHEN 0.
          hlp_checf_restart = p_rchk.
        WHEN 1.                        "vollstÃ¤ndiger Restart
          flg_restart = 2.             "complete restart
          CALL FUNCTION 'COMPARE_CHECK_NUMBERS'
            EXPORTING
              i_check1   = payr-checf
              i_check2   = payr-chect
            IMPORTING
              e_distance = par_anzp.
          ADD 1 TO par_anzp.
        WHEN 2.
          hlp_checf_restart = payr-checv.
      ENDCASE.
      tab_check-sign   = 'I'.
      tab_check-option = 'BT'.
      CALL FUNCTION 'GET_CHECK_INTERVAL'
        EXPORTING
          i_zbukr = zw_zbukr-low
          i_hbkid = sel_hbki-low
          i_hktid = sel_hkti-low
          i_check = p_rchk
        IMPORTING
          e_pcec  = pcec
        EXCEPTIONS
          OTHERS  = 4.
      pcec-checf = p_rchk.
      IF sy-subrc NE 0.
        CLEAR pcec-fstap.
        IF '9' GT 'Z'.                                    "#EC PORTABLE
          pcec-chect = '9999999999999'.
        ELSE.
          pcec-chect = 'ZZZZZZZZZZZZZ'.
        ENDIF.
      ENDIF.
      DO.
        tab_check-low  = pcec-checf.
        tab_check-high = pcec-chect.
        APPEND tab_check.
        IF pcec-fstap IS INITIAL.
          EXIT.
        ENDIF.
        SELECT SINGLE * FROM pcec
          WHERE zbukr EQ pcec-zbukr
            AND hbkid EQ pcec-hbkid
            AND hktid EQ pcec-hktid
            AND stapl EQ pcec-fstap.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
      ENDDO.
    ELSE.                              "neue Schecks
      IF sy-batch NE space.            "new checks
        CALL FUNCTION 'LOT_CHECK'
          EXPORTING
            i_zbukr = zw_zbukr-low
            i_hbkid = sel_hbki-low
            i_hktid = sel_hkti-low
            i_stapl = p_stap
          IMPORTING
            e_stapl = p_stap
          EXCEPTIONS
            OTHERS  = 4.
        IF sy-subrc NE 0.
          MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno WITH sy-msgv1.
          STOP.
        ENDIF.
      ENDIF.
      SELECT SINGLE * FROM pcec
        WHERE zbukr EQ zw_zbukr-low
          AND hbkid EQ sel_hbki-low
          AND hktid EQ sel_hkti-low
          AND stapl EQ p_stap.
    ENDIF.
    IMPORT flg_local FROM MEMORY ID 'MFCHKFN0'.
    IF sy-subrc EQ 0.                  "bei Transaktion 'Scheck neu
      flg_pruefung = 0.                "drucken' Pruefung ausschalten
    ENDIF.                             "no check when 'reprint check'

  ELSE.                                "Vorschlagslauf oder nur Avise
    "proposal run or only advices
    pcec-mandt = sy-mandt.             "Testdaten erhalten Dummy-Scheck-
    pcec-zbukr = zw_zbukr-low.         "nummern, die nicht in PAYR abge-
    pcec-hbkid = sel_hbki-low.         "speichert werden
    pcec-hktid = sel_hkti-low.         "test checks get dummy check
    pcec-stapl = 1.                    "numbers, not stored in PAYR
    pcec-checf = 'TEST000000001'.
    pcec-chect = 'TEST999999999'.
    pcec-fstap = 0.
    pcec-checl = space.

  ENDIF.

ENDFORM.                               "Scheckdaten prÃ¼fen



*----------------------------------------------------------------------*
* FORM SCHECKINFO_PRUEFEN                                              *
*----------------------------------------------------------------------*
* PrÃ¼fen, ob die Belegnummer bereits in PAYR gespeichert ist           *
* test that payment document number is already stored in PAYR          *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM scheckinfo_pruefen.

  IF t042z-xnopo NE space.             "keine ZahlungsauftrÃ¤ge erlaubt
    IF sy-batch EQ space.              "im Scheckmanagement
      MESSAGE a071(f3).                "payment orders are not allowed
    ELSE.                              "in the check management
      MESSAGE s071(f3).
      MESSAGE s549(fs).
      flg_selektiert = 0.
      STOP.
    ENDIF.
  ENDIF.

  CLEAR payr.
  CHECK:
    par_zdru NE space,                 "nur bei Scheckdruck
                                       "only if checks are to be printed
    zw_xvorl EQ space,                 "nur bei Echtlauf
                                       "only after production run
  flg_pruefung EQ 1.                   "nicht beim 'Schecks neu drucken'
  "not in transaction reprint check
  IF hlp_laufk NE 'P'.                 "FI-Beleg vorhanden?
    SELECT * FROM payr
      WHERE zbukr EQ reguh-zbukr
      AND   vblnr EQ reguh-vblnr
      AND   gjahr EQ regud-gjahr
      AND   voidr EQ 0.
    ENDSELECT.
    sy-msgv1 = reguh-zbukr.
    sy-msgv2 = regud-gjahr.
    sy-msgv3 = reguh-vblnr.
  ELSE.                                "HR-Abrechnung vorhanden?
    IF flg_neud NE 1.
      IF reguh-rwbtr EQ 0.                "PrÃ¼fung des Grundes fÃ¼r ZeroNet
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*SELECT * FROM tvoid WHERE sytyp EQ 4.
SELECT * FROM TVOID WHERE SYTYP EQ 4 ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
          EXIT.                          "Test that void reason code for
        ENDSELECT.                       "zero net checks exists
        IF sy-subrc NE 0.
          IF sy-batch EQ space.
            MESSAGE a669(fs).
          ELSE.
            MESSAGE s669(fs).
            MESSAGE s549(fs).
            flg_selektiert = 0.
            STOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT reguh-seqnr IS INITIAL.
      SELECT * FROM payr
      WHERE pernr EQ reguh-pernr
      AND   seqnr EQ reguh-seqnr
      AND   btznr EQ reguh-btznr
      AND   voidr EQ 0.
      ENDSELECT.
    ELSE.                              "HR-Sonderfall Stammdatenabschlag
      SELECT * FROM payr
        WHERE pernr EQ reguh-pernr
        AND   seqnr EQ reguh-seqnr
        AND   btznr EQ reguh-btznr
        AND   zaldt EQ reguh-zaldt
        AND   rwbtr EQ reguh-rwbtr
        AND   waers EQ reguh-waers
        AND   voidr EQ 0.
      ENDSELECT.
    ENDIF.
    sy-msgv1 = reguh-pernr.
    sy-msgv2 = reguh-seqnr.
    sy-msgv3 = reguh-btznr.
  ENDIF.

  IF flg_restart NE 0.
    IF NOT payr-chect IN tab_check.
      REJECT.
    ENDIF.
    IF sy-subrc NE 0.                  "Scheck nicht vorhanden
      IF sy-batch EQ space.            "check does not exist
        MESSAGE a564(fs) WITH sy-msgv1 sy-msgv2 sy-msgv3.
      ELSE.
        MESSAGE s564(fs) WITH sy-msgv1 sy-msgv2 sy-msgv3.
        MESSAGE s549(fs).
        flg_selektiert = 0.
        STOP.
      ENDIF.
    ENDIF.
  ELSEIF flg_neud EQ 1.                "soll Scheck neu gedruckt werden?
    IF NOT payr-chect IN tab_check.    "is this check to be reprinted?
      REJECT.
    ELSE.
       *payr = payr.
    ENDIF.
  ELSE.
    IF sy-subrc EQ 0.                  "Scheck bereits vorhanden
      "check does exist
      CALL FUNCTION 'READ_CUSTOMIZED_MESSAGE'
        EXPORTING
          i_arbgb = 'FS'
          i_dtype = 'A'
          i_msgnr = '670'
        IMPORTING
          e_msgty = sy-msgty.
      IF sy-msgty EQ 'A'.
        IF sy-batch EQ space.
          MESSAGE a670(fs) WITH sy-msgv1 sy-msgv2 sy-msgv3.
        ELSE.
          MESSAGE s670(fs) WITH sy-msgv1 sy-msgv2 sy-msgv3.
          MESSAGE s549(fs).
          flg_selektiert = 0.
          STOP.
        ENDIF.
      ELSE.
        fimsg-msgid = 'FS'.
        fimsg-msgv1 = sy-msgv1.
        fimsg-msgv2 = sy-msgv2.
        fimsg-msgv3 = sy-msgv3.
        PERFORM message USING 670.
        REJECT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               "Scheckinfo prÃ¼fen



*----------------------------------------------------------------------*
* FORM SCHECKNUMMERN_SPERREN                                           *
*----------------------------------------------------------------------*
* Sperren des zu druckenden Schecknummernbereichs                      *
* enqueue check numbers                                                *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM schecknummern_sperren.

  DATA:
    up_stapl     LIKE pcec-stapl,
    up_answer(1) TYPE c,
    up_subrc     LIKE sy-subrc.

  CHECK zw_xvorl EQ space.             "nur bei Echtlauf
  "only after production run
  IF flg_restart EQ 0.                 "nur ohne Restart
    "only without restart mode
    up_stapl = pcec-stapl.
    DO.
      CALL FUNCTION 'ENQUEUE_EFPCEC'
        EXPORTING
          zbukr    = pcec-zbukr
          hbkid    = pcec-hbkid
          hktid    = pcec-hktid
          stapl    = pcec-stapl
          _wait    = 'X'
          _collect = 'X'.
      IF pcec-fstap IS INITIAL.
        EXIT.
      ENDIF.
      SELECT SINGLE * FROM pcec
                      WHERE zbukr EQ pcec-zbukr
                        AND hbkid EQ pcec-hbkid
                        AND hktid EQ pcec-hktid
                        AND stapl EQ pcec-fstap.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
    ENDDO.
    pcec-stapl = up_stapl.
    DO.
      CALL FUNCTION 'FLUSH_ENQUEUE'
        EXCEPTIONS
          foreign_lock = 8.
      up_subrc = sy-subrc.
      IF up_subrc EQ 0 OR sy-batch NE space.
        EXIT.
      ENDIF.
      SET EXTENDED CHECK OFF.
      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
        EXPORTING
          diagnosetext1 = text-900
          diagnosetext2 = sy-msgv1
          diagnosetext3 = text-901
          textline1     = text-902
          textline2     = text-903
          titel         = text-904
        IMPORTING
          answer        = up_answer.
      IF up_answer NE 'J'.
        EXIT.
      ENDIF.
      SET EXTENDED CHECK ON.
    ENDDO.
    IF up_subrc NE 0.                  "Nummern sind durch anderen
      IF sy-batch EQ space.            "Benutzer gesperrt
        PERFORM scheckdruck_mail.      "numbers are locked by
        MESSAGE a536(fs) WITH sy-msgv1."another user
      ELSE.
        MESSAGE s536(fs) WITH sy-msgv1.
        MESSAGE s549(fs).
        STOP.
      ENDIF.
    ELSE.
      CALL FUNCTION 'LOT_CHECK'
        EXPORTING
          i_zbukr = pcec-zbukr
          i_hbkid = pcec-hbkid
          i_hktid = pcec-hktid
          i_stapl = pcec-stapl
        IMPORTING
          e_stapl = pcec-stapl
        EXCEPTIONS
          OTHERS  = 4.
      IF sy-subrc NE 0.
        IF zw_laufi+5(1) EQ '*'.
          PERFORM scheckdruck_mail.
          fimsg-msgno = sy-msgno.
          fimsg-msgv1 = sy-msgv1.
          MESSAGE a577(fs) WITH fimsg-msgno fimsg-msgv1.
        ELSE.
          MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH sy-msgv1.
        ENDIF.
      ENDIF.
      SELECT SINGLE * FROM pcec
        WHERE zbukr = pcec-zbukr
        AND   hbkid = pcec-hbkid
        AND   hktid = pcec-hktid
        AND   stapl = pcec-stapl.
    ENDIF.
    IF sy-batch NE space.
      MESSAGE s550(fs) WITH pcec-checl."Ausgabe des Nummernstandes
    ENDIF.                             "print last check number
    "assigned
  ENDIF.
  IF flg_restart NE 0 OR
     flg_neud    NE 0.
    DO.
      CALL FUNCTION 'ENQUEUE_EFPAYR'
        EXPORTING
          zbukr        = pcec-zbukr
          hbkid        = pcec-hbkid
          hktid        = pcec-hktid
          _wait        = 'X'
        EXCEPTIONS
          foreign_lock = 8.
      up_subrc = sy-subrc.
      IF up_subrc EQ 0 OR sy-batch NE space.
        EXIT.
      ENDIF.
      SET EXTENDED CHECK OFF.
      CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
        EXPORTING
          diagnosetext1 = text-900
          diagnosetext2 = sy-msgv1
          diagnosetext3 = text-901
          textline1     = text-902
          textline2     = text-903
          titel         = text-904
        IMPORTING
          answer        = up_answer.
      IF up_answer NE 'J'.
        EXIT.
      ENDIF.
      SET EXTENDED CHECK ON.
    ENDDO.
    IF up_subrc NE 0.                  "ZahlungstrÃ¤gerdatei ist durch
      IF sy-batch EQ space.            "anderen Benutzer gesperrt
        PERFORM scheckdruck_mail.      "payment register is locked by
        MESSAGE a556(fs) WITH sy-msgv1."another user
      ELSE.
        MESSAGE s556(fs) WITH sy-msgv1.
        MESSAGE s549(fs).
        STOP.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               "Schecknummern sperren



*----------------------------------------------------------------------*
* FORM SCHECKNUMMER_ERMITTELN                                          *
*----------------------------------------------------------------------*
* Erste, nÃ¤chste bzw. letzte Schecknummer ermitteln                    *
* find out first, next or last check number                            *
*----------------------------------------------------------------------*
* TYP = 1   erster benutzter Scheck                                    *
*           first used check                                           *
*       2   Scheck (bei SeitenÃ¼berlauf nur die erste Seite)            *
*           check (only first page when overflow)                      *
*       3   FormularabschluÃŸ                                           *
*           summary                                                    *
*----------------------------------------------------------------------*
FORM schecknummer_ermitteln USING typ.

  IF flg_restart EQ 0.                 "kein Restart
    "no restart
    IF pcec-checl IS INITIAL.
      regud-checf = pcec-checf.        "Start mit neuem Stapel
      regud-stapf = pcec-stapl.        "start with a new lot
      regud-chect = pcec-checf.
      regud-stapt = pcec-stapl.
       *pcec = pcec.
    ELSE.
      CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
        EXPORTING
          i_pcec = pcec
          i_n    = 1
        IMPORTING
          e_pcec = *pcec.
      IF typ EQ 1.
        regud-checf = *pcec-checl.     "erste Schecknummer
        regud-stapf = *pcec-stapl.     "first check number
        regud-chect = *pcec-checl.
        regud-stapt = *pcec-stapl.
      ELSE.
        regud-chect = *pcec-checl.     "nÃ¤chste/letzte Schecknummer
        regud-stapt = *pcec-stapl.     "next/last check number
      ENDIF.
    ENDIF.
    IF *pcec-zwels NE space AND *pcec-zwels NA reguh-rzawe.
      IF sy-batch EQ space.
        MESSAGE a665(fs) WITH reguh-rzawe *pcec-stapl *pcec-zwels.
      ELSE.
        MESSAGE s665(fs) WITH reguh-rzawe *pcec-stapl *pcec-zwels.
        MESSAGE s549(fs).
        STOP.
      ENDIF.
    ENDIF.

  ELSE.                                "Restart

    IF typ EQ 1.
      CALL FUNCTION 'GET_CHECK_INTERVAL'
        EXPORTING
          i_zbukr = zw_zbukr-low
          i_hbkid = sel_hbki-low
          i_hktid = sel_hkti-low
          i_check = hlp_checf_restart
        IMPORTING
          e_pcec  = pcec.
      pcec-checl  = hlp_checf_restart.
      regud-checf = pcec-checl.        "erste Schecknummer
      regud-stapf = pcec-stapl.        "first check number
      regud-chect = pcec-checl.
      regud-stapt = pcec-stapl.
    ELSE.
      IF hlp_laufk NE 'P'.             "FI-Beleg vorhanden
        SELECT * FROM payr             "Scheck zum Zahlungsbeleg
          WHERE zbukr EQ reguh-zbukr   "payment document's check
          AND   vblnr EQ reguh-vblnr
          AND   gjahr EQ regud-gjahr
          AND   voidr EQ 0.
        ENDSELECT.
      ELSE.                            "HR-Abrechnung vorhanden
        IF NOT reguh-seqnr IS INITIAL.
          SELECT * FROM payr
          WHERE pernr EQ reguh-pernr
          AND   seqnr EQ reguh-seqnr
          AND   btznr EQ reguh-btznr
          AND   voidr EQ 0.
          ENDSELECT.
        ELSE.                          "HR-Sonderfall Stammdatenabschlag
          SELECT * FROM payr
            WHERE pernr EQ reguh-pernr
            AND   seqnr EQ reguh-seqnr
            AND   btznr EQ reguh-btznr
            AND   zaldt EQ reguh-zaldt
            AND   rwbtr EQ reguh-rwbtr
            AND   waers EQ reguh-waers
            AND   voidr EQ 0.
          ENDSELECT.
        ENDIF.
      ENDIF.
      IF typ EQ 2 AND payr-checv NE space.
        IF payr-checv NE '*'.
          SELECT * FROM payr
            WHERE zbukr EQ payr-zbukr
            AND   hbkid EQ payr-hbkiv
            AND   hktid EQ payr-hktiv
            AND   rzawe EQ payr-rzawe
            AND   chect EQ payr-checv
            AND   voidr EQ 2.
            EXIT.
          ENDSELECT.
        ELSE.
          CALL FUNCTION 'GET_CHECK_INTERVAL'
            EXPORTING
              i_check = payr-chect
              i_hbkid = payr-hbkid
              i_hktid = payr-hktid
              i_zbukr = payr-zbukr
            IMPORTING
              e_pcec  = pcec.

*         The check might not be last one printed from the lot
          pcec-checl = payr-chect.

          CALL FUNCTION 'SUBTRACT_N_FROM_CHECK_NUMBER'
            EXPORTING
              i_pcec      = pcec
            IMPORTING
              e_pcec      = pcec
            EXCEPTIONS
              not_filled  = 1
              not_found   = 2
              not_numeric = 3
              not_valid   = 4
              OTHERS      = 5.
          IF sy-subrc EQ 0.
            SELECT SINGLE * FROM payr
               WHERE zbukr EQ payr-zbukr
                 AND hbkid EQ payr-hbkid
                 AND hktid EQ payr-hktid
                 AND rzawe EQ payr-rzawe
                 AND chect EQ pcec-checl
                 AND voidr EQ 2.
          ENDIF.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'GET_CHECK_INTERVAL'
        EXPORTING                   "zugehÃ¶riger Stapel
          i_zbukr = zw_zbukr-low "accompanying lot
          i_hbkid = sel_hbki-low
          i_hktid = sel_hkti-low
          i_check = payr-checf
        IMPORTING
          e_pcec  = pcec.
      pcec-checl = payr-checf.
      IF typ EQ 2 AND flg_restart NE 2.
        CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
          EXPORTING
            i_pcec = pcec
            i_n    = par_anzp
          IMPORTING
            e_pcec = pcec.
      ENDIF.
      IF typ EQ 3.
        CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
          EXPORTING                 "nÃ¤chster Scheck=FormularabschluÃŸ
            i_pcec = pcec        "next check=summary
            i_n    = 1
          IMPORTING
            e_pcec = pcec.
        IF flg_restart NE 2 AND par_anzp NE 0.
          PERFORM schecks_umnumerieren.
        ENDIF.
      ENDIF.
      regud-chect = pcec-checl.        "nÃ¤chste/letzte Schecknummer
      regud-stapt = pcec-stapl.        "next/last check number
    ENDIF.

  ENDIF.


  hlp_seite = '1'.

ENDFORM.                               "Schecknummer ermitteln



*----------------------------------------------------------------------*
* FORM SCHECKAVIS_ZEILE                                                *
*----------------------------------------------------------------------*
* Schreiben einer Zeile des Avis zum Scheck                            *
* Write one line of the remittance advice of the check                 *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM scheckavis_zeile.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element  = hlp_ep_element
      function = 'APPEND'
    EXCEPTIONS
      window   = 1
      element  = 2.
  IF sy-subrc EQ 2.
    err_element-fname = t042e-zforn.
    err_element-fenst = 'MAIN'.
    err_element-elemt = hlp_ep_element.
    err_element-text  = text_525.
    COLLECT err_element.
  ENDIF.

* Vornumerierte Schecks: Schecknummer hochzÃ¤hlen ab 2.Seite
* prenumbered checks: add 1 to check number
  IF flg_schecknum EQ 1.
    CALL FUNCTION 'GET_TEXTSYMBOL'
      EXPORTING
        line         = '&PAGE&'
        start_offset = 0
      IMPORTING
        value        = hlp_page.
    IF hlp_page NE hlp_seite.
      hlp_seite = hlp_page.
      PERFORM schecknummer_addieren.
    ENDIF.
  ENDIF.

ENDFORM.                               "Scheckavis Zeile



*----------------------------------------------------------------------*
* FORM SCHECKNUMMER_ADDIEREN                                           *
*----------------------------------------------------------------------*
* Werden zu einem Scheck mehrere Seiten gedruckt (Probedruck oder      *
* SeitenÃ¼berlauf), so wird ab Seite 2 mit dieser Routine hochgezÃ¤hlt   *
* If one check has more than 1 page (test or overflow), this routine   *
* computes the current check number                                    *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM schecknummer_addieren.

   *pcec = pcec.
  IF pcec-checl EQ space.              "neuer Stapel / new lot
     *pcec-checl = *pcec-checf.
    hlp_page    = hlp_page - 1.
  ELSEIF flg_restart NE 0.             "Restart
    hlp_page    = hlp_page - 1.
  ENDIF.
  CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
    EXPORTING
      i_pcec = *pcec
      i_n    = hlp_page
    IMPORTING
      e_pcec = *pcec.
  regud-chect = *pcec-checl.           "nÃ¤chste Schecknummer
  regud-stapt = *pcec-stapl.           "next check number

ENDFORM.                               "Schecknummer addieren



*----------------------------------------------------------------------*
* FORM SCHECKS_UMNUMERIEREN                                            *
*----------------------------------------------------------------------*
* Umnumerieren, wenn beim Restart, der nicht alle Schecks neu druckt,  *
* Probedrucke angegeben worden sind                                    *
* renumber, if in restart mode test prints are wished and not all      *
* checks are to be reprinted                                           *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM schecks_umnumerieren.
  DATA: up_mode TYPE c.

  DATA up_bdc LIKE bdcdata OCCURS 9 WITH HEADER LINE.

  CLEAR up_bdc.
  up_bdc-program  = 'SAPMFCHK'.
  up_bdc-dynpro   = '400'.
  up_bdc-dynbegin = 'X'.
  APPEND up_bdc.
  CLEAR up_bdc.
  up_bdc-fnam     = 'PAYR-ZBUKR'.
  up_bdc-fval     = zw_zbukr-low.
  APPEND up_bdc.
  CLEAR up_bdc.
  up_bdc-fnam     = 'PAYR-HBKID'.
  up_bdc-fval     = sel_hbki-low.
  APPEND up_bdc.
  CLEAR up_bdc.
  up_bdc-fnam     = 'PAYR-HKTID'.
  up_bdc-fval     = sel_hkti-low.
  APPEND up_bdc.
  CLEAR up_bdc.
  up_bdc-fnam     = 'PAYR-CHECF'.
  up_bdc-fval     = hlp_checf_restart.
  APPEND up_bdc.
  CLEAR up_bdc.
  up_bdc-fnam     = 'PAYR-CHECT'.
  up_bdc-fval     = pcec-checl.
  APPEND up_bdc.
  CLEAR up_bdc.
  up_bdc-fnam     = 'PAYR-VOIDR'.
  up_bdc-fval     = '01'.
  APPEND up_bdc.
  CALL FUNCTION 'GET_CHECK_INTERVAL'
    EXPORTING
      i_zbukr = zw_zbukr-low
      i_hbkid = sel_hbki-low
      i_hktid = sel_hkti-low
      i_check = hlp_checf_restart
    IMPORTING
      e_pcec  = *pcec.
   *pcec-checl   = hlp_checf_restart.
  CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
    EXPORTING
      i_pcec = *pcec
      i_n    = par_anzp
    IMPORTING
      e_pcec = *pcec.
  CLEAR up_bdc.
  up_bdc-fnam     = 'PCEC-CHECF'.
  up_bdc-fval     = *pcec-checl.
  APPEND up_bdc.
  CLEAR up_bdc.
  up_bdc-fnam     = 'BDC_OKCODE'.
  up_bdc-fval     = '/18'.
  APPEND up_bdc.

*kurzfristig entsperren, da die Sperre in FCH4 gesetzt wird
*  IF PAR_NENQ EQ SPACE.
  PERFORM schecknummern_entsperren.                         "RFFORI01
*  ENDIF.
  up_mode = 'N'.
  CALL TRANSACTION 'FCH4' USING up_bdc MODE up_mode.
  MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  pcec-checl = sy-msgv4.

ENDFORM.                               "Schecks umnumerieren



*----------------------------------------------------------------------*
* FORM SCHECKINFO_SPEICHERN                                            *
*----------------------------------------------------------------------*
* Speichern der Scheckinformationen in PAYR und                        *
* aktualisieren des Schecknummernstandes in PCEC                       *
* store check information in PAYR and update the                       *
* last used number in PCEC                                             *
*----------------------------------------------------------------------*
* TYP = 1   Probedrucke                                                *
*           test print                                                 *
*       2   Schecks, evtl. mit Ãœberlauf                                *
*           checks, perhaps with overflow                              *
*       3   FormularabschluÃŸ                                           *
*           summary                                                    *
*----------------------------------------------------------------------*
FORM scheckinfo_speichern USING typ.

  CHECK flg_restart EQ 0.              "nicht im Restartfall
  "not in restart mode
  DATA:
    up_checf LIKE payr-checf,          "Nummern der bedruckten Schecks
    up_chect LIKE payr-chect,          "numbers of printed checks
    up_checv LIKE payr-checv.

* Nummern der bedruckten Schecks berechnen
* compute numbers of printed checks
  IF pcec-checl IS INITIAL.            "Start mit neuem Stapel
    pcec-checl = pcec-checf.           "start with a new lot
  ELSE.
    CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
      EXPORTING
        i_pcec = pcec
        i_n    = 1
      IMPORTING
        e_pcec = pcec.
  ENDIF.
  up_checf = pcec-checl.
  IF cnt_seiten GT 1.
    cnt_seiten = cnt_seiten - 1.
    CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
      EXPORTING
        i_pcec = pcec
        i_n    = cnt_seiten
      IMPORTING
        e_pcec = pcec.
    cnt_seiten = cnt_seiten + 1.
  ENDIF.
  up_chect = pcec-checl.

  IF zw_xvorl EQ space.                "Echtlauf (PAYR und PCEC updaten)
    "production run

*   PrÃ¼fen, ob Eintrag bereits in PAYR vorhanden ist
*   test that entry does not already exist in PAYR
    SELECT * FROM payr
      WHERE ichec EQ space
        AND zbukr EQ pcec-zbukr
        AND hbkid EQ pcec-hbkid
        AND hktid EQ pcec-hktid
        AND chect EQ up_chect.
    ENDSELECT.
    IF sy-subrc EQ 0.                  "Schecknummer bereits vorhanden
      CALL FUNCTION 'CLOSE_FORM'.      "check number already exists
      ROLLBACK WORK.
      fimsg-msgid = 'FS'.
      fimsg-msgv1 = pcec-zbukr.
      fimsg-msgv2 = pcec-hbkid.
      fimsg-msgv3 = pcec-hktid.
      fimsg-msgv4 = up_chect.
      PERFORM message USING 552.
      fimsg-msgid = 'FS'.
      PERFORM message USING 549.
      PERFORM fehlermeldungen.
      PERFORM information.
      IF sy-batch EQ space.
        MESSAGE i552(fs)
          WITH pcec-zbukr pcec-hbkid pcec-hktid up_chect.
      ENDIF.
      STOP.
    ENDIF.

*   PAYR fÃ¼llen und Scheckinfo abspeichern
*   fill PAYR and store check information
    CLEAR payr.
    payr-mandt = sy-mandt.
    payr-zbukr = pcec-zbukr.
    payr-hbkid = pcec-hbkid.
    payr-hktid = pcec-hktid.
    payr-rzawe = reguh-rzawe.
    payr-laufd = zw_laufd.
    payr-laufi = zw_laufi.
    payr-pridt = sy-datlo.
    payr-priti = sy-timlo.
    payr-prius = sy-uname.
    CASE typ.

*     Probedrucke
*     test prints
      WHEN 1.
        payr-checf = up_checf.
        payr-chect = up_chect.
        payr-voidr = 1.
        payr-voidd = sy-datlo.
        payr-voidu = sy-uname.
        CALL FUNCTION 'VOID_CHECKS'
          EXPORTING
            i_payr = payr.

*     Schecks, evtl. mit Ãœberlauf
*     checks, perhaps with overflow
      WHEN 2.
        IF cnt_seiten GT 1.            "Ãœberlauf
          payr-checv = pcec-checl.     "overflow
          payr-hbkiv = pcec-hbkid.
          payr-hktiv = pcec-hktid.
          CALL FUNCTION 'SUBTRACT_N_FROM_CHECK_NUMBER'
            EXPORTING
              i_pcec = pcec
              i_n    = 1
            IMPORTING
              e_pcec = pcec.
          payr-checf = up_checf.
          payr-chect = pcec-checl.
          payr-voidr = 2.
          payr-voidd = sy-datlo.
          payr-voidu = sy-uname.
          CALL FUNCTION 'VOID_CHECKS'
            EXPORTING
              i_payr  = payr
            IMPORTING
              e_checv = up_checv.
          CLEAR payr.                  "Vorbereitung fÃ¼r echten Scheck
          payr-checv = up_checv.       "mit RÃ¼ckverweis zum entwerteten
          payr-hbkiv = pcec-hbkid.     "Scheck
          payr-hktiv = pcec-hktid.     "prepare genuine check
          CALL FUNCTION 'ADD_N_TO_CHECK_NUMBER'
            EXPORTING
              i_pcec = pcec
              i_n    = 1
            IMPORTING
              e_pcec = pcec.
        ENDIF.
        MOVE-CORRESPONDING reguh TO payr.
        IF hlp_laufk EQ 'P'.
          payr-vblnr = space.
          payr-kunnr = space.
          payr-lifnr = space.
        ENDIF.
        IF payr-rwbtr EQ 0.            "zero net check with special
          IF tvoid-sytyp NE 4.         "void reason code
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
*SELECT * FROM tvoid WHERE sytyp EQ 4.
SELECT * FROM TVOID WHERE SYTYP EQ 4 ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES02 ECDK917080 *
              EXIT.
            ENDSELECT.
          ENDIF.
          payr-voidr = tvoid-voidr.
          payr-voidd = sy-datlo.
          payr-voidu = sy-uname.
        ENDIF.
        payr-strgb = reguh-srtgb.
        payr-gjahr = regud-gjahr.
        payr-rwbtr = - payr-rwbtr.
        payr-rwskt = - payr-rwskt.
        payr-checf = up_chect.
        payr-chect = up_chect.
        payr-pridt = sy-datlo.
        payr-priti = sy-timlo.
        payr-prius = sy-uname.
        tab_uebergreifend-zbukr = reguh-zbukr.
        tab_uebergreifend-vblnr = reguh-vblnr.
        READ TABLE tab_uebergreifend.
        IF sy-subrc EQ 0.
          payr-xbukr = 'X'.
        ELSE.
          payr-xbukr = space.
        ENDIF.
        IF flg_neud EQ 1.
          IF payr-checv NE space OR *payr-checv NE space.
            payr-checv = '*'.
          ENDIF.
        ENDIF.
        INSERT payr.
        UPDATE pcec.

*       Schecknummer merken fÃ¼r das Avis
*       memorize check number for advice printing
        tab_schecks-zbukr = reguh-zbukr.
        tab_schecks-vblnr = reguh-vblnr.
        tab_schecks-chect = payr-chect.
        APPEND tab_schecks.


        CASE flg_neud.

*         Beim Neudruck alten Scheck entwerten
*         void old check in reprint mode
          WHEN 1.
            PERFORM scheck_entwerten.
            IF payr-checv EQ space.
              payr-hbkiv = *payr-hbkid.
              payr-hktiv = *payr-hktid.
              payr-checv = *payr-chect.
            ENDIF.
            UPDATE payr.

*         Beim Neudruck ohne Angabe von Schecks alle Kandidaten
*         entwerten (sofern nicht bereits geschehen) und verweisen
*         void all relevant checks if no check numbers were specified
*         on the selection screen and set pointer to new check
          WHEN 2.
            IF hlp_laufk NE 'P'.
              SELECT * FROM payr INTO *payr
                WHERE zbukr EQ payr-zbukr
                AND   vblnr EQ payr-vblnr
                AND   gjahr EQ payr-gjahr
                AND ( hbkid NE payr-hbkid
                   OR hktid NE payr-hktid
                   OR chect NE payr-chect ).
                PERFORM scheck_entwerten.
              ENDSELECT.
            ELSE.
              SELECT * FROM payr INTO *payr
                WHERE pernr EQ reguh-pernr
                AND   seqnr EQ reguh-seqnr
                AND   btznr EQ reguh-btznr
                AND   zaldt EQ reguh-zaldt
                AND   rwbtr EQ reguh-rwbtr
                AND   waers EQ reguh-waers
                AND ( zbukr NE payr-zbukr
                   OR hbkid NE payr-hbkid
                   OR hktid NE payr-hktid
                   OR chect NE payr-chect ).
                PERFORM scheck_entwerten.
              ENDSELECT.
            ENDIF.
            IF sy-dbcnt NE 0.
              IF sy-dbcnt EQ 1 AND payr-checv EQ space.
                payr-hbkiv = *payr-hbkid.
                payr-hktiv = *payr-hktid.
                payr-checv = *payr-chect.
              ELSE.
                payr-checv = '*'.
              ENDIF.
              UPDATE payr.
            ENDIF.
        ENDCASE.

*     FormularabschluÃŸ
*     summary
      WHEN 3.
        payr-checf = up_checf.
        payr-chect = up_chect.
        payr-voidr = 3.
        payr-voidd = sy-datlo.
        payr-voidu = sy-uname.
        CALL FUNCTION 'VOID_CHECKS'
          EXPORTING
            i_payr = payr.
    ENDCASE.

    CALL FUNCTION 'DB_COMMIT'.

  ENDIF.

ENDFORM.                               "Scheckinfo speichern



*----------------------------------------------------------------------*
* FORM SCHECK_ENTWERTEN                                                *
*----------------------------------------------------------------------*
* Entwerten der alten Schecks bei Neudruck und Verweis zum neuen Scheck*
* Void old checks in reprint mode and set pointer to new check         +
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM scheck_entwerten.

  IF *payr-checv NE space.
    IF *payr-checv NE '*'.
      UPDATE payr SET hbkiv = payr-hbkid
                      hktiv = payr-hktid
                      checv = payr-chect
                WHERE zbukr EQ *payr-zbukr
                  AND hbkid EQ *payr-hbkiv
                  AND hktid EQ *payr-hktiv
                  AND rzawe EQ *payr-rzawe
                  AND chect EQ *payr-checv.
    ELSE.
      UPDATE payr SET hbkiv = payr-hbkid
                      hktiv = payr-hktid
                      checv = payr-chect
                WHERE zbukr EQ *payr-zbukr
                  AND hbkid EQ *payr-hbkid
                  AND hktid EQ *payr-hktid
                  AND rzawe EQ *payr-rzawe
                  AND checv EQ *payr-chect.
    ENDIF.
    payr-checv = '*'.
  ENDIF.
   *payr-hbkiv   = payr-hbkid.
   *payr-hktiv   = payr-hktid.
   *payr-checv   = payr-chect.
  IF *payr-voidr EQ 0.
     *payr-voidr = tvoid-voidr.
  ENDIF.
   *payr-voidd   = sy-datlo.
   *payr-voidu   = sy-uname.
   *payr-extrd   = 0.
   *payr-extrt   = 0.
  UPDATE *payr.

ENDFORM.                               "Scheck entwerten



*----------------------------------------------------------------------*
* FORM SCHECKNUMMERN_ENTSPERREN                                        *
*----------------------------------------------------------------------*
* Entsperren des gedruckten Schecknummernbereichs                      *
* dequeue check numbers                                                +
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM schecknummern_entsperren.

  CHECK zw_xvorl EQ space.             "nur bei Echtlauf
  "only after production run
  CALL FUNCTION 'DEQUEUE_ALL'.

ENDFORM.                               "Schecknummern entsperren



*----------------------------------------------------------------------*
* FORM SCHECKDRUCK_MAIL                                                *
*----------------------------------------------------------------------*
* Im Online-Scheckdruck wird ein Mail versendet, wenn der Druck        *
* nicht erfolgreich war                                                *
* Using post + print the user will get a mail if the print was not     *
* successfull                                                          *
*----------------------------------------------------------------------*
* keine USING-Parameter                                                *
* no USING-parameters                                                  *
*----------------------------------------------------------------------*
FORM scheckdruck_mail.

  CHECK sy-tcode EQ 'FBZ4'.

  DATA BEGIN OF up_object_hd_change.
          INCLUDE STRUCTURE sood1.
  DATA END OF up_object_hd_change.
  DATA BEGIN OF up_user.
          INCLUDE STRUCTURE soud3.
  DATA END OF up_user.
  DATA BEGIN OF up_objcont OCCURS 10.
          INCLUDE STRUCTURE soli.
  DATA END OF up_objcont.
  DATA BEGIN OF up_objhead OCCURS 1.
          INCLUDE STRUCTURE soli.
  DATA END OF up_objhead.
  DATA BEGIN OF up_objpara OCCURS 10.
          INCLUDE STRUCTURE selc.
  DATA END OF up_objpara.
  DATA BEGIN OF up_objparb OCCURS 1.
          INCLUDE STRUCTURE soop1.
  DATA END OF up_objparb.
  DATA BEGIN OF up_receivers OCCURS 1.
          INCLUDE STRUCTURE soos1.
  DATA END OF up_receivers.

  CLEAR:
    up_object_hd_change,
    up_user,
    up_objcont,
    up_objhead,
    up_objpara,
    up_objparb,
    up_receivers.
  REFRESH:
    up_objcont,
    up_objhead,
    up_objpara,
    up_objparb,
    up_receivers.

  SET EXTENDED CHECK OFF.
  up_object_hd_change-objla  = sy-langu.
  up_object_hd_change-objnam = text-910.
  up_object_hd_change-objdes = text-911.
  up_object_hd_change-objsns = 'F'.
  up_object_hd_change-vmtyp  = 'T'.
  up_object_hd_change-acnam  = 'FBZ5'.
  up_user-sapnam             = sy-uname.
  CALL FUNCTION 'SO_NAME_CONVERT'
    EXPORTING
      name_in  = up_user
    IMPORTING
      name_out = up_user
    EXCEPTIONS
      OTHERS   = 8.
  IF sy-subrc NE 0.
    up_user-usrnam           = sy-uname.
  ENDIF.
  up_objcont-line            = space.          APPEND up_objcont.
  up_objcont-line            = text-912.       APPEND up_objcont.
  up_objcont-line            = text-913.       APPEND up_objcont.
  up_objcont-line            = space.          APPEND up_objcont.
  up_objcont-line            = text-914.
  GET PARAMETER ID 'BUK' FIELD reguh-zbukr.DATA: v_acum(1).
  GET PARAMETER ID 'BLN' FIELD reguh-vblnr.
  IF regud-gjahr EQ 0.
    GET PARAMETER ID 'GJR' FIELD regud-gjahr.
  ENDIF.
  REPLACE '&' WITH:
    reguh-vblnr INTO up_object_hd_change-objdes,
    reguh-zbukr INTO up_objcont-line,
    reguh-vblnr INTO up_objcont-line,
    regud-gjahr INTO up_objcont-line.
  APPEND up_objcont.
  up_objcont-line            = space.          APPEND up_objcont.
  up_objcont-line            = text-915.       APPEND up_objcont.
  up_objcont-line            = text-916.       APPEND up_objcont.
  up_objpara-name            = 'GJR'.
  up_objpara-low             = regud-gjahr.    APPEND up_objpara.
  up_objpara-name            = 'BLN'.
  up_objpara-low             = reguh-vblnr.    APPEND up_objpara.
  up_receivers-recnam        = up_user-usrnam.
  up_receivers-acall         = 'X'.
  up_receivers-sndex         = 'X'.            APPEND up_receivers.
  SET EXTENDED CHECK ON.

  CALL FUNCTION 'SO_OBJECT_SEND'
    EXPORTING
      object_hd_change = up_object_hd_change
      object_type      = 'RAW'
      owner            = up_user-usrnam
    TABLES
      objcont          = up_objcont
      objhead          = up_objhead
      objpara          = up_objpara
      objparb          = up_objparb
      receivers        = up_receivers
    EXCEPTIONS
      OTHERS           = 4.
  COMMIT WORK.

ENDFORM.                               "Scheckdruck Mail

*&---------------------------------------------------------------------*
*&      Form  REVISA_STRING
*&---------------------------------------------------------------------*
FORM revisa_string USING p_string.
  DATA: var(1) VALUE 'X'.

  TRANSLATE p_string USING 'ÑN'.
  TRANSLATE p_string USING 'ñn'.

  TRANSLATE p_string USING 'ÁA'.
  TRANSLATE p_string USING 'áa'.
  TRANSLATE p_string USING 'ÉE'.
  TRANSLATE p_string USING 'ée'.
  TRANSLATE p_string USING 'ÍI'.
  TRANSLATE p_string USING 'íi'.
  TRANSLATE p_string USING 'ÓO'.
  TRANSLATE p_string USING 'óo'.
  TRANSLATE p_string USING 'ÚU'.
  TRANSLATE p_string USING 'úu'.

ENDFORM.                    " REVISA_STRING
