#include "downloader.h"
#include <QUrl>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include "systemutils.h"

Downloader* Downloader::s_shared = nullptr;

Downloader::Downloader(QObject *parent) : QObject(parent), m_manager( this ) {

}

Downloader* Downloader::shared() {
    if ( s_shared == nullptr ) {
        s_shared = new Downloader;
    }
    return s_shared;
}

void Downloader::download(const QString &url, const QString &filepath) {
    QString temporaryPath = filepath + QString(".temp");
    //
    // delete existing
    //
    if ( QFile::exists(temporaryPath) ) {
        QFile::remove(temporaryPath);
    }
    //
    // download new
    //
    QNetworkReply *reply = m_manager.get(QNetworkRequest(QUrl(url)));
    //
    //
    //
    connect(reply, &QNetworkReply::readyRead,[=]() {
        QFile file( temporaryPath );
        if ( file.open(QFile::WriteOnly|QFile::Append) ) {
            QByteArray data = reply->readAll();
            file.write(data);
            file.close();
        }
    } );
    connect(reply, static_cast<void (QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error),[=](QNetworkReply::NetworkError /*error*/) {
        if ( QFile::exists(temporaryPath) ) {
            QFile::remove(temporaryPath);
            QString message = "network error";
            emit error( url, filepath, message );
        }
    });
    connect(reply, &QNetworkReply::sslErrors,[=](const QList<QSslError>& /*errors*/) {
        if ( QFile::exists(temporaryPath) ) {
            QFile::remove(temporaryPath);
            QString message = "ssl error";
            emit error( url, filepath, message );
        }
    });
    connect(reply, &QNetworkReply::finished,[=]() {
        if ( QFile::exists(temporaryPath) ) {
            SystemUtils::shared()->moveFile(temporaryPath,filepath,true);
            emit done( url, filepath );
        } else {
            QString message = "file did not download";
            emit error( url, filepath, message );

        }
        reply->deleteLater();
    });
}

