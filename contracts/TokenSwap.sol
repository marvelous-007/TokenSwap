// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IUSDT.sol";

contract TokenSwap is ERC20{

    IUSDT usdt;

     AggregatorV3Interface internal priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
      AggregatorV3Interface internal priceFeedLive = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    uint256 TokenPrice = 1;

    mapping(address=>uint) public balance;

    event swapDetail(uint);
    using SafeCast for int256;
    using SafeMath for uint256;

    constructor(string memory _name, string memory _symbol, uint256 _amount) ERC20(_name, _symbol){
        _mint(address(this), _amount);
        // priceFeed= AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
         priceFeedLive = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
         usdt = IUSDT(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    // function getLatestPrice() public view returns (int) {
    //     (
    //         /* uint80 roundID */,
    //         int price,
    //         /*uint startedAt*/,
    //         /*uint timeStamp*/,
    //         /*uint80 answeredInRound*/
    //     ) = priceFeed.latestRoundData();
    //     return price;
    // }

    function getLivePrice() public view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeedLive.latestRoundData();
        return price;
    }

    function burnToken(address account, uint Amount) public {
        _burn(account, Amount);
    }

    // function swap(uint amountInUsd ) payable public returns(uint256 result){
    //     uint EthUSD = uint(getLatestPrice());
    //     uint PriceDetermine = amountInUsd/((EthUSD)/1e8);

    //     uint Token = PriceDetermine * TokenPrice;

    //      uint sendToken = Token /100;

    //      result = sendToken;

    //     transfer(msg.sender, result);
    //     emit swapDetail(result);
    //     return result;
    // }

    function swapme(uint amountInUsd ) payable public returns(uint256 result){
        require(amountInUsd<= usdt.balanceOf(msg.sender), "insufficient Amount");
        uint EthUSD = uint(getLivePrice());
        uint PriceDetermine = amountInUsd/((EthUSD));

        uint Token = PriceDetermine * TokenPrice;

         uint sendToken = Token;

         result = sendToken;
        usdt.transferFrom(msg.sender, address(this), amountInUsd);
        balance[msg.sender] += result; 
        emit swapDetail(result);
        return result;
    }

    function getUserBalance() public view returns(uint256 result){
       result = balance[msg.sender];

    }

}