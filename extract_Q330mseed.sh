#!/bin/bash
#This Program is used to trannsform .ref data files to .sac event files base on then catlogue.
#                                                          Yu Yong  2012/3 
#######################################################################################
#Adding the function of correcting the magnetic decline
#
#            Yu Yong 2012/11
#
#Make the script shorter and simpler and use new version of mseed2sac
#Yong Yu@URI 2018/5

mseeddir=/home/yuy/HN_CAGS_q330

sacdir=/data/HN_sac/HN_I_CAGS/with_resp_q330
if [ ! -e $sacdir ];then
mkdir $sacdir
fi

tmpdir=/data/tmp_q330
if [ ! -e $tmpdir ];then
mkdir $tmpdir
fi

catlst=/home/yuy/Project/HUANAN/ST_info/USGS_HN.Regional_201408_201610_M5.5_D20_150.csv
#catlst=/home/yuy/Project/HUANAN/ST_info/test.lst
stlst=/home/yuy/Project/HUANAN/ST_info/HN_I_stn.lst
maglst=/home/yuy/Project/FFT_SOD/SOD_magdec.lst


channel=01
timelength=3600  ##the length of event data(unit s) less than 1 day

timeshift=0  ##the begin of the event file be before(-) or after(+) the origin time (sec)

###################################################################################

#lines=`cat $catlst |wc -l`

#cat $stlst | while read stline;do 
cat $stlst | grep "DZS" |grep "Q330" | while read stline;do
  echo $stline
  net=`echo $stline | awk '{print $1}'`
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
	
#    echo   "$fyear","$fjulday","$fhour"   # the start time of mseed file used for merging
#    echo   "$tyear","$tjulday","$thour"   # the end time of mseed file used for merging
###########################################################################################  
	filelst01=" "
	filelst02=" "
	filelst03=" "
	fyear2=`echo $fyear | awk '{print substr($1,3,2)}'`
	tyear2=`echo $tyear | awk '{print substr($1,3,2)}'`
	for ch in `echo 1 2 3` ;do
  	  zfhour=0
      zthour=23
  	  if [ $fjulday -eq $tjulday ];then
  		cd R"$fjulday"."$channel"
  		for zfile in `ls "$fyear2".*.$ch.m`;do
	  		zhour=`echo $zfile | awk -F. '{print $3}' |bc -l`
	  		if [ $zhour -lt $fhour ];then
		 	   zfhour=`echo "if ($zhour >= $zfhour){$zhour}else{$zfhour}" | bc -l`
	  	 	elif [ $zhour -gt $thour ];then
		 	   zthour=`echo "if ($zhour <= $zthour){$zhour}else{$zthour}" | bc -l`
	  	 	elif [ $zhour -ge $fhour ] && [ $zhour -le $thour ];then
				case $ch in
				1)
					filelst01="$filelst01"" "./R"$fjulday"."$channel"/$zfile
					;;
				2)
					filelst02="$filelst02"" "./R"$fjulday"."$channel"/$zfile
					;;
				3)
					filelst03="$filelst03"" "./R"$fjulday"."$channel"/$zfile
					;;
				esac
			fi
		done  
