import React, { useEffect, useState } from 'react'
import axios from 'axios'

export default function Audit(){
  const [rows, setRows] = useState([])
  useEffect(()=>{
    // Use demo endpoint which falls back to synthesized entries when audit table is empty
    axios.get('http://127.0.0.1:8000/audit/demo').then(r=> setRows(r.data))
  },[])

  return (
    <div>
      <h2>Donation Audit Log (latest 100)</h2>
      <div className="table-wrap">
      <table>
        <thead><tr><th>ID</th><th>Donation</th><th>Changed At</th><th>Action</th><th>Old</th><th>New</th><th>Note</th></tr></thead>
        <tbody>
          {rows.map(r=> (
            <tr key={r.audit_id}>
              <td>{r.audit_id}</td>
              <td>{r.donation_id}</td>
              <td>{r.changed_at}</td>
              <td>{r.action}</td>
              <td>{r.old_amount}</td>
              <td>{r.new_amount}</td>
              <td>{r.note}</td>
            </tr>
          ))}
        </tbody>
      </table>
      </div>
    </div>
  )
}
