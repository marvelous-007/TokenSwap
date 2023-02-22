import { ethers } from "hardhat";

async function main() {

    const Tokenswap = await ethers.getContractFactory("TokenSwap");
    
    const coin = ethers.utils.parseEther("4000000000000000000");
    const tokenSwap = await Tokenswap.deploy("Pyramid", "PYD", coin );
    await tokenSwap.deployed();
    console.log(`Token swap is deployed at: ${tokenSwap.address}`);

    const usdtContractAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const usdtHolder = "0x748dE14197922c4Ae258c7939C7739f3ff1db573";

    // impersonating the Dai Holder
    const helpers = require("@nomicfoundation/hardhat-network-helpers");
    await helpers.impersonateAccount(usdtHolder);
    const impersonatedSigner = await ethers.getSigner(usdtHolder);

    const USDTCONNECT = await ethers.getContractAt("IUSDT", usdtContractAddress);
    const balance = await USDTCONNECT.balanceOf(usdtHolder);
    console.log(`USDT Balance Before ${balance}`);

    const value = ethers.utils.parseEther("100000");
    await USDTCONNECT.connect(impersonatedSigner).approve(tokenSwap.address, value);

    const getPriceFeed = await tokenSwap.getLivePrice();
    console.log(`Eth live price feed ${getPriceFeed}`);
    const totalSupply = await tokenSwap.totalSupply();
    console.log(totalSupply);

    const swap = await tokenSwap.connect(impersonatedSigner).swapme(value);
    console.log(swap);

    const getBalance = await tokenSwap.connect(impersonatedSigner).getUserBalance();
    console.log(`Your token balance is ${getBalance}`);

    const TokenAddress = await USDTCONNECT.balanceOf(tokenSwap.address);

    console.log(`your usdt price is ${TokenAddress}`);



}

main().catch((error) => {
    console.log(error);
    process.exitCode = 1;
});