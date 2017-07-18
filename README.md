# TC++

## Town Crier Request Types

- 1 Flight departure delay
- 3 Stock ticker
- 4 UPS tracking
- 5 Coin market price
- 6 Weather
- 9 WolframAlpha
- 10 Random Number Generator (new)
- 16 Flight departure delay
- 17 Steam Transaction
- 21 Custom HTTP GET (new)
- 22 Custom HTTP POST (new)
- 23 Custom Computation (new)

### 21 Custom GET Request

Parameters
- URL string to be interpolated with the URL parameters
- Array of URL paramters to be inserted into the URL string
- Array of keys and values to be added as a query to the URL
- Array of headers to be included with the request
- Array of paths to parse out of the response(see TC Path section)
- Encrypted variable indicator

### 22 Custom POST Request

Parameters
- URL string to be interpolated with the URL parameters
- Array of URL paramters to be inserted into the URL string
- Array of keys and values to be added as a the body of the request
- Array of headers to be included with the request
- Array of paths to parse out of the response(see TC Path section)
- Encrypted variable indicator

### 23 Custom Computation

Runs custom solidity code to allow for secure and private off chain data retreival, computation, and formatting. Execution is entered by calling the `OffChain` contract's `report` function, with the parameters expected to be fed back on chain. If the report function is not called, the contract continues running until there are no longer log events to respond to, or the computation runs out of gas.

Parameters:
- Custom Computation ID(obtained from side loading)
- Data to be fed into the contract's `execute` function at the time of execution

Side loaded parameters are sent in as JSON with two top level keys, `data` and `key`. The `data` parameter can either be a JSON object or a string of encrypted JSON, if it is encrypted then the `key` parameter is optional. The keys present in the `data` object must be:

- gasLimit: The maximum amount of gas to charge your contract.
- solidity: A JSON object of the Solidity contracts to run. The keys should be the file paths as they are referred to in the import statements. A single contract named `OffChain`, with a single function named `execute` is required to be passed in.

The side loaded API responds with a JSON object with two top level keys, `data` and `signature`. The `signature` value is a signature from the Town Crier messaging key of the stringified `data` object. The `data` object contains:
- `id`: The Custom Computation ID used to refer to this computation from SGX in the future.
- `publicKey`: The public key of a private key that is accessible only when using this Custom Computation
- `hash`: The hash of the stringified `data` object which was passed in with the originating request.

## TC Path

The TC Path is a format similar to XPath and JsonPath, but generalized to work between both. The first part of the path is the response type, either 'XML' or 'JSON'. The second part begins with a dollar sign followed by a slash, followed by a path following typical XPath/JsonPath syntax. The final piece is two right arrows, ">>", followed by the EVM type you would like the value to be translated into. If the format selected for the value returned cannot reasonably be formated, then an error response will be returned to your contract.
