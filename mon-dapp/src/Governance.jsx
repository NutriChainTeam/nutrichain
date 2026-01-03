import React from 'react'
import { FaShieldHalved, FaScaleBalanced } from "react-icons/fa6"
import './App.css'

const Governance = () => {
  return (
    <div className="App" style={{ background: '#020617', minHeight: '100vh', display: 'flex', flexDirection: 'column', color: '#fff', padding: '0 25px' }}>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', height: '80px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <img src="./logo-nutrichain.png" alt="Logo" style={{ width: '38px', height: '38px', borderRadius: '50%' }} />
          <div>
            <h1 style={{ fontSize: '18px', fontWeight: 'bold', margin: 0 }}>NutriChain Protocol</h1>
            <div style={{ fontSize: '10px', color: '#22c55e', textTransform: 'uppercase' }}>● Governance Framework</div>
          </div>
        </div>
      </header>

      <main style={{ flex: 1, padding: '60px 0', maxWidth: '900px', margin: '0 auto', width: '100%' }}>
        <section style={{ textAlign: 'center', marginBottom: '60px' }}>
          <h2 style={{ fontSize: '32px', marginBottom: '20px' }}>Governance & Transparency</h2>
          <p style={{ color: '#9ca3af', lineHeight: '1.6' }}>
            NutriChain operates as a decentralized autonomous infrastructure for food security. 
            Leveraging Hedera's HCS and Smart Contracts to ensure integrity.
          </p>
        </section>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '30px' }}>
          <div style={{ background: 'rgba(255,255,255,0.02)', padding: '30px', borderRadius: '16px', border: '1px solid rgba(255,255,255,0.05)' }}>
            <FaShieldHalved style={{ fontSize: '24px', color: '#22c55e', marginBottom: '15px' }} />
            <h3 style={{ marginBottom: '10px' }}>Proof of Integrity</h3>
            <p style={{ fontSize: '14px', color: '#9ca3af' }}>Only authorized regional validators can anchor data.</p>
          </div>
          <div style={{ background: 'rgba(255,255,255,0.02)', padding: '30px', borderRadius: '16px', border: '1px solid rgba(255,255,255,0.05)' }}>
            <FaScaleBalanced style={{ fontSize: '24px', color: '#22c55e', marginBottom: '15px' }} />
            <h3 style={{ marginBottom: '10px' }}>Smart Policy</h3>
            <p style={{ fontSize: '14px', color: '#9ca3af' }}>Rules are hardcoded in immutable contracts.</p>
          </div>
        </div>
      </main>

      <footer style={{ height: '60px', borderTop: '1px solid rgba(255,255,255,0.05)', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '10px', color: '#4b5563' }}>
        <span>© 2026 NUTRICHAIN PROTOCOL. SECURED BY HEDERA.</span>
      </footer>
    </div>
  )
}

export default Governance
