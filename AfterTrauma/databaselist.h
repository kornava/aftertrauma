#ifndef DATABASELIST_H
#define DATABASELIST_H

#include <QAbstractListModel>
#include <QList>
#include <QVariant>
#include <QVariantMap>

class DatabaseList : public QAbstractListModel
{
    Q_OBJECT
    //
    //
    //
    Q_PROPERTY(QString collection WRITE setCollection MEMBER m_collection NOTIFY collectionChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QStringList roles MEMBER m_roles )
    Q_PROPERTY(QVariantMap sort MEMBER m_sort )
    Q_PROPERTY(QVariantMap filter MEMBER m_filter )
    //
    //
    //
public:
    explicit DatabaseList(QObject *parent = 0);
    //
    //
    //

    //
    // QAbstractListModel overrides
    //
    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    //
    //
    //
    void setCollection( QString collection );
signals:
    //
    //
    //
    void collectionChanged();
    void countChanged();
    void sortChanged();
    void error(QString operation,QString error);
    //
    //
    //
    void syncStart();
    void syncProgress(double complete,double total);
    void syncDone();
    //
    //
    //
public slots:
    //
    //
    //
    void load();
    void save();
    //
    //
    //
    void clear();
    QVariant add(QVariant o);
    QVariant update(QVariant q,QVariant u,bool upsert = false);
    QVariant remove(QVariant q);
    QVariant find(QVariant q);
    QVariant findOne(QVariant q);
    QVariant get(int i);
    // TODO:
    //void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override { };
    //void sort(QVariant s);
    void filter(QVariant f);
    //
    //
    //
    void beginBatch();
    QVariant batchAdd(QVariant o);
    void endBatch();
    //
    //
    //
    void sync( QString url );
    //
    //
    //
private slots:
    //
    //
    //
private:
    QString             m_collection;
    QStringList         m_roles;
    QVariantMap         m_sort;
    QVariantMap         m_filter;
    QList<QVariantMap>  m_objects;
    QList<QVariantMap>  m_filtered;
    QList<QVariantMap>& m_activeList;
    //
    //
    //
    void _sort();
    void _filter();
    bool _match( QVariantMap& object, QVariantMap& query );
    void _update( QVariantMap& object, QVariantMap& update );
    QString _path();
};

#endif // DATABASELIST_H
