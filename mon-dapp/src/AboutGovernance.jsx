import React from "react";

export default function AboutGovernance() {
  return (
    <div className="max-w-4xl mx-auto px-4 py-8 text-white">
      {/* 1. LES CARTES */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
        <div className="bg-slate-900/40 p-8 rounded-2xl border border-slate-800">
          <div className="text-green-500 mb-4 text-2xl">🛡️</div>
          <h3 className="text-white font-bold mb-2">Proof of Integrity</h3>
          <p className="text-slate-400 text-sm">Only authorized regional validators can anchor data.</p>
        </div>
        <div className="bg-slate-900/40 p-8 rounded-2xl border border-slate-800">
          <div className="text-green-500 mb-4 text-2xl">⚖️</div>
          <h3 className="text-white font-bold mb-2">Smart Policy</h3>
          <p className="text-slate-400 text-sm">Rules are hardcoded in immutable contracts.</p>
        </div>
      </div>

      {/* 2. LE TEXTE DÉTAILLÉ */}
      <div className="space-y-10 text-left border-t border-slate-800 pt-12">
        <section>
          <h2 className="text-2xl font-bold mb-4">What is NCHAIN?</h2>
          <p className="text-slate-300 leading-relaxed">
            NCHAIN is NutriChain’s impact token issued on the Hedera network via the Hedera Token Service (HTS).
            Each token is designed to represent funding for real-world food projects, following the simple idea that one NUTRI/NCHAIN approximately equals one meal in the current model.
          </p>
        </section>

        <section>
          <h2 className="text-2xl font-bold mb-4">How governance works today</h2>
          <p className="text-slate-300 leading-relaxed">
            Governance proposals are created and stored in the NutriChain backend. Your voting power is equal to your current NCHAIN balance, which is read from the Hedera Mirror Node.
          </p>
        </section>

        <section className="bg-slate-900/20 p-6 rounded-xl border border-slate-800">
          <h2 className="text-xl font-bold mb-4 text-green-500">On-chain (Hedera testnet)</h2>
          <ul className="text-xs font-mono text-slate-400 space-y-2">
            <li>NChainToken: 0xfe212d7db6b4bD072ac3B00F91Aa45333cc404C8</li>
            <li>NutriTimelock: 0xEF7B4ED0c99cfE7384A503dea7CB209c20Ae79CD</li>
            <li>NutriGovernance: 0x19D7865A985A8C9e6ECaEe989526298719786355</li>
          </ul>
        </section>

        {/* 3. LE BOUTON DE VOTE */}
        <div className="text-center pt-8 pb-12">
          <a href="/governance/" className="inline-block bg-green-600 hover:bg-green-500 text-white font-bold py-4 px-10 rounded-xl transition-all shadow-lg shadow-green-900/20">
            Go to Voting Portal (HashioDAO)
          </a>
        </div>
      </div>
    </div>
  );
}
