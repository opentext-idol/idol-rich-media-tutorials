# Patching AMD processors

> NOTE: Only do this if directed to do so.

If you run an AMD processor on Windows, you may require a patch to enable neural-network dependent functions, such as face recognition training.  To apply the patch:

1. ensure Knowledge Discovery Media Server is not running
1. in your Knowledge Discovery Media Server's `libs` directory, overwrite the file `libopenblas.dll` with the alternate version `libopenblas_amd_bulldozer.dll`, which you will find in the same directory
1. restart Knowledge Discovery Media Server
1. ensure Knowledge Discovery Media Server is again running by pointing your browser to [`admin`](http://localhost:14000/a=admin)
