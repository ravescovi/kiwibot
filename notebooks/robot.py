import numpy as np
import scipy.io.wavfile as wavfile

class Waveshaper():
    """
    Apply a transform to an audio signal; store transform as curve,
    use curve as lookup table.  Implementation of jQuery's WaveShaperNode
    API:
        http://webaudio.github.io/web-audio-api/#the-waveshapernode-interface
    """
    def __init__(self, curve):
        self.curve = curve
        self.n_bins = self.curve.shape[0]

    def transform(self, samples):
        # normalize to 0 < samples < 2
        max_val = np.max(np.abs(samples))
        if max_val >= 1.0:
            result = samples/np.max(np.abs(samples)) + 1.0
        else:
            result = samples + 1.0
        result = result * (self.n_bins-1)/2
        return self.curve[result.astype(np.int)]


# Diode constants (must be below 1; paper uses 0.2 and 0.4)
VB = 0.2
VL = 0.4

# Controls distortion
H = 4

# Controls N samples in lookup table; probably leave this alone
LOOKUP_SAMPLES = 1024

# Frequency (in Hz) of modulating frequency
MOD_F = 50

def diode_lookup(n_samples):
    result = np.zeros((n_samples,))
    for i in range(0, n_samples):
        v = float(i - float(n_samples)/2)/(n_samples/2)
        v = abs(v)
        if v < VB:
            result[i] = 0
        elif VB < v <= VL:
            result[i] = H * ((v - VB)**2)/(2*VL - 2*VB)
        else:
            result[i] = H*v - H*VL + (H*(VL-VB)**2)/(2*VL-2*VB)

    return result

def raw_diode(signal):
    result = np.zeros(signal.shape)
    for i in range(0, signal.shape[0]):
        v = signal[i]
        if v < VB:
            result[i] = 0
        elif VB < v <= VL:
            result[i] = H * ((v - VB)**2)/(2*VL - 2*VB)
    else:
        result[i] = H*v - H*VL + (H*(VL-VB)**2)/(2*VL-2*VB)
    return result


def dalekify(file):
    rate, data = wavfile.read(file)
    #data = data[:,1]

    # get max value to scale to original volume at the end
    scaler = np.max(np.abs(data))

    # Normalize to floats in range -1.0 < data < 1.0
    data = data.astype(np.float)/scaler

    # Length of array (number of samples)
    n_samples = data.shape[0]

    # Create the lookup table for simulating the diode.
    d_lookup = diode_lookup(LOOKUP_SAMPLES)
    diode = Waveshaper(d_lookup)

    # Simulate sine wave of frequency MOD_F (in Hz)
    tone = np.arange(n_samples)
    tone = np.sin(2*np.pi*tone*MOD_F/rate)

    # Gain tone by 1/2
    tone = tone * 0.5

    # Junctions here
    tone2 = tone.copy() # to top path
    data2 = data.copy() # to bottom path

    # Invert tone, sum paths
    tone = -tone + data2 # bottom path
    data = data + tone2 #top path

    #top
    data = diode.transform(data) + diode.transform(-data)

    #bottom
    tone = diode.transform(tone) + diode.transform(-tone)

    result = data - tone

    #scale to +-1.0
    result /= np.max(np.abs(result))
    #now scale to max value of input file.
    result *= scaler
    # wavfile.write wants ints between +-5000; hence the cast
    newfile = 'dalek_' + file
    wavfile.write(newfile, rate, result.astype(np.int16))
