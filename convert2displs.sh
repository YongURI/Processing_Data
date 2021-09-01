#!/bin/bash

respdir=/run/media/yuy/Data_YUY/NM/resp_WOP
#stlst=/Volumes/YUY_DATA/Project/FFT/Example/St_all.lst #Station information list

#eventdir=/Volumes/YUY_DATA/Project/FFT/Example/event   #Folder named by corresponding seismic events, eg. yyyydddhhmmss.Ms
eventdir=/run/media/yuy/Data_YUY/NM/with_resp_WOP
outdir=/run/media/yuy/Data_YUY/NM/no_resp_WOP            #Output folder
#stlst=/home/yuy/Project/HUANAN/ST_info/HN_I_stn.lst

if [ ! -e $outdir ];then
  mkdir $outdir
fi
cd $eventdir
for event in `ls -d 20*`
do
  cd $eventdir/$event
  origin_time=`echo $event | sed -n 's/\.//gp'|awk '{print substr($1,3,7)}'`
  for zfile in `ls -d *.BHZ.sac`;do
    efile=`echo $zfile | sed -n 's/.BHZ./.BHE./p'`
    nfile=`echo $zfile | sed -n 's/.BHZ./.BHN./p'`
    new_zfile=$outdir/$event/$zfile
    new_nfile=$outdir/$event/$nfile
    new_efile=$outdir/$event/$efile
    if [ ! -e $outdir/$event ];then
      mkdir $outdir/$event
    fi
    echo $zfile
    #net=`echo $zfile | awk -F. '{print $1}'`
    net=NM
    st=`echo $zfile | awk -F. '{print $1}'`
    ST1=`echo $st`
    respZ=$respdir/RESP.$net.$ST1..BHZ
    respN=$respdir/RESP.$net.$ST1..BHN
    respE=$respdir/RESP.$net.$ST1..BHE

#deconvolving the instrument response and converting the data to velocity recording
#resample if needed 'interp delta 0.025'

sac<<EOF
r $zfile
ch kevnm $origin_time
rmean;rtr;taper
ch kstnm $ST1 
ch khole -12345
ch lovrok true
ch lcalda true
transfer from evalresp fname $respZ to vel freq 0.01 0.02 4 8 prew on 
interp delta 0.025
w $new_zfile
r $nfile
ch kevnm $origin_time
ch kstnm $ST1
ch khole -12345
ch lovrok true
ch lcalda true
rmean;rtr;taper
transfer from evalresp fname $respN to vel freq 0.01 0.02 4 8 prew on
interp delta 0.025
w $new_nfile
r $efile
ch kstnm $ST1
ch kevnm $origin_time
ch khole -12345
ch lovrok true
ch lcalda true
rmean;rtr;taper
transfer from evalresp fname $respE to vel freq 0.01 0.02 4 8 prew on
interp delta 0.025
w $new_efile
q
EOF
  done
done
