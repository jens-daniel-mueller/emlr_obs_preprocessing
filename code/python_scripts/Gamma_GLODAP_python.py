# Polynomials and functions used in GLODAP to calculate GAMMA
# Translated into python from "gamma_GP_from_SP_pt.m" from Guillaume Serazin, Paul Barker & Trevor McDougall [ help@teos-10.org ]; VERSION NUMBER: 1.0 (27th October, 2011)

# Required packages

import pandas as pd
import numpy as np
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon
import math


# Define integers and coefficients for each term (28) of each basin. In the following functions called as "Fit".  Note that the Southern Ocean has an additional polynomial function

fit_north_atlantic = [
    [0,0,0.868250629754601],
    [1,0,4.40022403081395],
    [0,1,0.0324341891674178],
    [2,0,-6.45929201288070],
    [1,1,-9.92256348514822],
    [0,2,1.72145961018658],
    [3,0,-19.3531532033683],
    [2,1,66.9856908160296],
    [1,2,-12.9562244122766],
    [0,3,-3.47469967954487],
    [4,0,66.0796772714637],
    [3,1,-125.546334295077],
    [2,2,7.73752363817384],
    [1,3,10.1143932959310],
    [0,4,5.56029166412630],
    [5,0,-54.5838313094697],
    [4,1,70.6874394242861],
    [3,2,36.2272244269615],
    [2,3,-26.0173602458275],
    [1,4,-0.868664167905995],
    [0,5,-3.84846537069737],
    [6,0,10.8620520589394],
    [5,1,0.189417034623553],
    [4,2,-36.2275575056843],
    [3,3,22.6867313196590],
    [2,4,-8.16468531808416],
    [1,5,5.58313794099231],
    [0,6,-0.156149127884621]
]

fit_south_atlantic = [
    [0,0,0.970176813506429],
    [1,0,0.755382324920216],
    [0,1,0.270391840513646],
    [2,0,10.0570534575124],
    [1,1,-3.30869686476731],
    [0,2,-0.702511207122356],
    [3,0,-29.0124086439839],
    [2,1,-3.60728647124795],
    [1,2,10.6725319826530],
    [0,3,-0.342569734311159],
    [4,0,22.1708651635369],
    [3,1,61.1208402591733],
    [2,2,-61.0511562956348],
    [1,3,14.6648969886981],
    [0,4,-3.14312850717262],
    [5,0,13.0718524535924],
    [4,1,-106.892619745231],
    [3,2,74.4131690710915],
    [2,3,5.18263256656924],
    [1,4,-12.1368518101468],
    [0,5,2.73778893334855],
    [6,0,-15.8634717978759],
    [5,1,51.7078062701412],
    [4,2,-15.8597461367756],
    [3,3,-35.0297276945571],
    [2,4,28.7899447141466],
    [1,5,-8.73093192235768],
    [0,6,1.25587481738340]
]

fit_pacific = [
    [0,0,0.990419160678528],
    [1,0,1.10691302482411],
    [0,1,0.0545075600726227],
    [2,0,5.48298954708578],
    [1,1,-1.81027781763969],
    [0,2,0.673362062889351],
    [3,0,-9.59966716439147],
    [2,1,-11.1211267642241],
    [1,2,6.94431859780735],
    [0,3,-3.35534931941803],
    [4,0,-15.7911318241728],
    [3,1,86.4094941684553],
    [2,2,-63.9113580983532],
    [1,3,23.1248810527697],
    [0,4,-1.19356232779481],
    [5,0,48.3336456682489],
    [4,1,-145.889251358860],
    [3,2,95.6825154064427],
    [2,3,-8.43447476300482],
    [1,4,-16.0450914593959],
    [0,5,3.51016478240624],
    [6,0,-28.5141488621899],
    [5,1,72.6259160928028],
    [4,2,-34.7983038993856],
    [3,3,-21.9219942747555],
    [2,4,25.1352444814321],
    [1,5,-5.58077135773059],
    [0,6,0.0505878919989799]
]

