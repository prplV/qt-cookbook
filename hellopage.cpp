#include "hellopage.h"
#include "ui_hellopage.h"

HelloPage::HelloPage(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::HelloPage)
{
    ui->setupUi(this);
    ui->logFrame_2->setVisible(false);
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
    ui->logFrame_2->setVisible(true);

}

void HelloPage::on_back_to_login_btn_clicked()
{
    ui->logFrame_2->setVisible(false);

}

void HelloPage::on_log_out_final_btn_clicked()
{
    if (ui->name_ln_log_out->text() == ""){
        ui->errorHandlerLabel_2->setText("Name field is empty!");
    }else if (ui->login_ln_log_out->text() == ""){
        ui->errorHandlerLabel_2->setText("Login field is empty!");
    } else if (ui->passwd_ln_log_out->text() == "") {
        ui->errorHandlerLabel_2->setText("Password field is empty!");
    } else {
        ui->errorHandlerLabel_2->setText("");

    }
}
