#-------------------------------------------------------------------------------
# load packages

requiredpackages <- c('maps', 'mapdata', 'tidyverse', 'sf', 'rvest', 'viridis', 'ggrepel', 'ggthemes')

install_load <- function(packages){
  for (p in packages) {
    if (p %in% rownames(installed.packages())) {
      library(p, character.only=TRUE)
    } else {
      install.packages(p)
      library(p,character.only = TRUE)
    }
  }
}

install_load(requiredpackages)


gitpath <- 'https://github.com/sureshlazaruspaul/ihds/raw/main/maps/india-admin-maps/'

#-------------------------------------------------------------------------------
# read shape files

shp0 <-  read_sf('C:\\ihds\\maps\\IND_adm\\IND_adm0.shp')
shp1 <-  read_sf('C:\\ihds\\maps\\IND_adm\\IND_adm1.shp')
shp2 <-  read_sf('C:\\ihds\\maps\\IND_adm\\IND_adm2.shp')
shp3 <-  read_sf('C:\\ihds\\maps\\IND_adm\\IND_adm3.shp')


shp1 <- shp1%>%
  dplyr::mutate(NAME_1 = if_else(NAME_1 == 'Uttaranchal'
                                 , 'Uttarakhand'   
                                 , NAME_1))


#-------------------------------------------------------------------------------
# country level map

india_map <- shp0 %>%
  ggplot() +
  geom_sf(
    fill = "lightblue", 
    color = "black"
    ) +
  ggthemes::theme_map() +
  labs(title = "India country map"); # india_map


#-------------------------------------------------------------------------------
# state-level map

viridis_color_options <- c('magma', 'inferno', 'plasma', 'viridis', 
                           'cividis', 'rocket', 'mako', 'turbo')

# Fill each state in different colour ----
india_map_states <- 
  shp1 %>%
  ggplot() +
  geom_sf(aes(fill  = NAME_1)) +
  ggthemes::theme_map() +
  theme(legend.position = "none") + 
  labs(title = "India States map") +
  scale_fill_viridis_d(option=viridis_color_options[6]); # india_map_states

#-------------------------------------------------------------------------------
# fill each state based on the your own data
#-------------------------------------------------------------------------------
# state order
#-------------------------------------------------------------------------------
# [1]  "Andaman and Nicobar"    "Andhra Pradesh"         "Arunachal Pradesh"      
# [4]  "Assam"                  "Bihar"                  "Chandigarh"             
# [7]  "Chhattisgarh"           "Dadra and Nagar Haveli" "Daman and Diu"          
# [10] "Delhi"                  "Goa"                    "Gujarat"               
# [13] "Haryana"                "Himachal Pradesh"       "Jammu and Kashmir"      
# [16] "Jharkhand"              "Karnataka"              "Kerala"                 
# [19] "Lakshadweep"            "Madhya Pradesh"         "Maharashtra"            
# [22] "Manipur"                "Meghalaya"              "Mizoram"               
# [25] "Nagaland"               "Orissa"                 "Puducherry"             
# [28] "Punjab"                 "Rajasthan"              "Sikkim"                 
# [31] "Tamil Nadu"             "Telangana"              "Tripura"                
# [34] "Uttar Pradesh"          "Uttarakhand"            "West Bengal"           
#-------------------------------------------------------------------------------

# add electricity info:

shp1$elec_access_perc <- c(7261
                , 1810000
                , 31282
                , 459000
                , 717000
                , 61110
                , 987000
                , NA
                , NA
                , NA
                , NA
                , NA
                , NA
                , NA
                , NA
                , NA
                , 2770000
                , 2730000
                , NA
                , 788000
                , 5910000
                , 59852
                , 41906
                , 15364
                , 23644
                , 852000
                , 113000
                , 588000
                , 950000
                , 18414
                , 2350000
                , 603000
                , 59321
                , 1700000
                , 337000
                , 1460000
)

options(scipen = 999)

india_map_states1 <- 
  shp1 %>% 
  ggplot() +
  geom_sf(
    aes(
      fill  = elec_access_perc
    ), 
    alpha = 0.2, 
    show.legend = FALSE
  ) +  
  ggthemes::theme_map() +
  labs(
    title = "India Choropleth map\nshowing sales in each state"
  ) +
  scale_fill_gradient(
    low='blue', 
    high='red',
    na.value = 'white'
  ) + 
  geom_sf_text(
    data = shp1[which(shp1$elec_access_perc > 0),],
    aes(
      label = paste(
        NAME_1, '\n', 
        paste0(round(elec_access_perc, digits = 1), '%')
      )
    ), 
    size = 2, 
    color = "black"
  ); india_map_states1

