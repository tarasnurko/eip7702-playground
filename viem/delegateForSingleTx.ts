import {
  account,
  CHAIN,
  CONTRACT_ADDRESS,
  encodedCounterIncrementData,
  jsonStringify,
  logAccountCode,
  logAddresses,
  walletClient,
} from "./utils";

const main = async () => {
  await logAccountCode("EoA code before transaction");

  logAddresses();

  const authorization = await account.signAuthorization({
    contractAddress: CONTRACT_ADDRESS,
    chainId: CHAIN.id,
    nonce: await walletClient.getTransactionCount({
      address: account.address,
    }),
  });

  console.log(`Authorization data: ${jsonStringify(authorization)}`);

  const hash = await walletClient.sendTransaction({
    account,
    to: account.address,
    data: encodedCounterIncrementData,
    authorizationList: [authorization],
  });

  await walletClient.waitForTransactionReceipt({ hash });

  logAddresses();

  await logAccountCode("EoA code after transaction");
};

main();
