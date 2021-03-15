# File 4:  'File_4_Layer_Functions.r'.

# The plotly package has a collection of add_*() functions, 
# all of which inherit attributes defined in plot_ly(). 
# These functions also inherit the data associated with the 
# plotly object provided as input, unless otherwise specified 
# with the data argument. I prefer to think about add_*() 
# functions like a layer in ggplot2, which is slightly different,
# but related to a plotly.js trace. In Figure 1.2, there is 
# a 1-to-1 correspondence between layers and traces, 
# but add_*() functions do generate numerous traces 
# whenever mapping a discrete variable to a visual aesthetic 
# (e.g., color). In this case, since each call to 
# add_lines() generates a single trace, it makes sense to 
# name the trace, so a sensible legend entry is created.

# In the first layer of Figure 1.2, there is one line per city, 
# but all these lines belong a single trace. We could have 
# produced one trace for each line, but this is way more 
# computationally expensive because, among other things, 
# each trace produces a legend entry and tries to display 
# meaningful hover information. It is much more efficient to 
# render this layer as a single trace with missing values 
# to differentiate groups. In fact, this is exactly how 
# the group aesthetic is translated in ggplotly(); 
# otherwise, layers with many groups (e.g., geom_map()) 
# would be slow to render.

# 1.1.2.2 The data-plot-pipeline
# Since every plotly function modifies a plotly object 
# (or the data underlying that object), we can express 
# complex multi-layer plots as a sequence (or, more 
# specifically, a directed acyclic graph) of data 
# manipulations and mappings to the visual space. 
# Moreover, plotly functions are designed to take a 
# plotly object as input, and return a modified plotly object, 
# making it easy to chain together operations via the 
# pipe operator (%>%) from the magrittr package 
# (Bache and Wickham 2014). Consequently, we can 
# re-express Figure 1.2 in a much more readable and 
# understandable fashion.

allCities <- txhousing %>%
  group_by(city) %>%
  plot_ly(x = ~date, y = ~median) %>%
  add_lines(alpha = 0.2, name = "Texan Cities", 
            hoverinfo = "none")

allCities

allCities %>%
  filter(city == "Dallas") %>%
  add_lines(name = "Dallas")

allCities %>%
  filter(city == "Houston") %>%
  add_lines(name = "Houston")

# The problem is that each of these steps on other
# cities selected

# The way to deal with this is the add_fun() command,
# which will not step on previous command results:

allCities %>%
  add_fun(function(plot) {
    plot %>% filter(city == "Houston") %>% add_lines(name = "Houston")
  }) %>%
  add_fun(function(plot) {
    plot %>% filter(city == "San Antonio") %>% 
      add_lines(name = "San Antonio")
  }) %>%

add_fun(function(plot) {
  plot %>% filter(city == "Dallas") %>% 
    add_lines(name = "Dallas")
})


# It is useful to think of the function supplied to add_fun() 
# as a “layer” function – a function that accepts a 
# plot object as input, possibly applies a transformation 
# to the data, and maps that data to visual objects. 
# To make layering functions more modular, flexible, 
# and expressive, the add_fun() allows you to pass 
# additional arguments to a layer function. 
# Figure 1.4 makes use of this pattern, by creating a 
# reusable function for layering both a particular city 
# as well as the first, second, and third quartile of 
# median monthly house sales (by city):


# reusable function for highlighting a particular city

layer_city <- function(plot, name) {
  plot %>% filter(city == name) %>% add_lines(name = name)
}


# note that 'median' is calculated by the plotly function;
# everything pulling from that is based on the median by date,
# by city.

# reusable function for plotting overall median & IQR
layer_iqr <- function(plot) {
  plot %>%
    group_by(date) %>% 
    summarise(
     q1 = quantile(median, 0.25, na.rm = TRUE),
      m = median(median, na.rm = TRUE),
    q3 = quantile(median, 0.75, na.rm = TRUE)
    ) %>%
    add_lines(y = ~m, name = "median", color = I("black"))  %>%
  add_ribbons(ymin = ~q1, ymax = ~q3, name = "IQR", color = I("black"))
}

# Barry's attempt at a reusable function for plotting 
# overall mean
layer_mean <- function(plot) {
  plot %>%
    group_by(date) %>% 
    summarise(
      avg = mean(median, na.rm = TRUE)
    ) %>%
    add_lines(y = ~avg, name = "mean", color = I("green"))
}


allCities %>%
  add_fun(layer_iqr) %>%
  add_fun(layer_city, "Houston") %>%
  add_fun(layer_city, "San Antonio")  %>%
  add_fun(layer_mean)

# A layering function does not have to be a data-plot-pipeline
# itself. Its only requirement on a layering function is 
# that the first argument is a plot object and it returns a 
# plot object. This provides an opportunity to say, 
# fit a model to the plot data, extract the model components 
# you desire, and map those components to visuals. 
# Furthermore, since plotly’s add_*() functions don’t 
# require a data.frame, you can supply those components 
# directly to attributes (as long as they are well-defined), 
# as done in Figure 1.5 via the forecast package 
# (Hyndman, n.d.):

library(forecast)


layer_forecast <- function(plot) {
  d <- plotly_data(plot)
  series <- with(d, 
                 ts(median, frequency = 12, start = c(2000, 1), end = c(2015, 7))
  )
  fore <- forecast(ets(series), h = 48, level = c(80, 95))
  plot %>%
    add_ribbons(x = time(fore$mean), ymin = fore$lower[, 2],
                ymax = fore$upper[, 2], color = I("gray95"), 
                name = "95% confidence", inherit = FALSE) %>%
    add_ribbons(x = time(fore$mean), ymin = fore$lower[, 1],
                ymax = fore$upper[, 1], color = I("gray80"), 
                name = "80% confidence", inherit = FALSE) %>%
    add_lines(x = time(fore$mean), y = fore$mean, color = I("blue"), 
              name = "prediction")
}

txhousing %>%
  group_by(city) %>%
  plot_ly(x = ~date, y = ~median) %>%
  add_lines(alpha = 0.2, name = "Texan Cities", hoverinfo = "none") %>%
  add_fun(layer_iqr) %>%
  add_fun(layer_forecast)


