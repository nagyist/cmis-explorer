## CMIS Explorer w/Adobe AIR ##

### Flex Builder Project ###

I decided to check-in all of the Flex Builder project files. I'm not aware of a basic FB project archetype for Maven at this time. I did come across one for Flex libraries and another for BlazeDS, but not one that generates an FB project for the AIR runtime. If there is one out there, please feel free to let me know. That being said, I did check in a POM so that CMIS Explorer can be packaged using Maven.

**Update (03/02/09)** - I have moved the CMIS services (ATOM) client to a separate Flex library project (FlexCMIS). That project is also available on Google Code [here](http://code.google.com/p/flex-cmis-client/).

If you are using Flex Builder then you will have to import that project too. The FlexCMIS project is on the library path of the CMIS Explorer project.

### Configuring Maven ###

There are 3 properties that have to be set in a Maven profile.

  * Flex SDK Home
  * Certificate
  * Certificate Password

Here is an example settings.xml file that belong in your Maven Home (.m2) directory.

```
<settings>
  <profiles>
    <profile>
      <id>air</id>
      <properties>
        <flex.sdk.home>/path/to/air/sdks/3.0.0</flex.sdk.home>
        <cert.file.path>/path/to/certs/me.p12</cert.file.path>
        <cert.pass>password</cert.pass>
      </properties>
    </profile>
  </profiles>
  <activeProfiles>
    <activeProfile>air</activeProfile>
  </activeProfiles>
</settings>
```

If you are packaging CMIS Explorer using Maven, you will have to package and install FlexCMIS first. It is defined in the CMIS Explorer POM as a dependency.

### MVC Framework ###

I'm not using an MVC framework at this time. However, I am considering [Mate](http://mate.asfusion.com/).

### Blog Posts ###

Here are some blog posts where I have discussed the CMIS Explorer and/or the CMIS specification.

[CMIS Specification (Highlights)](http://blogs.citytechinc.com/sjohnson/?p=27)<br>
<a href='http://blogs.citytechinc.com/sjohnson/?p=56'>Flex/AIR, CMIS, &amp; Alfresco</a><br>
<a href='http://blogs.citytechinc.com/sjohnson/?p=57'>Alfresco Code Camp : Chicago - Complete</a><br>
<a href='http://blogs.citytechinc.com/sjohnson/?p=60'>CMIS Explorer - Download</a><br>
<a href='http://blogs.citytechinc.com/sjohnson/?p=79'>Alfresco Tech Talk - CMIS</a>