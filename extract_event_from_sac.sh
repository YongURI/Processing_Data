#!/bin/bash
#This Program is used to trannsform .ref data files to .sac event files base on then catlogue.
#                                                          Yu Yong  2012/3 
#refdir=/data/ref

mseeddir=/run/media/yuy/Data_YUY/NM/SAC/
if [ ! -e $mseeddir ];then 
mkdir $mseeddir
fi

sacdir=/run/media/yuy/Data_YUY/NM/with_resp
if [ ! -e $sacdir ];then
mkdir $sacdir
fi

tmpdir=/data/tmp
if [ ! -e $tmpdir ];then
mkdir $tmpdir
fi

stlst=/run/media/yuy/Data_YUY/NM/bash/nm_eric.sta
catlst=/run/media/yuy/Data_YUY/Bash/NCC.Regional_Catalog_2010_2011_M5.5.txt

channel=01
timelength=3600  ##the length of event data(unit s)
timeshift=0  ##the begin of the event file be before(-) or after(+) the origin time (sec)

###################################################################################

cat $stlst | while read stline;do 
  echo $stline
  #net=`echo $stline | awk '{print $1}'`
  net=NM
  stn=`echo $stline | awk '{print $2}'`
  stlat=`echo $stline | awk '{print $4}'`
  stlong=`echo $stline | awk '{print $3}'`
  stele=`echo $stline | awk '{print $5}'`
  #stele=1
  #decline=`cat $maglst | grep $stn[^B] | awk '{print $2}'`   #magnetic declination
  decline=0
#  echo $net $stn 
  if [ ! -e $mseeddir/$stn ];then
    continue
  fi
  cat $catlst | grep "2011 " | while read event;do
    cd $mseeddir/$stn
    year=`echo $event | awk '{print $1}'`
    julday=`echo $event | awk '{print $2}'| bc -l`
    hour=`echo $event | awk '{print substr($3,1,2)}'`
    min=`echo $event | awk '{print substr($3,3,2)}'`
    sec=`echo $event | awk '{print substr($3,5,2)}'`
    dsec=`echo $event | awk '{print substr($3,8,2)}'`
    msed=`echo $event | awk '{print substr($3,8,2)}'`
    evlat=`echo $event | awk '{print $4}'`
    evlong=`echo $event | awk '{print $5}'`
    evdep=`echo $event | awk '{print $6}'`
    Mw=`echo $event | awk '{printf("%.1f",$7)}'`
#    echo   "$year","$julday","$hour":"$min":"$sec"."$dsec"/"$evlat"/"$evlong"/"$evdep" >> origin.lst # origin time of the event
	fdate=`date -d"$year-1-1 $hour:$min:$sec $(($julday-1)) day 1 hour ago"`
	julday=`echo $julday | awk '{printf("%03d\n",$1)}'`
	if [ $timeshift -lt 0 ];then
		fdate=`date -d"$fdate $((0-$timeshift)) second ago"`
	else
		fdate=`date -d"$fdate $timeshift second"`
	fi
	
	tdate=`date -d"$fdate 2 hour $timelength second"`
	
	fyear=`date -d"$fdate" +"%Y"`
	fjulday=`date -d"$fdate" +"%j" | awk '{printf("%03d\n",$1)}'`
	#echo yuy $fjulday $stn
	fmonth=`date -d"$fdate" +"%m" | awk '{printf("%02d\n",$1)}'`
	fday=`date -d"$fdate" +"%d" | awk '{printf("%02d\n",$1)}'`
	fhour=`date -d"$fdate" +"%H"`
	fmin=`date -d"$fdate" +"%M" | awk '{printf("%02d\n",$1)}'`
	fsec=`date -d"$fdate" +"%S" | awk '{printf("%02d\n",$1)}'`
	
	tyear=`date -d"$tdate" +"%Y"`
	tjulday=`date -d"$tdate" +"%j" | awk '{printf("%03d\n",$1)}'`
	tmonth=`date -d"$tdate" +"%m" | awk '{printf("%02d\n",$1)}'`
    tday=`date -d"$tdate" +"%d" | awk '{printf("%02d\n",$1)}'`	
	thour=`date -d"$tdate" +"%H"`
  fyear2=`echo $fyear | awk '{print substr($1,3,2)}'`
	tyear2=`echo $tyear | awk '{print substr($1,3,2)}'`
    filelst01=" "
    filelst02=" "
    filelst03=" "
   #echo   "$fyear","$fjulday","$fhour"   # the start time of mseed file used for merging
    #echo   "$tyear","$tjulday","$thour"   # the end time of mseed file used for merging
