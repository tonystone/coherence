//
//  MGConnectEntityActionDefinition.h
//  Connect
//
//  Created by Tony Stone on 5/7/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectEntityAction.h"

/*
 
     We have the following requirements
     
     1) Mapping JSON for an object to the local representation
     
     Mapping can be an indipendent Operation per object type (create a mapping class.
     
     2) Identifying a local object by it's remote unique ID
     3) determining the path to use to fill a fault
     4) determining the path to use to refresh an object
     5) determining the path to use to update, delete or insert an object
     6) Allow definition of other actions like start, stop, duplicate, etc.
 
 */

/*
     Example 1 (www.rightscale.com model):
 
      Model
 
        Resource
            NSString * resourceID;
            NSString * name;
            NSString * textDescription;
            NSSet    * tags;

        Cloud : Resoruce
            NSString * type;

        Deployment : Resource
            NSSet    * inputs;
            NSSet    * servers;
            NSSet    * serverArrays;

        Server : Resource
            NSNumber * state;
            NSNumber * stateSection;

            Cloud      * cloud;
            Deployment * deployment;

            ServerInstance * nextInstance;
            ServerInstance * currentInstance;
            ServerTemplate * serverTemplate;


        ServerArray : Resource
            NSString * arrayType;
            NSNumber * instanceCount;
            NSNumber * enabled;
            NSString * state;

        ServerTemplate      * serverTemplate;
            ServerArrayInstance * nextInstance;
            NSSet               * currentInstances;

        Instance : Resource
            NSNumber * state;
            NSDate   * launchedAt;
            NSDate   * terminatedAt;
            NSString * osPlatform;
            NSString * pricingType;
            NSString * price;

        MonitoringMetrics * monitoringMetrics;
            MultiCloudImage   * multiCloudImage;
            ServerTemplate    * serverTemplate;
            InstanceType      * instanceType;
            Datacenter        * datacenter;
            Cloud             * cloud;

        ServerInstance : Instance
            Server * parent;

        ServerArrayInstance : Instance
            ServerArray * parent;

        Tag : Resource
            NSNumber * position;

        
    Action Definitions
 
    list = gets parent object or nil if no parent
    CRUD = get object
 
     CloudActionDefinition
 
        list  = GET: /api/clouds
        read  = GET: /api/clouds/<resourceID>
 
        remoteID: @"lastPathComponent(links/link[@rel='self']/@href)"
        root: /clouds/cloud
 
        KeyPath (CoreData)      Value (xPath)
        ----------------------  ----------------                       
        @"name":                @"name"
        @"type":                @"type"
 
     ServerActionDefinition

        list                 = GET: /api/servers
        read                 = GET: /api/servers/<self.remoteID>
        launch               = GET: /api/servers/<self.remoteID>/launch
        terminate            = GET: /api/servers/<self.remoteID>/terminate
        relaunch             = GET: /api/servers/<self.remoteID>/relaunch
        duplicate            = GET: /api/servers/<self.remoteID>/duplicate
         
        root: /servers/server
        remoteID: @"lastPathComponent(links/link[@rel='self']/@href)"
        
        Map
        
        KeyPath (CoreData)         Value (xPath)
        ----------------------     ----------------                       
        @"name":                    @"name"
        @"stateName":               @"state"
        @"textDescription":         @"description"
        @"createdAt":               @"dateTime(created_at,'yyyy/MM/dd HH:mm:ss Z')"
        @"updatedAt":               @"dateTime(updated_at,'yyyy/MM/dd HH:mm:ss Z')"

        @cloud":                    @"object(lastPathComponent(links/link[@rel='cloud']/@href))"
        @"deployment":              @"object(lastPathComponent(links/link[@rel='deployment']/@href))"
        @"currentInstance":         @"object(lastPathComponent(links/link[@rel='current_instance']/@href))"
        @"nextInstancee":           @"object(lastPathComponent(links/link[@rel='next_instance']/@href))"
 
        InMessage 
 
        Parameter                                   KeyPath (CoreData)
        ----------------------                      ----------------
        @"server[name]":                            @"<name>"
        @"server[deployment_href]":                 @"/api/deployments/<deployment.resourceID>"
        @"server[description]":                     @"<textDescription>"
        @"server[instance][cloud_href]":            @"/api/clouds/<cloud.resourceID>"
        @"server[instance][server_template_href]":  @"/api/server_templates/<serverTemplate.resourceID>"

     DeploymentActionDefinition
 
        list        = GET: /api/deployments
        read        = GET: /api/deployments/<remoteID>
        launch      = GET: /api/deployments/<self.remoteID>/launch
        terminate   = GET: /api/deployments/<self.remoteID>/terminate
        relaunch    = GET: /api/deployments/<self.remoteID>/relaunch
        duplicate   = GET: /api/deployments/<self.remoteID>/duplicate
 
        root: /servers/server
        remoteID: @"lastPathComponent(links/link[@rel='self']/@href)"
 
        KeyPath (CoreData)         Value (xPath)
        ----------------------     ----------------                       
        @"name":                    @"name"
        @"textDescription":         @"description"
 
    ServerInstanceActionDifinition
 
        list = GET: /api/clouds/<cloud.remoteID>/instances
        read = GET: /api/clouds/<cloud.remoteID>/instances/<remoteID>
 
    ServerTagActionDefinition
 
        list  = GET: /api/tags/by_resource?resource_hrefs[]=</api/servers/<remoteID>
 
        root: /resource_tags/resource_tag/tags/tag
        remoteID: @"name"

        KeyPath (CoreData)         Value (xPath)
        ----------------------     ----------------
        @"name":                    @"name"
 
    DeploymentTagActionDefinition
 
        list      = GET: /api/tags/by_resource?resource_hrefs[]=</api/deployments/<remoteID>
        insert    = POST: /api/tags/multi_add?resource_hrefs[]=<????>&tags[]=/api/tags/<resourceID>
        delete    = POST: /api/tags/multi_delete?resource_hrefs[]=<???>&tags[]=/api/tags/<resourceID>
 
        root: /resource_tags/resource_tag/tags/tag
        remoteID: @"name"

        KeyPath (CoreData)         Value (xPath)
        ----------------------     ----------------
        @"name":                   @"name"
 
 */

