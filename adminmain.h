#ifndef ADMINMAIN_H
#define ADMINMAIN_H

#include <QWidget>
#include "dbconnection.h"

namespace Ui {
class adminMain;
}

class adminMain : public QWidget
{
    Q_OBJECT

public:
    explicit adminMain(QWidget *parent = nullptr);
    ~adminMain();

private slots:
    void on_exitAdmin_btn_clicked();

private:
    Ui::adminMain *ui;
};

#endif // ADMINMAIN_H
