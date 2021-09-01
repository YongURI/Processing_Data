#!/bin/bash

rawdir=/run/media/yuy/BE72E2A572E2619F/HN_I/CAGS/TEAM2/"$1"
refdir=/data/tmp_ref
if [ ! -e $refdir ];then
	mkdir $refdir
fi
mseeddir=/home/yuy/HN_CAGS_ref
if [ ! -e $mseeddir ];then
        mkdir $mseeddir
fi

stlst=/home/yuy/Project/HUANAN/ST_info/GD_GX_GDW.lst
cd $rawdir
#for st in `cat $stlst | grep "GDW" |awk '{print $1}'`;do
#for st in `echo GDW01`;do
for st in `ls -d C018 C021 C02[4-8]`;do
	cd $refdir
	echo $rawdir/"$st"
	rt130cut -r $rawdir/"$st"
	if [ ! -e $mseeddir/"$st" ];then
		mkdir $mseeddir/"$st"
	fi
	cd $mseeddir/"$st"
	for refnm in `ls $refdir/*.ref`;do
		ref2mseed -h -f $refnm
	done
	rm  $refdir/*.ref
done
