#include "ck_property.hpp"
#include <contextproperty.h>

namespace ContextKitQml
{

Property::Property(QObject* parent) :
    QObject(parent),
    subscribed(true)
{
}

Property::~Property()
{
}

QString Property::key() const
{
    return prop ? prop->key() : QString("");
}

void Property::onValueChanged()
{
    valueChanged();
}

void Property::setKey(QString const& key)
{
    if (!prop || prop->key() != key)
        prop.reset(new ContextProperty(key));

    if (!subscribed)
        prop->unsubscribe();

    connect(prop.data(), SIGNAL(valueChanged()), SLOT(onValueChanged()));
    auto v = value();
    if (v != default_value)
        emit valueChanged();
}

void Property::setDefaultValue(QVariant const& value)
{
    default_value = value;
}

bool Property::isSubscribed() const
{
    return subscribed;
}

void Property::setSubscribed(bool subscribed)
{
    if (subscribed != this->subscribed) {
        if (prop) {
            if (subscribed)
                prop->subscribe();
            else
                prop->unsubscribe();
        }

        this->subscribed = subscribed;
        emit subscribedChanged();
    }
}

void Property::subscribe()
{
    setSubscribed(true);
}

void Property::unsubscribe()
{
    setSubscribed(false);
}

QVariant Property::value() const
{
    if (prop) {
        //prop->waitForSubscription();
        return prop->value(default_value);
    } else {
        return default_value;
    }
}

}
