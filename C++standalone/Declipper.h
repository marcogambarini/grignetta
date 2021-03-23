#ifndef DECLIPPER_H
#define DECLIPPER_H

#include "AudioFile.h"
#include <Eigen/LU>
#include "math.h"


using namespace Eigen;

class Declipper{
public:
    //constructor
    Declipper();

    //setting parameters
    void setPeakThreshold(double p);
    void setDiffThreshold(double d);

    //normalize
    void normalize(AudioFile<double> *f);

    //core function
    void declip(AudioFile<double> *f);

private:
    double peakThreshold;
    double diffThreshold;
    int numThreshold;
};




Declipper::Declipper(){
    peakThreshold = 0.85;
    diffThreshold = 0.025;
    numThreshold = 3;
}


void Declipper::setPeakThreshold(double p){
    peakThreshold = p;
}


void Declipper::setDiffThreshold(double d){
    diffThreshold = d;
}


void Declipper::normalize(AudioFile<double> *f){
    double channelMax;

    int numChannels = f->getNumChannels();
    int numSamples = f->getNumSamplesPerChannel();
    for (int i=0; i<numChannels; i++){
        channelMax = 0;
        for (int j=0; j<numSamples; j++){
            if (abs(f->samples[i][j])>channelMax){
                channelMax = abs(f->samples[i][j]);
            }
        }
        for (int j=0; j<numSamples; j++){
            f->samples[i][j] = f->samples[i][j]/channelMax;
        }
    }

}


void Declipper::declip(AudioFile<double> *f){
    int secStart, secCount, j;
    double fStart, fEnd, fDiffStart, fDiffEnd, xLocal;

    int numChannels = f->getNumChannels();
    int numSamples = f->getNumSamplesPerChannel();
    int numClippedSamples = 0;

    for (int i=0; i<numChannels; i++){
        /*even if the first samples are clipped (unlikely),
         * we need something on the left to build the peak */
        j = 2;
        while (j < numSamples - numThreshold){
            if (abs(f->samples[i][j]) > peakThreshold){
                secStart = j;
                secCount = 0;
                while ((j < numSamples-numThreshold) &&
                       (abs(f->samples[i][j]) > peakThreshold) &&
                       (abs(f->samples[i][j+1] - f->samples[i][j]) < diffThreshold)){
                    j++;
                    secCount++;
                }
                if (secCount >= numThreshold){
                    numClippedSamples += secCount+1;

                    fStart = f->samples[i][secStart-1];
                    fEnd = f->samples[i][secStart+secCount+1];
                    fDiffStart = f->samples[i][secStart-1] - f->samples[i][secStart-2];
                    fDiffEnd = f->samples[i][secStart+secCount+2] - f->samples[i][secStart+secCount+1];


                    //Eigen library definitions
                    MatrixXd M(4, 3); //overconstrained system matrix
                    MatrixXd A(3, 3); //least-squares system matrix
                    VectorXd preB(4); //overconstrained system rhs
                    VectorXd b(3);    //least-squares system rhs
                    VectorXd coeff(3);//solution (2nd order poly fit coefficients)


                    //overconstrained system definition
                    M(0,0) = 0;                        M(0,1) = 0;         M(0,2) = 1;
                    M(1,0) = 0;                        M(1,1) = 1;         M(1,2) = 0;
                    M(2,0) = (secCount+2)*(secCount+2);M(2,1) = secCount+2;M(2,2) = 1;
                    M(3,0) = 2*(secCount+2);           M(3,1) = 1;         M(3,2) = 0;

                    preB(0) = fStart;
                    preB(1) = fDiffStart;
                    preB(2) = fEnd;
                    preB(3) = fDiffEnd;

                    //least-squares system definition
                    A = M.transpose()*M;
                    b = M.transpose()*preB;

                    //solve the system by LU decomposition
                    coeff = A.lu().solve(b);


                    //peak reconstruction
                    for (int k=secStart; k<secStart+secCount+1; k++){
                        xLocal = k - secStart + 1;
                        f->samples[i][k] = xLocal * (coeff(0)*xLocal + coeff(1)) + coeff(2);
                    }
                }
            }
            j++;
        }
    }

    std::cout << "There were " << numClippedSamples << " clipped samples, on a total of "
              << numSamples << " samples" << std::endl;
}


#endif // DECLIPPER_H
