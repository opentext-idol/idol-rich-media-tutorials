# Patching AMD processors

> Only do this if directed to do so.

If you run an AMD processor on Windows, you may require a patch to enable neural-network dependent functions, such as face recognition training.  To apply the patch:

1. ensure Media Server is not running
2. in your Media Server's `libs` directory, overwrite the file `libopenblas.dll` with the alternate version `libopenblas_amd_bulldozer.dll`, which you will find in the same directory
3. restart Media Server
4. ensure Media Server is again running by pointing your browser to [`admin`](http://localhost:14000/a=admin)
