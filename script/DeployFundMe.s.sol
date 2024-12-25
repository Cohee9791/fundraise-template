// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
contract DeployScript is Script {
    function run() external returns (FundMe) {
        //create a mock contract
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        return fundMe;
    }

    receive() external payable {}
}
