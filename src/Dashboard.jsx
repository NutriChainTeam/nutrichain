function Dashboard() {
  return (
    <div className="flex min-h-screen">
      <aside className="hidden lg:flex w-64 flex-col fixed inset-y-0 bg-slate-900 border-r border-slate-800 z-40">
        {/* ... contenu du template ... */}
      </aside>
      <main className="flex-1 lg:ml-64 p-4 lg:p-8 pt-20 lg:pt-8 bg-slate-950 flex flex-col">
        {/* ... contenu du template ... */}
      </main>
    </div>
  );
}

export default Dashboard;
