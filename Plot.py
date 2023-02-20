import numpy as np
from scipy.integrate import solve_ivp

# Define the parameters
a = 0.0008  # Moose birth rate
y = 0.05    # Moose death rate due to other factors
m = 0.2     # Moose death rate due to predation by wolves
e = 0.002   # Efficiency of turning prey into predator offspring
c12 = 0.0005  # Moose carrying capacity affected by wolves
rR = 0.4    # Wolf reproduction rate
kR = 20000    # Wolf carrying capacity
rH = 0.05   # Moose reproduction rate
kH = 1200   # Moose carrying capacity
c21 = 0.0002  # Wolf deaths due to lack of food (moose)
b=0.00001
# Define the functions
def f(t, y):
    W, R, H = y
    dWdt = - m*W + a*e*R*W + c12*H*W 
    dRdt = rR*R*(1-R/kR) - a*R*W - b*R*H
    dHdt = rH*H*(1-H/kH) - c21*H*W
    return [dWdt, dRdt, dHdt]


# Define the initial conditions
W0 = 500
R0 = 5000
H0 = 100

# Define the time span and time step
t_span = (0, 100)
t_eval = np.linspace(0, 100, 1000)

# Solve the system using the Runge-Kutta method
sol = solve_ivp(f, t_span, [W0, R0, H0], t_eval=t_eval)

# Plot the solutions
import matplotlib.pyplot as plt
plt.plot(sol.t, sol.y[0], label='W')
plt.plot(sol.t, sol.y[1], label='R')
plt.plot(sol.t, sol.y[2], label='H')
plt.xlabel('Time')
plt.ylabel('Population')
plt.legend()
plt.show()