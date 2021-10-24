import React, {useState, useEffect} from 'react';
import css from './App.css';

import logo from './components/images/logo.png';
import connect from './components/images/connect.png';
import SupplyEther from './components/images/SupplyEther.png';
import Reedem from './components/images/Reedem.png';
import Card from './components/card/Card.js';
import Card2 from './components/card/Card.js';
import retrive from './components/images/retrieve.png';

const { ethers } = require("ethers");

const abi = [
  "function supplyEthToCompound() public payable returns (bool)",
  "function getEtherBack(uint256 _amount) public returns (bool)",
  "function getBalance(address _requested) public view returns (uint)",
  "function getCheckout(address _requested) external view returns (uint)",
  "function transferBack(uint _amount, address payable _to) public returns (bool)"
];
const contractAddress = "0x067B64684C00E545623062De131eE2330ab891BB";
const metaMaskProvider = new ethers.providers.Web3Provider(window.ethereum, "rinkeby");
const contract = new ethers.Contract(contractAddress, abi , metaMaskProvider);
const gasPriceHex = ethers.utils.hexlify(20000000000);
const gasLimitHex = ethers.utils.hexlify(150000);

export default function App() {

  let status;
  const [amount, setAmount] = useState("");
  const [reedem, setReedem] = useState("");
  const [balance, setBalance] = useState("");
  const [txt, setTxt] = useState("");
  const [checkout, setCheckout] = useState("");
  const [txt2, setTxt2] = useState("");

  async function connectAccount() {
    status = true;
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
   
    }).then(res => console.log(res))
      .catch(error => alert(error));
  }

  async function reedemEth() {
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    await signerContract.getEtherBack(ethers.utils.parseEther(reedem.toString()))
                        .then(res => console.log(res))
                        .catch(error => alert(error));
    
  }



  async function _transfer() {
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    const address = await signer.getAddress();
    const result = await signerContract.transferBack(ethers.utils.parseEther(checkout[0]), address)

  }

  async function _getBalance() {
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    const result = await signerContract.getBalance(await signer.getAddress());
    setBalance(ethers.utils.formatEther(result.toString()));
    console.log(ethers.utils.formatEther(result.toString()));
  }  

  useEffect(async () => {
    try {
      const signer = metaMaskProvider.getSigner();
      const signerContract = contract.connect(signer);
      const bal = await signerContract.getBalance(await signer.getAddress());
      const _checkout = await signerContract.getCheckout(await signer.getAddress());
      setBalance(ethers.utils.formatEther(bal.toString()) + " " + "ETH");
      setTxt("Collateral Balance");
      setCheckout(ethers.utils.formatEther(_checkout.toString()) + " " + "ETH");
      setTxt2("Checkout Balance");
    } catch (error) {
      console.error(error);
    }
  }, []);
  
  
  return (
    <div className="App">
      <div className="Logo">
        <img src={logo} width="100"/>
      </div>
      <div className="Connect">
        <img src={connect} width="150" onClick={connectAccount} style={{cursor:"pointer"}}/>
      </div>
      <div className="TitleText">
        <h1>
          The Easiest Way to Borrow & Stream
        </h1>
      </div>
      <div className="Card">
        <Card value={txt} name={balance}/>
      </div>
      <div className="Card2">
        <Card2 value= {txt2}name={checkout}/>
      </div>
      <div className="SupplyEther">
        <img src={SupplyEther} width="170" onClick={supplyEth} style={{cursor:"pointer"}}/>
      </div>
      <div className="form">
        <form>
            <input 
              type="text"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              className="form"
            />
        </form>
      </div>
      <div className="Reedem">
      <img src={Reedem} width="170" onClick={reedemEth} style={{cursor:"pointer"}}/>
      </div>
      <div className="form2">
        <form>
          <input 
            type="text"
            value={reedem}
            onChange={(e) => setReedem(e.target.value)}
            className="form2"
          />
        </form>
      </div>
      <div className="retrieve">
        <img src={retrive} width="180" onClick={_transfer} style={{cursor:"pointer"}}/>
      </div>
    </div>
  );
}



