import React, { useEffect, useState } from 'react'
import axios from 'axios'

export default function Analytics(){
  const [kpis, setKpis] = useState([])
  const [topSponsors, setTopSponsors] = useState([])
  const [monthly, setMonthly] = useState([])

  useEffect(()=>{
    axios.get('http://127.0.0.1:8000/analytics/kpis').then(r=> setKpis(r.data || []))
    axios.get('http://127.0.0.1:8000/analytics/top_sponsors').then(r=> setTopSponsors(r.data || []))
    axios.get('http://127.0.0.1:8000/queries/aggregate').then(r=> setMonthly(r.data || []))
  },[])

  const k = (kpis[0] || {})

  return (
    <div>
      <h2>Analytics / KPI Dashboard</h2>

      <div style={{display:'flex', gap:12, marginBottom:12}}>
        <div className="card" style={{padding:12}}>
          <div className="muted">Total Donations</div>
          <div style={{fontSize:20, fontWeight:600}}>{k.total_donations || 0}</div>
        </div>
        <div className="card" style={{padding:12}}>
          <div className="muted">Total Donors</div>
          <div style={{fontSize:20, fontWeight:600}}>{k.total_donors || 0}</div>
        </div>
        <div className="card" style={{padding:12}}>
          <div className="muted">Total Events</div>
          <div style={{fontSize:20, fontWeight:600}}>{k.total_events || 0}</div>
        </div>
        <div className="card" style={{padding:12}}>
          <div className="muted">Total Sponsors</div>
          <div style={{fontSize:20, fontWeight:600}}>{k.total_sponsors || 0}</div>
        </div>
      </div>

      <h3>Top Sponsors</h3>
      <div className="table-wrap">
        <table>
          <thead><tr><th>ID</th><th>Name</th><th>Total Sponsored</th></tr></thead>
          <tbody>
            {topSponsors.map(s=> (
              <tr key={s.Sponsor_ID}>
                <td>{s.Sponsor_ID}</td>
                <td>{s.sponsor_name}</td>
                <td>{s.total_sponsored}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <h3 style={{marginTop:18}}>Monthly Donations (sample)</h3>
      <div className="table-wrap">
        <table>
          <thead><tr><th>Month</th><th>NGO_ID</th><th>Total Amount</th><th>Count</th></tr></thead>
          <tbody>
            {monthly.map(m=> (
              <tr key={m.year_month + '-' + m.NGO_ID}>
                <td>{m.year_month}</td>
                <td>{m.NGO_ID}</td>
                <td>{m.total_amount}</td>
                <td>{m.donation_count}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
