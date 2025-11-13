import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { currency } from '../utils/format'

export default function Summary(){
  const [view, setView] = useState([])
  const [func, setFunc] = useState([])
  useEffect(()=>{
    axios.get('http://127.0.0.1:8000/summary/ngo').then(r=>{
      setView(r.data.view || [])
      setFunc(r.data.func || [])
    })
  },[])

  return (
    <div>
      <h2>NGO Summary View</h2>
      <div className="table-wrap">
      <table style={{marginBottom:16}}>
        <thead><tr><th>NGO_ID</th><th>NGO_Name</th><th>Total Donations</th><th>Donation Count</th></tr></thead>
        <tbody>
          {view.map(r=> (
            <tr key={r.NGO_ID}>
              <td>{r.NGO_ID}</td>
              <td>{r.NGO_Name}</td>
              <td>{currency(r.total_donations)}</td>
              <td>{r.donor_count}</td>
            </tr>
          ))}
        </tbody>
      </table>
      </div>

      <h3>Function: get_ngos_total_donations()</h3>
      <div className="table-wrap">
      <table>
        <thead><tr><th>NGO_ID</th><th>NGO_Name</th><th>Total Donations (func)</th></tr></thead>
        <tbody>
          {func.map(r=> (
            <tr key={r.NGO_ID}>
              <td>{r.NGO_ID}</td>
              <td>{r.NGO_Name}</td>
              <td>{currency(r.total_donations)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      </div>
    </div>
  )
}
