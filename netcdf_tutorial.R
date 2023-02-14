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
# 
# FALSE     TRUE 
# 7715670 10883679 

# Number of temperature values on Australian continent is 7715670 

##### 2.2. Get single "time slice" of data in R dataframe #######


tair_slice = tair_array[, , 1]
dim(tair_slice) # 4651 * 3999 data grid 

# view data range for colouring

summary(c(tair_slice), na.rm = T)  # 5-37 degrees 


###### levelplot -  ggplot-like visualisation of one map #########

tair_slice[is.na(tair_slice) == F]  # non-missing data 

tair_grid = expand.grid(x = tair_lon, y = tair_lat ) 
tair_df_0000 = data.frame(cbind(tair_grid, tair = as.vector(tair_slice)))

cutpts = seq(0,40,5); cuts = 11

col_ramp_discrete = rev(brewer.pal(10, "Spectral"))

# plot by variable name, so that locations and value are matched
levelplot(tair ~ x * y, data = tair_df_0000, at = cutpts , cuts = 11,
          col.regions = col_ramp_discrete)

# 3. Compute summary statistics of maximum and minimum temperature ######

tair_brick = brick(tair_name)
class(tair_dailymax)

# calc can apply a function for all layers in a RasterBrick object. The end result is a raster layer.
tair_dailymax = calc(tair_brick, max)

class(tair_dailymax)

col_ramp_cts = colorRampPalette(col_ramp_discrete)  # create interpolated ramp 

# plot raster is much quicker
plot(tair_dailymax, col = col_ramp_cts(255))        # ...(255) to set up the continous colour ramp!




