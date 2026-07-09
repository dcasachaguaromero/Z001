PROGRAM zrggbr000 .
*---------------------------------------------------------------------*
*                                                                     *
*   Regeln: EXIT-Formpool for Uxxx-Exits                              *
*                                                                     *
*   This formpool is used by SAP for demonstration purposes only.     *
*                                                                     *
*   Note: If you define a new user exit, you have to enter your       *
*         user exit in the form routine GET_EXIT_TITLES.              *
*                                                                     *
*---------------------------------------------------------------------*
INCLUDE fgbbgd00.               "Data types


*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
*    PLEASE INCLUDE THE FOLLOWING "TYPE-POOL"  AND "TABLES" COMMANDS  *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM         *
TYPE-POOLS: gb002. " TO BE INCLUDED IN
TABLES: bkpf,      " ANY SYSTEM THAT
        bseg,      " HAS 'FI' INSTALLED
        cobl,
        glu1.
*ENHANCEMENT-POINT RGGBR000_01 SPOTS ES_RGGBR000 STATIC.
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
*       C_EXIT_PARAM_CLASS  Use a type as parameter  Subst. and Valid  *
*----------------------------------------------------------------------*
*  -->  EXIT_TAB  table with exit-name and exit-titles                 *
*                 structure: NAME(5), PARAM(1), TITEL(60)
*----------------------------------------------------------------------*
FORM get_exit_titles TABLES etab.

  DATA: BEGIN OF exits OCCURS 50,
          name(5)   TYPE c,
          param     LIKE c_exit_param_none,
          title(60) TYPE c,
        END OF exits.
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*  EXITS-NAME  = 'U101'.
*  EXITS-PARAM = C_EXIT_PARAM_CLASS.
*  EXITS-TITLE = TEXT-100.                 "Posting date check
*  APPEND EXITS.

  exits-name  = 'U100'.
  exits-param = c_exit_param_none.        "Complete data used in exit.
  exits-title = TEXT-101.                 "Posting date check
  APPEND exits.

* forms for SAP_EIS
  exits-name  = 'US001'.                  "single validation: only one
  exits-param = c_exit_param_none.        "data record used
  exits-title = TEXT-102.                 "Example EIS
  APPEND exits.

  exits-name  = 'UM001'.                  "matrix validation:
  exits-param = c_exit_param_class.       "complete data used in exit.
  exits-title = TEXT-103.                 "Example EIS
  APPEND exits.






************************************************************************
***Validaciones FI BMSA*************************************************
************************************************************************

  exits-name  = 'U200'.
  exits-param = c_exit_param_none.                     "Complete data used in exit.
  exits-title = 'Periodos tributarios'.                "Fecha factura
  APPEND exits.

  exits-name  = 'U201'.
  exits-param = c_exit_param_none.                     "Complete data used in exit.
  exits-title = 'Cond.Doc. repetido K'.                "Condición documento repetido acreedores
  APPEND exits.

  exits-name  = 'U202'.
  exits-param = c_exit_param_none.                     "Complete data used in exit.
  exits-title = 'Verif. Docto repetido K'.             "Verificación documento repetido acreedores
  APPEND exits.

  exits-name  = 'U203'.
  exits-param = c_exit_param_none.                     "Complete data used in exit.
  exits-title = 'Cond.Doc. repetido D'.                "Condición documento repetido deudores
  APPEND exits.

  exits-name  = 'U204'.
  exits-param = c_exit_param_none.                     "Complete data used in exit.
  exits-title = 'Verif. Docto repetido D'.             "Verificación documento repetido acreedores
  APPEND exits.


***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
  INCLUDE rggbr_ps_titles.


  REFRESH etab.
  LOOP AT exits.
    etab = exits.
    APPEND etab.
  ENDLOOP.

ENDFORM.                    "GET_EXIT_TITLES

*eject
*----------------------------------------------------------------------*
*       FORM U100                                                      *
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule                          *
*       This exit can be used in FI for callup points 1,2 or 3.        *
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM u100  USING b_result.

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*
*   IF SY-DATUM = BKPF-BUDAT.
*     B_RESULT  = B_TRUE.
*  ELSE.
*    B_RESULT  = B_FALSE.
*  ENDIF.

*ENHANCEMENT-POINT RGGBR000_02 SPOTS ES_RGGBR000 STATIC.

*ENHANCEMENT-POINT RGGBR000_03 SPOTS ES_RGGBR000.


ENDFORM.                                                    "U100

