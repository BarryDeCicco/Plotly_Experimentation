# file 5:  'File_5_extending_ggplotly.r'

### 1.2 Extending ggplotly()


## 1.2.1 Customizing the layout

# dragmode

p <- ggplot(fortify(gold), aes(x, y)) + geom_line()
gg <- ggplotly(p)
layout(gg, dragmode = "pan")


# Range sliders

rangeslider(gg)

### 1.2.2 Modifying layers