fit_indian = [
    [0,0,0.915127744449523],
    [1,0,2.52567287174508],
    [0,1,0.276709571734987],
    [2,0,-0.531583207697361],
    [1,1,-5.95006196623071],
    [0,2,-1.29591003712053],
    [3,0,-6.52652369460365],
    [2,1,23.8940719644002],
    [1,2,-0.628267986663373],
    [0,3,3.75322031850245],
    [4,0,1.92080379786486],
    [3,1,0.341647815015304],
    [2,2,-39.2270069641610],
    [1,3,14.5023693075710],
    [0,4,-5.64931439477443],
    [5,0,20.3803121236886],
    [4,1,-64.7046763005989],
    [3,2,88.0985881844501],
    [2,3,-30.0525851211887],
    [1,4,4.04000477318118],
    [0,5,0.738499368804742],
    [6,0,-16.6137493655149],
    [5,1,46.5646683140094],
    [4,2,-43.1528176185231],
    [3,3,0.754772283610568],
    [2,4,13.2992863063285],
    [1,5,-6.93690276392252],
    [0,6,1.42081034484842]
]

fit_southern_ocean_N = [
    [0,0,0.874520046342081],
    [1,0,-1.64820627969497],
    [0,1,2.05462556912973],
    [2,0,28.0996269467290],
    [1,1,-8.27848721520081],
    [0,2,-9.03290825881587],
    [3,0,-91.0872821653811],
    [2,1,34.8904015133508],
    [1,2,0.949958161544143],
    [0,3,21.4780019724540],
    [4,0,133.921771803702],
    [3,1,-50.0511970208864],
    [2,2,-4.44794543753654],
    [1,3,-11.7794732139941],
    [0,4,-21.0132492641922],
    [5,0,-85.1619212879463],
    [4,1,7.85544471116596],
    [3,2,44.5061015983665],
    [2,3,-32.9544488911897],
    [1,4,31.2611766088444],
    [0,5,4.26251346968625],
    [6,0,17.2136374200161],
    [5,1,13.4683704071999],
    [4,2,-27.7122792678779],
    [3,3,11.9380310360096],
    [2,4,1.95823443401631],
    [1,5,-10.8585153444218],
    [0,6,1.44257249650877]
]

fit_southern_ocean_S = [
    [0,0,0.209190309846492],
    [1,0,-1.92636557096894],
    [0,1,-3.06518655463115],
    [2,0,9.06344944916046],
    [1,1,2.96183396117389],
    [0,2,39.0265896421229],
    [3,0,-15.3989635056620],
    [2,1,3.87221350781949],
    [1,2,-53.6710556192301],
    [0,3,-215.306225218700],
    [4,0,8.31163564170743],
    [3,1,-3.14460332260582],
    [2,2,3.68258441217306],
    [1,3,264.211505260770],
    [0,4,20.1983279379898]
]

# Define areas of different ocean basins used for weightening of the different gammas, i.e. specific weightening of northern atlantic gamma, indian ocean gamma etc... to get global gamma
indian_long = [100, 100, 55, 22, 22, 146, 146, 133.9, 126.94, 123.62, 120.92, 117.42, 114.11, 107.79, 102.57, 102.57, 98.79, 100]
indian_lat = [20,40,40,20,-90,-90, -41, -12.48, -8.58, -8.39, -8.7, -8.82, -8.02, -7.04, -3.784 , 2.9, 10, 20]
pacific_long = [100, 140, 240, 260, 272.59, 276.5, 278.65, 280.73, 295.217 ,290 , 300, 294, 290, 146, 146, 133.9, 126.94, 123.62, 120.92, 117.42, 114.11,107.79, 102.57, 102.57, 98.79, 100]
pacific_long_b = [lon - 360 for lon in pacific_long]

pacific_lat = [20, 66, 66, 19.55, 13.97, 9.6, 8.1, 9.33, 0, -52, -64.5, -67.5, -90, -90, -41,-12.48, -8.58, -8.39, -8.7, -8.82, -8.02,-7.04, -3.784 , 2.9, 10, 20]

