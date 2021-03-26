#include "grignetta.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    Grignetta w;
    w.show();



    return a.exec();
}
