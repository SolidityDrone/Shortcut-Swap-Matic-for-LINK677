// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

    /// This is an example do your own implementation. We pass the swap addres in constructor to facilitate
    /// test and comprehension, you can initialize contract your own way
    
 
interface ISwapMaticToLink{
    function swap() external payable returns (uint256);
}

contract ConsumerContract  {

    //Declaration of iSwapMaticToLink interface
    ISwapMaticToLink public immutable _swap;

    //Initialized iSwapMaticToLink contract address 
    constructor(address swap){
        _swap = ISwapMaticToLink(swap);
    }
    
    //Assume this address to be funded;
    //this function MAY be called multiple from another function to allow swapping more than 100k matic
    function callSwap(uint256 payableAmount) public returns (uint256){
        uint256 amountSwapped = ISwapMaticToLink(_swap).swap{value: payableAmount}();
        return amountSwapped;
    }
}


