# import required packages
import random
import numpy as np
import pandas as pd
from scipy.optimize import curve_fit
from scipy.integrate import odeint
import matplotlib.pyplot as plt

def sustainibilityODEs(y,t,parameters):
    # unpack vector inputs into variable names
    W = y[0]
    R = y[1]
    H = y[2]
    
    m = parameters[0] # VGO
    a = parameters[1] # Gasoline
    e = parameters[2] # Gas + Coke
    c12 = parameters[3]
    rR = parameters[4]
    kR = parameters[5]
    b = parameters[6]
    rH = parameters[7]
    kH = parameters[8]
    c21 = parameters[9]

    
    # define equations for three-lump model
    dWdt = - m*W + a*e*R*W + c12*H*W 
    dRdt = rR*R*(1-R/kR) - a*R*W - b*R*H
    dHdt = rH*H*(1-H/kH) - c21*H*W
    
    # return output for each of the ODEs in order
    return dWdt, dRdt, dHdt

def economicImpact(y,t,parameters):
    # unpack vector inputs into variable names
    W = y[0]
    R = y[1]
    H = y[2]
    
    m = parameters[0] # VGO
    a = parameters[1] # Gasoline
    e = parameters[2] # Gas + Coke
    c12 = parameters[3]
    rR = parameters[4]
    kR = parameters[5]
    b = parameters[6]
    rH = parameters[7]
    kH = parameters[8]
    c21 = parameters[9]

    
    # define equations for three-lump model
    dWdt = - m*W + a*e*R*W + c12*H*W 
    dRdt = rR*R*(1-R/kR) - a*R*W - b*R*H
    dHdt = rH*H*(1-H/kH) - c21*H*W
    
    # return output for each of the ODEs in order
    return dWdt, dRdt, dHdt


def model(xaxisdata, *params):
    # initial conditions for the ODEs
    
    yaxis0 = np.array([0.73722274, 0.99964489, 0.2])
    yaxisCalc = np.zeros((xaxisData.size, yaxis0.size))
    
    for i in np.arange(0, len(xaxisdata)): # loop iterates over each entry of time to check solved value at that time point
        if xaxisdata[i] == 0.0: # if true, output initial condition as answer
            yaxisCalc[i,:] = yaxis0
        else: # if false, solve ODE up to point of t and give solution at t as answer
            xaxisSpan = np.linspace(0.0, xaxisData[i], 101)
            ySoln = odeint(sustainibilityODEs, yaxis0, xaxisSpan, args = (params,))
            yaxisCalc[i,:] = ySoln[-1,:]
    # format output for curve_fit
    yaxisOutput = np.transpose(yaxisCalc)
    yaxisOutput = np.ravel(yaxisOutput)
    return yaxisOutput

# data needed for parameter estimation

data = pd.read_csv(r"C:\Users\Precision 5510\Documents\output.csv")
realtimeData = np.array(data)[0]
leng = 216 // 4
RList = realtimeData[:leng]
WList = realtimeData[leng:2*leng]
HList = [i for i in range(leng)]

# input data from Table 1, unitless unless otherwise specified
xaxisData = np.array([i for i in range(leng)]) # units of hours
# conversionData = np.array([0.4926,0.6204,0.7118,0.8238])
# VGOData = np.array([0.5074,0.3796,0.2882,0.1762])
mxRList = max(RList)
mxWList = max(WList)
mxHList = max(HList)

for i in range(leng):
    RList[i] = RList[i] / mxRList
    WList[i] = WList[i] / mxWList
    HList[i] = HList[i] / mxHList

yaxisData = np.array([RList, WList, HList])

# parameter guesses. Start with all at 1 as a rule of thumb
mGuess = 1 
aGuess = 1 
eGuess = 1 
c12Guess = 1
rRGuess = 1
kRGuess = 1
bGuess = 1
rHGuess = 1
kHGuess = 1
c21Guess = 1

# mGuess, aGuess, eGuess, c12Guess, rRGuess, kRGuess, bGuess, rHGuess, kHGuess, c21Guess
# pack parameter initial guesses together as a vector for use in curve_fit
parameterguesses = np.array([mGuess, aGuess, eGuess, c12Guess, rRGuess, kRGuess, bGuess, rHGuess, kHGuess, c21Guess])

# run curve_fit to estimate parameters
parametersoln, pcov = curve_fit(model, xaxisData, np.ravel(yaxisData), p0=parameterguesses)

# print outputs
print('Parameter values:')
print(parametersoln.tolist())
print('Covariance array:')
print(pcov)

# Run the model with estimated parameters for the specified timeaxisForPlotting

yaxis0 = np.array([0.73722274, 0.99964489, 0.2])
yatsoln = odeint(sustainibilityODEs,yaxis0,xaxisData,args = (parametersoln,))

# Figure 6: y_i vs. time
plt.plot(xaxisData, yaxisData[0,:],'ro', label='VGO data')
plt.plot(xaxisData, yaxisData[1,:],'gx', label='Gasoline data')
plt.plot(xaxisData, yaxisData[2,:],'b*', label='Gas+Coke data')
timeaxisForPlotting = np.linspace(0.0,1,100)
# plot labels: title, axis labels, legend
plt.plot(xaxisData, yatsoln[:,0], 'r', label='VGO')
plt.plot(xaxisData, yatsoln[:,1], 'g', label='Gasoline')
plt.plot(xaxisData, yatsoln[:,2], 'b', label='Gas+Coke')

plt.title('Three-lump parameter estimation for FCC process: yield vs. time')
plt.legend()
plt.xlabel('Time (hours)')
plt.ylabel('Yield (weight fraction)')
plt.show()