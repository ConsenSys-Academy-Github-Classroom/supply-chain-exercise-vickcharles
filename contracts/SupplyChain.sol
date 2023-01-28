// SPDX-License-Identifier: MIT
pragma solidity >=0.8.8 <0.9.0;

contract SupplyChain {

  enum State {
    ForSale, 
    Sold, 
    Shipped, 
    Received
  }

  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }

  address public owner;
  mapping(uint => Item) items;
  uint public skuCount;


  /* 
   * Events
   */
  event LogForSale(uint sku);
  event LogSold(uint sku);
  event LogShipped(uint sku);
  event LogReceived(uint sku);


  /* 
   * Modifiers
  */

  modifier isOwner() {
    require (msg.sender == owner); 
    _;
  }


  modifier verifySeller(uint _sku) { 
    require (items[_sku].seller == msg.sender); 
    _;
  }

  modifier verifyBuyller(uint _sku) { 
    require (items[_sku].buyer == msg.sender); 
    _;
  }

  modifier checkValue(uint _sku) {
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
    _;
  }

  // For each of the following modifiers, use what you learned about modifiers
  // to give them functionality. For example, the forSale modifier should
  // require that the item with the given sku has the state ForSale. Note that
  // the uninitialized Item.State is 0, which is also the index of the ForSale
  // value, so checking that Item.State == ForSale is not sufficient to check
  // that an Item is for sale. Hint: What item properties will be non-zero when
  // an Item has been added?
  modifier forSale(uint _sku) {
    require(items[_sku].state == State.ForSale, "this item is not for sale");
    _;
  }

  modifier sold(uint _sku) {
    require(items[_sku].state == State.Sold, "this is not sold");
    _;
  }

  modifier shipped(uint _sku) {
    require(items[_sku].state == State.Shipped, "this is not Shipped");
    _;
  }

  modifier received(uint _sku) {
    require(items[_sku].state == State.Received, "this is not Received");
    _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    items[skuCount] = Item({
     name: _name, 
     sku: skuCount, 
     price: _price, 
     state: State.ForSale, 
     seller: payable(msg.sender), 
     buyer: payable(address(0))
    });
    
    skuCount = skuCount  + 1;
    emit LogForSale(skuCount);
    return true;
  }

  // Implement this buyItem function. 
  // 1. it should be payable in order to receive refunds
  // 2. this should transfer money to the seller, 
  // 3. set the buyer as the person who called this transaction, 
  // 4. set the state to Sold. 
  // 5. this function should use 3 modifiers to check 
  //    - if the item is for sale, 
  //    - if the buyer paid enough, 
  //    - check the value after the function is called to make 
  //      sure the buyer is refunded any excess ether sent. 
  // 6. call the event associated with this function!
  function buyItem(uint sku) public payable forSale(sku) checkValue(sku)  {
    Item storage item = items[sku];
    require(msg.value >= item.price, "no enough ether");
    uint amontRefund= msg.value - item.price;
    uint toPay = msg.value - amontRefund;
    
    item.buyer = payable(msg.sender);
    item.state = State.Sold;
    item.seller.transfer(toPay);

  
    emit LogSold(sku);
  }

  // 1. Add modifiers to check:
  //    - the item is sold already 
  //    - the person calling this function is the seller. 
  // 2. Change the state of the item to shipped. 
  // 3. call the event associated with this function!
  function shipItem(uint sku) public sold(sku) verifySeller(sku) {
    Item storage item = items[sku];
    item.state = State.Shipped;
    emit LogShipped(sku);
  }

  // 1. Add modifiers to check 
  //    - the item is shipped already 
  //    - the person calling this function is the buyer. 
  // 2. Change the state of the item to received. 
  // 3. Call the event associated with this function!
  function receiveItem(uint sku) public shipped(sku) verifyBuyller(sku) {
    Item storage item = items[sku];
    item.state = State.Received;
    emit LogReceived(sku);
  }

  // Uncomment the following code block. it is needed to run tests
   function fetchItem(uint _sku) public view 
     returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
   { 
     name = items[_sku].name; 
     sku = items[_sku].sku; 
     price = items[_sku].price; 
     state = uint(items[_sku].state); 
     seller = items[_sku].seller; 
     buyer = items[_sku].buyer; 
     return (name, sku, price, state, seller, buyer);
   } 
}
