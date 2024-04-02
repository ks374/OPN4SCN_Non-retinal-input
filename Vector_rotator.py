import numpy as np

def rot_vet(vin_1,vin_2):
    vector_in = [vin_2[0]-vin_1[0],vin_2[1]-vin_1[1]]
    vector_rotate = [-vector_in[1],vector_in[0]]
    length = np.sqrt(vector_rotate[0]**2+vector_rotate[1]**2)
    ratio = length/5
    vector_out = [vector_rotate[0]/ratio,vector_rotate[1]/ratio]
    print(vector_out)
    return
