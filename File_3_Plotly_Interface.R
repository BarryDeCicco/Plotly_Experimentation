# File 3:  'File_3_Plotly_Interface.r'
# 1.1.2 The plot_ly() interface


# Although data frames are not required, using them is 
# highly recommended, especially when constructing a plot 
# with multiple layers or groups.

# When a data frame is associated with a plotly object, 
# it allows us to manipulate the data underlying that object 
# in the same way we would directly manipulate the data. 
# Currently, plot_ly() borrows semantics from and provides 
# special plotly methods for generic functions in the dplyr 
# and tidyr packages (Wickham and Francois 2016); 
# (Wickham 2016). 
# Most importantly, plot_ly() recognizes and preserves groupings
# created with dplyr’s group_by() function.

#library(dplyr) already loaded.

tx <- group_by(txhousing, city)

# initiate a plotly object with date on x and median on y
p <- plot_ly(tx, x = ~date, y = ~median)

# plotly_data() returns data associated with a plotly object
plotly_data(p)

p

# Similar to geom_line() in ggplot2, the add_lines() function
# connects (a group of) x/y pairs with lines in the order 
# of their x values, which is useful when plotting time series
# as shown in Figure 1.2.

# add a line highlighting houston

add_lines(
  # plots one line per city since p knows city is a 
  # grouping variable
  add_lines(p, alpha = 0.2, name = "Texan Cities", 
            overinfo = "none"),
  name = "Houston", 
  data = filter(txhousing, city == "Houston")
)