#	echo $zfhour $zthour
		zfhour=`echo $zfhour | awk '{printf("%02d\n",$1)}'`
		zthour=`echo $zthour | awk '{printf("%02d\n",$1)}'`
	
		case $ch in
		1)
			filelst01="$filelst01"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zfhour".*.$ch.m
			;;
		2)
			filelst02="$filelst02"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zfhour".*.$ch.m
			;;
		3)
			filelst03="$filelst03"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zfhour".*.$ch.m
			;;
		esac
	
		if [ $zthour -ne 23 ];then
			case $ch in
			1)
				filelst01="$filelst01"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
				;;
			2)
				filelst02="$filelst02"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
				;;
			3)
				filelst03="$filelst03"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
				;;
			esac
    	else
			n23=`ls "$tyear2"."$tjulday"."$zthour".*.$ch.m`
			if [ -n "$n23" ];then
				case $ch in
				1)
					filelst01="$filelst01"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
					;;
				2)
					filelst02="$filelst02"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
					;;
				3)
					filelst03="$filelst03"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
					;;
				esac
	    	fi	
    	fi

  	else
  		cd R"$fjulday"."$channel"
  		for zfile in `ls "$fyear2".*.$ch.m`;do
	  		zhour=`echo $zfile | awk -F. '{printf $3}'| bc -l`
	  	  	if [ $zhour -lt $fhour ];then
		 		zfhour=`echo "if ($zhour >= $zfhour){$zhour}else{$zfhour}" | bc -l`
	  	  	elif [ $zhour -ge $fhour ] && [ $zhour -le 23 ];then
				case $ch in
				1)
					filelst01="$filelst01"" "./R"$fjulday"."$channel"/$zfile
					;;
				2)
					filelst02="$filelst02"" "./R"$fjulday"."$channel"/$zfile
					;;
				3)
					filelst03="$filelst03"" "./R"$fjulday"."$channel"/$zfile
					;;
				esac
	  	 	fi  
   		done
  		cd ../R"$tjulday"."$channel"
  		for zfile in `ls "$tyear2".*.$ch.m`;do
	  		zhour=`echo $zfile | awk -F. '{print $3}' | bc -l`
	 		if [ $zhour -gt $thour ];then
	     		zthour=`echo "if ($zhour <= $zthour){$zhour}else{$zthour}" | bc -l` 
	  		elif [ $zhour -ge 0 ] && [ $zhour -le $thour ];then
				case $ch in
				1)
					filelst01="$filelst01"" "./R"$tjulday"."$channel"/$zfile
					;;
				2)
					filelst02="$filelst02"" "./R"$tjulday"."$channel"/$zfile
					;;
				3)
					filelst03="$filelst03"" "./R"$tjulday"."$channel"/$zfile
					;;
				esac
	  		fi  
   		done
		zfhour=`echo $zfhour | awk '{printf("%02d\n",$1)}'`
		zthour=`echo $zthour | awk '{printf("%02d\n",$1)}'`
		case $ch in
		1)
			filelst01="$filelst01"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
			filelst01="$filelst01"" "./R"$fjulday"."$channel"/"$fyear2"."$tjulday"."$zthour".*.$ch.m
			;;
		2)
			filelst02="$filelst02"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
			filelst02="$filelst02"" "./R"$fjulday"."$channel"/"$fyear2"."$tjulday"."$zthour".*.$ch.m
			;;
		3)
			filelst03="$filelst03"" "./R"$fjulday"."$channel"/"$fyear2"."$fjulday"."$zthour".*.$ch.m
			filelst03="$filelst03"" "./R"$fjulday"."$channel"/"$fyear2"."$tjulday"."$zthour".*.$ch.m
			;;
		esac
   	fi   
	done   
    cd $mseeddir/$stn
	
#############################################################################################  
   file1=`echo $filelst01 |awk '{print $1}'`
   if [ -e $file1 ];then
#    echo $file1 yuy
    
    filelst01="$filelst01"" "-o" ""$tmpdir"/tmp01.m
    filelst02="$filelst02"" "-o" ""$tmpdir"/tmp02.m
    filelst03="$filelst03"" "-o" ""$tmpdir"/tmp03.m
#    echo $filelst01   >>filelist.lst                  #the mseed file list used to merge
    qmerge -T -f "$year","$fjulday","$fhour":"$fmin":"$sec"."$dsec" -s "$timelength"S $filelst01
    qmerge -T -f "$year","$fjulday","$fhour":"$fmin":"$sec"."$dsec" -s "$timelength"S $filelst02
    qmerge -T -f "$year","$fjulday","$fhour":"$fmin":"$sec"."$dsec" -s "$timelength"S $filelst03    

    julday=`echo $julday | awk '{printf("%03d\n",$1)}'`

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
	
  mv *.[BH][HL]Z.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHZ.sac
  mv *.[BH][HL]N.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHN.sac
  mv *.[BH][HL]E.*.$year.$julday.$hour$min$sec.SAC $outdir/$stn.$year$julday$hour$min$sec.BHE.sac

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
