# Getting Started 

## Set up the TSMP_WorkflowGettingStarted

**First**, clone this repository into your project-directory with its 
dependencies marked with Git submodules, 

``` bash
cd $PROJECT_DIR
git clone --recurse-submodules https://github.com/HPSCTerrSys/TSMP_WorkflowGettingStarted.git
```

and export the following path to an environment variable for later use.

``` bash
cd $PROJECT_DIR/TSMP_WorkflowGettingStarted
export BASE_ROOT=$(pwd)
```

**Second**, get TSMP ready by cloning all component models (COSMO, ParFlow, 
CLM, and Oasis) into `src/TSMP/`, 

``` bash
cd ${BASE_ROOT}/src/TSMP
export TSMP_DIR=$(pwd)
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/cosmo5.01_fresh.git  cosmo5_1
git clone -b UseMaskNc https://github.com/HPSCTerrSys/parflow.git                             parflow
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/clm3.5_fresh.git     clm3_5
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/oasis3-mct.git       oasis3-mct
```

and build the binaries.

``` bash
cd $TSMP_DIR/bldsva
./build_tsmp.ksh --readclm=true --maxpft=4 -c clm3-cos5-pfl -m JURECA -O Intel
```

**Finally**, adapt `ctrl/export_paths.ksh` to correctly determine the root 
directory of this workflow and `SimInfo.sh` to set the correct author dates:

``` bash
cd $BASE_ROOT/ctrl
vi export_paths.ksh
vi SimInfo.sh
```

Within `export_paths.ksh` change the line   
`rootdir="/PATH/TO/YOUR/EXPDIR/${expid}"`   
according to you `$PROJECT_DIR` from above. To verify `rootdir` is set properly 
do   
`source $BASE_ROOT/ctrl/export_paths.ksh && echo "$rootdir" && ls -l $rootdir`.    
You should see the following content:

```
PATH/TO/YOUR/PROJECT
ctrl/
doc/
forcing/
geo/
LICENSE
monitoring/
postpro/
README.md
rundir/
simres/
src/
```

Within `SimInfo.sh` change the lines `export AUTHOR_NAME="AUTHOR NAME"`, 
`export AUTHOR_MAIL="AUTHOR EMAIL"`, and `export AUTHOR_INSTITUTE="INSTITUTE"`. 
Those infromation are used to be loged and saved with the simulation results and
the email is used to send `SLURM` notifications.

The setup is now complete, and can be run after providing proper restart and 
forcing files. 

## Provide restart files

To continue a simulation, restart-files are needed to define the initial 
state of the simulation. Since large simulations (simulation period of years / 
several decades), such as we are aiming for, are usually calculated as a 
sequence of shorter simulations (simulation period of days / months), each 
simulation represents a restart of the previous simulation. Therefore, restart 
files must be provided for each component and simulation.

Within this workflow, the component models expect the individual restart files 
to be located at:

```bash
$BASE_ROOT/rundir/MainRun/restarts/COMPONENT_MODEL
``` 

During the normal course of this workflow, the restart files are automatically 
placed there. Only for the very first simulation the user has to provide 
restart files manually to initialise the simulation. Therefore it is important 
to know that COSMO is able to run without restart files, than running a 
cold-start, while CLM and ParFlow always expect restart-files. So the user 
only needs to provide restart-files for ParFlow and CLM only.

In this example, we do run a simulation over the EUR-11 domain for the year 
1979, for which restart files could be taken from:

```
/p/largedata2/detectdata/projects/Z04/SPINUP_TSMP_EUR-11/restarts
``` 

If needed, do request access to the related data project via [JuDoor](https://judoor.fz-juelich.de/login).

To make the restart files available, go to the restart directory, and copy the 
restart files there:

``` bash
cd $BASE_ROOT/rundir/MainRun/restarts
# copy CLM restart file
cp -r /p/largedata2/detectdata/projects/Z04/SPINUP_TSMP_EUR-11/restarts/clm ./
# copy ParFlow restart file
cp -r /p/largedata2/detectdata/projects/Z04/SPINUP_TSMP_EUR-11/restarts/parflow ./
```
**NOTE**: 
ParFlow needs the previous model-outpt as a restart-file, whereas CLM needs a 
special restart-file from the current time-step. This is why the date within 
the file name is different.

## Provide forcing (boundary) files

COSMO is a local model, simulating only a subdomain of the globe, and therefore 
needs to be informed about incoming meteorological conditions passing the 
boundary (as e.g. low pressure systems). This is done using local boundary 
files (lbf for short). At the same time, the status quo of the atmosphere is 
needed for the first time step (not to be confused with restart files!). In 
the meteorological domain this status quo is called ‘analysis’, wherefore this 
information is passed to COSMO with so called ‘local analysis files’  (laf for 
short).

These two types of boundary files must to be provided for each simulation and 
are expected by the workflow under:

``` bash 
$BASE_ROOT/forcing/laf_lbfd/all
```

In the pre-processing step of this workflow the `laf_lbfd` files are generated
by `INT2LM` automatically wherefore on has to provide the raw meterological data
only, which are provided under:
```
/p/largedata2/detectdata/CentralDB/era5/
```
and have to be linked to 
```
${BASE_ROOT}/forcing
```
to be found by the workflow.   
If needed, do request access to the data project via [JuDoor](https://judoor.fz-juelich.de/login).

To properly provide these files, do link the directory from above to your 
workflow under `forcing/`
``` bash
# move to forcing dir and link forcing files
cd ${BASE_ROOT}/forcing
ln -sf /p/largedata2/detectdata/CentralDB/era5/ ./cafFilesIn
```

## Start a simulation

To start a simulation simply execute `starter.sh` from `ctrl` directory:

``` bash
cd $BASE_ROOT/ctrl
# adjust according to you need between 
# 'Adjust according to your need BELOW'
# and
# 'Adjust according to your need ABOVE'
vi ./starter.sh 
# start the simulation
./starter.sh 
```

## Exercice
To become a little bit famillar with this workflow, work on the following tasks:

1) Do simulate the compleat year of 1979.
2) Plot a time serie of the spatial averaged 2m temperature for 1979.
3) Write down which information / data / files you might think are needed to 
   repoduce the simulation.
4) Think about how you could check the simulation is running fine during 
   runtime.

