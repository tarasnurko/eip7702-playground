import {
  createWalletClient,
  createPublicClient,
  http,
  parseEther,
  publicActions,
  encodeFunctionData,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { anvil } from "viem/chains";
import "dotenv/config";
import { counterAbi } from "./abis";
import assert from "node:assert";

export const PRIVATE_KEY = process.env.PRIVATE_KEY as `0x${string}`;
export const RPC_URL = process.env.RPC_URL;
export const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS as `0x${string}`;

export const CONTRACTS = {
  COUNTER_ADDRESS: "0x5FbDB2315678afecb367f032d93F642f64180aa3" as const,
  MOCK_ERC20_ADDRESS: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512" as const,
  MULTICALL_ADDRESS: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0" as const,
  UTILS_ADDRESS: "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9" as const,
} as const;

export const CHAIN = anvil;

if (!PRIVATE_KEY) {
  throw new Error("PRIVATE_KEY not found in .env file");
}

const eoa = privateKeyToAccount(PRIVATE_KEY);

export const walletClient = createWalletClient({
  account: eoa,
  chain: CHAIN,
  transport: http(RPC_URL),
}).extend(publicActions);

export const encodedCounterIncrementData = encodeFunctionData({
  abi: counterAbi,
  functionName: "increment",
});

export const assertAcountHaveNoCode = async () => {
  let code = await walletClient.getCode({ address: walletClient.account.address });
  assert(code === undefined, "Account must have no code");
};

export const assertAcountHaveCode = async () => {
  let code = await walletClient.getCode({ address: walletClient.account.address });
  assert(code !== undefined, "Account must have code");
};

export const logAccountCode = async (msg: string) => {
  let code = await walletClient.getCode({ address: walletClient.account.address });
  console.log(`${msg}: ${code}`);
};

export const logAddresses = () => {
  console.log(`Account address: ${walletClient.account.address}`);
  console.log(`Contract address: ${CONTRACT_ADDRESS}`);
};

export const jsonStringify = (data: unknown) => {
  return JSON.stringify(
    data,
    (_, v) => (typeof v === "bigint" ? v.toString() : v),
    2
  );
};
