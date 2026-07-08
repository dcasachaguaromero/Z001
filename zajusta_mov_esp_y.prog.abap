*&---------------------------------------------------------------------*
*& Report  ZAJUSTA_MOV_ESP_Y
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*  Solicitado por   : Proyecto Upgrade S4/HANA
*  Desarrollador por: David Casachagua R. - NTTData
*  Fecha Modific.   : 26.05.2026
*  Detalle          : Ajuste para Upgrade S4/HANA
*  Marca Modificac. : @DCR
*----------------------------------------------------------------------*
REPORT  ZAJUSTA_MOV_ESP_Y.
*
tables : anek, anep, anea.

data : t_anep   like anep occurs 0 with header line,
       t_anep2  like anep occurs 0 with header line,
       t_anep_s like anep occurs 0 with header line,
       t_anea   like anea occurs 0 with header line,
       t_anea2  like anea occurs 0 with header line,
       t_anea_s like anea occurs 0 with header line,
       t_anek2  like anek occurs 0 with header line,
       t_anlh   like anlh occurs 0 with header line,
       begin of t_anek occurs 0."like anek occurs 0 with header line.
        include structure anek.
data:      lnran2 like anek-lnran,
       end of t_anek,
       BEGIN OF SALIDA,
          BUKRS  LIKE ANEA-BUKRS,
          ANLN1  LIKE ANEA-ANLN1,
          ANLN2  LIKE ANEA-ANLN2,
          GJAHR  LIKE ANEA-GJAHR,
          LNRAN  LIKE ANEA-LNRAN,
          BWASL  LIKE ANEP-BWASL,
          AFABE  LIKE ANEA-AFABE,
*
          ANBTR  LIKE ANEP-ANBTR,
          NAFAB  LIKE ANEP-NAFAB,
          SAFAB  LIKE ANEP-SAFAB,
          ZINSB  LIKE ANEP-ZINSB,
*
          AUFWV  LIKE ANEA-AUFWV,
          INVZV  LIKE ANEA-INVZV,
          NAFAV  LIKE ANEA-NAFAV,
          SAFAV  LIKE ANEP-SAFAB,
          AAFAV  LIKE ANEA-AAFAV,
          MAFAV  LIKE ANEA-MAFAV,
          AUFNV  LIKE ANEA-AUFNV,
          AUFWL  LIKE ANEA-AUFWL,
          INVZL  LIKE ANEA-INVZL,
          NAFAL  LIKE ANEA-NAFAL,
          SAFAL  LIKE ANEA-SAFAL,
          AAFAL  LIKE ANEA-AAFAL,
          MAFAL  LIKE ANEA-MAFAL,
          AUFNL  LIKE ANEA-AUFNL,
          ERLBT  LIKE ANEA-ERLBT,
          VERKO  LIKE ANEA-VERKO,
          SANWV  LIKE ANEA-SANWV,
       END OF SALIDA.
* Variables ALV
data: g_alv_tree         type ref to cl_gui_alv_tree,
      gt_fieldcatalog    TYPE lvc_t_fcat,
      G_IS_VARIANT       TYPE DISVARIANT,
      g_custom_container type ref to cl_gui_custom_container.

data: gt_anea         LIKE SALIDA occurs 0,      "Output-Table
      ok_code         like sy-ucomm,
      save_ok         like sy-ucomm.

SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-000.
SELECT-OPTIONS: s_bukrs for anep-bukrs obligatory
                                     no-extension no intervals,
                s_GJAHR for anep-GJAHR OBLIGATORY
                                     no-extension no intervals.
SELECTION-SCREEN END OF BLOCK bl0.
*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: S_BZDAT FOR ANEP-BZDAT OBLIGATORY,
                S_BWASL FOR ANEP-BWASL NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK bl1.

SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
SELECT-OPTIONS: S_ANLN1 FOR ANEP-ANLN1,
                s_anln2 for anep-anln2 no-display.
PARAMETERS: P_AFABEM LIKE ANEP-AFABE OBLIGATORY default '10', "Area Modelo
            P_AFABEN LIKE ANEP-AFABE OBLIGATORY default '20'. "Area Nueva
SELECTION-SCREEN END OF BLOCK bl2.

SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-003.
PARAMETERS: p_test   AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN skip 1.
PARAMETERS: P_TODO   RADIOBUTTON GROUP RADI default 'X'.
PARAMETERS: P_ACTUAL RADIOBUTTON GROUP RADI.
PARAMETERS: P_BORAJU RADIOBUTTON GROUP RADI.
SELECTION-SCREEN END OF BLOCK bl3.

start-of-selection.

  perform lee_tablas.
  if  t_anek[] is not initial.
    case 'X'.
      when p_todo.
        perform proceso_actualiza USING 'T'. "(opciones 1,2 y 3)
        perform muestra_datos.
      when p_actual.
        perform proceso_actualiza USING ' '.                "(opcion 1)
        perform muestra_datos.
      when p_boraju.
        perform proceso_borrado_ajuste.      "(opcion 2 y 3)
        perform muestra_datos.
    endcase.
  else.
    message e899(fi) with 'No se encontrarón datos'.
  endif.
*&---------------------------------------------------------------------*
*&      Form  LEE_TABLAS
*&---------------------------------------------------------------------*
FORM LEE_tablas .

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Lectura de tabla ANEP'
    EXCEPTIONS
      OTHERS = 1.
* Lee datos de tabla ANEP (Partidas individuales de act.fijos)
* select * into table t_anep                                     "DELETE@DCR:27.05.2026
   select * into TABLE @DATA(lt_anep)                            "INSERT@DCR:27.05.2026
         from anep where bukrs in @s_bukrs and
                         anln1 in @s_anln1 and
                         anln2 in @s_anln2 and
                         gjahr in @s_gjahr and
                         afabe eq @P_AFABEN and "Area Nueva
                         bzdat in @s_bzdat  and
                         bwasl LIKE 'Y%'.   "Todos los movimiento Y
*
    MOVE-CORRESPONDING lt_anep[] TO t_anep[].                    "INSERT@DCR:27.05.2026

  check t_anep[] is not initial.
* si existen datos lee la
* tabla ANEA (Partidas indiv.de activos fijos: Valores proporcionales)
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Lectura de tabla ANEA'
    EXCEPTIONS
      OTHERS = 1.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into table t_anea
*         from anea for all entries in t_anep
*                   where bukrs eq t_anep-bukrs and
*                         anln1 eq t_anep-anln1 and
*                         anln2 eq t_anep-anln2 and
*                         gjahr eq t_anep-gjahr and
*                         lnran eq t_anep-lnran and
*                         afabe eq t_anep-afabe.
*
* NEW CODE
  SELECT *
 into table t_anea
         from anea for all entries in t_anep
                   where bukrs eq t_anep-bukrs and
                         anln1 eq t_anep-anln1 and
                         anln2 eq t_anep-anln2 and
                         gjahr eq t_anep-gjahr and
                         lnran eq t_anep-lnran and
                         afabe eq t_anep-afabe ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
* tabla ANEK (Cabecera de documento de contabilización AF)
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Lectura de tabla ANEK'
    EXCEPTIONS
      OTHERS = 1.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into table t_anek
*         from anek for all entries in t_anep
*                   where bukrs eq t_anep-bukrs and
*                         anln1 eq t_anep-anln1 and
*                         anln2 eq t_anep-anln2 and
*                         gjahr eq t_anep-gjahr and
*                         lnran eq t_anep-lnran.
*
* NEW CODE
  SELECT *
 into table t_anek
         from anek for all entries in t_anep
                   where bukrs eq t_anep-bukrs and
                         anln1 eq t_anep-anln1 and
                         anln2 eq t_anep-anln2 and
                         gjahr eq t_anep-gjahr and
                         lnran eq t_anep-lnran ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
**add ini
  SORT t_anek BY bukrs anln1.
**add fin
  loop at t_anek.
    move t_anek-sgtxt(05) to t_anek-lnran2.
    modify t_anek index sy-tabix.
  endloop.
ENDFORM.                    " LEE_TABLAS
*&---------------------------------------------------------------------*
*&      Form  PROCESO_ACTUALIZA
*&---------------------------------------------------------------------*
FORM PROCESO_ACTUALIZA USING P_OPCION.
  data l_num like sy-tabix.
*
  REFRESH T_ANEP_S.
  REFRESH T_ANEA_S.
*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Lectura de tabla ANEP con datos de ANEK'
    EXCEPTIONS
      OTHERS = 1.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into table t_anep2
