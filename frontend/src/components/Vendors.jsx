import React, { useEffect, useState } from 'react'
import axios from 'axios'

export default function Vendors(){
  const [rows, setRows] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  const load = () => {
    setLoading(true)
    axios.get('http://127.0.0.1:8000/vendors')
      .then(r=> setRows(r.data))
      .catch(e=> setError(String(e)))
      .finally(()=> setLoading(false))
  }

  useEffect(()=>{ load() },[])

  const del = async (id) => {
    if(!confirm('Delete vendor #' + id + '?')) return
    try{
      await axios.delete('http://127.0.0.1:8000/vendor/' + id)
      load()
    }catch(e){
      alert('Delete failed: ' + e)
    }
  }

  return (
    <div>
      <h2>Vendors</h2>
      {loading && <div>Loading…</div>}
      {error && <div style={{color:'red'}}>{error}</div>}
      <div className="table-wrap">
      <table>
        <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Service</th><th>Actions</th></tr></thead>
        <tbody>
          {rows.map(r=> (
            <tr key={r.Vendor_ID}>
              <td>{r.Vendor_ID}</td>
              <td>{r.Name}</td>
              <td>{r.Email}</td>
              <td>{r.Service_type}</td>
              <td><button onClick={()=>del(r.Vendor_ID)}>Delete</button></td>
            </tr>
          ))}
        </tbody>
      </table>
      </div>
    </div>
  )
}
