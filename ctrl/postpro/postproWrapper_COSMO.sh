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
# COSMO
##############################################################################
echo "--- -- - cos"
echo "DEBUG: Create COS subdir within ToPostPro"
mkdir -vp ${ToPostProDir}/cosmo_out
#echo "DEBUG: link raw model output to ToPostPro"
# Do nothing nutil CMORizer is ready, no double work
#ln -sf ${SimresDir}/cosmo/* ${ToPostProDir}/cosmo_out/
# CMOR

# do below until CMOR is ready
# ${NCO_BINDIR} is expected by the CCLM postpro
tmp_NCO_BINDIR=$(which ncrcat)
NCO_BINDIR="${tmp_NCO_BINDIR%/*}"
echo "--- set NCO_BINDIR: ${NCO_BINDIR}"
tmp_NC_BINDIR=$(which ncdump)
NC_BINDIR="${tmp_NC_BINDIR%/*}"
echo "--- set NC_BINDIR: ${NC_BINDIR}"
tmp_CDO_BINDIR=$(which cdo)
CDO_BINDIR="${tmp_CDO_BINDIR%/*}"
CDO=${tmp_CDO_BINDIR} # postpro functions need this as "CDO"
echo "--- set CDO: ${CDO}"

NBOUNDCUT=3
IE_TOT=450
JE_TOT=438
let "IESPONGE = ${IE_TOT} - NBOUNDCUT - 1"
let "JESPONGE = ${JE_TOT} - NBOUNDCUT - 1"
YDATE_START=$(date -u -d "${initDate}" "+%Y%m%d%H")
CURRENT_DATE=$(date -u -d "${startDate}" "+%Y%m%d%H")
#YYYY_MM= "still needed?"
OUTDIR="${ToPostProDir}/cosmo_out"

export IGNORE_ATT_COORDINATES=0  # setting for better rotated coordinate handling in CDO
source ${BASE_CTRLDIR}/postpro/functions.sh

# const. file
INPDIR="${SimresDir}/cosmo/3h" # include subdir 3h/, 6h/, etc
#... cut of the boundary lines from the constant data file
if [ ! -f ${OUTDIR}/lffd${YDATE_START}c.nc ]
then
  ncks -h -d rlon,${NBOUNDCUT},${IESPONGE} -d rlat,${NBOUNDCUT},${JESPONGE} ${INPDIR}/lffd${YDATE_START}c.nc ${OUTDIR}/lffd${YDATE_START}c.nc
 fi

# At the moment the whole COSMO postpro is done sequentially. The only way 
# I can see to paralellise this is to split by different input fields, as 
# NCO cannot open the same file multiple times, and therefore blocks to 
# create time series for each parameter in parallel.
# As the CMORIZER is coming soon, I am not spending time here speeding this 
# up, but keeping it sqeuential.  
echo "- Start processing COSMO output"
echo "--- Starting CCLM default output timeseries"
# 3h output
INPDIR="${SimresDir}/cosmo/3h" 
TS_PARAM=( \
"RAIN_CON" "RAIN_GSP" "SNOW_CON" "SNOW_GSP" "TOT_PREC" "ALHFL_S" "ALWD_S" \
"ALWU_S" "ASOB_S" "ASOB_T" "ASOD_T" "ATHB_S" "ATHB_T" "ASHFL_S" "ASWDIFD_S" \
"ASWDIFU_S" "ASWDIR_S" "CLCT" "DURSUN" "PMSL" "PS" "QV_2M" "T_2M" "U_10M" \
"V_10M" "RELHUM_2M" "ALB_RAD" \
)

# set some helper-vars
echo "DEBUG TS_PARAM ${TS_PARAM[@]}"
for PARAM in ${TS_PARAM[@]}
do
  echo "DEBUG: starting timeseries ${PARAM}"
  timeseries ${PARAM}
done


echo "--- Starting CCLM default output timeseriesp"
PLEVS=(5 200. 500. 850. 925. 1000) # list of pressure levels. Must be the 
                                   # same as or a subset of the plev list 
                                   # in the specific GRIBOUT
INPDIR="${SimresDir}/cosmo/3h" 
TS_PARAM=( \
)

echo "DEBUG TS_PARAM ${TS_PARAM[@]}"
echo "--- using PLEVS: ${PLEVS[@]}"
for PARAM in ${TS_PARAM[@]}
do
  echo "DEBUG: starting timeseriesp ${PARAM} PLEVS[@]"
  timeseriesp ${PARAM}
done

echo "--- Starting calculate further fields"
#windspeed10M
#derotatewind10M
#winddir10M
#snowfraction
#addfields ASWDIR_S ASWDIFD_S ASWD_S
#subtractfields ASOD_T ASOB_T ASOU_T
#addfields RUNOFF_S RUNOFF_G RUNOFF_T
#addfields RAIN_CON SNOW_CON PREC_CON
#addfields SNOW_GSP SNOW_CON TOT_SNOW
#addfields TQC TQI TQW

# Copy ToPostPro to postpro dir (and clean before)
rm -rv ${PostProStoreDir}/cosmo
mkdir -pv ${PostProStoreDir}/cosmo
cp -v ${ToPostProDir}/cosmo_out/* ${PostProStoreDir}/cosmo

exit 0