*eject
*----------------------------------------------------------------------*
*       FORM U101                                                      *
*----------------------------------------------------------------------*
*       Example of an exit using the complete data from one            *
*       multi-line rule.                                               *
*       This exit is intended for use from callup point 3, in FI.      *
*                                                                      *
*       If account 400000 is used, then account 399999 must be posted  *
*       to in another posting line.                                    *
*----------------------------------------------------------------------*
*  -->  BOOL_DATA   The complete posting data.                         *
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINES *
*        IF THE ACCOUNTING MODULE IS INSTALLED IN YOUR SYSTEM:         *
*FORM u101 USING    bool_data TYPE gb002_015
*          CHANGING B_RESULT.
*  DATA: B_ACC_400000_USED LIKE D_BOOL VALUE 'F'.
*
*  B_RESULT = B_TRUE.
** Has account 400000 has been used?
*  LOOP AT BOOL_DATA-BSEG INTO BSEG
*                 WHERE HKONT  = '0000400000'.
*     B_ACC_400000_USED = B_TRUE.
*     EXIT.
*  ENDLOOP.
*
** Check that account 400000 has been used.
*  CHECK B_ACC_400000_USED = B_TRUE.
*
*  B_RESULT = B_FALSE.
*  LOOP AT BOOL_DATA-BSEG INTO BSEG
*                 WHERE HKONT  = '0000399999'.
*     B_RESULT = B_TRUE.
*     EXIT.
* ENDLOOP.
*
*ENDFORM.

*eject
*----------------------------------------------------------------------*
*       FORM US001
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule in SAP-EIS
*       for aspect 001 (single validation).
*       one data record is transfered in structure CF<asspect>
*----------------------------------------------------------------------
*       Attention: for any FORM one has to make an entry in the
*       form GET_EXIT_TITLES at the beginning of this include
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM us001 USING b_result.

*TABLES CF001.                                 "table name aspect 001
*
*  IF ( CF001-SPART = '00000001' OR
*       CF001-GEBIE = '00000001' ) AND
*       CF001-ERLOS >= '1000000'.
*
**   further checks ...
*
*    B_RESULT  = B_TRUE.
*  ELSE.
*
**   further checks ...
*
*    B_RESULT  = B_FALSE.
*  ENDIF.

ENDFORM.                                                    "US001

*eject
*----------------------------------------------------------------------*
*       FORM UM001
*----------------------------------------------------------------------*
*       Example of an exit for a boolean rule in SAP-EIS
*       for aspect 001 (matrix validation).
*       Data is transfered in BOOL_DATA:
*       BOOL_DATA-CF<aspect> is intern table of structure CF<asspect>
*----------------------------------------------------------------------
*       Attention: for any FORM one has to make an entry in the
*       form GET_EXIT_TITLES at the beginning of this include
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM um001 USING bool_data    "TYPE GB002_<boolean class of aspect 001>
           CHANGING b_result.

*DATA: LC_CF001 LIKE CF001.
*DATA: LC_COUNT TYPE I.

*  B_RESULT = B_TRUE.
*  CLEAR LC_COUNT.
*  process data records in BOOL_DATA
*  LOOP AT BOOL_DATA-CF001 INTO LC_CF001.
*    IF LC_CF001-SPART = '00000001'.
*      ADD 1 TO LC_COUNT.
*      IF LC_COUNT >= 2.
**       division '00000001' may only occur once !
*        B_RESULT = B_FALSE.
*        EXIT.
*      ENDIF.
*    ENDIF.
*
**   further checks ....
*
*  ENDLOOP.

ENDFORM.                                                    "UM001


***********************************************************************
** EXIT EXAMPLES FROM PUBLIC SECTOR INDUSTRY SOLUTION
**
** PLEASE DELETE THE FIRST '*' FORM THE BEGINING OF THE FOLLOWING LINE
** TO ENABLE PUBLIC SECTOR EXAMPLE SUBSTITUTION EXITS
***********************************************************************
*INCLUDE rggbr_ps_forms.








*----------------------------------------------------------------------*
*       FORM U200
*----------------------------------------------------------------------*
*       Validacion de periodo tributable para Contab. IVA
*
*----------------------------------------------------------------------*
*  <--  B_RESULT    T = True  F = False                                *
*----------------------------------------------------------------------*
FORM u200   USING b_result.
*    B_RESULT = B_FALSE.
*    B_RESULT = B_TRUE.

  DATA: BEGIN OF datum_von,
          jjjj(4) TYPE n,
          mm(2)   TYPE n,
          tt(2)   TYPE n,
        END OF datum_von.

  DATA: BEGIN OF datum_bis,
          jjjj(4) TYPE n,
          mm(2)   TYPE n,
          tt(2)   TYPE n,
        END OF datum_bis.

  DATA : val1 TYPE i.

  datum_von = bkpf-bldat.
  datum_bis = bkpf-budat.

  val1 = ( datum_bis-jjjj - datum_von-jjjj ) * 12
       + ( datum_bis-mm   - datum_von-mm   ).

  IF val1 GT 2.
    b_result  = b_false.
  ELSE.
    b_result  = b_true.
  ENDIF.

