### Script for netcdf4 package tutorial #####
# Here I use the interpolated Tair grids for example 

# https://pjbartlein.github.io/REarthSysSci/netCDF.html 

library(ncdf4)
library(raster)
library(RColorBrewer)

# 1. Read the ncdf file  ###########

target_date = "20191114"
# file name
tair_name = paste0("tair_hourly_", target_date, "_aus_1km_3577.nc")

##### 1.1 open dataset to see basic information ##########
tair_o = nc_open(tair_name)

print(tair_o)

##### 1.2 Get to understand different variables ###########

# spatial dimension 
tair_lon = ncvar_get(tair_o, "x")
tair_lat = ncvar_get(tair_o, "y")
print(c(dim(tair_lon), dim(tair_lat)))  # 4651 * 3999


head(tair_lon) ; head(tair_lat)

# time step
tair_time = ncvar_get(tair_o, "time")
ntime = dim(tair_time)   # 24 hours

# Get attribute of time units to when it started 
tair_tunits = ncatt_get(tair_o, "time", "units")

# > tair_tunits
# $hasatt  # whether the variable has this attribute
# [1] TRUE
# 
# $value
# [1] "hours since 2019-11-14 00:00:00"


# Get the measurement/target variable
tair_array = ncvar_get(tair_o, varid = "Tair")
# Get the scale factor attribute
tair_scalefac = ncatt_get(tair_o, varid = "Tair", attname = "scale_factor")

# Get global attribute

tair_units = ncatt_get(tair_o, 0, "units")

# 2. Reshape from raster to rectangular ########

##### 2.1 replace missing value with NA #########

# get fill value from the attribute 
fillvalue = ncatt_get(tair_o, "Tair", "_FillValue")$value
tair_array[tair_array == fillvalue] == NA

table(is.na(tair_array[, , 1]))  # view number of missing values in one raster slice

# > table(is.na(tair_array[, , 1]))
# FALSE     TRUE 
# 7715670 10883679 

# Number of temperature values on Australian continent is 10883679 

##### 2.2. Get single "time slice" of data in R dataframe #######

tair_slice = tair_array[, , 1]
dim(tair_slice) # 4651 * 3999 data grid 

# view data range for colouring

summary(c(tair_slice), na.rm = T)  # 5-37 degrees 


###### 2.3. Visualisation of raster data by levelplot #########
###### Data frame driven: ggplot-like visualisation of one map 

tair_grid = expand.grid(x = tair_lon, y = tair_lat ) 
tair_df_0000 = data.frame(cbind(tair_grid, tair = as.vector(tair_slice)))

cutpts = seq(0,40,5); cuts = 11

col_ramp_discrete = rev(brewer.pal(10, "Spectral"))  # cuts = 11, 10 classes in total 

# plot by variable name, so that locations and value are matched
levelplot(tair ~ x * y, data = tair_df_0000, at = cutpts , cuts = 11,
          col.regions = col_ramp_discrete)

# 3. Compute summary statistics of maximum and minimum temperature ######

# Load netcdf name to RasterBrick 
tair_brick = brick(tair_name)
class(tair_dailymax)

# calc can apply a function for all layers in a RasterBrick object. 
# The end result is a raster layer.
tair_dailymax = calc(tair_brick, max)

class(tair_dailymax)

# create interpolated colour ramp template
col_ramp_cts = colorRampPalette(col_ramp_discrete)  

# plot raster - quicker than specifying x-y coordinates in data frame
plot(tair_dailymax, col = col_ramp_cts(255))        # ...(255) to set up the continous colour ramp!


##### 3.2 Reshape the raster brick into array ##########

# use the as.data.frame functionality in raster package
# must specify xy=T to get the coordinates 
tair_dailymax_df = raster::as.data.frame(tair_dailymax, xy = T)

tair_dailymax_mat = raster::as.matrix(tair_dailymax)

# IMPORTANT: matrix for putting in values: rows being x, cols being y 
tair_dailymax_mat_val = as.array(t(tair_dailymax_mat))

# 4. Write the maximum temperature raster to netcdf file #######

tair_brick
crs(tair_brick) = "EPSG:3577"  # specify the coordinate reference system 

ncpath = "./"
ncname = paste0(target_date, "_daily_maxtemp.nc")
nc_fn = paste0(ncpath, ncname)

dname = "tmp"

##### 4.1 Define dimensions and variables in the file ########

lon_seq = tair_lon   
lat_seq = tair_lat
time_steps = 1 

# define dimensions using specific dimension value 

londim = ncdim_def("x", "easting", as.double(lon_seq))
latdim = ncdim_def("y", "northing", as.double(lat_seq))
timedim = ncdim_def("time", "hours", as.double(time_steps))

# define variable:  
# dimension needs to be the "ncdim4" class objects

fillvalue = 1e10 
dlname = "tair_daily_maximum"          # optional long name

tair_dailymax_def = ncvar_def(name = "dailymax", units = "°C", 
                              dim = list(londim, latdim) , missval = fillvalue, 
                              longname = dlname, prec = "single")

##### 4.2 Create netCDF files and put in the data #####

ncout_maxtemp = nc_create(filename = nc_fn, vars = list(tair_dailymax_def), force_v4 = T)

# write into the variable 
ncvar_put(nc = ncout_maxtemp, varid = tair_dailymax_def, vals = tair_dailymax_mat_val)

# write into additional attribute for dimension and variable 
# Variable name needs to match e.g. "y" as defined previously 
ncatt_put(nc = ncout_maxtemp, varid = "x", attname = "axis", attval = "X")
ncatt_put(nc = ncout_maxtemp,varid = "y", attname = "axis", attval = "Y")
# ncatt_put(ncout_maxtemp,"time","axis","T")

# add global attributes

ncatt_put(ncout_maxtemp, 0, "title", "Maximum air temperature data on 20191114 at 1km all Oz")
ncatt_put(ncout_maxtemp, 0, "institution", "CSIRO")

# close the file 
nc_close(ncout_maxtemp)


##### 4.3 check whether the data has been created correctly #######

maxtemp_o = nc_open("20191114_daily_maxtemp.nc")
maxtemp_brick = brick("20191114_daily_maxtemp.nc")

plot(maxtemp_brick,  col = col_ramp_cts(255))  # confirm that it's correct 


