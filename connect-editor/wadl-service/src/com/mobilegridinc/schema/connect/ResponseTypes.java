
package com.mobilegridinc.schema.connect;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ResponseTypes.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="ResponseTypes">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}token">
 *     &lt;enumeration value="resource"/>
 *     &lt;enumeration value="container"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "ResponseTypes", namespace = "http://www.mobilegridinc.com/schemas/connect/v1")
@XmlEnum
public enum ResponseTypes {

    @XmlEnumValue("resource")
    RESOURCE("resource"),
    @XmlEnumValue("container")
    CONTAINER("container");
    private final String value;

    ResponseTypes(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static ResponseTypes fromValue(String v) {
        for (ResponseTypes c: ResponseTypes.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
