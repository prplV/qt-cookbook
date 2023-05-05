#include "hellopage.h"

#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    HelloPage w;
    w.show();
    return a.exec();
}
