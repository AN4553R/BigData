library('ggplot2')
library('forecast')
library('tseries')
library('rjson')
library('lubridate')
library('cowplot')

df <- read.csv("ratings_Digital_Music.csv", header = TRUE,stringsAsFactors = FALSE)

df <-data.frame(df)

daily_data <- fromJSON(file="reviews_Digital_Music_5.json")

names(df) = c("reviewerID","productID","productRate","reviewTime")

df$reviewTime = as_datetime(df$reviewTime, origin = lubridate::origin)

# Rate Frequency

graph <- ggplot(df, aes(productRate)) + geom_histogram(binwidth = 0.4) + labs(x = "Product Rate",title = "Rate Frequency",caption = "Digital Music")

ggsave(filename = "ratefreq.png", plot = graph, width = 6, height = 4)

# Annual Trends

years = sort(unique(year(df$reviewTime)))

trends = data.frame()

for (y in years)
  trends <- rbind(trends,(df[year(df$reviewTime)==y & df$productRate==5,]))

dots = data.frame()

for(y in years)
{
  dots <- rbind(dots,data.frame(y,length(trends[year(trends$reviewTime)==y,1])))
}
names(dots) = c("year","cnt")

#dots$normalized <-apply(dots[2], 1, function(row_val) row_val / 100)

graph <-ggplot(data = dots) +
  geom_line(aes(year, cnt)) +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) +
  scale_x_discrete(limits=c(years[1]: years[length(years)])) +
  labs(x = "Year", y = "Number Of Trends", title = "Annual Trends", caption = "Digital Music")

ggsave(filename = "TrendsOfEachYear.png", plot = graph, width = 6, height = 4)

# Annual Rate 
cnt = 1
for(i in seq(1,length(years)-4,4))
{
  
  one = years[i]
  two =years[i+1]
  three = years[i+2]
  four = years[i+3]
  
  first = df[year(df$reviewTime)==one,]
  second = df[year(df$reviewTime)==two,]
  third = df[year(df$reviewTime)==three,]
  fourth = df[year(df$reviewTime)==four,]
  
  gOne <- ggplot(data = first)+geom_line(aes(first$reviewTime, productRate)) + 
    scale_x_datetime(first$reviewTime) + 
    theme(axis.text=element_text(size=6,angle =90),
          axis.title=element_text(size=10,face="bold"))+ xlab(str(one)) + ylab("Rate")
  
  gTwo <- ggplot(data = second)+geom_line(aes(second$reviewTime, productRate)) + 
    scale_x_datetime(second$reviewTime) + 
    theme(axis.text=element_text(size=6,angle =90),
          axis.title=element_text(size=10,face="bold"))+ xlab(str(two)) + ylab("Rate")
  
  gThree <- ggplot(data = third)+geom_line(aes(third$reviewTime, productRate)) + 
    scale_x_datetime(third$reviewTime) + 
    theme(axis.text=element_text(size=6,angle =90),
          axis.title=element_text(size=10,face="bold"))+ xlab(str(three)) + ylab("Rate")
  
  gFour <- ggplot(data = fourth)+geom_line(aes(fourth$reviewTime, productRate)) + 
    scale_x_datetime(fourth$reviewTime) + 
    theme(axis.text=element_text(size=6,angle =90),
          axis.title=element_text(size=10,face="bold"))+ xlab(str(four)) + ylab("Rate")
  
  
  figure <- ggdraw() +
    draw_plot(gOne, x = 0, y = .5, width = .5, height = .5) +
    draw_plot(gTwo, x = .5, y = .5, width = .5, height = .5) +
    draw_plot(gThree, x = 0, y = 0, width = 0.5, height = .5) +
    draw_plot(gFour, x = 0.5, y = 0, width = 0.5, height = .5)
  
  fname <- paste("annual_rate_graph",cnt,".png",sep = "")
  cnt <- cnt + 1
  ggsave(filename = fname, plot = figure, width = 6, height = 4)
  
}

# clean the data from the time dimension
daily_ts <- ts(df[, c('productRate')])


