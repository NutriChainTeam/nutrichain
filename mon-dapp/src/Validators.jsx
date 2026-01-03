import React, { useState, useEffect, useMemo } from "react";
import { 
  useAccount, 
  useConnect, 
  useDisconnect, 
  useWriteContract, 
  useWaitForTransactionReceipt 
} from "wagmi";
import { VALIDATOR_WALLETS } from "../../src/validatorsConfig";
import { FaXTwitter, FaTelegram, FaDiscord } from "react-icons/fa6";
import { injected } from "@wagmi/connectors";

export default function Validators() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect();
  const { disconnect } = useDisconnect();

  const [beneficiaryId, setBeneficiaryId] = useState("");
  const [mealsCount, setMealsCount] = useState(1);
  const [location, setLocation] = useState("");
  const [history, setHistory] = useState([]); // Historique local
  
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const { data: hash, writeContract, isPending: isSigning } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } = useWaitForTransactionReceipt({ hash });

  const isValidator = useMemo(() => {
    return isConnected && VALIDATOR_WALLETS.some(
      (addr) => addr.toLowerCase() === address?.toLowerCase()
    );
  }, [isConnected, address]);

  useEffect(() => {
    if (isConfirmed) {
      const newEntry = {
        id: beneficiaryId,
        meals: mealsCount,
        loc: location,
        time: new Date().toLocaleTimeString(),
        tx: hash.slice(0, 10) + "..."
      };
      setHistory([newEntry, ...history.slice(0, 4)]); // Garde les 5 derniers
      setSuccess("Proof anchored on Hedera!");
      setBeneficiaryId("");
      setMealsCount(1);
      setLocation("");
    }
  }, [isConfirmed]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(""); setSuccess("");
    try {
      const proofPayload = JSON.stringify({ id: beneficiaryId, meals: mealsCount, location: location, date: new Date().toISOString() });
      writeContract({
        address: '0x00000000000000000000000000000000009bd54f',
        abi: [{ "inputs": [{"internalType": "string", "name": "data", "type": "string"}], "name": "logProof", "outputs": [], "stateMutability": "nonpayable", "type": "function" }],
        functionName: 'logProof',
        args: [proofPayload],
      });
    } catch (err) { setError("Failed to initiate transaction."); }
  };

  return (
    <div className="App" style={{ background: '#020617', minHeight: '100vh', display: 'flex', flexDirection: 'column', color: '#fff', padding: '0 25px' }}>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', height: '80px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <img src="./logo-nutrichain.png" alt="Logo" style={{ width: '38px', height: '38px', borderRadius: '50%' }} />
          <div>
            <h1 style={{ fontSize: '18px', fontWeight: 'bold', margin: 0 }}>Validators Hub</h1>
            <div style={{ fontSize: '10px', color: '#22c55e', textTransform: 'uppercase' }}>● Hedera Mainnet</div>
          </div>
        </div>
        <button onClick={() => isConnected ? disconnect() : connect({ connector: injected() })} style={{ padding: '10px 20px', background: isConnected ? 'rgba(255,255,255,0.05)' : '#22c55e', border: 'none', color: '#fff', borderRadius: '8px', cursor: 'pointer' }}>
          {isConnected ? address.slice(0,6)+'...'+address.slice(-4) : 'Connect Wallet'}
        </button>
      </header>

      <main style={{ flex: 1, padding: '40px 0', maxWidth: '800px', margin: '0 auto', width: '100%' }}>
        {isConnected && isValidator ? (
          <>
            <form onSubmit={handleSubmit} style={{ background: 'rgba(255,255,255,0.02)', padding: '30px', borderRadius: '16px', border: '1px solid rgba(255,255,255,0.05)', marginBottom: '40px' }}>
              <h2 style={{ fontSize: '20px', marginBottom: '20px' }}>New Proof of Distribution</h2>
              <input type="text" placeholder="Beneficiary ID" value={beneficiaryId} onChange={(e) => setBeneficiaryId(e.target.value)} style={{ width: '100%', padding: '12px', background: '#0f172a', border: '1px solid #334155', borderRadius: '8px', color: '#fff', marginBottom: '15px' }} required />
              <input type="text" placeholder="Location (City, Country)" value={location} onChange={(e) => setLocation(e.target.value)} style={{ width: '100%', padding: '12px', background: '#0f172a', border: '1px solid #334155', borderRadius: '8px', color: '#fff', marginBottom: '15px' }} required />
              <input type="number" placeholder="Quantity" value={mealsCount} onChange={(e) => setMealsCount(e.target.value)} style={{ width: '100%', padding: '12px', background: '#0f172a', border: '1px solid #334155', borderRadius: '8px', color: '#fff', marginBottom: '20px' }} required />
              <button type="submit" disabled={isSigning || isConfirming} style={{ width: '100%', padding: '15px', background: '#22c55e', borderRadius: '8px', fontWeight: 'bold', color: '#fff', cursor: 'pointer' }}>
                {isSigning ? "Sign in Wallet..." : isConfirming ? "Anchoring..." : "Sign & Send Proof"}
              </button>
              {success && <p style={{ color: '#22c55e', marginTop: '10px', textAlign: 'center' }}>{success}</p>}
            </form>

            <div style={{ background: 'rgba(255,255,255,0.01)', borderRadius: '16px', padding: '20px', border: '1px solid rgba(255,255,255,0.05)' }}>
              <h3 style={{ fontSize: '14px', color: '#9ca3af', marginBottom: '15px' }}>Recent Session Activity</h3>
              <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
                <thead>
                  <tr style={{ color: '#4b5563', borderBottom: '1px solid #1e293b', textAlign: 'left' }}>
                    <th style={{ padding: '10px' }}>ID</th>
                    <th>Location</th>
                    <th>Qty</th>
                    <th>TX Hash</th>
                  </tr>
                </thead>
                <tbody>
                  {history.map((item, i) => (
                    <tr key={i} style={{ borderBottom: '1px solid #0f172a' }}>
                      <td style={{ padding: '10px' }}>{item.id}</td>
                      <td>{item.loc}</td>
                      <td>{item.meals}</td>
                      <td style={{ color: '#22c55e', fontFamily: 'monospace' }}>{item.tx}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {history.length === 0 && <p style={{ textAlign: 'center', color: '#374151', padding: '20px' }}>No transactions this session.</p>}
            </div>
          </>
        ) : (
          <p style={{ textAlign: 'center', color: '#9ca3af' }}>Please connect an authorized validator wallet.</p>
        )}
      </main>

      <footer style={{ height: '60px', borderTop: '1px solid rgba(255,255,255,0.05)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '10px', color: '#4b5563' }}>
        <span>© 2026 NUTRICHAIN PROTOCOL.</span>
        <div style={{ display: 'flex', gap: '15px', fontSize: '16px' }}>
          <FaXTwitter /> <FaTelegram /> <FaDiscord />
        </div>
      </footer>
    </div>
  );
}
