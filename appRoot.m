function r = appRoot()
% appRoot  Folder where EBEAE_FD_FLIM.mlapp (and these .m files) is located,
%          regardless of the current MATLAB folder.
    r = fileparts(mfilename('fullpath'));
end
