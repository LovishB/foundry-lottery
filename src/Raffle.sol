/* always try to follow this layout while wrtting contract code
1) Layout of Contract:
version
imports
errors
interfaces/libraries/contracts

2) Type declarations
Enums
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

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol"; //imports for random number
import {VRFV2PlusClient} from "@chainlink/contracts/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/v0.8/automation/AutomationCompatible.sol"; //import for automatic calls


/* Errors */
error Raffle__SendMoreToEnterRaffle(); //give prefix(Raffle) for better reading
error Raffle__TransferWinnerFailed();
error Raffle__RaffleNotOpen();

/**
 * @title A sample Raffle/Lottery Contract
 * @author Lovish Badlani
 * @notice This contract is for creating a sample lottery
 * @dev This implements the Chainlink VRF Version 2
 */
contract Raffle is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {  //'is' means extends(inheritance)
    /* Enums */
    enum RaffleState {
        OPEN,
        CALCULATING
    }

    // Chainlink VRF Variables
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    /* State variables */
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_raffleInterval;
    address payable[] private s_players; //made the address payble array as who ever wins will get paid
    address payable private s_recentWinner;
    uint256 private s_lastRaffleTimeStamp;
    RaffleState private s_raffleState;


    /* Events */
    //events are usually function name in reverse for readablity
    //indexed use more gas and can be decoded wihtout ABI
    //non indexed take less gas and need ABI to decode
    event RaffleEnter(
        address indexed player
    );
    event WinnerPicked(
        address indexed player
    );

    constructor(
        uint256 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        uint256 entranceFee, 
        uint256 raffleInterval, 
        address vrfCoordinator
    ) VRFConsumerBaseV2Plus(vrfCoordinator) { //passed vrf cordinator here
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_entranceFee = entranceFee;
        i_raffleInterval = raffleInterval;
        s_lastRaffleTimeStamp = block.timestamp;
    }

    /* Functions */
    /**
     * @dev Function will be called to participate in Raffle
     */
    function enterRaffle() external payable {
        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen(); //do not let players participate if winner is calculated
        }
        if(msg.value < i_entranceFee) { //if is more gas effecient than require
            revert Raffle__SendMoreToEnterRaffle(); //revert with error
        }
        s_players.push(payable(msg.sender));
        emit RaffleEnter(msg.sender); //Emit event when a player joins raffle
    }

    /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * the function checks for all conditions require to call upkeep
     * 1. The time interval has passed between raffle runs.
     * 2. The lottery is open.
     * 3. The contract has ETH.
     * 4. Implicity, your subscription is funded with LINK.
     */
    function checkUpkeep( bytes calldata /* checkData */) public view override 
        returns (bool upkeepNeeded, bytes memory /* performData */) {
       bool upkeep = 
        (s_raffleState == RaffleState.OPEN) && //state should be open
        (s_players.length > 0) && //should have atleast 1 player
        (address(this).balance > 0) && //should have balance to give winner
        ((block.timestamp - s_lastRaffleTimeStamp) > i_raffleInterval); //sufficient time has passed

        return (upkeep, "0x0");
    }

    /**
     * @dev Once `checkUpkeep` is returs `true`, this function is called
     * and it kicks off a Chainlink VRF call to get a random winner.
     */
    function performUpkeep(bytes calldata /* performData */) external override {
        s_raffleState = RaffleState.CALCULATING; //close the lottery until we calculate winner

        //Random number should be from outside blockchain as we are deterministic
        //we request a random number from chainlink VRF, chainlink will call fulfillRandomWords()
        s_vrfCoordinator.requestRandomWords(VRFV2PlusClient.RandomWordsRequest(
            {
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true}))
            })
        );
    }

    /**
     * @dev This is the override function that Chainlink VRF node
     * calls to send the money to the random winner.
     */
    function fulfillRandomWords(uint256, /* requestId */ uint256[] calldata randomWords) internal override {
        //deciding winner
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        emit WinnerPicked(recentWinner); //emit the event when someone wins the lottery

        //resetting lottery
        s_players = new address payable[](0); //reset the players 
        s_lastRaffleTimeStamp = block.timestamp;
        s_raffleState = RaffleState.OPEN; //open the lottery again

        //tx
        (   bool callSuccess, 
            /* bytes dataReturned */
        ) = recentWinner.call{value: address(this).balance}(""); //sending winner funds
        if(!callSuccess) {
            revert Raffle__TransferWinnerFailed();
        }
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

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getRaffleState() public view returns (RaffleState) {
        return s_raffleState;
    }
}