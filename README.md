# DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline 

**This is the experiment leaflet for the simulation experiment with the 
experiment-ID as in the heading.**

## Context

- Baseline simulation of the DETECT D02 project (S. Kollet)
- Contribution to CORDEX-CMIP6 climate change RCM ensemble through CLM-Community

## Experiment version and status

- Version: see tags (`git tag -n`)
- Status: production runs ongoing, CASE-ID: "ProductionV1"
- Experiment `$rootdir`: `/p/scratch/cjjsc39/goergen1/sim/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline`
- Simulation progress: see `$rootdir/simres/`, `$rootdir` as in `ctrl/export_paths.ksh`

> Background and concept:
> A "simulation experiment" is identified by an experiment-ID. Such a 
> "simulation experiment" consists of modular components. The components are 
> themselves git repositories; they may also be integrated as git submodules.
> A specific combination of the modular components is combined with each other 
> in a single git repository constituting the "experiment repository". This 
> repository is characterized by its commits and major releases are assigned 
> a git tag, i.e. its a specific release of an experiment. Aside from the git
> commits of the indivual model system components, the [CHANGELOG](./CHANGELOG) 
> of the experiment shows the major steps of the evolution of the experiment. 
> Once running stable an experiment usually does not change anymore. Smaller 
> adjustments are still possible and are reflected by patches or minor version 
> changes (semantic versioning scheme). Some components are interchangeable 
> between different experiments (e.g., static fields), others are not.

## Components used

The simulation experiment v1.0.1 consists of these components:  
- TSMP_Workflow-Engine, https://icg4geo.icg.kfa-juelich.de/Configurations/TSMP/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline.git, c01884b (v1.0.1), master, 2023-08-06
  - static fields (`geo/`), https://gitlab.jsc.fz-juelich.de/detect/detect_z03_z04/constant_fields/TSMP_EUR-11.git, 5fbc818, master, 2023-06-22
  - namelists (`ctrl/namelists`), https://icg4geo.icg.kfa-juelich.de/Configurations/TSMP_namelists/TSMP_EUR-11_eval.git, 703d8b7, master, 2023-08-02
  - int2lm (`src/int2lm3.00`), https://gitlab.jsc.fz-juelich.de/detect/detect_z03_z04/software_tools/tools_mirrors/int2lm3.00.git, 4ba1598, master, 2023-02-17
  - SLOTH (`src/SLOTH`), https://github.com/HPSCTerrSys/SLOTH.git, 9d7ee2b, master, 2023-07-12
    - ParFlow Diagnostics (`src/SLOTH/extern/ParFlowDiagnostics`), https://github.com/HPSCTerrSys/ParFlowDiagnostics.git, af0a2c8, master, 2022-03-29
    - colormaps (`src/SLOTH/extern/colormaps`), https://github.com/pratiman-91, ce4320c, 2023-02-15
  - TSMP (`src/TSMP`), https://github.com/HPSCTerrSys/TSMP.git, dad9a4c4 (v1.4.0), 2023-04-26
    - COSMO (`src/TSMP/cosmo5_1`), https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/cosmo5.01_fresh.git, f407b9b, master, 2020-01-21
    - CLM (`src/TSMP/clm3_5`), https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_src/clm3.5_fresh.git, 801b530, master, 2020-01-21
    - ParFlow (`src/TSMP/parflow`), https://github.com/HPSCTerrSys/parflow.git, 1eb4c44, UseMaskNc, 2023-05-31 (will become part of the main ParFlow repo https://github.com/parflow)

Each experiment is put together by starting off with the TSMP_Workflow-Engine, see below.

https://gitlab.jsc.fz-juelich.de/detect repos are are mirrors of 
https://icg4geo.icg.kfa-juelich.de

These components might be automatically cloned as they are configred as git 
submodules (see `git submodule status`), when cloning a git submodule always 
the latest HEAD is pulled. Hence it might be needed to set the HEAD to a 
specific commit to reproduce the exact simulation experiment.

Follow the setup instructions below to obtain these repos. But make sure you 
have the correct commit and branch checked out. For example do a:

```bash
git log --oneline -1
```

to see which commit you are dealing with.

To set the HEAD to a specific commit in the commit history:

```bash
git reset --hard 1eb4c447
```