*         from anep for all entries in t_anek
*                   where bukrs eq t_anek-bukrs  and
*                         anln1 eq t_anek-anln1  and
*                         anln2 eq t_anek-anln2  and
*                         gjahr eq t_anek-gjahr  and
*                         lnran eq t_anek-lnran2 and
*                         afabe eq P_AFABEM.     
*
* NEW CODE
  SELECT *
 into table t_anep2
         from anep for all entries in t_anek
                   where bukrs eq t_anek-bukrs  and
                         anln1 eq t_anek-anln1  and
                         anln2 eq t_anek-anln2  and
                         gjahr eq t_anek-gjahr  and
                         lnran eq t_anek-lnran2 and
                         afabe eq P_AFABEM ORDER BY PRIMARY KEY.     

* END. 07-07-2026 - ATC - ATC-03"Area Modelo
*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Lectura de tabla ANEA con datos de ANEK'
    EXCEPTIONS
      OTHERS = 1.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * into table t_anea2
*         from anea for all entries in t_anek
*                   where bukrs eq t_anek-bukrs  and
*                         anln1 eq t_anek-anln1  and
*                         anln2 eq t_anek-anln2  and
*                         gjahr eq t_anek-gjahr  and
*                         lnran eq t_anek-lnran2 and
*                         afabe eq P_AFABEM.    
*
* NEW CODE
  SELECT *
 into table t_anea2
         from anea for all entries in t_anek
                   where bukrs eq t_anek-bukrs  and
                         anln1 eq t_anek-anln1  and
                         anln2 eq t_anek-anln2  and
                         gjahr eq t_anek-gjahr  and
                         lnran eq t_anek-lnran2 and
                         afabe eq P_AFABEM ORDER BY PRIMARY KEY.    

* END. 07-07-2026 - ATC - ATC-03"Area Modelo
*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Proceso de preparación para Actualizar Datos'
    EXCEPTIONS
      OTHERS = 1.
  LOOP AT T_ANEK.
    PERFORM PROCESO_ANEP USING T_ANEK.
    PERFORM PROCESO_ANEA USING T_ANEK.
  ENDLOOP.
*
  free : t_anep2, t_anea2.
* si no es modo Test se actualizan las tablas.
*  check p_test is initial.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Proceso de Actualización de Datos'
    EXCEPTIONS
      OTHERS = 1.
* ACTUALIZA TABLA ANEP
*
  l_num = 0.
  loop at t_anep_s.
    add 1 to l_num.
* si no es modo Test se actualizan las tablas.
    check p_test is initial.
    move-corresponding t_anep_s to anep.
    modify anep.
************************************************************
*    modify anep set :   ANBTR = T_ANEP_S-ANBTR
*                        NAFAB = T_ANEP_S-NAFAB
*                        SAFAB = T_ANEP_S-SAFAB
*                        ZINSB = T_ANEP_S-ZINSB
*                  where bukrs eq t_anep_s-bukrs  and
*                        anln1 eq t_anep_s-anln1  and
*                        anln2 eq t_anep_s-anln2  and
*                        gjahr eq t_anep_s-gjahr  and
*                        lnran eq t_anep_s-lnran  and
*                        afabe eq t_anep_s-afabe.
*    check l_num gt 1000.
*************************************************************
    commit work and wait.
  endloop.
  commit work and wait.
* ACTUALIZA TABLA ANEA
  l_num = 0.
  loop at t_anea_s.
    add 1 to l_num.
* si no es modo Test se actualizan las tablas.
    check p_test is initial.
    move-corresponding t_anea_s to anea.
    modify anea.
