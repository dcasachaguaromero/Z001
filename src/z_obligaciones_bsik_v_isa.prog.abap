REPORT Z_OBLIGACIONES_BSIK_V_ISA message-id 26 line-size 255
no standard page heading.
* Z_OBLIGACIONES_BSIK_V_ISA.
PARAMETER DOWNLOAD(1) DEFAULT 'S' lower case. "N-svr,Y-clnt
PARAMETER EXECMODE(1) DEFAULT 'D' lower case. "D-dlg,B-btch
PARAMETER OUT_DIR(48) DEFAULT "output file dir
'\\172.31.100.100\' lower case.
PARAMETER IN_DIR(48) DEFAULT "input file dir
'\\172.31.100.100\' lower case.
PARAMETER P_DEST TYPE RFCDES-RFCDEST DEFAULT
'NONE'.
PARAMETER P_PROGID TYPE RFCOPT-RFCEXEC DEFAULT
SPACE.
PARAMETER P_GWHOST TYPE RFCOPT-RFCGWHOST DEFAULT
SPACE.
PARAMETER P_GWSERV TYPE RFCOPT-RFCGWSERV DEFAULT
SPACE.
PARAMETER P_SRVFM(30) DEFAULT "Server Callback function
SPACE.
PARAMETER P_PKGSZ TYPE I DEFAULT "Stream package size
5000.
PARAMETER P_SNC_ON(1) DEFAULT "X-on SPACE-off
SPACE.

PARAMETER $PARAM1(4) TYPE C.

PARAMETER $PARAM2 TYPE I.

PARAMETER $PARAM3 TYPE I.

PARAMETER $PARAM4 TYPE D.

PARAMETER $PARAM5 TYPE D.

PARAMETER P_DF_VK(40) DEFAULT "ABAP data flow object key
'' lower case.
PARAMETER P_DI_GEN(40) DEFAULT "DI version that generated ABAP
'' lower case.

*** Machine generated ABAP. Do not modify.            ***
*** (C)Copyright Business Objects S.A.  All rights reserved. ***
*
* Date Time:
*    12/18/18 17:34:59
* SAP used for generated this ABAP:
*    Release: 700
*    Host   : 172.31.100.100
*
* ABAP Dataflow Name:
*    Z_OBLIGACIONES_BSIK_V_ISA
* ABAP program name in SAP:
*  Z_OBLIGACIONES_BSIK_V_ISA
* Generated ABAP file name:
*  C:/ProgramData/SAP BusinessObjects/Data Services/workspace/Z_O
*BLI
*    GACIONES_BSIK_V_ISA
TABLES BKPF.
TABLES BSIK.
TABLES LFA1.

DATA: begin of ITAB3 occurs 0,
BUKRS(4) TYPE C,
BELNR(10) TYPE C,
XBLNR(16) TYPE C,
STBLG(10) TYPE C,
BKTXT(25) TYPE C,
AWKEY(20) TYPE C,
XREF2_HD(20) TYPE C,
LIFNR(10) TYPE C,
BUDAT TYPE D,
BLDAT TYPE D,
CPUDT TYPE D,
AUGBL(10) TYPE C,
ZUONR(18) TYPE C,
BLART(2) TYPE C,
SHKZG(1) TYPE C,
DMBTR(16) TYPE P DECIMALS 2,
SGTXT(50) TYPE C,
HKONT(10) TYPE C,
ZFBDT TYPE D,
ZLSCH(1) TYPE C,
HBKID(5) TYPE C,
XREF1(12) TYPE C,
XREF2(12) TYPE C,
XREF3(20) TYPE C,
ZZMOT_EMIS(10) TYPE C,
ZZRUT_TERC(10) TYPE C,
ZZ_AGENCIA(10) TYPE C,
BVTYP(4) TYPE C,
BANKL(15) TYPE C,
BANKN(18) TYPE C,
BUZEI(3) TYPE N.
DATA: end of ITAB3.

DATA: begin of ITAB5 occurs 0,
AIColumn35(4) TYPE C,
AIColumn36(10) TYPE C,
AIColumn37(16) TYPE C,
AIColumn38(10) TYPE C,
AIColumn39(25) TYPE C,
AIColumn40(20) TYPE C,
AIColumn41(20) TYPE C,
AIColumn42(10) TYPE C,
AIColumn43(16) TYPE C,
AIColumn44(71) TYPE C,
AIColumn45 TYPE D,
AIColumn46 TYPE D,
AIColumn47 TYPE D,
AIColumn48(10) TYPE C,
AIColumn49(18) TYPE C,
AIColumn50(2) TYPE C,
AIColumn51(1) TYPE C,
AIColumn52(16) TYPE P DECIMALS 2,
AIColumn53(50) TYPE C,
AIColumn54(10) TYPE C,
AIColumn55 TYPE D,
AIColumn56(1) TYPE C,
AIColumn57(5) TYPE C,
AIColumn58(12) TYPE C,
AIColumn59(12) TYPE C,
AIColumn60(20) TYPE C,
AIColumn61(10) TYPE C,
AIColumn62(10) TYPE C,
AIColumn63(10) TYPE C,
AIColumn64(4) TYPE C,
AIColumn65(3) TYPE N,
LIFNR(10) TYPE C,
AIColumn66(10) TYPE C.
DATA: end of ITAB5.

DATA: begin of ITAB6 occurs 0,
BUKRS(4) TYPE C,
BELNR(10) TYPE C,
XBLNR(16) TYPE C,
STBLG(10) TYPE C,
BKTXT(25) TYPE C,
AWKEY(20) TYPE C,
XREF2_HD(20) TYPE C,
LIFNR(10) TYPE C,
STCD1(16) TYPE C,
NOMBRE(100) TYPE C,
BUDAT TYPE D,
BLDAT TYPE D,
CPUDT TYPE D,
AUGBL(10) TYPE C,
ZUONR(18) TYPE C,
BLART(2) TYPE C,
SHKZG(1) TYPE C,
DMBTR(16) TYPE P DECIMALS 2,
SGTXT(50) TYPE C,
HKONT(10) TYPE C,
ZFBDT TYPE D,
ZLSCH(1) TYPE C,
HBKID(5) TYPE C,
XREF1(12) TYPE C,
XREF2(12) TYPE C,
XREF3(20) TYPE C,
ZZMOT_EMIS(10) TYPE C,
ZZRUT_TERC(10) TYPE C,
ZZ_AGENCIA(10) TYPE C,
BVTYP(4) TYPE C,
BANKL(15) TYPE C,
BANKN(18) TYPE C,
BUZEI(3) TYPE N.
DATA: end of ITAB6.

