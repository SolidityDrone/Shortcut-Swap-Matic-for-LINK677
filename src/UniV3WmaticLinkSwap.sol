// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
    
interface IWMatic is IERC20 {
    function deposit() external payable;
}

interface AggregatorV3Interface {
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract UniV3WmaticLinkSwap {


    //AggregatorV3Interface to retrieve Link/Matic price feed
    AggregatorV3Interface public priceFeed;
    //ISwapRouter interface
    ISwapRouter public swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    address constant ERC677_link = 0xb0897686c545045aFc77CF20eC7A532E3120E0F1;
    address constant bridged_Link = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;
    address  constant wmatic = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    //Declares pool fee equal to 0.3%.
    uint24 public constant poolFee = 3000;
    
    
    /**
     * Chainlink Price Feed Aggregator V3 
     * 
     * Network: Polygon Mainnet
     * Aggregator: Link/Matic
     * Address: 0x5787BefDc0ECd210Dfa948264631CD53E68F7802
     */
    /// @notice Constructor is executed upon deployment
    /// @dev Initializes pricefeed value through constructor 
    constructor(){
            priceFeed = AggregatorV3Interface(
            0x5787BefDc0ECd210Dfa948264631CD53E68F7802
        );
    }

    /// @notice Uses IWmatic interface to deposit matic for wrapped matic, finally swaps wrapped matic for bridged_Link
    /// @dev this function is called by MaticLinkSwap contract to wrap matic and launch a Uni v3 single swap
    /// @return amountOut the amount of token sent back after wrapping to wmatic and then swapping for bridged_Link
    function wrapAndSwap() external payable returns (uint256){
        require(msg.sender==address(this), "Function disabled");
        IWMatic(wmatic).deposit{value: msg.value}();
        IWMatic(wmatic).transfer(msg.sender, msg.value);
        uint256 amountOut = swapExactInputSingle(msg.value);
        return amountOut;
    }
    
    /// @notice swapExactInputSingle swaps a fixed amount of wmatic for a maximum possible amount of bridged_Link
    /// using the wmatic/bridged_Link 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its wmatic for this function to succeed.
    /// @param amountIn The exact amount of wmatic that will be swapped for bridged_Link.
    /// @return amountOut The amount of bridged_Link received.
    function swapExactInputSingle(uint256 amountIn) internal returns (uint256 amountOut) {
        // msg.sender must approve this contract

        // Transfer the specified amount of wmatic to this contract.
        TransferHelper.safeTransferFrom(wmatic, msg.sender, address(this), amountIn);

        // Approve the router to spend wmatic.
        TransferHelper.safeApprove(wmatic, address(swapRouter), amountIn);
       
       
        //calculate the amount of matic that make 1 link
        uint256 amount = ((checkLinkPerMatic()) * amountIn) / 1e18;
      
        //create a variable and calculate the amount to input in amountOutMinimum
        uint256 minOut =  (amount - (((amount)*5)/100));
        //set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: wmatic,
                tokenOut: bridged_Link,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                //minOut will be a number up to 5% less at worst
                amountOutMinimum: minOut,
                sqrtPriceLimitX96: 0
            });

        //The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }


    
    ///@notice getLatestPrice for a given pair
    ///@dev reads from AggregatorV3Interface and returns latestRoundData
    ///@return price returns latestRoundData price as int 
    function getLatestPrice() public view returns (int) {
        (
            ,
            int price,
            ,
            ,
        ) = priceFeed.latestRoundData();
            return price;
    }
    ///@notice Calculates the amount of Link per matic
    ///@dev Calculates the amount of link per matic through getLatestPrice()
    ///@return price in link of one matic price as uint256
    function checkLinkPerMatic() public view returns (uint256){
        return ((1e18 * 1e18 /(uint256(getLatestPrice()))) );
    }
    
}
   
    
