# Samples for Azure Container Apps | Revisions

## Single Revision Mode

Single Revision Mode means that you will only ever have a single active revision of your application. This is the default mode for Azure Container Apps. When you deploy a new revision, the previous revision is automatically deleted. This is the simplest mode to use, but it does not allow you to do things like A/B testing or Blue/Green deployments. This mode does have built-in support for zero-downtime deployments, however, because the previous revision is not deleted until the new revision is ready to serve traffic.

### Run the sample

To follow the steps below to deploy the [Hello World application]() to an Azure Container App in single revision mode, you will need the [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) version 2.2.0 or later. You can check your CLI version with `az --version`. If you need to install or upgrade, see [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli).

0. Assign variables

    ```bash
    export RESOURCE_GROUP=rg-aca-single-revision-tests
    export LOCATION=eastus
    export CONTAINER_APP_ENV=single-revision-tests
    export CONTAINER_APP=single-revision-test-app
    ```
1. Create a resource group

    ```bash
    az group create -n $RESOURCE_GROUP -l $LOCATION
    ```
1. Create an Azure Container Apps environment

    ```bash
    az containerapp env create -n $CONTAINER_APP_ENV -g $RESOURCE_GROUP -l $LOCATION
    ```
1. Deploy the Hello World application

    ```bash
    az containerapp create -n $CONTAINER_APP -g $RESOURCE_GROUP --environment $CONTAINER_APP_ENV \
        --image mcr.microsoft.com/azuredocs/containerapps-helloworld:latest \
        --ingress external --target-port 80
    ```
1. Get the URL for the application

    ```bash
    az containerapp show -n $CONTAINER_APP -g $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv
    ```
1. Open the URL in a browser to see the application running


## Multiple Revision Mode

### Sample Application

The sample application is a simple web application that displays the hostname of the container that is serving the request and the revision number. This is useful for demonstrating how traffic is routed between revisions. Additionally, the application will expose environment variables and application configuration to see how revisions can be configured differently.

