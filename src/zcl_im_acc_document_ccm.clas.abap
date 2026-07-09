class ZCL_IM_ACC_DOCUMENT_CCM definition
  public
  final
  create public .

*"* public components of class ZCL_IM_ACC_DOCUMENT_CCM
*"* do not include other source files here!!!
public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ACC_DOCUMENT .
protected section.
*"* protected components of class ZCL_IM_ACC_DOCUMENT_CCM
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_ACC_DOCUMENT_CCM
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_ACC_DOCUMENT_CCM IMPLEMENTATION.


METHOD if_ex_acc_document~change .

  FIELD-SYMBOLS : <lfs_accit> TYPE accit.
*
  LOOP AT c_accit ASSIGNING <lfs_accit> .
    <lfs_accit>-anbwa = zcl_acc_pass=>gv_anbwa.
  ENDLOOP.

ENDMETHOD.                    "IF_EX_ACC_DOCUMENT~CHANGE


method IF_EX_ACC_DOCUMENT~FILL_ACCIT.
endmethod.
ENDCLASS.
