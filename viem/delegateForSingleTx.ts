import {
  assertAcountHaveCode,
  assertAcountHaveNoCode,
  CONTRACTS,
  jsonStringify,
  logAccountCode,
  logAddresses,
  walletClient,
} from "./utils";
import { multicallAbi, utilsAbi } from "./abis";
import { encodeFunctionData } from "viem";

const main = async () => {
  await assertAcountHaveNoCode();

  console.log(`Account address: ${walletClient.account.address}`);
  console.log(`Multicall address: ${CONTRACTS.MULTICALL_ADDRESS}`);
  console.log(`Utils address: ${CONTRACTS.UTILS_ADDRESS}`);

  const authorization = await walletClient.signAuthorization({
    contractAddress: CONTRACTS.MULTICALL_ADDRESS,
    executor: "self",
  });

  console.log(`Authorization data: ${jsonStringify(authorization)}`);

  const utilsCallData = encodeFunctionData({
    abi: utilsAbi,
    functionName: "isSender",
    args: [walletClient.account.address],
  });

  const hash = await walletClient.writeContract({
    abi: multicallAbi,
    address: walletClient.account.address,
    authorizationList: [authorization],
    functionName: "multicall",
    args: [[CONTRACTS.UTILS_ADDRESS], [utilsCallData]],
  });

  console.log(`Transaction hash: ${hash}`);

  await walletClient.waitForTransactionReceipt({ hash });

  await assertAcountHaveCode();
};

const testWithMulticall = async () => {
  await assertAcountHaveNoCode();

  console.log(`Account address: ${walletClient.account.address}`);
  console.log(`Multicall address: ${CONTRACTS.MULTICALL_ADDRESS}`);
  console.log(`Utils address: ${CONTRACTS.UTILS_ADDRESS}`);

  const currentNonce = await walletClient.getTransactionCount({
    address: walletClient.account.address,
  });

  const delegateAuth = await walletClient.signAuthorization({
    contractAddress: CONTRACTS.MULTICALL_ADDRESS,
    executor: "self",
    nonce: currentNonce,
  });

  const removeAuth = await walletClient.signAuthorization({
    contractAddress: "0x0000000000000000000000000000000000000000",
    executor: "self",
    nonce: currentNonce + 1,
  });

  console.log(`Authorization data: ${jsonStringify(delegateAuth)}`);

  const utilsCallData = encodeFunctionData({
    abi: utilsAbi,
    functionName: "isSender",
    args: [CONTRACTS.MULTICALL_ADDRESS],
  });

  try {
    const hash = await walletClient.writeContract({
      abi: multicallAbi,
      address: walletClient.account.address,
      authorizationList: [delegateAuth, removeAuth],
      functionName: "multicall",
      args: [[CONTRACTS.UTILS_ADDRESS], [utilsCallData]],
    });

    await walletClient.waitForTransactionReceipt({ hash });

    console.log(
      "❌ Test failed: isSender() should have reverted but succeeded"
    );
  } catch (error) {
    console.log(error);
    console.log("✅ Test passed: isSender() correctly reverted!");
    console.log("This proves msg.sender == EOA address, not Multicall address");
  }

  await assertAcountHaveNoCode();
  logAccountCode("EoA code after transaction");
};

// main();
testWithMulticall();
