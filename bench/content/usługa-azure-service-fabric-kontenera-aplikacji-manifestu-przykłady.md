{ "title": "Usługa Azure Service Fabric kontenera aplikacji manifestu przykłady", "date": "2019-01-02" }

# <a name="multi-container-application-and-service-manifest-examples"></a>Przykłady manifestu wielokontenerowej aplikacji i usługi
Poniżej przedstawiono przykłady manifestów aplikacji i usługi dla aplikacji usługi Service Fabric obsługującej wiele kontenerów. Te przykłady ma na celu Pokaż jakie ustawienia są dostępne i jak z nich korzystać. Te manifesty aplikacji i usługi są oparte na [przykład kontenera systemu Windows Server 2016](https://github.com/Azure-Samples/service-fabric-containers/tree/master/Windows) manifestów.

Wyświetlane są następujące funkcje:

|Manifest|Funkcje|
|---|---|
|[Manifest aplikacji](#application-manifest)| [Zastąp zmienne środowiskowe](service-fabric-get-started-containers.md#configure-and-set-environment-variables), [skonfigurowania mapowania kontenera typu port do hosta](service-fabric-get-started-containers.md#configure-container-port-to-host-port-mapping-and-container-to-container-discovery), [Skonfiguruj uwierzytelnianie rejestru kontenerów](service-fabric-get-started-containers.md#configure-container-registry-authentication), [nadzór nad zasobami](service-fabric-resource-governance.md), [Ustawia tryb izolacji](service-fabric-get-started-containers.md#configure-isolation-mode), [Określanie obrazów kontenera specyficzne dla kompilacji systemu operacyjnego](service-fabric-get-started-containers.md#specify-os-build-specific-container-images)| 
|[FrontEndService manifestu usługi](#frontendservice-service-manifest)| [Ustawianie zmiennych środowiskowych](service-fabric-get-started-containers.md#configure-and-set-environment-variables), [konfigurowania punktu końcowego](service-fabric-get-started-containers.md#configure-communication), przekazywania poleceń do kontenera, [zaimportuj certyfikat do kontenera](service-fabric-securing-containers.md)| 
|[BackEndService manifestu usługi](#backendservice-service-manifest)|[Ustawianie zmiennych środowiskowych](service-fabric-get-started-containers.md#configure-and-set-environment-variables), [konfigurowania punktu końcowego](service-fabric-get-started-containers.md#configure-communication), [skonfigurować sterownik woluminu](service-fabric-containers-volume-logging-drivers.md)| 

Zobacz [elementy manifestu aplikacji](#application-manifest-elements), [elementy manifestu usługi FrontEndService](#frontendservice-service-manifest-elements), i [elementy manifestu usługę BackEndService](#backendservice-service-manifest-elements) więcej informacji na temat określonych Elementy XML.

## <a name="application-manifest"></a>Manifest aplikacji

```xml
<?xml version="1.0" encoding="utf-8"?>
<ApplicationManifest ApplicationTypeName="Container.ApplicationType"
                     ApplicationTypeVersion="1.0.0"
                     xmlns="http://schemas.microsoft.com/2011/01/fabric"
                     xmlns:xsd="https://www.w3.org/2001/XMLSchema"
                     xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance">
  <Parameters>
    <Parameter Name="BackEndService_InstanceCount" DefaultValue="-1" />
    <Parameter Name="FrontEndService_InstanceCount" DefaultValue="-1" />
    <Parameter Name="CpuCores" DefaultValue="2" />
    <Parameter Name="BlockIOWeight" DefaultValue="200" />
    <Parameter Name="MaximumIOBandwidth" DefaultValue="1024" />
    <Parameter Name="MemoryReservationInMB" DefaultValue="1024" />
    <Parameter Name="MemorySwapInMB" DefaultValue="4084"/>
    <Parameter Name="MaximumIOps" DefaultValue="20"/>
    <Parameter Name="MemoryFront" DefaultValue="4084" />
    <Parameter Name="MemoryBack" DefaultValue="2048" />
    <Parameter Name="CertThumbprint" DefaultValue=""/>
  </Parameters>
  <!-- Import the ServiceManifest from the ServicePackage. The ServiceManifestName and ServiceManifestVersion 
       should match the Name and Version attributes of the ServiceManifest element defined in the 
       ServiceManifest.xml file. -->
  <ServiceManifestImport>
    <ServiceManifestRef ServiceManifestName="BackEndServicePkg" ServiceManifestVersion="1.0.0" />    
    
    <!-- Policies to be applied to the imported service manifest. -->
    <Policies>
      <!-- Set resource governance at the service package level. -->
      <ServicePackageResourceGovernancePolicy CpuCores="[CpuCores]" MemoryInMB="[MemoryFront]"/>

      <!-- Set resource governance at the code package level. -->
      <ResourceGovernancePolicy CodePackageRef="Code" CpuPercent="10" MemoryInMB="[MemoryFront]" BlockIOWeight="[BlockIOWeight]" MaximumIOBandwidth="[MaximumIOBandwidth]" MaximumIOps="[MaximumIOps]" MemoryReservationInMB="[MemoryReservationInMB]" MemorySwapInMB="[MemorySwapInMB]"/>
      
      <!-- Policies for activating container hosts. -->
      <ContainerHostPolicies CodePackageRef="Code" Isolation="process">
        
        <!-- Credentials for the repository hosting the container image.-->
        <RepositoryCredentials AccountName="sfsamples" Password="ENCRYPTED-PASSWORD" PasswordEncrypted="true"/>
        
        <!-- This binds the port the container is listening on (8905 in this sample) to an endpoint resource named "BackEndServiceTypeEndpoint", which is defined in the service manifest.  -->
        <PortBinding ContainerPort="8905" EndpointRef="BackEndServiceTypeEndpoint"/>
        
        <!-- Configure the Azure Files volume plugin.  Bind the source folder on the host VM or a remote share to the destination folder within the running container. -->
        <Volume Source="azfiles" Destination="c:\VolumeTest\Data" Driver="sfazurefile">
          <!-- Driver options to be passed to driver. The Azure Files volume plugin supports the following driver options:
            shareName (the Azure Files file share that provides the volume for the container), storageAccountName (the Azure storage account
            that contains the Azure Files file share), storageAccountKey (Access key for the Azure storage account that contains the Azure Files file share).
            These three driver options are required. -->
          <DriverOption Name="shareName" Value="" />
          <DriverOption Name="storageAccountName" Value="MY-STORAGE-ACCOUNT-NAME" />
          <DriverOption Name="storageAccountKey" Value="MY-STORAGE-ACCOUNT-KEY" />
        </Volume>
        
        <!-- Windows Server containers may not be compatible across different versions of the OS.  You can specify multiple OS images per container and tag 
        them with the build versions of the OS. Get the build version of the OS by running "winver" at a Windows command prompt. -->
        <ImageOverrides>
          <!-- If the underlying OS is build version 16299 (Windows Server version 1709), Service Fabric picks the container image tagged with Os="16299". -->
          <Image Name="sfsamples.azurecr.io/sfsamples/servicefabricbackendservice_1709" Os="16299" />
          
          <!-- An untagged container image is assumed to work across all versions of the OS and overrides the image specified in the service manifest. -->
          <Image Name="sfsamples.azurecr.io/sfsamples/servicefabricbackendservice_default" />          
        </ImageOverrides>
      </ContainerHostPolicies>
    </Policies>
  </ServiceManifestImport>

  <!-- Policies to be applied to the imported service manifest. -->
  <ServiceManifestImport>
    <ServiceManifestRef ServiceManifestName="FrontEndServicePkg" ServiceManifestVersion="1.0.0" />
    
    <!-- This enables you to provide different values for environment variables when creating a FrontEndService
         Theses environment variables are declared in the FrontEndServiceType service manifest-->
    <EnvironmentOverrides CodePackageRef="Code">
      <EnvironmentVariable Name="BackendServiceName" Value="Container.Application/BackEndService"/>
      <EnvironmentVariable Name="HttpGatewayPort" Value="19080"/>
      <EnvironmentVariable Name="IsContainer" Value="true"/>
    </EnvironmentOverrides>
    
    <!-- This policy maps the  port of the container (80) to the endpoint declared in the service, 
         FrontEndServiceTypeEndpoint which is exposed as port 80 on the host-->    
    <Policies>

      <!-- Set resource governance at the service package level. -->
      <ServicePackageResourceGovernancePolicy CpuCores="[CpuCores]" MemoryInMB="[MemoryBack]"/>

      <!-- Policies for activating container hosts. -->
      <ContainerHostPolicies CodePackageRef="Code" Isolation="process">

        <!-- Credentials for the repository hosting the container image.-->
        <RepositoryCredentials AccountName="sfsamples" Password="ENCRYPTED-PASSWORD" PasswordEncrypted="true"/>

        <!-- Binds an endpoint resource (declared in the service manifest) to the exposed container port. -->
        <PortBinding ContainerPort="80" EndpointRef="FrontEndServiceTypeEndpoint"/>

        <!-- Import a certificate into the container.  The certificate must be installed in the LocalMachine store of all the cluster nodes.
          When the application starts, the runtime reads the certificate and generates a PFX file and password (on Windows) or a PEM file (on Linux).
          The PFX file and password are accessible in the container using the Certificates_ServicePackageName_CodePackageName_CertName_PFX and 
          Certificates_ServicePackageName_CodePackageName_CertName_Password environment variables. The PEM file is accessible in the container using the 
          Certificates_ServicePackageName_CodePackageName_CertName_PEM and Certificates_ServicePackageName_CodePackageName_CertName_PrivateKey environment variables.-->
        <CertificateRef Name="MyCert1" X509StoreName="My" X509FindValue="[CertThumbprint]" />

        <!-- If the certificate is already in PFX or PEM form, you can create a data package inside your application and reference that certificate here. -->
        <CertificateRef Name="MyCert2" DataPackageRef="Data" DataPackageVersion="1.0.0" RelativePath="MyCert2.PFX" Password="ENCRYPTED-PASSWORD" IsPasswordEncrypted="true"/>
      </ContainerHostPolicies>
    </Policies>
  </ServiceManifestImport>
  
  <DefaultServices>
    <!-- The section below creates instances of service types, when an instance of this 
         application type is created. You can also create one or more instances of service type using the 
         ServiceFabric PowerShell module.
         
         The attribute ServiceTypeName below must match the name defined in the imported ServiceManifest.xml file. -->
        
    <Service Name="FrontEndService" >
      <StatelessService ServiceTypeName="FrontEndServiceType" InstanceCount="[FrontEndService_InstanceCount]">
        <SingletonPartition />
      </StatelessService>
    </Service>
        <Service Name="BackEndService" ServicePackageActivationMode="ExclusiveProcess">
      <StatelessService ServiceTypeName="BackEndServiceType" InstanceCount="[BackEndService_InstanceCount]">
        <SingletonPartition />
      </StatelessService>
    </Service>
  </DefaultServices>
</ApplicationManifest>
```

## <a name="frontendservice-service-manifest"></a>FrontEndService manifestu usługi

```xml
<?xml version="1.0" encoding="utf-8"?>
<ServiceManifest Name="FrontEndServicePkg"
                 Version="1.0.0"
                 xmlns="http://schemas.microsoft.com/2011/01/fabric"
                 xmlns:xsd="https://www.w3.org/2001/XMLSchema"
                 xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance">
  <ServiceTypes>
    <!-- This is the name of your ServiceType.
         The UseImplicitHost attribute indicates this is a guest service. -->
    <StatelessServiceType ServiceTypeName="FrontEndServiceType" UseImplicitHost="true" />
  </ServiceTypes>

  <!-- Code package is your service executable. -->
  <CodePackage Name="Code" Version="1.0.0">
    <EntryPoint>
      <ContainerHost>
        <!--The repo and image on https://hub.docker.com or Azure Container Registry. -->
        <ImageName>sfsamples.azurecr.io/sfsamples/servicefabricfrontendservice:v1</ImageName>
      </ContainerHost>
    </EntryPoint>
    <!-- Pass environment variables to your container or exe.  These variables are overridden in the application manifest. -->
    <EnvironmentVariables>
      <EnvironmentVariable Name="BackendServiceName" Value=""/>
      <EnvironmentVariable Name="HttpGatewayPort" Value=""/>
      <EnvironmentVariable Name="IsContainer" Value=""/>
    </EnvironmentVariables>
  </CodePackage>

  <!-- Config package is the contents of the Config directory under PackageRoot that contains an 
       independently-updateable and versioned set of custom configuration settings for your service. -->
  <ConfigPackage Name="Config" Version="1.0.0" />
  
  <!-- Data package is the contents of the Data directory under PackageRoot that contains an 
       independently-updateable and versioned static data that's consumed by the process at runtime. -->
  <DataPackage Name="Data" Version="1.0.0"/>

  <Resources>
    <Endpoints>
      <!-- This endpoint is used by the communication listener to obtain the port on which to 
           listen. For a guest executable is used to register with the NamingService at its REST endpoint
           with http scheme and port 80 -->
      <Endpoint Name="FrontEndServiceTypeEndpoint" UriScheme="http" Port="80"/>
    </Endpoints>
  </Resources>
</ServiceManifest>
```

## <a name="backendservice-service-manifest"></a>BackEndService manifestu usługi

```xml
<?xml version="1.0" encoding="utf-8"?>
<ServiceManifest Name="BackEndServicePkg"
                 Version="1.0.0"
                 xmlns="http://schemas.microsoft.com/2011/01/fabric"
                 xmlns:xsd="https://www.w3.org/2001/XMLSchema"
                 xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance">
  <ServiceTypes>
    <!-- This is the name of your ServiceType.
         The UseImplicitHost attribute indicates this is a guest service. -->
    <StatelessServiceType ServiceTypeName="BackEndServiceType" UseImplicitHost="true" />
  </ServiceTypes>

  <!-- Code package is your service executable. -->
  <CodePackage Name="Code" Version="1.0.0">
    <EntryPoint>
      <ContainerHost>
        <!--The repo and image on https://hub.docker.com or Azure Container Registry. -->
        <ImageName>sfsamples.azurecr.io/sfsamples/servicefabricbackendservice:v1</ImageName>
        
        <!-- Pass comma delimited commands to your container. -->
        <Commands> dotnet, myproc.dll, 5 </Commands>
      </ContainerHost>
    </EntryPoint>
    <!-- Pass environment variables to your container. These variables are overridden in the application manifest. -->
    <EnvironmentVariables>
      <EnvironmentVariable Name="IsContainer" Value="true"/>
    </EnvironmentVariables>
  </CodePackage>

  <!-- Config package is the contents of the Config directory under PackageRoot that contains an 
       independently-updateable and versioned set of custom configuration settings for your service. -->
  <ConfigPackage Name="Config" Version="1.0.0" />

  <Resources>
    <Endpoints>
      <!-- This endpoint is used by the communication listener to obtain the host port on which to 
           listen. For a guest executable is used to register with the NamingService at its REST endpoint
           with http scheme. In this case since no port is specified, one is created and assigned dynamically
           to the service. This dynamically assigned host port is mapped to the container port (8905 in this sample),
            which was specified in the application manifest.-->
      <Endpoint Name="BackEndServiceTypeEndpoint" UriScheme="http" />
    </Endpoints>
  </Resources>
</ServiceManifest>
```

## <a name="application-manifest-elements"></a>Elementy manifestu aplikacji
### <a name="applicationmanifest-element"></a>ApplicationManifest Element
Opisuje sposób deklaratywny typ i wersja aplikacji. Co najmniej jeden manifestów usługi składowe usług odwołują się do redagowania typu aplikacji. Ustawienia konfiguracji usługi składowe można zastąpić przy użyciu ustawień aplikacji sparametryzowanych. Domyślnie usługi, szablony usług, podmiotów zabezpieczeń, zasady, konfiguracji diagnostyki i certyfikatów mogą również zadeklarowane na poziomie aplikacji. Aby uzyskać więcej informacji, zobacz [ApplicationManifest — Element](service-fabric-service-model-schema-elements.md#ApplicationManifestElementApplicationManifestTypeComplexType)

### <a name="parameters-element"></a>Parametry elementu
Deklaruje parametry, które są używane w tym manifeście aplikacji. Wartości tych parametrów można podać, gdy aplikacja zostanie uruchomiony i może służyć do zastępowania ustawień konfiguracji usługi lub aplikacji. Aby uzyskać więcej informacji, zobacz [parametrów elementu](service-fabric-service-model-schema-elements.md#ParametersElementanonymouscomplexTypeComplexTypeDefinedInApplicationManifestTypecomplexType)

### <a name="parameter-element"></a>Parameter — Element
Parametr aplikacji ma być używany w tym manifeście. Podczas tworzenia wystąpienia aplikacji, można zmienić wartość tego parametru lub, jeśli nie dostarczono żadnej wartości zostanie użyta domyślna wartość. Aby uzyskać więcej informacji, zobacz [Parameter — Element](service-fabric-service-model-schema-elements.md#ParameterElementanonymouscomplexTypeComplexTypeDefinedInParameterselement)

### <a name="servicemanifestimport-element"></a>ServiceManifestImport Element
Importuje manifestu usługi utworzone przez dewelopera usługi. Manifest usługi muszą zostać zaimportowane dla poszczególnych składników usługi w aplikacji. Zastępuje element konfiguracji, a zasady mogą być deklarowane manifestu usługi. Aby uzyskać więcej informacji, zobacz [ServiceManifestImport — Element](service-fabric-service-model-schema-elements.md#ServiceManifestImportElementanonymouscomplexTypeComplexTypeDefinedInApplicationManifestTypecomplexType)

### <a name="servicemanifestref-element"></a>ServiceManifestRef Element
Importuje manifestu usługi przez odwołanie. Obecnie plik manifestu usługi (ServiceManifest.xml) musi być obecne w pakiecie kompilacji. Aby uzyskać więcej informacji, zobacz [ServiceManifestRef — Element](service-fabric-service-model-schema-elements.md#ServiceManifestRefElementServiceManifestRefTypeComplexTypeDefinedInServiceManifestImportelement)

### <a name="policies-element"></a>Element zasad
W tym artykule opisano zasady (punkt końcowy powiązania, pakiet do udostępniania, Uruchom jako i zabezpieczenia dostępu) mają być stosowane w manifeście importowanych usługi. Aby uzyskać więcej informacji, zobacz [Element zasad](service-fabric-service-model-schema-elements.md#PoliciesElementServiceManifestImportPoliciesTypeComplexTypeDefinedInServiceManifestImportelement)

### <a name="servicepackageresourcegovernancepolicy-element"></a>ServicePackageResourceGovernancePolicy Element
Definiuje zasady ładu zasobów, która jest stosowana na poziomie pakietu całą usługę. Aby uzyskać więcej informacji, zobacz [ServicePackageResourceGovernancePolicy — Element](service-fabric-service-model-schema-elements.md#ServicePackageResourceGovernancePolicyElementServicePackageResourceGovernancePolicyTypeComplexTypeDefinedInServiceManifestImportPoliciesTypecomplexTypeDefinedInServicePackageTypecomplexType)

### <a name="resourcegovernancepolicy-element"></a>ResourceGovernancePolicy Element
Określa limity zasobów dla pakietu kodu. Aby uzyskać więcej informacji, zobacz [ResourceGovernancePolicy — Element](service-fabric-service-model-schema-elements.md#ResourceGovernancePolicyElementResourceGovernancePolicyTypeComplexTypeDefinedInServiceManifestImportPoliciesTypecomplexTypeDefinedInDigestedCodePackageelementDefinedInDigestedEndpointelement)

### <a name="containerhostpolicies-element"></a>ContainerHostPolicies Element
Określa zasady do aktywacji na hostach kontenerów. Aby uzyskać więcej informacji, zobacz [ContainerHostPolicies — Element](service-fabric-service-model-schema-elements.md#ContainerHostPoliciesElementContainerHostPoliciesTypeComplexTypeDefinedInServiceManifestImportPoliciesTypecomplexTypeDefinedInDigestedCodePackageelement)

### <a name="repositorycredentials-element"></a>RepositoryCredentials Element
Poświadczenia dla repozytorium obrazów kontenera do ściągania obrazów z. Aby uzyskać więcej informacji, zobacz [RepositoryCredentials — Element](service-fabric-service-model-schema-elements.md#RepositoryCredentialsElementRepositoryCredentialsTypeComplexTypeDefinedInContainerHostPoliciesTypecomplexType)

### <a name="portbinding-element"></a>PortBinding Element
Określa zasobu punktu końcowego, który chcesz powiązać ujawnionych portów kontenera. Aby uzyskać więcej informacji, zobacz [PortBinding — Element](service-fabric-service-model-schema-elements.md#PortBindingElementPortBindingTypeComplexTypeDefinedInServicePackageContainerPolicyTypecomplexTypeDefinedInContainerHostPoliciesTypecomplexType)

### <a name="volume-element"></a>Element woluminu
Określa wolumin, który może być powiązane z kontenera. Aby uzyskać więcej informacji, zobacz [Element woluminu](service-fabric-service-model-schema-elements.md#VolumeElementContainerVolumeTypeComplexTypeDefinedInContainerHostPoliciesTypecomplexType)

### <a name="driveroption-element"></a>DriverOption Element
Opcje sterownika, które zostaną przekazane do sterownika. Aby uzyskać więcej informacji, zobacz [DriverOption — Element](service-fabric-service-model-schema-elements.md#DriverOptionElementDriverOptionTypeComplexTypeDefinedInContainerLoggingDriverTypecomplexTypeDefinedInContainerVolumeTypecomplexType)

### <a name="imageoverrides-element"></a>ImageOverrides Element
Kontenery systemu Windows Server może nie być zgodny w różnych wersjach systemu operacyjnego.  Można określić wielu obrazów systemu operacyjnego na kontener i oznacza je za pomocą wersji kompilacji systemu operacyjnego. Pobieranie wersji kompilacji systemu operacyjnego, uruchamiając "polecenie winver" w wierszu polecenia Windows. Podstawowego systemu operacyjnego w przypadku kompilacji wersji 16299 (Windows Server w wersji 1709), Usługa Service Fabric wybiera obraz kontenera oznakowane za pomocą systemu operacyjnego = "16299". Nieotagowany obraz kontenera przyjęto, że będzie działać we wszystkich wersjach systemu operacyjnego i przesłania obrazu określonego w manifeście usługi. Aby uzyskać więcej informacji, zobacz [ImageOverrides — Element](service-fabric-service-model-schema-elements.md#ImageOverridesElementImageOverridesTypeComplexTypeDefinedInContainerHostPoliciesTypecomplexType)

### <a name="image-element"></a>Elementu obrazu
Obraz kontenera odpowiadający numer wersji kompilacji systemu operacyjnego do uruchomienia. Jeśli nie określono atrybutu systemu operacyjnego, obraz kontenera przyjęto, że będzie działać we wszystkich wersjach systemu operacyjnego i przesłania obrazu określonego w manifeście usługi. Aby uzyskać więcej informacji, zobacz [elementu obrazu](service-fabric-service-model-schema-elements.md#ImageElementImageTypeComplexTypeDefinedInImageOverridesTypecomplexType)

### <a name="environmentoverrides-element"></a>EnvironmentOverrides Element
 Aby uzyskać więcej informacji, zobacz [EnvironmentOverrides — Element](service-fabric-service-model-schema-elements.md#EnvironmentOverridesElementEnvironmentOverridesTypeComplexTypeDefinedInServiceManifestImportelement)

### <a name="environmentvariable-element"></a>Element zmiennych środowiskowych
zmiennej środowiskowej. Aby uzyskać więcej informacji, zobacz [Element zmiennych środowiskowych](service-fabric-service-model-schema-elements.md#EnvironmentVariableElementEnvironmentVariableOverrideTypeComplexTypeDefinedInEnvironmentOverridesTypecomplexType)

### <a name="certificateref-element"></a>CertificateRef Element
Określa informacje o X509 certyfikatu, który ma być udostępniana dla środowiska kontenera. Certyfikat musi być zainstalowany w magazynie LocalMachine wszystkich węzłów klastra.
Podczas uruchamiania aplikacji, środowisko uruchomieniowe odczytuje certyfikat i generuje plik PFX i hasła (Windows) lub plik PEM (w systemie Linux).
Plik PFX i hasło są dostępne w kontenerze za pomocą zmiennych środowiskowych Certificates_ServicePackageName_CodePackageName_CertName_PFX i Certificates_ServicePackageName_CodePackageName_CertName_Password. Plik PEM jest dostępny w kontenerze za pomocą zmiennych środowiskowych Certificates_ServicePackageName_CodePackageName_CertName_PEM i Certificates_ServicePackageName_CodePackageName_CertName_PrivateKey. Aby uzyskać więcej informacji, zobacz [CertificateRef — Element](service-fabric-service-model-schema-elements.md#CertificateRefElementContainerCertificateTypeComplexTypeDefinedInContainerHostPoliciesTypecomplexType)

### <a name="defaultservices-element"></a>DefaultServices Element
Deklaruje wystąpień usług, które są tworzone automatycznie, gdy aplikacja zostanie uruchomiony dla tego typu aplikacji. Aby uzyskać więcej informacji, zobacz [DefaultServices — Element](service-fabric-service-model-schema-elements.md#DefaultServicesElementDefaultServicesTypeComplexTypeDefinedInApplicationManifestTypecomplexTypeDefinedInApplicationInstanceTypecomplexType)

### <a name="service-element"></a>Element usługi
Deklaruje usługi, które zostaną utworzone automatycznie podczas tworzenia wystąpienia aplikacji. Aby uzyskać więcej informacji, zobacz [Element usługi](service-fabric-service-model-schema-elements.md#ServiceElementanonymouscomplexTypeComplexTypeDefinedInDefaultServicesTypecomplexType)

### <a name="statelessservice-element"></a>StatelessService Element
Definiuje usługę bezstanową. Aby uzyskać więcej informacji, zobacz [StatelessService — Element](service-fabric-service-model-schema-elements.md#StatelessServiceElementStatelessServiceTypeComplexTypeDefinedInServiceTemplatesTypecomplexTypeDefinedInServiceelement)


## <a name="frontendservice-service-manifest-elements"></a>Elementy manifestu usługi FrontEndService
### <a name="servicemanifest-element"></a>ServiceManifest Element
Deklaratywnie w tym artykule opisano usługę typu i wersji. Wyświetla listę niezależnie możliwość uaktualnienia pakiety kodu, konfiguracji i danych, które razem tworzą pakietu usług do obsługi co najmniej jeden typ usługi. Zasoby, ustawienia diagnostyczne i metadanych usługi, takie jak typ usługi, właściwości kondycji i równoważenie obciążenia metryki, również są określone. Aby uzyskać więcej informacji, zobacz [ServiceManifest — Element](service-fabric-service-model-schema-elements.md#ServiceManifestElementServiceManifestTypeComplexType)

### <a name="servicetypes-element"></a>ServiceTypes Element
Definiuje, jakie usługi są obsługiwane przez CodePackage w tym manifeście. Gdy usługa zostanie uruchomiony na jednym z tych typów usług, wszystkie pakiety kodu zadeklarowany w tym manifeście zostaną aktywowane przez uruchomienie ich punkty wejścia. Typy usług są zadeklarowane na poziomie manifestu, a nie na poziomie pakietu kodu. Aby uzyskać więcej informacji, zobacz [ServiceTypes — Element](service-fabric-service-model-schema-elements.md#ServiceTypesElementServiceAndServiceGroupTypesTypeComplexTypeDefinedInServiceManifestTypecomplexType)

### <a name="statelessservicetype-element"></a>StatelessServiceType Element
Opisuje typ usługi bezstanowej. Aby uzyskać więcej informacji, zobacz [StatelessServiceType — Element](service-fabric-service-model-schema-elements.md#StatelessServiceTypeElementStatelessServiceTypeTypeComplexTypeDefinedInServiceAndServiceGroupTypesTypecomplexTypeDefinedInServiceTypesTypecomplexType)

### <a name="codepackage-element"></a>CodePackage Element
W tym artykule opisano pakiet kodu, który obsługuje typ zdefiniowany usługi. Gdy usługa zostanie uruchomiony na jednym z tych typów usług, wszystkie pakiety kodu zadeklarowany w tym manifeście zostaną aktywowane przez uruchomienie ich punkty wejścia. Wynikowy procesy powinny zarejestrować obsługiwanych typów usług w czasie wykonywania. W przypadku wielu pakietów kodu ich wszystkich aktywacji zawsze wtedy, gdy system wyszukuje jeden z typów zadeklarowane usług. Aby uzyskać więcej informacji, zobacz [CodePackage — Element](service-fabric-service-model-schema-elements.md#CodePackageElementCodePackageTypeComplexTypeDefinedInServiceManifestTypecomplexTypeDefinedInDigestedCodePackageelement)

### <a name="entrypoint-element"></a>EntryPoint — Element
Plik wykonywalny określony przez punkt wejścia jest zazwyczaj długotrwałych hosta usługi. Obecność punktu wejścia Instalatora oddzielne pozwala na uniknięcie konieczności uruchamiania hosta usługi z wysokim poziomem uprawnień na dłuższy czas. Plik wykonywalny określony przez punkt wejścia jest uruchamiany po SetupEntryPoint kończy się pomyślnie. Proces wynikowy jest monitorowana i uruchomione ponownie (od początku ponownie, używając SetupEntryPoint), jeśli kiedykolwiek kończy się lub ulega awarii. Aby uzyskać więcej informacji, zobacz [EntryPoint — Element](service-fabric-service-model-schema-elements.md#EntryPointElementEntryPointDescriptionTypeComplexTypeDefinedInCodePackageTypecomplexType)

### <a name="containerhost-element"></a>ContainerHost Element
 Aby uzyskać więcej informacji, zobacz [ContainerHost — Element](service-fabric-service-model-schema-elements.md#ContainerHostElementContainerHostEntryPointTypeComplexTypeDefinedInEntryPointDescriptionTypecomplexType)

### <a name="imagename-element"></a>ImageName Element
Repozytorium i obraz na https://hub.docker.com lub Azure Container Registry. Aby uzyskać więcej informacji, zobacz [ImageName — Element](service-fabric-service-model-schema-elements.md#ImageNameElementxs:stringComplexTypeDefinedInContainerHostEntryPointTypecomplexType)

### <a name="environmentvariables-element"></a>EnvironmentVariables Element
Przekazać zmienne środowiskowe do kontenera lub pliku exe.  Aby uzyskać więcej informacji, zobacz [EnvironmentVariables — Element](service-fabric-service-model-schema-elements.md#EnvironmentVariablesElementEnvironmentVariablesTypeComplexTypeDefinedInCodePackageTypecomplexType)

### <a name="environmentvariable-element"></a>Element zmiennych środowiskowych
zmiennej środowiskowej. Aby uzyskać więcej informacji, zobacz [Element zmiennych środowiskowych](service-fabric-service-model-schema-elements.md#EnvironmentVariableElementEnvironmentVariableOverrideTypeComplexTypeDefinedInEnvironmentOverridesTypecomplexType)

### <a name="configpackage-element"></a>ConfigPackage Element
Deklaruje folderu nazwane nazwy atrybutu, który zawiera Settings.xml plik. Ten plik zawiera sekcje ustawień zdefiniowanych przez użytkownika, pary klucz wartość pary, które ten proces może odczytywać Wstecz w czasie wykonywania. Podczas uaktualniania Jeśli istnieją tylko w wersji ConfigPackage został zmieniony, następnie uruchomiony proces nie zostanie ponownie uruchomiony. Zamiast tego wywołania zwrotnego powiadamia procesu, które uległy zmianie ustawień konfiguracji, aby dynamicznie załadowania. Aby uzyskać więcej informacji, zobacz [ConfigPackage — Element](service-fabric-service-model-schema-elements.md#ConfigPackageElementConfigPackageTypeComplexTypeDefinedInServiceManifestTypecomplexTypeDefinedInDigestedConfigPackageelement)

### <a name="datapackage-element"></a>DataPackage Element
Deklaruje folderem o nazwie określonej przez atrybut "Name", który zawiera pliki danych statycznych. Usługa Service Fabric będzie Odtwórz wszystkich plików exe i DLLHOSTs określone w pakietach hosta i pomocy technicznej, po uaktualnieniu żadnych pakietów danych, wymienione w manifeście usługi. Aby uzyskać więcej informacji, zobacz [DataPackage — Element](service-fabric-service-model-schema-elements.md#DataPackageElementDataPackageTypeComplexTypeDefinedInServiceManifestTypecomplexTypeDefinedInDigestedDataPackageelement)

### <a name="resources-element"></a>Element zasobów
W tym artykule opisano zasoby używane przez tę usługę, która może być zadeklarowana bez konieczności modyfikowania kodu skompilowanego i zmieniać w przypadku wdrażania usługi. Dostęp do tych zasobów jest kontrolowany za pośrednictwem podmiotów i zasad części manifestu aplikacji. Aby uzyskać więcej informacji, zobacz [elementu zasobów](service-fabric-service-model-schema-elements.md#ResourcesElementResourcesTypeComplexTypeDefinedInServiceManifestTypecomplexType)

### <a name="endpoints-element"></a>Element punktów końcowych
Definiuje punkty końcowe usługi. Aby uzyskać więcej informacji, zobacz [Element punktów końcowych](service-fabric-service-model-schema-elements.md#EndpointsElementanonymouscomplexTypeComplexTypeDefinedInResourcesTypecomplexType)

### <a name="endpoint-element"></a>Punkt końcowy elementu
Aby uzyskać więcej informacji, zobacz [elementu punktu końcowego](service-fabric-service-model-schema-elements.md#EndpointElementEndpointOverrideTypeComplexTypeDefinedInEndpointselement)


## <a name="backendservice-service-manifest-elements"></a>Elementy manifestu usługę BackEndService
### <a name="servicemanifest-element"></a>ServiceManifest Element
Deklaratywnie w tym artykule opisano usługę typu i wersji. Wyświetla listę niezależnie możliwość uaktualnienia pakiety kodu, konfiguracji i danych, które razem tworzą pakietu usług do obsługi co najmniej jeden typ usługi. Zasoby, ustawienia diagnostyczne i metadanych usługi, takie jak typ usługi, właściwości kondycji i równoważenie obciążenia metryki, również są określone. Aby uzyskać więcej informacji, zobacz [ServiceManifest — Element](service-fabric-service-model-schema-elements.md#ServiceManifestElementServiceManifestTypeComplexType)

### <a name="servicetypes-element"></a>ServiceTypes Element
Definiuje, jakie usługi są obsługiwane przez CodePackage w tym manifeście. Gdy usługa zostanie uruchomiony na jednym z tych typów usług, wszystkie pakiety kodu zadeklarowany w tym manifeście zostaną aktywowane przez uruchomienie ich punkty wejścia. Typy usług są zadeklarowane na poziomie manifestu, a nie na poziomie pakietu kodu. Aby uzyskać więcej informacji, zobacz [ServiceTypes — Element](service-fabric-service-model-schema-elements.md#ServiceTypesElementServiceAndServiceGroupTypesTypeComplexTypeDefinedInServiceManifestTypecomplexType)

### <a name="statelessservicetype-element"></a>StatelessServiceType Element
Opisuje typ usługi bezstanowej. Aby uzyskać więcej informacji, zobacz [StatelessServiceType — Element](service-fabric-service-model-schema-elements.md#StatelessServiceTypeElementStatelessServiceTypeTypeComplexTypeDefinedInServiceAndServiceGroupTypesTypecomplexTypeDefinedInServiceTypesTypecomplexType)

### <a name="codepackage-element"></a>CodePackage Element
W tym artykule opisano pakiet kodu, który obsługuje typ zdefiniowany usługi. Gdy usługa zostanie uruchomiony na jednym z tych typów usług, wszystkie pakiety kodu zadeklarowany w tym manifeście zostaną aktywowane przez uruchomienie ich punkty wejścia. Wynikowy procesy powinny zarejestrować obsługiwanych typów usług w czasie wykonywania. W przypadku wielu pakietów kodu ich wszystkich aktywacji zawsze wtedy, gdy system wyszukuje jeden z typów zadeklarowane usług. Aby uzyskać więcej informacji, zobacz [CodePackage — Element](service-fabric-service-model-schema-elements.md#CodePackageElementCodePackageTypeComplexTypeDefinedInServiceManifestTypecomplexTypeDefinedInDigestedCodePackageelement)

### <a name="entrypoint-element"></a>EntryPoint — Element
Plik wykonywalny określony przez punkt wejścia jest zazwyczaj długotrwałych hosta usługi. Obecność punktu wejścia Instalatora oddzielne pozwala na uniknięcie konieczności uruchamiania hosta usługi z wysokim poziomem uprawnień na dłuższy czas. Plik wykonywalny określony przez punkt wejścia jest uruchamiany po SetupEntryPoint kończy się pomyślnie. Proces wynikowy jest monitorowana i uruchomione ponownie (od początku ponownie, używając SetupEntryPoint), jeśli kiedykolwiek kończy się lub ulega awarii. Aby uzyskać więcej informacji, zobacz [EntryPoint — Element](service-fabric-service-model-schema-elements.md#EntryPointElementEntryPointDescriptionTypeComplexTypeDefinedInCodePackageTypecomplexType)

### <a name="containerhost-element"></a>ContainerHost Element
Aby uzyskać więcej informacji, zobacz [ContainerHost — Element](service-fabric-service-model-schema-elements.md#ContainerHostElementContainerHostEntryPointTypeComplexTypeDefinedInEntryPointDescriptionTypecomplexType)

### <a name="imagename-element"></a>ImageName Element
Repozytorium i obraz na https://hub.docker.com lub Azure Container Registry. Aby uzyskać więcej informacji, zobacz [ImageName — Element](service-fabric-service-model-schema-elements.md#ImageNameElementxs:stringComplexTypeDefinedInContainerHostEntryPointTypecomplexType)

### <a name="commands-element"></a>Commands, Element
Rozdzielany przecinkami listę poleceń należy przekazać do kontenera. Aby uzyskać więcej informacji, zobacz [Commands, Element](service-fabric-service-model-schema-elements.md#CommandsElementxs:stringComplexTypeDefinedInContainerHostEntryPointTypecomplexType)

### <a name="environmentvariables-element"></a>EnvironmentVariables Element
Przekazać zmienne środowiskowe do kontenera lub pliku exe.  Aby uzyskać więcej informacji, zobacz [EnvironmentVariables — Element](service-fabric-service-model-schema-elements.md#EnvironmentVariablesElementEnvironmentVariablesTypeComplexTypeDefinedInCodePackageTypecomplexType)

### <a name="environmentvariable-element"></a>Element zmiennych środowiskowych
zmiennej środowiskowej. Aby uzyskać więcej informacji, zobacz [Element zmiennych środowiskowych](service-fabric-service-model-schema-elements.md#EnvironmentVariableElementEnvironmentVariableOverrideTypeComplexTypeDefinedInEnvironmentOverridesTypecomplexType)

### <a name="configpackage-element"></a>ConfigPackage Element
Deklaruje folderu nazwane nazwy atrybutu, który zawiera Settings.xml plik. Ten plik zawiera sekcje ustawień zdefiniowanych przez użytkownika, pary klucz wartość pary, które ten proces może odczytywać Wstecz w czasie wykonywania. Podczas uaktualniania Jeśli istnieją tylko w wersji ConfigPackage został zmieniony, następnie uruchomiony proces nie zostanie ponownie uruchomiony. Zamiast tego wywołania zwrotnego powiadamia procesu, które uległy zmianie ustawień konfiguracji, aby dynamicznie załadowania. Aby uzyskać więcej informacji, zobacz [ConfigPackage — Element](service-fabric-service-model-schema-elements.md#ConfigPackageElementConfigPackageTypeComplexTypeDefinedInServiceManifestTypecomplexTypeDefinedInDigestedConfigPackageelement)

### <a name="resources-element"></a>Element zasobów
W tym artykule opisano zasoby używane przez tę usługę, która może być zadeklarowana bez konieczności modyfikowania kodu skompilowanego i zmieniać w przypadku wdrażania usługi. Dostęp do tych zasobów jest kontrolowany za pośrednictwem podmiotów i zasad części manifestu aplikacji. Aby uzyskać więcej informacji, zobacz [elementu zasobów](service-fabric-service-model-schema-elements.md#ResourcesElementResourcesTypeComplexTypeDefinedInServiceManifestTypecomplexType)

### <a name="endpoints-element"></a>Element punktów końcowych
Definiuje punkty końcowe usługi. Aby uzyskać więcej informacji, zobacz [Element punktów końcowych](service-fabric-service-model-schema-elements.md#EndpointsElementanonymouscomplexTypeComplexTypeDefinedInResourcesTypecomplexType)

### <a name="endpoint-element"></a>Punkt końcowy elementu
 Aby uzyskać więcej informacji, zobacz [elementu punktu końcowego](service-fabric-service-model-schema-elements.md#EndpointElementEndpointOverrideTypeComplexTypeDefinedInEndpointselement)

