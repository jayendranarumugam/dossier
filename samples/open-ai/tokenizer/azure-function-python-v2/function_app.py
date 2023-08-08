import azure.functions as func
import json
import logging
import tiktoken

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)

@app.route(route="encodings")
def Encodings(req: func.HttpRequest) -> func.HttpResponse:
    encodings = tiktoken.list_encoding_names()
    mappings_to_models = tiktoken.model.MODEL_TO_ENCODING
    mappings_to_model_prefixes = tiktoken.model.MODEL_PREFIX_TO_ENCODING

    return func.HttpResponse(json.dumps([encodings, mappings_to_models, mappings_to_model_prefixes]))

@app.route(route="tokenize")
def Tokenize(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    # Check if the request specifies the model; otherwise, default
    # to 'gpt-3.5-turbo'
    model = req.params.get('model')
    if not model:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            model = req_body.get('model')
    # Just fall back to our default...
    if not model:
        model = 'gpt-3.5-turbo'
    
    # Check the request for the input.
    source_text = req.params.get('input')
    if not source_text:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            source_text = req_body.get('input')

    if source_text:
        logging.info(f'Processing source: {source_text} using the {model} model')

        # The first time a model is used, it will take slightly longer to pull the
        # encoding. Tiktoken caches for decreased latency in subsequent runs.
        encoding = tiktoken.encoding_for_model(model)

        token_integers = encoding.encode(source_text)
        num_tokens = len(token_integers)
        token_strs = [str(encoding.decode_single_token_bytes(token)) for token in token_integers]

        response = json.dumps({'encoding_model': model, 'num_tokens': num_tokens, 'token_integers': token_integers, 'token_strings': token_strs})
        return func.HttpResponse(response)
    else:
        logging.warn(f'No input detected')
        return func.HttpResponse(
             "Couldn't find your input text to tokenize. Either GET with an 'input' parameter or POST with a JSON body parameter 'input' (e.g., '{'input': 'my text'}')",
             status_code=422
        )