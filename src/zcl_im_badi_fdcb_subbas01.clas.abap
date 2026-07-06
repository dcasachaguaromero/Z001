class ZCL_IM_BADI_FDCB_SUBBAS01 definition
  public
  final
  create public .

*"* public components of class ZCL_IM_BADI_FDCB_SUBBAS01
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_BADI_FDCB_SUBBAS01 .
protected section.
*"* protected components of class ZCL_IM_BADI_FDCB_SUBBAS01
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_BADI_FDCB_SUBBAS01
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_BADI_FDCB_SUBBAS01 IMPLEMENTATION.


method IF_EX_BADI_FDCB_SUBBAS01~GET_DATA_FROM_SCREEN_OBJECT.
*  ex_invfo  = me->if_ex_badi_fdcb_subbas01~invfo.
endmethod.


METHOD if_ex_badi_fdcb_subbas01~put_data_to_screen_object.
  SET PARAMETER ID 'BUK'  FIELD im_invfo-bukrs.
*  me->if_ex_badi_fdcb_subbas01~invfo  = im_invfo.
ENDMETHOD.
ENDCLASS.
