import React, { useEffect, useState } from 'react'
import axios from 'axios'

export default function Events(){
  const [rows, setRows] = useState([])
  const [form, setForm] = useState({
    event_type:'', start_date:'', end_date:'', location:'', ngo_id:'', venue_id:'', vendors_json:'[]'
  })
  const [busy, setBusy] = useState(false)

  const load = () => {
    axios.get('http://127.0.0.1:8000/events').then(r=> setRows(r.data))
  }
  useEffect(()=>{ load() },[])

  const create = async (e) => {
    e.preventDefault()
    setBusy(true)
    try{
      const payload = {
        event_type: form.event_type,
        start_date: form.start_date,
        end_date: form.end_date,
        location: form.location,
        ngo_id: Number(form.ngo_id),
        venue_id: form.venue_id ? Number(form.venue_id) : null,
        vendors_json: form.vendors_json
      }
      await axios.post('http://127.0.0.1:8000/events', payload)
      setForm({event_type:'', start_date:'', end_date:'', location:'', ngo_id:'', venue_id:'', vendors_json:'[]'})
      load()
    }catch(e){
      alert('Create failed: ' + (e.response?.data?.detail || e))
    }finally{
      setBusy(false)
    }
  }

  const set = (k) => (ev)=> setForm({...form, [k]: ev.target.value})

  return (
    <div>
      <h2>Events</h2>
  <form onSubmit={create} style={{display:'grid', gridTemplateColumns:'repeat(3, 1fr)', gap:8, marginBottom:12}}>
        <input placeholder="Event type" value={form.event_type} onChange={set('event_type')} required />
        <input type="date" placeholder="Start date" value={form.start_date} onChange={set('start_date')} required />
        <input type="date" placeholder="End date" value={form.end_date} onChange={set('end_date')} required />
        <input placeholder="Location" value={form.location} onChange={set('location')} required />
        <input placeholder="NGO ID" value={form.ngo_id} onChange={set('ngo_id')} required />
        <input placeholder="Venue ID (optional)" value={form.venue_id} onChange={set('venue_id')} />
        <input placeholder='Vendors JSON (e.g., [{"Vendor_ID":1,"Cost":5000}])' value={form.vendors_json} onChange={set('vendors_json')} />
        <button type="submit" disabled={busy} style={{gridColumn:'span 3'}}>Create event</button>
      </form>

      <div className="table-wrap">
      <table>
  <thead><tr><th>ID</th><th>Type</th><th>Location</th><th>Venue</th><th>Venue Status</th><th>Sponsor</th><th>Sponsor POC</th><th>Sponsored Amount</th><th>Sponsors</th></tr></thead>
        <tbody>
          {rows.map(r=> (
            <tr key={r.Event_ID}>
              <td>{r.Event_ID}</td>
              <td>{r.Event_Type}</td>
              <td>{r.Location}</td>
              <td>{r.Venue_ID}</td>
              <td>{r.venue_status}</td>
              <td>{r.sponsor_name || '-'}</td>
              <td>{r.sponsor_person_name || '-'}</td>
              <td>{r.sponsored_amount != null ? r.sponsored_amount : '-'}</td>
              <td style={{whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis', maxWidth:240}}>{r.sponsors_list || '-'}</td>
            </tr>
          ))}
        </tbody>
      </table>
      </div>
    </div>
  )
}
