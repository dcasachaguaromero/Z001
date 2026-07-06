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


SELECT  SINGLE CSKS~PKZER INTO EPKZER
FROM CSKS
WHERE  CSKS~BUKRS EQ IBUKRS   AND
       CSKS~KOSTL EQ IKOSTL   AND
       CSKS~DATBI >= SY-DATUM.



    IF sy-subrc <> 0.
      EPKZER :='N'.
      EMENSAJE :='NO EXISTE O NO ESTA VIGENTE CENTRO DE COSTO.'.
    ELSE.
      IF EPKZER EQ 'X'.
          EMENSAJE :='CENTRO DE COSTO BLOQUEADO'.
      ELSE.
          SELECT  SINGLE CSKS~DATBI INTO EDATBI
          FROM CSKS
          WHERE  CSKS~BUKRS EQ IBUKRS   AND
                 CSKS~KOSTL EQ IKOSTL AND
                 CSKS~DATBI >= SY-DATUM.

          if SY-DATUM <= EDATBI.
              EPKZER :='E'.
              SELECT  SINGLE CSKT~LTEXT INTO EMENSAJE
              FROM CSKT
              WHERE  CSKT~KOSTL = IKOSTL.
          else.
              EPKZER :='N'.
              EMENSAJE :='CENTRO DE COSTO NO VIGENTE'.
          endif.



      ENDIF.
    ENDIF.





ENDFUNCTION.
