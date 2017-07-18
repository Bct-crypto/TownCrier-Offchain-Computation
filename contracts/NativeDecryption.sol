import './Ownable.sol';


contract NativeDecryption is Ownable {
  struct Request {
      address callbackAddr;
      bytes4 callbackFID;
  }
  Request[] requests;

  event Decrypt(uint requestID, bytes data);

  uint requestCounter = 1;

  function request(address _requester, bytes4 _fID, bytes _cipherText) returns(uint requestID)
  {
    requestID = requestCounter;
    requestCounter = requestCounter + 1;

    Decrypt(requestID, _cipherText);

    requests[requestID].callbackAddr = _requester;
    requests[requestID].callbackFID = _fID;

    return requestID;
  }

  function deliver(uint _requestID, bytes _data) {
    Request request = requests[_requestID];
    require(request.callbackAddr.call(request.callbackFID, _data));
  }
}
