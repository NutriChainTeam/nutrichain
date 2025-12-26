// src/Validators.jsx
import React, { useState } from "react";
import { useAccount, useConnect } from "wagmi";
import { VALIDATOR_WALLETS } from "./validatorsConfig";
import logo from "./assets/logo-nutrichain.png";
import { FaXTwitter, FaTelegram, FaDiscord } from "react-icons/fa6";
import { Link } from "react-router-dom";
import { injected } from "@wagmi/connectors";

const Icon = {
  Shield: (props) => (
    <svg
      viewBox="0 0 24 24"
      width="1em"
      height="1em"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      {...props}
    >
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
      <path d="M9 12l2 2 4-4" />
    </svg>
  ),
  Pin: (props) => (
    <svg
      viewBox="0 0 24 24"
      width="1em"
      height="1em"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      {...props}
    >
      <path d="M21 10c0 5.523-9 12-9 12S3 15.523 3 10a9 9 0 1118 0z" />
      <circle cx="12" cy="10" r="3" />
    </svg>
  ),
  Calendar: (props) => (
    <svg
      viewBox="0 0 24 24"
      width="1em"
      height="1em"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      {...props}
    >
      <rect x="3" y="4" width="18" height="18" rx="2" />
      <path d="M16 2v4M8 2v4M3 10h18" />
    </svg>
  ),
  External: (props) => (
    <svg
      viewBox="0 0 24 24"
      width="1em"
      height="1em"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      {...props}
    >
      <path d="M18 13v6a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
      <path d="M15 3h6v6" />
      <path d="M10 14L21 3" />
    </svg>
  ),
};

const validators = [
  {
    id: 1,
    name: "Fatou Diop",
    role: "Regional Coordinator",
    location: "Dakar, Senegal",
    status: "Active",
    image: logo,
    lastAction: "Distributed 1,200 meals – 2025-12-15",
    videoLink: "https://youtube.com/",
  },
  {
    id: 2,
    name: "Jean Kouassi",
    role: "Logistics Supervisor",
    location: "Abidjan, Ivory Coast",
    status: "On mission",
    image: logo,
    lastAction: "Warehouse audit – 2025-12-20",
    videoLink: "https://youtube.com/",
  },
  {
    id: 3,
    name: "Amina Traoré",
    role: "Quality Manager",
    location: "Bamako, Mali",
    status: "Active",
    image: logo,
    lastAction: "Health inspection – 2025-12-18",
    videoLink: "https://youtube.com/",
  },
];

