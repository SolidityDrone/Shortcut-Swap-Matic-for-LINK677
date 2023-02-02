// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.6;
pragma abicoder v2;


import "../src/UniV3WmaticLinkSwap.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

    /// @title interface for chainlink PegSwap
    /// @notice needed to interact with PegSwap contract 
    /// @dev Interface for PegSwap contract at 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b 
interface IPegSwap{
    function swap(uint256 amount, address source, address target) external;
}
    /// @title Matic to Link ERC677 compatible in one function
    /// @author SolidtyDrone - See deployer address;
    /// @notice this contract contains and external function to swap matic to erc677 Link
    /// @dev simply create an interface for swap() external payable returns(uint256) and call from a contract
contract SwapMaticToLink677 is UniV3WmaticLinkSwap, ReentrancyGuard{

    
    event SwapCompleted(address indexed caller, uint256 indexed maticAmount, uint256 linkAmount);
    
    IPegSwap public immutable pegswap;
    UniV3WmaticLinkSwap public immutable MaticLinkSwap;
    //@notice address for polygon mainnet Chainlink PegSwap 
    //              https://polygonscan.com/address/0xaa1dc356dc4b18f30c347798fd5379f3d77abc5b#code
    address constant ChainlinkPegSwap =             0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
    //              https://polygonscan.com/address/0xb0897686c545045aFc77CF20eC7A532E3120E0F1#code
    address public constant ERC677_Link =           0xb0897686c545045aFc77CF20eC7A532E3120E0F1;

    /// @notice constructor is called upon deployment
    /// @dev intializes immutable variables
    constructor(){
        MaticLinkSwap = UniV3WmaticLinkSwap(address(this));
        pegswap = IPegSwap(ChainlinkPegSwap);
    }

    /// @notice Swaps matic for erc677 Link in one function
    /// @dev call this function with a msg.value greater than 0 to swap matic for 677Link
    /// @param (msg.value) requires to be greater than 0 and less than 1e23 (100000Eth)
    /// @return swapAmountOut of token returned from operations
    function swap() external payable nonReentrant returns (uint256){
        require(msg.value >= 1e18, "Msg.value has to be higher than 1 eth (matic)");
        require(msg.value < 1e23, "Msg.value has to be less than 100000 eth (matic)");
        //This address MUST be approved to call swapExactInputSingle() called in wrapAndSwap()
        IERC20(wmatic).approve(address(this), msg.value);
        //calls wrapAndSwap from MaticLinkSwap which returns uint256
        uint256 swapAmountOut =  MaticLinkSwap.wrapAndSwap{value: msg.value}();
        //returned swapAmountOut value must be greater than 0 to save worthless transactions
        require(swapAmountOut > 0, "Swap returns 0");
        //This address MUST be approved to call swap() on PegSwap chainlink contract
        IERC20(bridged_Link).approve(ChainlinkPegSwap, swapAmountOut);
        //call swap() and swaps swapAmountOut from bridged_Link to ERC677_Link on PegSwap contract 
        pegswap.swap(swapAmountOut, bridged_Link, ERC677_Link);
        //finally transfer ERC677Link tokens to msg.sender( the consumer ) of this function
        IERC20(ERC677_Link).transfer(msg.sender, IERC20(ERC677_Link).balanceOf(address(this)));

        //emits event SwapCompleted
        emit SwapCompleted(msg.sender, msg.value, swapAmountOut);
        return swapAmountOut;
    }
    
 
}
