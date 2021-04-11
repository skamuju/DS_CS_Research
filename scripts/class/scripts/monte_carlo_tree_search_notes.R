# Library
library(animation)

# Data
tickers = "AAPL"
quantmod::getSymbols(tickers)
closePrices <- do.call(merge, lapply(tickers, function(x) get(x)[,4]))
closeReturns <- quantmod::dailyReturn(closePrices)


# Q: what is the difference between closePrices and closeReturns
# someone told me this:
# you took SAT 3 times: 1st has 2000, 2nd has 2400, 3rd has 2200
# in your head, you should have two graphs

# we collect data
SATGrades = c(2000, 2400, 2200, 2300, 2200, 2400, 2300, 2200, 2300, 2200, 2400, 2200, 2200, 2300, 2200, 2200, 2300, 2400)

# compute change
SATChange = SATGrades[-1] / SATGrades[-length(SATGrades)] - 1

# what the real data looks like in time-series plot
plot(SATGrades, xlab = "Year") # first plot, everybody knows

# this is the histogram of real data but in terms of returns
hist(SATChange) # second plot, you need to add it, because your brain think of it automatically

# created fake times-series data based on returns from real data
plot(2000*cumprod(SATChange+1), xlab = "Year", main = "Fake")

par(mfrow=c(1,1))
plot(closePrices)

# this section I used prices
empiricalAve = mean(closePrices[1:100, ])
empiricalDiff = closePrices[1:100, ] - empiricalAve
plot(empiricalDiff)
empiricalAve = mean(closePrices[100:200, ])
empiricalDiff = closePrices[100:200, ] - empiricalAve
plot(empiricalDiff)
empiricalAve = mean(closePrices[200:500, ])
empiricalDiff = closePrices[200:500, ] - empiricalAve
plot(empiricalDiff)

# this section I used returns: try this part
empiricalAve = mean(closeReturns[1:100, ])
empiricalDiff = closeReturns[1:100, ] - empiricalAve
plot(empiricalDiff)
empiricalAve = mean(closeReturns[100:200, ])
empiricalDiff = closeReturns[100:200, ] - empiricalAve
plot(empiricalDiff)
empiricalAve = mean(closeReturns[200:500, ])
empiricalDiff = closeReturns[200:500, ] - empiricalAve
plot(empiricalDiff)

# say your goal is forecast
# you want to say: I observe the past and I guess the future is XXX with little error (*)
# section (i): use prices, during a certain time window 1, the average is X1; if you go for time window 2, then you'll have X2, X1=X2 not gauranteed!
# section (ii): use returns, then you can say (*)


par(mfrow=c(2,1))
plot(closeReturns) # time-series plot: on a certain day, I plot a return on that day
hist(closeReturns) # histogram: a window, say [0.00, 0.02], has approx. 1500+500 obs.


simulatedReturns = closeReturns
correctPath = cumprod(closeReturns + 1)
plot(correctPath, main = paste0("Entered Ticker: ", tickers, " (starting from $1)"))
L = length(closeReturns)
plot(closePrices, main = paste0("Entered Ticker: ", tickers, " (daily closing price)"))

# Define data
# Core assumption
# 1st, we don't know, let me guess
# naive, random number generator
# challenge: I look at the history and it is a bellshape
# let me assign as normal distribution => this means I need to assign mu, and s
mu = 0 # I believe the average is 0
s = 0.005 # I believe the SD is 0.005
num.of.sim <- 3e3
num.of.days <- 25
data <- matrix(rnorm(num.of.sim*num.of.days,mean=mu,sd=s),nrow=num.of.days); data[1, ] = 0L
updatedPath <- data
takeBearIntoConsideration = FALSE # sth new, indicates market trend direction

