#include "imageuploader.h"
#include <QJsonObject>
#include <QJsonDocument>

ImageUploader::ImageUploader(QObject *parent)
    : QObject(parent)
    , m_networkAccessManager(nullptr)
    , m_networkReply (nullptr)
{
    m_networkAccessManager = new QNetworkAccessManager(this);
}

void ImageUploader::uploadImage(const QString &imageFilename, const QString &token)
{

    /*QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    QHttpPart textPart;
    textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"text\""));
    textPart.setBody("my text");

    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"image\""));
    QFile *file = new QFile(imageFilename);
    file->open(QIODevice::ReadOnly);
    imagePart.setBodyDevice(file);
    file->setParent(multiPart); // we cannot delete the file now, so delete it with the multiPart

    multiPart->append(textPart);
    multiPart->append(imagePart);

    QUrl url("http://127.0.0.1:8000/api/kootwall/ProductImage");
    QNetworkRequest request(url);

    QString headerData = "Bearer " + token;
    request.setRawHeader("Authorization", headerData.toLocal8Bit());

    QNetworkAccessManager manager;
    QNetworkReply *reply = manager.post(request, multiPart);
    multiPart->setParent(reply); // delete the multiPart with the reply
    // here connect signals etc.

    connect(reply, SIGNAL(finished()), this, SLOT(uploadImageFinished()));*/

    //=========

    /*QNetworkAccessManager *am = new QNetworkAccessManager(this);
    QString path("E:/user.png");
    QNetworkRequest request(QUrl("http://127.0.0.1:8000/api/kootwall/ProductImage")); //our server with php-script

    QString headerData = "Bearer " + token;
    request.setRawHeader("Authorization", headerData.toLocal8Bit());

        QString bound="margin"; //name of the boundary
    //according to rfc 1867 we need to put this string here:
    QByteArray data(QString("--" + bound + "/r/n").toLatin1());
    data.append("Content-Disposition: form-data; name=' action'\r\n\r\n");
    data.append("testuploads.php\r\n"); //our script's name, as I understood. Please, correct me if I'm wrong
    data.append("--" + bound + "\r\n"); //according to rfc 1867
    data.append("Content-Disposition: form-data; name='uploaded'; filename='user.png'\r\n"); //name of the input is "uploaded" in my form, next one is a file name.
    data.append("Content-Type: image/jpeg\r\n\r\n"); //data type
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
    return;
    data.append(file.readAll()); //let's read the file
    data.append("\r\n");
    data.append("--" + bound + "--\r\n"); //closing boundary according to rfc 1867
    request.setRawHeader(QString("Content-Type").toLatin1(),QString("multipart/form-data; boundary=" + bound).toLatin1());
    request.setRawHeader(QString("Content-Length").toLatin1(), QString::number(data.length()).toLatin1());
    m_networkReply = am->post(request,data);
    qDebug() << data.data();
    connect(m_networkReply, SIGNAL(finished()), this, SLOT(uploadImageFinished()));


    return;*/


    //============


    QFileInfo fileInfo(imageFilename);
    QFile* file = new QFile(imageFilename);

    qDebug() << "sending file is " << imageFilename;

    if (!file->open(QIODevice::ReadWrite)) {
        emit imageUploaded(999, "Image not found");
        return;
    }

    emit imageUploaded(-1, "Try to upload image to server, please wait...");

    QHttpMultiPart* multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

    QHttpPart imagePart;
    imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));
    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(QString("form-data; name=\"pic\"; filename=\"%1\"").arg(fileInfo.fileName()).toLatin1()));
//    imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(QString("form-data; name=\"pic\"")));
    imagePart.setBodyDevice(file);
    file->setParent(multiPart);
    multiPart->append(imagePart);

//    QHttpPart textPart;
//    textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"text\""));
//    textPart.setBody("{description:'my descriptions'}");
//    multiPart->append(textPart);


    //----------------

    QNetworkRequest request(QUrl("http://127.0.0.1:8000/api/kootwall/ProductImage"));

//    QString headerData = "Bearer " + token;
//    request.setRawHeader("Authorization", headerData.toLocal8Bit());

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject obj {
        {"description", "tozihat"}
    };

    m_networkReply = m_networkAccessManager->post(request, multiPart);
//    m_networkReply = m_networkAccessManager->post(request, QJsonDocument(obj).toJson());
    multiPart->setParent(m_networkReply);

    connect(m_networkReply, SIGNAL(finished()), this, SLOT(uploadImageFinished()));
}

void ImageUploader::uploadImageFinished()
{
    QString xmlReply = QString(m_networkReply->readAll());
    delete m_networkReply;
    qDebug() << xmlReply;
    // here, you can parse the reply from the server...
    emit imageUploaded(0, "Image successfully uploaded");
}