****************************************************************
*    update anea set:     AUFWV = T_ANEA_S-AUFWV
*                         INVZV = T_ANEA_S-INVZV
*                         NAFAV = T_ANEA_S-NAFAV
*                         SAFAV = T_ANEA_S-SAFAV
*                         AAFAV = T_ANEA_S-AAFAV
*                         MAFAV = T_ANEA_S-MAFAV
*                         AUFNV = T_ANEA_S-AUFNV
*                         AUFWL = T_ANEA_S-AUFWL
*                         INVZL = T_ANEA_S-INVZL
*                         NAFAL = T_ANEA_S-NAFAL
*                         SAFAL = T_ANEA_S-SAFAL
*                         AAFAL = T_ANEA_S-AAFAL
*                         MAFAL = T_ANEA_S-MAFAL
*                         AUFNL = T_ANEA_S-AUFNL
*                         ERLBT = T_ANEA_S-ERLBT
*                         VERKO = T_ANEA_S-VERKO
*                         SANWV = T_ANEA_S-SANWV
*                   where bukrs eq t_anea_s-bukrs  and
*                         anln1 eq t_anea_s-anln1  and
*                         anln2 eq t_anea_s-anln2  and
*                         gjahr eq t_anea_s-gjahr  and
*                         lnran eq t_anea_s-lnran  and
*                         afabe eq t_anea_s-afabe.
*    check l_num gt 1000.
****************************************************************
    commit work and wait.
  endloop.
  commit work and wait.

* SI LA OPCION SELECCIONADA FUE LA PRIMERA
  CHECK P_OPCION EQ 'T'.
* PROCESO DE BORRADO
  perform proceso_borrado.
* PROCESO DE AJUSTE DE INDICE
  perform proceso_ajuste_indice.
ENDFORM.                    "PROCESO_ACTUALIZA
*&---------------------------------------------------------------------*
*&      Form  PROCESO_BORRADO_AJUSTE
*&---------------------------------------------------------------------*
FORM PROCESO_BORRADO_AJUSTE .
* PROCESO DE BORRADO
  perform proceso_borrado.
* PROCESO DE AJUSTE DE INDICE
  perform proceso_ajuste_indice.
ENDFORM.                    " PROCESO_BORRADO_AJUSTE
*&---------------------------------------------------------------------*
*&      Form  PROCESO_ANEP
*&---------------------------------------------------------------------*
FORM PROCESO_ANEP  USING P_ANEK STRUCTURE T_ANEK.

*
  READ TABLE T_ANEP2 WITH KEY bukrs = p_anek-bukrs
                              anln1 = p_anek-anln1
                              anln2 = p_anek-anln2
                              gjahr = p_anek-gjahr
                              lnran = p_anek-lnran2
                              afabe = P_AFABEM.     "Area Modelo
  CHECK SY-SUBRC EQ 0.
  READ TABLE T_ANEP  WITH KEY bukrs = p_anek-bukrs
                              anln1 = p_anek-anln1
                              anln2 = p_anek-anln2
                              gjahr = p_anek-gjahr
                              lnran = p_anek-lnran
                              afabe = P_AFABEN.     "Area Nueva
  CHECK SY-SUBRC EQ 0.
  MOVE-CORRESPONDING T_ANEP2 TO T_ANEP_S.
  T_ANEP_S-AFABE = P_AFABEN.                  "Area Nueva
  T_ANEP_S-ANBTR = T_ANEP-ANBTR.
  T_ANEP_S-NAFAB = T_ANEP-NAFAB.
  T_ANEP_S-SAFAB = T_ANEP-SAFAB.
  T_ANEP_S-ZINSB = T_ANEP-ZINSB.

  APPEND T_ANEP_S.
  CLEAR  T_ANEP_S.

ENDFORM.                    " PROCESO_ANEP
*&---------------------------------------------------------------------*
*&      Form  PROCESO_ANEA
*&---------------------------------------------------------------------*
FORM PROCESO_ANEA  USING P_ANEK STRUCTURE T_ANEK.
*
  READ TABLE T_ANEA2 WITH KEY bukrs = p_anek-bukrs
                              anln1 = p_anek-anln1
                              anln2 = p_anek-anln2
                              gjahr = p_anek-gjahr
                              lnran = p_anek-lnran2
                              afabe = P_AFABEM.       "Area Modelo
  CHECK SY-SUBRC EQ 0.
  READ TABLE T_ANEA  WITH KEY bukrs = p_anek-bukrs
                              anln1 = p_anek-anln1
                              anln2 = p_anek-anln2
                              gjahr = p_anek-gjahr
                              lnran = p_anek-lnran
                              afabe = P_AFABEN.   "Area Nueva
  CHECK SY-SUBRC EQ 0.
  MOVE-CORRESPONDING T_ANEA2 TO T_ANEA_S.
  T_ANEA_S-AFABE = P_AFABEN.                  "Area Nueva
  T_ANEA_S-AUFWV = T_ANEA-AUFWV.
  T_ANEA_S-INVZV = T_ANEA-INVZV.
  T_ANEA_S-NAFAV = T_ANEA-NAFAV.
  T_ANEA_S-SAFAV = T_ANEA-SAFAV.
  T_ANEA_S-AAFAV = T_ANEA-AAFAV.
  T_ANEA_S-MAFAV = T_ANEA-MAFAV.
  T_ANEA_S-AUFNV = T_ANEA-AUFNV.
  T_ANEA_S-AUFWL = T_ANEA-AUFWL.
  T_ANEA_S-INVZL = T_ANEA-INVZL.
  T_ANEA_S-NAFAL = T_ANEA-NAFAL.
  T_ANEA_S-SAFAL = T_ANEA-SAFAL.
  T_ANEA_S-AAFAL = T_ANEA-AAFAL.
  T_ANEA_S-MAFAL = T_ANEA-MAFAL.
  T_ANEA_S-AUFNL = T_ANEA-AUFNL.
  T_ANEA_S-ERLBT = T_ANEA-ERLBT.
  T_ANEA_S-VERKO = T_ANEA-VERKO.
  T_ANEA_S-SANWV = T_ANEA-SANWV.

  APPEND T_ANEA_S.
  CLEAR  T_ANEA_S.
