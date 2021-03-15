

m <- lm(Sepal.Length~Sepal.Width*Petal.Length*Petal.Width, data = iris)

# to order categories sensibly arrange by estimate then coerce factor 

d <- broom::tidy(m) %>% 
  arrange(desc(estimate)) %>%
  mutate(term = factor(term, levels = term))


plot_ly(d, x = ~estimate, y = ~term) %>%
  add_markers(error_x = ~list(value = std.error)) %>%
  layout(margin = list(l = 200))

