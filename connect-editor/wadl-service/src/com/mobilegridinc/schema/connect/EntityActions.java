
package com.mobilegridinc.schema.connect;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for EntityActions.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="EntityActions">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}token">
 *     &lt;enumeration value="LIST"/>
 *     &lt;enumeration value="READ"/>
 *     &lt;enumeration value="INSERT"/>
 *     &lt;enumeration value="UPDATE"/>
 *     &lt;enumeration value="DELETE"/>
 *     &lt;enumeration value="CUSTOM"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "EntityActions", namespace = "http://www.mobilegridinc.com/schemas/connect/v1")
@XmlEnum
public enum EntityActions {

    LIST,
    READ,
    INSERT,
    UPDATE,
    DELETE,
    CUSTOM;

    public String value() {
        return name();
    }

    public static EntityActions fromValue(String v) {
        return valueOf(v);
    }

}
