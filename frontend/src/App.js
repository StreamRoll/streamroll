import React, {useState} from 'react';
import css from './App.css';

import logo from './components/images/logo.png';
import MetaMask from './components/images/MetaMask.png';
import SupplyEther from './components/images/SupplyEther.png';
import Reedem from './components/images/Reedem.png';

const { ethers } = require("ethers");

const abi = [
  "function supplyEthToCompound() public payable returns (bool)",
  "function getEtherBack(uint256 _amount) public returns (bool)",
  "function getBalance(address _requested) public view returns (uint)",
  "function exchangeRate() public returns (uint)",
  "function transfer(uint amount, address payable _to) public returns (bool)"
];
const contractAddress = "0xC8061C8f8eDD040Ff26cde647B3006E4d395C7E9";
const metaMaskProvider = new ethers.providers.Web3Provider(window.ethereum, "rinkeby");
const contract = new ethers.Contract(contractAddress, abi , metaMaskProvider);
const gasPriceHex = ethers.utils.hexlify(20000000000);
const gasLimitHex = ethers.utils.hexlify(150000);

export default function App() {

  const [amount, setAmount] = useState("");
  const [reedem, setReedem] = useState("");

  async function connectAccount() {
    await window.ethereum.enable();
    await metaMaskProvider.send("eth_requestAccounts");
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
  }

  async function supplyEth() {
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    signerContract.supplyEthToCompound({
      value:ethers.utils.parseEther(amount.toString()),
   
    });
  }

  async function reedemEth() {
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    const result = await signerContract.getEtherBack(reedem * 1e8,
    {
      gasLimit:gasLimitHex, 
      gasPrice:gasPriceHex
    });
  }

  // async function _getBalance() {
  //   const signer = metaMaskProvider.getSigner();
  //   const signerContract = contract.connect(signer);
  //   const result = await signerContract.getBalance(await signer.getAddress());
  //   console.log(result.toString());
  // }

  // async function _transfer() {
  //   const signer = metaMaskProvider.getSigner();
  //   const signerContract = contract.connect(signer);
  //   const address = await signer.getAddress();
  //   const result = await signerContract.transfer(ethers.utils.parseEther("0.9"), address,
  //   {
  //     gasLimit:gasLimitHex,
  //     gasPrice:gasPriceHex
  //   });
  // }

  return (
    <div className="App">
      <div className="Logo">
        <img src={logo} width="150"/>
      </div>
      <div className="MetaMask">
        <img src={MetaMask} width="150" onClick={connectAccount} style={{cursor:"pointer"}}/>
      </div>
      <div className="SupplyEther">
        <img src={SupplyEther} width="150" onClick={supplyEth} style={{cursor:"pointer"}}/>
      </div>
      <div className="form">
        <form>
          <input 
            type="text"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
        </form>
      </div>
      <div className="Reedem">
      <img src={Reedem} width="150" onClick={reedemEth} style={{cursor:"pointer"}}/>
      </div>
      <div className="form2">
        <form>
          <input 
            type="text"
            value={reedem}
            onChange={(e) => setReedem(e.target.value)}
          />
        </form>
      </div>
    </div>
  );
}



