# StreamRoll
[Interwebs](https://streamroll.netlify.app/)

[Presentation Slides](https://www.canva.com/design/DAEsGA41-_Y/6tE3j28XecoUz6mWRt5jJA/view#1)

[Video]()

---

## Pain and Target Audience :weary: :dart:
DAOs and other crypto entities who have to efficiently utilize their treasury for ongoing expenses.  Whether the treasury is concentrated with majority of governance tokens or well diversified, these DAOs need liquidity solutions that minimize tax events, support HR and the flow of capital within the DAO (guilds). 

## Solution :heavy_check_mark:
StreamRoll has several unique solutions to streamline the HR nightmare.  We begin with creating a "safe" for each DAO that will allow them to borrow and lend their capital, pay payroll and automate HR as efficiently as possible. 


---
## Introduction :wave: :metal:

StreamRoll Finance allows DAOs and crypto companies to utilize their treasury as collateral for payroll expenses. These payrolls will be streamed out via the Superfluid protocol to the employees who may do what they wish with their salaries. StreamRoll will enable DAOs to borrow against their governance and other tokens in real time to minimize interest expense and stream in real-time to their employees. The benefits to DAOs is to unlock their net worth to pay expenses without having to sell their tokens and also incur tax events. 

Employees can receive their salaries each minute and can choose to invest in real-time (e.g. via Ricochet Exchange) or however they see t. These streaming smart contracts can also represent the employer/employee contract agreement written on-chain via calldata[^1]. 
* DAO's will be able to:
  * Supply their governance token (or ETH, other types of collateral) and receive a DAI (or any other ERC-20 stable coin) in return.
  * Setup salary streams to their employees via the [Superfluid Protocol](https://docs.superfluid.finance/superfluid/docs/constant-flow-agreement).
  *DAOs will be able to make their real-time payroll without the necessity of selling their treasury for fiat. 



---
## Construction of Contracts :page_with_curl: :hammer:


StreamRoll implements the Minimal Proxy Contract Standard or [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167). There is one implementation contract (`StreamRollV1`) where all the logic will be kept, and every time a user wants to interact with the protocol, it will call the `_clone()` function in the `CloneFactory.sol` contract.

`StreamRollV1.sol`:
* This contract holds all the **core logic** and will be deployed only **ONCE** and act as the base "implementation" contract.
* In order for it to function as a base contract, we used a technique that makes it "unusable" (check the constructor).
* The copies will call the `initialize()` function acting as the constructor for the Proxy.

`CloneFactory.sol`:
* This contract will make identical copies of `StreamRollV1.sol`.
* The DAO and/or user will call the `_clone()` function to create a copy of `StreamRollV1.sol` via the Minial Proxy Contract Standard. 

<img src ="https://github.com/StreamRoll/streamroll/blob/master/images/ProxyStructure.png">

---
## Security :closed_lock_with_key: :link:
* Immediately after the `_clone()` function is triggered, the `initialize()` function is also triggered for the `StreamRollV1.sol` copy as `msg.sender` for the argument. 
* This makes the contract temper-proof and the `msg.sender` as the **owner**. 
* All the functions that change the state have an `onlyOwner()` modifier, making it not possible for a bad actor to steal funds.
* As another security check, every time the owner retrieves funds, the funds go straight to the `owner`, not to a provided `address`. 
* Once the safe is created, you cannot change the `owner` and is a one-way function :arrow_right:, funds can only be retrieved from the `owner` to the `owner`.
* Sound familiar? We got inspired by a protocol that implemented a similar architecture → [Gnosis Safe](https://gnosis-safe.io/).

## DAO Global Hackathon :factory:
* We lost three front-end dev's during our process  :anguished:, so it is what it is.  We think it is unique with lots of character :sparkles:
* When we went to upload the video, we noticed no sound :no_entry_sign::sound: was recorded and we can re-make it.  We did upload it and plan to make one with sound, since we think people want to hear us, maybe??  Our team is global and we cannot re-do it at 8:00pm CST 12/10/21. 
* We begin work on this project from an uncompleted idea for ETH Global.  We knew we wanted to keep working on this and saw the DAO Global Hackathon a perfect fit in which we put a lot of effort (and still are....lol) into.
* Contact:
  * Chris Adams → chrisadams@startmail.com  

### Operate :key:
* This repo contains our Solidity contracts only:
  * `npm i`
  * `npx hardhat compile`
  * `npx hardhat node` → Spin up a local node **OR**:
  * make a copy of `.env.example` and name it `.env`
  * Fill out credentials 
  * `npx hardhat run scripts/deploy.js --network <yourchoice>` 

[^1]: Would be V2. :checkered_flag:









