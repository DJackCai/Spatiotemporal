library(raster)
library(ncdf4)

###
day_path1 = "/g/data/lr26/H8_LST_ANU/2019/12/30/"

# day_path1 = "./"

# list all files in full name so that the directory can be found 
LST_raster_files1 = list.files(path = day_path1, 
                               pattern = "*ANU_LSTv1.2_AusSubset.tif",
                               full.names = T)

strsplit(LST_raster_files1[1], "/")
# one example raster 
r1 = raster(LST_raster_files1[1])

LST_daily_brick = brick(as.list(LST_raster_files1))

# rename the raster layers
names(LST_daily_brick)

LST_fns = sapply(as.list(LST_raster_files1), function(x) {
  tail(strsplit(x, "/")[[1]], 1) } ) 

output_dir = "/g/data/dt1/H8_LST_ANU/"
writeRaster(LST_daily_brick, paste0(output_dir, "20191230_Daily_AUS.tiff") )
