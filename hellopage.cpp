#include "hellopage.h"
#include "ui_hellopage.h"
#include "cookbookmain.h"
#include "adminmain.h"

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
    killCurrentConnection();
}


void HelloPage::on_loginButton_clicked()
{
    if (ui->lineEdit->text()  ==  "")
    {
        ui->errorHandlerLabel->setText("Пустое поле Логин!");
    }
    else if (ui->lineEdit_2->text() == ""){
        ui->errorHandlerLabel->setText("Пустое поле Пароль!");
    }
    else{
        ui->errorHandlerLabel->setText("");
        if (setConnection(ui->lineEdit->text(), ui->lineEdit_2->text())){
            QString temp = ui->lineEdit->text();
            if (temp == "default_user")
            {
                cookbookMain *cbm  = new cookbookMain();
                cbm->show();
                HelloPage::close();
            }
            else if (temp == "moder"){
                adminMain *adm = new adminMain();
                adm->show();
                HelloPage::close();
            }
        }
    }
}

void HelloPage::on_logoutButton_clicked()
{
    ui->logFrame_2->setVisible(true);

}

void HelloPage::on_back_to_login_btn_clicked()
{
    ui->logFrame_2->setVisible(false);
}