# tsclean() to remove time series outliers
df$clean_rate <- daily_ts #tsclean(daily_ts)


graph <- ggplot(data = df) +
  geom_line(aes(reviewTime, clean_rate)) +
  scale_y_continuous(expand = c(0,5)) +
  ylab('Cleaned Rate Count') 
ggsave(filename = "cleaned.png", plot = graph, width = 6, height = 4)


# Rate Average (ma) demo

# weekly rate average
df$cnt_ma <- ma(df$clean_rate, order = 7)

# monthly moving average
df$cnt_ma30 = ma(df$clean_rate, order = 30)

graph <- ggplot(data = df) +
  geom_line(aes(x = reviewTime, y = clean_rate, colour = "Counts")) +
  geom_line(aes(x = reviewTime, y = cnt_ma, colour = "Weekly rate average")) +
  geom_line(aes(x = reviewTime, y = cnt_ma30, colour = "Monthly rate average")) +
  scale_y_continuous(expand = c(0,5)) +
  ylab('Movie Rate')

ggsave(filename = "rate_average.png", plot = graph, width = 6, height = 4)

# Decomposition

# calculate seasonal component of data using stl()

ts_ma <- ts(na.omit(df$cnt_ma), frequency = 30)
decom <- decompose(ts_ma, "additive")
deseasonal_cnt <- seasadj(decom)

png(filename = "deseasonal.png", width = 1024, height = 800)
plot(decom)
dev.off()

# Augmented Dickey-Fuller Test (ADF) - test if data is stationary

stationary_test <- adf.test(ts_ma, alternative = "stationary")

# Fitting an arima model
fit <- auto.arima(deseasonal_cnt, seasonal = FALSE)

# calculate ACF and PACF and choose correct order for p and q
png(filename = "fit_non_seasonal_residuals.png", width = 1024, height = 800)
tsdisplay(residuals(fit), lag.max = 45, main = "(1,1,1) Model Residuals")
dev.off()

# see that AIC is smaller for this order
fit2 <- arima(deseasonal_cnt, order = c(1,1,7))

png(filename = "fit_order_1_1_7.png", width = 1024, height = 800)
tsdisplay(residuals(fit2), lag.max = 45, main = "(1,1,7) Model Residuals")
dev.off()


# forecast
fcast <- forecast(fit2, h = 30)
png(filename = "forecast_1_1_7.png", width = 1024, height = 800)
plot(fcast)
dev.off()

#########################################################################

# fit with seasonality
fit_w_season <- auto.arima(deseasonal_cnt, seasonal = TRUE)

# residuals
png(filename = "fit_w_season_residuals.png", width = 1024, height = 800)
tsdisplay(residuals(fit_w_season), lag.max = 45,
          main = "Seasonal Model Residuals")
dev.off()



# forecast - better prediction
fcast <- forecast(fit_w_season, h = 30)
png(filename = "forecast_seasonal.png", width = 1024, height = 800)
plot(fcast)
dev.off()

arima_seasonal <- Arima(daily_ts, order = c(2,1,2), seasonal = c(1,0,1), include.drift = TRUE)

arima_seasonal_pred <- fitted(arima_seasonal)

graph <- ggplot(daily_data) +
  geom_line(aes(x = date, y = cnt, colour = "Count")) +
  geom_line(aes(x = date, y = arima_seasonal_pred, colour = "ARIMA prediction")) +
  scale_x_date('month') +
  ylab("Rate count")

ggsave(filename = "arima_pred_1.png", plot = graph, width = 8, height = 6)

arima_cleaned_seasonal_pred <- fitted(fit_w_season)

mySeq <- seq(from = as.Date("2011-01-01"), to = as.Date("2012-12-25"), by = "day")

graph <- ggplot() +
  geom_line(aes(x = mySeq, y = arima_cleaned_seasonal_pred, colour = "ARIMA prediction")) +
  scale_x_date('month') +
  ylab("Rate count")

ggsave(filename = "arima_pred_2.png", plot = graph, width = 8, height = 6)
