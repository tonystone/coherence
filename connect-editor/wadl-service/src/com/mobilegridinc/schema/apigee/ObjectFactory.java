
package com.mobilegridinc.schema.apigee;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.namespace.QName;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the com.mobilegridinc.schema.apigee package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {

    private final static QName _Attachments_QNAME = new QName("http://api.apigee.com/wadl/2010/07/", "attachments");
    private final static QName _Payload_QNAME = new QName("http://api.apigee.com/wadl/2010/07/", "payload");
    private final static QName _Choice_QNAME = new QName("http://api.apigee.com/wadl/2010/07/", "choice");
    private final static QName _Tags_QNAME = new QName("http://api.apigee.com/wadl/2010/07/", "tags");
    private final static QName _Authentication_QNAME = new QName("http://api.apigee.com/wadl/2010/07/", "authentication");
    private final static QName _Example_QNAME = new QName("http://api.apigee.com/wadl/2010/07/", "example");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: com.mobilegridinc.schema.apigee
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link AttachmentsType }
     * 
     */
    public AttachmentsType createAttachmentsType() {
        return new AttachmentsType();
    }

    /**
     * Create an instance of {@link PayloadType }
     * 
     */
    public PayloadType createPayloadType() {
        return new PayloadType();
    }

    /**
     * Create an instance of {@link ChoiceType }
     * 
     */
    public ChoiceType createChoiceType() {
        return new ChoiceType();
    }

    /**
     * Create an instance of {@link TagsType }
     * 
     */
    public TagsType createTagsType() {
        return new TagsType();
    }

    /**
     * Create an instance of {@link AuthenticationType }
     * 
     */
    public AuthenticationType createAuthenticationType() {
        return new AuthenticationType();
    }

    /**
     * Create an instance of {@link ExampleType }
     * 
     */
    public ExampleType createExampleType() {
        return new ExampleType();
    }

    /**
     * Create an instance of {@link Attachment }
     * 
     */
    public Attachment createAttachment() {
        return new Attachment();
    }

    /**
     * Create an instance of {@link TagType }
     * 
     */
    public TagType createTagType() {
        return new TagType();
    }

    /**
     * Create an instance of {@link Include }
     * 
     */
    public Include createInclude() {
        return new Include();
    }

    /**
     * Create an instance of {@link Doc }
     * 
     */
    public Doc createDoc() {
        return new Doc();
    }

    /**
     * Create an instance of {@link Request }
     * 
     */
    public Request createRequest() {
        return new Request();
    }

    /**
     * Create an instance of {@link Param }
     * 
     */
    public Param createParam() {
        return new Param();
    }

    /**
     * Create an instance of {@link Option }
     * 
     */
    public Option createOption() {
        return new Option();
    }

    /**
     * Create an instance of {@link Link }
     * 
     */
    public Link createLink() {
        return new Link();
    }

    /**
     * Create an instance of {@link Representation }
     * 
     */
    public Representation createRepresentation() {
        return new Representation();
    }

    /**
     * Create an instance of {@link Method }
     * 
     */
    public Method createMethod() {
        return new Method();
    }

    /**
     * Create an instance of {@link Response }
     * 
     */
    public Response createResponse() {
        return new Response();
    }

    /**
     * Create an instance of {@link Resource }
     * 
     */
    public Resource createResource() {
        return new Resource();
    }

    /**
     * Create an instance of {@link ResourceType }
     * 
     */
    public ResourceType createResourceType() {
        return new ResourceType();
    }

    /**
     * Create an instance of {@link Resources }
     * 
     */
    public Resources createResources() {
        return new Resources();
    }

    /**
     * Create an instance of {@link Application }
     * 
     */
    public Application createApplication() {
        return new Application();
    }

    /**
     * Create an instance of {@link Grammars }
     * 
     */
    public Grammars createGrammars() {
        return new Grammars();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link AttachmentsType }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://api.apigee.com/wadl/2010/07/", name = "attachments")
    public JAXBElement<AttachmentsType> createAttachments(AttachmentsType value) {
        return new JAXBElement<AttachmentsType>(_Attachments_QNAME, AttachmentsType.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link PayloadType }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://api.apigee.com/wadl/2010/07/", name = "payload")
    public JAXBElement<PayloadType> createPayload(PayloadType value) {
        return new JAXBElement<PayloadType>(_Payload_QNAME, PayloadType.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ChoiceType }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://api.apigee.com/wadl/2010/07/", name = "choice")
    public JAXBElement<ChoiceType> createChoice(ChoiceType value) {
        return new JAXBElement<ChoiceType>(_Choice_QNAME, ChoiceType.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link TagsType }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://api.apigee.com/wadl/2010/07/", name = "tags")
    public JAXBElement<TagsType> createTags(TagsType value) {
        return new JAXBElement<TagsType>(_Tags_QNAME, TagsType.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link AuthenticationType }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://api.apigee.com/wadl/2010/07/", name = "authentication")
    public JAXBElement<AuthenticationType> createAuthentication(AuthenticationType value) {
        return new JAXBElement<AuthenticationType>(_Authentication_QNAME, AuthenticationType.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link ExampleType }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://api.apigee.com/wadl/2010/07/", name = "example")
    public JAXBElement<ExampleType> createExample(ExampleType value) {
        return new JAXBElement<ExampleType>(_Example_QNAME, ExampleType.class, null, value);
    }

}
