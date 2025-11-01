import React, {useEffect, useState} from 'react'
import axios from 'axios'

export default function Donations(){
  const [rows, setRows] = useState([])
  useEffect(()=>{
    axios.get('http://127.0.0.1:8000/donations')
      .then(r=> setRows(r.data))
      .catch(e=> console.error(e))
  },[])
  return (
    <div>
      <h2>Donations</h2>
      <div className="table-wrap">
      <table>
        <thead><tr><th>ID</th><th>Receipt</th><th>Date</th><th>Amount</th><th>Type</th></tr></thead>
        <tbody>
          {rows.map(r=> (
            <tr key={r.Donation_ID} style={{borderTop:'1px solid #ddd'}}>
              <td>{r.Donation_ID}</td>
              <td>{r.Receipt_Number}</td>
              <td>{r.Donation_date}</td>
              <td>{r.Amount}</td>
              <td>{r.Type}</td>
            </tr>
          ))}
        </tbody>
      </table>
      </div>
    </div>
  )
}
