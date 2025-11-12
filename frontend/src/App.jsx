import React, { useState } from 'react'
import Donations from './components/Donations'
import Vendors from './components/Vendors'
import Events from './components/Events'
import NGOs from './components/NGOs'
import Audit from './components/Audit'
import Queries from './components/Queries'
import Analytics from './components/Analytics'

export default function App(){
  const [page, setPage] = useState('ngos')

  const renderPage = () => {
      switch(page){
      case 'ngos': return <NGOs />
      case 'vendors': return <Vendors />
      case 'events': return <Events />
      case 'audit': return <Audit />
      case 'queries': return <Queries />
      case 'analytics': return <Analytics />
      default: return <Donations />
    }
  }

  return (
    <div className="app-root">
      <div className="page-title">
        <h1>NGO Management</h1>
        <div className="small">Light demo • MySQL + FastAPI</div>
      </div>

      <div className="nav controls" style={{margin:'12px 0'}}>
        <button className={page==='ngos'? 'active':''} onClick={()=>setPage('ngos')}>NGOs</button>
        <button className={page==='donations'? 'active':''} onClick={()=>setPage('donations')}>Donations</button>
        <button className={page==='vendors'? 'active':''} onClick={()=>setPage('vendors')}>Vendors</button>
        <button className={page==='events'? 'active':''} onClick={()=>setPage('events')}>Events</button>
  <button className={page==='analytics'? 'active':''} onClick={()=>setPage('analytics')}>Analytics</button>
  <button className={page==='audit'? 'active':''} onClick={()=>setPage('audit')}>Audit</button>
  <button className={page==='queries'? 'active':''} onClick={()=>setPage('queries')}>Queries</button>
      </div>

      {renderPage()}
    </div>
  )
}
