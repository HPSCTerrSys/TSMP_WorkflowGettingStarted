# DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline 

# Getting started
First clone this repository (**Setup**) to you project-directory:
``` bash
cd $PROJECT_DIR
git clone --recurse-submodules https://icg4geo.icg.kfa-juelich.de/Configurations/TSMP/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline.git
```

Than prepare the **ModelSystem** (TSMP), located under `src` directory:
``` bash
cd $BASE_ROOT/src/TSMP
export TSMP_DIR=$(pwd)
# Get TSMP component models (COSMO, ParFlow, CLM, Oasis)
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/cosmo5.01_fresh.git cosmo5_1
git clone -b v3.12.0 https://github.com/parflow/parflow.git parflow
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/clm3.5_fresh.git clm3_5
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/oasis3-mct.git oasis3-mct
```
Compile TSMP
``` bash
cd $TSMP_DIR/bldsva
./build_tsmp.ksh --readclm=true -v 3.1.0MCT -c clm-cos-pfl -m JURECA -O Intel
```

Finally you need to adjust `export_paths.ksh` in the `ctrl` directory:
``` bash
cd $BASE_ROOT/ctrl
vi export_paths.ksh
```
Within this file change the line `rootdir="/p/scratch/cjibg35/tsmpforecast/development/${expid}"` 
according to you `$PROJECT_DIR` from above. To verify `rootdir` is set properly 
do `source $BASE_ROOT/ctrl/export_paths.ksh && echo "$rootdir" && ls -l $rootdir`. You should see the following content:
``` console
PATH/TO/YOUR/PROJECT
ctrl
doc
forcing
geo
monitoring
postpro
README.md
rundir
simres
src
```

Now the setup is complete, and can be run after providing proper forcing and restart files. 
To start a simulation simply execute `starter.sh` from `ctrl`-directory:
``` bash
cd $BASE_ROOT/ctrl
# adjust according to you need between l10 and l31
vi ./starter.sh 
# start the simulation
./starter.sh 
```
