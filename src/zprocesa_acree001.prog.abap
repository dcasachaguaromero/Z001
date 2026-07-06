*&---------------------------------------------------------------------*
*& Report  ZPROCESA_ACREE001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPROCESA_ACREE001.

TABLES: lfb1.
SELECT-OPTIONS: s_bukrs for lfb1-bukrs,
                s_lifnr for lfb1-lifnr.

START-OF-SELECTION.
data: w_name1(35) type c,
      w_name2(35) type c,
      w_lifnr(10) type c,
      w_stcd1(11) type c,
      w_sortl(10) type c,
      w_ind_fdob(1) type c,
      w_dist(50) type c,
      w_iter type i,
      w_bukrs(4) type c,
      l_oref type ref to cx_root,
      status type statusflag1.

  exec sql.
    connect to 'SAPCSC' as 'con'
  endexec.

  exec sql.
    set connection 'con'
  endexec.

  select a~name1 a~name2 a~stcd1 a~sortl b~bukrs a~lifnr b~REPRF a~ORT02
    into (w_name1, w_name2, w_stcd1, w_sortl, w_bukrs, w_lifnr, w_ind_fdob, w_dist)
    from lfb1 as b inner join lfa1 as a
                on b~lifnr eq a~lifnr
    where b~bukrs in s_bukrs
          and b~lifnr in s_lifnr.
    status = 'X'.
*    SELECT NAME1 NAME2 STCD1 SORTL LIFNR
*      into (w_name1, w_name2, w_stcd1, w_sortl, w_lifnr)
*      from lfa1.
          add 1 to w_iter.
          IF w_iter > 1000.
            w_iter = 0.
            exec sql.
              SET CONNECTION DEFAULT
            endexec.
            exec sql.
                set connection 'con'
            endexec.
          ENDIF.
          TRY .

            EXEC SQL.
                EXECUTE PROCEDURE csc_sap_auxiliares.sp_insert_sap_acreedor(
                                IN :w_name1,
                                IN :w_name2,
                                IN :w_stcd1,
                                IN :w_sortl,
                                IN :w_lifnr,
                                IN :w_bukrs,
                                IN :w_ind_fdob,
                                IN :w_dist
                )
            ENDEXEC.
          catch cx_sy_native_sql_error into l_oref.
            status = ' '.
            write 'problema al insertar el cheque'.
            write:    /,
                      w_name1,
                      w_name2,
                      w_stcd1,
                      w_sortl,
                      w_lifnr,
                      w_bukrs,
                      w_ind_fdob,
                      w_dist,
                      /.
*            message text-001 type 'I'.
*            message `Error in Native SQL.` type 'I'.
          endtry.
  endselect.
  exec sql.
    SET CONNECTION DEFAULT
  endexec.
