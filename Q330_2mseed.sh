#/bin/bash

#data_d=/run/media/yuy/5C2C52412C5215FC/201703华南查台
data_d=/run/media/yuy/5C2C52412C5215FC/"$1"

outdir=/run/media/yuy/新加卷/HN_II/QS330_3t

tmpdir=/data/tmp_II
stlst=/home/yuy/Project/HUANAN/ST_info/BDinf/BDcmg3t.lst

if [ ! -d $outdir ];then
	mkdir $outdir
fi

if [ ! -d $tmpdir ];then
	mkdir $tmpdir
fi

cd $data_d
for stnm in `cat $stlst`
do

if [ ! -d $outdir/$stnm ];then
	mkdir $outdir/$stnm
fi

for filenm in `ls $data_d/$stnm/data-*/`
#for filenm in `ls $data_d/$stnm/data/bd-bd* $data_d/$stnm/disk[12]/data/bd-bd* $data_d/$stnm/bd-bd*`
do
	echo $filenm
	cd $tmpdir
	cp $filenm $tmpdir
	sdrsplit -P -x *.HL? -D $filenm
	n_channel=`ls *.HLN.|wc -l`
	if [ $n_channel -ge 1 ] ; then
		for n_file in `ls *.HLN.`
		do
			date_n=`echo $n_file | awk '{print substr($1,1,15)}'`
			julday=`echo $n_file | awk -F. '{printf $2}'`
#			hour=`echo $n_file | awk -F. '{printf $3}'`
			if [ ! -d /$outdir/$stnm/R$julday.01 ];then
				mkdir /$outdir/$stnm/R$julday.01
			fi

			mv $n_file /$outdir/$stnm/R$julday.01/$date_n.XXXX.2.m		
		done
		for e_file in `ls *.HLE.`
		do
			date_e=`echo $e_file | awk '{print substr($1,1,15)}'`
			julday=`echo $e_file | awk -F. '{printf $2}'`
			if [ ! -d /$outdir/$stnm/R$julday.01 ];then
				mkdir /$outdir/$stnm/R$julday.01
			fi
			mv $e_file /$outdir/$stnm/R$julday.01/$date_e.XXXX.3.m		
		done
		for z_file in `ls *.HLZ.`
		do
			date_z=`echo $z_file | awk '{print substr($1,1,15)}'`
			julday=`echo $z_file | awk -F. '{printf $2}'`
			if [ ! -d /$outdir/$stnm/R$julday.01 ];then
				mkdir /$outdir/$stnm/R$julday.01
			fi
			mv $z_file /$outdir/$stnm/R$julday.01/$date_z.XXXX.1.m		
		done
		
	fi
	rm $tmpdir/*
	
done
	
done
