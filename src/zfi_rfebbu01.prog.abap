*---------------------------------------------------------------*
*   Dieser Report ruft den Report RFEBBU00 zur Verarbeitung der *
*   Zwischenspeicherdaten mit der internen Batch-Input-Schnitt- *
*   stelle                                                      *
*---------------------------------------------------------------*
REPORT RFEBBU01 MESSAGE-ID FB
                LINE-SIZE 132
                NO STANDARD PAGE HEADING.

TABLES: BKPF.
TABLES: FEBKO,
        FEBEP,
        RFPDO1.


DATA:   JOBGROUP   LIKE TBTCO-JOBGROUP,
        JOBCOUNT   LIKE TBTCO-JOBCOUNT.

* Print Parameters
DATA:  BEGIN OF PRI_PARAM.
*        INCLUDE STRUCTURE %_print.                 "31H
         INCLUDE STRUCTURE PRI_PARAMS.              "31H
DATA:  END OF PRI_PARAM.

DATA:  BEGIN OF ARC_PARAM.                         "mp45A
         INCLUDE STRUCTURE ARC_PARAMS.             "mp45A
DATA:  END OF ARC_PARAM.                           "mp45A

DATA:   BEGIN OF PRI_KEY OCCURS 0,                  "31H
          REPID LIKE SY-REPID,                      "31H
          KUKEY LIKE FEBKO-KUKEY,                   "31H
        END OF PRI_KEY.                             "31H

DATA:   KUKEY      LIKE FEBKO-KUKEY.

PARAMETERS:     ANWND   LIKE FEBKO-ANWND.
SELECT-OPTIONS: S_KUKEY FOR FEBKO-KUKEY,
                S_ESNUM FOR FEBEP-ESNUM.
PARAMETERS:     JOBNAME      LIKE TBTCO-JOBNAME,  "Jobname
                EXPORTID(32) TYPE C,
                BUBER(1)     TYPE C,         "A, 1, 2
                MREGEL(1)    TYPE C,         " 1, 2, Space
                BNKGROUP     LIKE APQI-GROUPID,
                NEBGROUP     LIKE APQI-GROUPID.
*               USEREXIT     TYPE C.                             "30D
*               SELFD        LIKE RFPDO1-FEBSELFD. "SELFIELD für VwZweck
*                SELFDLEN     LIKE RFPDO1-FEBSELFDL. "Länge SELFD
*SELECT-OPTIONS: S_FILTER FOR BKPF-XBLNR.        " Nummernbereich SELFD
DATA: NUM10(10) TYPE N.
DATA: CHR16(16) TYPE C.
SELECT-OPTIONS: S_FILTER FOR NUM10.        " Nummernbereich SELFD
SELECT-OPTIONS: T_FILTER FOR CHR16.        " Nummernbereich SELFD
PARAMETERS:     PA_BDART     LIKE FEBPDO-BDART,
                PA_BDANZ     LIKE FEBPDO-BDANZ.
PARAMETERS:     FUNCTION(1)  TYPE C,         "C=CallTrans, B=BatchInput
                MODE(1)      TYPE C,         "A=All, E=Error, N=Nothing
                PA_EFART     LIKE FEBKO-EFART,
                P_BUPRO(1)   TYPE C,         "Buchungsprotokoll drucken
                P_STATIK(1)  TYPE C,         "Statistik drucken
                PA_XAKON(1)     TYPE C DEFAULT ' ',
*               VALUT_ON: Valuta-Datum kontieren
                VALUT_ON(1)  TYPE C DEFAULT 'X',
                TESTL(1)     TYPE C,         "Testlauf
                SPOOL(1)     TYPE C,         "Spool print
                EXECPRI      LIKE RFPDO1-FEBEINLES
                DEFAULT SPACE NO-DISPLAY.

*eject
START-OF-SELECTION.
*GB obtain print parameters from calling program
* IF SPOOL = 'X'.                            " print to spool  "31H
  IF SPOOL = 'X' OR                 " print to spool           "31H
     JOBNAME <> SPACE.              " submit job               "31H
*        IMPORT PRT_PARAM FROM MEMORY.
    CLEAR PRI_KEY.                                             "31H
    PRI_KEY-REPID = 'RFEBBU00'.                                "31H
    LOOP AT S_KUKEY.                                           "31H
      PRI_KEY-KUKEY = S_KUKEY-LOW.                             "31H
      EXIT.                                                    "31H
    ENDLOOP.                                                   "31H

    IMPORT PRI_PARAM ARC_PARAM FROM MEMORY ID PRI_KEY.        "mp45A

    IF SY-SUBRC NE 0.
       SPOOL = ' '.
    ENDIF.
  ENDIF.

  IF JOBNAME = SPACE.
    PERFORM SUBMIT_REPORT.
  ELSE.
    PERFORM SUBMIT_JOB.
  ENDIF.


*---------------------------------------------------------------*
*  FORM SUBMIT_REPORT.                                          *
*---------------------------------------------------------------*
FORM SUBMIT_REPORT.
*
  IF SPOOL = 'X'.
    PERFORM SUBMIT_TO_SPOOL.
  ELSE.

    SUBMIT ZFI_RFEBBU00 AND RETURN
                    USER SY-UNAME
                    WITH ANWND    =  ANWND
                    WITH S_KUKEY  IN S_KUKEY
                    WITH S_ESNUM  IN S_ESNUM
                    WITH BUBER    =  BUBER
                    WITH MREGEL   =  MREGEL
                    WITH BNKGROUP =  BNKGROUP
                    WITH NEBGROUP =  NEBGROUP
