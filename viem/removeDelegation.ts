import { zeroAddress } from "viem";
import {
  assertAcountHaveCode,
  assertAcountHaveNoCode,
  jsonStringify,
  logAccountCode,
  walletClient,
} from "./utils";

const main = async () => {
  await logAccountCode("EoA code before removing delegation");
  console.log(`Account address: ${walletClient.account.address}`);

  await assertAcountHaveCode();

  const authorization = await walletClient.signAuthorization({
    contractAddress: zeroAddress,
    executor: "self",
  });

  console.log(`Authorization data: ${jsonStringify(authorization)}`);

  const hash = await walletClient.sendTransaction({
    to: walletClient.account.address,
    data: "0x",
    authorizationList: [authorization],
  });

  console.log(`Transaction hash: ${hash}`);

  await walletClient.waitForTransactionReceipt({ hash });

  await logAccountCode("EoA code after removing delegation");

  await assertAcountHaveNoCode();

  console.log("Delegation removed successfully!");
};

main();
