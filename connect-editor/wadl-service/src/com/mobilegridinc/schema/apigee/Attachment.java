
package com.mobilegridinc.schema.apigee;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for attachment complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="attachment">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{http://wadl.dev.java.net/2009/02}doc" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="href" type="{http://www.w3.org/2001/XMLSchema}anyURI" />
 *       &lt;attribute name="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="contentType" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="contentDisposition" type="{http://www.w3.org/2001/XMLSchema}string" default="form-data" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "attachment", namespace = "http://api.apigee.com/wadl/2010/07/", propOrder = {
    "doc"
})
public class Attachment {

    @XmlElement(namespace = "http://wadl.dev.java.net/2009/02")
    protected List<Doc> doc;
    @XmlAttribute(name = "name")
    protected String name;
    @XmlAttribute(name = "href")
    @XmlSchemaType(name = "anyURI")
    protected String href;
    @XmlAttribute(name = "required")
    protected Boolean required;
    @XmlAttribute(name = "contentType")
    protected String contentType;
    @XmlAttribute(name = "contentDisposition")
    protected String contentDisposition;

    /**
     * Gets the value of the doc property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the doc property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getDoc().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Doc }
     * 
     * 
     */
    public List<Doc> getDoc() {
        if (doc == null) {
            doc = new ArrayList<Doc>();
        }
        return this.doc;
    }

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Gets the value of the href property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getHref() {
        return href;
    }

    /**
     * Sets the value of the href property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setHref(String value) {
        this.href = value;
    }

    /**
     * Gets the value of the required property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isRequired() {
        return required;
    }

    /**
     * Sets the value of the required property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setRequired(Boolean value) {
        this.required = value;
    }

    /**
     * Gets the value of the contentType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getContentType() {
        return contentType;
    }

    /**
     * Sets the value of the contentType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setContentType(String value) {
        this.contentType = value;
    }

    /**
     * Gets the value of the contentDisposition property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getContentDisposition() {
        if (contentDisposition == null) {
            return "form-data";
        } else {
            return contentDisposition;
        }
    }

    /**
     * Sets the value of the contentDisposition property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setContentDisposition(String value) {
        this.contentDisposition = value;
    }

}
