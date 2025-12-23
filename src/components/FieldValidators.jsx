import React, { useState } from 'react'

const Icon = {
  Shield: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
      <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
      <path d="M9 12l2 2 4-4" />
    </svg>
  ),
  Pin: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
      <path d="M21 10c0 5.523-9 12-9 12S3 15.523 3 10a9 9 0 1118 0z" />
      <circle cx="12" cy="10" r="3" />
    </svg>
  ),
  Calendar: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
      <rect x="3" y="4" width="18" height="18" rx="2" />
      <path d="M16 2v4M8 2v4M3 10h18" />
    </svg>
  ),
  Play: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="currentColor" {...props}>
      <path d="M8 5v14l11-7z" />
    </svg>
  ),
  External: (props) => (
    <svg viewBox="0 0 24 24" width="1em" height="1em" fill="none" stroke="currentColor" strokeWidth="2" {...props}>
      <path d="M18 13v6a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" />
      <path d="M15 3h6v6" />
      <path d="M10 14L21 3" />
    </svg>
  ),
}

const validators = [
  {
    id: 1,
    name: "Fatou Diop",
    role: "Coordinatrice Régionale",
    location: "Dakar, Sénégal",
    status: "Actif",
    image: "/logo-nutrichain.png",
    videoThumbnail: "/logo-nutrichain.png",
    lastAction: "Distribution 1200 repas - 15/12/2025",
    videoLink: "https://youtube.com/"
  },
  {
    id: 2,
    name: "Jean Kouassi",
    role: "Superviseur Logistique",
    location: "Abidjan, Côte d'Ivoire",
    status: "En mission",
    image: "/logo-nutrichain.png",
    videoThumbnail: "/logo-nutrichain.png",
    lastAction: "Audit Entrepôt - 20/12/2025",
    videoLink: "https://youtube.com/"
  },
  {
    id: 3,
    name: "Amina Traoré",
    role: "Responsable Qualité",
    location: "Bamako, Mali",
    status: "Actif",
    image: "/logo-nutrichain.png",
    videoThumbnail: "/logo-nutrichain.png",
    lastAction: "Contrôle Sanitaire - 18/12/2025",
    videoLink: "https://youtube.com/"
  }
]

export default function FieldValidators() {
  const [selectedVideo, setSelectedVideo] = useState(null)

  return (
    <div className="p-6 bg-slate-950 min-h-screen text-white font-sans">
      <div className="mb-10 text-center">
        <h2 className="text-3xl font-bold bg-gradient-to-r from-emerald-400 to-cyan-500 bg-clip-text text-transparent mb-2">
          Nos Héros du Terrain
        </h2>
        <p className="text-slate-400 max-w-2xl mx-auto">
          La confiance n'est pas une option, c'est une preuve. Découvrez les agents qui valident chaque distribution NutriChain en temps réel.
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        <Stat icon={<Icon.Shield />} value="12" label="Validateurs Certifiés" color="emerald" />
        <Stat icon={<Icon.Pin />} value="5 Pays" label="Zones Couvertes" color="blue" />
        <Stat icon={<Icon.Calendar />} value="24h" label="Délai moyen de preuve" color="purple" />
      </div>

      {/* Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {validators.map(v => (
          <div key={v.id} className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden hover:border-emerald-500/30 transition">
            <div className="relative h-48">
              <img src={v.image} alt={v.name} className="w-full h-full object-cover" />
              <span className={`absolute top-3 right-3 px-3 py-1 text-xs rounded-full ${
                v.status === "Actif"
                  ? "bg-emerald-500/20 text-emerald-300"
                  : "bg-amber-500/20 text-amber-300"
              }`}>
                {v.status}
              </span>
            </div>

            <div className="p-5">
              <h3 className="font-bold">{v.name}</h3>
              <p className="text-sm text-emerald-400">{v.role}</p>

              <div className="mt-4 space-y-2 text-sm text-slate-300">
                <div className="flex items-center gap-2"><Icon.Pin /> {v.location}</div>
                <div className="flex items-center gap-2"><Icon.Calendar /> {v.lastAction}</div>
              </div>

              <a
                href={v.videoLink}
                target="_blank"
                rel="noreferrer"
                className="mt-4 flex items-center justify-center gap-1 text-xs text-slate-400 hover:text-white"
              >
                Voir le rapport <Icon.External />
              </a>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
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
  )
}

