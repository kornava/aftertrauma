#include "cachedmediasource.h"
#include <QMediaPlayer>
#include <QDebug>
#include <QFile>
#include <QNetworkReply>

#include "systemutils.h"
#include "networkaccess.h"
#include "cachedtee.h"

CachedMediaSource::CachedMediaSource(QQuickItem *parent) : QQuickItem(parent) {
}
//
//
//
void CachedMediaSource::setUrl( const QString url ) {
    m_url = url;
    setMediaSource();
}
void CachedMediaSource::setPlayer( const QVariant player ) {
    qDebug() << "CachedMediaSource::setPlayer : " << player;
    m_player = player;
    setMediaSource();
}
//
//
//
void CachedMediaSource::play() {
    QMediaPlayer *player = getPlayer();
    if ( player ) {
        player->play();
    }
}

void CachedMediaSource::pause() {
    QMediaPlayer *player = getPlayer();
    if ( player ) {
        player->pause();
    }
}
//
//
//
void CachedMediaSource::setMediaSource() {
    if ( m_url.length() > 0 && !m_player.isNull() ) {
        QMediaPlayer *player = getPlayer();
        if ( player ) {
            //
            // TODO: check for media in cache
            //
            qDebug() << "CachedMediaSource::setMediaSource : got player";
            QUrl url( m_url );
            QString fileName = url.fileName();
            QString localPath = SystemUtils::shared()->documentDirectory().append("/media/").append(fileName);
            if ( QFile::exists(localPath) ) {
                qDebug() << "CachedMediaSource::setMediaSource : playing local file : " << localPath;
                player->setMedia(QUrl::fromLocalFile(localPath));
            } else {
                qDebug() << "CachedMediaSource::setMediaSource : unable to find local file : " << localPath;
                //
                // create tee
                //
                QMediaContent content( url );
                QFile* output = new QFile( localPath );
                if ( output->open(QFile::WriteOnly) ) {
                    QNetworkReply* input = NetworkAccess::shared()->get(url);
                    if ( input ) {
                        //
                        // TODO: replace tee with downloader or get setMedia to accept tee as input
                        //
                        CachedTee* tee = new CachedTee; // TODO: where is this deleted
                        connect( tee, &CachedTee::aboutToClose,[tee]() {
                            qDebug() << "CachedTee::aboutToClose";
                            tee->deleteLater();
                        });
                        //
                        //
                        //
                        connect( input, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),[tee,localPath](QNetworkReply::NetworkError code) {
                            qDebug() << "QNetworkReply::error : " << code;
                            //
                            // close tee
                            //
                            tee->close();
                            //
                            // delete local file
                            //
                            QFile::remove(localPath);
                        });
                        connect( input, &QNetworkReply::finished,[tee]() {
                            qDebug() << "QNetworkReply::finished";
                            tee->close();
                        });
                        tee->setup(input,output);
                        tee->open(CachedTee::ReadOnly);
                        player->setMedia(content,tee);
                    } else {
                        output->close();
                        output->deleteLater();
                    }
                }
            }
        }
    }
}

QMediaPlayer* CachedMediaSource::getPlayer() {
    QMediaPlayer* player = nullptr;
    if ( !m_player.isNull() ) {
        QObject* playerObject = m_player.value<QObject*>();
        if ( playerObject ) {
            player =  qvariant_cast<QMediaPlayer *>(playerObject->property("mediaObject"));
        }
    }
    return player;
}

