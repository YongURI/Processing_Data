#!/home/yuy/anaconda3/envs/seism27/bin/python
# -*- coding: UTF-8 -*-

def write_cat(cat,cat_file):
    import obspy

    f = open(cat_file,"w+")
    for evt in cat.events:
        evlat = evt.origins[0].latitude
        evlon = evt.origins[0].longitude
        evdep = evt.origins[0].depth/1e3
        evyear = evt.origins[0].time.date.year
        evmonth = evt.origins[0].time.date.month
        evday = evt.origins[0].time.date.day
        evhour = evt.origins[0].time.datetime.hour
        evmin = evt.origins[0].time.datetime.minute
        evsec = evt.origins[0].time.datetime.second
        evmsec = int(evt.origins[0].time.datetime.microsecond/1e3)
        Mag = evt.magnitudes[0].mag
        evid = evt.resource_id.resource_id.split("=")[1]
        f.write('%d-%02d-%02dT%02d:%02d:%02d.%03d %s %.4f %.4f %.1f %.1f\n' \
            %(evyear,evmonth,evday,evhour,evmin,evsec,evmsec,evid,evlat,evlon,evdep,Mag))

    f.close()