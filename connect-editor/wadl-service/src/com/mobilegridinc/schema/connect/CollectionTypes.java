
package com.mobilegridinc.schema.connect;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for CollectionTypes.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="CollectionTypes">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}token">
 *     &lt;enumeration value="ARRAY"/>
 *     &lt;enumeration value="DICTIONARY"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "CollectionTypes", namespace = "http://www.mobilegridinc.com/schemas/connect/v1")
@XmlEnum
public enum CollectionTypes {

    ARRAY,
    DICTIONARY;

    public String value() {
        return name();
    }

    public static CollectionTypes fromValue(String v) {
        return valueOf(v);
    }

}
