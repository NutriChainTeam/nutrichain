import { useState, useEffect } from 'react'
import { useAppKitAccount } from '@reown/appkit/react'
import { getNChainBalance, transferNChain, NCHAIN_TOKEN_ID } from './hederaUtils'
import './App.css'

export default function App() {
  const { address, isConnected } = useAppKitAccount()
  const [nchainBalance, setNchainBalance] = useState(0)
  const [recipientAddress, setRecipientAddress] = useState('')
  const [amount, setAmount] = useState('')
  const [loading, setLoading] = useState(false)
  const [message, setMessage] = useState({ text: '', type: '' })

  useEffect(() => {
    if (isConnected && address) {
      loadBalance()
    }
  }, [isConnected, address])

  const loadBalance = async () => {
    const balance = await getNChainBalance(address)
    setNchainBalance(balance)
  }

  const handleTransfer = async (e) => {
    e.preventDefault()
    setLoading(true)
    setMessage({ text: '', type: '' })

    try {
      await transferNChain(address, recipientAddress, parseFloat(amount))
      setMessage({
        text: '✅ Transfer successful.',
        type: 'success'
      })

      setTimeout(loadBalance, 2000)
      setRecipientAddress('')
      setAmount('')
    } catch (error) {
      setMessage({
        text: `❌ Error: ${error.message}`,
        type: 'error'
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="App" style={{ maxWidth: '600px', margin: '0 auto', padding: '20px' }}>
      {/* Header with NutriChain logo */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '20px' }}>
        {/* Replace /logo-nutrichain.png by your real logo path in public/ or src/assets */}
        <img
          src="/logo-nutrichain.png"
          alt="NutriChain logo"
          style={{ width: '32px', height: '32px', borderRadius: '8px' }}
        />
        <div>
          <h1 style={{ margin: 0, fontSize: '1.3rem', color: '#e5e7eb' }}>NutriChain Wallet</h1>
          <p style={{ margin: 0, fontSize: '0.85rem', color: '#9ca3af' }}>
            Manage and transfer your NCHAIN tokens.
          </p>
        </div>
      </div>

      {/* Wallet connect button */}
      <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '30px' }}>
        <appkit-button />
      </div>

      {isConnected ? (
        <>
          {/* Balance card */}
          <div
            className="card"
            style={{
              background: '#1a1f2e',
              borderRadius: '12px',
              padding: '20px',
              border: '1px solid #374151',
              marginBottom: '20px',
              color: 'white'
            }}
          >
            <h3
              style={{
                margin: '0 0 10px 0',
                fontSize: '0.9rem',
                color: '#9ca3af',
                textTransform: 'uppercase'
              }}
            >
              NCHAIN balance
            </h3>
            <div style={{ fontSize: '2.5rem', fontWeight: 'bold', color: '#10b981' }}>
              {nchainBalance.toLocaleString('en-US')}
              <span style={{ fontSize: '1rem', color: '#6b7280', marginLeft: '10px' }}>
                NCHAIN
              </span>
            </div>
            <div
              style={{
                fontSize: '0.8rem',
                color: '#6b7280',
                marginTop: '10px',
                wordBreak: 'break-all'
              }}
            >
              Wallet: {address}
            </div>
          </div>

          {/* Transfer card */}
          <div
            className="card"
            style={{
              background: '#1a1f2e',
              borderRadius: '12px',
              padding: '20px',
              border: '1px solid #374151',
              color: 'white'
            }}
          >
            <h3 style={{ margin: '0 0 20px 0', fontSize: '1.2rem' }}>Transfer NCHAIN</h3>

            <form onSubmit={handleTransfer}>
              <div style={{ marginBottom: '15px' }}>
                <label
                  style={{
                    display: 'block',
                    marginBottom: '5px',
                    fontSize: '0.9rem',
                    color: '#9ca3af'
                  }}
                >
                  Recipient address (Hedera 0.0.xxxx)
                </label>
                <input
                  type="text"
                  value={recipientAddress}
                  onChange={(e) => setRecipientAddress(e.target.value)}
                  placeholder="e.g. 0.0.123456"
                  required
                  style={{
                    width: '100%',
                    padding: '10px',
                    borderRadius: '6px',
                    border: '1px solid #374151',
                    background: '#111827',
                    color: 'white'
                  }}
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label
                  style={{
                    display: 'block',
                    marginBottom: '5px',
                    fontSize: '0.9rem',
                    color: '#9ca3af'
                  }}
                >
                  Amount
                </label>
                <input
                  type="number"
                  step="0.000001"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  placeholder="0.00"
                  required
                  min="0"
                  max={nchainBalance}
                  style={{
                    width: '100%',
                    padding: '10px',
                    borderRadius: '6px',
                    border: '1px solid #374151',
                    background: '#111827',
                    color: 'white'
                  }}
                />
                <div style={{ marginTop: '4px', fontSize: '0.8rem', color: '#6b7280' }}>
                  Available: {nchainBalance.toLocaleString('en-US')} NCHAIN
                </div>
              </div>

              <button
                type="submit"
                disabled={loading || !amount || !recipientAddress}
                style={{
                  width: '100%',
                  padding: '12px',
                  borderRadius: '6px',
                  border: 'none',
                  background: loading ? '#4b5563' : '#2563eb',
                  color: 'white',
                  cursor: loading ? 'not-allowed' : 'pointer',
                  fontWeight: 'bold'
                }}
              >
                {loading ? 'Processing...' : 'Send NCHAIN'}
              </button>
            </form>

            {message.text && (
              <div
                style={{
                  marginTop: '15px',
                  padding: '10px',
                  borderRadius: '6px',
                  fontSize: '0.9rem',
                  background:
                    message.type === 'success'
                      ? 'rgba(16, 185, 129, 0.2)'
                      : 'rgba(239, 68, 68, 0.2)',
                  color: message.type === 'success' ? '#34d399' : '#f87171'
                }}
              >
                {message.text}
              </div>
            )}
          </div>
        </>
      ) : (
        <div
          style={{
            textAlign: 'center',
            color: '#9ca3af',
            marginTop: '40px',
            fontSize: '0.95rem'
          }}
        >
          Connect your wallet to view your NCHAIN balance and send tokens.
        </div>
      )}

      {/* Quick links */}
      <div
        style={{
          marginTop: '30px',
          display: 'flex',
          gap: '10px',
          justifyContent: 'center',
          fontSize: '0.9rem'
        }}
      >
        <a href="https://nutrichain.org" style={{ color: '#60a5fa', textDecoration: 'none' }}>
          Dashboard
        </a>
        <span style={{ color: '#4b5563' }}>|</span>
        <a
          href="https://nutrichain.org/stake"
          style={{ color: '#60a5fa', textDecoration: 'none' }}
        >
          Staking
        </a>
        <span style={{ color: '#4b5563' }}>|</span>
        <a
          href="https://nutrichain.org/governance"
          style={{ color: '#60a5fa', textDecoration: 'none' }}
        >
          Governance
        </a>
      </div>
    </div>
  )
}

