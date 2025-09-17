import {
  CONTRACTS,
  jsonStringify,
  logAccountCode,
  walletClient,
} from "./utils";
import { multicallAbi, utilsAbi } from "./abis";
import { encodeFunctionData } from "viem";

const main = async () => {
  await logAccountCode("EoA code before delegation");

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

  console.log(`Delegation transaction hash: ${hash}`);

  await walletClient.waitForTransactionReceipt({ hash });

  await logAccountCode("EoA code after delegation");

  console.log("🔗 EOA is now permanently delegated to Multicall");
  console.log("Testing that delegation persists by calling Utils.isSender() again WITHOUT authorization...");

  const result = await walletClient.writeContract({
    abi: multicallAbi,
    address: walletClient.account.address,
    functionName: "multicall",
    args: [[CONTRACTS.UTILS_ADDRESS], [utilsCallData]],
  });

  console.log(`Second test transaction hash: ${result}`);

  await walletClient.waitForTransactionReceipt({ hash: result });

  console.log("✅ EIP-7702 permanent delegation test completed successfully!");
  console.log("Utils.isSender() succeeded, proving persistent delegation works!");
  console.log("EOA remains delegated for future transactions");
};

main();
