#ifndef IMAGEUPLOADER_H
#define IMAGEUPLOADER_H

#include <QObject>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QHttpMultiPart>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QString>

class ImageUploader : public QObject
{
    Q_OBJECT
public:
    explicit ImageUploader(QObject *parent = nullptr);

signals:
    // errorCode = -1 : start image uploading
    // 0 : success
    // >0: error
    void imageUploaded(int errorCode, const QString& errorMessage);

public slots:
    void uploadImage(const QString& imageFilename, const QString &token);

private slots:
    void uploadImageFinished();

private:
    QNetworkAccessManager* m_networkAccessManager;
    QNetworkReply* m_networkReply;
};

#endif // IMAGEUPLOADER_H
