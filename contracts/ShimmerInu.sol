// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;

/*
--------------------------------
| -> SHIMMER INU MEME TOKEN <- |
--------------------------------
----------------------------------------
| -> https://medium.com/@shimmerinu <- |
----------------------------------------
- Total supply minted
- No tax in transfer
- No pre-minted tokens for dev
- LPs locked in the contract of the token
- Burning Mechanism
- Governance feature
- Free tokens for holders of the NFT collections:
    - LUMI: 3333 NFTs
    - IOTABOTS: 1337 NFTs
    - OGEAPE: 1074 NFTs
    - LILAPE: 5370 NFTs = 11.114 Claims

-> Holders can claim 29.962.209 M of Shimmer Inu per NFT <-
-> 11.114 * 29.962.209 M = 332.999.990.826 B Claimables ( without decimal precision ) <-
--------------
| Tokenomics |
--------------
- Name: Shimmer Inu
- Symbol: $SHIMMERINU
- Decimals: 18
- Total Supply: 3.300 T
- Total for Burn: 2.640 T (80%)
- Total for Holders: 330 B (10%)
- Total for Liquidity: 330 B (10%) {
    - ShimmerSea  -> 110 B / 10 SMR
    - TangleSwap  -> 110 B / 10 SMR
    - IotaBee     -> 110 B / 10 SMR
---------------------
| Burning Mechanism |
---------------------
- Every month up to a maximum of 9 months, anyone can call the `burn()` function.
- Each time anyone call the `burn()` function, 293.333.333.333 B of Shimmer Inu will be burned.
- In month 9, anyone can call the `burnUnclaimed()` function, this will burn all the Shimmer Inu that are in the contract.
--------------------
| ¿ How to claim ? |
--------------------
- Go to the contract tab -> click on write contract -> look for the `claim()` function -> paste address of the collection -> click on write.

*/

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit, ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface Holders {
    function balanceOf(address wallet) external view returns (uint256);
    function tokenOfOwnerByIndex(address wallet, uint256 index) external view returns (uint256);
}

contract ShimmerInuMemeToken is ERC20, ERC20Permit, ERC20Votes, ReentrancyGuard {
    address public constant IOTABOTS = 0x6c2D60145cDD0396bd03298693495bf98fcdD93E;
    address public constant LILAPE   = 0x3F5ae5270b404fF94BB4d2f15A4f3b46f16470D1;
    address public constant OGAPE    = 0xf640ed4ADFD525a3DEae9FA76a840898d61009C1;
    address public constant LUMI     = 0xC55650e30d5e66159bCB3d32928c8b16879F2664;

    /* TOTAL_FOR_BURN % TOTAL_CYCLES = 293.333.333.333 B * TOTAL_CYCLES = 2.639.999.999.997 T ( without decimal precision ) */

    uint256 public constant TOTAL_FOR_LIQUIDITY  = 330_000_000_000e18; // 330 B (10%)
    uint256 public constant TOTAL_FOR_HOLDERS    = 330_000_000_000e18; // 330 B (10%)
    uint256 public constant TOTAL_FOR_BURN       = 2_640_000_000_000e18; // 2.640 T (80%)

    uint256 public constant FOR_HOLDER           = 29_962_209e18; // 29.962.209 B
    uint256 public constant FOR_BURN             = 293_333_333_333e18; // 293.333.333.333 B

    uint256 public constant CYCLE_TIME = 4 weeks + 1 days;
    uint256 public constant TOTAL_CYCLES = 9;

    uint256 public totalBurned;
    uint256 public lastBurn;
    uint256 public currentCycle;
    uint256 public totalClaims;
    uint256 public totalClaimed;
    
    bool public unclaimedBurned;

    // tokenID -> collection -> bool
    mapping(uint256 => mapping(address => bool)) public hasBeenClaimed;

    event Claim(address indexed collection, uint256 quantity, uint256 claimed);
    event Burn(uint256 newCycle, uint256 burned);
    event BurnUnclaimed(uint256 burned);

    constructor() 
        ERC20("Shimmer Inu", "SHIMMERINU") 
        ERC20Permit("Shimmer Inu") 
    {
        _mint(msg.sender, TOTAL_FOR_LIQUIDITY);
        _mint(address(this), TOTAL_FOR_BURN + TOTAL_FOR_HOLDERS);

        lastBurn = block.timestamp;
    }

    function claim(address collection) external nonReentrant {
        if (currentCycle == TOTAL_CYCLES) revert("Nothing to claim.");

        if (collection != LUMI && collection != IOTABOTS 
            && collection != OGAPE && collection != LILAPE) revert("Wrong collection.");

        uint256 counterNFTs = Holders(collection).balanceOf(msg.sender);

        if (counterNFTs == 0) revert("Nothing in your wallet.");

        uint256 tokenID;
        uint256 counter;

        unchecked {
            for (uint256 b; b<counterNFTs; b++) {
                tokenID = Holders(collection).tokenOfOwnerByIndex(msg.sender, b);
                if (hasBeenClaimed[tokenID][collection]) break;
                hasBeenClaimed[tokenID][collection] = true;
                counter++;
            }
        }

        if (counter == 0) revert("Already claimed.");

        uint256 calc = FOR_HOLDER * counter;
        uint256 balance = IERC20(address(this)).balanceOf(address(this));

        if (calc > balance) revert("Not enough for you.");

        SafeERC20.safeTransfer(IERC20(address(this)), msg.sender, calc);

        totalClaims += counter;
        totalClaimed += calc;

        emit Claim(collection, counter, calc);
    }

    function burn() external {
        if (lastBurn + CYCLE_TIME > block.timestamp) revert("Wait, Plz.");
        if (currentCycle == TOTAL_CYCLES) revert("Nothing else to burn.");

        _burn(address(this), FOR_BURN);
        lastBurn = block.timestamp;
        unchecked { currentCycle++; }

        emit Burn(currentCycle, FOR_BURN);
    }

    function burnUnclaimed() external {
        if (currentCycle == TOTAL_CYCLES && !unclaimedBurned) {
            uint256 amount = IERC20(address(this)).balanceOf(address(this));
            _burn(address(this), amount);
            unclaimedBurned = true;
            emit BurnUnclaimed(amount);
        } else revert("Nothing to see here.");
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function _afterTokenTransfer(
        address from, 
        address to, 
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to, 
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account, 
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
        totalBurned += amount;
    }

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    function CLOCK_MODE() public virtual pure override returns (string memory) {
        return "mode=timestamp";
    }
}