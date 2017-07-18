import './OnChain.sol';
import './TownCrier.sol';


contract OffChain {
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
    OnChain onChain = new OnChain();
    if (averagePrice() > 300000) {
      onChain.report(uint(1));
    } else {
      onChain.report(uint(0));
    }
  }

  function getBitStampPrice()
  {
    bitStampID = townCrier.request(21, this, bytes4(keccak256('bitStampCallback(uint256)')), 0,
      "['https://www.bitstamp.net/api/ticker/',[],[],[],['json$/last>>uint256'],0]");
  }

  function bitStampCallback(int _requestID, uint _price)
  public
  {
    require(_requestID == bitStampID);
    bitStampPrice = _price;
    compareAverage();
  }

  function getCoinbasePrice()
  {
    coinbaseID = townCrier.request(21, this, bytes4(keccak256('coinbaseCallback(uint256)')), 0,
      "['curl https://api.coinbase.com/v2/prices/BTC-USD/buy',[],[],['Authorization: Bearer abd90df5f27a7b170cd775abf89d632b350b7c1c9d53e08b340cd9832ce52c2c'],['json$/data/amount>>uint256'],0]");
  }

  function coinbaseCallback(int _requestID, uint _price)
  public
  {
    require(_requestID == coinbaseID);
    coinbasePrice = _price;
    compareAverage();
  }

  function getCoinMarketCapPrice()
  {
    coinMarketCapID = townCrier.request(21, this, bytes4(keccak256('coinMarketCapCallback(uint256)')), 0,
      "['https://api.coinmarketcap.com/v1/ticker/bitcoin/',[],[],[],['json$/0/price_usd>>uint256'],0]");
  }

  function coinMarketCapCallback(int _requestID, uint _price)
  public
  {
    require(_requestID == coinMarketCapID);
    coinMarketCapPrice = _price;
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
