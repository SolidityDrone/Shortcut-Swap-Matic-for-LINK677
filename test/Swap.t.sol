// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "std/test.sol";
import "../src/SwapMaticToLink677.sol";
import "../src/ConsumerExample.sol";

contract testMaticFor677LinkSwap is Test, SwapMaticToLink677{
    
    SwapMaticToLink677 private swapMaticForLink677;
    ConsumerContract private consumer;
    function setUp() public {
        //deploy the SwapMaticToLink677.sol contract 
        swapMaticForLink677 = new SwapMaticToLink677();
        //deploy ConsumerContract which is an example contract that uses SwapMaticLink 
        consumer = new ConsumerContract(address(swapMaticForLink677));
        //Checks addresses initialized according to official contracts on mainnet
        assertEq(address(ChainlinkPegSwap), 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b);
        assertEq(address(priceFeed), 0x5787BefDc0ECd210Dfa948264631CD53E68F7802);
        assertEq(address(ERC677_Link), 0xb0897686c545045aFc77CF20eC7A532E3120E0F1);
        assertEq(address(swapRouter), 0xE592427A0AEce92De3Edee1F18E0157C05861564);
        //Assert pool is initialized at 0.3%
        assertEq(poolFee, 3000);
    }
    function testConsumerExampleCall() public {
        vm.prank(address(consumer));
        vm.deal(address(consumer), 1e23);
        consumer.callSwap(1e23-1);
        console.log("ConsumerExample starting matic balance: ", address(this).balance);
        console.log("ConsumerExample final link balance: ", IERC20(ERC677_link).balanceOf(address(this)));
        console.log("ConsumerExample final matic balance: ", address(this).balance);
    }

    function testSwapOutPut() public {
        vm.prank(address(this));
        vm.deal(address(this), 1e30);
        console.log("Contract matic Balance: ", address(this).balance);
        vm.expectRevert("Msg.value has to be higher than 1 eth (matic)");
        uint256 amountOut = swapMaticForLink677.swap{value: 1}();
   
      
        amountOut = swapMaticForLink677.swap{value:40000e18}();
        console.log("AmountOut", amountOut);
        console.log("Operates swap() function on swapMaticForLink677");
        console.log("Contract matic Balance: ", address(this).balance);
        console.log("Contract 677Link Balance: ", IERC20(ERC677_link).balanceOf(address(this)));
        assertEq(amountOut, IERC20(ERC677_link).balanceOf(address(this)));
       
        console.log("Contract 677Link Balance: ", IERC20(ERC677_link).balanceOf(address(this)));
      
      
    } 
   


    function testcheckLinkPerMatic() public  view returns (uint256){
        return ((1e18 / (uint256(getLatestPrice())/1e10)) * 1e8);
    }
    
    function testPriceConversions()public {
        uint256 price = uint256(getLatestPrice());
        console.log("1 Link is ", price, "Polygon matic wei");
        assertTrue(price > 0, "Price returns 0! ");
        uint256 expectedOut = ((1e18 / (price/1e10)) * 1e8);
        console.log("chainlink price approximation per 1e18 wei: ",expectedOut );
        console.log ("minimum price to not revert swap: ", expectedOut - ((expectedOut)/100)*3);
        console.log("", ((expectedOut) * (1e23)) / 1e18) ;
    }
 
   
   //Fuzz testing in a range between 1*1e18 and 1*1e23 
    function testSwapOutputWithFuzz(uint256 fuzzAmount)public {
        vm.prank(address(this));
        vm.deal(address(this), 1e33);
        console.log("Contract matic Balance: ", fuzzAmount);
        uint256 amountOut;
        if (fuzzAmount < 1e18) {
            vm.expectRevert("Msg.value has to be higher than 1 eth (matic)");
             amountOut = swapMaticForLink677.swap{value: fuzzAmount}();
           
        }
        else if (fuzzAmount <  1e23){
            amountOut = swapMaticForLink677.swap{value: fuzzAmount}();
            
            assertEq(amountOut, IERC20(ERC677_link).balanceOf(address(this)));
            
        } if (fuzzAmount > 1e23) {
            //Expect the uniswap router to revert for liquidity shortage
            
            vm.expectRevert();
            amountOut = swapMaticForLink677.swap{value: fuzzAmount}();
        }

    }
    
    
    function testWrapAndSwapFailFromExternalCall()public {
        swapMaticForLink677 = new SwapMaticToLink677();
        vm.expectRevert("Function disabled");
        swapMaticForLink677.wrapAndSwap{value: 1e23-1}();
    }

}


