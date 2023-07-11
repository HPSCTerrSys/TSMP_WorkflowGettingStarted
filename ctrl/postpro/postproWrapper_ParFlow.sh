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
# ParFlow
##############################################################################
timemeasure_startDate=$(date -u -Iseconds)
echo "--- -- - pfl"
echo "DEBUG: Create PFL subdir within ToPostPro"
mkdir -vp ${ToPostProDir}/parflow_out
#echo "DEBUG: link raw model output to ToPostPro"
#ln -sf ${SimresDir}/parflow/* ${ToPostProDir}/parflow_out/

# .pfb -> .nc
# add correct grid
echo "DEBUG: convert .pfb files to .nc and add grid information"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/${pfidb}.out.n.pfb \
  --varname n \
  --outfile ${ToPostProDir}/parflow_out/n.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/n.nc_tmp" \
 "${ToPostProDir}/parflow_out/n.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.alpha.pfb \
  --varname alpha \
  --outfile ${ToPostProDir}/parflow_out/alpha.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/alpha.nc_tmp" \
 "${ToPostProDir}/parflow_out/alpha.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.mask.pfb \
  --varname mask \
  --outfile ${ToPostProDir}/parflow_out/mask.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/mask.nc_tmp" \
 "${ToPostProDir}/parflow_out/mask.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.sres.pfb \
  --varname sres \
  --outfile ${ToPostProDir}/parflow_out/sres.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/sres.nc_tmp" \
 "${ToPostProDir}/parflow_out/sres.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.ssat.pfb \
  --varname ssat \
  --outfile ${ToPostProDir}/parflow_out/ssat.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/ssat.nc_tmp" \
 "${ToPostProDir}/parflow_out/ssat.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.perm_x.pfb \
  --varname perm_x \
  --outfile ${ToPostProDir}/parflow_out/perm_x.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/perm_x.nc_tmp" \
 "${ToPostProDir}/parflow_out/perm_x.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.perm_y.pfb \
  --varname perm_y \
  --outfile ${ToPostProDir}/parflow_out/perm_y.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/perm_y.nc_tmp" \
 "${ToPostProDir}/parflow_out/perm_y.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.perm_z.pfb \
  --varname perm_z \
  --outfile ${ToPostProDir}/parflow_out/perm_z.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/perm_z.nc_tmp" \
 "${ToPostProDir}/parflow_out/perm_z.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.porosity.pfb \
  --varname porosity \
  --outfile ${ToPostProDir}/parflow_out/porosity.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
 "${ToPostProDir}/parflow_out/porosity.nc_tmp" \
 "${ToPostProDir}/parflow_out/porosity.nc"
