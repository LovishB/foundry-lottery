/* always try to follow this layout while wrtting contract code
1) Layout of Contract:
version
imports
errors
interfaces/libraries/contracts

2) Type declarations
State variables
Events
Modifiers
Functions

3) Layout of Functions:
constructor
receive function (if exists)
fallback function (if exists)
external
public
internal
private
view & pure functions */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A sample Raffle/Lottery Contract
 * @author Lovish Badlani
 * @notice This contract is for creating a sample lottery
 * @dev This implements the Chainlink VRF Version 2
 */
contract Raffle is VRFConsumerBaseV2Plus {  //'is' means extends(inheritance)
    /* Errors */
    error Raffle__SendMoreToEnterRaffle(); //give prefix(Raffle) for better reading

    /* State variables */
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_raffleInterval;
    address payable[] private s_players; //made the address payble array as who ever wins will get paid
    uint256 private s_lastRaffleTimeStamp;


    /* Events */
    //events are usually function name in reverse for readablity
    //indexed use more gas and can be decoded wihtout ABI
    //non indexed take less gas and need ABI to decode
    event RaffleEnter(
        address indexed player
    );

    constructor(uint256 entranceFee, uint256 raffleInterval, address vrfCoordinator)
            VRFConsumerBaseV2Plus(vrfCoordinator) { //passed vrf cordinator here
        i_entranceFee = entranceFee;
        i_raffleInterval = raffleInterval;
        s_lastRaffleTimeStamp = block.timestamp;
    }

    /* Functions */
    function enterRaffle() external payable {
        if(msg.value < i_entranceFee) { //if is more gas effecient than require
            revert Raffle__SendMoreToEnterRaffle(); //revert with error
        }
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender); //Emit event when a player joins raffle
    }

    function fulfillRandomWords(uint256, /* requestId */ uint256[] calldata randomWords) internal override {
    }

    /* Getter Functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleInterval() public view returns (uint256) {
        return i_raffleInterval;
    }

    function getLastRaffleTimeStamp() public view returns (uint256) {
        return s_lastRaffleTimeStamp;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getNumberOfPlayer() public view returns (uint256) {
        return s_players.length;
    }
}