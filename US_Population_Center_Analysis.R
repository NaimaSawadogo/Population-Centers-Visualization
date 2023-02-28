#Reading in the dataframes for 2010 and 2020
Center.2010 <- read.csv("https://www2.census.gov/geo/docs/reference/cenpop2010/CenPop2010_Mean_ST.txt", header = TRUE)
Center.2020 <- read.csv("https://www2.census.gov/geo/docs/reference/cenpop2020/CenPop2020_Mean_ST.txt", header = TRUE)

#Adding a year column to distinguish between the two datasets
Center.2010$YEAR <- "2010"
Center.2020$YEAR <- "2020"

#Combining the two dataframes
both_years <- rbind(Center.2010, Center.2020)

#Plotting the population centers on a map
library(ggmap)
qmplot(LONGITUDE, LATITUDE, data = both_years, maptype = "toner-lite", color = YEAR)

#Using the httr library to get the links for each county population center
library(httr)

#Creating the link components
linkstart <- "https://www2.census.gov/geo/docs/reference/cenpop2020/county/CenPop2020_Mean_CO"
linkmiddle <- sprintf("%02d", 1:56)
linkend <- ".txt"

#Combining the link components to get all of the links
allinks <- purrr::map(linkmiddle, ~ paste0(linkstart, .x, linkend))

#Creating a loop to iterate through the links and combine the dataframes
combined_data <- data.frame()

for (link in allinks) {
  #Handling any exceptions with the tryCatch function
  tryCatch({
    data <- read.csv(link)
    combined_data <- rbind(combined_data, data)
  }, error = function(e) {
    #If there is a "cannot open the connection" error, print a message and continue iterating
    if (grepl("cannot open the connection", e$message)) {
      message(paste0("Error: could not open connection to link ", link, ". Skipping..."))
    } else {
      #For any other type of error, stop iterating and print the error message
      stop(e)
    }
  })
}

#Plotting the population centers on a map
library(ggmap)
plot <- qmplot(LONGITUDE, LATITUDE, data = combined_data, maptype = "toner-lite", size = I(.25))
plot
