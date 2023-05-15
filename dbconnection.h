#ifndef DBCONNECTION_H
#define DBCONNECTION_H

#include <QSqlDatabase>
#include <QMessageBox>
#include <QDebug>

QSqlDatabase dbCookbook = QSqlDatabase::addDatabase("QPSQL");

bool setConnection(QString user_name, QString password){
    dbCookbook.setDatabaseName("cookbook");
    dbCookbook.setHostName("localhost");
    dbCookbook.setUserName(user_name);
    dbCookbook.setPassword(password);
    QMessageBox *mb = new QMessageBox();

    if (!(dbCookbook.open())){
        QMessageBox::critical(mb, "Connectionnn failed!", "User name or password is invalid!");
        qDebug() << "Connectionnn failed!";
        dbCookbook.close();
        return false;
    }else{
        if (dbCookbook.isOpen())
        {
            dbCookbook.close();
        }
        qDebug() << "Connectionnn approved!";
        mb->setText("Connection has been approved!");
        mb->exec();
        return true;
    }
}

void killCurrentConnection(){
    dbCookbook.close();
    return;
}


#endif // DBCONNECTION_H