export default function Validators() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect();
  const [beneficiaryId, setBeneficiaryId] = useState("");
  const [mealsCount, setMealsCount] = useState(1);
  const [proofPhoto, setProofPhoto] = useState(null);
  const [proofVideoUrl, setProofVideoUrl] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const isValidator =
    isConnected &&
    VALIDATOR_WALLETS.some(
      (addr) => addr.toLowerCase() === address?.toLowerCase()
    );

  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError("");
    setSuccess("");

    try {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      setSuccess(
        `Validation succeeded for ${mealsCount} meals, beneficiary ID: ${beneficiaryId}`
      );
    } catch (err) {
      setError("Validation failed. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isConnected) {
    return (
      <div className="p-6 bg-slate-950 min-h-screen text-white">
        <Header connect={connect} />
        <p className="mt-10 text-center text-slate-300">
          Please connect your wallet to access the validators dashboard.
        </p>
        <Footer />
      </div>
    );
  }

  if (!isValidator) {
    return (
      <div className="p-6 bg-slate-950 min-h-screen text-white">
        <Header connect={connect} />
        <p className="mt-10 text-center text-slate-300">
          Access restricted. This area is reserved for approved NutriChain
          validators.
        </p>
        <Footer />
      </div>
    );
  }

  return (
    <div className="p-6 bg-slate-950 min-h-screen text-white flex flex-col">
      <Header connect={connect} />

      {/* Hero */}
      <div className="mb-10 text-center">
        <h2 className="text-3xl font-bold bg-gradient-to-r from-emerald-400 to-cyan-500 bg-clip-text text-transparent mb-2">
          Our field heroes
        </h2>
        <p className="text-slate-400 max-w-2xl mx-auto">
          Trust is not a promise, it is proof. Discover the agents who validate
          every NutriChain distribution in real time.
        </p>
        <div className="mt-2">
          <Link
            to="/about-governance"
            className="text-xs text-sky-400 hover:text-sky-300 underline"
          >
            Governance details
          </Link>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        <Stat
          icon={<Icon.Shield />}
          value="12"
          label="Certified validators"
          color="emerald"
        />
        <Stat
          icon={<Icon.Pin />}
          value="5 countries"
          label="Regions covered"
          color="blue"
        />
        <Stat
          icon={<Icon.Calendar />}
          value="24h"
          label="Average proof delay"
          color="purple"
        />
      </div>

      {/* Validators list */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
        {validators.map((v) => (
          <div
            key={v.id}
            className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden hover:border-emerald-500/30 transition"
          >
            <div className="relative h-48">
              <img
                src={v.image}
                alt={v.name}
                className="w-full h-full object-cover"
              />
              <span
                className={`absolute top-3 right-3 px-3 py-1 text-xs rounded-full ${
                  v.status === "Active"
                    ? "bg-emerald-500/20 text-emerald-300"
                    : "bg-amber-500/20 text-amber-300"
                }`}
              >
                {v.status}
              </span>
            </div>

            <div className="p-5">
              <h3 className="font-bold">{v.name}</h3>
              <p className="text-sm text-emerald-400">{v.role}</p>

              <div className="mt-4 space-y-2 text-sm text-slate-300">
                <div className="flex items-center gap-2">
                  <Icon.Pin /> {v.location}
                </div>
                <div className="flex items-center gap-2">
                  <Icon.Calendar /> {v.lastAction}
                </div>
              </div>

              <a
                href={v.videoLink}
                target="_blank"
                rel="noreferrer"
                className="mt-4 flex items-center justify-center gap-1 text-xs text-slate-400 hover:text-white"
              >
                View report <Icon.External />
              </a>
            </div>
          </div>
        ))}
      </div>

      {/* Validation form */}
      <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6 mt-4 mb-10">
        <h3 className="text-xl font-bold mb-4">Validate a distribution</h3>
        <form onSubmit={handleSubmit} className="max-w-md mx-auto">
          <div className="mb-4">
            <label className="block text-sm font-medium mb-1">
              Beneficiary ID (or QR code)
            </label>
            <input
              type="text"
              value={beneficiaryId}
              onChange={(e) => setBeneficiaryId(e.target.value)}
              className="w-full px-4 py-2 rounded-lg bg-slate-800 border border-slate-600 focus:outline-none focus:ring-2 focus:ring-emerald-500"
              placeholder="Enter ID or scan QR"
              required
            />
          </div>

          <div className="mb-4">
            <label className="block text-sm font-medium mb-1">
              Number of meals
            </label>
            <input
              type="number"
              value={mealsCount}
              onChange={(e) => setMealsCount(e.target.value)}
              className="w-full px-4 py-2 rounded-lg bg-slate-800 border border-slate-600 focus:outline-none focus:ring-2 focus:ring-emerald-500"
              min="1"
              required
            />
          </div>

          <div className="mb-4">
            <label className="block text-sm font-medium mb-1">
              Proof photo (optional)
            </label>
            <input
              type="file"
              accept="image/*"
              onChange={(e) => setProofPhoto(e.target.files[0])}
              className="w-full px-4 py-2 rounded-lg bg-slate-800 border border-slate-600 focus:outline-none focus:ring-2 focus:ring-emerald-500"
            />
          </div>

          <div className="mb-4">
            <label className="block text-sm font-medium mb-1">
              Proof video link (optional)
            </label>
            <input
              type="url"
              value={proofVideoUrl}
              onChange={(e) => setProofVideoUrl(e.target.value)}
              className="w-full px-4 py-2 rounded-lg bg-slate-800 border border-slate-600 focus:outline-none focus:ring-2 focus:ring-emerald-500"
              placeholder="https://youtube.com/..."
            />
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full py-3 bg-emerald-500 hover:bg-emerald-600 rounded-lg font-bold transition disabled:opacity-70"
          >
            {isSubmitting ? "Submitting validation..." : "Validate distribution"}
          </button>

          {error && (
            <p className="mt-4 text-red-400 text-center">{error}</p>
          )}
          {success && (
            <p className="mt-4 text-emerald-400 text-center">{success}</p>
          )}
        </form>
      </div>

      <Footer />
    </div>
  );
}

function Header({ connect }) {
  return (
    <header className="flex items-center justify-between mb-8">
      <div className="flex items-center gap-3">
        <img src={logo} alt="NutriChain" className="h-10 w-10 rounded-full" />
        <div>
          <h1 className="text-2xl font-bold">NutriChain Validators</h1>
          <p className="text-xs text-slate-400">
            On‑chain transparency for every donated meal.
          </p>
        </div>
      </div>
      <button
        onClick={() => connect({ connector: injected() })}
        className="px-4 py-2 bg-emerald-500 hover:bg-emerald-600 rounded-lg font-bold text-white"
      >
        Connect Wallet
      </button>
    </header>
  );
}

function Footer() {
  return (
    <footer className="mt-auto pt-6 border-t border-slate-800 text-sm text-slate-400 flex flex-col md:flex-row items-center justify-between gap-3">
      <span>© {new Date().getFullYear()} NutriChain. All rights reserved.</span>
      <div className="flex items-center gap-4">
        <a
          href="https://x.com/nutrichain_"
          target="_blank"
          rel="noreferrer"
          className="flex items-center gap-1 hover:text-white"
        >
          <FaXTwitter /> X
        </a>
        <a
          href="https://t.me/NutriChainTeam"
          target="_blank"
          rel="noreferrer"
          className="flex items-center gap-1 hover:text-white"
        >
          <FaTelegram /> Telegram
        </a>
        <a
          href="https://discord.gg/MZ39wQwb"
          target="_blank"
          rel="noreferrer"
          className="flex items-center gap-1 hover:text-white"
        >
          <FaDiscord /> Discord
        </a>
      </div>
    </footer>
  );
}

function Stat({ icon, value, label, color }) {
  return (
    <div className="bg-slate-900/50 border border-slate-800 p-4 rounded-xl flex items-center gap-4">
      <div className={`p-3 bg-${color}-500/10 text-${color}-400 rounded-lg`}>
        {icon}
      </div>
      <div>
        <h4 className="text-2xl font-bold">{value}</h4>
        <p className="text-sm text-slate-400">{label}</p>
      </div>
    </div>
  );
}
