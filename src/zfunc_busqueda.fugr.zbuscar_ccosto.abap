FUNCTION ZBUSCAR_CCOSTO.
*"--------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IBUKRS) TYPE  BUKRS
*"     VALUE(IKOSTL) TYPE  KOSTL
*"  EXPORTING
*"     VALUE(EPKZER) TYPE  PKZER
*"     VALUE(EMENSAJE) TYPE  KLTXT correciones
*"--------------------------------------------------------------------
DATA: EDATBI TYPE DATBI.


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT  SINGLE CSKS~PKZER INTO EPKZER
*FROM CSKS
*WHERE  CSKS~BUKRS EQ IBUKRS   AND
*       CSKS~KOSTL EQ IKOSTL   AND
*       CSKS~DATBI >= SY-DATUM.
*
* NEW CODE
SELECT CSKS~PKZER
UP TO 1 ROWS  INTO EPKZER
FROM CSKS
WHERE  CSKS~BUKRS EQ IBUKRS   AND
       CSKS~KOSTL EQ IKOSTL   AND
       CSKS~DATBI >= SY-DATUM ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01



    IF sy-subrc <> 0.
      EPKZER :='N'.
      EMENSAJE :='NO EXISTE O NO ESTA VIGENTE CENTRO DE COSTO.'.
    ELSE.
      IF EPKZER EQ 'X'.
          EMENSAJE :='CENTRO DE COSTO BLOQUEADO'.
      ELSE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT  SINGLE CSKS~DATBI INTO EDATBI
*          FROM CSKS
*          WHERE  CSKS~BUKRS EQ IBUKRS   AND
*                 CSKS~KOSTL EQ IKOSTL AND
*                 CSKS~DATBI >= SY-DATUM.
*
* NEW CODE
          SELECT CSKS~DATBI
          UP TO 1 ROWS  INTO EDATBI
          FROM CSKS
          WHERE  CSKS~BUKRS EQ IBUKRS   AND
                 CSKS~KOSTL EQ IKOSTL AND
                 CSKS~DATBI >= SY-DATUM ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          if SY-DATUM <= EDATBI.
              EPKZER :='E'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT  SINGLE CSKT~LTEXT INTO EMENSAJE
*              FROM CSKT
*              WHERE  CSKT~KOSTL = IKOSTL.
*
* NEW CODE
              SELECT CSKT~LTEXT
              UP TO 1 ROWS  INTO EMENSAJE
              FROM CSKT
              WHERE  CSKT~KOSTL = IKOSTL ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          else.
              EPKZER :='N'.
              EMENSAJE :='CENTRO DE COSTO NO VIGENTE'.
          endif.



      ENDIF.
    ENDIF.





ENDFUNCTION.