# Create GIF
setwd("C:/Users/eagle/OneDrive/Desktop/")
saveGIF({
  for (d in 1:length(c(seq(1, L-num.of.days, num.of.days)[-length(seq(1, L-num.of.days, num.of.days))], L - num.of.days))) {
    # Setup
    currGenIdx = d
    d = seq(1, L, num.of.days)[d]
    
    # Start New Generation of MC Simulation
    par(mfrow=c(2, 1))
    if (d > 1) {
      mu = mean(data[, currIdx]) # an update ; 2nd time
      s = sd(data[, currIdx]) # an update
    } # update parameter of prior distribution
    if (takeBearIntoConsideration) {
      data1 <- matrix(rnorm((.5*num.of.sim)*num.of.days,mean=mu,sd=s),nrow=num.of.days); data1[1, ] = 0L
      data2 <- matrix(rnorm((.5*num.of.sim)*num.of.days,mean=mu,sd=s)*(-1),nrow=num.of.days); data2[1, ] = 0L
      data <- cbind(data1, data2)
    } else {
      data <- matrix(rnorm(num.of.sim*num.of.days,mean=mu,sd=s),nrow=num.of.days); data[1, ] = 0L
    }
    for (N in seq(10,num.of.days,10)) {
      select.data <- data[1:N, ]
      cumret <- select.data + 1L
      cumretpath <- apply(cbind(cumret), 2, cumprod)
      # plot(x = 1:N, y = cumretpath[,1], type = "l", 
      #      main = paste0(
      #        "Simulated Path for $1 Investment\n Comment: X1, X2, ..., X", num.of.sim, 
      #        " drawn from N(",mu,",",s,") assuming iid"),
      #      ylab = "Numbers in USD",
      #      xlab = paste0("Time from Day 1 to Day ", N), 
      #      xaxs = "i", yaxs = "i",
      #      col = 1, xlim = c(1, num.of.days), ylim = c(min(cumretpath), max(cumretpath)))
      # for (i in 1:num.of.sim) { lines(x = 1:N, y = cumretpath[, i], type = "l", col = i) }
    } # end of current generation
    
    # Tree Search Current Generation for Least Errors
    currIdx = which.min(apply(cumretpath, 2, function(c) {mean((c - cumprod(closeReturns + 1)[1:num.of.days])^2)}))
    currMSE = mean((cumretpath[, currIdx] - cumprod(closeReturns + 1)[1:num.of.days])^2)
    
    # Store
    closeReturns[1:num.of.days]
    simulatedReturns[d:(d+num.of.days-1)] = data[, currIdx]
    
    # Visualization
    plot(x = 1:(d+num.of.days), y = correctPath[1:(d+num.of.days)],
         main = paste0("Real Path for Ticker: ", tickers, " (starting from $1)"),
         type = "l",
         ylab = "Numbers in USD",
         xlab = paste0("Time from Day 1 to Day ", d+num.of.days), 
         xaxs = "i", yaxs = "i",
         col = 1, xlim = c(1, L))
    simulatedPath = cumprod(simulatedReturns + 1)
    plot(x = 1:(d+num.of.days), y = simulatedPath[1:(d+num.of.days)],
         main = paste0(
           "Simulated Path Up to ", currGenIdx, "th Gen (starting from $1)\nRMSE for Current Gen is ", round(sqrt(currMSE), 4)),
         type = "l",
         ylab = "Numbers in USD",
         xlab = paste0("Time from Day 1 to Day ", d+num.of.days), 
         xaxs = "i", yaxs = "i",
         col = 1, xlim = c(1, L))
    
    # Checkpoint
    print(paste0("Finished ", currGenIdx, "/", length(seq(1, L, num.of.days))))
  } # end of all generations
}, movie.name = "mc-sim-random-walk-adv.gif", interval = .5, nmax = 30,
ani.width = 800, ani.height = 600)


# Reinforcement Learning [branch of research]
# MC Tree Search [this is the technique]
# MC Simulation (we create the data [*] subjectively, there is human error) => as One Gen; one single experiment [this is what the technique needs]
# Pick the Closest Path and regenerate data using that path

# objection: why not use deep learning to predict the moves instead of guessing by human?
# answer: yes, let's try that
# first: what is deep learning? 1st Neural Network or Deep Neural Network, 2nd is Convolutional Neural Network, 3rd is Recurrent Neural Network
# any 3 can give you a prediction of something
# the job here is to come up with a design such that this "something" is what can help us update the data (what data are we referring? refer to data [*])





















