*&---------------------------------------------------------------------*
*& Report  ZJOB_INS_TRANSFER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZJOB_INS_TRANSFER.

*Submit report as job(i.e. in background)


parameters: bukrs type  dzbukr,
            v_fecha type laufd,
            v_nomina  type  laufi.

data: jobname like tbtcjob-jobname value
                             'TRANSFER DATA'.
data: jobcount like tbtcjob-jobcount,
      host like msxxlist-host.
data: begin of starttime.
        include structure tbtcstrt.
data: end of starttime.
data: starttimeimmediate like btch0000-char1 value 'X',
      str_date(10) type c.

START-OF-SELECTION.
*  CONCATENATE  v_fecha+6(2) v_fecha+4(2) v_fecha+0(4) into str_date SEPARATED BY '.' .
* Job open
  call function 'JOB_OPEN'
       exporting
            delanfrep        = ' '
            jobgroup         = ' '
            jobname          = jobname
            sdlstrtdt        = sy-datum
            sdlstrttm        = sy-uzeit
       importing
            jobcount         = jobcount
       exceptions
            cant_create_job  = 01
            invalid_job_data = 02
            jobname_missing  = 03.
  if sy-subrc ne 0.
                                       "error processing
  endif.

* Insert process into job
 SUBMIT ztr_ins_transfer and return
                with BUKRS = BUKRS
                with V_FECHA = v_fecha
                with V_NOMINA = V_NOMINA
                user sy-uname
                via job jobname
                number jobcount.
  if sy-subrc > 0.
                                       "error processing
  endif.

* Close job
  starttime-sdlstrtdt = sy-datum + 1.
  starttime-sdlstrttm = '220000'.
  call function 'JOB_CLOSE'
       exporting
"            event_id             = starttime-eventid
"            event_param          = starttime-eventparm
"            event_periodic       = starttime-periodic
            jobcount             = jobcount
            jobname              = jobname
"            laststrtdt           = starttime-laststrtdt
"            laststrttm           = starttime-laststrttm
"            prddays              = 1
"            prdhours             = 0
"            prdmins              = 0
"            prdmonths            = 0
"            prdweeks             = 0
"            sdlstrtdt            = starttime-sdlstrtdt
"            sdlstrttm            = starttime-sdlstrttm
            strtimmed            = starttimeimmediate
"            targetsystem         = host
       exceptions
            cant_start_immediate = 01
            invalid_startdate    = 02
            jobname_missing      = 03
            job_close_failed     = 04
            job_nosteps          = 05
            job_notex            = 06
            lock_failed          = 07
            others               = 99.
  if sy-subrc eq 0.
                                       "error processing
  endif.

  end-of-SELECTION.

  write: 'Se ha creado el JOB con el siguiente ID: ',
          jobcount.
  write:  'Fecha:', v_fecha, /,
          'Nomina:', v_nomina, /,
          'Sociedad:', bukrs.