DATA: begin of ITAB7 occurs 0,
BUKRS(4) TYPE C,
BELNR(10) TYPE C,
XBLNR(16) TYPE C,
STBLG(10) TYPE C,
BKTXT(25) TYPE C,
AWKEY(20) TYPE C,
XREF2_HD(20) TYPE C,
LIFNR(10) TYPE C,
STCD1(16) TYPE C,
NOMBRE(100) TYPE C,
BUDAT TYPE D,
BLDAT TYPE D,
CPUDT TYPE D,
AUGBL(10) TYPE C,
ZUONR(18) TYPE C,
BLART(2) TYPE C,
SHKZG(1) TYPE C,
DMBTR(16) TYPE P DECIMALS 2,
SGTXT(50) TYPE C,
HKONT(10) TYPE C,
ZFBDT TYPE D,
ZLSCH(1) TYPE C,
HBKID(5) TYPE C,
XREF1(12) TYPE C,
XREF2(12) TYPE C,
XREF3(20) TYPE C,
ZZMOT_EMIS(10) TYPE C,
ZZRUT_TERC(10) TYPE C,
ZZ_AGENCIA(10) TYPE C,
BVTYP(4) TYPE C,
BANKL(15) TYPE C,
BANKN(18) TYPE C,
BUZEI(3) TYPE N.
DATA: end of ITAB7.

data: append_flag(1) value ' ',
      cntbuf type i,
      delimleng type i,last_batch(1) value ' '.

CONSTANTS C_DF_VK(40) VALUE '321'.
CONSTANTS C_DI_GEN(40) VALUE '14.2.7.1641'.
DATA WARN_MSG(50).


start-of-selection.


  IF DOWNLOAD = 'S' OR
     DOWNLOAD = 'N' OR
     DOWNLOAD = 'Y'.
      .
  ELSE.
     DATA: m_xfer_err_msg(700).
     CONCATENATE
