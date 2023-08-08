# Sample tokenizer for Open AI models

This is a sample Azure Function written in Python to provide details about how text input will be tokenized based on Open AI models. It is a wrapper around the [tiktoken](https://github.com/openai/tiktoken) library.

## Usage

The function accepts two inputs -- a required string of text (`input`) to tokenize, and optionally an Open AI model name (`model`) to determine the encoding (e.g., *gpt-3.5-turbo*). If the model is not included, it will default to use *gpt-3.5-turbo*. These inputs may be either passed as query parameters in a GET request or as part of the body of a POST request.

Example GET request:
```http
GET /api/tokenize?input=tokenize%20me&model=gpt-4
```

Example POST request:
```http
POST /api/tokenize
Content-Type: application/json

{
  "input": "tokenize me",
  "model": "gpt-4"
}
```

If successful, the function returns an HTTP response of 200 with a JSON object with the schema:

```json
{
  "encoding_model": "string",
  "num_tokens": 0,
  "token_integers": [0],
  "token_strings": ["string"]
}
```

If the input text cannot be determine, the function returns an HTTP 422 response code.

## Building

See the [getting started documentation](getting_started.md).

## Deployment

See the guide in our [Azure Functions documentation](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python#publish-the-project-to-azure) for instructions on how to deploy this function to Azure.

## Optimizations

- Additional work is done to decode the token integers into strings, so if not required an optimization would be to remove this step.

