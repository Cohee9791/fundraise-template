// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;
    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        (bool callSuccess, ) = payable(i_owner).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }

    ///getters
    function getAddressToAmountFunded(
        address funderAddress
    ) public view returns (uint256) {
        return addressToAmountFunded[funderAddress];
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }
}
