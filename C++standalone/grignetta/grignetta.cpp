#include "grignetta.h"
#include "ui_grignetta.h"
#include <iostream>
#include <string>
#include <QFileDialog>
#include "AudioFile.h"

#include "declipper.h"

Grignetta::Grignetta(QWidget *parent)
    : QWidget(parent)
    , ui(new Ui::Grignetta)
{
    ui->setupUi(this);
    ui->infoListing->setText("Ready!\n");

    ui->peakSlider->setSliderPosition(85);
    ui->diffSlider->setSliderPosition(25);
}

Grignetta::~Grignetta()
{
    delete ui;
}



void Grignetta::on_inputButton_clicked()
{
    inputFileName = QFileDialog::getOpenFileName(this,
            tr("Open audio file"), "", tr("Audio files (*.wav)"));
    ui->infoListing->setText(ui->infoListing->text()
                             +"Input file:\n"+inputFileName+"\n");
}

void Grignetta::on_outputButton_clicked()
{
    outputFileName = QFileDialog::getSaveFileName(this,
            tr("Locate or create output file"), "", tr("Audio files (*.wav)"));
    ui->infoListing->setText(ui->infoListing->text()
                             +"Output file:\n"+outputFileName+"\n");
}

void Grignetta::on_declipButton_clicked()
{
    if ((inputFileName.compare("lavalier")==0)||(outputFileName.compare("lavalier")==0)){
        ui->infoListing->setText(ui->infoListing->text()
                                 +"Choose input and output files \n");
    }
    else{
        ui->infoListing->setText(ui->infoListing->text()
                                 +"Declipping ... \n");
        AudioFile<double> audioTrack;
        Declipper decl;

        //update thresholds only if the user changed them
        if (peakThreshold<1){
            decl.setPeakThreshold(peakThreshold);
        }

        if (diffThreshold<1){
            decl.setDiffThreshold(diffThreshold);
        }

        audioTrack.load(inputFileName.toStdString());

        decl.normalize(&audioTrack);
        decl.declip(&audioTrack);
        decl.normalize(&audioTrack);

        audioTrack.save(outputFileName.toStdString());

        ui->infoListing->setText(ui->infoListing->text()
                                 +"Done!\n");
    }
}

void Grignetta::on_peakSlider_valueChanged(int value)
{
    double peakThreshold = (double)value/(double)100;
    ui->peakValue->setText(QString::number(peakThreshold));
}

void Grignetta::on_diffSlider_valueChanged(int value)
{
    double diffThreshold = (double)value/(double)1000;
    ui->diffValue->setText(QString::number(diffThreshold));
}
