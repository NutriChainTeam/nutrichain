import React, { useState, useEffect } from "react";
import { 
  useAccount, 
  useConnect, 
  useDisconnect, 
  useWriteContract, 
  useWaitForTransactionReceipt 
} from "wagmi";
import { VALIDATOR_WALLETS } from "./validatorsConfig";
import logo from "./assets/logo-nutrichain.png";
import { FaXTwitter, FaTelegram, FaDiscord } from "react-icons/fa6";
import { Link } from "react-router-dom";
import { injected } from "@wagmi/connectors";

// --- Composants Icones (inchangés) ---
const Icon = {
  Shield: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" /><path d="M9 12l2 2 4-4" />
    </svg>
  ),
  Pin: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
      <path d="M21 10c0 5.523-9 12-9 12S3 15.523 3 10a9 9 0 1118 0z" /><circle cx="12" cy="10" r="3" />
    </svg>
  ),
  Calendar: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
      <rect x="3" y="4" width="18" height="18" rx="2" /><path d="M16 2v4M8 2v4M3 10h18" />
    </svg>
  ),
  External: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
      <path d="M18 13v6a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" /><path d="M15 3h6v6" /><path d="M10 14L21 3" />
    </svg>
  ),
};

const validators = [
  { id: 1, name: "Fatou Diop", role: "Regional Coordinator", location: "Dakar, Senegal", status: "Active", lastAction: "Distributed 1,200 meals – 2025-12-15", videoLink: "https://youtube.com/" },
  { id: 2, name: "Jean Kouassi", role: "Logistics Supervisor", location: "Abidjan, Ivory Coast", status: "On mission", lastAction: "Warehouse audit – 2025-12-20", videoLink: "https://youtube.com/" },
  { id: 3, name: "Amina Traoré", role: "Quality Manager", location: "Bamako, Mali", status: "Active", lastAction: "Health inspection – 2025-12-18", videoLink: "https://youtube.com/" },
];

export default function Validators() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();

  // États du formulaire
  const [beneficiaryId, setBeneficiaryId] = useState("");
  const [mealsCount, setMealsCount] = useState(1);
  const [proofPhoto, setProofPhoto] = useState(null);
  const [proofVideoUrl, setProofVideoUrl] = useState("");
  
  // États de feedback
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // Logic Blockchain via Wagmi
  const { data: hash, writeContract, isPending: isSigning } = useWriteContract();
  
  const { isLoading: isConfirming, isSuccess: isConfirmed } = 
    useWaitForTransactionReceipt({ hash });

  const isValidator = isConnected && VALIDATOR_WALLETS.some(
    (addr) => addr.toLowerCase() === address?.toLowerCase()
  );

  // Gérer la fin de la transaction
  useEffect(() => {
    if (isConfirmed) {
      setSuccess(`Proof anchored on Hedera! Transaction: ${hash.slice(0, 10)}...`);
      setBeneficiaryId("");
      setMealsCount(1);
    }
  }, [isConfirmed, hash]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");

    if (!isValidator) {
      setError("Unauthorized: Only validators can submit proofs.");
      return;
    }

    try {
      // Données à inscrire en dur sur la chaîne
      const proofPayload = JSON.stringify({
        id: beneficiaryId,
        meals: mealsCount,
        video: proofVideoUrl || "none",
        date: new Date().toISOString()
      });

      writeContract({
        address: '0x0000000000000000000000000000000000000000', // REMPLACER PAR TON CONTRAT
        abi: [{
          "inputs": [{"internalType": "string", "name": "data", "type": "string"}],
          "name": "logProof",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        }],
        functionName: 'logProof',
        args: [proofPayload],
      });
    } catch (err) {
      console.error(err);
      setError("Failed to initiate transaction.");
    }
  };

  return (
    <div className="p-6 bg-slate-950 min-h-screen text-white flex flex-col">
      <Header connect={connect} address={address} disconnect={disconnect} isConnected={isConnected} />

      {!isConnected ? (
        <p className="mt-10 text-center text-slate-300">Please connect your wallet to access the validators dashboard.</p>
      ) : !isValidator ? (
        <p className="mt-10 text-center text-slate-300">Access restricted. Reserved for approved NutriChain validators.</p>
      ) : (
        <>
          <div className="mb-10 text-center">
            <h2 className="text-3xl font-bold bg-gradient-to-r from-emerald-400 to-cyan-500 bg-clip-text text-transparent mb-2">Field Operations</h2>
            <p className="text-slate-400 max-w-2xl mx-auto">Every signature below triggers a permanent record on the Hedera network.</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
            <Stat icon={<Icon.Shield />} value="12" label="Active Validators" color="emerald" />
            <Stat icon={<Icon.Pin />} value="5" label="Active Regions" color="blue" />
            <Stat icon={<Icon.Calendar />} value="< 1h" label="Sync Speed" color="purple" />
          </div>

          {/* Validation form */}
          <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 mb-10 max-w-2xl mx-auto w-full">
            <h3 className="text-xl font-bold mb-4 flex items-center gap-2">
              <Icon.Shield className="text-emerald-400" /> New Proof of Distribution
            </h3>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium mb-1 text-slate-400">Beneficiary ID</label>
                <input type="text" value={beneficiaryId} onChange={(e) => setBeneficiaryId(e.target.value)} className="w-full px-4 py-2 rounded-lg bg-slate-850 border border-slate-700 focus:ring-2 focus:ring-emerald-500 outline-none transition" placeholder="NC-2025-XXXX" required />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1 text-slate-400">Meal Quantity</label>
                <input type="number" value={mealsCount} onChange={(e) => setMealsCount(e.target.value)} className="w-full px-4 py-2 rounded-lg bg-slate-850 border border-slate-700 focus:ring-2 focus:ring-emerald-500 outline-none" min="1" required />
              </div>
              <div>
                <label className="block text-sm font-medium mb-1 text-slate-400">Video Evidence Link (YouTube/IPFS)</label>
                <input type="url" value={proofVideoUrl} onChange={(e) => setProofVideoUrl(e.target.value)} className="w-full px-4 py-2 rounded-lg bg-slate-850 border border-slate-700 focus:ring-2 focus:ring-emerald-500 outline-none" placeholder="https://..." />
              </div>

              <button 
                type="submit" 
                disabled={isSigning || isConfirming} 
                className={`w-full py-3 rounded-lg font-bold transition flex justify-center items-center gap-2 ${
                  isSigning || isConfirming ? "bg-slate-700 cursor-not-allowed" : "bg-emerald-500 hover:bg-emerald-600 shadow-lg shadow-emerald-500/20"
                }`}
              >
                {isSigning ? "Check your wallet..." : isConfirming ? "Anchoring on Chain..." : "Sign & Send Proof"}
              </button>

              {error && <div className="p-3 bg-red-500/10 border border-red-500/50 rounded-lg text-red-400 text-sm text-center">{error}</div>}
              {success && <div className="p-3 bg-emerald-500/10 border border-emerald-500/50 rounded-lg text-emerald-400 text-sm text-center">{success}</div>}
            </form>
          </div>
        </>
      )}
      <Footer />
    </div>
  );
}

