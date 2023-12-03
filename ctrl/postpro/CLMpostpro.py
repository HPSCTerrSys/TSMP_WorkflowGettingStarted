import numpy as np
import netCDF4 as nc
import glob
import argparse
import sys
import datetime as dt
import sloth.IO
import os

parser = argparse.ArgumentParser(description='Tell me what this script can do!.')
parser.add_argument('--variables', '-v', nargs='+', type=str, required=True,
                    help='variable to process (have to fit model convention')
parser.add_argument('--indir', '-i', type=str, required=True,
                    help='absolut path to directory holding Model output')
parser.add_argument('--outdir', '-o', type=str, required=True,
                    help='absolut path to directory output should be placed')
parser.add_argument('--gridDes', '-t', type=str, required=True,
                    help='absolut path to griddes file needed to create new netCDF')
parser.add_argument('--NBOUNDCUT', '-nc', type=int, default=6,
                    help='number of pixels to cut of at each side to fit other grids (related to COSMO)')
args = parser.parse_args()

VARs          = args.variables
inDir         = args.indir
outDir        = args.outdir
gridDes       = args.gridDes
NBOUNDCUT     = args.NBOUNDCUT 

# Get environment variables
author_name      = os.getenv('AUTHOR_NAME')
author_mail      = os.getenv('AUTHOR_MAIL')
author_institute = os.getenv('AUTHOR_INSTITUTE')

################################################################################
# Read in all CLM output
################################################################################
tmp_vars = {VAR:{'data':None, 'att':''} for VAR in VARs}
allowedDims = ['time', 'hist_interval', 'lat', 'lon']
inFiles = sorted(glob.glob(f'{inDir}/*.h0.*.nc'))
for inFile in inFiles:
    with nc.Dataset(inFile, 'r') as nc_file:
        for name, variable in nc_file.variables.items():
            # Check that we process variables passed to this program only.
            # Check that we process with allowed dimension only.
            tmp_check = all(dim in allowedDims for dim in nc_file[name].dimensions)
            #print(f'DEBUG: name {name} -- tmp_check {tmp_check}')
            if (name in VARs) and (tmp_check):
                #print(f'name: {name}')
                #print(f'nc_file[name][...]: {nc_file[name][...]}')
                #print(f'nc_file[name].__dict__: {nc_file[name].__dict__}')
                if not tmp_vars[name]['data'] is None:
                    tmp_vars[name]['data'] = np.append(tmp_vars[name]['data'], nc_file[name][...], axis=0)
                    tmp_vars[name]['att'] = nc_file[name].__dict__
                else:
                    tmp_vars[name]['data'] = nc_file[name][...]
                    tmp_vars[name]['att'] = nc_file[name].__dict__

################################################################################
# Write out CLM output in one files per variables.
# And do some manipulation needed.
################################################################################
for name in VARs:
    try:
        print(f'DEBUG: name {name}')
        # skip time and time_bounds variables, as thsoe get special handling
        # and are added to each variable.
        if name in ['time', 'time_bounds']:
            continue

        # manipulating variable attributes
        # keeping below in would lead to:
        # RuntimeError: NetCDF: Can't open HDF5 attribute
        # seems that '_FillValues' is related to old netcdflib
        #print(f'DEBUG: tmp_vars[name]["att"] {tmp_vars[name]["att"]}')
        del(tmp_vars[name]["att"]['_FillValue'])
        # add projection information
        tmp_vars[name]["att"]['grid_mapping'] = 'rotated_pole'
        tmp_vars[name]["att"]['coordinates'] = 'lon lat'
        # notic that 'cell_methods' is correct (accoring to NCO) but CLM stores 
        # the attribute 'cell_method' which is renamed here (to fit NCO)
        # 'correct' cell_methods which is named cell_method in CLM output
        tmp_vars[name]["att"]['cell_methods'] = tmp_vars[name]["att"]['cell_method']
        del(tmp_vars[name]["att"]['cell_method'])


        netCDFFileName = sloth.IO.createNetCDF(f'{outDir}/{name}.nc', domain=gridDes,
                author=author_name, contact=author_mail,
                institution=author_institute, calcLatLon=True,
                history=f'Created: {dt.datetime.now().strftime("%Y-%m-%d %H:%M")}')
        with nc.Dataset(netCDFFileName, 'r+') as dst:
            a = dst.createVariable('time','f8',('time'))
            if 'time_bounds' in tmp_vars:
                tmp_time = np.nanmean(tmp_vars['time_bounds']['data'][...], axis=1)
                dst['time'][...] = tmp_time[...]
                dst['time'].setncatts(tmp_vars['time']['att'])
            
            #x = dst.createVariable('time_orig','f8',('time'))
            #dst['time_orig'][...] = tmp_vars['time']['data'][...]
            #dst['time_orig'].setncatts(tmp_vars['time']['att'])
            
            if 'time_bounds' in tmp_vars:
                bnds = dst.createDimension('bnds',2)
                y = dst.createVariable('time_bounds','f8',('time', 'bnds'))
                dst['time_bounds'][...] = tmp_vars['time_bounds']['data'][...]
                dst['time_bounds'].setncatts(tmp_vars['time_bounds']['att'])

            z = dst.createVariable(name,'f4',('time','rlat','rlon'), zlib=True)
            dst[name][...] = tmp_vars[name]['data'][...]
            dst[name].setncatts(tmp_vars[name]['att'])
    except Exception as e:
        print(f'WARNING: could not handle VAR {name}')
        print(f'{e}')
        continue

