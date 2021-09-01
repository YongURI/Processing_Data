#!/bin/bash
#This Program is used to trannsform .ref data files to .sac event files base on then catlogue.
#                                                          Yu Yong  2012/3 
#refdir=/data/ref

#mseeddir=/home/yuy/DATA/mseed
#mseeddir=/data/GX17XX
mseeddir=/home/yuy/HN_CAGS_ref
if [ ! -e $mseeddir ];then 
mkdir $mseeddir
fi

#sacdir=/home/yuy/DATA/InnerM
#sacdir=/data/GX17/with_resp
sacdir=/data/HN_sac/HN_I_CAGS/with_resp_ref
if [ ! -e $sacdir ];then
mkdir $sacdir
fi

tmpdir=/data/tmp_refteck
if [ ! -e $tmpdir ];then
mkdir $tmpdir
fi

#catlst=/home/yuy/RAWdata/Catlogue/global.m6.0.20110601_20111101.out.lst
#stlst=/home/yuy/Iner.lst
stlst=/home/yuy/Project/HUANAN/ST_info/HN_I_stn.lst
catlst=/home/yuy/Project/HUANAN/ST_info/USGS_HN.Regional_201408_201610_M5.5_D20_150.csv
#catlst=/home/yuy/Project/HUANAN/ST_info/test.lst

channel=01
timelength=3600  ##the length of event data(unit s)
timeshift=0  ##the begin of the event file be before(-) or after(+) the origin time (sec)

###################################################################################

cat $stlst | grep "DZS"| grep "REFTECK" |while read stline;do 
  echo $stline
  #net=`echo $stline | awk '{print $1}'`
  net=HN
  stn=`echo $stline | awk '{print $2}'`
  stlat=`echo $stline | awk '{print $4}'`
  stlong=`echo $stline | awk '{print $3}'`
  stele=`echo $stline | awk '{print $5}'`
  #decline=`cat $maglst | grep $stn[^B] | awk '{print $2}'`   #magnetic declination
  decline=0
#  echo $net $stn 
  if [ ! -e $mseeddir/$stn ];then
    continue
  fi
  cat $catlst | while read event;do
    cd $mseeddir/$stn
    year=`echo $event | awk '{print $1}'`
    julday=`echo $event | awk '{print $2}'| bc -l`
    hour=`echo $event | awk '{print substr($3,1,2)}'`
    min=`echo $event | awk '{print substr($3,3,2)}'`
    sec=`echo $event | awk '{print substr($3,5,2)}'`
    dsec=`echo $event | awk '{print substr($3,8,2)}'`
    evlat=`echo $event | awk '{print $4}'`
    evlong=`echo $event | awk '{print $5}'`
    evdep=`echo $event | awk '{print $6}'`
    Mw=`echo $event | awk '{printf("%.1f",$7)}'`
#    echo   "$year","$julday","$hour":"$min":"$sec"."$dsec"/"$evlat"/"$evlong"/"$evdep" >> origin.lst # origin time of the event
	fdate=`date -d"$year-1-1 $hour:$min:$sec $(($julday-1)) day"`
	julday=`echo $julday | awk '{printf("%03d\n",$1)}'`
	if [ $timeshift -lt 0 ];then
		fdate=`date -d"$fdate $((0-$timeshift)) second ago"`
	else
		fdate=`date -d"$fdate $timeshift second"`
	fi
	
	tdate=`date -d"$fdate $timelength second"`
	
	fyear=`date -d"$fdate" +"%Y"`
	fjulday=`date -d"$fdate" +"%j" | awk '{printf("%03d\n",$1)}'`
	fhour=`date -d"$fdate" +"%H"`
	fmin=`date -d"$fdate" +"%M" | awk '{printf("%02d\n",$1)}'`
	fsec=`date -d"$fdate" +"%S" | awk '{printf("%02d\n",$1)}'`
	
	tyear=`date -d"$tdate" +"%Y"`
	tjulday=`date -d"$tdate" +"%j" | awk '{printf("%03d\n",$1)}'`
	thour=`date -d"$tdate" +"%H"`
  fyear2=`echo $fyear | awk '{print substr($1,3,2)}'`
	tyear2=`echo $tyear | awk '{print substr($1,3,2)}'`
    filelst01=" "
    filelst02=" "
    filelst03=" "