// --- Sous-composants (Header, Footer, Stat inchangés mais stylisés) ---

function Header({ connect, address, disconnect, isConnected }) {
  return (
    <header className="flex items-center justify-between mb-8">
      <div className="flex items-center gap-3">
        <img src={logo} alt="NutriChain" className="h-10 w-10 rounded-full" />
        <div>
          <h1 className="text-xl font-bold">Validators Hub</h1>
          <div className="flex items-center gap-1.5 text-[10px] text-emerald-500 uppercase tracking-wider font-bold">
            <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-pulse" /> Hedera Mainnet
          </div>
        </div>
      </div>
      {isConnected ? (
        <div className="flex items-center gap-3">
          <div className="hidden md:block text-right">
            <p className="text-[10px] text-slate-500">Connected As</p>
            <p className="text-xs font-mono text-emerald-400">{address?.slice(0, 6)}...{address?.slice(-4)}</p>
          </div>
          <button onClick={() => disconnect()} className="px-3 py-1.5 bg-slate-900 border border-slate-800 hover:bg-red-500/10 hover:border-red-500/50 rounded-lg text-xs transition">
            Disconnect
          </button>
        </div>
      ) : (
        <button onClick={() => connect({ connector: injected() })} className="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 rounded-lg font-bold text-white text-sm transition shadow-lg shadow-emerald-500/20">
          Connect Wallet
        </button>
      )}
    </header>
  );
}

function Footer() {
  return (
    <footer className="mt-auto pt-6 border-t border-slate-900 text-[10px] text-slate-500 flex flex-col md:flex-row items-center justify-between gap-3">
      <span>© {new Date().getFullYear()} NUTRICHAIN PROTOCOL. SECURED BY HEDERA.</span>
      <div className="flex items-center gap-4 text-sm">
        <a href="#" className="hover:text-emerald-400 transition"><FaXTwitter /></a>
        <a href="#" className="hover:text-emerald-400 transition"><FaTelegram /></a>
        <a href="#" className="hover:text-emerald-400 transition"><FaDiscord /></a>
      </div>
    </footer>
  );
}

function Stat({ icon, value, label, color }) {
  const colorMap = {
    emerald: "text-emerald-400 bg-emerald-500/10",
    blue: "text-blue-400 bg-blue-500/10",
    purple: "text-purple-400 bg-purple-500/10"
  };
  return (
    <div className="bg-slate-900/50 border border-slate-900 p-4 rounded-xl flex items-center gap-4">
      <div className={`p-3 rounded-lg ${colorMap[color]}`}>{icon}</div>
      <div>
        <h4 className="text-xl font-bold">{value}</h4>
        <p className="text-[10px] text-slate-500 uppercase tracking-widest font-bold">{label}</p>
      </div>
    </div>
  );
}
