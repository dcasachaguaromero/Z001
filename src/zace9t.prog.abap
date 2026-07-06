REPORT ZACE9T MESSAGE-ID AD.

*=================================================
*     ACE-ABAP 9 for 4.7, ECC 5.0 and higher
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
PARAMETERS: DWNLFLAG(1)  TYPE C
                         DEFAULT 'N'.
PARAMETERS: GEN(100)     TYPE C
                         DEFAULT ''.
PARAMETERS: FLDLST(1000) TYPE C
                         DEFAULT ''.
*------------------------------------------------*

*------------------------------------------------*
* VARIABLES                                      *
*------------------------------------------------*
DATA: PATH(100)    TYPE C VALUE
  '/Pwc/Pwc/'
     ,SELDATE      TYPE D VALUE
  '20240101'
     ,FILELENG     TYPE I VALUE
  20971520
     ,FEXT(4)      TYPE C VALUE
  '.XJF'
     ,FTYPE(1)     TYPE C VALUE
  'O'
     ,TABNAME(30)  TYPE C VALUE
  'ZFI_OB52_T001B'
     ,TABTEXT(60)  TYPE C VALUE
  'Permitted Posting Periods'
     ,SCHEMA(50)   TYPE C VALUE
  'OTHER'
     ,QUERIES(1)   TYPE C VALUE
  'Y'.
*------------------------------------------------*