ENDFORM.                    " PROCESO_ANEA
*&---------------------------------------------------------------------*
*&      Form  PROCESO_BORRADO
*&---------------------------------------------------------------------*
FORM PROCESO_BORRADO .
* SI no es TEST
*  CHECK P_test is initial.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Proceso de Borrado de Datos'
    EXCEPTIONS
      OTHERS = 1.
  loop at t_anek.
* SI HAY MOVIMIENTOS PARA OTRAS AREAS,NO BORRA ANEK.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM ANEP WHERE BUKRS = T_ANEK-BUKRS
*                               AND  ANLN1 = T_ANEK-ANLN1
*                               AND  ANLN2 = T_ANEK-ANLN2
*                               AND  GJAHR = T_ANEK-GJAHR
*                               AND  LNRAN = T_ANEK-LNRAN
*                               AND  AFABE NE P_AFABEN.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM ANEP WHERE BUKRS = T_ANEK-BUKRS
                               AND  ANLN1 = T_ANEK-ANLN1
                               AND  ANLN2 = T_ANEK-ANLN2
                               AND  GJAHR = T_ANEK-GJAHR
                               AND  LNRAN = T_ANEK-LNRAN
                               AND  AFABE NE P_AFABEN ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
    IF SY-SUBRC NE 0.
* si no es modo Test se actualizan las tablas.
    check p_test is initial.
    delete from anek where bukrs eq t_anek-bukrs  and
                           anln1 eq t_anek-anln1  and
                           anln2 eq t_anek-anln2  and
                           gjahr eq t_anek-gjahr  and
                           lnran eq t_anek-lnran.

  ENDIF.
  endloop.
*
  loop at t_anep.
* si no es modo Test se actualizan las tablas.
    check p_test is initial.
    delete from anep where bukrs eq t_anep-bukrs  and
                           anln1 eq t_anep-anln1  and
                           anln2 eq t_anep-anln2  and
                           gjahr eq t_anep-gjahr  and
                           lnran eq t_anep-lnran  and
                           afabe eq t_anep-afabe  and
                           zujhr eq t_anep-zujhr  and
                           zucod eq t_anep-zucod.
  endloop.
*
  loop at t_anea.
* si no es modo Test se actualizan las tablas.
    check p_test is initial.
    delete from anea where bukrs eq t_anea-bukrs  and
                           anln1 eq t_anea-anln1  and
                           anln2 eq t_anea-anln2  and
                           gjahr eq t_anea-gjahr  and
                           lnran eq t_anea-lnran  and
                           afabe eq t_anea-afabe  and
                           zujhr eq t_anea-zujhr  and
                           zucod eq t_anea-zucod.
  endloop.
*
  commit work and wait.
ENDFORM.                    " PROCESO_BORRADO
*&---------------------------------------------------------------------*
*&      Form  PROCESO_AJUSTE_INDICE
*&---------------------------------------------------------------------*
FORM PROCESO_AJUSTE_INDICE .
*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Proceso de Preparación de Ajuste de Indice'
    EXCEPTIONS
      OTHERS = 1.

