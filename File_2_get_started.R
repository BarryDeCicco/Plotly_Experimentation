# File 2:  'File_2_get_started.r'

# There are two ways to start a plotly object:

# 1. plot_ly()  takes data, and makes a plotly object.

# 2. ggplotly() transforms a ggplot object into a plotly object.

txhousing
class(txhousing)
names(txhousing)
str(txhousing)


# Create a ggplot object, drawing lines through the median
# price by date, grouping by city:

p <- ggplot(txhousing, aes(date, median)) +
  geom_line(aes(group = city), alpha = 0.2)

p

length(unique(txhousing$city)) # how many cities? - 46.

# raw version

ggplotly(p, tooltip="city")

# adding some extra intermediate objects
# (especially useful when the geom is not 
# using the identity function).

subplot(
  p, ggplotly(p, tooltip = "city"), 
  ggplot(txhousing, aes(date, median)) + geom_bin2d(),
  ggplot(txhousing, aes(date, median)) + geom_hex(),
  nrows = 2, shareX = TRUE, shareY = TRUE,
  titleY = FALSE, titleX = FALSE
)


# The ggplotly() function translates most things that you 
# can do in ggplot2, but not quite everything. 
# To help demonstrate the coverage, I’ve built a plotly 
# version of the ggplot2 docs
# (http://ropensci.github.io/plotly/ggplot2). 
# This version of the docs 
# displays the ggplotly() version of each plot in a 
# static form (to reduce page loading time), 
# but you can click any plot to view its interactive version. 
# The next section demonstrates how to create plotly.js 
# visualizations via the R package, without ggplot2, 
# ia the plot_ly() function. We’ll then leverage those 
# concepts to extend ggplotly().



