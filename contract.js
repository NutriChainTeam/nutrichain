// Configuration de ton projet NutriChain
const contractAddress = "0xb2B4DD7D075DF8302e0c155e7a7E082D6d788311";
const contractABI = [
	{
		"anonymous": false,
		"inputs": [
			{ "indexed": true, "internalType": "address", "name": "validator", "type": "address" },
			{ "indexed": false, "internalType": "string", "name": "proofData", "type": "string" },
			{ "indexed": false, "internalType": "uint256", "name": "timestamp", "type": "uint256" }
		],
		"name": "ProofSubmitted",
		"type": "event"
	},
	{
		"inputs": [ { "internalType": "string", "name": "_data", "type": "string" } ],
		"name": "logProof",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
];

async function certifyProduct(data) {
    if (typeof window.ethereum !== 'undefined') {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(contractAddress, contractABI, signer);

        try {
            const tx = await contract.logProof(data);
            console.log("Transaction envoyée : ", tx.hash);
            await tx.wait();
            alert("Certification réussie sur Hedera !");
        } catch (error) {
            console.error("Erreur : ", error);
            alert("La certification a échoué.");
        }
    } else {
        alert("Installez MetaMask pour certifier !");
    }
}
