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
# sfc output
INPDIR="${SimresDir}/cosmo/sfc" 
TS_PARAM=( \
   'T_2M' 'TMAX_2M' 'TMIN_2M' 'TOT_PREC' 'QV_2M' 'RELHUM_2M' 'PS' 'PMSL' 'U_10M' 'V_10M' 'CLCT' 'ASWDIR_S' 'ASWDIFD_S' 'ALWD_S' \
   'AEVAP_S' \
   'FR_SNOW' \
   'RUNOFF_S' 'RUNOFF_G' 'SNOW_MELT' 'W_SNOW' 'H_SNOW' 'W_SO' 'W_SO_ICE' \
   'HSURF' 'FR_LAND' \
   'T_SO' 'T_S' 'PRR_CON' 'PRS_CON' 'PRR_GSP' 'PRS_GSP' 'AUMFL_S' 'AVMFL_S' 'VABSMX_10M' 'ASWDIFU_S' 'ALWU_S' 'ASOD_T' 'ATHB_T' 'ASOB_T' 'ASHFL_S' 'ALHFL_S' 'HPBL' 'TQV' 'TQC' 'TQI' 'SNOW_CON' 'SNOW_GSP' 'DURSUN' \
   'VMAX_10M' 'CLCH' 'CLCM' 'CLCL' 'Z0' 'CAPE_ML' 'CAPE_MU' 'CIN_ML' 'CIN_MU' \
   'TQG' 'PRG_GSP' \
   'TQS' 'TQR' 'FIS' 'TWATER' 'TOT_PR' 'RAIN_GSP' 'RAIN_CON' 'TD_2M' \
   'TDIV_HUM' \
   'TCM' 'TCH' 'HBAS_CON' 'HTOP_CON' 'CEILING' 'TKE_CON' 'CAPE_CON' 'LCL_ML' 'LFC_ML' 'DURSUN_M' 'DURSUN_R' 'QV_S' 'T_SNOW' 'ALB_RAD' 'ATHB_S' 'ASOB_S' \
   'FRESHSNW', 'W_I' \
)

# set some helper-vars
echo "DEBUG TS_PARAM ${TS_PARAM[@]}"
for PARAM in ${TS_PARAM[@]}
do
  echo "DEBUG: starting timeseries ${PARAM}"
  timeseries ${PARAM}
done


echo "--- Starting CCLM default output timeseriesp"
# list of pressure levels. Must be the same as or a subset of the plev list 
# in the specific GRIBOUT
PLEVS=(50. 70. 100. 150. 200. 250. 300. 400. 500. 600. 700. 850. 925. 1000.) 
INPDIR="${SimresDir}/cosmo/pl" 
TS_PARAM=( \
  'U' 'V' 'W' 'T' 'QV' 'FI' \
)

echo "DEBUG TS_PARAM ${TS_PARAM[@]}"
echo "--- using PLEVS: ${PLEVS[@]}"
for PARAM in ${TS_PARAM[@]}
do
  echo "DEBUG: starting timeseriesp ${PARAM} PLEVS[@]"
  timeseriesp ${PARAM}
done


echo "--- Starting CCLM default output timeseriesZ"
# list of z-levels. Must be the same as or a subset of the zlev list 
# in the specific GRIBOUT
ZLEVS=(50. 100. 150. 200. 250. 300.) 
INPDIR="${SimresDir}/cosmo/zl" 
TS_PARAM=( \
  'U' 'V' 'T' 'QV' \
)

echo "DEBUG TS_PARAM ${TS_PARAM[@]}"
echo "--- using ZLEVS: ${ZLEVS[@]}"
for PARAM in ${TS_PARAM[@]}
do
  echo "DEBUG: starting timeseriesp ${PARAM} ZLEVS[@]"
  timeseriesz ${PARAM}
done


# Copy ToPostPro to postpro dir (and clean before)
rm -rv ${PostProStoreDir}/cosmo
mkdir -pv ${PostProStoreDir}/cosmo
cp -v ${ToPostProDir}/cosmo_out/* ${PostProStoreDir}/cosmo

exit 0
