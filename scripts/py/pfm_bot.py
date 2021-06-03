


from numpy.random import random
import yfinance as yf
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from datetime import date
import random

stockData = {}
tickers = ["MSFT", "AAPL"]
colors = ['red', 'blue', 'orange', 'yellow', 'olive', 'teal']
 
for ticker in tickers:
    stockData[ticker] = yf.download(ticker, start = '2020-01-01', end = '2021-04-04')

msft_mean = np.mean(stockData['MSFT']['Adj Close'])

msft_returns = (stockData["MSFT"]["Close"] - stockData['MSFT']["Open"])/stockData['MSFT']["Open"] + 1

def create_branch(runs):
    color_ind = 0 
    for i in range(runs):
        branch = (msft_mean + (i * 10)) * msft_returns

if __name__ == "__main__":

    for ticker in tickers:
        stockData[ticker]['Adj Close'].plot()
    plt.ylabel('Price')
    plt.show()