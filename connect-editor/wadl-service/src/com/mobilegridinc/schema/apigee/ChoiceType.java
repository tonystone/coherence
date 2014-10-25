
package com.mobilegridinc.schema.apigee;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for choiceType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="choiceType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{http://wadl.dev.java.net/2009/02}param" maxOccurs="unbounded" minOccurs="2"/>
 *       &lt;/sequence>
 *       &lt;attribute name="required" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="countMin" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *       &lt;attribute name="countMax" type="{http://www.w3.org/2001/XMLSchema}integer" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "choiceType", namespace = "http://api.apigee.com/wadl/2010/07/", propOrder = {
    "param"
})
public class ChoiceType {

    @XmlElement(namespace = "http://wadl.dev.java.net/2009/02", required = true)
    protected List<Param> param;
    @XmlAttribute(name = "required")
    protected Boolean required;
    @XmlAttribute(name = "countMin")
    protected BigInteger countMin;
    @XmlAttribute(name = "countMax")
    protected BigInteger countMax;

    /**
     * Gets the value of the param property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the param property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getParam().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Param }
     * 
     * 
     */
    public List<Param> getParam() {
        if (param == null) {
            param = new ArrayList<Param>();
        }
        return this.param;
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
     * Gets the value of the countMin property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getCountMin() {
        return countMin;
    }

    /**
     * Sets the value of the countMin property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setCountMin(BigInteger value) {
        this.countMin = value;
    }

    /**
     * Gets the value of the countMax property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getCountMax() {
        return countMax;
    }

    /**
     * Sets the value of the countMax property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setCountMax(BigInteger value) {
        this.countMax = value;
    }

}
