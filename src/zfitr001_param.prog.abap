*&---------------------------------------------------------------------*
*&  Include           ZFITR001_PARAM
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-B01.
parameters    :
              p_BUKRS like FEBKO-BUKRS obligatory.   "sociedad
*             p_HBKID like FEBKO-HBKID.   "Banco propio

select-options:
                 s_HBKID for FEBKO-HBKID obligatory,   "Banco propio
                 S_HKTID FOR FEBKO-HKTID.    "cuenta corriente bancaria
*                s_ktonr FOR febko-ktonr,
*                S_WAERS FOR FEBKO-WAERS.


PARAMETERS:  P_FILE TYPE FILENAME
                        DEFAULT 'C:\'
                        OBLIGATORY MEMORY ID A,   "Archivo de Carga
            P_TYPE LIKE RLGRAP-FILETYPE DEFAULT 'ASC' OBLIGATORY,
            p_file2 TYPE filename DEFAULT 'C:\auszug.txt' obligatory,  "auszug.
            p_file3 TYPE filename DEFAULT 'C:\umsatz.txt' obligatory.  "umsatz. "Tipo de Archivo

*PARAMETERS: P_LIST(20) AS LISTBOX VISIBLE LENGTH 10.
PARAMETERS kz_app as checkbox default 'X'.    "RADIOBUTTON GROUP 0001 DEFAULT 'X'.

PARAMETERS: LDS_NAME     LIKE FILENAME-FILEINTERN
                         DEFAULT 'ZCB_FICHEROS'.


  SELECTION-SCREEN END OF BLOCK B1.
