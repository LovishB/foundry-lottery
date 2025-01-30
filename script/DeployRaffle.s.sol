// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol"; //importing standard scripting lib
import {Raffle} from "../src/Raffle.sol"; //import contract 
import {HelperConfig} from "./HelperConfig.s.sol"; //importing networks
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";


contract DeployRaffle is Script {

    function run() external returns (Raffle, HelperConfig) {
        //Anything before broadcast is not a real 'tx'
        HelperConfig helperConfig = new HelperConfig(); //deploying in temporary env as we don't want it deployed for gas usage
        (
            uint256 subscriptionId,
            bytes32 gasLane,
            uint32 callbackGasLimit,
            uint256 entranceFee,
            uint256 raffleInterval,
            address vrfCoordinator
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            subscriptionId,
            gasLane,
            callbackGasLimit,
            entranceFee,
            raffleInterval,
            vrfCoordinator
        );

        if (block.chainid == 31337) { // If we're on Anvil We have to programtically add our mock coordinator as consumer
            VRFCoordinatorV2_5Mock mock = VRFCoordinatorV2_5Mock(vrfCoordinator);
            mock.addConsumer(subscriptionId, address(raffle));
        }


        vm.stopBroadcast();
        return (raffle, helperConfig);
    }
}