#ifndef QSOCKETTHREADWORKER_H
#define QSOCKETTHREADWORKER_H

#include <QObject>
#include <QTcpSocket>
#include <QMutex>
#include <QMutexLocker>

class QSocketThreadWorker : public QObject
{
    Q_OBJECT
public:
    explicit QSocketThreadWorker(QObject *parent = nullptr);

public slots:
    void update(QString status);
    void open(QString hostName);
    void readSocket();
    void discardSocket();
    void onStateChanged(QAbstractSocket::SocketState);

signals:
    void statusMsg(QString msg);
    void stateChanged(int);

private:
    QTcpSocket* socket;
    QMutex socketMutex;

};

#endif // QSOCKETTHREADWORKER_H