The sample application is a .NET 7 application. To build the application, you will need the [.NET 7 SDK](https://dotnet.microsoft.com/download/dotnet/7.0) installed. You can check your .NET version with `dotnet --version`. If you need to install or upgrade, see [Install .NET](https://dotnet.microsoft.com/download). 

It is also hosted as an available image in the GitHub repository's container registry, so you can use that image instead of building it yourself. The images available are:
* `ghcr.io/awkwardindustries/dossier/aca-multi-revision:a`
* `ghcr.io/awkwardindustries/dossier/aca-multi-revision:b`

Those images are not guaranteed to be available, so instructions to recreate them (or create and host your own) are:

```bash
# Run from the root with the Dockerfile
cd samples/azure-container-apps/revisions

# Build the image with the tag a
docker build -t ghcr.io/awkwardindustries/dossier/aca-multi-revision:a .

# Tag the same image with the tag b
docker tag ghcr.io/awkwardindustries/dossier/aca-multi-revision:a ghcr.io/awkwardindustries/dossier/aca-multi-revision:b

# Push both images to the GitHub container registry
docker push ghcr.io/awkwardindustries/dossier/aca-multi-revision:a
docker push ghcr.io/awkwardindustries/dossier/aca-multi-revision:b
```

### Run the sample

0. Assign variables

    ```bash
    export RESOURCE_GROUP=rg-aca-multi-revision-tests
    export LOCATION=eastus
    export CONTAINER_APP_ENV=multi-revision-tests
    export CONTAINER_APP=multi-revision-test-app
    ```
1. Create a resource group

    ```bash
    az group create -n $RESOURCE_GROUP -l $LOCATION
    ```
1. Create an Azure Container Apps environment

    ```bash
    az containerapp env create -n $CONTAINER_APP_ENV -g $RESOURCE_GROUP -l $LOCATION
    ```

#### A/B Testing

1. Deploy the sample application's A revision
  
    ```bash
    az containerapp create -n $CONTAINER_APP -g $RESOURCE_GROUP --environment $CONTAINER_APP_ENV \
        --revisions-mode multiple \
        --revision-suffix a \
        --image ghcr.io/awkwardindustries/dossier/aca-multi-revision:a \
        --ingress external --target-port 80
    ```
1. Fix 100% of the traffice to the A revision

    ```bash
    az containerapp ingress traffic set -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --revision-weight $CONTAINER_APP--a=100
    ```
1. Test the endpoints

    ```bash
    # Get the containerapp environment default domain
    export APP_DOMAIN=$(az containerapp env show -g $RESOURCE_GROUP -n $CONTAINER_APP_ENV --query properties.defaultDomain -o tsv | tr -d '\r\n')

    # Test the production FQDN
    curl -s https://$CONTAINER_APP.$APP_DOMAIN/WeatherForecast | jq

    # Test the specific A revision FQDN
    curl -s https://$CONTAINER_APP--a.$APP_DOMAIN/WeatherForecast | jq
    ```
1. Show the revisions

    ```bash
    az containerapp revision list -n $CONTAINER_APP -g $RESOURCE_GROUP -o table
    ```
1. Deploy the sample application's B revision (with a different image)

    ```bash
    az containerapp update -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --image ghcr.io/awkwardindustries/dossier/aca-multi-revision:b \
        --revision-suffix b \
        --set-env-vars "DESIRED_TEMP_UNIT=Celcius"
    ```
1. Test the endpoints
    
    ```bash
    # Test the A revision FQDN
    curl -s https://$CONTAINER_APP--a.$APP_DOMAIN/WeatherForecast | jq

    # Test the B revision FQDN
    curl -s https://$CONTAINER_APP--b.$APP_DOMAIN/WeatherForecast | jq

    # Test the production FQDN
    curl -s https://$CONTAINER_APP.$APP_DOMAIN/WeatherForecast | jq
    ```
1. Split traffic 50/50 between the A and B revisions
    
    ```bash
    az containerapp ingress traffic set -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --revision-weight $CONTAINER_APP--a=50 $CONTAINER_APP--b=50
    ```
1. Test the production endpoint

    ```bash
    curl -s https://$CONTAINER_APP.$APP_DOMAIN/WeatherForecast | jq
    ```

    > Note: It may take several hits before you see traffic switch between the active revisions.
1. Show the revisions

    ```bash
    az containerapp revision list -n $CONTAINER_APP -g $RESOURCE_GROUP
    ```
1. Send all traffic to the B revision

    ```bash
    az containerapp ingress traffic set -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --revision-weight $CONTAINER_APP--a=0 $CONTAINER_APP--b=100
    ```
1. Deactivate the A revision

    ```bash
    az containerapp revision deactivate -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --revision $CONTAINER_APP--a
    ```

#### Blue/Green Deployments

Official documentation for using Azure Container Apps for blue/green deployments can be found [here](https://learn.microsoft.com/en-us/azure/container-apps/blue-green-deployment?pivots=azure-cli).

1. Deploy the sample application's version A revision 
  
    ```bash
    az containerapp create -n $CONTAINER_APP -g $RESOURCE_GROUP --environment $CONTAINER_APP_ENV \
        --revisions-mode multiple \
        --revision-suffix a \
        --image ghcr.io/awkwardindustries/dossier/aca-multi-revision:a \
        --ingress external --target-port 80
    ```
1. Add a label to the A revision to have a clear identifier between the blue and green revisions since those two labels will swap over time and is independent of the version 

    ```bash
    az containerapp revision label add -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --revision $CONTAINER_APP--a \
        --label blue
    ```
1. (In a long-lived blue-green deployment environment this step would not be required) Fix 100% of the traffice to the current production revision (blue)

    ```bash
    az containerapp ingress traffic set -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --label-weight blue=100
    ```
1. Test the endpoints

    ```bash
    # Get the containerapp environment default domain
    export APP_DOMAIN=$(az containerapp env show -g $RESOURCE_GROUP -n $CONTAINER_APP_ENV --query properties.defaultDomain -o tsv | tr -d '\r\n')

    # Test the production FQDN
    curl -s https://$CONTAINER_APP.$APP_DOMAIN/WeatherForecast | jq

    # Test the blue label FQDN
    curl -s https://$CONTAINER_APP---blue.$APP_DOMAIN/WeatherForecast | jq
    ```
1. Show the revisions

    ```bash
    az containerapp revision list -n $CONTAINER_APP -g $RESOURCE_GROUP -o table
    ```
1. Deploy the sample application's version B revision with additional environment variables

    ```bash
    az containerapp update -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --image ghcr.io/awkwardindustries/dossier/aca-multi-revision:b \
        --revision-suffix b \
        --set-env-vars "DESIRED_TEMP_UNIT=Celcius"
    ```
1. Add a label to the B revision

    ```bash
    az containerapp revision label add -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --revision $CONTAINER_APP--b \
        --label green
    ```
1. Test the endpoints
    
    ```bash
    # Test the blue label FQDN
    curl -s https://$CONTAINER_APP---blue.$APP_DOMAIN/WeatherForecast | jq

    # Test the green label FQDN
    curl -s https://$CONTAINER_APP---green.$APP_DOMAIN/WeatherForecast | jq

    # Test the production FQDN
    curl -s https://$CONTAINER_APP.$APP_DOMAIN/WeatherForecast | jq
    ```
1. Split traffic 50/50 between the blue and green revisions
    
    ```bash
    az containerapp ingress traffic set -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --label-weight blue=50 green=50
    ```
1. Test the production endpoint

    ```bash
    curl -s https://$CONTAINER_APP.$APP_DOMAIN/WeatherForecast | jq
    ```
1. Show the revisions

    ```bash
    az containerapp revision list -n $CONTAINER_APP -g $RESOURCE_GROUP
    ```
1. Send all traffic to the green revision

    ```bash
    az containerapp ingress traffic set -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --label-weight blue=0 green=100
    ```
1. Remove the blue label so that you're ready for the next deployment cycle

    ```bash
    az containerapp revision label remove -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --label blue
    ```
1. Deactivate the A revision

    ```bash
    az containerapp revision deactivate -n $CONTAINER_APP -g $RESOURCE_GROUP \
        --revision $CONTAINER_APP--a
    ```
1. Show the revisions

    ```bash
    az containerapp revision list -n $CONTAINER_APP -g $RESOURCE_GROUP
    ```

Although not shown, there is also a command available to swap labels and associated traffic weights between two revisions. That command would look like: `az containerapp revision label swap -n $CONTAINER_APP -g $RESOURCE_GROUP --source blue --target green`.