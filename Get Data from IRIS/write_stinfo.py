#!/home/yuy/anaconda3/envs/seism27/bin/python
# -*- coding: UTF-8 -*-
from obspy import read_inventory

inv = read_inventory('./stations/*.xml')

st_f = open('St_info.txt','w')
for Network in inv.networks:
    net = Network.code
    for St in Network.stations:
        stnm = St.code
        stlon = St.longitude
        stlat = St.latitude
        stele = St.elevation
        st_f.write('%s %s %.4f %.4f %.1f\n'%(net,stnm,stlon,stlat,stele))
st_f.close()