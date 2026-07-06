FUNCTION ZBUSCACTA.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IBUKRS) TYPE  BUKRS
*"  TABLES
*"      OZTBPMCTA TYPE  ZTBPMCTA
*"----------------------------------------------------------------------



SELECT SKB1~SAKNR SKAT~TXT20 INTO CORRESPONDING FIELDS OF TABLE oztbpmcta
FROM SKB1 INNER JOIN   SKAT ON SKB1~SAKNR = SKAT~SAKNR
WHERE ( SKB1~BUKRS = IBUKRS ).




ENDFUNCTION.
