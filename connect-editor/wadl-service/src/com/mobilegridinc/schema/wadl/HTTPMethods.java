
package com.mobilegridinc.schema.wadl;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for HTTPMethods.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="HTTPMethods">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *     &lt;enumeration value="GET"/>
 *     &lt;enumeration value="POST"/>
 *     &lt;enumeration value="PUT"/>
 *     &lt;enumeration value="HEAD"/>
 *     &lt;enumeration value="DELETE"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "HTTPMethods", namespace = "http://wadl.dev.java.net/2009/02")
@XmlEnum
public enum HTTPMethods {

    GET,
    POST,
    PUT,
    HEAD,
    DELETE;

    public String value() {
        return name();
    }

    public static HTTPMethods fromValue(String v) {
        return valueOf(v);
    }

}