*PGR
* Deja un Unico Registro por Activo.
*    DELETE ADJACENT DUPLICATES FROM t_ANEK
*                   COMPARING ANLN1.



  loop at t_anek.


*    select bukrs anln1 anln2 gjahr max( lnran ) appending table t_anek2
*           from anek where bukrs eq t_anek-bukrs  and
*                           anln1 eq t_anek-anln1  and
*                           anln2 eq t_anek-anln2  and
*                           gjahr eq t_anek-gjahr
*                           group by bukrs anln1 anln2 gjahr lnran.

* PGR

    AT NEW ANLN1.

      CLEAR T_ANLH.
      SELECT MAX( LNRAN ) INTO T_ANLH-LANEP FROM ANEK
      WHERE BUKRS = T_ANEK-BUKRS
      AND   ANLN1 = T_ANEK-ANLN1.
      IF SY-SUBRC EQ 0.
        MOVE T_ANEK-BUKRS TO T_ANLH-BUKRS.
        MOVE T_ANEK-ANLN1 TO T_ANLH-ANLN1.
        APPEND T_ANLH.
      ENDIF.

    ENDAT.

  endloop.

* SI no es TEST
  CHECK P_test is initial.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text   = 'Proceso de Ajuste de Indice'
    EXCEPTIONS
      OTHERS = 1.
*  loop at t_anek2.

  LOOP AT T_ANLH.

    update anlh set : lanep = t_anlh-lanep
            where bukrs eq t_anlh-bukrs and
                  anln1 eq t_anlh-anln1.



*    update anlh set : lanep = t_anek2-lnran
*              where bukrs eq t_anek2-bukrs and
*                    anln1 eq t_anek2-anln1.
  endloop.
*
  commit work and wait.
ENDFORM.                    " PROCESO_AJUSTE_INDICE
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM MUESTRA_DATOS .
*
  call screen 100.

ENDFORM.                    " MUESTRA_DATOS
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PBO OUTPUT.
  set pf-status 'MAIN100'    OF PROGRAM 'BCALV_TREE_01'.
  set titlebar  'MAINTITLE'  OF PROGRAM 'BCALV_TREE_01'.

  if g_alv_tree is initial.
    perform init_tree.

    call method cl_gui_cfw=>flush
      EXCEPTIONS
        cntl_system_error = 1
        cntl_error        = 2.
    if sy-subrc ne 0.
      call function 'POPUP_TO_INFORM'
        EXPORTING
          titel = 'Automation Queue failure'(801)
          txt1  = 'Internal error:'(802)
          txt2  = 'A method in the automation queue'(803)
          txt3  = 'caused a failure.'(804).
    endif.
  endif.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE PAI INPUT.

  save_ok = ok_code.
  clear ok_code.

  case save_ok.
    when 'EXIT' or 'BACK' or 'CANC'.
      perform exit_program.

    when others.
* §6. Call dispatch to process toolbar functions
      call method cl_gui_cfw=>dispatch.

  endcase.

  call method cl_gui_cfw=>flush.
ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  INIT_TREE
*&---------------------------------------------------------------------*
FORM INIT_TREE .
  data: l_tree_container_name(30) type c.

  l_tree_container_name = 'CCONTAINER1'.

  create object g_custom_container
    EXPORTING
      container_name              = l_tree_container_name
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5.
  if sy-subrc <> 0.
    message x208(00) with 'ERROR'(100).
  endif.

* create tree control
  create object g_alv_tree
    EXPORTING
      parent                      = g_custom_container
      node_selection_mode         = cl_gui_column_tree=>node_sel_mode_single
      item_selection              = 'X'
      no_html_header              = 'X'
      no_toolbar                  = ''
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      illegal_node_selection_mode = 5
      failed                      = 6
      illegal_column_name         = 7.
  if sy-subrc <> 0.
    message x208(00) with 'ERROR'.                          "#EC NOTEXT
  endif.
*
  data l_hierarchy_header type treev_hhdr.
  perform build_hierarchy_header changing l_hierarchy_header.
*
  PERFORM build_fieldcatalog.
*
  G_IS_VARIANT-REPORT = SY-REPID.
*
  call method g_alv_tree->set_table_for_first_display
    EXPORTING
      IS_VARIANT          = G_IS_VARIANT
      I_SAVE              = 'A'
      is_hierarchy_header = l_hierarchy_header
    CHANGING
      it_outtab           = gt_anea
      IT_FIELDCATALOG     = gt_fieldcatalog.

