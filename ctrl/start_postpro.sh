#!/bin/bash

#SBATCH --job-name="ERA5_postpro"
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=02:00:00
#SBATCH --partition=devel
#SBATCH --mail-type=NONE
#SBATCH --account=jibg35

# author: Niklas Wagner
# e-mail: n.wagner@fz-juelich.de
# last modified: 2020-12-11
# USAGE: 

# IMPORTANT
# CTRLDIR and startDate HAVE TO be set via sbatch --export command 
echo "--- source environment"
source $CTRLDIR/export_paths.ksh
source ${BASE_CTRLDIR}/start_helper.sh
source ${BASE_CTRLDIR}/postpro/loadenvs

###############################################################################
# Prepare
###############################################################################
h0=$(TZ=UTC date '+%H' -d "$startDate")
d0=$(TZ=UTC date '+%d' -d "$startDate")
m0=$(TZ=UTC date '+%m' -d "$startDate")
y0=$(TZ=UTC date '+%Y' -d "$startDate")

# echo for logfile
echo "###################################################"
echo "START Logging ($(date)):"
echo "###################################################"
echo "--- exe: $0"
echo "--- Simulation start-date: ${startDate}"
echo "--- HOST:  $(hostname)"

###############################################################################
# Post-Pro
###############################################################################

# Place post-processing steps here
# NOTE: scripts HAVE to run on compute-nodes.
# If the script runs in parralel or on single cpu is not important

#---------------insert here initial, start and final dates of TSMP simulations----------
initDate="19800101" #DO NOT TOUCH! start of the whole TSMP simulation
WORK_DIR="${BASE_RUNDIR_TSMP}"
WORK_FOLDER="sim_output_heter_geology_improved_with_pfl_sink"
template_FOLDER="tsmp_era5clima_template"
expID="TSMP_3.1.0MCT_cordex11_${y0}_${m0}"
rundir=${WORK_DIR}/${WORK_FOLDER}/${expID}

# Create individual subdir in ToPostPro to copy model-output
# there. I want to seperate modeloutput first, to be 100%
# sure modelputput is not changed by post-pro scripts (cdo, nco)
mkdir -p ${WORK_DIR}/${WORK_FOLDER}/ToPostPro/${y0}_${m0}/cosmo_out
mkdir -p ${WORK_DIR}/${WORK_FOLDER}/ToPostPro/${y0}_${m0}/parflow_out
mkdir -p ${WORK_DIR}/${WORK_FOLDER}/ToPostPro/${y0}_${m0}/clm_out

# copy model-output to ToPostPro subdir
cp ${rundir}/cosmo_out/* ${WORK_DIR}/${WORK_FOLDER}/ToPostPro/${y0}_${m0}/cosmo_out/
cp ${rundir}/cordex0.11_${y0}_${m0}.out.*.pfb ${WORK_DIR}/${WORK_FOLDER}/ToPostPro/${y0}_${m0}/parflow_out/
cp ${rundir}/clmoas.clm2.h0.${y0}-${m0}*.nc ${WORK_DIR}/${WORK_FOLDER}/ToPostPro/${y0}_${m0}/clm_out/

cd ${BASE_CTRLDIR}
postpro_initDate=$(date '+%Y%m%d%H' -d "${initDate}")
postpro_startDate=$(date '+%Y%m%d%H' -d "${startDate}")
postpro_YYYY_MM=$(date '+%Y_%m' -d "${startDate}")
./postproWraper.sh $postpro_initDate $postpro_startDate $postpro_YYYY_MM
if [[ $? != 0 ]] ; then exit 1 ; fi

echo "-- deleting ToPostPro/${y0}_${m0}"
rm -r ${WORK_DIR}/${WORK_FOLDER}/ToPostPro/${y0}_${m0}

echo "-- taring postpro/${y0}_${m0}"
cd ${BASE_POSTPRODIR}
tar -cf "${y0}_${m0}.tar" ${y0}_${m0} 

echo "-- deleting postpro/${y0}_${m0}"
rm -r ${BASE_POSTPRODIR}/${y0}_${m0}

exit 0