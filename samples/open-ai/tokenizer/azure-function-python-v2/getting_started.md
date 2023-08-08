# Getting Started with Azure Functions in Python

## Building and Running Locally with VS Code

This project was created using the [Quickstart: Create a function in Azure with Python using Visual Studio Code](https://learn.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python?pivots=python-mode-decorators). It assumes several [prerequisites](https://learn.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python?pivots=python-mode-decorators#configure-your-environment) to ensure your environment is setup correctly.

You will need to create a local Python virtual environment to run the Functions host locally. You can do this in VS Code by running the task `Python: Create Environment...` and choosing `Venv` as the environment type. This will create a `.venv` folder in the root of the project. You will also need to install the dependencies for the project by running the task `Python: Install Dependencies`. This will install the dependencies listed in the `requirements.txt` file.

Additionally, when running the local Functions host, you will need a `local.settings.json` file at the root of the directory. This file is not checked into source control to reduce unintentional leakage of credentials. The file should look like something like this:

```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "AzureWebJobsFeatureFlags": "EnableWorkerIndexing"
  }
}
```

The `UseDevelopmentStorage=true` assumes Azurite is setup and running locally when beginning to debug the Function. If you are using a different storage account, you will need to update the `AzureWebJobsStorage` value to point to the correct storage account.

## Python Programming Model V2

The new programming model in Azure Functions Python delivers an experience that aligns with Python development principles, and subsequently with commonly used Python frameworks. 

The improved programming model requires fewer files than the default model, and specifically eliminates the need for a configuration file (`function.json`). Instead, triggers and bindings are represented in the `function_app.py` file as decorators. Moreover, functions can be logically organized with support for multiple functions to be stored in the same file. Functions within the same function application can also be stored in different files, and be referenced as blueprints.

In addition to the [documentation](https://docs.microsoft.com/azure/azure-functions/functions-reference-python?tabs=asgi%2Capplication-level), hints are available in code editors that support type checking with PYI files.

To learn more about the new programming model for Azure Functions in Python, see [Programming Models in Azure Functions](https://aka.ms/functions-programming-models).

## Notes

- Mix and match of Functions written in the V1 programming model and the V2 programming model in the same Function App will not be supported.
- At this time, the main functions file must be named `function_app.py`.

To learn more about the new programming model for Azure Functions in Python, see the [Azure Functions Python developer guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=asgi%2Capplication-level).

## Getting Started

Project Structure

The main project folder (<project_root>) can contain the following files:

* *function_app.py*: Functions along with their triggers and bindings are defined here.
* *local.settings.json*: Used to store app settings and connection strings when running locally. This file doesn't get published to Azure.
* *requirements.txt*: Contains the list of Python packages the system installs when publishing to Azure.
* *host.json*: Contains configuration options that affect all functions in a function app instance. This file does get published to Azure. Not all options are supported when running locally.
* *blueprint.py*: (Optional) Functions that are defined in a separate file for logical organization and grouping, that can be referenced in `function_app.py`.    
* *.vscode/*: (Optional) Contains store VSCode configuration.
* *.venv/*: (Optional) Contains a Python virtual environment used by local development.
* *Dockerfile*: (Optional) Used when publishing your project in a custom container.
* *tests/*: (Optional) Contains the test cases of your function app.
* *.funcignore*: (Optional) Declares files that shouldn't get published to Azure. Usually, this file contains `.vscode/` to ignore your editor setting, `.venv/` to ignore local Python virtual environment, `tests/` to ignore test cases, and `local.settings.json` to prevent local app settings being published.
  
## Developing your first Python function using VS Code

If you have not already, please checkout our [quickstart](https://aka.ms/fxpythonquickstart) to get you started with Azure Functions developments in Python.

## Publishing your function app to Azure
  
For more information on deployment options for Azure Functions, please visit this [guide](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python#publish-the-project-to-azure).

## Next Steps
  
To learn more specific guidance on developing Azure Functions with Python, please visit [Azure Functions Developer Python Guide](https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=asgi%2Capplication-level).