* §4. Create hierarchy (nodes and leaves)
  perform create_hierarchy.

* §5. Send data to frontend.
  call method g_alv_tree->frontend_update.

ENDFORM.                    " INIT_TREE
*&---------------------------------------------------------------------*
*&      Form  BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
form build_hierarchy_header changing
                               p_hierarchy_header type treev_hhdr.

  p_hierarchy_header-heading   = 'Soc/ANLN1/ANLN2/Año'(300).
  p_hierarchy_header-tooltip   = 'Activo Fijo'(400).
  p_hierarchy_header-width     = 50.
  p_hierarchy_header-width_pix = ' '.

ENDFORM.                    " BUILD_HIERARCHY_HEADER
*&---------------------------------------------------------------------*
*&      Form  CREATE_HIERARCHY
*&---------------------------------------------------------------------*
FORM CREATE_HIERARCHY .
  data: l_node_text  type lvc_value,
        l_node_key   type lvc_nkey,
        l_node_key2  type lvc_nkey,
        l_relat_key  type lvc_nkey,
        l_last_key   type lvc_nkey,
        e_anek       like anek,
        e_anea       like anea.
*
  LOOP AT T_ANEK.
    move-corresponding t_anek to e_anek.
    at new anln1.
      concatenate e_anek-bukrs '-' e_anek-anln1 '-' e_anek-anln2 '-'
                  e_anek-gjahr into l_node_text.

      perform add_grafos using    l_node_text
                                  ' '
                         changing l_node_key.
    endat.
*
    CONCATENATE e_ANEK-lnran '-' e_ANEK-BLDAT+6(02) '.'
    e_ANEK-BLDAT+4(02) '.' e_ANEK-BLDAT(04)  INTO l_node_text.


*    move e_ANEK-lnran  to l_node_text.

    perform add_grafos using    l_node_text
                                l_node_key
                       changing l_node_key2.
*
    case 'X'.
      when p_todo OR p_boraju.
        loop at t_anep where anln1 eq e_anek-anln1 and
                             anln2 eq e_anek-anln2 and
                             lnran eq e_anek-lnran.

          move 'ANEP'  to l_node_text.


          move-corresponding t_anep to salida.
          perform add_anep using      salida
                                      l_node_text
                                      l_node_key2
                             changing l_last_key.
        endloop.
*
        loop at t_anea where anln1 eq e_anek-anln1 and
                             anln2 eq e_anek-anln2 and
                             lnran eq e_anek-lnran.

          move 'ANEA'  to l_node_text.
          move-corresponding t_anea to salida.
          perform add_anep using      salida
                                      l_node_text
                                      l_node_key2
                             changing l_last_key.
        endloop.
      when p_actual.
        loop at t_anep_S where anln1 eq e_anek-anln1 and
                               anln2 eq e_anek-anln2 and
                               lnran eq e_anek-lnran.




          move 'ANEP'  to l_node_text.
          move-corresponding t_anep_S to salida.
          perform add_anep using      salida
                                      l_node_text
                                      l_node_key2
                             changing l_last_key.
        endloop.
*
        loop at t_anea_S where anln1 eq e_anek-anln1 and
                               anln2 eq e_anek-anln2 and
                               lnran eq e_anek-lnran.

          move 'ANEA'  to l_node_text.
          move-corresponding t_anea_S to salida.
          perform add_anep using      salida
                                      l_node_text
                                      l_node_key2
                             changing l_last_key.
        endloop.
    endcase.
  ENDLOOP.
ENDFORM.                    " CREATE_HIERARCHY
*&---------------------------------------------------------------------*
*&      Form  ADD_GRAFOS
*&---------------------------------------------------------------------*
FORM ADD_GRAFOS  USING    P_L_NODE_TEXT
                          p_relat_key  type lvc_nkey
                 CHANGING P_L_NODE_KEY type lvc_nkey.

  data : ls_ANEa  type ANEA.

  call method g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = p_l_node_text
    IMPORTING
      e_new_node_key   = p_l_node_key.
