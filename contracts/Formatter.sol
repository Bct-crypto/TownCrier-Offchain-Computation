contract Formatter {

  function stringToUint(string s)
  internal returns (uint result) {
    bytes memory b = bytes(s);
    uint i;
    result = 0;
    for (i = 0; i < b.length; i++) {
      uint c = uint(b[i]);
      if (c >= 48 && c <= 57) {
        result = result * 10 + (c - 48);
      }
    }
  }

  function bytesConcat(bytes _a, bytes _b)
  internal returns (bytes) {
    bytes memory combined;
    uint i = 0;
    uint j = 0;

    for (i = 0; i < _a.length; i++) combined[j++] = _a[i];
    for (i = 0; i < _b.length; i++) combined[j++] = _b[i];

    return combined;
  }

}
