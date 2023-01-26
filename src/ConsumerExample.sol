// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


 
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
    function callSwap(uint256 payableAmount) public returns (uint256){
        uint256 amountSwapped = ISwapMaticToLink(_swap).swap{value: payableAmount}();
        return amountSwapped;
    }

    
}


