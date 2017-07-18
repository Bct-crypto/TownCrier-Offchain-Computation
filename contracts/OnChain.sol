contract OnChain {

  event Report(bool value1);
  event Report(bytes value1);
  event Report(bytes32 value1);
  event Report(int256 value1);
  event Report(uint256 value1);

  function report(bool _value1)
  public {
    Report(_value1);
  }

  function report(bytes _value1)
  public {
    Report(_value1);
  }

  function report(bytes32 _value1) {
    Report(_value1);
  }

  function report(int _value1) {
    Report(_value1);
  }

  function report(uint _value1) {
    Report(_value1);
  }

}