*------------------------------------------------*
* DATA DECLARATION                               *
*------------------------------------------------*
DATA: MNO TYPE I VALUE 0
     ,FNO TYPE I VALUE 0
     ,FBYTE(10) TYPE N VALUE 0
     ,FREC(10) TYPE N VALUE 0
     ,SREC(10) TYPE N VALUE 0
     ,TNAME(30) TYPE C VALUE ''
     ,TTEXT(60) TYPE C VALUE ''
     ,FN2 TYPE I VALUE 0
     ,FBYT2(10) TYPE N VALUE 0
     ,FRE2(10) TYPE N VALUE 0
     ,SRE2(10) TYPE N VALUE 0
     ,TNAM2(30) TYPE C VALUE ''
     ,TTEX2(60) TYPE C VALUE ''
     ,FN3 TYPE I VALUE 0
     ,FBYT3(10) TYPE N VALUE 0
     ,FRE3(10) TYPE N VALUE 0
     ,SRE3(10) TYPE N VALUE 0
     ,TNAM3(30) TYPE C VALUE ''
     ,TTEX3(60) TYPE C VALUE ''
     ,FN4 TYPE I VALUE 0
     ,FBYT4(10) TYPE N VALUE 0
     ,FRE4(10) TYPE N VALUE 0
     ,SRE4(10) TYPE N VALUE 0
     ,TNAM4(30) TYPE C VALUE ''
     ,TTEX4(60) TYPE C VALUE ''
     ,TXTSTR(400) TYPE C
     ,TXT2STR(400) TYPE C
     ,TREC(4000) TYPE C
     ,CONCAT(400) TYPE C
     ,HEXCHAR1 TYPE x value '0A'
     ,HEXCHAR2 TYPE x value '0D'
     ,HEXCHARS TYPE x value '09'
     ,INVCONV TYPE ref to CL_ABAP_CONV_IN_CE
     ,INVXSTR TYPE xstring
     ,TRANSH1 TYPE string
     ,TRANSH2 TYPE string
     ,TRANSHS TYPE string
     ,TRANSQ1(1) TYPE C VALUE '"'
     ,TRANSQ2(1) TYPE C VALUE ''''
     ,REPLQ(1) TYPE C VALUE '`'.

PERFORM MAINPROG.

COMMIT WORK AND WAIT.

*-----------------------------------------------*
* MAIN PROGRAM SECTION                          *
*-----------------------------------------------*
FORM MAINPROG.
  IF SP = 'I'.
    CONCATENATE 'Do not start manually'
                'this program (use ZACE9M)!'
                INTO CONCAT
                SEPARATED BY SPACE.
    MESSAGE ID 'AD' TYPE 'S' NUMBER 10
                      WITH CONCAT.
    LEAVE PROGRAM.
  ENDIF.

  INVXSTR = HEXCHAR1.

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
      DATA = TRANSH1.

  INVXSTR = HEXCHAR2.

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
      DATA = TRANSH2.

  INVXSTR = HEXCHARS.

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
      DATA = TRANSHS.

  PERFORM INITSTDPROC.

  PERFORM EXPB3.

  IF DWNLFLAG = 'Y'.
    PERFORM PROC.
  ENDIF.

  PERFORM EXPB45.

  PERFORM ENDSTDPROC.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB1REC                            *
*------------------------------------------------*
FORM EXPB1REC USING INFONAME INFOTYPE INFOVALTYPE
                                      INFOVALUE.
  DATA: BEGIN OF WB1
       ,INFODATETIME(14) TYPE C
       ,INFONAME(50) TYPE C
       ,INFOTYPE(1) TYPE C
       ,INFOVALTYPE(1) TYPE C
       ,INFOCVALUE(2000) TYPE C
       ,INFONVALUE(50) TYPE C
       ,END OF WB1.

  CLEAR WB1.
  CONCATENATE SY-DATUM
              SY-UZEIT
         INTO WB1-INFODATETIME.
  WB1-INFONAME = INFONAME.
  WB1-INFOTYPE = INFOTYPE.
  WB1-INFOVALTYPE = INFOVALTYPE.
  IF INFOVALTYPE = 'C'.
    WB1-INFOCVALUE = INFOVALUE.
  ELSE.
    WB1-INFONVALUE = INFOVALUE.
    SHIFT WB1-INFONVALUE
          LEFT DELETING LEADING '0'.
    CONDENSE WB1-INFONVALUE NO-GAPS.
  ENDIF.

  PERFORM FILEOPEN USING 'B' 1 'APPENDING'.

  CONCATENATE WB1-INFODATETIME
              WB1-INFONAME
              WB1-INFOTYPE
              WB1-INFOVALTYPE
              WB1-INFOCVALUE
              WB1-INFONVALUE
              INTO TREC
              SEPARATED BY TRANSHS.
  PERFORM FILETRANS USING 'B' 1.

  IF INFOTYPE = 'T' OR INFOTYPE = 'P'.
    CONCATENATE INFONAME ':' INTO TXTSTR.
    CONCATENATE TXTSTR INFOVALUE INTO CONCAT
                     SEPARATED BY SPACE.
    MESSAGE ID 'AD' TYPE 'S' NUMBER 10
                         WITH CONCAT.
  ELSEIF INFOTYPE = 'E'.
    CONCATENATE INFONAME ':' INTO TXTSTR.
    CONCATENATE TXTSTR INFOVALUE INTO CONCAT
                     SEPARATED BY SPACE.
    MESSAGE ID 'AD' TYPE 'E' NUMBER 10
                         WITH CONCAT.
  ENDIF.

  PERFORM FILECLOSE USING 'B' 1.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB2STDREC                         *
*------------------------------------------------*
FORM EXPB2STDREC USING PNO.
  CASE PNO.
    WHEN FNO.
      PERFORM EXPB2REC USING FNO TNAME TTEXT
                             FBYTE FREC.
    WHEN FN2.
      PERFORM EXPB2REC USING FN2 TNAM2 TTEX2
                             FBYT2 FRE2.
    WHEN FN3.
      PERFORM EXPB2REC USING FN3 TNAM3 TTEX3
                             FBYT3 FRE3.
    WHEN FN4.
      PERFORM EXPB2REC USING FN4 TNAM4 TTEX4
                             FBYT4 FRE4.
  ENDCASE.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB2REC                            *
*------------------------------------------------*
FORM EXPB2REC USING FILENUMBER TABLENAME TABLEDESC
                    NUMBYTES NUMRECS.
  DATA: BEGIN OF WB2
       ,FTYPE(1) TYPE C
       ,FILENUMBER(5) TYPE N
       ,TABLENAME(80) TYPE C
       ,TABLEDESC LIKE DD02V-DDTEXT
       ,NUMBYTES(15) TYPE C
       ,NUMRECS(15) TYPE C
       ,END OF WB2.

  CLEAR WB2.
  WB2-FTYPE = FTYPE.
  WB2-FILENUMBER = FILENUMBER.
  WB2-TABLENAME = TABLENAME.
  WB2-TABLEDESC = TABLEDESC.
  WB2-NUMBYTES = NUMBYTES.
  WB2-NUMRECS = NUMRECS.

  SHIFT WB2-NUMBYTES
        LEFT DELETING LEADING '0'.
  CONDENSE WB2-NUMBYTES NO-GAPS.
  IF WB2-NUMBYTES = ''.
     WB2-NUMBYTES = '0'.
  ENDIF.
  SHIFT WB2-NUMRECS
        LEFT DELETING LEADING '0'.
  CONDENSE WB2-NUMRECS NO-GAPS.
  IF WB2-NUMRECS = ''.
     WB2-NUMRECS = '0'.
  ENDIF.

  PERFORM CHARFIELDREPL USING WB2-FTYPE.
  PERFORM CHARFIELDREPL USING WB2-FILENUMBER.
  PERFORM CHARFIELDREPL USING WB2-TABLENAME.
  PERFORM CHARFIELDREPL USING WB2-TABLEDESC.

  PERFORM FILEOPEN USING 'B' 2 'APPENDING'.

  CONCATENATE WB2-FTYPE
              WB2-FILENUMBER
              WB2-TABLENAME
              WB2-TABLEDESC
              WB2-NUMBYTES
              WB2-NUMRECS
              INTO TREC
              SEPARATED BY TRANSHS.
  PERFORM FILETRANS USING 'B' 2.

  PERFORM FILECLOSE USING 'B' 2.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB3V                              *
*------------------------------------------------*
FORM EXPB3V USING TABLENAME POSITION FIELDNAME
                  REFTABLE.
  DATA: BEGIN OF WB3
       ,TABLENAME(80) TYPE C
       ,FIELDNAME(80) TYPE C
       ,POSITION(6) TYPE C
       ,LENGTH(6) TYPE C
       ,CHECKTABLE LIKE DD03L-CHECKTABLE
       ,KEYFLAG LIKE DD03L-KEYFLAG
       ,DDTEXT LIKE DD04T-DDTEXT
       ,REPTEXT LIKE DD04T-REPTEXT
       ,DOMNAME LIKE DD03L-DOMNAME
       ,END OF WB3.

  DATA: DATATYPE LIKE DD03L-DATATYPE
       ,DECIMALS LIKE DD03L-DECIMALS
       ,ROLLNAME LIKE DD03L-ROLLNAME.

  CLEAR WB3.

  SELECT SINGLE LENG
                CHECKTABLE
                KEYFLAG
                DOMNAME
                DECIMALS
                DATATYPE
                ROLLNAME
          INTO (WB3-LENGTH
               ,WB3-CHECKTABLE
               ,WB3-KEYFLAG
               ,WB3-DOMNAME
               ,DECIMALS
               ,DATATYPE
               ,ROLLNAME
               )
           FROM DD03L
          WHERE TABNAME = REFTABLE
            AND FIELDNAME = FIELDNAME
            AND AS4LOCAL = 'A'.

  IF SY-SUBRC = 0.
    SELECT SINGLE DDTEXT
                  REPTEXT
             INTO (WB3-DDTEXT
                  ,WB3-REPTEXT
                  )
             FROM DD04T
            WHERE ROLLNAME = ROLLNAME
              AND DDLANGUAGE = SY-LANGU
              AND AS4LOCAL = 'A'.
  ELSE.
    WB3-LENGTH = 1000.
    WB3-DDTEXT = 'No Text'.
    WB3-REPTEXT = 'No Text'.
  ENDIF.

  IF DATATYPE = 'RAW'.
    WB3-LENGTH = WB3-LENGTH * 4.
  ELSEIF DATATYPE = 'DEC' OR
         DATATYPE = 'CURR'.
    WB3-LENGTH = WB3-LENGTH + DECIMALS + 5.
  ENDIF.
  IF WB3-LENGTH > 255.
    WB3-LENGTH = 255.
  ENDIF.

  PERFORM EXPB3REC USING TABLENAME
                         POSITION FIELDNAME
                         WB3-LENGTH WB3-CHECKTABLE
                         WB3-KEYFLAG WB3-DDTEXT
                         WB3-REPTEXT WB3-DOMNAME.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB3W                              *
*------------------------------------------------*
FORM EXPB3W USING TABLENAME POSITION FIELDNAME
                  LENGTH DDTEXT REPTEXT.
  PERFORM EXPB3REC USING TABLENAME
                         POSITION FIELDNAME
                         LENGTH '' ''
                         DDTEXT REPTEXT ''.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB3X                              *
*------------------------------------------------*
FORM EXPB3X USING POSITION FIELDNAME REFTABLE.
  PERFORM EXPB3V USING TABNAME POSITION
                       FIELDNAME REFTABLE.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB3Y                              *
*------------------------------------------------*
FORM EXPB3Y USING POSITION FIELDNAME
                  LENGTH DDTEXT REPTEXT.
  PERFORM EXPB3REC USING TABNAME
                         POSITION FIELDNAME
                         LENGTH '' ''
                         DDTEXT REPTEXT ''.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB3REC                            *
*------------------------------------------------*
FORM EXPB3REC USING TABLENAME POSITION FIELDNAME
                    LENGTH CHECKTABLE KEYFLAG
                    DDTEXT REPTEXT DOMNAME.
  DATA: BEGIN OF WB3
       ,FTYPE(1) TYPE C
       ,TABLENAME(80) TYPE C
       ,FIELDNAME(80) TYPE C
       ,POSITION(6) TYPE C
       ,LENGTH(6) TYPE C
       ,CHECKTABLE LIKE DD03L-CHECKTABLE
       ,KEYFLAG LIKE DD03L-KEYFLAG
       ,DDTEXT LIKE DD04T-DDTEXT
       ,REPTEXT LIKE DD04T-REPTEXT
       ,DOMNAME LIKE DD03L-DOMNAME
       ,END OF WB3.

  CLEAR WB3.
  WB3-FTYPE = FTYPE.
  WB3-TABLENAME = TABLENAME.
  WB3-FIELDNAME = FIELDNAME.
  WB3-POSITION = POSITION.
  WB3-LENGTH = LENGTH.
  WB3-CHECKTABLE = CHECKTABLE.
  WB3-KEYFLAG = KEYFLAG.
  WB3-DDTEXT = DDTEXT.
  WB3-REPTEXT = REPTEXT.
  WB3-DOMNAME = DOMNAME.

  SHIFT WB3-POSITION
        LEFT DELETING LEADING '0'.
  CONDENSE WB3-POSITION NO-GAPS.
  SHIFT WB3-LENGTH
        LEFT DELETING LEADING '0'.
  CONDENSE WB3-LENGTH NO-GAPS.

  PERFORM CHARFIELDREPL USING WB3.

  PERFORM FILEOPEN USING 'B' 3 'APPENDING'.

  CONCATENATE WB3-FTYPE
              WB3-TABLENAME
              WB3-FIELDNAME
              WB3-POSITION
              WB3-LENGTH
              WB3-CHECKTABLE
              WB3-KEYFLAG
              WB3-DDTEXT
              WB3-REPTEXT
              WB3-DOMNAME
              INTO TREC
              SEPARATED BY TRANSHS.

  PERFORM FILETRANS USING 'B' 3.

  PERFORM FILECLOSE USING 'B' 3.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB4RECY                           *
*------------------------------------------------*
FORM EXPB4RECY USING TABLENAME TABLETEXT TABLERECS.
  PERFORM EXPB4REC USING TABLENAME TABLETEXT
                   '' '' '' '' ''
                   '' '' '' '' ''
                   '' '' '' TABLERECS.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB4RECX                           *
*------------------------------------------------*
FORM EXPB4RECX.
  PERFORM EXPB4REC USING TNAME TTEXT
                   '' '' '' '' ''
                   '' '' '' '' ''
                   '' '' '' SREC.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB4REC                            *
*------------------------------------------------*
FORM EXPB4REC USING TABLENAME TABLETEXT
                    LANGFIELD TABNAMETEXT
                    LANGFIELDTEXT LIMIT MANDATORY
                    CLIENT FSD AGF SDV STAB
                    TOOBIG NOTEXIST NOTSELECTED
                    TABLERECS.

DATA: BEGIN OF WB4
     ,FTYPE(1) TYPE C
     ,TABNAME LIKE DD03L-TABNAME
     ,TABTEXT LIKE DD03T-DDTEXT
     ,LANGFIELD LIKE DD03L-FIELDNAME
     ,TABNAMETEXT LIKE DD03L-TABNAME
     ,LANGFIELDTEXT LIKE DD03L-FIELDNAME
     ,SCHEMA(50) TYPE C
     ,QUERIES(1) TYPE C
     ,LIMIT(20) TYPE C
     ,GENERATE(100) TYPE C
     ,MANDATORY(1) TYPE C
     ,CLIENT(1) TYPE C
     ,FSD(1) TYPE C
     ,AGF(1) TYPE C
     ,SDV(19) TYPE C
     ,STAB(19) TYPE C
     ,FLDLIST(1000) TYPE C
     ,TOOBIG(1) TYPE C
     ,NOTEXIST(1) TYPE C
     ,NOTSELECTED(1) TYPE C
     ,NUMRECS(15) TYPE C
     ,END OF WB4.

  WB4-FTYPE = FTYPE.
  WB4-TABNAME = TABLENAME.
  WB4-TABTEXT = TABLETEXT.
  WB4-LANGFIELD = LANGFIELD.
  WB4-TABNAMETEXT = TABNAMETEXT.
  WB4-LANGFIELDTEXT = LANGFIELDTEXT.
  WB4-SCHEMA = SCHEMA.
  WB4-QUERIES = QUERIES.
  WB4-LIMIT = LIMIT.
  WB4-GENERATE  = GEN.
  WB4-MANDATORY = MANDATORY.
  WB4-CLIENT = CLIENT.
  WB4-FSD = FSD.
  WB4-AGF = AGF.
  WB4-SDV = SDV.
  WB4-STAB = STAB.
  WB4-FLDLIST = FLDLST.
  WB4-TOOBIG = TOOBIG.
  WB4-NOTEXIST = NOTEXIST.
  WB4-NOTSELECTED = NOTSELECTED.
  WB4-NUMRECS = TABLERECS.

  SHIFT WB4-LIMIT LEFT DELETING LEADING '0'.
  CONDENSE WB4-LIMIT NO-GAPS.
  IF WB4-LIMIT = ''.
     WB4-LIMIT = '0'.
  ENDIF.
  SHIFT WB4-NUMRECS LEFT DELETING LEADING '0'.
  CONDENSE WB4-NUMRECS NO-GAPS.
  IF WB4-NUMRECS = ''.
     WB4-NUMRECS = '0'.
  ENDIF.

  PERFORM CHARFIELDREPL USING WB4.

  PERFORM FILEOPEN USING 'B' 4 'APPENDING'.

  CONCATENATE WB4-FTYPE
              WB4-TABNAME
              WB4-TABTEXT
              WB4-LANGFIELD
              WB4-TABNAMETEXT
              WB4-LANGFIELDTEXT
              WB4-SCHEMA
              WB4-QUERIES
              WB4-LIMIT
              WB4-GENERATE
              WB4-MANDATORY
              WB4-CLIENT
              WB4-FSD
              WB4-AGF
              WB4-SDV
              WB4-STAB
              WB4-FLDLIST
              WB4-TOOBIG
              WB4-NOTEXIST
              WB4-NOTSELECTED
              WB4-NUMRECS
              INTO TREC
              SEPARATED BY TRANSHS.

  PERFORM FILETRANS USING 'B' 4.

  PERFORM FILECLOSE USING 'B' 4.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB5REC                            *
*------------------------------------------------*
FORM EXPB5REC USING CHECKTABLE FORTABLE FORKEY.
  DATA: BEGIN OF WB5
       ,CHECKTABLE LIKE DD08VV-CHECKTABLE
       ,FORTABLE LIKE DD08VV-FORTABLE
       ,FORKEY LIKE DD08VV-FORKEY
       ,END OF WB5.

  CLEAR WB5.
  WB5-CHECKTABLE = CHECKTABLE.
  WB5-FORTABLE = FORTABLE.
  WB5-FORKEY = FORKEY.

  PERFORM CHARFIELDREPL USING WB5.

  PERFORM FILEOPEN USING 'B' 5 'APPENDING'.

  CONCATENATE WB5-CHECKTABLE
              WB5-FORTABLE
              WB5-FORKEY
              INTO TREC
              SEPARATED BY TRANSHS.

  PERFORM FILETRANS USING 'B' 5.

  PERFORM FILECLOSE USING 'B' 5.
ENDFORM.

*------------------------------------------------*
*       FORM FILEOPEN                            *
*------------------------------------------------*
FORM FILEOPEN USING PTYPE PNO POPENTYPE.
  DATA: FNAME(400) TYPE C.

  PERFORM GETFILENAME USING PTYPE PNO
                      CHANGING FNAME.

  IF POPENTYPE = 'OUTPUT'.
    OPEN DATASET FNAME FOR OUTPUT
                 IN TEXT MODE
                 ENCODING UTF-8
                 REPLACEMENT CHARACTER REPLQ
                 IGNORING CONVERSION ERRORS
                 MESSAGE TXT2STR.
  ELSE.
    OPEN DATASET FNAME FOR APPENDING
                 IN TEXT MODE
                 ENCODING UTF-8
                 REPLACEMENT CHARACTER REPLQ
                 IGNORING CONVERSION ERRORS
                 MESSAGE TXT2STR.
  ENDIF.

  IF SY-SUBRC <> 0.
    TXTSTR = SY-SUBRC.
    CONCATENATE 'File-Open-Error:' FNAME
                TXTSTR TXT2STR INTO CONCAT
                SEPARATED BY SPACE.
    MESSAGE ID 'AD' TYPE 'S' NUMBER 10
                                 WITH CONCAT.
**ins ini
*    EXIT.
    return.
**ins fin
  ENDIF.
ENDFORM.

*------------------------------------------------*
*       FORM FILECLOSE                           *
*------------------------------------------------*
FORM FILECLOSE USING PTYPE PNO.
  DATA: FNAME(400) TYPE C.

  PERFORM GETFILENAME USING PTYPE PNO
                      CHANGING FNAME.

  CLOSE DATASET FNAME.

  IF SY-SUBRC <> 0.
    TXTSTR = SY-SUBRC.
    CONCATENATE 'File-Close-Error:' FNAME TXTSTR
                INTO CONCAT
                SEPARATED BY SPACE.
    MESSAGE ID 'AD' TYPE 'S' NUMBER 10
                                 WITH CONCAT.
**ins ini
*    EXIT.
    return.
**ins fin
  ENDIF.
ENDFORM.

*------------------------------------------------*
*       FORM FILETRANS                           *
*------------------------------------------------*
FORM FILETRANS USING PTYPE PNO.
  DATA: FNAME(400) TYPE C.

  PERFORM GETFILENAME USING PTYPE PNO
                      CHANGING FNAME.

  REPLACE ALL OCCURRENCES OF TRANSH1
                             IN TREC WITH SPACE.
  REPLACE ALL OCCURRENCES OF TRANSH2
                             IN TREC WITH SPACE.
  REPLACE ALL OCCURRENCES OF TRANSQ1
                             IN TREC WITH REPLQ.
  REPLACE ALL OCCURRENCES OF TRANSQ2
                             IN TREC WITH REPLQ.

  TRANSFER TREC TO FNAME.
ENDFORM.

*------------------------------------------------*
*       FORM FILETRANSFER                        *
*------------------------------------------------*
FORM FILETRANSFER USING PTYPE
                  CHANGING PNO PBYTE PREC PSREC.
  DATA: REALTRANSBYTE TYPE I,
        RECLEN TYPE I.

  PERFORM FILETRANS USING PTYPE PNO.

  RECLEN = STRLEN( TREC ).
  PBYTE = PBYTE + RECLEN.
  PREC =  PREC + 1.
  PSREC =  PSREC + 1.
  REALTRANSBYTE = PBYTE + PREC * 2.

  IF REALTRANSBYTE > FILELENG.
    PERFORM FILECLOSE USING PTYPE PNO.
    PERFORM EXPB2STDREC USING PNO.
    PBYTE = 0.
    PREC = 0.
    PERFORM GETNEXTFILENO CHANGING PNO.
    PERFORM FILEOPEN USING PTYPE PNO 'OUTPUT'.
    PERFORM FILECLOSE USING PTYPE PNO.
    PERFORM FILEOPEN USING PTYPE PNO
                                  'APPENDING'.
  ENDIF.
ENDFORM.

*------------------------------------------------*
*       FORM GETFILENAME                         *
*------------------------------------------------*
FORM GETFILENAME USING PTYPE PNO CHANGING PNAME.
  DATA: FID(5) TYPE N.

  FID = PNO.
  CONCATENATE PATH PTYPE FID FEXT
              INTO PNAME.
ENDFORM.

*------------------------------------------------*
*       FORM GETNEXTFILENO                       *
*------------------------------------------------*
FORM GETNEXTFILENO CHANGING PNO.
  DATA: FID(5) TYPE N
       ,REC(400) TYPE C
       ,FNAME(400) TYPE C
       ,LENG TYPE I.

  IF MNO <> 0.
    MNO = MNO + 1.
  ELSE.
    FID = 2.

    CONCATENATE PATH 'B' FID FEXT
                INTO FNAME.

    OPEN DATASET FNAME FOR INPUT
                 IN TEXT MODE
                 ENCODING UTF-8
                 REPLACEMENT CHARACTER REPLQ
                 IGNORING CONVERSION ERRORS
                 MESSAGE TXT2STR.

    MNO = 8.

    IF SY-SUBRC = 0.
      DO.
        READ DATASET FNAME INTO REC LENGTH LENG.
        IF SY-SUBRC = 0.
          IF LENG > 7.
            MNO = REC+2(5) + 1.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
    ENDIF.

    CLOSE DATASET FNAME.
  ENDIF.

  PNO = MNO.
ENDFORM.

*------------------------------------------------*
*       FORM CHARFIELDREPL                       *
*------------------------------------------------*
FORM CHARFIELDREPL USING FLD.
  REPLACE ALL OCCURRENCES OF TRANSHS
                          IN FLD WITH SPACE.
ENDFORM.

*------------------------------------------------*
*       FORM INITSTDPROC                         *
*------------------------------------------------*
FORM INITSTDPROC.
  TNAME = TABNAME.
  TTEXT = TABTEXT.

  PERFORM EXPB1REC USING TABNAME
                         'T' 'C' 'Start'.

  PERFORM GETNEXTFILENO CHANGING FNO.
  PERFORM FILEOPEN USING FTYPE FNO 'OUTPUT'.
  PERFORM FILECLOSE USING FTYPE FNO.
ENDFORM.

*------------------------------------------------*
*       FORM STARTDOWNLOAD                       *
*------------------------------------------------*
FORM STARTDOWNLOAD.
  PERFORM FILEOPEN USING FTYPE FNO 'APPENDING'.
ENDFORM.

*------------------------------------------------*
*       FORM ENDDOWNLOAD                         *
*------------------------------------------------*
FORM ENDDOWNLOAD.
  PERFORM FILECLOSE USING FTYPE FNO.
ENDFORM.

*------------------------------------------------*
*       FORM ENDSTDPROC                          *
*------------------------------------------------*
FORM ENDSTDPROC.
  PERFORM EXPB2STDREC USING FNO.
  IF FN2 <> 0.
    PERFORM EXPB2STDREC USING FN2.
  ENDIF.
  IF FN3 <> 0.
    PERFORM EXPB2STDREC USING FN3.
  ENDIF.
  IF FN4 <> 0.
    PERFORM EXPB2STDREC USING FN4.
  ENDIF.
  COMMIT WORK AND WAIT.
  PERFORM EXPB1REC USING TABNAME
                         'T' 'C' 'End'.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB3                               *
*------------------------------------------------*
FORM EXPB3.
ENDFORM.

*------------------------------------------------*
*       FORM EXPB45                              *
*------------------------------------------------*
FORM EXPB45.
ENDFORM.

*------------------------------------------------*
*       FORM PROC                                *
*------------------------------------------------*
FORM PROC.

ENDFORM.
