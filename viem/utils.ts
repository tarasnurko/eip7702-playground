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

export const PRIVATE_KEY = process.env.PRIVATE_KEY as `0x${string}`;
export const RPC_URL = process.env.RPC_URL;
export const CONTRACT_ADDRESS = process.env.CONTRACT_ADDRESS as `0x${string}`;

export const CHAIN = anvil;

if (!PRIVATE_KEY) {
  throw new Error("PRIVATE_KEY not found in .env file");
}

if (!CONTRACT_ADDRESS) {
  throw new Error("CONTRACT_ADDRESS not found in .env file");
}

export const counterAbi = [
  {
    type: "function",
    name: "increment",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "number",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "setNumber",
    inputs: [{ name: "newNumber", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
] as const;

export const account = privateKeyToAccount(PRIVATE_KEY);

export const walletClient = createWalletClient({
  account,
  chain: CHAIN,
  transport: http(RPC_URL),
}).extend(publicActions);

export const encodedCounterIncrementData = encodeFunctionData({
  abi: counterAbi,
  functionName: "increment",
});

export const logAccountCode = async (msg: string) => {
  let code = await walletClient.getCode({ address: account.address });
  console.log(`${msg}: ${code}`);
};

export const logAddresses = () => {
  console.log(`Account address: ${account.address}`);
  console.log(`Contract address: ${CONTRACT_ADDRESS}`);
};

export const jsonStringify = (data: unknown) => {
  return JSON.stringify(
    data,
    (_, v) => (typeof v === "bigint" ? v.toString() : v),
    2
  );
};
