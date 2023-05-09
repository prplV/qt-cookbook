#include "hellopage.h"
#include "ui_hellopage.h"

HelloPage::HelloPage(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::HelloPage)
{
    ui->setupUi(this);
}

HelloPage::~HelloPage()
{
    delete ui;
}


void HelloPage::on_loginButton_clicked()
{
    //ui->logFrame->setVisible(false);  very very vajno
    if (ui->lineEdit->text()  ==  "")
    {
        ui->errorHandlerLabel->setText("Empty Login field!");
    }
    else if (ui->lineEdit_2->text() == ""){
        ui->errorHandlerLabel->setText("Empty Password field!");
    }
    else{
        ui->errorHandlerLabel->setText("");

    }
    /*
        db requests
    */
}

void HelloPage::on_logoutButton_clicked()
{

}
