function out = setupDataJoint_mjs()

setenv('DB_PREFIX','u19_'); 
setenv('DJ_USER','mjs20'); %Fill in username
setenv('DJ_PASS','Peace be with you'); %Fill in password
out  = dj.conn('g-u19-db.pni.princeton.edu', getenv('DJ_USER'), getenv('DJ_PASS'), '', true);

%--------------------------------------------------------------------
% Syntax for dj.conn:
% connObj = conn(host, user, pass, initQuery, reset, use_tls, nogui)
%
% Save setupDataJoint_mjs as p-file