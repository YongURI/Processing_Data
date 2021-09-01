# Processing_Data
Scripts for converting seismic file formats to .Sac and other scripts

1. Get Data From IRIS/
  Get_waveform_IRIS.py: This script is use for downloading seismic event data from IRIS, converting data from mseed to sac, and removing instrument responses.
2. convert2displs.sh
  This script is used to remove instrument responses from .Sac files.
  The response file can be writen by package named PDCC.
3. extract_event_from_sac.sh
  This script is used to cut sac files based the catlogue.
4. CatlogCHst.sh
  This script is used to reformat the catlogue file downloaded from https://earthquake.usgs.gov/earthquakes/search/
5. raw2ref.sh
  This script is used to convert raw date from RT130 to mseed.
6. Q330_2mseed.sh
  This script is used to organise the mseed files from Q330.
