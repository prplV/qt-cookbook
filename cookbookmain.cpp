#include "ui_cookbookmain.h"
#include "cookbookmain.h"
#include "hellopage.h"


cookbookMain::cookbookMain(QWidget *parent) :
    QFrame(parent),
    ui(new Ui::cookbookMain)
{
    ui->setupUi(this);
    ui->mealSearchFrame->hide();
}

cookbookMain::~cookbookMain()
{
    delete ui;
    killCurrentConnection();
}

void cookbookMain::on_widget_on_click_mealWidget(){

}

// кнопка "back"
void cookbookMain::on_pushButton_clicked()
{
    killCurrentConnection();
    HelloPage *hp = new HelloPage();
    hp->show();
    cookbookMain::close();
}

//отображение меню поиска
void cookbookMain::on_menu_btn_clicked()
{
    if (ui->mealSearchFrame->isHidden())
    {
        ui->mealSearchFrame->setVisible(true);
    }
    else{
        ui->mealSearchFrame->setVisible(false);
    }
}

//поиск по имени блюда
void cookbookMain::on_pushButton_2_clicked()
{

}
