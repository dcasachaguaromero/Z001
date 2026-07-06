FUNCTION ZBUSCA_FECHA_CONTABLE.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IBUKRS) TYPE  BUKRS
*"     VALUE(IBELNR) TYPE  BELNR_D
*"     VALUE(IGJAHR) TYPE  GJAHR
*"  TABLES
*"      FECHASCONT STRUCTURE  ZFECHACON
*"----------------------------------------------------------------------


SELECT  BKPF~BELNR BKPF~BUDAT INTO CORRESPONDING FIELDS OF TABLE FECHASCONT
FROM BKPF
WHERE  BKPF~BUKRS EQ IBUKRS   AND
       BKPF~BELNR EQ IBELNR   AND
       BKPF~GJAHR EQ IGJAHR.






ENDFUNCTION.