*                   WITH USEREXIT =  USEREXIT                    "30D
*                    WITH SELFD    =  SELFD
*                   WITH SELFDLEN =  SELFDLEN
                    WITH S_FILTER IN S_FILTER
                    WITH T_FILTER IN T_FILTER
                    WITH PA_BDART =  PA_BDART
                    WITH PA_BDANZ =  PA_BDANZ
                    WITH FUNCTION =  FUNCTION
                    WITH MODE     =  MODE
                    WITH PA_EFART  =  PA_EFART
                    WITH P_BUPRO  =  P_BUPRO
                    WITH P_STATIK =  P_STATIK
                    WITH PA_XAKON  =  PA_XAKON
                    WITH VALUT_ON =  VALUT_ON
                    WITH TESTL    =  TESTL
                    WITH EXECPRI = EXECPRI.

  ENDIF.
ENDFORM.

FORM SUBMIT_TO_SPOOL.
     SUBMIT ZFI_RFEBBU00 TO SAP-SPOOL
                        SPOOL PARAMETERS PRI_PARAM
                        WITHOUT SPOOL DYNPRO
                     AND RETURN
                     USER SY-UNAME
                     WITH ANWND    =  ANWND
                     WITH S_KUKEY  IN S_KUKEY
                     WITH S_ESNUM  IN S_ESNUM
                     WITH BUBER    =  BUBER
                     WITH MREGEL   =  MREGEL
                     WITH BNKGROUP =  BNKGROUP
                     WITH NEBGROUP =  NEBGROUP
*                    WITH USEREXIT =  USEREXIT                  "30D
*                     WITH SELFD    =  SELFD
*                    WITH SELFDLEN =  SELFDLEN
                     WITH S_FILTER IN S_FILTER
                     WITH T_FILTER IN T_FILTER
                     WITH PA_BDART =  PA_BDART
                     WITH PA_BDANZ =  PA_BDANZ
                     WITH FUNCTION =  FUNCTION
                     WITH MODE     =  MODE
                     WITH PA_EFART  =  PA_EFART
                     WITH P_BUPRO  =  P_BUPRO
                     WITH P_STATIK =  P_STATIK
                     WITH PA_XAKON =  PA_XAKON
                     WITH VALUT_ON =  VALUT_ON
                     WITH TESTL    =  TESTL.
ENDFORM.




*---------------------------------------------------------------*
*  FORM SUBMIT_JOB.                                             *
*---------------------------------------------------------------*
FORM SUBMIT_JOB.
  data: l_recipient like swotobjid,                        "hw595978
        l_jobhead type tbtcjob,                            "hw595978
        l_jobcount type tbtcjob-jobcount,                  "hw595978
        l_jobname type tbtcjob-jobname.                    "hw595978

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING JOBNAME    = JOBNAME
              JOBGROUP   = 'FEB '
    IMPORTING JOBCOUNT   = JOBCOUNT.

* WRITE: / 'Jobcount = ', JOBCOUNT.

  EXPORT JOBCOUNT TO MEMORY ID EXPORTID.


* SUBMIT RFEBBU00 AND RETURN                         "31H
  SUBMIT ZFI_RFEBBU00 TO SAP-SPOOL                       "31H
                  SPOOL PARAMETERS PRI_PARAM         "31H
                  ARCHIVE PARAMETERS ARC_PARAM       "mp45A
                  WITHOUT SPOOL DYNPRO               "31H
                  AND RETURN                         "31H
                  USER SY-UNAME
                  VIA JOB JOBNAME NUMBER JOBCOUNT
                  WITH ANWND    =  ANWND
                  WITH S_KUKEY  IN S_KUKEY
                  WITH S_ESNUM  IN S_ESNUM
                  WITH BUBER    =  BUBER
                  WITH MREGEL   =  MREGEL
                  WITH BNKGROUP =  BNKGROUP
                  WITH NEBGROUP =  NEBGROUP
*                 WITH USEREXIT =  USEREXIT                       "30D
*                 WITH SELFD    =  SELFD
*                 WITH SELFDLEN =  SELFDLEN
                  WITH S_FILTER IN S_FILTER
                  WITH T_FILTER IN T_FILTER
                  WITH PA_BDART =  PA_BDART
                  WITH PA_BDANZ =  PA_BDANZ
                  WITH FUNCTION =  FUNCTION
                  WITH MODE     =  MODE
                  WITH PA_EFART  =  PA_EFART
                  WITH P_BUPRO  =  P_BUPRO
                  WITH P_STATIK =  P_STATIK
                  WITH PA_XAKON =  PA_XAKON
                  WITH VALUT_ON =  VALUT_ON
                  WITH TESTL    =  TESTL.

  if sy-batch = 'X'.                                       "hw595978
    call function 'GET_JOB_RUNTIME_INFO'                   "hw595978
      importing                                            "hw595978
        jobcount = l_jobcount                              "hw595978
        jobname  = l_jobname.                              "hw595978
    call function 'BP_JOB_READ'                            "hw595978
      exporting                                            "hw595978
        job_read_jobcount = l_jobcount                     "hw595978
        job_read_jobname  = l_jobname                      "hw595978
        job_read_opcode   = '19'                           "hw595978
      importing                                            "hw595978
        job_read_jobhead  = l_jobhead.                     "hw595978
     l_recipient-logsys = l_jobhead-reclogsys.             "hw595978
     l_recipient-objtype = l_jobhead-recobjtype.           "hw595978
     l_recipient-objkey = l_jobhead-recobjkey.             "hw595978
     l_recipient-describe = l_jobhead-recdescrib.          "hw595978
  endif.                                                   "hw595978

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING JOBNAME    = JOBNAME
              JOBCOUNT   = JOBCOUNT
              STRTIMMED  = 'X'
              recipient_obj = l_recipient.                 "hw595978
ENDFORM.
