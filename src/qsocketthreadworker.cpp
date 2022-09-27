#include "qsocketthreadworker.h"
#include <QAbstractSocket>
#include <QDataStream>

QSocketThreadWorker::QSocketThreadWorker(QObject *parent)
    : QObject{parent}
{
    socket = NULL;
}

void QSocketThreadWorker::open(QString hostName)
{
    QMutexLocker locker(&socketMutex);

    if (socket != NULL)
    {
        socket->close();
        socket->deleteLater();
        socket = nullptr;
    }

    socket = new QTcpSocket(this);

    connect(socket,SIGNAL(readyRead()),this,SLOT(readSocket()));
    connect(socket,SIGNAL(disconnected()),this,SLOT(discardSocket()));
    connect(socket,SIGNAL(stateChanged(QAbstractSocket::SocketState)),this,SLOT(onStateChanged(QAbstractSocket::SocketState)));

    emit statusMsg(QString("Connecting to Server '%1'").arg(hostName));

    socket->connectToHost(hostName,9001);
    if (socket->waitForConnected())
    {
        emit statusMsg("Connected to Server");
    }
    else
    {
        emit statusMsg(QString("Error Connecting to TCP Server: %1.").arg(socket->errorString()));
    }
}

void QSocketThreadWorker::onStateChanged(QAbstractSocket::SocketState state)
{
    emit stateChanged((int)state);
}

void QSocketThreadWorker::update(QString status)
{
    QMutexLocker locker(&socketMutex);

    if (socket)
    {
        if (socket->isOpen())
        {
            if (socket->state() == QAbstractSocket::ConnectedState)
            {
                QByteArray block;
                QDataStream out(&block, QIODevice::WriteOnly);

                out.setVersion(QDataStream::Qt_5_15);
                out << status;

                if (socket->write(block) == -1)
                {
                    emit statusMsg("Error writing to socket!");
                }
            }
        }
        else
        {
            socket->deleteLater();
            socket=nullptr;
            emit statusMsg("Socket not open, aborting!");
        }
    }
}

void QSocketThreadWorker::readSocket()
{
    if (socket && socket->isOpen())
    {
        QByteArray block = socket->readAll();

        QDataStream in(&block, QIODevice::ReadOnly);
        in.setVersion(QDataStream::Qt_5_15);

        while (!in.atEnd())
        {
            QString receiveString;
            in >> receiveString;
            emit statusMsg(receiveString);
        }
    }
}

void QSocketThreadWorker::discardSocket()
{
    if (socket!=NULL)
    {
        socket->deleteLater();
        socket=nullptr;
    }

    emit statusMsg("Client TCP Socket Disconnected!");
}
