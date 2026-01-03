import { useState, useEffect } from 'react'
import { useAppKitAccount } from '@reown/appkit/react'
import { getNChainBalance, transferNChain } from './hederaUtils'
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

  console.log('NUTRICHAIN WALLET BUILD v3')

  // Styles pour les icônes sociales
  const socialLinkStyle = {
    color: '#9ca3af',
    transition: 'color 0.2s',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center'
  }

  return (
    <div
      style={{
        minHeight: '100vh',
        backgroundColor: '#020617',
        color: '#e5e7eb',
        display: 'flex',
        flexDirection: 'column'
      }}
    >
      <main
        style={{
          flex: 1,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '24px'
        }}
      >
        <div
          className="App"
          style={{
            width: '100%',
            maxWidth: '640px',
            background: '#020617',
            borderRadius: '16px',
            border: '1px solid #1f2937',
            padding: '24px 24px 32px 24px',
            boxShadow: '0 20px 50px rgba(15,23,42,0.8)'
          }}
        >
          {/* Header with NutriChain logo */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '16px',
              marginBottom: '24px'
            }}
          >
            <img
              src="/wallet/logo-nutrichain.png"
              alt="NutriChain logo"
              style={{
                width: '56px',
                height: '56px',
                borderRadius: '999px',
                border: '2px solid #22c55e',
                objectFit: 'cover'
              }}
            />
            <div>
              <h1 style={{ margin: 0, fontSize: '1.4rem', color: '#f9fafb' }}>
                NutriChain Wallet
              </h1>
              <p style={{ margin: 0, fontSize: '0.85rem', color: '#9ca3af' }}>
                Manage and transfer your NCHAIN tokens.
              </p>
            </div>
          </div>

          {/* Wallet connect button */}
          <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '24px' }}>
            <appkit-button />
          </div>

          {isConnected ? (
            <>
              {/* Balance card */}
              <div
                className="card"
                style={{
                  background: '#020617',
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
                    textTransform: 'uppercase',
                    letterSpacing: '0.08em'
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
                  background: '#020617',
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
      </main>

      <footer
        style={{
          textAlign: 'center',
          fontSize: '0.8rem',
          color: '#6b7280',
          padding: '8px 0 24px'
        }}
      >
        {/* Social Icons */}
        <div style={{ display: 'flex', gap: '24px', justifyContent: 'center', marginBottom: '16px' }}>
          {/* X / Twitter */}
          <a 
            href="https://x.com/nutrichain_" 
            target="_blank" 
            rel="noopener noreferrer"
            title="Follow us on X"
            style={socialLinkStyle}
            onMouseOver={(e) => e.currentTarget.style.color = '#fff'}
            onMouseOut={(e) => e.currentTarget.style.color = '#9ca3af'}
          >
            <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
            </svg>
          </a>

          {/* Discord */}
          <a 
            href="https://discord.gg/WYxT835A" 
            target="_blank" 
            rel="noopener noreferrer"
            title="Join our Discord"
            style={socialLinkStyle}
            onMouseOver={(e) => e.currentTarget.style.color = '#5865F2'}
            onMouseOut={(e) => e.currentTarget.style.color = '#9ca3af'}
          >
            <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
              <path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189z" />
            </svg>
          </a>

          {/* Telegram */}
          <a 
            href="https://t.me/NutriChainTeam" 
            target="_blank" 
            rel="noopener noreferrer"
            title="Join us on Telegram"
            style={socialLinkStyle}
            onMouseOver={(e) => e.currentTarget.style.color = '#229ED9'}
            onMouseOut={(e) => e.currentTarget.style.color = '#9ca3af'}
          >
            <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
              <path d="M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z" />
            </svg>
          </a>
        </div>
        
        {/* Copyright */}
        <div>© NutriChain – Each token = 1 meal.</div>
      </footer>
    </div>
  )
}