/*
 
 
         MGObjectMapper * serverMapper = [MGXmlObjectMapper
                                        mapperWithRootXPath: @"/servers/server" 
                                        elementMappers: @[
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @"name"              xpath: @"name"],
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @"stateName":        xpath: @"state"],
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @"textDescription":  xpath: @"description"],
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @"createdAt":        xpath: @"dateTime(created_at,'yyyy/MM/dd HH:mm:ss Z')"],
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @"updatedAt":        xpath: @"dateTime(updated_at,'yyyy/MM/dd HH:mm:ss Z')"],
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @cloud":             xpath: @"object(lastPathComponent(links/link[@rel='cloud']/@href))"],
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @"deployment":       xpath: @"object(lastPathComponent(links/link[@rel='deployment']/@href))"],
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @"currentInstance":  xpath: @"object(lastPathComponent(links/link[@rel='current_instance']/@href))"],
                                            [MGXmlElementMapper mapperWithTargetKeyPath: @"nextInstancee":    xpath: @"object(lastPathComponent(links/link[@rel='next_instance']/@href))"]
                                        ]
                                    ];
        
        MGObjectMapper * serverInMessage = [MGParameterWriter 
                                                     @"server[name]":                            @"<name>"
                                                     @"server[deployment_href]":                 @"/api/deployments/<deployment.resourceID>"
                                                     @"server[description]":                     @"<textDescription>"
                                                     @"server[instance][cloud_href]":            @"/api/clouds/<cloud.resourceID>"
                                                     @"server[instance][server_template_href]":  @"/api/server_templates/<serverTemplate.resourceID>"
 
        [MGConnect registerEntityAction: [MGEntityAction   listActionWithMethod: @"GET"  location: @"/api/servers"                 inMessage: nil               mapper: serverMapper] forEntityName: @"Server"];
        [MGConnect registerEntityAction: [MGEntityAction   readActionWithMethod: @"GET"  location: @"/api/servers/<self.remoteID>" inMessage: nil               mapper: serverMapper] forEntityName: @"Server"];
        [MGConnect registerEntityAction: [MGEntityAction createActionWithMethod: @"POST" location: @"/api/servers"                 inMessage: serverInMessage]                        forEntityName: @"Server"];
        [MGConnect registerEntityAction: [MGEntityAction customActionWithMethod: @"POST" location: @"/api/servers/<self.remoteID>" inMessage: ]                                       forEntityName: @"Server"];
 
 */

