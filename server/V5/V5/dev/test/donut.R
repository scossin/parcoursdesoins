rhtmlPictographs::graphic('circle:lightblue')
rhtmlPictographs::graphic()


library(plotly)
library(dplyr)
# Get Manufacturer
mtcars$manuf <- sapply(strsplit(rownames(mtcars), " "), "[[", 1)

p <- mtcars %>%
  group_by(manuf) %>%
  summarize(count = n()) %>%
  plot_ly(labels = ~manuf, values = ~count) %>%
  add_pie(hole = 0.6) %>%
  layout(title = "Donut charts using Plotly",  showlegend = F,
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
p
# Create a shareable link to your chart
# Set up API credentials: https://plot.ly/r/getting-started
chart_link = plotly_POST(p, filename="pie/donut")
chart_link

df <- data.frame(labels=c("unselected","selected"),values=c(0,1))

library(plotly)
colors <- c('rgb(0,0,0)','rgb(255,215,0)')
plot_ly(data = df, labels = ~labels, values = ~values,
        marker = list(colors=colors)) %>%
  add_pie(hole = 0.6) %>%
  layout(title = "Donut charts using Plotly",  showlegend = F,
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
         )
