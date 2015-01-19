rem make pForth dictionary
cd \nomad\pForth\fth
\nomad\pHMSL\pHMSL -i system.fth
copy /Y pForth.dic \nomad\pHMSL\

cd \nomad\pHMSL\
pHMSL fth/make_hmsl.fth
