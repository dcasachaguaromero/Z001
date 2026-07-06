PROGRAM ZRGGBS000 .
*---------------------------------------------------------------------*
* Corrections/ repair
* wms092357 070703 Note 638886: template routines to be used for
*                  workaround to substitute bseg-bewar from bseg-xref1/2
*---------------------------------------------------------------------*
*                                                                     *
*   Substitutions: EXIT-Formpool for Uxxx-Exits                       *
*                                                                     *
*   This formpool is used by SAP for testing purposes only.           *
*                                                                     *
*   Note: If you define a new user exit, you have to enter your       *
*         user exit in the form routine GET_EXIT_TITLES.              *
*                                                                     *
*---------------------------------------------------------------------*
INCLUDE FGBBGD00.              "Standard data types


*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
*    PLEASE INCLUDE THE FOLLOWING "TYPE-POOL"  AND "TABLES" COMMANDS  *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM         *
TYPE-POOLS: GB002. " TO BE INCLUDED IN                       "wms092357
TABLES: BKPF,      " ANY SYSTEM THAT                         "wms092357
        BSEG,      " HAS 'FI' INSTALLED                      "wms092357
        COBL,                                               "wms092357
        CSKS,                                               "wms092357
        ANLZ,                                               "wms092357
        GLU1.                                               "wms092357
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*


*----------------------------------------------------------------------*
*       FORM GET_EXIT_TITLES                                           *
*----------------------------------------------------------------------*
*       returns name and title of all available standard-exits         *
*       every exit in this formpool has to be added to this form.      *
*       You have to specify a parameter type in order to enable the    *
*       code generation program to determine correctly how to          *
*       generate the user exit call, i.e. how many and what kind of    *
*       parameter(s) are used in the user exit.                        *
*       The following parameter types exist:                           *
*                                                                      *
*       TYPE                Description              Usage             *
*    ------------------------------------------------------------      *
*       C_EXIT_PARAM_NONE   Use no parameter         Subst. and Valid. *
*                           except B_RESULT                            *
*       C_EXIT_PARAM_FIELD  Use one field as param.  Only Substitution *
*       C_EXIT_PARAM_CLASS  Use a type as parameter  Subst. and Valid  *
*                                                                      *
*----------------------------------------------------------------------*
*  -->  EXIT_TAB  table with exit-name and exit-titles                 *
*                 structure: NAME(5), PARAM(1), TITEL(60)
*----------------------------------------------------------------------*
FORM GET_EXIT_TITLES TABLES ETAB.

  DATA: BEGIN OF EXITS OCCURS 50,
          NAME(5)   TYPE C,
          PARAM     LIKE C_EXIT_PARAM_NONE,
          TITLE(60) TYPE C,
        END OF EXITS.

  EXITS-NAME  = 'U100'.
  EXITS-PARAM = C_EXIT_PARAM_NONE.
  EXITS-TITLE = TEXT-100.             "Cost center from CSKS
  APPEND EXITS.

  EXITS-NAME  = 'U101'.
  EXITS-PARAM = C_EXIT_PARAM_FIELD.
  EXITS-TITLE = TEXT-101.             "Cost center from CSKS
  APPEND EXITS.

* begin of insertion                                          "wms092357
  EXITS-NAME  = 'U200'.
  EXITS-PARAM = C_EXIT_PARAM_FIELD.
  EXITS-TITLE = TEXT-200.             "Cons. transaction type
  APPEND EXITS.                       "from xref1/2
* end of insertion                                            "wms092357

* begin of insertion                                          "V1-20110823
  EXITS-NAME  = 'U201'.
  EXITS-PARAM = C_EXIT_PARAM_NONE.
  EXITS-TITLE = TEXT-201.             "MOdif. Clave Reval Area 05
  APPEND EXITS.                       "

* end of insertion                                            "V1-20110823

