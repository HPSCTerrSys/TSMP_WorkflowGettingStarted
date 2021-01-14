[[_TOC_]]
# Welcome to the Wiki of `era5climat_eur-11_ecmwf-era5_analysis_fzj-ibg3`

This repository is containing (or pointing to) everything needed for a climate simulation based on TSMP. To keep everything most flexible a modular approach is aimed, with currently three modules distinguished:

1. Workflow (this project)
2. ModelSystem (TMSP)
3. ModelSetup (individual)

All modules together forming the final climate simulation setup.

# Getting started
First clone this repository (**Workflow**) to you project-directory:
``` bash
cd $PROJECT_DIR
git clone https://icg4geo.icg.kfa-juelich.de/ModelSystems/tsmp_scripts_tools_engines/era5climat_eur-11_ecmwf-era5_analysis_fzj-ibg3.git
```
and export the new path to an environment variable for later use:
``` bash
cd $PROJECT_DIR/era5climat_eur-11_ecmwf-era5_analysis_fzj-ibg3
export BASE_ROOT=$(pwd)
```
Than clone the **ModelSystem** [TSMP](https://www.terrsysmp.org/) to the `src` directory:
``` bash
cd $BASE_ROOT/src
git clone https://github.com/HPSCTerrSys/TSMP.git
```
Next get the **ModelSetup** and place at the right subdirectory in `run_TSMP`:
``` bash
cd $BASE_ROOT/run_TSMP/sim_output_heter_geology_improved_with_pfl_sink/
git clone https://icg4geo.icg.kfa-juelich.de/Configurations/TSMP/tsmp_era5clima_template.git
```

Finally you need to adjust `export_paths.ksh` in the `ctrl` directory:
``` bash
cd $BASE_ROOT/ctrl
vi export_paths.ksh
```
Within this file change the line `rootdir="/p/scratch/cjibg35/tsmpforecast/${expid}"` according to you `$PROJECT_DIR` from above. To verify `rootdir` is set properly do `cd $rootdir`. You should see the following content:
``` console
ctrl
forcing
postpro
README
run_INT2LM
run_TSMP
simres
src
```

Now the setup is complete, but to run a simulation proper forcing- and restart-files are needed.

Link the provided forcing sample to the proper subdirectory in `run_TSMP`:
``` bash
cd $BASE_ROOT/run_TSMP/laf_lbfd_int2lm_juwels2019a_ouput/all
ln -sf NEED/TO/ADD/PATH ./
```

Copy provided restart-files to the proper subdirectory in `run_TSMP`: 
``` bash
cd $BASE_ROOT/run_TSMP/sim_output_heter_geology_improved_with_pfl_sink/restarts
cp -r NEED/TO/ADD/PATH/* ./
```
To start a simulation simply submit `starter.sh` from `ctrl`-directory:
``` bash
cd $BASE_ROOT/ctrl
sbatch --export=ALL,startDate=YYYYMMDD,months=X,CTRLDIR=$(pwd) starter.sh 
```