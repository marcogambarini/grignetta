#include <QCoreApplication>
#include <iostream>
#include "AudioFile.h"

#include "Declipper.h"



AudioFile<double> audioInput;




int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    Declipper decl;
    decl.setPeakThreshold(0.825);
    decl.setDiffThreshold(0.025);


    audioInput.load("D:/marco/Carmel/plugin/provaaudiofile/esempio_norm_0.wav");
    audioInput.printSummary();


    decl.normalize(&audioInput);
    std::cout << "Done normalizing" << std::endl;
    decl.declip(&audioInput);
    decl.normalize(&audioInput);

    std::cout << "Done declipping! Saving..." << std::endl;

    audioInput.save("D:/marco/Carmel/plugin/provaaudiofile/output.wav");

    std::cout << "Saved!" << std::endl;

    return 0;
 }


