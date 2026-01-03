import { 
  Client, 
  AccountBalanceQuery,
  TransferTransaction,
  TokenAssociateTransaction,
  AccountId,
  TokenId
} from "@hashgraph/sdk"

export const NCHAIN_TOKEN_ID = "0.0.10136204"

// Obtenir le solde NCHAIN d'un compte
export async function getNChainBalance(accountId) {
  try {
    const client = Client.forMainnet()
    const balance = await new AccountBalanceQuery()
      .setAccountId(accountId)
      .execute(client)
    
    const tokenBalance = balance.tokens.get(TokenId.fromString(NCHAIN_TOKEN_ID))
    return tokenBalance ? tokenBalance.toNumber() / 1000000 : 0 // Diviser par 10^6 (decimals)
  } catch (error) {
    console.error("Erreur lors de la récupération du solde:", error)
    return 0
  }
}

// Associer le token NCHAIN à un compte (requis avant le premier transfert)
export async function associateToken(accountId, privateKey) {
  const client = Client.forMainnet().setOperator(accountId, privateKey)
  
  const transaction = await new TokenAssociateTransaction()
    .setAccountId(accountId)
    .setTokenIds([TokenId.fromString(NCHAIN_TOKEN_ID)])
    .freezeWith(client)
  
  const signTx = await transaction.sign(privateKey)
  const txResponse = await signTx.execute(client)
  const receipt = await txResponse.getReceipt(client)
  
  return receipt.status.toString()
}

// Transférer des tokens NCHAIN (avec clé privée - pour tests uniquement)
export async function transferNChain(fromAccountId, toAccountId, amount, privateKey) {
  const client = Client.forMainnet().setOperator(fromAccountId, privateKey)
  
  const transaction = await new TransferTransaction()
    .addTokenTransfer(NCHAIN_TOKEN_ID, fromAccountId, -amount * 1000000) // Multiplier par 10^6
    .addTokenTransfer(NCHAIN_TOKEN_ID, toAccountId, amount * 1000000)
    .freezeWith(client)
  
  const signTx = await transaction.sign(privateKey)
  const txResponse = await signTx.execute(client)
  const receipt = await txResponse.getReceipt(client)
  
  return receipt.status.toString()
}

// Version avec WalletConnect (pour production)
export async function transferNChainWithWallet(fromAccountId, toAccountId, amount, signer) {
  const client = Client.forMainnet()
  
  const transaction = new TransferTransaction()
    .addTokenTransfer(NCHAIN_TOKEN_ID, fromAccountId, -amount * 1000000)
    .addTokenTransfer(NCHAIN_TOKEN_ID, toAccountId, amount * 1000000)
  
  // Utiliser le signer du wallet connecté
  const frozenTx = await transaction.freezeWithSigner(signer)
  const txResponse = await frozenTx.executeWithSigner(signer)
  const receipt = await txResponse.getReceiptWithSigner(signer)
  
  return receipt.status.toString()
}
