#ifndef GRIGNETTA_H
#define GRIGNETTA_H

#include <QWidget>


QT_BEGIN_NAMESPACE
namespace Ui { class Grignetta; }
QT_END_NAMESPACE

class Grignetta : public QWidget
{
    Q_OBJECT

public:
    Grignetta(QWidget *parent = nullptr);
    ~Grignetta();

private slots:
    void on_inputButton_clicked();

    void on_outputButton_clicked();

    void on_declipButton_clicked();

    void on_peakSlider_valueChanged(int value);

    void on_diffSlider_valueChanged(int value);

private:
    Ui::Grignetta *ui;
    QString inputFileName = "lavalier";
    QString outputFileName = "lavalier";
    double peakThreshold = 999;
    double diffThreshold = 999;

};
#endif // GRIGNETTA_H