ENDFORM.                                                     "U200



*----------------------------------------------------------------------*
*       FORM U201                                                      *
*----------------------------------------------------------------------*
* Condición documento repetido de acreedores
FORM u201  USING b_result.
*ACREEDOR
  RANGES: t_code FOR syst-tcode.
  DATA: pvalsign   LIKE  setleaf-valsign,
        pvaloption LIKE  setleaf-valoption,
        pvalfrom   LIKE  setleaf-valfrom,
        pvalto     LIKE  setleaf-valto.
  RANGES: pp_blart FOR bkpf-blart.

  b_result  = b_false.
* ini Waldo ALarcón - Visionone - 20-06-2022
*  t_code-sign   = 'E'.
*  t_code-option = 'EQ'.
*  t_code-low    = 'FB08'.
*  APPEND t_code.
*  t_code-low    = 'F.80'.
*  APPEND t_code.

  SELECT valsign, valoption, valfrom, valto INTO @DATA(lw_setleaf)
         FROM setleaf WHERE setname EQ 'ZFI_TCODE_EX'.
    MOVE: 'E'                  TO t_code-sign,
          lw_setleaf-valoption TO t_code-option,
          lw_setleaf-valfrom   TO t_code-low,
          lw_setleaf-valto     TO t_code-high.
    APPEND t_code.
  ENDSELECT.
* fin Waldo ALarcón - Visionone - 20-06-2022

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT  valsign valoption valfrom valto INTO (pvalsign, pvaloption, pvalfrom, pvalto)
*   FROM setleaf
*  WHERE setname EQ 'ZFIBLART_K'.
*
* NEW CODE
  SELECT valsign valoption val
from valto INTO (pvalsign, pvaloption, pvalfrom, pvalto)
   FROM setleaf
  WHERE setname EQ 'ZFIBLART_K' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    MOVE: pvalsign TO pp_blart-sign,
          pvaloption TO pp_blart-option,
          pvalfrom   TO pp_blart-low,
          pvalto     TO pp_blart-high.
    APPEND pp_blart.
    CLEAR:pvalsign, pvaloption, pvalfrom, pvalto, pp_blart.
  ENDSELECT.

  CHECK NOT pp_blart[] IS INITIAL.
*  BREAK-POINT.
  IF sy-tcode   IN t_code    AND
     bkpf-blart IN pp_blart  AND    " Clases de documentos
     bseg-koart EQ 'K'.
    b_result  = b_true.
  ELSE.
    b_result  = b_false.
  ENDIF.

ENDFORM.                                                    "U201

*----------------------------------------------------------------------*
*       FORM U202                                                      *
*----------------------------------------------------------------------*
* Verificación documento repetido de acreedores
FORM u202  USING b_result.

  DATA docto LIKE bkpf-belnr.
*  BREAK-POINT.
  IF bseg-koart = 'K'.         "Acreedor
    SELECT SINGLE bkpf~belnr
        INTO docto
        FROM bsik JOIN bkpf ON ( bsik~belnr = bkpf~belnr AND bsik~bukrs = bkpf~bukrs
                                 AND bsik~gjahr = bkpf~gjahr )
        WHERE bsik~lifnr = bseg-lifnr AND   "Acreedor

* Inicio Mod. se descomenta sentencia por sociedad Fosorio 20.11.2013

              bsik~bukrs = bkpf-bukrs AND   "Sociedad

* Fin Mod. se descomenta sentencia por sociedad Fosorio 20.11.2013

              bkpf~xblnr = bkpf-xblnr AND   "Referencia
              bkpf~blart = bkpf-blart AND   "Clase de documento
              bkpf~stblg = ''         AND   "Número del documento de anulación.
              bkpf~belnr <> bkpf-belnr.
    IF sy-subrc = 0.
      b_result  = b_false.
    ELSE.
      SELECT SINGLE bkpf~belnr
        INTO docto
        FROM bsak JOIN bkpf ON ( bsak~belnr = bkpf~belnr  AND bsak~bukrs = bkpf~bukrs
                                 AND bsak~gjahr = bkpf~gjahr )
        WHERE bsak~lifnr = bseg-lifnr AND   "Acreedor

* Inicio Mod. se descomenta sentencia por sociedad Fosorio 20.11.2013

              bsak~bukrs = bkpf-bukrs AND   "Sociedad

* Fin Mod. se descomenta sentencia por sociedad Fosorio 20.11.2013

              bkpf~xblnr = bkpf-xblnr AND   "Referencia
              bkpf~blart = bkpf-blart AND   "Clase de documento
              bkpf~stblg = ''         AND   "Número del documento de anulación.
              bkpf~belnr <> bkpf-belnr.

      IF sy-subrc = 0.
        b_result  = b_false.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                                                    "U202

