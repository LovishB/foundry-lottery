// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Script} from "forge-std/Script.sol"; //importing standard scripting lib


contract HelperConfig is Script {
    
    struct NetworkConfig {
        uint256 subscriptionId;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 entranceFee;
        uint256 raffleInterval; 
        address vrfCoordinator;
    }

    //in the constructor we check the chainID of block and return network config
    NetworkConfig public activeNetworkConfig;
    constructor() {
         if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        return NetworkConfig({
            subscriptionId: 0, // Replace with your Sepolia subscription ID
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 500000,
            entranceFee: 0.01 ether,
            raffleInterval: 30, // 30 seconds
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
        });
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
       return NetworkConfig({
            subscriptionId: 0, // Replace with your Mainnet subscription ID
            gasLane: 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef,
            callbackGasLimit: 500000,
            entranceFee: 0.1 ether,
            raffleInterval: 30, // 30 seconds
            vrfCoordinator: 0x271682DEB8C4E0901D1a1550aD2e64D568E69909
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        // If we already have an active network config for Anvil, return it
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        // Deploy mocks
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(
            0.25 ether, // baseFee
            1e9, // gasPriceLink
            4e15 //link token
        );
        vm.stopBroadcast();

        return NetworkConfig({
            subscriptionId: 0,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 500000,
            entranceFee: 0.01 ether,
            raffleInterval: 30, // 30 seconds
            vrfCoordinator: address(vrfCoordinatorMock)
        });
    }
}