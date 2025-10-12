import React from 'react'
import { createRoot } from 'react-dom/client'

const PROM_URL = (import.meta as any).env?.VITE_PROM_URL || '/prometheus'

async function promQuery(expr: string): Promise<any> {
  const url = `${PROM_URL}/api/v1/query?query=${encodeURIComponent(expr)}`
  const res = await fetch(url)
  if (!res.ok) throw new Error(`Prometheus error ${res.status}`)
  return res.json()
}

function App() {
  const [tab, setTab] = React.useState<'health'|'ops'|'control'|'charts'>('health')
  const [klineRate, setKlineRate] = React.useState<string>('-')
  const [storageUp, setStorageUp] = React.useState<string>('?')
  React.useEffect(() => {
    let stop = false
    async function tick() {
      try {
        const r1 = await promQuery('rate(binance_data_storage_kline_events_saved_total[5m])')
        const v1 = r1?.data?.result?.[0]?.value?.[1]
        if (!stop) setKlineRate(v1 ? Number(v1).toFixed(2) + ' ev/s' : '0')
      } catch {}
      try {
        const r2 = await promQuery('up{job="binance-data-storage-testnet"}')
        const v2 = r2?.data?.result?.[0]?.value?.[1]
        if (!stop) setStorageUp(v2 === '1' ? 'UP' : 'DOWN')
      } catch {}
    }
    tick()
    const id = setInterval(tick, 5000)
    return () => { stop = true; clearInterval(id) }
  }, [])
  return (
    <div style={{height:'100%', display:'flex', flexDirection:'column'}}>
      <div className="topbar">
        <div className="glow" style={{fontWeight:700}}>Matrix UI Portal</div>
        <div className={`tab ${tab==='health'?'active':''}`} onClick={()=>setTab('health')}>System Health</div>
        <div className={`tab ${tab==='ops'?'active':''}`} onClick={()=>setTab('ops')}>Operations</div>
        <div className={`tab ${tab==='control'?'active':''}`} onClick={()=>setTab('control')}>Control Board</div>
        <div className={`tab ${tab==='charts'?'active':''}`} onClick={()=>setTab('charts')}>Live Charts</div>
      </div>
      <main style={{flex:1}}>
        {tab==='health' && (
          <section className="card">
            <h2 className="glow">System Health Dashboard</h2>
            <p>Storage status: <b>{storageUp}</b></p>
            <p>Kline saves rate (5m): <b>{klineRate}</b></p>
            <small>Configured Prometheus URL: {PROM_URL}</small>
          </section>
        )}
        {tab==='ops' && <section className="card"><h2 className="glow">System Operational Dashboard</h2><p>Stub: throughput, latency, Kafka lag, job status.</p></section>}
        {tab==='control' && <section className="card"><h2 className="glow">Control Board</h2><p>Stub: list strategies, enable/disable, create/edit forms.</p></section>}
        {tab==='charts' && <section className="card"><h2 className="glow">Live Chart Board</h2><p>Stub: candlesticks + MACD overlays per strategy.</p></section>}
      </main>
    </div>
  )
}

const root = createRoot(document.getElementById('root')!)
root.render(<App />)


