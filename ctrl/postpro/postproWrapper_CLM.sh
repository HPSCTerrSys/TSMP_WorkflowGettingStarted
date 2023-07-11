#!/bin/bash
# Using a 'strict' bash
#set -xe
#
# IMPORTANT
# The script below cannot be run as a standalone. It can only be run from within 
# `start_postpro.sh`. The only reason not to include the lines below directly in 
# `start_postpro.sh` is to use `srun` to run post-processing for COSMO, CLM, and 
# ParFlow in parallel.
# So use with `source $0` only

##############################################################################
# CLM
##############################################################################
echo "--- -- - clm"
echo "DEBUG: Create CLM subdir within ToPostPro"
mkdir -vp ${ToPostProDir}/clm_out
#echo "DEBUG: link raw model output to ToPostPro"
# Do nothing nutil CMORizer is ready, no double work
#ln -sf ${SimresDir}/clm/* ${ToPostProDir}/clm_out/
# CMOR
outVar="H2OSNO H2OSOI SOILLIQ FSH FSDS FLDS FGR FGEV FCTR FCEV FSR FIRA TBOT TSA QFLX_RAIN_GRND QFLX_SNOW_GRND QFLX_EVAP_TOT RAIN SNOW WIND THBOT QBOT ZBOT time time_bounds"
python CLMpostpro.py --variables ${outVar} \
  --indir ${SimresDir}/clm \
  --outdir ${ToPostProDir}/clm_out \
  --gridDes "${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
  --NBOUNDCUT 0
 # Copy ToPostPro to postpro dir (and clean before)
rm -rv ${PostProStoreDir}/clm
mkdir -pv ${PostProStoreDir}/clm
cp -v ${ToPostProDir}/clm_out/* ${PostProStoreDir}/clm

exit 0
