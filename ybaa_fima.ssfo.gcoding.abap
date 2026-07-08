CALL FUNCTION 'GET_SF_DUNN_DATA'
EXPORTING
is_sfparam              = is_sfparam
IMPORTING
ES_MHNK                    = mhnk
ES_T001                    = t001
ES_KNB5                    = knb5
ES_LFB5                    = lfb5
ES_T047                    = t047
ES_T047C                   = t047c
ES_T047I                   = t047i
ES_T056Z                   = t056z
ES_F150D                   = f150d
ES_FSABE                   = fsabe
ES_ADRNR                   = adrnr
ES_UADRNR                  = uadrnr
ES_ADRS                    = adrs
ES_UADRS                   = uadrs
ES_T047B                   = t047b
eb_testprint               = testprint
e_langu                    = langu
e_lang2                    = lang2
es_F150d_esr               = f150d_esr
es_paymi                   = paymi
es_paymo                   = paymo
tables
t_mhnd                    = th_mhnd
EXCEPTIONS
NO_PARAMETERS_FOUND       = 1
OTHERS                    = 2
.
IF sy-subrc <> 0.
SY-MSGID = 'FM'.
SY-MSGTY = 'E'.
SY-MSGNO = 461.
raise others.
ENDIF.
h_t040a-text1 = space.
show_interest = space.
loop at th_mhnd into mhnd where xzins = ' '.
show_interest = 'X'.
exit.
endloop.

************************************
*SF-Textbausteine

gv_header    = t047i-header.
gv_sender    = t047i-sender.
gv_greetings = t047i-greetings.

concatenate t047i-footer '1' into gv_footer1.
concatenate t047i-footer '2' into gv_footer2.
concatenate t047i-footer '3' into gv_footer3.
concatenate t047i-footer '4' into gv_footer4.

