'ABAP program does not recognize this new '
'data transfer method: ' DOWNLOAD
'. Regenerate the ABAP program and upload to this system.'
     INTO m_xfer_err_msg.
     MESSAGE  E240(S#) WITH m_xfer_err_msg.
  ENDIF.

  IF EXECMODE = 'B' OR
     EXECMODE = 'D'.
      .
  ELSE.
     DATA: m_exec_err_msg(700).
     CONCATENATE
'ABAP program does not recognize this new '
'execution option: ' EXECMODE
'. Regenerate the ABAP program and upload to this system.'
     INTO m_exec_err_msg.
     MESSAGE  E240(S#) WITH m_exec_err_msg.
  ENDIF.

  IF DOWNLOAD = 'S'.
     PERFORM CONNECT_RFCDEST_TO_PROGID.
  ENDIF.



PERFORM FORM3.
PERFORM FORM5.
FREE ITAB3.
PERFORM FORM6.
FREE ITAB5.
PERFORM FORM8.
FREE ITAB7.
last_batch = 'X'.
PERFORM FORM7.
FREE ITAB6.
  IF DOWNLOAD = 'S'.
     PERFORM DISCONNECT_RFCDEST_FROM_PROGID.
  ENDIF.


end-of-selection.

CLEAR WARN_MSG.

IF NOT P_DF_VK IS INITIAL.
  IF P_DF_VK <> C_DF_VK.
     CONCATENATE '$$Warning$'
                 C_DF_VK
                 '$' INTO WARN_MSG.
  ENDIF.
ENDIF.
IF NOT P_DI_GEN IS INITIAL.
  IF P_DI_GEN <> C_DI_GEN.
     IF WARN_MSG IS INITIAL.
       CONCATENATE '$$Warning$$'
                   C_DI_GEN
                   INTO WARN_MSG.
     ELSE.
       CONCATENATE WARN_MSG
                   C_DI_GEN
                   INTO WARN_MSG.
     ENDIF.
  ENDIF.
ENDIF.

IF NOT WARN_MSG IS INITIAL.
  IF EXECMODE = 'D'.
    WRITE WARN_MSG.
    NEW-LINE.
  ELSE.
    MESSAGE S240(S#) with WARN_MSG.
  ENDIF.
ENDIF.


write  '* Program Complete *'.
write
 '(C)Copyright Business Objects S.A.  All rights reserved.'.

FORM FORM3.
STATICS rowCount TYPE i VALUE 0.
DATA ALTMP1(4) TYPE C.
DATA ALTMP2(10) TYPE C.
DATA ALTMP3(16) TYPE C.
DATA ALTMP4(10) TYPE C.
DATA ALTMP5(25) TYPE C.
DATA ALTMP6(20) TYPE C.
DATA ALTMP7(20) TYPE C.
DATA ALTMP8(10) TYPE C.
DATA ALTMP9 TYPE D.
DATA ALTMP10 TYPE D.
DATA ALTMP11 TYPE D.
DATA ALTMP12(10) TYPE C.
DATA ALTMP13(18) TYPE C.
DATA ALTMP14(2) TYPE C.
DATA ALTMP15(1) TYPE C.
DATA ALTMP16(16) TYPE P DECIMALS 2.
DATA ALTMP17(50) TYPE C.
DATA ALTMP18(10) TYPE C.
DATA ALTMP19 TYPE D.
DATA ALTMP20(1) TYPE C.
DATA ALTMP21(5) TYPE C.
DATA ALTMP22(12) TYPE C.
DATA ALTMP23(12) TYPE C.
DATA ALTMP24(20) TYPE C.
DATA ALTMP25(10) TYPE C.
DATA ALTMP26(10) TYPE C.
DATA ALTMP27(10) TYPE C.
DATA ALTMP28(4) TYPE C.
DATA ALTMP29 TYPE F.
DATA ALTMP30 TYPE F.
DATA ALTMP31(3) TYPE N.

DATA BKPF9BUKRS LIKE BKPF-BUKRS.
DATA BKPF9BELNR LIKE BKPF-BELNR.
DATA BKPF9XBLNR LIKE BKPF-XBLNR.
DATA BKPF9STBLG LIKE BKPF-STBLG.
DATA BKPF9BKTXT LIKE BKPF-BKTXT.
DATA BKPF9AWKEY LIKE BKPF-AWKEY.
DATA BKPF9XREF2_HD LIKE BKPF-XREF2_HD.
DATA BSIK9LIFNR LIKE BSIK-LIFNR.
DATA BSIK9BUDAT LIKE BSIK-BUDAT.
DATA BSIK9BLDAT LIKE BSIK-BLDAT.
DATA BSIK9CPUDT LIKE BSIK-CPUDT.
DATA BSIK9AUGBL LIKE BSIK-AUGBL.
DATA BSIK9ZUONR LIKE BSIK-ZUONR.
DATA BSIK9BLART LIKE BSIK-BLART.
DATA BSIK9SHKZG LIKE BSIK-SHKZG.
DATA BSIK9DMBTR LIKE BSIK-DMBTR.
DATA BSIK9SGTXT LIKE BSIK-SGTXT.
DATA BSIK9HKONT LIKE BSIK-HKONT.
DATA BSIK9ZFBDT LIKE BSIK-ZFBDT.
DATA BSIK9ZLSCH LIKE BSIK-ZLSCH.
DATA BSIK9HBKID LIKE BSIK-HBKID.
DATA BSIK9XREF1 LIKE BSIK-XREF1.
DATA BSIK9XREF2 LIKE BSIK-XREF2.
DATA BSIK9XREF3 LIKE BSIK-XREF3.
DATA BSIK9ZZMOT_EMIS LIKE BSIK-ZZMOT_EMIS.
DATA BSIK9ZZRUT_TERC LIKE BSIK-ZZRUT_TERC.
DATA BSIK9ZZ_AGENCIA LIKE BSIK-ZZ_AGENCIA.
DATA BSIK9BVTYP LIKE BSIK-BVTYP.
DATA BSIK9BUZEI LIKE BSIK-BUZEI.

ALTMP29 = ''.
ALTMP30 = ''.


SELECT DISTINCT
  BKPF9~BUKRS
  BKPF9~BELNR
  BKPF9~XBLNR
  BKPF9~STBLG
  BKPF9~BKTXT
  BKPF9~AWKEY
  BKPF9~XREF2_HD
  BSIK9~LIFNR
  BSIK9~BUDAT
  BSIK9~BLDAT
  BSIK9~CPUDT
  BSIK9~AUGBL
  BSIK9~ZUONR
  BSIK9~BLART
  BSIK9~SHKZG
  BSIK9~DMBTR
  BSIK9~SGTXT
  BSIK9~HKONT
  BSIK9~ZFBDT
  BSIK9~ZLSCH
  BSIK9~HBKID
  BSIK9~XREF1
  BSIK9~XREF2
  BSIK9~XREF3
  BSIK9~ZZMOT_EMIS
  BSIK9~ZZRUT_TERC
  BSIK9~ZZ_AGENCIA
  BSIK9~BVTYP
  BSIK9~BUZEI
into (BKPF9BUKRS,
  BKPF9BELNR,
  BKPF9XBLNR,
  BKPF9STBLG,
  BKPF9BKTXT,
  BKPF9AWKEY,
  BKPF9XREF2_HD,
  BSIK9LIFNR,
  BSIK9BUDAT,
  BSIK9BLDAT,
  BSIK9CPUDT,
  BSIK9AUGBL,
  BSIK9ZUONR,
  BSIK9BLART,
  BSIK9SHKZG,
  BSIK9DMBTR,
  BSIK9SGTXT,
  BSIK9HKONT,
  BSIK9ZFBDT,
  BSIK9ZLSCH,
  BSIK9HBKID,
  BSIK9XREF1,
  BSIK9XREF2,
  BSIK9XREF3,
  BSIK9ZZMOT_EMIS,
  BSIK9ZZRUT_TERC,
  BSIK9ZZ_AGENCIA,
  BSIK9BVTYP,
  BSIK9BUZEI)
FROM BSIK AS BSIK9
 INNER JOIN BKPF AS BKPF9
 ON ( ( BKPF9~GJAHR = BSIK9~GJAHR )
 AND ( ( BKPF9~BELNR = BSIK9~BELNR )
 AND ( BKPF9~BUKRS = BSIK9~BUKRS ) ) )
WHERE ( BSIK9~BLART IN ('Z1',
'Z3',
'Z4',
'Z5',
'Z6',
'XG',
'XB',
'XC',
'SA',
'AB',
'B1',
'B2',
'B3',
'B4',
'B5',
'D1',
'D2',
'D3',
'D4',
'E1',
'E2',
'F0',
'F1',
'F2',
'F3',
'F4',
'F5',
'F6',
'F7',
'F8',
'F9',
'FA',
'FB',
'FC',
'FI',
'FR',
'I1',
'I2',
'N0',
'N1',
'N2',
'N3',
'N4',
'NA',
'NB',
'NC',
'NR',
'ZP')
 AND ( ( BKPF9~CPUDT <= $PARAM5 )
 AND ( ( BKPF9~CPUDT >= $PARAM4 )
 AND ( ( BKPF9~GJAHR <= $PARAM3 )
 AND ( ( BKPF9~GJAHR >= $PARAM2 )
 AND ( BKPF9~BUKRS = $PARAM1 ) ) ) ) ) ).
ALTMP1 = BKPF9BUKRS.
ALTMP2 = BKPF9BELNR.
ALTMP3 = BKPF9XBLNR.
ALTMP4 = BKPF9STBLG.
ALTMP5 = BKPF9BKTXT.
ALTMP6 = BKPF9AWKEY.
ALTMP7 = BKPF9XREF2_HD.
ALTMP8 = BSIK9LIFNR.
ALTMP9 = BSIK9BUDAT.
ALTMP10 = BSIK9BLDAT.
ALTMP11 = BSIK9CPUDT.
ALTMP12 = BSIK9AUGBL.
ALTMP13 = BSIK9ZUONR.
ALTMP14 = BSIK9BLART.
ALTMP15 = BSIK9SHKZG.
ALTMP16 = BSIK9DMBTR.
ALTMP17 = BSIK9SGTXT.
ALTMP18 = BSIK9HKONT.
ALTMP19 = BSIK9ZFBDT.
ALTMP20 = BSIK9ZLSCH.
ALTMP21 = BSIK9HBKID.
ALTMP22 = BSIK9XREF1.
ALTMP23 = BSIK9XREF2.
ALTMP24 = BSIK9XREF3.
ALTMP25 = BSIK9ZZMOT_EMIS.
ALTMP26 = BSIK9ZZRUT_TERC.
ALTMP27 = BSIK9ZZ_AGENCIA.
ALTMP28 = BSIK9BVTYP.
ALTMP31 = BSIK9BUZEI.
 move ALTMP1 to ITAB3-BUKRS.
 move ALTMP2 to ITAB3-BELNR.
 move ALTMP3 to ITAB3-XBLNR.
 move ALTMP4 to ITAB3-STBLG.
 move ALTMP5 to ITAB3-BKTXT.
 move ALTMP6 to ITAB3-AWKEY.
 move ALTMP7 to ITAB3-XREF2_HD.
 move ALTMP8 to ITAB3-LIFNR.
 move ALTMP9 to ITAB3-BUDAT.
 move ALTMP10 to ITAB3-BLDAT.
 move ALTMP11 to ITAB3-CPUDT.
 move ALTMP12 to ITAB3-AUGBL.
 move ALTMP13 to ITAB3-ZUONR.
 move ALTMP14 to ITAB3-BLART.
 move ALTMP15 to ITAB3-SHKZG.
 move ALTMP16 to ITAB3-DMBTR.
 move ALTMP17 to ITAB3-SGTXT.
 move ALTMP18 to ITAB3-HKONT.
 move ALTMP19 to ITAB3-ZFBDT.
 move ALTMP20 to ITAB3-ZLSCH.
 move ALTMP21 to ITAB3-HBKID.
 move ALTMP22 to ITAB3-XREF1.
 move ALTMP23 to ITAB3-XREF2.
 move ALTMP24 to ITAB3-XREF3.
 move ALTMP25 to ITAB3-ZZMOT_EMIS.
 move ALTMP26 to ITAB3-ZZRUT_TERC.
 move ALTMP27 to ITAB3-ZZ_AGENCIA.
 move ALTMP28 to ITAB3-BVTYP.
 move ALTMP29 to ITAB3-BANKL.
 move ALTMP30 to ITAB3-BANKN.
 move ALTMP31 to ITAB3-BUZEI.
 append ITAB3.
rowCount = rowCount + 1.
IF ( download = 'S' ).
 IF ( rowCount = P_PKGSZ ).
   PERFORM FORM5.
   REFRESH ITAB3.
   rowCount = 0.
 ENDIF.
ELSE.
 IF ( rowCount = 5000 ).
   PERFORM FORM5.
   REFRESH ITAB3.
   rowCount = 0.
 ENDIF.
ENDIF.
ENDSELECT.
ENDFORM.

FORM FORM5.
STATICS rowCount TYPE i VALUE 0.
STATICS firstRun(1) TYPE C VALUE 'Y'.
DATA ALTMP32(4) TYPE C.
DATA ALTMP33(10) TYPE C.
DATA ALTMP34(16) TYPE C.
DATA ALTMP35(10) TYPE C.
DATA ALTMP36(25) TYPE C.
DATA ALTMP37(20) TYPE C.
DATA ALTMP38(20) TYPE C.
DATA ALTMP39(10) TYPE C.
DATA ALTMP40(16) TYPE C.
DATA ALTMP41(35) TYPE C.
DATA ALTMP42(36) TYPE C.
DATA ALTMP43(35) TYPE C.
DATA ALTMP44(71) TYPE C.
DATA ALTMP45 TYPE D.
DATA ALTMP46 TYPE D.
DATA ALTMP47 TYPE D.
DATA ALTMP48(10) TYPE C.
DATA ALTMP49(18) TYPE C.
DATA ALTMP50(2) TYPE C.
DATA ALTMP51(1) TYPE C.
DATA ALTMP52(16) TYPE P DECIMALS 2.
DATA ALTMP53(50) TYPE C.
DATA ALTMP54(10) TYPE C.
DATA ALTMP55 TYPE D.
DATA ALTMP56(1) TYPE C.
DATA ALTMP57(5) TYPE C.
DATA ALTMP58(12) TYPE C.
DATA ALTMP59(12) TYPE C.
DATA ALTMP60(20) TYPE C.
DATA ALTMP61(10) TYPE C.
DATA ALTMP62(10) TYPE C.
DATA ALTMP63(10) TYPE C.
DATA ALTMP64(4) TYPE C.
DATA ALTMP65(3) TYPE N.
DATA ALTMP66(10) TYPE C.
DATA ALTMP67(10) TYPE C.
DATA ALOJF0 TYPE C.
DATA ALOJF1 TYPE C.



LOOP AT ITAB3.
ALTMP32 = ITAB3-BUKRS.
ALTMP33 = ITAB3-BELNR.
ALTMP34 = ITAB3-XBLNR.
ALTMP35 = ITAB3-STBLG.
ALTMP36 = ITAB3-BKTXT.
ALTMP37 = ITAB3-AWKEY.
ALTMP38 = ITAB3-XREF2_HD.
ALTMP39 = ITAB3-LIFNR.
ALTMP45 = ITAB3-BUDAT.
ALTMP46 = ITAB3-BLDAT.
ALTMP47 = ITAB3-CPUDT.
ALTMP48 = ITAB3-AUGBL.
ALTMP49 = ITAB3-ZUONR.
ALTMP50 = ITAB3-BLART.
ALTMP51 = ITAB3-SHKZG.
ALTMP52 = ITAB3-DMBTR.
ALTMP53 = ITAB3-SGTXT.
ALTMP54 = ITAB3-HKONT.
ALTMP55 = ITAB3-ZFBDT.
ALTMP56 = ITAB3-ZLSCH.
ALTMP57 = ITAB3-HBKID.
ALTMP58 = ITAB3-XREF1.
ALTMP59 = ITAB3-XREF2.
ALTMP60 = ITAB3-XREF3.
ALTMP61 = ITAB3-ZZMOT_EMIS.
ALTMP62 = ITAB3-ZZRUT_TERC.
ALTMP63 = ITAB3-ZZ_AGENCIA.
ALTMP64 = ITAB3-BVTYP.
ALTMP65 = ITAB3-BUZEI.
ALTMP66 = ITAB3-LIFNR.
ALOJF0 = 'Y'.
ALOJF1 = 'N'.
IF ( ALOJF0 = 'Y' ).

SELECT
  STCD1
  NAME1
  NAME2
  LIFNR
INTO CORRESPONDING FIELDS OF LFA1
FROM LFA1
WHERE ( LIFNR = ITAB3-LIFNR ).
ALTMP40 = LFA1-STCD1.
ALTMP41 = LFA1-NAME1 .
 shift ALTMP41 right deleting trailing space.
shift ALTMP41 right deleting trailing LFA1-NAME1.
concatenate ALTMP41 ' ' into ALTMP42.
ALTMP43 = LFA1-NAME2 .
 shift ALTMP43 right deleting trailing space.
shift ALTMP43 right deleting trailing LFA1-NAME2.
concatenate ALTMP42 ALTMP43 into ALTMP44.
ALTMP67 = LFA1-LIFNR.
ALOJF1 = 'Y'.
 move ALTMP32 to ITAB5-AIColumn35.
 move ALTMP33 to ITAB5-AIColumn36.
 move ALTMP34 to ITAB5-AIColumn37.
 move ALTMP35 to ITAB5-AIColumn38.
 move ALTMP36 to ITAB5-AIColumn39.
 move ALTMP37 to ITAB5-AIColumn40.
 move ALTMP38 to ITAB5-AIColumn41.
 move ALTMP39 to ITAB5-AIColumn42.
 move ALTMP40 to ITAB5-AIColumn43.
 move ALTMP44 to ITAB5-AIColumn44.
 move ALTMP45 to ITAB5-AIColumn45.
 move ALTMP46 to ITAB5-AIColumn46.
 move ALTMP47 to ITAB5-AIColumn47.
 move ALTMP48 to ITAB5-AIColumn48.
 move ALTMP49 to ITAB5-AIColumn49.
 move ALTMP50 to ITAB5-AIColumn50.
 move ALTMP51 to ITAB5-AIColumn51.
 move ALTMP52 to ITAB5-AIColumn52.
 move ALTMP53 to ITAB5-AIColumn53.
 move ALTMP54 to ITAB5-AIColumn54.
 move ALTMP55 to ITAB5-AIColumn55.
 move ALTMP56 to ITAB5-AIColumn56.
 move ALTMP57 to ITAB5-AIColumn57.
 move ALTMP58 to ITAB5-AIColumn58.
 move ALTMP59 to ITAB5-AIColumn59.
 move ALTMP60 to ITAB5-AIColumn60.
 move ALTMP61 to ITAB5-AIColumn61.
 move ALTMP62 to ITAB5-AIColumn62.
 move ALTMP63 to ITAB5-AIColumn63.
 move ALTMP64 to ITAB5-AIColumn64.
 move ALTMP65 to ITAB5-AIColumn65.
 move ALTMP66 to ITAB5-LIFNR.
 move ALTMP67 to ITAB5-AIColumn66.
 append ITAB5.
firstRun = 'N' .
rowCount = rowCount + 1.
IF ( download = 'S' ).
 IF ( rowCount = P_PKGSZ ).
   PERFORM FORM6.
   REFRESH ITAB5.
   rowCount = 0.
 ENDIF.
ELSE.
 IF ( rowCount = 5000 ).
   PERFORM FORM6.
   REFRESH ITAB5.
   rowCount = 0.
 ENDIF.
ENDIF.
ENDSELECT.
ENDIF.
IF ( ALOJF1 = 'N' ).
clear LFA1-STCD1.
clear LFA1-NAME1.
clear LFA1-NAME2.
clear LFA1-LIFNR.
clear ALTMP40.
clear ALTMP41.
clear ALTMP42.
clear ALTMP43.
clear ALTMP44.
clear ALTMP67.
 move ALTMP32 to ITAB5-AIColumn35.
 move ALTMP33 to ITAB5-AIColumn36.
 move ALTMP34 to ITAB5-AIColumn37.
 move ALTMP35 to ITAB5-AIColumn38.
 move ALTMP36 to ITAB5-AIColumn39.
 move ALTMP37 to ITAB5-AIColumn40.
 move ALTMP38 to ITAB5-AIColumn41.
 move ALTMP39 to ITAB5-AIColumn42.
 move ALTMP40 to ITAB5-AIColumn43.
 move ALTMP44 to ITAB5-AIColumn44.
 move ALTMP45 to ITAB5-AIColumn45.
 move ALTMP46 to ITAB5-AIColumn46.
 move ALTMP47 to ITAB5-AIColumn47.
 move ALTMP48 to ITAB5-AIColumn48.
 move ALTMP49 to ITAB5-AIColumn49.
 move ALTMP50 to ITAB5-AIColumn50.
 move ALTMP51 to ITAB5-AIColumn51.
 move ALTMP52 to ITAB5-AIColumn52.
 move ALTMP53 to ITAB5-AIColumn53.
 move ALTMP54 to ITAB5-AIColumn54.
 move ALTMP55 to ITAB5-AIColumn55.
 move ALTMP56 to ITAB5-AIColumn56.
 move ALTMP57 to ITAB5-AIColumn57.
 move ALTMP58 to ITAB5-AIColumn58.
 move ALTMP59 to ITAB5-AIColumn59.
 move ALTMP60 to ITAB5-AIColumn60.
 move ALTMP61 to ITAB5-AIColumn61.
 move ALTMP62 to ITAB5-AIColumn62.
 move ALTMP63 to ITAB5-AIColumn63.
 move ALTMP64 to ITAB5-AIColumn64.
 move ALTMP65 to ITAB5-AIColumn65.
 move ALTMP66 to ITAB5-LIFNR.
 move ALTMP67 to ITAB5-AIColumn66.
 append ITAB5.
firstRun = 'N' .
rowCount = rowCount + 1.
IF ( download = 'S' ).
 IF ( rowCount = P_PKGSZ ).
   PERFORM FORM6.
   REFRESH ITAB5.
   rowCount = 0.
 ENDIF.
ELSE.
 IF ( rowCount = 5000 ).
   PERFORM FORM6.
   REFRESH ITAB5.
   rowCount = 0.
 ENDIF.
ENDIF.
ENDIF.
ENDLOOP.
ENDFORM.

FORM FORM6.
STATICS firstRun(1) TYPE C VALUE 'Y'.
DATA ALTMP68(4) TYPE C.
DATA ALTMP69(10) TYPE C.
DATA ALTMP70(16) TYPE C.
DATA ALTMP71(10) TYPE C.
DATA ALTMP72(25) TYPE C.
DATA ALTMP73(20) TYPE C.
DATA ALTMP74(20) TYPE C.
DATA ALTMP75(10) TYPE C.
DATA ALTMP76(16) TYPE C.
DATA ALTMP77(71) TYPE C.
DATA ALTMP78 TYPE D.
DATA ALTMP79 TYPE D.
DATA ALTMP80 TYPE D.
DATA ALTMP81(10) TYPE C.
DATA ALTMP82(18) TYPE C.
DATA ALTMP83(2) TYPE C.
DATA ALTMP84(1) TYPE C.
DATA ALTMP85(16) TYPE P DECIMALS 2.
DATA ALTMP86(50) TYPE C.
DATA ALTMP87(10) TYPE C.
DATA ALTMP88 TYPE D.
DATA ALTMP89(1) TYPE C.
DATA ALTMP90(5) TYPE C.
DATA ALTMP91(12) TYPE C.
DATA ALTMP92(12) TYPE C.
DATA ALTMP93(20) TYPE C.
DATA ALTMP94(10) TYPE C.
DATA ALTMP95(10) TYPE C.
DATA ALTMP96(10) TYPE C.
DATA ALTMP97(4) TYPE C.
DATA ALTMP98 TYPE F.
DATA ALTMP99 TYPE F.
DATA ALTMP100(3) TYPE N.


ALTMP98 = ''.
ALTMP99 = ''.

LOOP AT ITAB5.
ALTMP68 = ITAB5-AIColumn35.
ALTMP69 = ITAB5-AIColumn36.
ALTMP70 = ITAB5-AIColumn37.
ALTMP71 = ITAB5-AIColumn38.
ALTMP72 = ITAB5-AIColumn39.
ALTMP73 = ITAB5-AIColumn40.
ALTMP74 = ITAB5-AIColumn41.
ALTMP75 = ITAB5-AIColumn42.
ALTMP76 = ITAB5-AIColumn43.
ALTMP77 = ITAB5-AIColumn44.
ALTMP78 = ITAB5-AIColumn45.
ALTMP79 = ITAB5-AIColumn46.
ALTMP80 = ITAB5-AIColumn47.
ALTMP81 = ITAB5-AIColumn48.
ALTMP82 = ITAB5-AIColumn49.
ALTMP83 = ITAB5-AIColumn50.
ALTMP84 = ITAB5-AIColumn51.
ALTMP85 = ITAB5-AIColumn52.
ALTMP86 = ITAB5-AIColumn53.
ALTMP87 = ITAB5-AIColumn54.
ALTMP88 = ITAB5-AIColumn55.
ALTMP89 = ITAB5-AIColumn56.
ALTMP90 = ITAB5-AIColumn57.
ALTMP91 = ITAB5-AIColumn58.
ALTMP92 = ITAB5-AIColumn59.
ALTMP93 = ITAB5-AIColumn60.
ALTMP94 = ITAB5-AIColumn61.
ALTMP95 = ITAB5-AIColumn62.
ALTMP96 = ITAB5-AIColumn63.
ALTMP97 = ITAB5-AIColumn64.
ALTMP100 = ITAB5-AIColumn65.
 move ALTMP68 to ITAB7-BUKRS.
 move ALTMP69 to ITAB7-BELNR.
 move ALTMP70 to ITAB7-XBLNR.
 move ALTMP71 to ITAB7-STBLG.
 move ALTMP72 to ITAB7-BKTXT.
 move ALTMP73 to ITAB7-AWKEY.
 move ALTMP74 to ITAB7-XREF2_HD.
 move ALTMP75 to ITAB7-LIFNR.
 move ALTMP76 to ITAB7-STCD1.
 move ALTMP77 to ITAB7-NOMBRE.
 move ALTMP78 to ITAB7-BUDAT.
 move ALTMP79 to ITAB7-BLDAT.
 move ALTMP80 to ITAB7-CPUDT.
 move ALTMP81 to ITAB7-AUGBL.
 move ALTMP82 to ITAB7-ZUONR.
 move ALTMP83 to ITAB7-BLART.
 move ALTMP84 to ITAB7-SHKZG.
 move ALTMP85 to ITAB7-DMBTR.
 move ALTMP86 to ITAB7-SGTXT.
 move ALTMP87 to ITAB7-HKONT.
 move ALTMP88 to ITAB7-ZFBDT.
 move ALTMP89 to ITAB7-ZLSCH.
 move ALTMP90 to ITAB7-HBKID.
 move ALTMP91 to ITAB7-XREF1.
 move ALTMP92 to ITAB7-XREF2.
 move ALTMP93 to ITAB7-XREF3.
 move ALTMP94 to ITAB7-ZZMOT_EMIS.
 move ALTMP95 to ITAB7-ZZRUT_TERC.
 move ALTMP96 to ITAB7-ZZ_AGENCIA.
 move ALTMP97 to ITAB7-BVTYP.
 move ALTMP98 to ITAB7-BANKL.
 move ALTMP99 to ITAB7-BANKN.
 move ALTMP100 to ITAB7-BUZEI.
 append ITAB7.
firstRun = 'N' .
ENDLOOP.
ENDFORM.

FORM FORM8.
SORT ITAB7 BY
  BUKRS
  BELNR
  XBLNR
  STBLG
  BKTXT
  AWKEY
  XREF2_HD
  LIFNR
  STCD1
  NOMBRE
  BUDAT
  BLDAT
  CPUDT
  AUGBL
  ZUONR
  BLART
  SHKZG
  DMBTR
  SGTXT
  HKONT
  ZFBDT
  ZLSCH
  HBKID
  XREF1
  XREF2
  XREF3
  ZZMOT_EMIS
  ZZRUT_TERC
  ZZ_AGENCIA
  BVTYP
  BANKL
  BANKN
  BUZEI.
delete adjacent duplicates from ITAB7 comparing all fields.

ITAB6[] = ITAB7[].
ENDFORM.

FORM FORM7.
data: outfile(512), ldfile(50).
ldfile = 'Z_OBLIGACIONES_BSIK_V_ISA'.
concatenate out_dir ldfile into outfile
  separated by '/'.
  IF DOWNLOAD = 'S'.
     DATA: error_message(700),mtext(800),iEOP(1).
     CALL FUNCTION P_SRVFM
          DESTINATION P_DEST
          KEEPING LOGICAL UNIT OF WORK
          EXPORTING
            EOS = last_batch
          IMPORTING
            EOP = iEOP
          TABLES
            E_TABLE = ITAB6
          EXCEPTIONS
            READ_ERROR = 1
            SYSTEM_FAILURE = 2
            MESSAGE error_message
            COMMUNICATION_FAILURE = 3
            MESSAGE error_message
            OTHERS = 4.

     IF sy-subrc ne 0.
        Case sy-subrc.
        when 1.
        CONCATENATE
        'Data Services read error. '
        'Check Data Services error log.'
        INTO mtext.
        MESSAGE  E240(S#) WITH mtext.
        when 2.
        CONCATENATE
'SAP System Failure while calling DS remote function: '
      error_message INTO mtext.
        MESSAGE  E240(S#) WITH mtext.
        when 3.
        CONCATENATE
'SAP System Failure while calling DS remote function: '
      error_message INTO mtext.
        MESSAGE  E240(S#) WITH mtext.
        when 4.
        MESSAGE  E240(S#) WITH
'Other SAP System Failure while calling DS remote function.'.
        endcase.
      ENDIF.
      IF iEOP = 'X'.
         PERFORM DISCONNECT_RFCDEST_FROM_PROGID.
         LEAVE PROGRAM.
       ENDIF.
  ELSE.
data  dlmtlen type i value '1'.
data xdlmtlen type i value '1'.
data:
  ht(1) type c,
  xht(1) type x,
  conv type ref to cl_abap_conv_in_ce.
xht = '7F'.
conv = cl_abap_conv_in_ce=>create(
  encoding = '1100'
  input = xht
).
call method conv->read(
  exporting n    = xdlmtlen
  importing data = ht
            len = dlmtlen
).
data return_code type i.
 perform write_delimited_file
           tables   ITAB6
           using    outfile
                    append_flag
                    ht
                    dlmtlen
                    download
           changing return_code.

  case return_code.
    when 1.
      IF EXECMODE = 'D'.
        WRITE: /5 'No line selected'.
      ELSE.
        MESSAGE E047(S#).
      ENDIF.
    when 2.
      IF EXECMODE = 'D'.
        WRITE: /5 'Open File Error -- ', 25 OUTFILE.
      ELSE.
        MESSAGE  E084(E0) WITH OUTFILE.
      ENDIF.
    when 3.
      IF EXECMODE = 'D'.
        WRITE: /5 'Data exceed length limit (8192) '.
      ELSE.
        MESSAGE  E240(S#) WITH
             'Data exceed length limit (8192) '.
      ENDIF.
    when 4.
      IF EXECMODE = 'D'.
        WRITE: /5 'Call function WS_DOWNLOAD error'.
      ELSE.
        MESSAGE  E240(S#) WITH
             'Call function WS_DOWNLOAD error'.
      ENDIF.
  endcase.
 ENDIF.
ENDFORM.

FORM SUBSTRING USING SRC BEG LEN CHANGING RET.

DATA: VA1 TYPE I.
DATA: VA2 TYPE I.
DATA: VA3 TYPE I.

VA3 = STRLEN( SRC ).

IF  BEG = 0.   VA1 = 0.
ELSE.
  IF  BEG < 0.
    VA1 = VA3 + BEG.
    IF  VA1 < 0.   VA1 = 0.
    ENDIF.
  ELSE.          VA1 = BEG - 1.
  ENDIF.
ENDIF.

IF  LEN < 0.   VA2 = 0.
ELSE.          VA2 = VA3 - VA1.
ENDIF.

IF  VA2 > LEN. VA2 = LEN.
ENDIF.

IF  VA2 < 1.   MOVE ''           TO RET.
ELSE.          MOVE SRC+VA1(VA2) TO RET.
ENDIF.

ENDFORM.

form write_delimited_file
           tables   datatab
           using    file
                    append
                    delimit
                    dlength
                    dwnload
          changing rc.

  data: type1,
        appd(1),
        temp(32),
        time1(8),
        date1(10),
        output(8192),
        rcount type i,
        offset type i,
        tablen type i,
        maxlen type i value '8192'.

  data: begin of clientab occurs 0,
             output(8192),
          end of clientab.

  field-symbols: <f>.
  field-symbols <delim1>.
  data delim2(16).
  data l_filename type string.

  appd = append.
  if appd is not initial.
     appd = 'X'.
  endif.
  move file to l_filename.
  describe table datatab lines tablen.


  if dwnload = 'Y'.
     clear clientab. refresh clientab.
     rcount = 0.
  else.
     if appd = space.
   open dataset file for output in text mode ENCODING UTF-8.
     else.
    open dataset file for appending in text mode ENCODING UTF-8.

     endif.
     if sy-subrc <> 0.
         rc = 2. exit.
     endif.
  endif.

  loop at datatab.
    clear: tablen, offset, output.
    do.
      assign component sy-index of
         structure datatab to <f>.
      if sy-subrc <> 0. exit. endif.
      if sy-index > 1.
         assign delimit(dlength) TO <delim1> CASTING TYPE C.
         delim2 = <delim1>.
         write delim2(dlength) to output+offset(dlength).
         add dlength to offset.
      endif.

      describe field <f> type type1.

      if type1 = 'I' or type1 = 'N'.
          type1 = 'P'.
      endif.

      case type1.
        when 'D'.
          if <f> = '00000000'.
             <f> = ' '.
          else.
             move <f> to time1.
             assign time1 to <f>.
          endif.
        when 'F'.
          if <f> = '0.0'.
            temp = '0.0'.
          else.
             write <f> to temp exponent 0.
          endif.
          condense temp no-gaps.
          translate temp using ',.'.
          assign temp to <f>.
        when 'P'.
          if <f> < 0.
             write '-' to output+offset(1).
             add 1 to offset.
             <f> = <f> * ( -1 ).
          endif.
          move <f> to temp.
          condense temp no-gaps.
          translate temp using ',.'.
          assign temp to <f>.
      endcase.

      sy-fdpos = strlen( <f> ).

      tablen = offset + sy-fdpos.
      if tablen > maxlen.
         rc = 3. exit.
      endif.
      write <f> to output+offset(sy-fdpos).
      add sy-fdpos to offset.
    enddo.

    if dwnload = 'Y'.
       clientab-output = output.
       append clientab.
       rcount = rcount + 1.
       if rcount >= 50.
          SY-BATCH = SPACE.
          CALL FUNCTION 'GUI_DOWNLOAD'
            EXPORTING
              FILENAME = l_filename
              FILETYPE = 'ASC'
              CODEPAGE = '4110'
              APPEND   = appd
              WRITE_FIELD_SEPARATOR = 'X'
*            IMPORTING
*              FILELENGTH =
            TABLES
              DATA_TAB = clientab
            EXCEPTIONS
              OTHERS = 1.
          if sy-subrc <> 0.
             rc = 4.
          endif.
          clear clientab. refresh clientab.
          rcount = 0. appd = 'A'.
       endif.
    else.
       transfer output to file.
    endif.
  endloop.

  if dwnload = 'Y'.
       SY-BATCH = SPACE.
       CALL FUNCTION 'GUI_DOWNLOAD'
         EXPORTING
           FILENAME = l_filename
           FILETYPE = 'ASC'
              CODEPAGE = '4110'
           APPEND   = appd
           WRITE_FIELD_SEPARATOR = 'X'
*         IMPORTING
*           FILELENGTH =
         TABLES
           DATA_TAB = clientab
         EXCEPTIONS
           OTHERS = 1.
          if sy-subrc <> 0.
             rc = 4.
          endif.
  else.
       close dataset file.
  endif.
endform.

FORM CONNECT_RFCDEST_TO_PROGID.
 INCLUDE rfctypes.

 DATA: len     type i,
       R3NAME(4),
       SYSTNR(2),
       uid     LIKE SYS_UID,
       options LIKE RFCOPT,
       isunicode  TYPE n.

 DATA: NTOTAL     LIKE GWY_STRUCT-NOREG,
       GWY_GWHOST LIKE GWY_STRUCT-GWHOST,
       GWY_GWSERV LIKE GWY_STRUCT-GWSERV,
       GWY_TPNAME LIKE GWY_SYSTEM-TPNAME.

 TABLES: RFCSI.

* Check program ID
 IF P_PROGID = SPACE.
    RAISE INVALID_PROGRAM_ID.
 ENDIF.

* determine if the RFC destination authority
  CALL FUNCTION 'RFC_READ_TCPIP_DESTINATION'
       EXPORTING destination = P_DEST
                 authority_check = 'X'
  IMPORTING rfcunicode = isunicode.

* Use current gateway if no info exits
 IF P_GWHOST = SPACE OR P_GWSERV = SPACE.
  CALL FUNCTION 'RFC_SYSTEM_INFO'
      IMPORTING
          RFCSI_EXPORT = RFCSI.

  len = strlen( rfcsi-rfcdest ) - 2.
  systnr = rfcsi-rfcdest+len.
  len = len - 1 - 3.
  r3name = rfcsi-rfcdest+len(3).
  len = len - 1.
  options-rfcgwhost = rfcsi-rfcdest(len).
  CONCATENATE 'sapgw' SYSTNR INTO options-rfcgwserv.
 ELSE.
   options-rfcgwhost = P_GWHOST.
   options-rfcgwserv = P_GWSERV.
 ENDIF.

* Parameters for GWY function call
  GWY_GWHOST = OPTIONS-RFCGWHOST.
  GWY_GWSERV = OPTIONS-RFCGWSERV.
  GWY_TPNAME = P_PROGID.

* Check gateway and server program registered
  CALL FUNCTION 'GWY_GET_NO_REG_PROGRAMS'
     EXPORTING
        GWHOST      = GWY_GWHOST
        GWSERV      = GWY_GWSERV
        TPNAME      = GWY_TPNAME
     IMPORTING
        NOREG_TOTAL = NTOTAL
     EXCEPTIONS
        OTHERS      = 1.

  IF sy-subrc NE 0.
     raise CONNECT_TO_GATEWAY_FAILED.
  ENDIF.

  IF NTOTAL = 0.
     raise SERVER_NOT_REGISTERED.
  ENDIF.

  IF NTOTAL GT 1.
     raise DUPLICATE_REG_PROGRAMS.
  ENDIF.

* build new connection to a registered server
  options-rfcexec   = gwy_tpname.
  options-rfcgwhost = gwy_gwhost.
  options-rfcgwserv = gwy_gwserv.
  options-rfchost   = '%%RFCSERVER%%'.
  IF P_SNC_ON = 'X'.
    options-rfcsnc  = 'X'.
  ENDIF.

  CALL 'RFCControl' ID 'CODE' FIELD 'O'
                    ID 'DESTINATION' FIELD P_DEST
                    ID 'TYPE' FIELD rfctype_external_tcp
                    ID 'OPTIONS' FIELD options.

  IF sy-subrc NE 0.
     RAISE CONNECT_TO_REG_SERVER_FAILED.
   ENDIF.

* and set exclusive mode to keep server owned
  CALL FUNCTION 'SYSTEM_SET_REG_SERVER_PROPERTY'
      EXPORTING  destination = P_DEST
                 exclusiv    = 'Y'
      EXCEPTIONS connect_to_reg_server_failed = 1
                 exclusiv_not_supported       = 2.

  IF SY-SUBRC NE 0.
     CASE SY-SUBRC.
          WHEN 1.
              RAISE CONNECT_TO_REG_SERVER_FAILED.
          WHEN 2.
              RAISE EXCLUSIV_NOT_SUPPORTED.
     ENDCASE.
  ENDIF.

ENDFORM.

FORM DISCONNECT_RFCDEST_FROM_PROGID.
* set exclusive mode to E to end the session
  CALL FUNCTION 'SYSTEM_SET_REG_SERVER_PROPERTY'
     EXPORTING
         destination = P_DEST
         exclusiv    = 'E'
     EXCEPTIONS
         connect_to_reg_server_failed = 1
         exclusiv_not_supported       = 2.
ENDFORM.