python ${SLOTHDIR}/tmp/Pfb2NetCDF.py \
  --infiles ${SimresDir}/parflow/*.out.specific_storage.pfb \
  --varname specific_storage \
  --outfile ${ToPostProDir}/parflow_out/specific_storage.nc_tmp 
cdo -L -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
  "${ToPostProDir}/parflow_out/specific_storage.nc_tmp" \
  "${ToPostProDir}/parflow_out/specific_storage.nc"
echo ""
echo "time measure after converting .pfb->.nc"
datediff $(date -u -Iseconds) ${timemeasure_startDate}
timemeasure_startDate=$(date -u -Iseconds)

# Add time info (refdate and calendar) to ParFlow output, split for 
# individual variables and merge for one file per simulation length.
# Therefore loop over all files in simres/ and write output to ToPostPro/
pflFiles=$(ls ${SimresDir}/parflow/${pfidb}.out.?????.nc)
bash ${BASE_CTRLDIR}/postpro/addTimeInfoAnsSplitVar.sh ${startDate} \
  ${CaseCalendar} "${ToPostProDir}/parflow_out" ${SLURM_NTASKS} \
  "${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
  ${pflFiles}
echo "time measure after addTimeInfoAnsSplitVar.sh"
datediff $(date -u -Iseconds) ${timemeasure_startDate}
timemeasure_startDate=$(date -u -Iseconds)

# merge raw parflow output into one file of length `simLength`?
echo "DEBUG: start merging ParFlow output"
cdo -L -f nc4c -z zip_4 mergetime "${ToPostProDir}/parflow_out/${pfidb}.out.?????_evaptrans.nc_tmp" \
  "${ToPostProDir}/parflow_out/evaptrans.nc" &
cdo -L -f nc4c -z zip_4 mergetime "${ToPostProDir}/parflow_out/${pfidb}.out.?????_pressure.nc_tmp" \
  "${ToPostProDir}/parflow_out/pressure.nc" &
cdo -L -f nc4c -z zip_4 mergetime "${ToPostProDir}/parflow_out/${pfidb}.out.?????_saturation.nc_tmp" \
  "${ToPostProDir}/parflow_out/saturation.nc" &
wait
echo "time measure after mergetime"
datediff $(date -u -Iseconds) ${timemeasure_startDate}
timemeasure_startDate=$(date -u -Iseconds)

# extract static vars from *.out.00000.nc
cdo -L -f nc4c -z zip_4 \
  -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
  -selvar,slopex "${SimresDir}/parflow/${pfidb}.out.00000.nc" \
  "${ToPostProDir}/parflow_out/slopex.nc"
cdo -L -f nc4c -z zip_4 \
  -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
  -selvar,slopey "${SimresDir}/parflow/${pfidb}.out.00000.nc" \
  "${ToPostProDir}/parflow_out/slopey.nc"
cdo -L -f nc4c -z zip_4 \
  -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
  -selvar,mannings "${SimresDir}/parflow/${pfidb}.out.00000.nc" \
  "${ToPostProDir}/parflow_out/mannings.nc"
cdo -L -f nc4c -z zip_4 \
  -setgrid,"${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
  -selvar,DZ_Multiplier "${SimresDir}/parflow/${pfidb}.out.00000.nc" \
  "${ToPostProDir}/parflow_out/DZ_Multiplier.nc"
echo "time measure after extract static vars from *.out.00000.nc"
datediff $(date -u -Iseconds) ${timemeasure_startDate}
timemeasure_startDate=$(date -u -Iseconds)
# calc water vars
python calcParFlowDiagnosticVars.py \
  --pressure "${ToPostProDir}/parflow_out/pressure.nc" \
  --pressureVarName "pressure" \
  --nFile "${ToPostProDir}/parflow_out/n.nc" \
  --alphaFile "${ToPostProDir}/parflow_out/alpha.nc" \
  --sresFile "${ToPostProDir}/parflow_out/sres.nc" \
  --ssatFile "${ToPostProDir}/parflow_out/ssat.nc" \
  --maskFile "${ToPostProDir}/parflow_out/mask.nc" \
  --permXFile "${ToPostProDir}/parflow_out/perm_x.nc" \
  --permYFile "${ToPostProDir}/parflow_out/perm_y.nc" \
  --permZFile "${ToPostProDir}/parflow_out/perm_z.nc" \
  --porosityFile "${ToPostProDir}/parflow_out/porosity.nc" \
  --specificStorageFile "${ToPostProDir}/parflow_out/specific_storage.nc" \
  --slopexFile "${ToPostProDir}/parflow_out/slopex.nc" \
  --slopeyFile "${ToPostProDir}/parflow_out/slopey.nc" \
  --manningsFile "${ToPostProDir}/parflow_out/mannings.nc" \
  --dzMultFile "${ToPostProDir}/parflow_out/DZ_Multiplier.nc" \
  --dz 2 --dy 12500 --dx 12500 --dt 0.25 \
  --outDir "${ToPostProDir}/parflow_out" \
  --griddesFile "${BASE_GEODIR}/grids/EUR-11_TSMP_FZJ-IBG3_CLMPFLDomain_444x432_griddes.txt" \
  --LLSMFile "${BASE_GEODIR}/land-lake-sea-mask/EUR-11_TSMP_FZJ-IBG3_444x432_LAND-LAKE-SEA-MASK.nc" \
  --outPrepandName ""
  #--outPrepandName "${pfidb}"
echo "time measure after calcParFlowDiagnosticVars.py"
datediff $(date -u -Iseconds) ${timemeasure_startDate}
timemeasure_startDate=$(date -u -Iseconds)
    
find ${ToPostProDir} -name "*_tmp" -type f -delete

# Copy ToPostPro to postpro dir (and clean before)
rm -rv ${PostProStoreDir}/parflow
mkdir -pv ${PostProStoreDir}/parflow
cp -v ${ToPostProDir}/parflow_out/* ${PostProStoreDir}/parflow
# CMOR
exit 0
