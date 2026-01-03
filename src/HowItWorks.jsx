import React from 'react';
import { Wallet, Vote, Utensils } from 'lucide-react'; // Assure-toi d'avoir lucide-react ou utilise des <i>

const HowItWorks = () => {
  return (
    <div className="max-w-5xl mx-auto p-8 text-white">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold mb-4">From Crypto to Meals</h1>
        <p className="text-slate-400">How NutriChain converts digital assets into real-world impact.</p>
      </div>

      <div className="space-y-8">
        {/* Step 1 */}
        <div className="bg-slate-900 p-6 rounded-xl border border-slate-800 flex items-center gap-6">
          <div className="bg-blue-500/10 p-4 rounded-full text-blue-400">
             <Wallet size={32} />
          </div>
          <div>
            <h3 className="text-xl font-bold">1. Donation</h3>
            <p className="text-slate-400">Donors send crypto or stake NCHAIN. Funds are secured in the Treasury.</p>
          </div>
        </div>

        {/* Step 2 */}
        <div className="bg-slate-900 p-6 rounded-xl border border-slate-800 flex items-center gap-6">
          <div className="bg-purple-500/10 p-4 rounded-full text-purple-400">
             <Vote size={32} />
          </div>
          <div>
            <h3 className="text-xl font-bold">2. Governance Vote</h3>
            <p className="text-slate-400">Holders vote on which NGOs receive funding.</p>
          </div>
        </div>

        {/* Step 3 */}
        <div className="bg-slate-900 p-6 rounded-xl border border-slate-800 flex items-center gap-6">
          <div className="bg-orange-500/10 p-4 rounded-full text-orange-400">
             <Utensils size={32} />
          </div>
          <div>
            <h3 className="text-xl font-bold">3. Distribution</h3>
            <p className="text-slate-400">Meals are distributed and proof is uploaded to IPFS.</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default HowItWorks;
