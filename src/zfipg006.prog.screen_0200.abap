
process before output.
  module status_0200.

process after input.
  module user_command_0100_exit at exit-command.
  module user_command_0200.

process on value-request.
  field zfipg003-dir_org1 module value_org1.
*  field zfipg003-dir_des1 module value_des1.

  field zfipg003-dir_org2 module value_org2.
*  field zfipg003-dir_des2 module value_des2.

  field zfipg003-dir_org3 module value_org3.
*  field zfipg003-dir_des3 module value_des3.
