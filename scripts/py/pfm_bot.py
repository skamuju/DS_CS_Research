


from numpy.random import random
from tensorflow.python.framework.meta_graph import read_meta_graph_file
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

def calc_returns(mu, so, ticker, lent):
    returns  = np.random.normal(mu, so, lent)
    return returns

def create_branch(runs, s_mu, s_so, ticker, scale, xlo, lent):
    
    mu = s_mu
    so = s_so
    diff_list = []

    for i in range(int(runs)):
        diff = 0
        if i != 0:
            mu += scale
        d_returns = calc_returns(mu, so, ticker, lent)
        branch = []
        branch.append(stockData['MSFT']['Adj Close'][xlo])
        
        for j in range(len(d_returns)-1):
            branch.append((branch[-1] * (1 + d_returns[j])))
            diff += abs(stockData['MSFT']['Adj Close'][xlo + j] - branch[j])
    
        diff_list.append(diff)
        plt.plot(branch, label = "branch: {}, mean: {}".format(i + 1, mu))
    
    for i in range(len(diff_list)):
        if diff_list[i] == min(diff_list):
            print(i + 1, mu, so, diff_list[i])
            print(diff_list)
    
    return mu 

def MCTS(runs, s_mu, s_so, splits, ticker, intra_scale, inter_scale):

    sectlen = len(stockData[ticker]['Adj Close']) // splits
    slo = 0
    mu = s_mu
    for i in range(splits):
        mu = create_branch(runs, mu, s_so, ticker, intra_scale, slo, sectlen)
        slo += sectlen
        intra_scale = intra_scale * inter_scale
 

#Neural Network Setup and Architecture

data_len = 100
train_data = []

for i in range(data_len):
    train_data.append(stockData['MSFT']['Adj Close'][i])

# mean_train = np.mean(train_data)

model = keras.Sequential()
model.add(layers.Embedding(input_dim = data_len, output_dim = 64))
model.add(layers.LSTM(128))
model.add(layers.Dense(10))
model.add(layers.Dense(1, activation = 'relu'))

model.compile(
    optimizer = 'adam',
    loss = 'binary_crossentropy',
)

model.fit(train_data, epochs = 10)

if __name__ == "__main__":

    # model.summary()
    stock = []
    num_runs = int(input('Number of runs: '))
    num_splits = int(input('Number of generations: '))

    for ticker in tickers:
        for price in stockData[ticker]['Adj Close']:
            stock.append(price)
    
    plt.plot(stock, label = "MSFT")
    # create_branch(num_runs, 0, 0.01, 'MSFT', 0.001)
    MCTS(num_runs, 0.0007, 0.01, num_splits, 'MSFT', 0.0001, 0.1)

    plt.ylabel('Price')
    plt.legend()
    plt.show()

"""
update readme
change image in 

"""

