REPORT ZACE8T MESSAGE-ID AD.

*=================================================
*     ACE-ABAP 8 for 4.7, ECC 5.0 and higher
*
* Copyright © 1996 - 2014 PricewaterhouseCoopers.
*              All rights reserved.
* PricewaterhouseCoopers refers to the network of
*     member firms of PricewaterhouseCoopers
*   International Limited, each of which is a
*     separate and independent legal entity.
*=================================================

*------------------------------------------------*
PARAMETERS: SP(1)        TYPE C OBLIGATORY
                         DEFAULT 'I'.
PARAMETERS: PARFLAG(1)   TYPE C
                         DEFAULT 'N'.
*------------------------------------------------*

*------------------------------------------------*
* VARIABLES                                      *
*------------------------------------------------*
DATA: PATH(100)    TYPE C
  VALUE '/MEDIOS/ACE/'
     ,CDP(4)       TYPE C
                   VALUE '1101'
     ,REPLCHAR(1)  TYPE C
                   VALUE '`'
     ,SELDATE      TYPE D
                   VALUE '20140701'
     ,NUM(4)       TYPE C
                   VALUE '1709'
     ,FILELENG     TYPE I
                   VALUE '010485760'
     ,FTYPE(1)     TYPE C
                   VALUE ''.
*------------------------------------------------*