indian_coord = [(lo, la) for lo, la in zip(indian_long, indian_lat)]
pacific_coord = [(lo, la) for lo, la in zip(pacific_long, pacific_lat)]
pacific_coord_b = [(lo, la) for lo, la in zip(pacific_long_b, pacific_lat)]

indian_poly = Polygon(indian_coord)
pacific_poly = Polygon(pacific_coord)
pacific_poly_b = Polygon(pacific_coord_b)

# Obtain polynomials, weight them and finally calculate the ("global") neutral density GAMMA
def calculate_gamma(df, log=None):
    """
    Calculate gamma values using different polynomials for different regions.

    Keyword arguments:
    df -- pandas data frame to work with
    log -- handle of the logger (default is None - print to standard output)
    """
    SP = df.SALNTY / 42.
    pt = df.THETA / 40.

    gamma_NAtl = fit_polynomial(SP, pt, fit_north_atlantic)
    gamma_SAtl = fit_polynomial(SP, pt, fit_south_atlantic)
    gamma_Pac = fit_polynomial(SP, pt, fit_pacific)
    gamma_Ind = fit_polynomial(SP, pt, fit_indian)
    gamma_SOce = gamma_G_southern_ocean(SP, pt, df.CTDPRS)
    #gamma_Arc = [np.nan] * len(SP)

    in_pacific = np.logical_or(in_poly(df.LONGITUDE, df.LATITUDE, pacific_poly), in_poly(df.LONGITUDE, df.LATITUDE, pacific_poly_b))
    in_indian = np.logical_and(in_poly(df.LONGITUDE, df.LATITUDE, indian_poly), np.logical_not(in_pacific))
    in_atlantic = np.logical_not(np.logical_or(in_pacific, in_indian))

    c1_sa = df.LATITUDE < -10
    c2_sa = np.logical_and(df.LATITUDE <= 10, df.LATITUDE >= -10)
    weight_sa = c1_sa + c2_sa * (0.5 + 0.5 * np.cos(math.pi * 0.05 * (df.LATITUDE+10)))

    c1_so = df.LATITUDE < -40
    c2_so = np.logical_and(df.LATITUDE <= -20, df.LATITUDE >= -40)
    weight_so = c1_so + c2_so * (0.5 + 0.5 * np.cos(math.pi * 0.05 * (df.LATITUDE+40)))

    gamma_Atl = (1 - weight_sa) * gamma_NAtl + weight_sa * gamma_SAtl

    gamma_middle = in_pacific * gamma_Pac + in_atlantic * gamma_Atl + in_indian * gamma_Ind

    gamma_GP = weight_so * gamma_SOce + (1 - weight_so) * gamma_middle

    gamma_GP[df.LATITUDE > 66] = np.nan

    gamma_GP = 20*gamma_GP - 20

    df = df.assign(GAMMA = gamma_GP)

    return df

# Here are the actual polynomials created and the individual (basin) gammas calculated
def fit_polynomial(SP, pt, Fit):
    """
    Calculates the value of the specific polynomials.
    """
    g = [Fit[0][2] for i in SP]
    for k in range(len(Fit)-1):
        i = Fit[k+1][0]
        j = Fit[k+1][1]
        g += Fit[k+1][2] * (SP**i * pt**j)
    return g

def gamma_G_southern_ocean(SP, pt, p):
    """
    """
    g_N = fit_polynomial(SP, pt, fit_southern_ocean_N)
    g_S = fit_polynomial(SP, pt, fit_southern_ocean_S)
    
    p_ref = 700
    pt_ref = 2.5
    c_pt = 0.65

    g_S = g_S * np.exp(-p/p_ref) * (0.5 - 0.5 * np.tanh((40*pt-pt_ref)/c_pt))
    g = g_N + g_S
    return g
    
def in_poly(long, lat, poly):
    """
    Creates a vector of booleans indication if a location (by long, lat) is inside a polygon.
    """
    points = [Point(lo, la) for lo, la in zip(long, lat)]
    inside = []
    for point in points:
        inside.append(poly.contains(point))
    return inside