/*
     Example 2:
 
      Model
 
        Company
            NSString * id;
            NSString * name;
            NSSet    * employees;
     
         Emplyee
            NSString * id;
            NSString * employeeID;
            Company  * company;
            Person   * person;
         
         Person
            NSString * id;
            NSString * ssn;
            NSString * firstName;
            NSString * lastName;
            NSSet    * parents;
            NSSet    * children;
 
    Solution to 1:
 
    CompanyAttributeMappingDefintion
 
    root: /companies/company
 
      Key (CoreData)         Value (xPath)
     ---------------------- ----------------
       @"id":                       @"id"
       @"name":                     @"name"
 
    EmployeeAttributeMappingDefinition
 
    root: /employees/employee
 
       Key (CoreData)         Value (xPath)
     ---------------------- ----------------
       @"id":                       @"id"
       @"employeeID":               @"employee_id"
       @"person"                    PersonAttributeMappingDefinition
 
     PersonAttributeMappingDefinition
 
     root: /people/person
 
       Key (CoreData)         Value (xPath)
     ---------------------- ----------------
       @"id":                       @"id"
       @"ssn":                      @"ssn"
       @"firstName":                @"first_name"
       @"lastName":                 @"last_name"
 
 
    Solution to 2, 3, 4, and 5:
 
    CompanyActionDefinition
 
        company.list = GET: /companies
        company.read = GET: /companies/<company.id>
        company.employees.list = GET: /companies/<company.id>/employees
 
    EmployeeActionDefinition
 
        employee.list   = GET: /companies/<company.id>/employees
        employee.read   = GET: /companies/<company.id>/employees/<employee.id>
        employee.insert = GET: /companies/<company.id>/employees
        employee.update = GET: /companies/<company.id>/employees/<employee.id>
        employee.delete = GET: /companies/<company.id>/employees/<employee.id>
 
    PersonActionDefinition
 
        person.list = GET: /companies/<company.id>/employees/<employee.id>/people
        person.read = GET: /companies/<company.id>/employees/<employee.id>/people/<person.id>
 
 
 
 */

/**
 The MGConnectEntityMappingDefinition defines a mapping between
 the return data from a web service and the target object in CoreData.
 */
@protocol MGConnectEntityMappingDefinition <NSObject>

@required

    /**
     The CoreData attribute that represents 
     the unique ID of the remote object.
     */
    - (NSArray *) remoteIDAttributes;

    /**
     The object root of the objects.  The mapping is relative to this root.
     
     Example:
     
        @"/servers/server"
     
     */
    - (NSString *) mappingRoot;

    /**
     
     Key value pairs mapping API result set elements to CoreData model fields
     
     Example:
     
     Server
     
     Key (CoreData)         Value (xPath)
     ---------------------- ----------------
     @{@"name":                       @"name",
       @"stateName":                  @"state",
       @"textDescription":            @"description",
       @"createdAt":                  @"dateTime(created_at,'yyyy/MM/dd HH:mm:ss Z')",
       @"updatedAt":                  @"dateTime(updated_at,'yyyy/MM/dd HH:mm:ss Z')",
       @"resourceReference":          @"links/link[@rel='self']/@href",
       @"deploymentReference":        @"links/link[@rel='deployment']/@href",
       @"currentInstanceReference":   @"links/link[@rel='current_instance']/@href",
       @"nextInstanceReference":      @"links/link[@rel='next_instance']/@href", 
       nil}
     
     Key (CoreData)         Value (keyPath)
     ---------------------- ----------------
     
     @{@"name":                       @"name",
       @"stateName":                  @"state",
       @"textDescription":            @"description",
       @"createdAt":                  @"created_at",
       @"updatedAt":                  @"updated_at",
       @"resourceReference":          @"links.object.href",
       @"deploymentReference":        @"links.deployment.href",
       @"currentInstanceReference":   @"links.current_instance.href",
       @"nextInstanceReference":      @"links.next_instance.href",
       nil}
     
     */
    - (NSDictionary *) mapping;

