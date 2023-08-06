#!/bin/bash
#
# USAGE: 
# >> ./$0 CTRLDIR startDate
# >> ./start_finishing.sh $startDate

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
source ${BASE_CTRLDIR}/envs/env_finishing
cd ${BASE_CTRLDIR}

###############################################################################
# finishing
###############################################################################
formattedStartDate=$(date -u -d "${startDate}" ${dateString})
SimresDir=${BASE_SIMRESDIR}/${formattedStartDate}

echo "--- gzip and sha512sum individual files in simresdir"
cd ${SimresDir}/cosmo/ml
wrap_calc_sha512sum ${FIN_NTASKS} ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/cosmo/ml/*
wait
cd ${SimresDir}/cosmo/pl
wrap_calc_sha512sum ${FIN_NTASKS} ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/cosmo/pl/*
wait
cd ${SimresDir}/cosmo/sfc
wrap_calc_sha512sum ${FIN_NTASKS} ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/cosmo/sfc/*
wait
cd ${SimresDir}/cosmo/zl
wrap_calc_sha512sum ${FIN_NTASKS} ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/cosmo/zl/*
wait
cd ${SimresDir}/parflow
wrap_calc_sha512sum ${FIN_NTASKS} ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/parflow/*
wait
cd ${SimresDir}/clm
wrap_calc_sha512sum ${FIN_NTASKS} ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/clm/*
wait
cd ${SimresDir}/restarts/clm
wrap_calc_sha512sum 1 ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/restarts/clm/*
wait
cd ${SimresDir}/restarts/cosmo
wrap_calc_sha512sum 1 ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/restarts/cosmo/*
wait
cd ${SimresDir}/restarts/parflow
wrap_calc_sha512sum 1 ./*
parallelGzip ${FIN_NTASKS} ${SimresDir}/restarts/parflow/*
wait
cd ${SimresDir}/log
wrap_calc_sha512sum 1 ./*
wait

exit 0

