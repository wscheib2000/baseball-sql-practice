library(DBI)
library(dplyr)
library(ggplot2)

# Set seed for reproducibility
set.seed(12345)

# Connect db
db <- dbConnect(RSQLite::SQLite(), dbname="./data/lahman2019.sqlite")


query <- dbSendQuery(db, readr::read_file('./sp_query.sql'))
data <- query %>% dbFetch()
query %>% dbClearResult()


# Histogram theme settings
plot_theme <- function() {
  theme(
    axis.title = element_blank(),
    title = element_text(colour = 'blue', size = 20),
    plot.margin = margin(1, 1, 1, 1, 'cm'),
    axis.text = element_text(size = 12),
    axis.ticks.x = element_blank(),
    panel.grid = element_blank(),
    panel.background = element_rect(fill = 'white', colour = 'black'),
    plot.background = element_rect(fill = 'light grey')
  )
}

# Calculate parameters
mean = data$weighted_TTO_above_yearly_avg %>% mean()
sd = data$weighted_TTO_above_yearly_avg %>% sd()
binwidth = data$weighted_TTO_above_yearly_avg %>% (function(val) (max(val) - min(val)) / 20)
n = data %>% nrow()

# Create histogram
above_avg_hist <- 
  ggplot(
    data = data, 
    aes(
      x=weighted_TTO_above_yearly_avg,
      mean = mean,
      sd = sd,
      binwidth = binwidth,
      n = n
    )
  ) + 
  geom_histogram(binwidth = binwidth, colour = 'red', fill = 'pink') +
  stat_function(
    fun = function(x) dnorm(x, mean, sd) * binwidth * n,
    colour = 'black',
    size = 1)

above_avg_hist <- above_avg_hist +
  labs(title = 'Weighted TTO Above Yearly Average') +
  annotate(
    geom = 'text',
    label = list(
      deparse(bquote(mu*":"~.(round(mean, 3)))),
      deparse(bquote(sigma*":"~.(round(sd, 3))))
    ),
    parse = TRUE,
    x = max(data$weighted_TTO_above_yearly_avg) - binwidth*2,
    y = c(
      max(ggplot_build(above_avg_hist)$data[[1]]$count)*.8, 
      max(ggplot_build(above_avg_hist)$data[[1]]$count)*.7
    ),
    size = 5
  ) +
  plot_theme()

above_avg_hist


data$wght_TTO_abv_avg_adj = data$weighted_TTO_above_yearly_avg - mean(data$weighted_TTO_above_yearly_avg)

head(data, 10)
tail(data, 10)


# Calculate parameters
mean = data$wght_TTO_abv_avg_adj %>% mean()
sd = data$wght_TTO_abv_avg_adj %>% sd()
binwidth = data$wght_TTO_abv_avg_adj %>% (function(val) (max(val) - min(val)) / 20)
n = data %>% nrow()

# Create histogram
above_avg_adj_hist <- 
  ggplot(
    data = data, 
    aes(
      x=wght_TTO_abv_avg_adj,
      mean = mean,
      sd = sd,
      binwidth = binwidth,
      n = n
    )
  ) + 
  geom_histogram(binwidth = binwidth, colour = 'red', fill = 'pink') +
  stat_function(
    fun = function(x) dnorm(x, mean, sd) * binwidth * n,
    colour = 'black',
    size = 1)

above_avg_hist <- above_avg_hist +
  labs(title = 'Adjusted Weighted TTO Above Yearly Average') +
  annotate(
    geom = 'text',
    label = list(
      deparse(bquote(mu*":"~.(round(mean, 3)))),
      deparse(bquote(sigma*":"~.(round(sd, 3))))
    ),
    parse = TRUE,
    x = max(data$wght_TTO_abv_avg_adj) - binwidth*2,
    y = c(
      max(ggplot_build(above_avg_hist)$data[[1]]$count)*.8, 
      max(ggplot_build(above_avg_hist)$data[[1]]$count)*.7
    ),
    size = 5
  ) +
  plot_theme()

above_avg_adj_hist
