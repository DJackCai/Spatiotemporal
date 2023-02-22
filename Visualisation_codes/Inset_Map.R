  ### Shapefile plotting: southeast Australia  #########
  
    ### Shapefile plotting: southeast Australia  #########

statebord = shapefile("StateBoundaries.shp")
SEAbound = statebord[c(4,5,8),]

    ## add a factor to the shapefile data indicating SEA ####

SEA_names = c("New South Wales", "Victoria", "Australian Capital Territory")
     
statebord@data = statebord@data %>% 
                  mutate(id = rownames(.)) %>%
                  mutate(SEA = as.factor(ifelse(NAME %in% SEA_names, "Yes","No")))

# create a data frame for the spatial polygon feature 

statebord_df = broom::tidy(statebord, region = "id")  

 ## join the shp data to the attribute data ####

statebord_join = statebord_df %>% 
                 left_join(statebord@data, by = c('id' = 'id'))


   # bord_f = fortify(statebord, region = "OBJECTID")
 
 ### Create map, with southeast Australia being the coloured site 

ggplot() + geom_polygon(data = statebord_join, aes(x = long, y = lat, 
                        group = group, fill =  SEA), col = "black") +
        # set colour for each factor level 
        scale_fill_manual(values = c("white", "red")) +
        theme_void()  + theme (legend.position = "none") # no need for lat/lon