*----------------------------------------------------------------------*
*       FORM U203                                                      *
*----------------------------------------------------------------------*
* Condición documento repetido de deudores
FORM u203  USING b_result.
*DEUDORES
  RANGES: t_code FOR syst-tcode.
  DATA: pvalsign   LIKE  setleaf-valsign,
        pvaloption LIKE  setleaf-valoption,
        pvalfrom   LIKE  setleaf-valfrom,
        pvalto     LIKE  setleaf-valto.
  RANGES: pp_blart FOR bkpf-blart.

  b_result  = b_true.
* ini Waldo ALarcón - Visionone - 20-06-2022
*  t_code-sign   = 'E'.
*  t_code-option = 'EQ'.
*  t_code-low    = 'FB08'.
*  APPEND t_code.
*  t_code-low    = 'F.80'.
*  APPEND t_code.
  SELECT valsign, valoption, valfrom, valto INTO @DATA(lw_setleaf)
         FROM setleaf WHERE setname EQ 'ZFI_TCODE_EX'.
    MOVE: 'E'                  TO t_code-sign,
          lw_setleaf-valoption TO t_code-option,
          lw_setleaf-valfrom   TO t_code-low,
          lw_setleaf-valto     TO t_code-high.
    APPEND t_code.
  ENDSELECT.
* fin Waldo ALarcón - Visionone - 20-06-2022


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT  valsign valoption valfrom valto INTO (pvalsign, pvaloption, pvalfrom, pvalto)
*   FROM setleaf
*  WHERE setname EQ 'ZFIBLART_D'.
*
* NEW CODE
  SELECT valsign valoption val
from valto INTO (pvalsign, pvaloption, pvalfrom, pvalto)
   FROM setleaf
  WHERE setname EQ 'ZFIBLART_D' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    MOVE: pvalsign TO pp_blart-sign,
          pvaloption TO pp_blart-option,
          pvalfrom   TO pp_blart-low,
          pvalto     TO pp_blart-high.
    APPEND pp_blart.
    CLEAR:pvalsign, pvaloption, pvalfrom, pvalto, pp_blart.
  ENDSELECT.

  CHECK NOT pp_blart[] IS INITIAL.

  IF sy-tcode   IN t_code    AND
     bkpf-blart IN pp_blart  AND    " Clases de documentos
     bseg-koart EQ 'D'.
    b_result  = b_true.
  ELSE.
    b_result  = b_false.
  ENDIF.

ENDFORM.                                                    "U203

*----------------------------------------------------------------------*
*       FORM U204                                                      *
*----------------------------------------------------------------------*
* Verificacin documento repetido de deudores
FORM u204  USING b_result.

  DATA docto LIKE bkpf-belnr.

  IF bseg-koart = 'D'.         "Deudor
    SELECT SINGLE bkpf~belnr
        INTO docto
        FROM bsid JOIN bkpf ON ( bsid~belnr = bkpf~belnr AND bsid~bukrs = bkpf~bukrs
                                 AND bsid~gjahr = bkpf~gjahr )
        WHERE bsid~kunnr = bseg-kunnr AND   "Deudor

* Inicio Mod. se descomenta sentencia por sociedad Fosorio 20.11.2013

              bsid~bukrs = bkpf-bukrs AND   "Sociedad

* Fin Mod. se descomenta sentencia por sociedad Fosorio 20.11.2013

              bkpf~xblnr = bkpf-xblnr AND   "Referencia
              bkpf~blart = bkpf-blart AND   "Clase de documento
              bkpf~stblg = ''         AND   "Número del documento de anulación.
              bkpf~belnr <> bkpf-belnr.
    IF sy-subrc = 0.
      b_result  = b_false.
    ELSE.
      SELECT SINGLE bkpf~belnr
        INTO docto
        FROM bsad JOIN bkpf ON ( bsad~belnr = bkpf~belnr AND bsad~bukrs = bkpf~bukrs
                                 AND bsad~gjahr = bkpf~gjahr )
        WHERE bsad~kunnr = bseg-kunnr AND   "Deudor

* Inicio Mod. se descomenta sentencia por sociedad Fosorio 20.11.2013

              bsad~bukrs = bkpf-bukrs AND   "Sociedad

* Fin Mod. se descomenta sentencia por sociedad Fosorio 20.11.2013

              bkpf~xblnr = bkpf-xblnr AND   "Referencia
              bkpf~blart = bkpf-blart AND   "Clase de documento
              bkpf~stblg = ''         AND   "Número del documento de anulación.
              bkpf~belnr <> bkpf-belnr.
      IF sy-subrc = 0.
        b_result  = b_false.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                                                    "U204
