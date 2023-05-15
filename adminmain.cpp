#include "ui_adminmain.h"
#include "adminmain.h"
#include "hellopage.h"

adminMain::adminMain(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::adminMain)
{
    ui->setupUi(this);
    killCurrentConnection();
}

adminMain::~adminMain()
{
    delete ui;
}

void adminMain::on_exitAdmin_btn_clicked()
{
    killCurrentConnection();
    HelloPage *hp = new HelloPage();
    hp->show();
    adminMain::close();
}
