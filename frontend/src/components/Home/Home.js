import React, { useState, useEffect } from "react";
import Logo from "../Logo/Logo";
import Connect from "../Connect/Connect";
import Text from "../Text/Text";
import Cards from "../Cards/Cards";
import css from "./Home.css";

const { ethers } = require("ethers");

const abi = [
  "function supplyEthToCompound() external payable returns (bool)",
  "function borrowFromCompound(uint _amount) external payable returns (bool)",
  "function transferBack(uint _amount, address payable _to) external returns (bool)",
  "function getEtherBack(uint _amount) external returns (bool)",
  "function repayDebt(uint _repayAmount) external returns (bool)",
  "function getSuppliedBalances(address _requested) external view returns (uint)",
  "function getCheckout(address _requested) external view returns (uint)",
  "function returnBorrowedBalances() external view returns (uint) "
];
const contractAddress = "0xE137811c2Af799a39379e7C213362238a6939222"; //This is a deployed contract.. Change it to yours if you want.
const metaMaskProvider = new ethers.providers.Web3Provider(
  window.ethereum,
  "rinkeby"
);
const contract = new ethers.Contract(contractAddress, abi, metaMaskProvider);

const Home = () => {
  const [supplyAmount, setSupplyAmount] = useState("");
  const [userAddress, setUserAddress] = useState("");
  const [collateralBalance, setCollateralBalance] = useState(
    "Connect your wallet"
  );
  const [checkoutBalance, setCheckoutBalance] = useState("Connect your wallet");
  const [retrieveAmount, setRetrieveAmount] = useState("");
  const [amountToBorrow, setAmountToBorrow] = useState("");
  const [borrowedBalance, setBorrowedBalance] = useState("Connect your wallet");
  const [repayAmount, setRepayAmount] = useState("");


  useEffect(async () => {
    try {
      const signer = metaMaskProvider.getSigner();
      const signerContract = contract.connect(signer);
      const bal = await signerContract.getSuppliedBalances(await signer.getAddress());
      const checkout = await signerContract.getCheckout(
        await signer.getAddress()
      );
      const _borrowedBalance = await signerContract.returnBorrowedBalances();
      setCollateralBalance(
        ethers.utils.formatEther(bal.toString()) + " " + "ETH"
      );
      setCheckoutBalance(
        ethers.utils.formatEther(checkout.toString()) + " " + "ETH"
      );
      setBorrowedBalance(ethers.utils.formatEther(
        _borrowedBalance.toString()) + " " + "Dai"
        );
      
    } catch (error) {
      console.error(error);
    }
  }, []);

  const connectAccount = async () => {
    await window.ethereum.enable();
    await metaMaskProvider.send("eth_requestAccounts");
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    const userAddr = await signer.getAddress();
    setUserAddress(userAddr);
    alert("You are connected");
  }

  const supplyEth = async () => {
    if (supplyAmount <= 0) {
      alert("You need to supply more than 0 ETH");
      return;
    }
    if (isNaN(supplyAmount) === true) {
      alert("You need to type numbers");
      return;
    }
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    signerContract
      .supplyEthToCompound({
        value: ethers.utils.parseEther(supplyAmount.toString()),
      })
      .then((res) => console.log(res))
      .catch((error) => alert(error));
  }

  const retrieveEth = async () => {
    if (retrieveAmount <= 0) {
      alert("0 or negative amounts are invalid");
      return;
    }
    if (isNaN(retrieveAmount) === true) {
      alert("You need to type numbers");
      return;
    }
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    await signerContract
      .getEtherBack(ethers.utils.parseEther(retrieveAmount.toString()))
      .then((res) => console.log(res))
      .catch((error) => alert(error));
  }

  const _transfer = async () => {
    const signer = metaMaskProvider.getSigner();
    const signerContract = contract.connect(signer);
    if ((await signerContract.getCheckout(await signer.getAddress())) <= 0) {
      alert("Insufficient checkout funds");
      return;
    }
    const address = await signer.getAddress();
    const amount = await signerContract.getCheckout(await signer.getAddress());
    const result = await signerContract.transferBack(amount, address);
  }

  const _borrow = async () => {
    try {
      const signer = metaMaskProvider.getSigner();
      const signerContract = contract.connect(signer);
      const amount = ethers.utils.parseEther(amountToBorrow);
      const result = await signerContract.borrowFromCompound(amount);
    } catch(err) {
        alert(err);
    }
  }

  const _repayDebt = async () => {
    try {
      const signer = metaMaskProvider.getSigner();
      const signerContract = contract.connect(signer);
      const amount = ethers.utils.parseEther(repayAmount);
      const result = await signerContract.repayDebt(amount);
    } catch(err) {
        alert(err);
    }   
  }
  
  
  return (
    <div className="Home">
      <Logo />
      <Connect onClick={() => connectAccount()} userAddress={userAddress} />
      <div className="Text">
        <Text />
      </div>
      <Cards
        title1="Collateral Balance"
        text1={collateralBalance}
        placeholder1="Supply ETH"
        onChange1={(e) => setSupplyAmount(e.target.value)}
        button1="Supply"
        onClick1={() => supplyEth()}
        title2="Borrowed Dai"
        text2={borrowedBalance}
        placeholder2="Amount to Borrow - 'Dai'"
        onChange2={(e) => setAmountToBorrow(e.target.value)}
        button2="Borrow"
        onClick2={() => _borrow()}
        placeholder2a="Repay balance"
        onChange2a={(e) => setRepayAmount(e.target.value)}
        button2a="Repay"
        onClick2a={() => _repayDebt()}
        title3="Checkout Balance"
        text3={checkoutBalance}
        placeholder3="Retrieve ETH"
        onChange3={(e) => setRetrieveAmount(e.target.value)}
        button3="Retrieve"
        onClick3={() => retrieveEth()}
        sendEth={() => _transfer()}
      />
    </div>
  );
};

export default Home;
 