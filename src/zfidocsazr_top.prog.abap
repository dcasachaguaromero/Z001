*&---------------------------------------------------------------------*
*&  Include           ZFIDOCSAZR_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS slis.

TABLES bkpf.
TABLES reguh.

Tables ZFI_DOC_ZPSAZR.

CONSTANTS true        TYPE c VALUE 'X'.
CONSTANTS c_zp        TYPE bkpf-blart  VALUE 'ZP'.
CONSTANTS c_XVORL     TYPE reguh-XVORL VALUE ' '.


DATA: TI_TABLA        TYPE TABLE OF ZFI_DOC_ZPSAZR,
      WA_TABLA        TYPE ZFI_DOC_ZPSAZR.
