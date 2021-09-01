# Processing_Data
Scripts for converting seismic file formats to .Sac and other scripts

1. Get Data From IRIS/
  Get_waveform_IRIS.py: This script is use for downloading seismic event data from IRIS, converting data from mseed to sac, and removing instrument responses.
2. CatlogCHst.sh
  This script is used to reformat the catlogue file downloaded from https://earthquake.usgs.gov/earthquakes/search/
3. extract_event_from_sac.sh
  This script is used to cut sac files based the catlogue.
4. raw2ref.sh
  This script is used to convert raw date from RT130 to mseed.
5. extract_ref.sh
  This script is used to cut .Sac files from the organised mseed files by raw2ref.sh.
6. Q330_2mseed.sh
  This script is used to organise the mseed files from Q330.
7. extract_Q330.sh
  This script is used to cut .Sac files from the organised mseed files by Q330_2mseed.sh.
8. extract_nano.sh
  This script is used t cut .Sac files from nano compact sensor.
9. convert2displs.sh
  This script is used to remove instrument responses from .Sac files.
  The response file can be writen by package named PDCC.
 
