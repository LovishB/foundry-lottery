# Provably Fair Raffle Smart Contract

A decentralized and automated raffle system built with Solidity and Foundry, leveraging Chainlink VRF for verifiable randomness and Chainlink Automation for trustless execution.

## Overview

This smart contract implements a fully automated raffle system where:
- Users can enter by paying an entrance fee
- Winners are selected randomly using Chainlink VRF
- The raffle automatically resets and picks winners using Chainlink Automation
- The system is provably fair and fully decentralized

## Features

- Automated winner selection
- Verifiable random number generation
- Configurable entrance fees
- Customizable raffle intervals
- Multi-network support (Mainnet, Sepolia, Local Anvil)
- Comprehensive test coverage
- Gas-optimized operations

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd raffle-contract
```

2. Install dependencies
```bash
forge install
```

3. Build the project
```bash
forge build
```

### Running Tests

```bash
forge test
```

For detailed test output:
```bash
forge test -vv
```

## Contract Architecture

### Core Components

1. **Raffle.sol**
   - Main contract implementing the raffle logic
   - Handles user entries
   - Manages raffle state
   - Integrates with Chainlink VRF and Automation

2. **DeployRaffle.s.sol**
   - Deployment script
   - Handles network-specific configurations
   - Sets up Chainlink VRF consumer

3. **HelperConfig.s.sol**
   - Network configuration management
   - Provides network-specific parameters
   - Handles mock deployments for local testing

### Key Features Explained

#### Entrance Fee
- Configurable minimum entry fee
- Prevents spam entries
- Network-specific pricing

#### Random Number Generation
- Uses Chainlink VRF for verifiable randomness
- Immune to miner/validator manipulation
- Multi-block confirmation for security

#### Automation
- Chainlink Automation for trustless execution
- Configurable raffle intervals
- Automatic winner selection and prize distribution

## Configuration

### Network Configurations

The contract supports multiple networks with different configurations:

1. **Sepolia Testnet**
```solidity
subscriptionId: <your-subscription-id>
gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c
callbackGasLimit: 500000
entranceFee: 0.01 ether
raffleInterval: 30 seconds
```

2. **Ethereum Mainnet**
```solidity
subscriptionId: <your-subscription-id>
gasLane: 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef
callbackGasLimit: 500000
entranceFee: 0.1 ether
raffleInterval: 30 seconds
```

3. **Local Anvil**
- Automatically deploys required mocks
- Creates and funds VRF subscription
- Uses test configuration values

## Testing

### Test Coverage

The contract includes comprehensive tests covering:

- Initial state verification
- Entry validation
- Multiple participant handling
- Random number generation
- Winner selection
- Prize distribution
- Event emission
- Edge cases and error conditions

### Test Commands

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test testFunctionName

# Run tests with gas reporting
forge test --gas-report

# Run tests with coverage
forge coverage
```

## Deployment

1. Set up environment variables
```bash
cp .env.example .env
# Add your private key and RPC URLs
```

2. Deploy to testnet
```bash
forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

## Security Considerations

- Uses OpenZeppelin contracts for standard implementations
- Implements checks-effects-interactions pattern
- Includes reentrancy protection
- Gas-optimized for cost-effective operations
- Thoroughly tested edge cases
- Verifiable random number generation

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Chainlink VRF for secure random number generation
- Chainlink Automation for trustless execution
- Foundry for development framework
- OpenZeppelin for contract standards