#   echo   "$fyear","$fjulday","$fhour"   # the start time of mseed file used for merging
#    echo   "$tyear","$tjulday","$thour"   # the end time of mseed file used for merging
###########################################################################################     
    if [ $fjulday -eq $tjulday ];then
      i=`echo $fhour | bc -l`
      while [ $i -le $thour ]
      do
        hourdir=`echo $i | awk '{printf("%02d\n",$1)}'`
        filelst01="$filelst01"" "./R"$fjulday"."$channel"/"$hourdir"/"$fyear2".*.1.m
        filelst02="$filelst02"" "./R"$fjulday"."$channel"/"$hourdir"/"$fyear2".*.2.m
        filelst03="$filelst03"" "./R"$fjulday"."$channel"/"$hourdir"/"$fyear2".*.3.m
        ((i=$i+1))
      done
    else
      i=`echo $fhour | bc -l`
      while [ $i -le 23 ]
      do
        hourdir=`echo $i | awk '{printf("%02d\n",$1)}'`
        filelst01="$filelst01"" "./R"$fjulday"."$channel"/"$hourdir"/"$fyear2".*.1.m
        filelst02="$filelst02"" "./R"$fjulday"."$channel"/"$hourdir"/"$fyear2".*.2.m
        filelst03="$filelst03"" "./R"$fjulday"."$channel"/"$hourdir"/"$fyear2".*.3.m
        ((i=$i+1))
      done
      i=0
      while [ $i -le $thour ]
      do
        hourdir=$i
        hourdir=`echo $i | awk '{printf("%02d\n",$1)}'`
        filelst01="$filelst01"" "./R"$tjulday"."$channel"/"$hourdir"/"$tyear2".*.1.m
        filelst02="$filelst02"" "./R"$tjulday"."$channel"/"$hourdir"/"$tyear2".*.2.m
        filelst03="$filelst03"" "./R"$tjulday"."$channel"/"$hourdir"/"$tyear2".*.3.m
        ((i=$i+1))
      done
    fi      
#############################################################################################  
   # echo $filelst01 
    nfile=`ls $filelst01 | wc -l`
    #echo $nfile
    if [ $nfile -gt 0 ];then
#    echo $file1 yuy
    filelst01="$filelst01"" "-o" ""$tmpdir"/tmp01.m
    filelst02="$filelst02"" "-o" ""$tmpdir"/tmp02.m
    filelst03="$filelst03"" "-o" ""$tmpdir"/tmp03.m
#    echo $filelst01   >>filelist.lst                  #the mseed file list used to merge
    qmerge -T -f "$year","$fjulday","$fhour":"$fmin":"$sec"."$dsec" -s "$timelength"S $filelst01
    qmerge -T -f "$year","$fjulday","$fhour":"$fmin":"$sec"."$dsec" -s "$timelength"S $filelst02
    qmerge -T -f "$year","$fjulday","$fhour":"$fmin":"$sec"."$dsec" -s "$timelength"S $filelst03    

    cd $tmpdir
    mseed2sac -k "$stlat"/"$stlong" -E "$year","$julday","$hour":"$min":"$sec"."$dsec"/"$evlat"/"$evlong"/"$evdep"/\
  $tmpdir/tmp01.m
    mseed2sac -k "$stlat"/"$stlong" -E "$year","$julday","$hour":"$min":"$sec"."$dsec"/"$evlat"/"$evlong"/"$evdep"/\
  $tmpdir/tmp02.m
    mseed2sac -k "$stlat"/"$stlong" -E "$year","$julday","$hour":"$min":"$sec"."$dsec"/"$evlat"/"$evlong"/"$evdep"/\
  $tmpdir/tmp03.m  

	outdir=$sacdir/$year.$julday.$hour$min$sec.$Mw
    if [ ! -e $outdir ];then
      mkdir $outdir
    fi
	
  #mv *.[BH][HL]Z.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHZ.sac
  #mv *.[BH][HL]N.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHN.sac
  #mv *.[BH][HL]E.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHE.sac
  mv *.1C1.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHZ.sac
  mv *.1C2.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHN.sac
  mv *.1C3.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHE.sac


  Ncmpaz=`echo "0+$decline"|bc -l`
  Ecmpaz=`echo "90+$decline"|bc -l`
  cd $outdir
sac <<EOF
r $stn.$year$julday$hour$min$sec*.BHZ.sac
ch cmpaz 0
ch cmpinc 0
wh
r $stn.$year$julday$hour$min$sec*.BHN.sac
ch cmpaz $Ncmpaz
ch cmpinc 90
wh
r $stn.$year$julday$hour$min$sec*.BHE.sac
ch cmpaz $Ecmpaz
ch cmpinc 90
wh
r $stn.$year$julday$hour$min$sec*.BH*.sac
setbb chtime &1,o
setbb chtime1 (0 - %chtime%)
ch allt %chtime1
wh
q
EOF

  rm $tmpdir/*
 fi
  done
#  rm -r $mseeddir/$stn/ 
done
rm -r $tmpdir
#rm -r $mseeddir
