import './Formatter.sol';
import './OnChain.sol';
import './TownCrier.sol';
import './NativeDecryption.sol';


contract OffChain is Formatter {
  OnChain onChain;
  TownCrier townCrier;
  NativeDecryption decrypter;

  int bitStampID;
  int coinbaseID;
  int coinMarketCapID;
  uint decryptID;
  uint bitStampPrice;
  uint coinbasePrice;
  uint coinMarketCapPrice;

  function OffChain()
  public {
    townCrier = new TownCrier();
    onChain = new OnChain();
  }

  function execute(bytes _data)
  public {
    getBitStampPrice();
    decryptCoinbaseCredentials(_data);
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
    bitStampPrice = stringToUint(_price);
    compareAverage();
  }

  function decryptCoinbaseCredentials(bytes _data)
  {
    decryptID = decrypter.request(this, bytes4(keccak256('getCoinbasePrice(uint256,bytes)')), _data);
  }

  function getCoinbasePrice(uint256 _requestID, bytes _key)
  public
  {
    require(_requestID == decryptID && msg.sender == address(decrypter));

    string memory queryStart = "['curl https://api.coinbase.com/v2/prices/BTC-USD/buy',[],[],['Authorization: Bearer ";
    string memory queryEnd = "'],['json$/data/amount>>string'],0]";
    bytes memory query = bytesConcat(bytes(queryStart), _key);
    query = bytesConcat(query, bytes(queryEnd));

    coinbaseID = townCrier.request(21, this, bytes4(keccak256('coinbaseCallback(int256,uint256)')), 0, query);
  }

  function coinbaseCallback(int _requestID, string _price)
  public
  {
    require(_requestID == coinbaseID && msg.sender == address(townCrier));
    coinbasePrice = stringToUint(_price);
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
    coinMarketCapPrice = stringToUint(_price);
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