###########################################################################################     
	i=`echo $fhour | bc -l`
	fyy=`echo $fyear | awk '{print substr($1,3,2)}'`
	tyy=`echo $tyear | awk '{print substr($1,3,2)}'`
	if [ $fjulday -eq $tjulday ];then
 		while [ $i -le $thour ];do
      ii=`echo $i | awk '{printf("%02d",$1)}'`
			filelst01="$filelst01"" "./$fyy.$fjulday.$ii.*.1.sac
        	filelst02="$filelst02"" "./$fyy.$fjulday.$ii.*.2.sac
        	filelst03="$filelst03"" "./$fyy.$fjulday.$ii.*.3.sac
			((i=$i+1))
		done
	else
		while [ $i -le 23 ];do 
				ii=`echo $i | awk '{printf("%02d",$1)}'`
				filelst01="$filelst01"" "./$fyy.$fjulday.$ii.*.1.sac
	        	filelst02="$filelst02"" "./$fyy.$fjulday.$ii.*.2.sac
	        	filelst03="$filelst03"" "./$fyy.$fjulday.$ii.*.3.sac
				((i=$i+1))
        done
		i=0
		while [ $i -le $thour ];do
			ii=`echo $i | awk '{printf("%02d",$1)}'`
			filelst01="$filelst01"" "./$tyy.$tjulday.$ii.*.1.sac
        	filelst02="$filelst02"" "./$tyy.$tjulday.$ii.*.2.sac
        	filelst03="$filelst03"" "./$tyy.$tjulday.$ii.*.3.sac
			((i=$i+1))
        done	
	fi      
#############################################################################################  
   # echo $filelst01 
    nfile=`ls $filelst01 | wc -l`
    #echo $filelst01
    if [ $nfile -gt 0 ];then
    otime="$year $julday $hour $min $sec $dsec"0
	  echo $otime
    outdir=$sacdir/$year.$julday.$hour$min$sec.$Mw
    if [ ! -e $outdir ];then
      mkdir $outdir
    fi
    foutZ=$outdir/$stn.$year$julday$hour$min$sec.BHZ.sac
    foutN=$outdir/$stn.$year$julday$hour$min$sec.BHN.sac
    foutE=$outdir/$stn.$year$julday$hour$min$sec.BHE.sac
sac<<EOF
r $filelst01
ch KNETWK $net
merge overlap average gap zero
ch o gmt $otime
ch allt (0-&1,o&)
ch cmpaz 0
ch cmpinc 0
ch kcmpnm BHZ
w tmp01.sac
r $filelst02
ch KNETWK $net
merge overlap average gap zero
ch o gmt $otime
ch allt (0-&1,o&)
ch cmpaz 0
ch cmpinc 90
ch kcmpnm BHN
w tmp02.sac
r $filelst03
ch KNETWK $net
merge overlap average gap zero
ch o gmt $otime
ch allt (0-&1,o&)
ch cmpaz 90
ch cmpinc 90
ch kcmpnm BHE
w tmp03.sac
cut o $timeshift $timelength
r tmp01.sac tmp02.sac tmp03.sac
ch stla $stlat
ch stlo $stlong
ch stel $stele
ch evla $evlat
ch evlo $evlong
ch evdp $evdep
ch A -12345
w $foutZ $foutN $foutE 
cut off
q
EOF


  rm $tmpdir/*
 fi
  done
#  rm -r $mseeddir/$stn/ 
done
rm -r $tmpdir
#rm -r $mseeddir