@end

/**
 Main protocol to define an MGConnectEntityAction
 
 */
@protocol MGConnectEntityActionDefinition <MGConnectEntityMappingDefinition>

@end

/*
 XML Example Data
 
 <?xml version="1.0" encoding="UTF-8"?>
<servers>
  <server>
    <links>
      <link rel="self" href="/api/servers/9"/>
      <link rel="deployment" href="/api/deployments/78"/>
      <link rel="current_instance" href="/api/clouds/668087126/instances/ABC373511836DEF"/>
      <link rel="next_instance" href="/api/clouds/668087126/instances/EOBLAVRJAMRO7"/>
      <link rel="alert_specs" href="/api/servers/9/alert_specs"/>
    </links>
    <current_instance>
      <private_ip_addresses>
        <private_ip_address>0.6.8.9</private_ip_address>
      </private_ip_addresses>
      <links>
        <link rel="self" href="/api/clouds/668087126/instances/ABC373511836DEF"/>
        <link rel="cloud" href="/api/clouds/668087126"/>
        <link rel="deployment" href="/api/deployments/78"/>
        <link rel="server_template" href="/api/server_templates/22"/>
        <link rel="multi_cloud_image" inherited_source="server_template" href="/api/multi_cloud_images/14"/>
        <link rel="parent" href="/api/servers/9"/>
        <link rel="volume_attachments" href="/api/clouds/668087126/instances/ABC373511836DEF/volume_attachments"/>
        <link rel="inputs" href="/api/clouds/668087126/instances/ABC373511836DEF/inputs"/>
        <link rel="monitoring_metrics" href="/api/clouds/668087126/instances/ABC373511836DEF/monitoring_metrics"/>
      </links>
      <state>operational</state>
      <resource_uid>resource_3541155111</resource_uid>
      <created_at>2013/03/20 22:47:50 +0000</created_at>
      <actions>
        <action rel="terminate"/>
        <action rel="reboot"/>
        <action rel="run_executable"/>
      </actions>
      <updated_at>2013/03/20 22:47:50 +0000</updated_at>
      <name>name_3196160295</name>
      <pricing_type>fixed</pricing_type>
      <public_ip_addresses>
        <public_ip_address>217.251.97.204</public_ip_address>
      </public_ip_addresses>
    </current_instance>
    <state>operational</state>
    <description>description_2072138007</description>
    <next_instance>
      <private_ip_addresses></private_ip_addresses>
      <links>
        <link rel="self" href="/api/clouds/668087126/instances/EOBLAVRJAMRO7"/>
        <link rel="cloud" href="/api/clouds/668087126"/>
        <link rel="deployment" href="/api/deployments/78"/>
        <link rel="server_template" href="/api/server_templates/22"/>
        <link rel="multi_cloud_image" inherited_source="server_template" href="/api/multi_cloud_images/14"/>
        <link rel="parent" href="/api/servers/9"/>
        <link rel="volume_attachments" href="/api/clouds/668087126/instances/EOBLAVRJAMRO7/volume_attachments"/>
        <link rel="inputs" href="/api/clouds/668087126/instances/EOBLAVRJAMRO7/inputs"/>
        <link rel="monitoring_metrics" href="/api/clouds/668087126/instances/EOBLAVRJAMRO7/monitoring_metrics"/>
      </links>
      <state>inactive</state>
      <resource_uid>309d18d0-91b0-11e2-a4e1-58b035ef95ec</resource_uid>
      <created_at>2013/03/20 22:47:49 +0000</created_at>
      <actions></actions>
      <updated_at>2013/03/20 22:47:49 +0000</updated_at>
      <name>name_2852752682</name>
      <pricing_type>default</pricing_type>
      <public_ip_addresses></public_ip_addresses>
    </next_instance>
    <created_at>2013/03/20 22:47:49 +0000</created_at>
    <actions>
      <action rel="terminate"/>
      <action rel="clone"/>
    </actions>
    <updated_at>2013/03/20 22:47:50 +0000</updated_at>
    <name>name_2852752682</name>
  </server>
  <server>
    <links>
      <link rel="self" href="/api/servers/11"/>
      <link rel="deployment" href="/api/deployments/83"/>
      <link rel="current_instance" href="/api/clouds/673318817/instances/ABC1859069796DEF"/>
      <link rel="next_instance" href="/api/clouds/673318817/instances/2F9QC38KCGDE5"/>
      <link rel="alert_specs" href="/api/servers/11/alert_specs"/>
    </links>
    <current_instance>
      <private_ip_addresses>
        <private_ip_address>3.4.9.3</private_ip_address>
      </private_ip_addresses>
      <links>
        <link rel="self" href="/api/clouds/673318817/instances/ABC1859069796DEF"/>
        <link rel="cloud" href="/api/clouds/673318817"/>
        <link rel="deployment" href="/api/deployments/83"/>
        <link rel="server_template" href="/api/server_templates/26"/>
        <link rel="multi_cloud_image" inherited_source="server_template" href="/api/multi_cloud_images/16"/>
        <link rel="parent" href="/api/servers/11"/>
        <link rel="volume_attachments" href="/api/clouds/673318817/instances/ABC1859069796DEF/volume_attachments"/>
        <link rel="inputs" href="/api/clouds/673318817/instances/ABC1859069796DEF/inputs"/>
        <link rel="monitoring_metrics" href="/api/clouds/673318817/instances/ABC1859069796DEF/monitoring_metrics"/>
      </links>
      <state>operational</state>
      <resource_uid>resource_1073623723</resource_uid>
      <created_at>2013/03/20 22:47:54 +0000</created_at>
      <actions>
        <action rel="terminate"/>
        <action rel="reboot"/>
        <action rel="run_executable"/>
      </actions>
      <updated_at>2013/03/20 22:47:54 +0000</updated_at>
      <name>name_2264515513</name>
      <pricing_type>fixed</pricing_type>
      <public_ip_addresses>
        <public_ip_address>168.98.88.240</public_ip_address>
      </public_ip_addresses>
    </current_instance>
    <state>operational</state>
    <description>description_1676990309</description>
    <next_instance>
      <private_ip_addresses></private_ip_addresses>
      <links>
        <link rel="self" href="/api/clouds/673318817/instances/2F9QC38KCGDE5"/>
        <link rel="cloud" href="/api/clouds/673318817"/>
        <link rel="deployment" href="/api/deployments/83"/>
        <link rel="server_template" href="/api/server_templates/26"/>
        <link rel="multi_cloud_image" inherited_source="server_template" href="/api/multi_cloud_images/16"/>
        <link rel="parent" href="/api/servers/11"/>
        <link rel="volume_attachments" href="/api/clouds/673318817/instances/2F9QC38KCGDE5/volume_attachments"/>
        <link rel="inputs" href="/api/clouds/673318817/instances/2F9QC38KCGDE5/inputs"/>
        <link rel="monitoring_metrics" href="/api/clouds/673318817/instances/2F9QC38KCGDE5/monitoring_metrics"/>
      </links>
      <state>inactive</state>
      <resource_uid>337755a2-91b0-11e2-a4e1-58b035ef95ec</resource_uid>
      <created_at>2013/03/20 22:47:53 +0000</created_at>
      <actions></actions>
      <updated_at>2013/03/20 22:47:53 +0000</updated_at>
      <name>name_2699466021</name>
      <pricing_type>default</pricing_type>
      <public_ip_addresses></public_ip_addresses>
    </next_instance>
    <created_at>2013/03/20 22:47:53 +0000</created_at>
    <actions>
      <action rel="terminate"/>
      <action rel="clone"/>
    </actions>
    <updated_at>2013/03/20 22:47:54 +0000</updated_at>
    <name>name_2699466021</name>
  </server>
</servers>
 
 
 */