or do a 

```bach
git clone -n <repo_name> 
git checkout <commit_sha>
```

(See here on how to revover from a ['Deteched HEAD' state](https://circleci.com/blog/git-detached-head-state/?utm_source=google&utm_medium=sem&utm_campaign=sem-google-dg--emea-en-dsa-tROAS-auth-nb&utm_term=g_-_c__dsa_&utm_content=&gclid=CjwKCAjwt52mBhB5EiwA05YKowS4Lli89cXh6W4sT_CTlGJH1rdKN8JX7QSSHG-zZmK5v36JSldJohoCgGkQAvD_BwE))

Fixes and improvements in the respective repos might be ingested in different 
ways (see additional documentation link below), and might lead to release
changes (as documented in the CHANGELOG and with the `HISTORY.txt` file with
each simulation. In case of a major change the use CASE might change, e.g.,
from "ProductionV1" to "ProductionV2" make this obvious. If a major change is 
needed, it might lead also to a complete new experiment.

## Setup

- ERA5.1 atmospheric forcing (via caf files form CLM-Community at DKRZ)
- One-way single nest dynamical downscaling 
- EUR-11 (pan European, about 12km) model domain
- TSMPv1 model system 
- 1979-2023 simulation timespan, 1979 counts as spinup
- x3 1970-1979 spinup beforehand, see seperate infomration by NWagner
- JURECA-DC CPU
- stage2023
- cjjsc39 compute + jjsc39 data projects
- 1979/01 start of main experiment (COSMO coldstart), CLM+ParFLow: restart from 
SPINUP03
 
## Configuration

- RCP4.5 GHGs (observed)
- Tanre constant aerosols
- GLC2000 static land cover
- Soil grids and IHME hydrogeology
- Especially the COSMO configuration is by and large (a) compliant to the 
CLM-Community reference version for COSMO v5 from the COPAT1 initiative, (b) the
namelists used in CORDEX-CMIP5 downscaling with COSMO only, (c) previous TSMPv1 
runsi, (d) DETECT requiremnets, (e) new CORDEX-CMIP6 variable lists.

For details, see namelists: https://icg4geo.icg.kfa-juelich.de/Configurations/TSMP_namelists/TSMP_EUR-11_eval

## Implementation and checks

in CASES "MainRun" and "ProductionTest" (see ./ctrl/CASES.conf ./ctrl/CASES.conf
- Takeover experiment and TSMP_Workflow-Engine from NWagner on 2023-07-28 with commit 0265916a (master), 
- Check functionality of Workflow-Engine, adjustment to new use case
- Refinements and fixes
- Exact reproduction after implementation of test and developer simulations by NWagner (checking 1979/01), forcing files, simulation results, postprocessing, monitoring, logfiles; restarts work properly, also in 1979/01
- Check of setup and configuration once more: check of compatibility with and suitability for DETECT and CORDEX; check of correct static fields (land cover, indicator file, ParFlow slopes); various cross checks (static input equals static output)

## Related experiments

exp-ID:
- https://icg4geo.icg.kfa-juelich.de/Configurations/TSMP/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaselineHwu

## Responsibilities

- Current owner: k.goergen@fz-juelich.de
- Current Simulations and monitoring: k.goergen@fz-juelich.de
- Current implementation: k.goergen@fz-juelich.de
- Development of experiment: n.wagner@fz-juelich.de, c.hartick@fz-juelich.de, 
  s.poll@fz-juelich.de, k.goergen@fz-juelich.de, s.kollet@fz-juelich.de 

## Known and open issues

There are some things to be observed, however they do not prevent going to
production mode.

- CLM runs at the beginning with fixed CO2 concentrations. Later we activate a 
  transient CO2 being passed form COSMO to CLM.
- HeAT is still not used from its github repo but from local JSC install, neded in
  th postprocessing and therein the ParFlow Diagnostics.
- Reduction of output frequency with ParFlow from 15min to 60min
- Reduction of COSMO variables, zl variables might be calculated from ml
- In portprocessing 3D CLM soil temperature is missing still
- COSMO might be set to run at sec with I/O -> allows for sub-hourly outputs
- COSMO some addons to the vartab file will allow more variables to be output 
  (not needed immediately), e.g., durting standaline run (FR_SNOW), or at 3km 
  (QG with different microphysics scheme)
- Runtime optimisation in fully coupled mode (ParFlow seems to slow down), 
  towards 1 SYPD -- if possible at all, without MSA
- SW-corner excess rainfall
- Get SSP transient CO2 forcing in to COSMO v5.01 (`src_radiation.f90`)
- No seaice setting in COSMO (COPAT2 with C2C316=False as well)
- Aerosol treatment is not in line with EURO-CORDEX CMIP6 EUR-11 protocol

## Notes

- `$BASE_ROOT/geo/TSMP_EUR-11/static/int2lm/EUR-11_TSMP_FZJ-IBG3_464x452_EXTPAR.nc` 
contains GLOBCOVER2009 land cover data; the experiment uses GLC2000; if boundary
conditions are generated with `int2lm`for COSMO, then this LULC dataset is used; 
albeit CLM uses GLC2000; but in case a COSMO-only simulation is to be done, this
needs to be observed. In that case a new extpar file needs to be generated for 
COSMO.
- Note `$BASE_ROOT` and `$TSMP_DIR` are just used in this README.md, they are not
needed for any part of the workflow later on.
- Parflow shows in layer 0 saturation < 1 at 1979-01-01_00
- `subSurfStor_ts_*` in `monitoring/` does not contain timeseries from SPINUP03
- Postprocessing: time-vector is missing in CLM output
- Postprocessing: pCMORizer.f90 not yet activated
- ParFlow had to be set back by 2 commits to prevent runtime error (`ifdef readclm`)

## Runtime behaviour

See `starter.sh` for resource allocation.

Preprocessing
- About 25min wallclock time

Simulation
- Between 3.5h and 5.5h wall clock time

Postprocessing
- After 30min ParFlow and CLM are done, even with very high resolution ParFlow output
- **1:25 is needed for ProductionV1 1979/01** COSMO needs most
- 5.5GB, 35 files, CLM
- 73GB, 118 files, ParFlow
- 67GB, 182 files, COSMO

Monitoring
- Use `gpicview` to check monitoring png files on HPC front nodes.

Finalisation
- 
- Reduces about 450GB to about 200GB per month.

## Set up the TSMP_Workflow-Engine

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
$BASE_ROOT/rundir/ProductionV1/restarts/{clm,cosmo,parflow}
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
$BASE_ROOT/rundir/ProductionV1/restarts/restarts_SPINUP03_197812
```

(For completeness also a COSMO restart file is stored. Not provided from Z04 
but NWa.)

If needed, do request access to the related data project (=``detectdata``) via 
[JuDoor](https://judoor.fz-juelich.de/login).

To make the restart files available, go to the restart directory, and copy the 
restart files there:

``` bash
cd $BASE_ROOT/rundir/ProductioonV1/restarts
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

## Archiving of simulation results

After postprocessing and finalization (gzip) this is done manually:

```bash
cd ctrl/
bash ./aux_MigrateFromScratch.sh /p/largedata/jjsc39/goergen1/sim/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline/simres/ProductionV1/ /p/scratch/cjjsc39/goergen1/sim/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline/simres/ProductionV1/19790[1,2]*
```

Any filename matching pattern can be used; granularity of the tar-balls: about 
200GB / month. All stored data are in a single tar-ball.

Store initially not on archive (tape) but on largedata.

## Further documentation
Please find further and more general information about the TSMP Workflow-Engine 
in [the doc/ directory](https://icg4geo.icg.kfa-juelich.de/Configurations/TSMP/DETECT_EUR-11_ECMWF-ERA5_evaluation_r1i1p1_FZJ-COSMO5-01-CLM3-5-0-ParFlow3-12-0_vBaseline/-/tree/master/doc/content) and a [rendered version is here](https://niklaswr.github.io/TSMP_WorkflowStarter/content/introduction.html), might be outdated due to rendering date and time.

## Exercise
To become a little bit familiar with the TSMP Workflow-Engine before and actual
run, work on the following tasks:

1) Do simulate the complete year of 2020.
2) Plot a time series of the spatial averaged 2m temperature for 2020.
3) Write down which information / data / files you might think are needed to 
   repoduce the simulation.
4) Think about how you could check the simulation is running fine during 
   runtime.
