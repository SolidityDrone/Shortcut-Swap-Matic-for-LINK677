// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "std/test.sol";
import "../src/SwapMaticToLink677.sol";
import "../src/ConsumerExampleAgainstLiveContract.sol";

contract ConsumerTest is Test, SwapMaticToLink677{
    
    SwapMaticToLink677 private swapMaticForLink677;
    ConsumerContract private consumer;
    function setUp() public {
        //deploy the SwapMaticToLink677.sol contract 
        swapMaticForLink677 = new SwapMaticToLink677();
        //deploy ConsumerContract which is an example contract that uses SwapMaticLink
        //it has hardcoded address of SwapMaticToLink677 on mainnet
        consumer = new ConsumerContract();
        
    }
    function testConsumerLiveExampleCall() public {
        vm.prank(address(consumer));
        vm.deal(address(consumer), 1e23);
        consumer.callSwap(1e23-1);
        console.log("ConsumerExample starting matic balance: ", address(this).balance);
        console.log("ConsumerExample final link balance: ", IERC20(ERC677_link).balanceOf(address(this)));
        console.log("ConsumerExample final matic balance: ", address(this).balance);
    }

}


