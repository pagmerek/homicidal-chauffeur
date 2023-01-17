import numpy as np
from scipy import optimize
from scipy.integrate import solve_ivp

def hc_dynamics(t, z, w1, w2, r, v1, v2, u):
        x, y = z
        return np.array([-w1/r * y * u[int(t*10)] + v1, w1/r*u[t]*x - w2 + v2])


def p_cost(u, t, z1, z2, w1, w2, v1, v2, r):
  sol = solve_ivp(hc_dynamics, [0, t], [z1, z2], dense_output=True, args=(w1, w2, r, v1, v2, u[0]))
  z = sol.sol(t)
  return 10e-6/2*u(t)**2 + 0.5*np.linalg.norm(z)  + t


def e_cost(v, u, t, z1, z2, w1, w2, r):
  sol = solve_ivp(hc_dynamics, [0, t], [z1, z2], dense_output=True, args=(w1, w2, r, v[0], v[1], u))
  z = sol.sol(t)
  return 10e-6/2*np.linalg.norm(v)**2 - 10e-4/2*np.linalg.norm(z) - 10e-6*t

def get_controls(t, z1, z2, w1, w2, r, v1, v2, u):
    bound_p = [(-1, 1)]
    bound_e = bound_p * 2 
    v1_n, v2_n = v1, v2
    t_eval = np.linspace(0, 10, 100)
    u_n = np.ones(100)
    control_p = optimize.minimize(p_cost, u_n, args=(t,z1,z2,w1,w2,v1_n,v2_n,r), bounds=bound_p).x

    return control_p.tolist()

# def get_controls(t, z1, z2, w1, w2, r, v1, v2, u):
#   sol = solve_ivp(costate, [0,t], [5,5], dense_output=True, args=(w1,r,v2,u,v1) )
#   p = sol.sol(t)
#   u = np.sign(p[0]*z2 - p[1]*z1)
#   return u.item()

# def costate(t, p,w1,r,v2,u,v1):
#   p1, p2 = p 
#   return [-v1*p1 - w1/r*u*p2, w1/r*u*p1 - p2*v2]
 