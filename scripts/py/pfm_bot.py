


from numpy.random import random
import yfinance as yf
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from datetime import date
import tensorflow as tf 
from tensorflow import keras
from tensorflow.keras import layers, Input
from tensorflow.keras.models import Sequential
import random

stockData = {}
tickers = ["MSFT"]
colors = ['red', 'blue', 'orange', 'yellow', 'olive', 'teal']
 
for ticker in tickers:
    stockData[ticker] = yf.download(ticker, start = '2020-01-01', end = '2021-04-04') 

msft_mean = np.mean(stockData['MSFT']['Adj Close'])

msft_returns = (stockData["MSFT"]["Close"] - stockData['MSFT']["Open"])/stockData['MSFT']["Open"] + 1

def calc_returns(mu, so, ticker):
    returns  = np.random.normal(mu, so, len(stockData[ticker]['Adj Close']))
    return returns

def create_branch(runs, s_mu, s_so, ticker, scale):
    
    mu = s_mu
    so = s_so
    diff_list = []

    for i in range(int(runs)):
        diff = 0
        if i != 0:
            mu += scale
        d_returns = calc_returns(mu, so, ticker)
        branch = []
        branch.append(stockData['MSFT']['Adj Close'][0])
        
        for j in range(len(d_returns)-1):
            branch.append((branch[-1] * (1 + d_returns[j])))
            diff += abs(stockData['MSFT']['Adj Close'][j] - branch[-1])
        
        diff_list.append(diff)
        plt.plot(branch, label = "branch: {}, mean: {}".format(i + 1, mu))
    
    for i in range(len(diff_list)):
        if diff_list[i] == min(diff_list):
            print(i + 1, mu, so, diff_list)

#Neural Netowrk Setup and Architecture

data_len = 100
train_data = []

for i in range(data_len):
    train_data.append(stockData['MSFT']['Adj Close'][i])

mean_train = np.mean(train_data)

model = keras.Sequential()
model.add(layers.Embedding(input_dim = data_len, output_dim = 64))
model.add(layers.LSTM(128))
model.add(layers.Dense(10))
model.add(layers.Dense(1, activation = 'sigmoid'))

model.compile(
    optimizer = 'adam',
    loss = 'categorical_crossentropy',
)

model.fit(train_data, epochs = 10)

if __name__ == "__main__":

    model.summary()
    stock = []

    for ticker in tickers:
        for price in stockData[ticker]['Adj Close']:
            stock.append(price)
    
    plt.plot(stock, label = "MSFT")
    create_branch(4, 0, 0.01, 'MSFT', 0.001)

    plt.ylabel('Price')
    plt.legend()
    plt.show()
