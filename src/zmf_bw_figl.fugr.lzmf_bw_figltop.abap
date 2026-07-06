FUNCTION-POOL ZMF_BW_FIGL.                  "MESSAGE-ID ..

* INCLUDE LZMF_BW_FIGLD...                   " Local class definition

* Include LRSAXD01 can be directly referenced by application APIs !!
INCLUDE lrsaxd01.

* Include macros for "describe field"
INCLUDE rsaucmac.

* Data and macros for tracing of BI Content Extraction
DATA g_r_tracer TYPE REF TO if_rsap_extraction_tracer.
INCLUDE rsap_extraction_tracing_bice.

* Constants
CONSTANTS: rsax_c_flag_on  VALUE 'X',
           rsax_c_flag_off VALUE ' '.

* Type-pools                       (TNS_220101)
TYPE-POOLS:
  rsaot,
  rsazt.

* Select ranges
RANGES:
   g_r_carrid FOR sbook-carrid,
   g_r_connid FOR sbook-connid,
   g_r_fldate FOR sbook-fldate,
   g_r_bookid FOR sbook-bookid.

* Global data for reading from archive.
DATA:
  g_extrmode      TYPE rsazt_extrmode,
  g_step_extrmode TYPE rsazt_extrmode,
  g_handle        TYPE i.

* ==== Required by RSAX_BIW_GET_SEGM
* General
DATA: g_no_more_data,
      g_s_params TYPE roextrprms.

* ---- requested fields
DATA: g_t_segfields TYPE TABLE OF rssegfdsel,
      g_t_fields1 TYPE sbiwa_t_fields,
      g_t_fields2 TYPE sbiwa_t_fields,
      g_t_fields3 TYPE sbiwa_t_fields,
      g_t_fields4 TYPE sbiwa_t_fields,
      g_t_fields5 TYPE sbiwa_t_fields,
      g_t_fields6 TYPE sbiwa_t_fields.

* ---- Length
DATA: BEGIN OF g_s_length,
        roosource    TYPE i,
        roosourcet   TYPE i,
        roosseg      TYPE i,
        roosfield    TYPE i,
        roohiecat    TYPE i,
        roohiecom    TYPE i,
      END OF g_s_length.
