// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Flash Auction Contract with Bid Tracking and Refunds
/// @author 
/// @notice This contract allows users to participate in a flash auction with bid history, partial withdrawals, and automatic duration extensions.
contract FlashAuction {
    struct IndividualBid {
        uint amount;
        uint timestamp;
        bool refunded;
    }

    address public owner;
    address public highestBidder;
    uint public highestBid;
    uint public startTime;
    uint public initialDuration = 2 minutes;
    uint public currentDuration;
    bool public ended;

    mapping(address => IndividualBid[]) public bidHistory;
    mapping(address => uint) public participantBalances;
    address[] public participants;

    event NewBid(address indexed bidder, uint amount, uint newEndTime);
    event AuctionExtended(uint previousEndTime, uint newEndTime);
    event AuctionEnded(address winner, uint amount);
    event FundsWithdrawn(address indexed to, uint amount);
    event PartialRefund(address indexed bidder, uint amount);

    constructor() {
        owner = msg.sender;
        startTime = block.timestamp;
        currentDuration = initialDuration;
    }

    modifier auctionActive() {
        require(!ended, "Subasta finalizada");
        require(block.timestamp <= startTime + currentDuration, "Tiempo terminado");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "No eres el owner");
        _;
    }

    function placeBid() external payable auctionActive {
        require(msg.value > 0, "Debes enviar ETH");

        uint total = participantBalances[msg.sender] + msg.value;
        uint minimumRequired = highestBid + (highestBid * 5) / 100;
        require(total >= minimumRequired, "La oferta debe superar en al menos 5%");
        
        uint previousTime = startTime + currentDuration;
        currentDuration += 5 minutes;
        emit AuctionExtended(previousTime, startTime + currentDuration);
        
        if (bidHistory[msg.sender].length == 0) {
            participants.push(msg.sender);
        }

        bidHistory[msg.sender].push(IndividualBid({
            amount: msg.value,
            timestamp: block.timestamp,
            refunded: false
        }));

        participantBalances[msg.sender] = total;
        highestBidder = msg.sender;
        highestBid = total;

        emit NewBid(msg.sender, msg.value, startTime + currentDuration);
    }

    function withdrawExcess(uint amount) external auctionActive {
        require(amount > 0, "Monto debe ser positivo");
        uint excess = participantBalances[msg.sender];

        if (msg.sender == highestBidder) {
            excess -= highestBid;
        }

        require(excess >= amount, "Fondos insuficientes");

        participantBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit PartialRefund(msg.sender, amount);
    }

    function finalizeAuction() external onlyOwner {
        require(!ended, "Ya finalizo");
        require(block.timestamp >= startTime + currentDuration, "Aun no termina");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
    }

    function withdraw() external {
        require(ended, "Subasta no finalizada");
        require(msg.sender != highestBidder, "Ganador no puede retirar");

        uint deposit = participantBalances[msg.sender];
        require(deposit > 0, "Nada para retirar");

        uint fee = (deposit * 2) / 100;
        uint refund = deposit - fee;

        participantBalances[msg.sender] = 0;
        payable(msg.sender).transfer(refund);
        emit FundsWithdrawn(msg.sender, refund);
    }

    function withdrawOwnerFunds() external onlyOwner {
        require(ended, "Subasta no finalizada");
        require(address(this).balance > 0, "Sin balance disponible");

        uint amount = highestBid;
        uint fee = (amount * 2) / 100;
        uint net = amount - fee;

        payable(owner).transfer(net);
        emit FundsWithdrawn(owner, net);
    }

    function getAllBids() external view returns (
        address[] memory addresses,
        uint[] memory amounts,
        uint[] memory timestamps,
        bool[] memory statuses
    ) {
        uint totalBids;
        for (uint i = 0; i < participants.length; i++) {
            totalBids += bidHistory[participants[i]].length;
        }

        addresses = new address[](totalBids);
        amounts = new uint[](totalBids);
        timestamps = new uint[](totalBids);
        statuses = new bool[](totalBids);

        uint counter;
        for (uint i = 0; i < participants.length; i++) {
            for (uint j = 0; j < bidHistory[participants[i]].length; j++) {
                addresses[counter] = participants[i];
                amounts[counter] = bidHistory[participants[i]][j].amount;
                timestamps[counter] = bidHistory[participants[i]][j].timestamp;
                statuses[counter] = bidHistory[participants[i]][j].refunded;
                counter++;
            }
        }

        return (addresses, amounts, timestamps, statuses);
    }

    function timeLeft() external view returns (uint) {
        if (block.timestamp >= startTime + currentDuration || ended) {
            return 0;
        }
        return (startTime + currentDuration) - block.timestamp;
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function getDurations() external view returns (uint initial, uint current) {
        return (initialDuration, currentDuration);
    }
}
