#!/bin/bash
# Using a 'strict' bash
#set -xe
#
# USAGE: 
# >> ./$0 $startDate
# >> ./starter_postpro.sh $startDate

###############################################################################
# Prepare
###############################################################################
startDate=$1
echo "###################################################"
echo "START Logging ($(date)):"
echo "###################################################"
echo "--- exe: $0"
echo "--- Simulation    init-date: ${initDate}"
echo "---              start-data: ${startDate}"
echo "---                  CaseID: ${CaseID}"
echo "---            CaseCalendar: ${CaseCalendar}"
echo "---             COMBINATION: ${COMBINATION}"
echo "--- HOST:  $(hostname)"

echo "--- source helper scripts"
source ${BASE_CTRLDIR}/start_helper.sh
source ${BASE_CTRLDIR}/envs/env_postpro

h0=$(date -u -d "$startDate" '+%H')
d0=$(date -u -d "$startDate" '+%d')
m0=$(date -u -d "$startDate" '+%m')
y0=$(date -u -d "$startDate" '+%Y')

###############################################################################
# Post-Pro
###############################################################################
# Place post-processing steps here
# NOTE: scripts HAVE to run on compute-nodes.
# If the script runs in parralel or on single cpu is not important
formattedStartDate=$(date -u -d "${startDate}" ${dateString})
pfidb="ParFlow_EU11_${formattedStartDate}"
SimresDir="${BASE_SIMRESDIR}/${formattedStartDate}"
ToPostProDir="${BASE_RUNDIR}/ToPostPro/${formattedStartDate}"
PostProStoreDir="${BASE_POSTPRODIR}/${formattedStartDate}"
SLOTHDIR="${BASE_SRCDIR}/SLOTH/sloth"


# comment start here to only run monitoring
# Remove ToPostProDir in case already exisit, to avoid conflicts.
# E.g. from some simulation before.
if [[ -d ${ToPostProDir} ]]; then
  rm -rv ${ToPostProDir}
fi
mkdir -vp ${PostProStoreDir} 

# Enter ctrl/postpro/ dir for needed scripts
cd ${BASE_CTRLDIR}/postpro
echo "DEBUG: pwd --> $(pwd)"
################################################################################
# Handle individual components
################################################################################
IFS='-' read -ra components <<< "${COMBINATION}"
for component in "${components[@]}"; do
  ##############################################################################
  # COSMO
  ##############################################################################
  if [[ "${component}" == cos? ]]; then
    source postproWrapper_COSMO.sh &
  ##############################################################################
  # CLM
  ##############################################################################
  elif [[ "${component}" == clm? ]]; then
    source postproWrapper_CLM.sh &
  ##############################################################################
  # ParFlow
  ##############################################################################
  elif [[ "${component}" == pfl ]]; then
    source postproWrapper_ParFlow.sh &
  fi
done
# wait for all postproWrapper's
wait

# clean up temp-files
rm -rv ${ToPostProDir}
# comment end here to only run monitoring



# comment start here to only run postpro processing
echo "-- START monitoring and monitoring-ts"
newMonitoringDir="${BASE_MONITORINGDIR}/${formattedStartDate}"
# Clean up if already exist, to avoid conflicts.
if [[ -d ${newMonitoringDir} ]]; then
  rm -rf ${newMonitoringDir}
fi
# Create new monitoring dir
mkdir -p ${BASE_MONITORINGDIR}/${formattedStartDate}
# run monitoring_ts script
cd ${BASE_CTRLDIR}/monitoring/
python monitoring_ts.py \
	--configFile ./CONFIG_ts \
	--dataRootDir ${PostProStoreDir}/parflow \
  --tmpDataDir ${BASE_MONITORINGDIR} \
	--saveDir ${newMonitoringDir} &
python monitoring_ts_prud.py \
  --configFile ./CONFIG_ts_prud \
  --dataRootDir ${PostProStoreDir}/parflow \
  --tmpDataDir ${BASE_MONITORINGDIR} \
  --saveDir ${newMonitoringDir} &
python monitoring_SanityCheck.py \
  --configFile CONFIG_SanityCheck_postpro \
  --dataRootDir ${PostProStoreDir} \
  --saveDir ${newMonitoringDir} \
  --runName ${CaseID} &
wait
echo "--- END monitoring"
# comment endhere to only run postpro processing

exit 0
