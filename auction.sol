
contract Acution{

    address payable public beneficiary;

    uint public auctionEnd;
    address public hightestBidder;
    uint public highestBid;
    mapping(address => uint) pendingReturns;
    mapping(address => uint256) public lastBidTime;
    bool ended;

    uint256 public timeExtension = 5 minutes;
    uint256 public timeWeighted = 5 minutes;
    uint256 public triggerTime = 1 minutes; 
    uint256 public cooldown = 5 seconds; 
    uint256 public weighted = 2; 

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingtime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEnd = block.timestamp + _biddingtime;
    }

    function bid() public payable {
        require(block.timestamp <= auctionEnd);
        require(msg.value > highestBid);



        uint256 last = lastBidTime[msg.sender];
        require(last + cooldown < block.timestamp, "waitting the bid cooldown");
        lastBidTime[msg.sender] = block.timestamp;


        if (auctionEnd < block.timestamp + timeWeighted) {
            require(msg.value >= highestBid * weighted, "bid price must be equ highestBid * Weighted ");
        }

        // Extend the game time by timeExtension
        if (auctionEnd < block.timestamp + triggerTime) {
            auctionEnd += timeExtension;
        }

        if (highestBid != 0) {
            pendingReturns[hightestBidder] += highestBid;
        }

        hightestBidder = msg.sender;
        highestBid = msg.value;

        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns(bool) {
        uint amount = pendingReturns[msg.sender];

        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable (msg.sender).transfer(amount);
        }

        return true;
    }

    function endAuction() public {
        require (block.timestamp >= auctionEnd, "Auction not yet ended" );
        require(!ended, "auction End has already been called");

        ended = true;
        emit  AuctionEnded(hightestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}