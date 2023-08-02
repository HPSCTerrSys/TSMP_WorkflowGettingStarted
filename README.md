# DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline 

> :warning: **Warning**  
> The current version / tag of this repository is < v1.0.0 and is therefore 
> still under testing, so use it with caution.

## Set up the TSMP_WorkflowStarter

**First**, clone this repository into your project-directory with its 
dependencies provided as git submodules, 

``` bash
cd $PROJECT_DIR
git clone --recurse-submodules https://gitlab.jsc.fz-juelich.de/detect/detect_z03_z04/setups_configurations/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline.git
```

and export the following path to an environment variable for later use.

``` bash
cd DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline
export BASE_ROOT=$(pwd)
```

**Second**, get TSMP ready by cloning all component models (COSMO, ParFlow, 
CLM, and Oasis) into `src/TSMP/`, 

``` bash
cd ${BASE_ROOT}/src/TSMP
export TSMP_DIR=$(pwd)
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/cosmo5.01_fresh.git  cosmo5_1
git clone -b UseMaskNc https://github.com/HPSCTerrSys/parflow.git                       parflow
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/clm3.5_fresh.git     clm3_5
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/oasis3-mct.git       oasis3-mct
```

It is crucial that a specific experiment that is based on various modularly
combined git repositories uses a very specific commit (and branch) of the
respective repositories. Even if the current head of a repository is at the
time of built what we want, the parent repo might change and to rebuilt the
same binary, the exact commits of each used repository need to be known. A
commit may then also coincide with a tag.

As it is not possible to clone a specific commit, do this:

```bash
cd ${BASE_ROOT}/src/TSMP/parflow
git checkout UseMaskNc # is already cloned, but do this nevertheless
git reset --hard 1eb4c447 # with latest commits code does not run
```

With UseMaskNc and commits `1eb4c447c68c547217e18c4d2a2b00866b641bd3`,
`5f0d24d8bcee4b4300494f07d92d7f6d563a86ef` ParFlow does not run.

Todo: Specify commits or tags of all repos to be used and list respective 
commands here.

Build the binaries (uses software stage 2023):.

``` bash
cd $TSMP_DIR/bldsva
./build_tsmp.ksh --readclm=true --maxpft=4 -c clm3-cos5-pfl -m JURECA -O Intel
```

Check the built logs under `$TSMP_DIR/bin/JURECA_clm3-cos5-pfl` for errors.

**Third**, install `int2lm` which is needed to prepare the COSMO forcing needed 
during the actual simulation. `int2lm` is provided as a submodule and can be 
found in `src/int2lm3.00/`.    
To build `int2lm` change to its directory and prepare the `Fopts` and `loadenv` 
file. You find predefined files in `LOCAL`, which you can simply link to the 
int2lm-rootdir:                                              
```
cd ${BASE_ROOT}/src/int2lm3.00/                                                     
ln -sf LOCAL/JUWELS_Fopts ./Fopts && ln -sf LOCAL/JUWELS_Stage2020_loadenv ./loadenv
```
Note: `Fopts` and `loadenv` are generic enough to work on both `JUWELS` and 
`JURECA`, so stick with them on both machines for now.    

After preparation, source the environment, clean up the installation directory, 
and compile the source:                                                                    
```                                                                             
cd ${BASE_ROOT}/src/int2lm3.00/                                                      
source loadenv                                                                  
make clean                                                                      
make                                                                            
```                                                                             
When no error is thrown, a binary called `int2lm3.00` is created.

**Next**, customise your personal information in `ctrl/SimInfo.sh`. The lines 
you need to adjust are   
`AUTHOR_NAME=`  
`AUTHOR_MAIL=`  
`AUTHOR_INSTITUTE=`  
This information will be used to add to simulation results and to send SLURM 
notifications.

``` bash
cd $BASE_ROOT/ctrl
vi SimInfo.sh
```

**Finally**, adapt `ctrl/export_paths.sh` to correctly determine the root 
directory of this workflow:

``` bash
cd $BASE_ROOT/ctrl
vi export_paths.sh
```

Within this file change the line   
`rootdir="/ADD/YOUR/ROOT/DIR/${expid}"`   
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

The setup is now complete, and can be run after providing proper restart and 
forcing files. 

## Get the external parameter or static files

(from a previous pre-processing)

The static or external parameter files are in a Git LFS repo, which is included 
as a submodule. It is possible that only pointer files are cloned. If there are 
no files under `static/` you get the actual files by ``cd`` into the submodule 
repo and download the actual files:

```bash
cd $BASE_ROOT/geo/TSMP_EUR-11
git lfs pull
```

## Provide restart files

(from a previous (spin-up) model run)

To continue a simulation, restart-files are needed to define the initial 
state of the simulation. Since large simulations (simulation period of years / 
several decades), such as we are aiming for, are usually calculated as a 
sequence of shorter simulations (simulation period of days / months), each 
simulation represents a restart of the previous simulation. Therefore, restart 
files must be provided for each component model and simulation.

Within this workflow, the component models expect the individual restart files 
to be located at:

```
$BASE_ROOT/rundir/MainRun/restarts/{clm,cosmo,parflow}
``` 

(these directories need are best created manually)

Note: See `ctrl/CASES.conf`; replace "MainRun" in this README.md with 
"Productionv1". During SOP clearly desitibuishable tests had to be done to 
ensure the integrity of the system.

During the normal course of this workflow, the restart files are automatically 
placed there. Only for the very first simulation the user has to provide 
restart files manually to initialise the simulation. Therefore it is important 
to know that COSMO is able to run without restart files, then its running a 
cold-start, while CLM and ParFlow always expect restart-files. So the user 
only needs to provide restart-files for ParFlow and CLM only.

In this production run, we run / start a simulation over the EUR-11 domain for 
the year 1979, for which restart files must copied from (observe checksums):

```
/p/largedata2/detectdata/projects/Z04/SPINUP_TSMP_EUR-11/restarts/clm
/p/largedata2/detectdata/projects/Z04/SPINUP_TSMP_EUR-11/restarts/parflow
``` 

Highly important: TSMP in this setup and configuration has been run from 1970 to 
1979 three times to spinup the sub-surface; hence these restart files need to be
used; these restart runs were done with the static fields and ERA5 boundary 
conditions; COSMO needs to cold-start as 1979 is the official spinup year of 
CORDEX and the atmosphere has only a short-term memory as opposed to the 
sub-surface.
1979-01-01_00:00:00
COSMO: cold-start
CLM: restart
ParFlow: restart

Due to the importance of the restart files they are also kept in

```
$BASE_ROOT/rundir/MainRun/restarts/restarts_SPINUP03_197812
```

(For completeness also a COSMO restart file is stored. Not provided from Z04 
but NWa.)

If needed, do request access to the related data project (=``detectdata``) via 
[JuDoor](https://judoor.fz-juelich.de/login).

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

## Provide forcing files for the atmosphere

We use caf-files from the CLM-Community as a basis to generate 

```
${BASE_ROOT}/forcing
ln -sf /p/largedata2/detectdata/CentralDB/era5/ ./cafFilesIn
```
**TBE**

## Start a simulation

To start a simulation simply execute `starter.sh` from `ctrl` directory:

The default simulation environment needs to be in line with the environment
during compilation.
`$BASE_DIR/ctrl/envs/env_simulation` needs to be the same as 
`$BASE_DIR/src/TSMP/bldsva/machines/loadenvs.Intel`


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

The COSMO cold-start or restart is simply triggered by the `starter.sh` 
`startDate` and `initDate`.

## Exercice
To become a little bit famillar with this workflow, work on the following tasks:

1) Do simulate the compleat year of 2020.
2) Plot a time serie of the spatial averaged 2m temperature for 2020.
3) Write down which information / data / files you might think are needed to 
   repoduce the simulation.
4) Think about how you could check the simulation is running fine during 
   runtime.

## Further documentation
Please find further and more general information about the workflow [here](https://niklaswr.github.io/TSMP_WorkflowStarter/content/introduction.html)

## Known issues
- `$BASE_ROOT/geo/TSMP_EUR-11/static/int2lm/EUR-11_TSMP_FZJ-IBG3_464x452_EXTPAR.nc` 
contains GLOBCOVER2009 land cover data; rhe experiment uses GLC2000; if boundary
conditions are generated with `int2lm`for COSMO, then this LULC dataset is used; 
albeit CLM uses GLC2000; but in case a COSMO-only simulation is to be done, this
needs to be observed. In that case a new extpar file needs to be generated for 
COSMO.
- Note `$BASE_ROOT` and `$TSMP_DIR` are just used in this README.md, they are not
needed for any part of the workflow later on.
- CLM runs at the beginning with fixed CO2 concentrations. Later we activateA 
transient CO2 being passed form COSMO to CLM.
- HeAT is still not used from its github repo but from local JSC install, neded in
th postprocessing and therein the ParFlow Diagnostics.
- Runtime optimisation is pending.
- ...
