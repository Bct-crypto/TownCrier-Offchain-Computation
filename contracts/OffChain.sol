import './Formatter.sol';
import './OnChain.sol';
import './TownCrier.sol';


contract OffChain {
  Formatter formatter;
  OnChain onChain;
  TownCrier townCrier;

  int bitStampID;
  int coinbaseID;
  int coinMarketCapID;
  uint bitStampPrice;
  uint coinbasePrice;
  uint coinMarketCapPrice;

  function OffChain()
  public {
    townCrier = new TownCrier();
    onChain = new OnChain();
  }

  function execute()
  public {
    getBitStampPrice();
    getCoinbasePrice();
    getCoinMarketCapPrice();
  }

  function compareAverage()
  ensureAllPricesReceived
  {
    if (averagePrice() > 300000) {
      onChain.report(true);
    } else {
      onChain.report(false);
    }
  }

  function getBitStampPrice()
  {
    bitStampID = townCrier.request(21, this, bytes4(keccak256('bitStampCallback(int256,uint256)')), 0,
      "['https://www.bitstamp.net/api/ticker/',[],[],[],['json$/last>>string'],0]");
  }

  function bitStampCallback(int _requestID, string _price)
  public
  {
    require(_requestID == bitStampID && msg.sender == address(townCrier));
    bitStampPrice = formatter.stringToUint(_price);
    compareAverage();
  }

  function getCoinbasePrice()
  {
    decryptID = decrypter.request(this, bytes4(keccak256('coinbaseCallback(uint256)')), _data);
  }

  function getCoinbasePrice(bytes _data)
  external
  {
    string memory queryStart = "['curl https://api.coinbase.com/v2/prices/BTC-USD/buy',[],[],['Authorization: Bearer ";
    bytes memory query = bytesConcat(bytes(queryStart), bytes(queryStart));
    coinbaseID = townCrier.request(21, this, bytes4(keccak256('coinbaseCallback(int256,uint256)')), 0,
      "['curl https://api.coinbase.com/v2/prices/BTC-USD/buy',[],[],['Authorization: Bearer abd90df5f27a7b170cd775abf89d632b350b7c1c9d53e08b340cd9832ce52c2c'],['json$/data/amount>>string'],0]");
  }

  function coinbaseCallback(int _requestID, string _price)
  public
  {
    require(_requestID == coinbaseID && msg.sender == address(townCrier));
    coinbasePrice = formatter.stringToUint(_price);
    compareAverage();
  }

  function getCoinMarketCapPrice()
  {
    coinMarketCapID = townCrier.request(21, this, bytes4(keccak256('coinMarketCapCallback(int256,uint256)')), 0,
      "['https://api.coinmarketcap.com/v1/ticker/bitcoin/',[],[],[],['json$/0/price_usd>>string'],0]");
  }

  function coinMarketCapCallback(int _requestID, string _price)
  public
  {
    require(_requestID == coinMarketCapID && msg.sender == address(townCrier));
    coinMarketCapPrice = formatter.stringToUint(_price);
    compareAverage();
  }

  function averagePrice() returns (uint average) {
    uint total = bitStampPrice + coinbasePrice + coinMarketCapPrice;
    return total / 3;
  }

  // MODIFIERS

  modifier ensureAllPricesReceived() {
    if (bitStampPrice != 0 &&
      coinbasePrice != 0 &&
      coinMarketCapPrice != 0)
    _;
  }

}
