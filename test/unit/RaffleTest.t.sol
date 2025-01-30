// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol"; //importing standard testing lib
import {Raffle} from "../..//src/Raffle.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle, Raffle__SendMoreToEnterRaffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/*
Unit tests 
- individual components of contract
*/
contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;

    //we have to copy events we want to test(due to limited visiblity)
    event RaffleEnter(
        address indexed player
    );
    event WinnerPicked(
        address indexed player
    );

    address USER = makeAddr("user"); //this is a feature of foundry to create a new user & use to make txs

    //instead of same code in each test, we can just call modifier and save code
    modifier fundUser() {
        vm.deal(USER, 10e19);
         vm.startPrank(USER); //this setup will make all tx using USER in a test
        _;
        vm.stopPrank();
    }

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();
    }

    function testRaffleInitialStates() public view {
        assertEq(raffle.getRaffleInterval(), 30);
        assertEq(raffle.getEntranceFee(), 0.01 ether);
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testEnterRaffleRevertLessFee() public fundUser {
        vm.expectRevert(Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testEnterRaffleSuccessful() public fundUser {
        raffle.enterRaffle{value: 0.011 ether}();
        assertEq(raffle.getPlayer(0), address(USER));
    }

    function testEnterRaffleMultipleTimes() public fundUser {
        raffle.enterRaffle{value: 0.011 ether}();
        assertEq(raffle.getPlayer(0), address(USER));
        raffle.enterRaffle{value: 0.011 ether}();
        assertEq(raffle.getPlayer(1), address(USER));
    }

    function testRaffleEnterEmit() public fundUser {
        vm.expectEmit(
            true, //indexed topic 1 (address)
            false, // no indexed topic 2
            false, // no indexed topic 3
            false // no non-indexed data
        );
        emit RaffleEnter(USER); //this tells to expect which event

        raffle.enterRaffle{value: 0.011 ether}();
    }


}