* begin of insertion                                          "V1-20190730
  EXITS-NAME  = 'U204'.
  EXITS-PARAM = C_EXIT_PARAM_NONE.
  EXITS-TITLE = TEXT-204.             "MOdif. Rut de tercero
  APPEND EXITS.                       "
* end of insertion                                            "V1-20190730

* ini - Waldo Alarcón - Visionone - 23-04-2020.
  exits-name  = 'U205'.
  exits-param = c_exit_param_none.                     "Complete data used in exit.
  exits-title = 'Compensación Bono cruzado'.           "Compensación Bono cruzado
  APPEND exits.
* fin - Waldo Alarcón - Visionone - 23-04-2020.

* begin of insertion                                          "V1-RVY-261021
  EXITS-NAME  = 'U206'.
  EXITS-PARAM = C_EXIT_PARAM_FIELD.
  EXITS-TITLE = TEXT-206.             "MOdif. Ceco con Cebe
  APPEND EXITS.                       "
* end of insertion                                            "V1-RVY-261021
* begin of insertion                                          "V1-RVY-300523
  EXITS-NAME  = 'U207'.
  EXITS-PARAM = C_EXIT_PARAM_FIELD.
  EXITS-TITLE = TEXT-207.             "MOdif. Texto posicion
  APPEND EXITS.                       "
* end of insertion                                            "V1-RVY-300523

*
************************************************************************************
************************** sustituciones BMSA***************************************
************************************************************************************
  EXITS-NAME  = 'U301'.
  EXITS-PARAM = C_EXIT_PARAM_NONE.
  EXITS-TITLE = TEXT-301.             "Area que contabiliza (XREF2_HD)
  APPEND EXITS.

  EXITS-NAME  = 'U302'.
  EXITS-PARAM =   c_exit_param_class.
  EXITS-TITLE = TEXT-302.             "Area que contabiliza (XREF2_HD)
  APPEND EXITS.



************************************************************************
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  EXITS-NAME  = 'U102'.
*  EXITS-PARAM = C_EXIT_PARAM_CLASS.
*  EXITS-TITLE = TEXT-102.             "Sum is used for the reference.
*  APPEND EXITS.


***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
  INCLUDE RGGBS_PS_TITLES.


  REFRESH ETAB.
  LOOP AT EXITS.
    ETAB = EXITS.
    APPEND ETAB.
  ENDLOOP.

ENDFORM.                    "GET_EXIT_TITLES
* eject
*---------------------------------------------------------------------*
*       FORM U100                                                     *
*---------------------------------------------------------------------*
*       Reads the cost-center from the CSKS table .                   *
*---------------------------------------------------------------------*
FORM U100.

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  SELECT * FROM CSKS
*            WHERE KOSTL EQ COBL-KOSTL
*              AND KOKRS EQ COBL-KOKRS.
*    IF CSKS-DATBI >= SY-DATUM AND
*       CSKS-DATAB <= SY-DATUM.
*
*      MOVE CSKS-ABTEI TO COBL-KOSTL.
*
*    ENDIF.
*  ENDSELECT.

ENDFORM.                                                    "U100
* eject
*---------------------------------------------------------------------*
*       FORM U101                                                     *
*---------------------------------------------------------------------*
*       Reads the cost-center from the CSKS table for accounting      *
*       area '0001'.                                                  *
*       This exit uses a parameter for the cost_center so it can      *
*       be used irrespective of the table used in the callup point.   *
*---------------------------------------------------------------------*
FORM U101 USING COST_CENTER.
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  SELECT * FROM CSKS
*            WHERE KOSTL EQ COST_CENTER
*              AND KOKRS EQ '0001'.
*    IF CSKS-DATBI >= SY-DATUM AND
*       CSKS-DATAB <= SY-DATUM.
*
*      MOVE CSKS-ABTEI TO COST_CENTER .
*
*    ENDIF.
*  ENDSELECT.
ENDFORM.                                                    "U101

