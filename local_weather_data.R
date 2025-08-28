

#For the creation of the .Renviron file
# install.packages("usethis")  # once
# usethis::edit_r_environ()    # opens/creates your user .Renviron

key <- Sys.getenv("OPENWEATHER_API_KEY")
key
# should print your key (not empty)

install.packages("jsonlite")  # once
library(jsonlite)

# city <- "Belmopan,bz"  # name,country-code
# url  <- paste0(
#   "https://api.openweathermap.org/data/2.5/weather",
#   "?q=", city,
#   "&units=imperial",
#   "&appid=", key
# )
# 
# 
# j <- fromJSON(url)   # open the box (JSON → R list)
# 
# # make a tiny table
# one_row <- data.frame(
#   city = j$name,
#   temp = j$main$temp,
#   lon  = j$coord$lon,
#   lat  = j$coord$lat
# )
# 
# one_row

library(jsonlite)

key <- Sys.getenv("OPENWEATHER_API_KEY")   # or "paste-your-key"

cities <- c("Belmopan,bz", "Belize City,bz", "San Ignacio,bz")

get_one <- function(city, units = "metric") {
  url <- paste0(
    "https://api.openweathermap.org/data/2.5/weather",
    "?q=", URLencode(city),
    "&units=", units,
    "&appid=", key
  )
  j <- fromJSON(url)  # JSON → list
  data.frame(
    city = j$name,
    temp = j$main$temp,
    lon  = j$coord$lon,
    lat  = j$coord$lat
  )
}

# run for all cities and stack rows
all_weather <- do.call(rbind, lapply(cities, get_one))
all_weather




#Simplest plot(bar chart)
barplot(
  all_weather$temp,
  names.arg = all_weather$city,
  col = "dodgerblue",
  border = "white",
  ylim = c(0,max(all_weather$temp, na.rm = TRUE) +2),
  ylab = "°C",
  main = "Current Temperature"
)


all_weather$temp <- as.numeric(all_weather$temp)
summary(all_weather$temp)



#Print png
png("weather_plot.png", width=800, height=600)
barplot(
  all_weather$temp,
  names.arg = all_weather$city,
  ylab = "°C",
  main = "Current Temperature"
)
dev.off()

#Simplest map
install.packages("leaflet")  # once
library(leaflet)

leaflet(all_weather) |>
  addTiles() |>
  addCircleMarkers(
    lng = ~lon, lat = ~lat,
    color = ifelse(all_weather$hot, "red", "blue"),
    radius = 6,
    label = ~paste(city, "—", temp, "°C")
  )

#create csv

dir.create("data", showWarnings = FALSE)
write.csv(all_weather, "data/weather_now.csv", row.names = FALSE)


