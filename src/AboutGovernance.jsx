// src/AboutGovernance.jsx
import React from "react";
import { Layout } from "./Layout";

export default function AboutGovernance() {
  return (
    <Layout>
      <div className="max-w-3xl mx-auto">
        <header className="mb-8 flex items-center justify-between">
          <h1 className="text-2xl font-bold text-white">
            About NutriChain Governance
          </h1>
        </header>

        <section className="mb-6">
          <h2 className="text-lg font-semibold text-white mb-2">
            What is NCHAIN?
          </h2>
          <p className="text-sm text-slate-300">
            NCHAIN is NutriChain’s impact token issued on the Hedera network via
            the Hedera Token Service (HTS). Each token represents funding for
            real-world food projects, following the idea that one NUTRI/NCHAIN
            approximately equals one meal.
          </p>
        </section>

        <section className="mb-6">
          <h2 className="text-lg font-semibold text-white mb-2">
            How governance works today
          </h2>
          <p className="text-sm text-slate-300">
            Governance proposals are created and stored in the NutriChain
            backend, and the governance interface lets you submit and vote on
            these proposals using your Hedera account. When you provide your
            Hedera account, your voting power equals your current NCHAIN
            balance; if you do not provide an account, your vote counts as one.
          </p>
        </section>

        <section className="mb-6">
          <h2 className="text-lg font-semibold text-white mb-2">
            Off-chain and on-chain layers
          </h2>
          <p className="text-sm text-slate-300">
            The off-chain layer (Flask backend) aggregates proposals and
            NCHAIN‑weighted votes, exposing them via simple APIs like
            <code> /proposals</code>, <code> /vote/&lt;id&gt;</code>, and
            <code> /proposals/&lt;id&gt;/results</code>. The on-chain layer
            uses smart contracts (Governor, Timelock, Vault) that will execute
            approved decisions on an EVM‑compatible network such as Hedera
            Smart Contract Service.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="text-lg font-semibold text-white mb-2">
            On-chain (Hedera testnet)
          </h2>
          <p className="text-sm text-slate-300 mb-2">
            These contracts are deployed on Hedera testnet (EVM, chainId 296)
            and are used to test NutriChain governance before any mainnet
            deployment.
          </p>
          <ul className="text-xs text-slate-300 space-y-1 font-mono">
            <li>
              NChainToken (testnet):
              0xfe212d7db6b4bD072ac3B00F91Aa45333cc404C8
            </li>
            <li>
              NutriTimelock (testnet):
              0xEF7B4ED0c99cfE7384A503dea7CB209c20Ae79CD
            </li>
            <li>
              NutriGovernance (testnet):
              0x19D7865A985A8C9e6ECaEe989526298719786355
            </li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="text-lg font-semibold text-white mb-2">
            Transparency and references
          </h2>
          <p className="text-sm text-slate-300">
            NutriChain publishes the NCHAIN token ID, the treasury account, and
            the governance contract addresses, together with links to public
            explorers such as HashScan. The source code of the governance
            contracts and deployment scripts is available on the project’s
            GitHub so anyone can review how proposals, voting, and treasury
            actions are implemented.
          </p>
        </section>

        <footer className="text-xs text-slate-500 border-t border-slate-800 pt-4">
          <p>
            This page is informational and does not replace the on‑chain rules
            defined by the smart contracts once they are deployed.
          </p>
        </footer>
      </div>
    </Layout>
  );
}
