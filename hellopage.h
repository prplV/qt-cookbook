#ifndef HELLOPAGE_H
#define HELLOPAGE_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class HelloPage; }
QT_END_NAMESPACE

class HelloPage : public QMainWindow
{
    Q_OBJECT

public:
    HelloPage(QWidget *parent = nullptr);
    ~HelloPage();

private slots:
    void on_loginButton_clicked();
    void on_logoutButton_clicked();

private:
    Ui::HelloPage *ui;
};
#endif // HELLOPAGE_H