* eject
*---------------------------------------------------------------------*
*       FORM U102                                                     *
*---------------------------------------------------------------------*
*       Inserts the sum of the posting into the reference field.      *
*       This exit can be used in FI for the complete document.        *
*       The complete data is passed in one parameter.                 *
*---------------------------------------------------------------------*
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*FORM u102 USING bool_data TYPE gb002_015.
*DATA: SUM(10) TYPE C.
*
*    LOOP AT BOOL_DATA-BSEG INTO BSEG
*                    WHERE    SHKZG = 'S'.
*       BSEG-ZUONR = 'Test'.
*       MODIFY BOOL_DATA-BSEG FROM BSEG.
*       ADD BSEG-DMBTR TO SUM.
*    ENDLOOP.
*
*    BKPF-XBLNR = TEXT-001.
*    REPLACE '&' WITH SUM INTO BKPF-XBLNR.
*
*ENDFORM.
***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
*INCLUDE rggbs_ps_forms.

*eject
* begin of insertion                                          "wms092357
*&---------------------------------------------------------------------*
*&      Form  u200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM U200 USING E_RMVCT TYPE BSEG-BEWAR.
  PERFORM XREF_TO_RMVCT USING BKPF BSEG 1 CHANGING E_RMVCT.
ENDFORM.                                                    "u200

*---------------------------------------------------------------------*
*       FORM U201                                                     *
*---------------------------------------------------------------------*
*       Determines Revaluation Keys in Asset                          *
*---------------------------------------------------------------------*
FORM U201.
  TABLES : ANLA , ANLB.
  break-point.
*
  CASE ANLB-AFABE.
    when '10'.
     CONCATENATE 'CF' ANLA-ZUPER+1(02)
     INTO ANLB-J_1AARVKEY.
    when '05'.
     CONCATENATE 'CT' ANLA-ZUPER+1(02)
     INTO ANLB-J_1AARVKEY.
  ENDCASE.
*
  UPDATE ANLB.
*
ENDFORM.                    "U113

*&---------------------------------------------------------------------*
*&      Form  xref_to_rmvct
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM XREF_TO_RMVCT
     USING    IS_BKPF         TYPE BKPF
              IS_BSEG         TYPE BSEG
              I_XREF_FIELD    TYPE I
     CHANGING C_RMVCT         TYPE RMVCT.

  DATA L_MSGV TYPE SYMSGV.
  STATICS ST_RMVCT TYPE HASHED TABLE OF RMVCT WITH UNIQUE DEFAULT KEY.

* either bseg-xref1 or bseg-xref2 must be used as source...
  IF I_XREF_FIELD <> 1 AND I_XREF_FIELD <> 2.
    MESSAGE X000(GK) WITH 'UNEXPECTED VALUE I_XREF_FIELD ='
      I_XREF_FIELD '(MUST BE = 1 OR = 2)' ''.
  ENDIF.
  IF ST_RMVCT IS INITIAL.
    SELECT TRTYP FROM T856 INTO TABLE ST_RMVCT.
  ENDIF.
  IF I_XREF_FIELD = 1.
    C_RMVCT = IS_BSEG-XREF1.
  ELSE.
    C_RMVCT = IS_BSEG-XREF2.
  ENDIF.
  IF C_RMVCT IS INITIAL.
    WRITE I_XREF_FIELD TO L_MSGV LEFT-JUSTIFIED.
    CONCATENATE TEXT-M00 L_MSGV INTO L_MSGV SEPARATED BY SPACE.
*   cons. transaction type is not specified => send an error message...
    MESSAGE E123(G3) WITH L_MSGV.
*   Bitte geben Sie im Feld &1 eine Konsolidierungsbewegungsart an
  ENDIF.
* c_rmvct <> initial...
  READ TABLE ST_RMVCT TRANSPORTING NO FIELDS FROM C_RMVCT.
  CHECK NOT SY-SUBRC IS INITIAL.
