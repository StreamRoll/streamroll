# StreamRoll
[Interwebs](https://streamroll.netlify.app/)

[Presentation Slides](https://www.canva.com/design/DAEsGA41-_Y/6tE3j28XecoUz6mWRt5jJA/view#1)

[Video]()

---

## Pain and Target Audience
DAOs and other crypto entities who have to efficently utilize their treasury for ongoing expenses.  Whether the treasury is concentrated with majority of goverance tokens or well diversfied, these DAOs need liquity solutions that minimize tax events, support HR and the flow of capital within the DAO (guilds). 

## Solution
StreamRoll has several unqiue solutions to streamline the HR nightmare.  We begin with creating a "safe" for each DAO that will allow them to borrow and lend their capital, pay payroll and automate HR as efficently as possible. 


---
## Introduction :wave: :metal:

StreamRoll Finance allows DAOs and crypto companies to utilize their treasury as collateral for payroll expenses. These payrolls will be streamed out via the Supefluid protocol to the employees who may do what they wish with their salaries. StreamRoll will enable DAOs to borrow against their governance and other tokens in real time to minimize interest expense and stream in real-time to their employees. The benefits to DAOs is to unlock their net worth to pay expenses without having to sell their tokens and also incur tax events. 

Employees can receive their salaries each minute and can choose to invest in real-time (e.g. via Ricochet Exchange) or however they see t. These streaming smart contracts can also represent the employer/employee contract agreement written on-chain via calldata[^1]. 
* DAO's will be able to:
  * Supply their goverance token (or ETH, other types of collateral) and receive a DAI (or any other ERC-20 stable coin) in return.
  * Setup salary streams to their employees via the [Superfluid Protocol](https://docs.superfluid.finance/superfluid/docs/constant-flow-agreement).
  *DAOs will be able to make their real-time payroll without the necessity of selling their treasury for fiat. 



---
## Construction of Contracts :page_with_curl: :hammer:


StreamRoll implements the Minimal Proxy Contract Standard or [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167). There is one implmentation contract (`StreamRollV1`) where all the logic will be kept, and every time a user wants to interact with the protocol, it will call the `_clone()` function in the `CloneFactory.sol` contract.

`StreamRollV1.sol`:
* This contract holds all the **core logic** and will be deployed only **ONCE** and act as the base "implementation" contract.
* In order for it to function as a base contract, we used a technique that makes it "unusable" (check the constructor).
* The copies will call the `initialize()` function acting as the contructor for the Proxy.

`CloneFactory.sol`:
* This contract will make idential copes of `StreamRollV1.sol`.
* The DAO and/or user will call the `_clone()` function to create a copy of `StreamRollV1.sol` via the Minial Proxy Contract Standard. 
---
## Security :closed_lock_with_key: :link:
* Immediately after the `_clone()` function is triggered, the `initialize()` function is also triggered for the `StreamRollV1.sol` copy as `msg.sender` for the argument. 
* This makes the contract temper-proof and the `msg.sender` as the **owner**. 
* All the functions that change the state have an `onlyOwner()` modifier, making it not possible for a bad actor to steal funds.
* As another security check, every time the owner retrieves funds, the funds go straight to the `owner`, not to a provided `address`. 
* Once the safe is created, you cannot change the `owner` and is a one-way function :arrow_right:, funds can only be retrieved from the `owner` to the `owner`.
* Soound familiar? We got inspired by a protocol that implemented a similiar architecture → [Gnosis Safe](https://gnosis-safe.io/).



[^1]: Would be V2. :checkered_flag:


<img src ="https://github.com/StreamRoll/streamroll/blob/master/images/im-1.png">
<img src ="https://github.com/StreamRoll/streamroll/blob/master/images/im-2.png">