ENDFORM.                    " ADD_GRAFOS
*&---------------------------------------------------------------------*
*&      Form  ADD_ANEP
*&---------------------------------------------------------------------*
FORM ADD_ANEP  USING    P_T_ANEA       structure salida
                        P_L_NODE_TEXT
                        p_relat_key    type lvc_nkey
               CHANGING P_L_LAST_KEY   type lvc_nkey.

  call method g_alv_tree->add_node
    EXPORTING
      i_relat_node_key = p_relat_key
      i_relationship   = cl_gui_column_tree=>relat_last_child
      i_node_text      = p_l_node_text
      is_outtab_line   = P_T_ANEA
    IMPORTING
      e_new_node_key   = P_L_LAST_KEY.
ENDFORM.                    " ADD_ANEP

*&---------------------------------------------------------------------*
*&      Form  EXIT_PROGRAM
*&---------------------------------------------------------------------*
FORM EXIT_PROGRAM .
  call method g_custom_container->free.
  leave program.
ENDFORM.                    " EXIT_PROGRAM
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
FORM BUILD_FIELDCATALOG .
  DATA: ls_fieldcatalog    TYPE lvc_s_fcat,
        tt_fieldcatalog    TYPE lvc_t_fcat,
        tt_fieldcatalog2   TYPE lvc_t_fcat,
        L_NUM1 TYPE I,
        L_NUM2 TYPE I.

  L_NUM1 = 1.
  L_NUM2 = 20.

  REFRESH Gt_fieldcatalog.
* The following function module generates a fieldcatalog according
* to a given structure.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ANEA'
    CHANGING
      ct_fieldcat      = tt_fieldcatalog.
*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ANEP'
    CHANGING
      ct_fieldcat      = tt_fieldcatalog2.
*
  LOOP AT tt_fieldcatalog2 INTO ls_fieldcatalog.
    CASE ls_fieldcatalog-fieldname.
      WHEN  'BWASL' OR 'ANBTR' OR 'NAFAB' OR 'SAFAB' OR 'ZINSB'.
        APPEND ls_fieldcatalog TO Tt_fieldcatalog.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
*
  LOOP AT tt_fieldcatalog INTO ls_fieldcatalog.
    CASE ls_fieldcatalog-fieldname.
      WHEN 'BUKRS' OR 'ANLN1' OR 'ANLN2' OR 'GJAHR' OR 'LNRAN'.
        ls_fieldcatalog-no_out  = 'X'.
        ls_fieldcatalog-KEY     = ' '.
        ls_fieldcatalog-KEY_SEL = ' '.
        ls_fieldcatalog-COL_POS = L_NUM1.
        ADD 1 TO L_NUM1.
      WHEN 'BWASL'.
        ls_fieldcatalog-OUTPUTLEN = 5.
        ls_fieldcatalog-COL_POS = L_NUM1.
        ADD 1 TO L_NUM1.
      WHEN  'AFABE'.
        ls_fieldcatalog-OUTPUTLEN = 5.
        ls_fieldcatalog-COL_POS = L_NUM1.
        ADD 1 TO L_NUM1.

      WHEN  'ANBTR' OR 'NAFAB' OR 'SAFAB' OR 'ZINSB'.
        ls_fieldcatalog-do_sum  = 'X'.
        ls_fieldcatalog-h_ftype = 'SUM'.
        ls_fieldcatalog-KEY_SEL = 'X'.
        ls_fieldcatalog-COL_POS = L_NUM1.
        ADD 1 TO L_NUM1.
      WHEN 'AUFWV' OR 'INVZV' OR 'AAFAV' OR 'NAFAV' OR 'SAFAV' OR
           'MAFAV' OR 'AUFNV' OR 'AUFWL' OR 'INVZL' OR 'NAFAL' OR
           'SAFAL' OR 'AAFAL' OR 'MAFAL' OR 'AUFNL' OR 'ERLBT' OR
           'VERKO' OR 'SANWV'.
        ls_fieldcatalog-do_sum  = 'X'.
        ls_fieldcatalog-h_ftype = 'SUM'.
        ls_fieldcatalog-COL_POS = L_NUM2.
        ADD 1 TO L_NUM2.
      WHEN OTHERS.
        continue.
    ENDCASE.
    APPEND ls_fieldcatalog TO gt_fieldcatalog.
  ENDLOOP.
*
  SORT gt_fieldcatalog BY COL_POS.
ENDFORM.                    " BUILD_FIELDCATALOG
