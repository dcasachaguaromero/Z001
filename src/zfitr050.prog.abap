*&---------------------------------------------------------------------*
*& Report  ZFITR050
*&---------------------------------------------------------------------*
*&  Marca eliminaciones en archivo de NOVEDADES (ZNOVEDADBANCO
*&---------------------------------------------------------------------*

REPORT  zfitr050.

TABLES: znovedadbanco, zbancossbif, t001.

DATA: soc(4),
      nom(15)             TYPE n,
      fec                 TYPE sy-datum,
      sw(1)               TYPE n,
      men(30)             TYPE c,
      mot(90)             TYPE c,
      nombrefuncion(12),
      reg                 type znovedadbanco.

selection-screen begin of block marco1 with frame title text-001.
PARAMETER : bukrs    LIKE bkpf-bukrs             obligatory.
PARAMETER : ubnkl    LIKE znovedadbanco-banco    obligatory.
PARAMETER : identif  LIKE znovedadbanco-identif  obligatory.
PARAMETER : motivo   LIKE mot                    obligatory.
 selection-screen end of block marco1 .

*&---------------------------------------------------------------------*
*&     Validación de parámetros ingresados
*&---------------------------------------------------------------------*
  at selection-screen on bukrs.
sw = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM t001
*                WHERE bukrs = bukrs.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM t001
                WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

 IF sy-subrc <> 0.
      message w899(v1) with 'Sociedad no existe'.
      sw = sw + 1.
 endif.

  at selection-screen on ubnkl.

sw = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* SELECT SINGLE * FROM zbancossbif
*                WHERE banco   = ubnkl.
*
* NEW CODE
 SELECT *
 UP TO 1 ROWS  FROM zbancossbif
                WHERE banco   = ubnkl ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

 IF sy-subrc <> 0.
      message w899(v1) with 'Banco No en tabla ZBANCOSSBIF'.
      sw = sw + 1.
 endif.

IF  ubnkl+0(3) <> '012' AND  ubnkl+0(3) <> '027' AND ubnkl+0(3) <> '037'.
      message w899(v1) with 'Banco No habilitado para NOVEDADES'.
      sw = sw + 1.
ENDIF.

  at selection-screen on identif.
sw = 0.

*--------------------------------------------------------------------------------
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT SINGLE * FROM znovedadbanco
*                WHERE sociedad = bukrs
*                  AND banco    = ubnkl
*                  AND identif  = identif.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM znovedadbanco
                WHERE sociedad = bukrs
                  AND banco    = ubnkl
                  AND identif  = identif ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

IF sy-subrc <> 0.
      message w899(v1) with 'No existe Novedad, revise datos'.
       sw = sw + 1.
else.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM znovedadbanco
*                WHERE sociedad = bukrs
*                  AND banco    = ubnkl
*                  AND identif  = identif
*                  and estado   = 0.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM znovedadbanco
                WHERE sociedad = bukrs
                  AND banco    = ubnkl
                  AND identif  = identif
                  and estado   = 0 ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
   IF sy-subrc <> 0.
      message w899(v1) with 'Novedad existe, pero no pendiente de proceso'.
   endif.
Endif.

   at selection-screen on motivo.

sw = 0.

IF motivo is initial.
   message w899(v1) with 'Debe ingresar motivo de eliminacion'.
   sw = sw + 1.
endif.

  at selection-screen.

if sw > 0.
   message i899(v1) with 'Hubo errores, no se procesa'.
   exit.
else.
   reg = znovedadbanco.
   update  znovedadbanco
     set estado = 8
         moteli = motivo
         feceli = sy-datum
         horeli = sy-uzeit
         usreli = sy-uname
                  WHERE sociedad = bukrs
                  AND banco    = ubnkl
                  AND nomina   = znovedadbanco-nomina
                  AND fecha    = znovedadbanco-fecha
                  AND hora     = znovedadbanco-hora
                  AND identif  = identif
                  and estado   = 0.
   message i899(v1) with 'Registro marcado como ELIMINADO'.
endif.
