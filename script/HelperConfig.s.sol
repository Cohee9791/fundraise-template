//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mocks/MockV3Aggregator.t.sol";
contract HelperConfig is Script {
    //？struct节省gas，所以不用mapping
    struct NetworkConfig {
        address priceFeed;
    }
    NetworkConfig public activeNetworkConfig;
    MockV3Aggregator mockPriceFeed;
    uint8 public constant decimal = 8;
    int256 public constant Intial_Price = 2000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        //避免重造合约
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        //创建合约并返回合约地址
        vm.startBroadcast();
        mockPriceFeed = new MockV3Aggregator(decimal, Intial_Price);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
