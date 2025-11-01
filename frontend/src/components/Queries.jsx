import React, { useEffect, useState } from 'react'
import axios from 'axios'

export default function Queries(){
  const [tab, setTab] = useState('nested')
  const [rows, setRows] = useState([])

  useEffect(()=>{
    const url = {
      nested: 'http://127.0.0.1:8000/queries/nested',
      join: 'http://127.0.0.1:8000/queries/join',
      aggregate: 'http://127.0.0.1:8000/queries/aggregate',
    }[tab]
    axios.get(url).then(r=> setRows(r.data))
  },[tab])

  const columns = {
    nested: ['Donor_ID','Name','total_donated'],
    join: ['Event_ID','Event_Type','vendor_name','Cost'],
    aggregate: ['year_month','NGO_ID','total_amount','donation_count']
  }[tab]

  return (
    <div>
      <h2>Queries</h2>
      <div style={{display:'flex', gap:8, margin:'8px 0'}} className="nav">
        <button className={tab==='nested' ? 'active' : ''} onClick={()=>setTab('nested')}>Nested</button>
        <button className={tab==='join' ? 'active' : ''} onClick={()=>setTab('join')}>Join</button>
        <button className={tab==='aggregate' ? 'active' : ''} onClick={()=>setTab('aggregate')}>Aggregate</button>
      </div>

      <div className="table-wrap">
      <table>
        <thead>
          <tr>
            {columns.map(c=> <th key={c}>{c}</th>)}
          </tr>
        </thead>
        <tbody>
          {rows.map((r, idx)=> (
            <tr key={idx}>
              {columns.map(c=> <td key={c}>{r[c]}</td>)}
            </tr>
          ))}
        </tbody>
      </table>
      </div>
    </div>
  )
}
