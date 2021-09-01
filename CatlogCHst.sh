#!/bin/bash
#This shell script is used to change the format downloaded from USGS for cutting event data form seismic data files.
#                                                       yuyong 2012/3
# For the USGS has the only accsess of Catlogue in the .cvs file. Changed must be done to the script.
#                                                       yuyong 2013/10
#########################################################################################
workdir=/home/yuy/Project/HUANAN
outdir=/home/yuy/Project/HUANAN/ST_info

catlst=$workdir/ST_info/USGS_Global_201408_201610.csv
stlst=$workdir/ST_info/CEIC_station_HN.txt
if [ ! -e $outdir ];then
  mkdir $outdir
fi
cd $workdir

mindeltdg=20
maxdeltdg=150
#mindeltdg=85
#maxdeltdg=149
#maxlat=
#minlat=
#maxlong=
#minlong=
#minlong & maxlong 确定是由北极向下看，沿顺时针，进入所选区域为min,出所选区域为max
minMw=0

lines=`cat $catlst |wc -l`

#for stn in `cat $stlst | awk '{print $1}'`
for stn in `echo HN`
do 
     stlat=28
     stlong=110
    #stlat=`cat $stlst | grep $stn | awk '{print $2}'`
    #stlong=`cat $stlst | grep $stn | awk '{print $3}'`
    echo $stn $stlat $stlong
    outlst=`echo $catlst | awk -F/ '{print $NF}'| sed 's/Global/'$stn'.Regional'/g`
    if [ -e $outdir/$outlst ];then
       rm -i $outdir/$outlst
    fi
    i=2
    while [ "$i" -le "$lines" ] 
    do 
      event=`sed -n "$i"p $catlst`
      ((i=$i+1))
      year=`echo $event | awk -F- '{print $1}'`
      month=`echo $event | awk -F- '{print $2}'`
      day=`echo $event | awk -F- '{print substr($3,1,2)}'`
      hms=`echo $event | awk '{print substr($1,12,11)}' | sed -n s/://gp`
      if [ `echo $hms | wc -m` -lt 8 ];then 
      	hms=$hms".00"
      fi
      julday=`date -d"$year-$month-$day" +%j`

      lat=`echo $event | awk -F, '{print $2}'`
      long=`echo $event | awk -F, '{print $3}'`
      deepth=`echo $event | awk -F, '{print $4}'`
      Mw=`echo $event | awk -F, '{print $5}'`
      Mw_int=`echo $event | awk -F, '{print int($5)}'`

#      if [ $Mw -ge $minMw ];then    
#         echo $year $julday $hms $lat $long $deepth $Mw >> $outdir/$outlst
#      fi

#      if [ $lat -ge $minlat ] && [ $lat -le $maxlat ];then 
#         if [ $long -ge $maxlong ] && [ $long -le $maxlong ];then
#            echo $year $julday $hms $lat $long $deepth $Mw >> $outdir/$outlst  
#         fi 
#      fi
delaz.v2 <<!
$stlat $stlong
$lat $long
!
      deltdg=`cat delaz.out | awk '{print int($2+0.5)}'`
      if [ $deltdg -le $maxdeltdg ] && [ $deltdg -ge $mindeltdg ] && [ $Mw_int -ge $minMw ];then 
         echo $year $julday $hms $lat $long $deepth $Mw $deltdg 
         echo $year $julday $hms $lat $long $deepth $Mw $deltdg>> $outdir/$outlst
      fi

    done
done
rm delaz.out
