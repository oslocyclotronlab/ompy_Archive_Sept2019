import os
import numpy as np
from scipy.interpolate import interp1d#, interp2d

# from .firstgen import *
# from .unfold import *
from .rebin import *
from .library import *

DTYPE = np.float64


def gaussian(double[:] E_array, double mu, double sigma):
    """
    Returns a normalized Gaussian supported on E_array
    """
    gaussian_array = np.zeros(len(E_array), dtype=DTYPE)
    cdef double[:] gaussian_array_view = gaussian_array
    cdef double prefactor

    prefactor = (1/(sigma*np.sqrt(2*np.pi)))
    cdef int i
    for i in range(len(E_array)):
        gaussian_array_view[i] = (prefactor
                                  * np.exp(
                                    -(E_array[i]-mu)
                                    * (E_array[i]-mu)/(2*sigma*sigma))
                                  )

    return gaussian_array


def gauss_smoothing(double[:] vector_in, double[:] E_array, double fwhm):
    """
    Function which smooths an array of counts by a Gaussian
    of full-width-half-maximum FWHM. Preserves number of counts.
    Args:
        vector_in (array, double): Array of inbound counts to be smoothed
        E_array (array, double): Array with energy calibration of vector_in
        fwhm (double): The full-width-half-maximum value to smooth by

    Returns:
        vector_out: Array of smoothed counts

    """
    if not len(vector_in) == len(E_array):
        raise ValueError("Length mismatch between vector_in and E_array")

    cdef double[:] vector_in_view = vector_in

    vector_out = np.zeros(len(vector_in), dtype=DTYPE)
    # cdef double[:] vector_out_view = vector_out

    cdef int i
    for i in range(len(vector_out)):
        vector_out += (vector_in_view[i]
                       * gaussian(E_array, mu=E_array[i], sigma=fwhm/2.355))

    return vector_out