* cons. transaction type does not exist => send error message...
  WRITE I_XREF_FIELD TO L_MSGV LEFT-JUSTIFIED.
  CONCATENATE TEXT-M00 L_MSGV INTO L_MSGV SEPARATED BY SPACE.
  MESSAGE E124(G3) WITH C_RMVCT L_MSGV.
* KonsBewegungsart &1 ist ungültig (bitte Eingabe im Feld &2 korrigieren
ENDFORM.                    "xref_to_rmvct
* end of insertion                                            "wms092357
*&---------------------------------------------------------------------*
*&      Form  u301
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM U301.

  SELECT SINGLE TSAD4~PREFIX_TXT
    INTO BKPF-XREF2_HD
    FROM USR21 INNER JOIN ADRP ON ( USR21~PERSNUMBER = ADRP~PERSNUMBER )
               INNER JOIN TSAD4 ON ( ADRP~PREFIX2 = TSAD4~PREFIX_KEY )
    WHERE USR21~BNAME = BKPF-USNAM.

ENDFORM.                                                    "U301
*---------------------------------------------------------------------*
*       FORM U302                                                     *
*---------------------------------------------------------------------*
*       Inserts the sum of the posting into the reference field.      *
*       This exit can be used in FI for the complete document.        *
*       The complete data is passed in one parameter.                 *
*---------------------------------------------------------------------*
FORM U302 USING BOOL_DATA TYPE GB002_015.
  DATA: SUM(10) TYPE C.
  DATA: ZUONR      LIKE BSEG-ZUONR,
        SGTXT      LIKE BSEG-SGTXT,
        ZZMOT_EMIS LIKE BSEG-ZZMOT_EMIS.

*  LOOP AT BOOL_DATA-BSEG INTO  BSEG
*                         WHERE SHKZG = 'S'.
*    BSEG-ZUONR = 'Test'.
*    MODIFY BOOL_DATA-BSEG FROM BSEG.
*    ADD BSEG-DMBTR TO SUM.
*  ENDLOOP.
*
*  BKPF-XBLNR = TEXT-001.
*  REPLACE '&' WITH SUM INTO BKPF-XBLNR.
  LOOP AT BOOL_DATA-BSEG INTO  BSEG
                         WHERE SHKZG = 'H' AND
** INI V1 RVY 22-05-23
**                             HKONT <> '5211110001'.
                               HKONT <> '8117100001'.
**    SGTXT       = BSEG-SGTXT.
** FIN V1 RVY 22-05-23
      ZUONR       = BSEG-ZUONR.
      ZZMOT_EMIS  = BSEG-ZZMOT_EMIS.
  ENDLOOP.
  LOOP AT BOOL_DATA-BSEG INTO  BSEG
                         WHERE SHKZG = 'S' AND
** INI V1 RVY 22-05-23
**                             HKONT <> '5211110001'.
                               HKONT <> '8117100001'.
**     BSEG-SGTXT      = SGTXT.
** FIN V1 RVY 22-05-23
       BSEG-ZUONR      = ZUONR.
       BSEG-ZZMOT_EMIS = ZZMOT_EMIS.
       MODIFY BOOL_DATA-BSEG FROM BSEG.
  ENDLOOP.

ENDFORM.                                                    "U302

*---------------------------------------------------------------------*
*       FORM U204                                                     *
*---------------------------------------------------------------------*
*       Sustituye campo BSEG-ZZRUT_TERC                               *
*---------------------------------------------------------------------*
FORM U204.
  TABLES : RBKP,RSEG, MKPF, MSEG, LFA1, T001Z.

  data ls_RBKP_lifnr    like RBKP-lifnr.
  data ls_LFA1_stcd1    like LFA1-stcd1.
*
  CASE BSEG-BSCHL.
    when '21' OR
         '31' OR
         '81' OR
         '91'.
*
*     SELECT STCD1 INTO ls_LFA1_stcd1
*                  FROM LFA1
*                  WHERE lifnr = bseg-lifnr.
*     ENDSELECT.
*
*     move ls_LFA1_stcd1 to BSEG-ZZRUT_TERC.
*     move bseg-lifnr to BSEG-ZZRUT_TERC.
      IF BSEG-LIFNR <> '  '.
         move bseg-lifnr to bseg-zzrut_terc.
      else.
         SELECT LIFNR INTO ls_rbkp_lifnr
                      FROM EKKO
                      WHERE EBELN = BSEG-EBELN.
         ENDSELECT.
         IF ls_rbkp_lifnr <> '  '.
            move ls_rbkp_lifnr to bseg-zzrut_terc.
** RVY 14-10-2020
         else.
            if BSEG-bschl = '81' or
               bseg-bschl = '91'.
               select paval into bseg-zzrut_terc
                           from T001Z
                           WHERE bukrs = bseg-bukrs.
               ENDSELECT.
            ENDIF.
** RVY 14-10-2020.
         endif.
      ENDIF.

   when '86' OR
        '96'.
*
     SELECT LIFNR INTO ls_rbkp_lifnr
                  FROM EKKO
                  WHERE EBELN = BSEG-EBELN.
     ENDSELECT.
*
*     SELECT STCD1 INTO ls_LFA1_stcd1
*                  FROM LFA1
*                  WHERE lifnr = ls_rbkp_lifnr.
*     ENDSELECT.
**
*     move ls_LFA1_stcd1 to BSEG-ZZRUT_TERC.
*     move ls_rbkp_lifnr to BSEG-ZZRUT_TERC.
     IF ls_rbkp_lifnr <> '  '.
        move ls_rbkp_lifnr to bseg-zzrut_terc.
     ENDIF.
  ENDCASE.
*
ENDFORM.                    "U204
*----------------------------------------------------------------------*
*       FORM U205                                                      *
*----------------------------------------------------------------------*
* Compensación Bono cruzado
*----------------------------------------------------------------------*
FORM u205.
  DATA : lv_ltx TYPE fcltx.
*
  IF bkpf-monat IS NOT INITIAL.
    SELECT SINGLE ltx INTO lv_ltx
           FROM t247 WHERE spras EQ sy-langu AND
                           mnr   EQ bkpf-monat.
    CONCATENATE 'Compensación bono cruzado' lv_ltx INTO bseg-sgtxt
                                                   SEPARATED BY space.
  ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
*       FORM U206                                                     *
*---------------------------------------------------------------------*
*       Sustituye campo BSEG-KOSTL                          *
*---------------------------------------------------------------------*
FORM U206 USING ZBSEG_KOSTL.
*
  move bseg-PRCTR to ZBSEG_KOSTL.
*
ENDFORM.                    "U205
*---------------------------------------------------------------------*
*       FORM U207                                                    *
*---------------------------------------------------------------------*
*       Sustituye campo BSEG-STXT                               *
*---------------------------------------------------------------------*
FORM U207 USING ZBSEG_SGTXT.
  TABLES : KNA1, SKAT.

  CASE BSEG-KOART .
    WHEN 'K'.
         SELECT NAME1 INTO ZBSEG_SGTXT
                      FROM LFA1
                      WHERE LIFNR = BSEG-LIFNR.
         ENDSELECT.
   WHEN 'D'.
         SELECT NAME1 INTO ZBSEG_SGTXT
                      FROM KNA1
                      WHERE KUNNR = BSEG-KUNNR.
         ENDSELECT.
   WHEN OTHERS.
         SELECT TXT50 INTO ZBSEG_SGTXT
                      FROM SKAT
                      WHERE KTOPL = 'B100' AND
                            SAKNR = BSEG-HKONT.
         ENDSELECT.
  ENDCASE.
*
ENDFORM.                    "U207
