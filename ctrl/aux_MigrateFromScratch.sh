#!/usr/bin/bash
#
# Description:
# This script does tar given sourc-dir(s) to given target-dir, 
# removes the original directory(s), and links the created tar-ball form 
# target-dir to the location of the original directory.
#
# USAGE:
# >> bash ./$0 TARGET/DIR SOURCE/DIR/pattern*
# >> bash ./aux_MigrateFromScratch.sh /p/arch2/jibg33/tsmpforecast/ERA5Climat_EUR11_ECMWF-ERA5_analysis_FZJ-IBG3/simres/ /p/scratch/cjibg35/tsmpforecast/ERA5Climat_EUR11_ECMWF-ERA5_analysis_FZJ-IBG3/simres/ERA5Climat_EUR11_ECMWF-ERA5_analysis_FZJ-IBG3_2005*
# >> bash ./aux_MigrateFromScratch.sh /p/largedata/jjsc39/goergen1/sim/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline/simres/ProductionV1/ /p/scratch/cjjsc39/goergen1/sim/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline/simres/ProductionV1/19790[1,2]*

TARGET=$1
# .. and assumes every further argument as SOURCES (there is a plural s!)
shift 1
SOURCES=$@

for SOURCE in $SOURCES; do
  # skip if targetdir is not a directory
  if [[ ! -d $SOURCE ]]; then continue; fi
  source_name=${SOURCE##*/}
  echo "-- taring"
  cd ${SOURCE%/*} && pwd
  echo "working on: $source_name"
  echo "taring to: ${TARGET}/${source_name}.tar"
  tar -cvf ${TARGET}/${source_name}.tar ${source_name}
  if [[ $? != 0 ]] ; then echo "ERROR" && exit 1 ; fi
  echo "-- remove source"
  rm -rf ${source_name}
  echo "-- linking"
  ln -sf ${TARGET}/${source_name}.tar ./
  echo "-- done"
done
