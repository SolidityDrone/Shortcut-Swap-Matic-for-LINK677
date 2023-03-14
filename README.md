<!-- PROJECT LOGO -->
<br />
<div align="center">
  ![image](https://user-images.githubusercontent.com/104315978/225035494-215a1394-4b58-442b-b10b-e373e2cf5913.png)


  <h3 align="center">One function Matic to link 677 swap on Polygon Mainnet</h3>

  <p align="center">
   This contract is live on the Polygon Mainnet!
    <br/>  Live at address: 0xa1dd997D3c214b9F4B4510cfF0E6c78f58720feF <br/>
    <br/>
    <a href="https://polygonscan.com/address/0xa1dd997D3c214b9F4B4510cfF0E6c78f58720feF"><strong> Check on PolygonScan» </strong></a>
  
    
    
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- What it does -->
## What it does 
This contract simply makes 3 swaps in one function in order to easily obtain ERC677 Link to use Chainlink services on mainnet. 
Easy to implement in your contract with one function one use design, or use via EOA

## Keep in mind
This isn't endorsed by Chainlink, its a personal project that I mainly developed to overcome the problem of swapping Bridged for ERC677 programmatically onchain. Using it blindly on production is discouraged, always make sure you test your app against this contract
forking mainnet. 
Works with amount from 1e18 to 1e23-1 to avoid uniswap Error LS 
1e23 its 100k Matic 

<!-- How it works -->
## How it works

Using chainlink services can be tricky on mainnet, in order to have your services you need ERC677 Compatible LINK to pay the fees, and the LINK you can buy
through for example uniswap is "Bridged Link". As you can imagine Bridged Link is not compatible with Chainlink services thus requiring to handle few swaps to get your 677 Link onchain via contract.
This  contract makes a swap directly from matic to ERC677 Link in on function call.

Here's what this contract does under the hood:
* Receives matic from callee and use it to call 'deposit()' function Wrapper Contract.
* Executes a singleHop swap on UniSwap to acquire LINK in WrappedMatic/Link pair
* Uses official Chainlink PegSwap to swap Bridged LINK to ERC677 compatible LINK

Addittionally Chainlink priceFeed is used to calculate a minimun amount of token to be received to not revert.

### What's been used


* ISwapRouter
* Official Chainlink PegSwap
* Official Matic Wrapper contract


<!-- USAGE EXAMPLES -->
## Usage

 
Contracts that need to swap matic to bridge 677 in a simple way can just import the interface of the contract 

NOTE! Calling swap on ISwapMaticToLink interface assumes that contract has the matic sent as value in the tx. 
Otherwise this will revert.

  ```
  interface ISwapMaticToLink{
    function swap() external payable returns (uint256);
}
  ```
Once initialized you can just call 
 ```
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
 ```

For more examples, please refer to use consumerExample.sol.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- How to run test  -->

### How to run test

Requires you to have Foundry installed. Check https://github.com/foundry-rs/foundry

simply navigate into the folder and run 
* 
  ```
  forge test --fork-url https://polygon-rpc.com -vv
  ```
This will fork polygon mainnet. You can then run tests.
As this project is born to fit my specific problem this only works oneway in for now, but you can easily add a new function to make it backwards. Then include that in your contract's interface ;)


<!-- License and use -->
## Licenses and use
This contract is free to use at your own risk, if you are integrating this in your production code its strongly raccomanded you do your software test to fit your application at best. 



<!-- Donation -->
This project took me a while to figure out, and I'm giving it to you for free. If you ever find that useful for your needs or just appreciate my work and want to make a donation here's two address I have access to

 0xD4E7B756BCE89070D0558E02D801FAE0C419a990 <br />
 0xf8D487dE6F92995c539093fd4419e1B12759c08b

