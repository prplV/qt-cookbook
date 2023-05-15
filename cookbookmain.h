#ifndef COOKBOOKMAIN_H
#define COOKBOOKMAIN_H

#include <QFrame>
#include <QMessageBox>
#include "dbconnection.h"

namespace Ui {
class cookbookMain;
}

class cookbookMain : public QFrame
{
    Q_OBJECT

public:
    explicit cookbookMain(QWidget *parent = nullptr);
    ~cookbookMain();
private slots:
    void on_pushButton_clicked();

    void on_widget_on_click_mealWidget();

    void on_menu_btn_clicked();

    void on_pushButton_2_clicked();

private:
    Ui::cookbookMain *ui;
};

#endif // COOKBOOKMAIN_H
