import React, { useEffect, useState } from 'react'
import axios from 'axios'

export default function Events(){
  const [rows, setRows] = useState([])
  const [form, setForm] = useState({
    event_type:'', start_date:'', end_date:'', location:'', ngo_id:'', venue_id:'', vendors_json:'[]'
  })
  const [busy, setBusy] = useState(false)
  const [sponsorsRec, setSponsorsRec] = useState([])
  const [vendorsRec, setVendorsRec] = useState([])
  const [recBusy, setRecBusy] = useState(false)
  const [selectedEventId, setSelectedEventId] = useState(null)

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

  // Fetch recommendations for a given text (either passed or the current form.event_type)
  const fetchRecommendations = async (text) => {
    const queryText = (text || form.event_type || '').trim()
    if(!queryText || queryText.length < 2) {
      alert('Enter an event type or short description to get recommendations')
      return
    }
    setRecBusy(true)
    try{
      const q = encodeURIComponent(queryText)
      const [s, v] = await Promise.all([
        axios.get(`http://127.0.0.1:8000/sponsors/recommend?q=${q}`),
        axios.get(`http://127.0.0.1:8000/vendors/recommend?q=${q}`)
      ])
      setSponsorsRec(s.data || [])
      setVendorsRec(v.data || [])
    }catch(err){
      // show a single friendly alert for either failure
      alert('Failed to load recommendations: ' + (err.response?.data?.detail || err.message || err))
    }finally{
      setRecBusy(false)
    }
  }

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
        <div style={{gridColumn:'span 3', display:'flex', gap:8, alignItems:'center'}}>
          <div style={{color:'#666', fontSize:13}}>{recBusy ? 'Fetching recommendations…' : 'Click an event in the table to fetch sponsor & vendor recommendations'}</div>
        </div>
      </form>

      {/* Recommendations */}
      <div style={{display:'flex', gap:20, marginBottom:12}}>
        <div style={{flex:1}}>
          <h3>Sponsor recommendations</h3>
          {sponsorsRec.length === 0 ? <div style={{color:'#666'}}>No sponsor recommendations yet.</div> : (
            <ul>
              {sponsorsRec.map(s => (
                <li key={s.Sponsor_ID} style={{marginBottom:6}}>
                  <strong>{s.Name}</strong> <span style={{color:'#666'}}>({s.Focus_area})</span>
                  {s.score != null ? <span style={{marginLeft:8, color:'#0a6'}}>Score: {s.score}</span> : null}
                  <div style={{fontSize:13, color:'#444'}}>{s.interests}</div>
                </li>
              ))}
            </ul>
          )}
        </div>

        <div style={{flex:1}}>
          <h3>Vendor recommendations</h3>
          {vendorsRec.length === 0 ? <div style={{color:'#666'}}>No vendor recommendations yet.</div> : (
            <ul style={{listStyleType:'disc', paddingLeft:18}}>
              {vendorsRec.map(v => (
                <li key={v.Vendor_ID} style={{marginBottom:8}}>
                  <div>
                    <strong>{v.Name}</strong>
                    <span style={{color:'#666', marginLeft:6}}>({v.Service_type})</span>
                    {v.score != null ? <span style={{marginLeft:10, color:'#0a6'}}>Score: {v.score}</span> : null}
                  </div>
                  {/* subtext similar to sponsor interests - show service type or extra info if available */}
                  <div style={{fontSize:13, color:'#444'}}>{v.Service_type}</div>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>

      <div className="table-wrap">
      <table>
        <thead><tr><th>ID</th><th>Type</th><th>Location</th><th>NGO</th><th>NGO Type</th><th>Venue</th><th>Venue Status</th></tr></thead>
        <tbody>
          {rows.map(r=> (
            <tr
              key={r.Event_ID}
              onClick={() => { setSelectedEventId(r.Event_ID); fetchRecommendations(r.Event_Type) }}
              style={{cursor:'pointer', background: selectedEventId === r.Event_ID ? '#f0fbf9' : 'transparent'}}
              title="Click to fetch recommendations for this event"
            >
              <td>{r.Event_ID}</td>
              <td>{r.Event_Type}</td>
              <td>{r.Location}</td>
              <td>{r.NGO_Name || 'N/A'}</td>
              <td>{r.ngo_type || 'N/A'}</td>
              <td>{r.Venue_ID}</td>
              <td>{r.venue_status}</td>
            </tr>
          ))}
        </tbody>
      </table>
      </div>
    </div>
  )
}
