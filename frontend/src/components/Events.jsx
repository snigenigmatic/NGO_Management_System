import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { currency } from '../utils/format'

export default function Events(){
  const [rows, setRows] = useState([])
  const [form, setForm] = useState({
    event_type:'', start_date:'', end_date:'', location:'', ngo_id:'', venue_id:'', vendor_id:'', vendor_cost:''
  })
  const [busy, setBusy] = useState(false)
  const [sponsorsRec, setSponsorsRec] = useState([])
  const [vendorsRec, setVendorsRec] = useState([])
  const [recBusy, setRecBusy] = useState(false)
  const [selectedEventId, setSelectedEventId] = useState(null)
  const [recMode, setRecMode] = useState('both') // Track what type of recommendations are being shown

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
        vendor_id: form.vendor_id ? Number(form.vendor_id) : null,
        vendor_cost: form.vendor_cost ? Number(form.vendor_cost) : null
      }
      await axios.post('http://127.0.0.1:8000/events', payload)
      setForm({event_type:'', start_date:'', end_date:'', location:'', ngo_id:'', venue_id:'', vendor_id:'', vendor_cost:''})
      load()
    }catch(e){
      alert('Create failed: ' + (e.response?.data?.detail || e))
    }finally{
      setBusy(false)
    }
  }

  const set = (k) => (ev)=> setForm({...form, [k]: ev.target.value})

  // Fetch recommendations for a given text (either passed or the current form.event_type)
  // Now also accepts a 'mode' parameter to fetch only 'sponsor', 'vendor', or 'both'
  const fetchRecommendations = async (text, mode = 'both') => {
    const queryText = (text || form.event_type || '').trim()
    if(!queryText || queryText.length < 2) {
      alert('Enter an event type or short description to get recommendations')
      return
    }
    setRecBusy(true)
    setRecMode(mode) // Track the mode for display purposes
    try{
      const q = encodeURIComponent(queryText)
      const promises = []
      
      if (mode === 'both' || mode === 'sponsor') {
        promises.push(axios.get(`http://127.0.0.1:8000/sponsors/recommend?q=${q}`))
      } else {
        promises.push(Promise.resolve({ data: [] }))
      }
      
      if (mode === 'both' || mode === 'vendor') {
        promises.push(axios.get(`http://127.0.0.1:8000/vendors/recommend?q=${q}`))
      } else {
        promises.push(Promise.resolve({ data: [] }))
      }
      
      const [s, v] = await Promise.all(promises)
      
      if (mode === 'both' || mode === 'sponsor') {
        setSponsorsRec(s.data || [])
      }
      if (mode === 'both' || mode === 'vendor') {
        setVendorsRec(v.data || [])
      }
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
        <input placeholder="Vendor ID (optional)" value={form.vendor_id} onChange={set('vendor_id')} />
        <input placeholder="Vendor Cost (optional)" value={form.vendor_cost} onChange={set('vendor_cost')} type="number" step="0.01" />
  <button type="submit" disabled={busy} style={{gridColumn:'span 3'}}>Create event</button>
        <div style={{gridColumn:'span 3', display:'flex', gap:8, alignItems:'center'}}>
          <div style={{color:'#666', fontSize:13}}>{recBusy ? 'Fetching recommendations…' : 'Use the Action button in the table to get recommendations based on what\'s missing (vendor/sponsor/both)'}</div>
        </div>
      </form>

      {/* Recommendations */}
      <div style={{display:'flex', gap:20, marginBottom:12}}>
        {/* Show sponsor recommendations only if mode is 'sponsor' or 'both' */}
        {(recMode === 'sponsor' || recMode === 'both') && (
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
        )}

        {/* Show vendor recommendations only if mode is 'vendor' or 'both' */}
        {(recMode === 'vendor' || recMode === 'both') && (
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
        )}
      </div>

      <div className="table-wrap">
      <table>
  <thead><tr><th>ID</th><th>Type</th><th>Location</th><th>NGO</th><th>NGO Type</th><th>Venue</th><th>Vendor</th><th>Sponsor</th><th>Total Cost</th><th>Action</th></tr></thead>
        <tbody>
          {rows.map(r=> {
            const hasVendor = r.vendor_names != null
            const hasSponsor = r.sponsor_name != null
            const hasBoth = hasVendor && hasSponsor
            const hasNeither = !hasVendor && !hasSponsor
            
            // Determine button text and mode
            let buttonText = ''
            let recMode = 'both'
            let isClickable = true
            
            if (hasBoth) {
              buttonText = 'Has Both ✓'
              isClickable = false
            } else if (hasVendor && !hasSponsor) {
              buttonText = 'Get Recommendations'
              recMode = 'sponsor'
            } else if (!hasVendor && hasSponsor) {
              buttonText = 'Get Recommendations'
              recMode = 'vendor'
            } else {
              buttonText = 'Get Recommendations'
              recMode = 'both'
            }
            
            return (
              <tr key={r.Event_ID}>
                <td>{r.Event_ID}</td>
                <td>{r.Event_Type}</td>
                <td>{r.Location}</td>
                <td>{r.NGO_Name || 'N/A'}</td>
                <td>{r.ngo_type || 'N/A'}</td>
                <td>{r.Venue_ID}</td>
                <td>{r.vendor_names || 'N/A'}</td>
                <td>{r.sponsor_name || 'N/A'}</td>
                <td>{r.total_cost != null ? currency(r.total_cost) : 'N/A'}</td>
                <td>
                  <button
                    onClick={() => { 
                      setSelectedEventId(r.Event_ID)
                      fetchRecommendations(r.Event_Type, recMode)
                    }}
                    disabled={!isClickable || recBusy}
                    style={{
                      cursor: isClickable ? 'pointer' : 'not-allowed',
                      opacity: isClickable ? 1 : 0.5,
                      fontSize: '12px',
                      padding: '4px 8px'
                    }}
                  >
                    {buttonText}
                  </button>
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
      </div>
    </div>
  )
}