*------------------------------------------------*
* DATA DECLARATION                               *
*------------------------------------------------*
DATA: FILENAM(400)
     ,FILENA2(400)
     ,FILENA4(400)
     ,TEXT(400)
     ,ZEILE(400)
     ,TREC(4000)
     ,DOWNDIR(400)
     ,MESS(400)
     ,NEWTRANSBYTE(10) TYPE N
     ,NEWTRANSREC(10) TYPE N
     ,CURTRANSBYTE(10) TYPE N
     ,CURTRANSREC(10) TYPE N
     ,NEWTRANSBYT2(10) TYPE N
     ,NEWTRANSRE2(10) TYPE N
     ,CURTRANSBYT2(10) TYPE N
     ,CURTRANSRE2(10) TYPE N
     ,NEWTRANSBYT3(10) TYPE N
     ,NEWTRANSRE3(10) TYPE N
     ,NEWTRANSBYT4(10) TYPE N
     ,NEWTRANSRE4(10) TYPE N
     ,NEWFILENUM(4) TYPE N
     ,NEWFILENU2(4) TYPE N
     ,NEWFILENU4(4) TYPE N
     ,NEWFILELIST(10000) TYPE C
     ,TRANSTXT(1) TYPE C VALUE '"'
     ,TRANSSEP(1) TYPE C VALUE ''''
     ,INVCHAR1 TYPE x value '0A'
     ,INVCHAR2 TYPE x value '0D'
     ,INVCONV TYPE ref to CL_ABAP_CONV_IN_CE
     ,INVXSTR TYPE xstring
     ,INVSTR1 TYPE string
     ,INVSTR2 TYPE string.

PERFORM MAINPROG.

*-----------------------------------------------*
* MAIN PROGRAM SECTION                          *
*-----------------------------------------------*
FORM MAINPROG.
  IF SP = 'I'.
    CONCATENATE 'Do not start manually'
                'this program (use ZACE8M)!'
                INTO MESS
                SEPARATED BY SPACE.
    MESSAGE ID 'AD' TYPE 'S' NUMBER 10
                      WITH MESS.
    LEAVE PROGRAM.
  ENDIF.

  INVXSTR = INVCHAR1.

  CALL METHOD CL_ABAP_CONV_IN_CE=>CREATE
    EXPORTING
      INPUT       = INVXSTR
      ENCODING    = 'UTF-8'
      REPLACEMENT = '?'
      IGNORE_CERR = ABAP_TRUE
    RECEIVING
      CONV        = INVCONV.

  CALL METHOD INVCONV->READ
    IMPORTING
      DATA = INVSTR1.

  INVXSTR = INVCHAR2.

  CALL METHOD CL_ABAP_CONV_IN_CE=>CREATE
    EXPORTING
      INPUT       = INVXSTR
      ENCODING    = 'UTF-8'
      REPLACEMENT = '?'
      IGNORE_CERR = ABAP_TRUE
    RECEIVING
      CONV        = INVCONV.

  CALL METHOD INVCONV->READ
    IMPORTING
      DATA = INVSTR2.

  NEWFILENUM = NUM.
  NEWFILELIST = ''.

  PERFORM PROC.

  EXPORT NEWTRANSBYTE TO MEMORY ID 'ACEByte'.
  EXPORT NEWTRANSREC  TO MEMORY ID 'ACERec'.
  EXPORT NEWFILENUM   TO MEMORY ID 'ACEFNum'.
ENDFORM.

*------------------------------------------------*
*       FORM GETFILENAME                         *
*------------------------------------------------*
FORM GETFILENAME.
  CONCATENATE PATH FTYPE NEWFILENUM
            '.QJF'
              INTO FILENAM.
ENDFORM.

*------------------------------------------------*
*       FORM GETFILENAM2                         *
*------------------------------------------------*
FORM GETFILENAM2.
  CONCATENATE PATH FTYPE NEWFILENU2
            '.QJF'
              INTO FILENA2.
ENDFORM.

*------------------------------------------------*
*       FORM GETFILENAM4                         *
*------------------------------------------------*
FORM GETFILENAM4.
  CONCATENATE PATH FTYPE NEWFILENU4
            '.QJF'
              INTO FILENA4.
ENDFORM.

*------------------------------------------------*
*       FORM FILEOPEN                            *
*------------------------------------------------*
FORM FILEOPEN USING FILESPEC OPENTYPE.
  IF OPENTYPE = 'OUTPUT'.
      OPEN DATASET FILESPEC FOR OUTPUT
                   IN LEGACY TEXT MODE
                   CODE PAGE CDP
                   REPLACEMENT CHARACTER REPLCHAR
                   IGNORING CONVERSION ERRORS
                   MESSAGE MESS.
    ELSE.
      OPEN DATASET FILESPEC FOR APPENDING
                   IN LEGACY TEXT MODE
                   CODE PAGE CDP
                   REPLACEMENT CHARACTER REPLCHAR
                   IGNORING CONVERSION ERRORS
                   MESSAGE MESS.
    ENDIF.

    IF SY-SUBRC <> 0.
      MOVE SY-SUBRC            TO TEXT.
      CONCATENATE 'File-open-error:'
                  FILESPEC TEXT MESS
                  INTO ZEILE SEPARATED BY SPACE.
      WRITE / ZEILE.
      LEAVE PROGRAM.
    ENDIF.
ENDFORM.

*------------------------------------------------*
*       FORM FILECLOS                            *
*------------------------------------------------*
FORM FILECLOS USING FILESPEC.
    CLOSE DATASET FILESPEC.

    IF SY-SUBRC <> 0.
      MOVE SY-SUBRC            TO TEXT.
      CONCATENATE 'File-close-error:'
                  FILESPEC TEXT MESS
                  INTO ZEILE SEPARATED BY SPACE.
      WRITE / ZEILE.
      LEAVE PROGRAM.
    ENDIF.
ENDFORM.

*------------------------------------------------*
*       FORM TRANS                               *
*------------------------------------------------*
FORM TRANS.
  DATA: REALTRANSBYTE TYPE I,
        RECLEN TYPE I.

  REALTRANSBYTE = CURTRANSBYTE + CURTRANSREC * 2.

  IF REALTRANSBYTE > FILELENG.
    PERFORM FILECLOS USING FILENAM.
    CURTRANSBYTE = 0.
    CURTRANSREC = 0.
    IF NEWFILENU2 >  NEWFILENUM.
      NEWFILENUM = NEWFILENU2 + 1.
    ELSE.
      NEWFILENUM = NEWFILENUM + 1.
    ENDIF.

    PERFORM GETFILENAME.
    PERFORM FILEOPEN USING FILENAM 'OUTPUT'.
    CONCATENATE NEWFILELIST 'S'
                INTO NEWFILELIST.
  ENDIF.

  REPLACE ALL OCCURRENCES OF INVSTR1
          IN TREC WITH ' '.
  REPLACE ALL OCCURRENCES OF INVSTR2
          IN TREC WITH ' '.

  RECLEN = STRLEN( TREC ).

  TRANSFER TREC TO FILENAM.

  NEWTRANSBYTE = NEWTRANSBYTE + RECLEN.
  CURTRANSBYTE = CURTRANSBYTE + RECLEN.

  NEWTRANSREC =  NEWTRANSREC + 1.
  CURTRANSREC =  CURTRANSREC + 1.
ENDFORM.

*------------------------------------------------*
*       FORM PROC                                *
*------------------------------------------------*
FORM PROC.

ENDFORM.
