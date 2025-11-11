import React, { useEffect, useState } from 'react'
import axios from 'axios'
import { Chart as ChartJS, ArcElement, CategoryScale, LinearScale, BarElement, LineElement, PointElement, Title, Tooltip, Legend } from 'chart.js'
import { Bar, Pie, Line } from 'react-chartjs-2'
import { currency } from '../utils/format'

// Register Chart.js components
ChartJS.register(ArcElement, CategoryScale, LinearScale, BarElement, LineElement, PointElement, Title, Tooltip, Legend)

export default function Analytics() {
  const [kpis, setKpis] = useState({})
  const [sponsors, setSponsors] = useState([])
  const [events, setEvents] = useState([])
  const [vendors, setVendors] = useState([])
  const [volunteers, setVolunteers] = useState([])
  const [donors, setDonors] = useState([])
  const [donationsByType, setDonationsByType] = useState([])
  const [activeTab, setActiveTab] = useState('dashboard')

  // currency() is imported from utils/format

  useEffect(() => {
    loadDashboard()
  }, [])

  const loadDashboard = () => {
    axios.get('http://127.0.0.1:8000/analytics/dashboard').then(r => {
      setKpis(r.data.kpis || {})
    })
  }

  const loadSponsors = () => {
    axios.get('http://127.0.0.1:8000/analytics/sponsors').then(r => setSponsors(r.data || []))
  }

  const loadEvents = () => {
    axios.get('http://127.0.0.1:8000/analytics/events').then(r => setEvents(r.data || []))
  }

  const loadVendors = () => {
    axios.get('http://127.0.0.1:8000/analytics/vendors').then(r => setVendors(r.data || []))
  }

  const loadVolunteers = () => {
    axios.get('http://127.0.0.1:8000/analytics/volunteers').then(r => setVolunteers(r.data || []))
  }

  const loadDonors = () => {
    axios.get('http://127.0.0.1:8000/analytics/donors').then(r => setDonors(r.data || []))
  }

  const loadDonationsByType = () => {
    axios.get('http://127.0.0.1:8000/analytics/donations/by-type').then(r => setDonationsByType(r.data || []))
  }

  const switchTab = (tab) => {
    setActiveTab(tab)
    if (tab === 'sponsors' && sponsors.length === 0) loadSponsors()
    if (tab === 'events' && events.length === 0) loadEvents()
    if (tab === 'vendors' && vendors.length === 0) loadVendors()
    if (tab === 'volunteers' && volunteers.length === 0) loadVolunteers()
    if (tab === 'donors' && donors.length === 0) loadDonors()
    if (tab === 'donations' && donationsByType.length === 0) loadDonationsByType()
  }

  return (
    <div>
      <h2>Analytics Dashboard</h2>

      {/* Tab navigation */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 16, borderBottom: '2px solid #ddd', paddingBottom: 8 }}>
        {['dashboard', 'sponsors', 'events', 'vendors', 'volunteers', 'donors', 'donations'].map(tab => (
          <button
            key={tab}
            onClick={() => switchTab(tab)}
            style={{
              padding: '8px 16px',
              background: activeTab === tab ? '#17a2b8' : '#f8f9fa',
              color: activeTab === tab ? '#fff' : '#333',
              border: 'none',
              borderRadius: 4,
              cursor: 'pointer',
              fontWeight: activeTab === tab ? 'bold' : 'normal'
            }}
          >
            {tab.charAt(0).toUpperCase() + tab.slice(1)}
          </button>
        ))}
      </div>

      {/* Dashboard KPIs */}
      {activeTab === 'dashboard' && (
        <div>
          <h3>Overall System KPIs</h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(150px, 1fr))', gap: 16, marginBottom: 20 }}>
            <div style={{ padding: 16, background: '#e7f3ff', borderRadius: 8 }}>
              <div style={{ fontSize: 28, fontWeight: 'bold', color: '#0056b3' }}>{kpis.total_ngos || 0}</div>
              <div style={{ color: '#666', fontSize: 14 }}>Total NGOs</div>
            </div>
            <div style={{ padding: 16, background: '#e7ffe7', borderRadius: 8 }}>
              <div style={{ fontSize: 28, fontWeight: 'bold', color: '#0a6' }}>{currency(kpis.total_donations || 0)}</div>
              <div style={{ color: '#666', fontSize: 14 }}>Total Donations</div>
            </div>
            <div style={{ padding: 16, background: '#fff3e0', borderRadius: 8 }}>
              <div style={{ fontSize: 28, fontWeight: 'bold', color: '#f57c00' }}>{kpis.total_donors || 0}</div>
              <div style={{ color: '#666', fontSize: 14 }}>Total Donors</div>
            </div>
            <div style={{ padding: 16, background: '#f3e5f5', borderRadius: 8 }}>
              <div style={{ fontSize: 28, fontWeight: 'bold', color: '#7b1fa2' }}>{kpis.total_volunteers || 0}</div>
              <div style={{ color: '#666', fontSize: 14 }}>Total Volunteers</div>
            </div>
            <div style={{ padding: 16, background: '#e0f7fa', borderRadius: 8 }}>
              <div style={{ fontSize: 28, fontWeight: 'bold', color: '#00796b' }}>{kpis.total_events || 0}</div>
              <div style={{ color: '#666', fontSize: 14 }}>Total Events</div>
            </div>
            <div style={{ padding: 16, background: '#fce4ec', borderRadius: 8 }}>
              <div style={{ fontSize: 28, fontWeight: 'bold', color: '#c2185b' }}>{kpis.total_sponsors || 0}</div>
              <div style={{ color: '#666', fontSize: 14 }}>Total Sponsors</div>
            </div>
            <div style={{ padding: 16, background: '#fff9c4', borderRadius: 8 }}>
              <div style={{ fontSize: 28, fontWeight: 'bold', color: '#f57f17' }}>{kpis.total_vendors || 0}</div>
              <div style={{ color: '#666', fontSize: 14 }}>Total Vendors</div>
            </div>
          </div>

          {/* Dashboard Charts */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, marginTop: 30 }}>
            <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
              <h4>System Overview</h4>
              <Pie
                data={{
                  labels: ['NGOs', 'Donors', 'Volunteers', 'Events', 'Sponsors', 'Vendors'],
                  datasets: [{
                    data: [
                      kpis.total_ngos || 0,
                      kpis.total_donors || 0,
                      kpis.total_volunteers || 0,
                      kpis.total_events || 0,
                      kpis.total_sponsors || 0,
                      kpis.total_vendors || 0
                    ],
                    backgroundColor: ['#0056b3', '#f57c00', '#7b1fa2', '#00796b', '#c2185b', '#f57f17']
                  }]
                }}
                options={{ responsive: true, maintainAspectRatio: true }}
              />
            </div>
            <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
              <h4>Key Metrics</h4>
              <Bar
                data={{
                  labels: ['NGOs', 'Donors', 'Volunteers', 'Events', 'Sponsors', 'Vendors'],
                  datasets: [{
                    label: 'Count',
                    data: [
                      kpis.total_ngos || 0,
                      kpis.total_donors || 0,
                      kpis.total_volunteers || 0,
                      kpis.total_events || 0,
                      kpis.total_sponsors || 0,
                      kpis.total_vendors || 0
                    ],
                    backgroundColor: ['#0056b3', '#f57c00', '#7b1fa2', '#00796b', '#c2185b', '#f57f17']
                  }]
                }}
                options={{
                  responsive: true,
                  plugins: { legend: { display: false } },
                  scales: { y: { beginAtZero: true } }
                }}
              />
            </div>
          </div>
        </div>
      )}

      {/* Sponsor Engagement */}
      {activeTab === 'sponsors' && (
        <div>
          <h3>Sponsor Engagement</h3>
          
          {/* Chart */}
          {sponsors.length > 0 && (
            <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)', marginBottom: 20, maxWidth: 800 }}>
              <h4>Events Sponsored by Sponsor</h4>
              <Bar
                data={{
                  labels: sponsors.map(s => s.sponsor_name),
                  datasets: [{
                    label: 'Events Sponsored',
                    data: sponsors.map(s => s.events_sponsored),
                    backgroundColor: '#c2185b'
                  }]
                }}
                options={{
                  responsive: true,
                  plugins: { legend: { display: false } },
                  scales: { y: { beginAtZero: true } }
                }}
              />
            </div>
          )}

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Sponsor Name</th>
                  <th>Focus Area</th>
                  <th>Events Sponsored</th>
                  <th>Interest Count</th>
                  <th>Interests</th>
                </tr>
              </thead>
              <tbody>
                {sponsors.map(s => (
                  <tr key={s.Sponsor_ID}>
                    <td>{s.Sponsor_ID}</td>
                    <td>{s.sponsor_name}</td>
                    <td>{s.Focus_area}</td>
                    <td>{s.events_sponsored}</td>
                    <td>{s.interest_count}</td>
                    <td style={{ fontSize: 13, color: '#555' }}>{s.interests}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Event ROI */}
      {activeTab === 'events' && (
        <div>
          <h3>Event ROI & Performance</h3>

          {/* Chart */}
          {events.length > 0 && (
            <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)', marginBottom: 20 }}>
              <h4>Event Net Impact (Donations - Costs)</h4>
              <Bar
                data={{
                  labels: events.map(e => e.Event_Type),
                  datasets: [{
                    label: 'Lifetime Value (₹)',
                    data: donors.slice(0, 10).map(d => d.lifetime_value),
                        data: events.map(e => e.donations_raised),
                      backgroundColor: '#0a6'
                    },
                    {
                      label: 'Total Cost (₹)',
                        data: events.map(e => e.total_cost),
                      backgroundColor: '#d32f2f'
                    },
                    {
                      label: 'Net Impact (₹)',
                        data: events.map(e => e.net_impact),
                      backgroundColor: '#00796b'
                    }
                  ]
                }}
                options={{
                  responsive: true,
                  scales: { y: { beginAtZero: true } }
                }}
              />
            </div>
          )}

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Event ID</th>
                  <th>Type</th>
                  <th>Location</th>
                  <th>Total Cost</th>
                  <th>Donations Raised</th>
                  <th>Net Impact</th>
                  <th>Volunteers</th>
                  <th>Volunteer Hours</th>
                </tr>
              </thead>
              <tbody>
                {events.map(e => (
                  <tr key={e.Event_ID}>
                    <td>{e.Event_ID}</td>
                    <td>{e.Event_Type}</td>
                    <td>{e.Location}</td>
                    <td>{currency(e.total_cost)}</td>
                    <td>{currency(e.donations_raised)}</td>
                    <td style={{ color: e.net_impact >= 0 ? '#0a6' : '#d32f2f', fontWeight: 'bold' }}>
                      {currency(e.net_impact)}
                    </td>
                    <td>{e.volunteer_count}</td>
                    <td>{e.total_volunteer_hours}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Vendor Performance */}
      {activeTab === 'vendors' && (
        <div>
          <h3>Vendor Performance</h3>

          {/* Chart */}
          {vendors.length > 0 && (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, marginBottom: 20 }}>
              <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
                <h4>Vendor Revenue</h4>
                <Bar
                  data={{
                    labels: vendors.map(v => v.vendor_name),
                    datasets: [{
                      label: 'Total Revenue (₹)',
                        data: vendors.map(v => v.total_revenue),
                      backgroundColor: '#f57f17'
                    }]
                  }}
                  options={{
                    responsive: true,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true } }
                  }}
                />
              </div>
              <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
                <h4>Events Served by Vendor</h4>
                <Bar
                  data={{
                    labels: vendors.map(v => v.vendor_name),
                    datasets: [{
                      label: 'Events Served',
                      data: vendors.map(v => v.events_served),
                      backgroundColor: '#00796b'
                    }]
                  }}
                  options={{
                    responsive: true,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true } }
                  }}
                />
              </div>
            </div>
          )}

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Vendor ID</th>
                  <th>Vendor Name</th>
                  <th>Service Type</th>
                  <th>Events Served</th>
                  <th>Total Revenue</th>
                  <th>Avg Cost/Event</th>
                  <th>First Contract</th>
                  <th>Latest Contract</th>
                </tr>
              </thead>
              <tbody>
                {vendors.map(v => (
                  <tr key={v.Vendor_ID}>
                    <td>{v.Vendor_ID}</td>
                    <td>{v.vendor_name}</td>
                    <td>{v.Service_type}</td>
                    <td>{v.events_served}</td>
                    <td>{currency(v.total_revenue)}</td>
                    <td>{currency(v.avg_cost_per_event)}</td>
                    <td>{v.first_contract}</td>
                    <td>{v.latest_contract}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Volunteer Impact */}
      {activeTab === 'volunteers' && (
        <div>
          <h3>Volunteer Impact</h3>

          {/* Chart */}
          {volunteers.length > 0 && (
            <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)', marginBottom: 20, maxWidth: 900 }}>
              <h4>Top Volunteers by Hours Contributed</h4>
              <Bar
                data={{
                  labels: volunteers.slice(0, 10).map(v => v.volunteer_name),
                  datasets: [{
                    label: 'Total Hours',
                    data: volunteers.slice(0, 10).map(v => v.total_hours),
                    backgroundColor: '#7b1fa2'
                  }]
                }}
                options={{
                  responsive: true,
                  plugins: { legend: { display: false } },
                  scales: { y: { beginAtZero: true } }
                }}
              />
            </div>
          )}

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Vol ID</th>
                  <th>Volunteer Name</th>
                  <th>Skills</th>
                  <th>Events Participated</th>
                  <th>Total Hours</th>
                  <th>Avg Hours/Event</th>
                </tr>
              </thead>
              <tbody>
                {volunteers.map(v => (
                  <tr key={v.Vol_ID}>
                    <td>{v.Vol_ID}</td>
                    <td>{v.volunteer_name}</td>
                    <td style={{ fontSize: 13, color: '#555' }}>{v.Skills}</td>
                    <td>{v.events_participated}</td>
                    <td>{v.total_hours}</td>
                    <td>{v.avg_hours_per_event?.toFixed(1)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Donor Retention */}
      {activeTab === 'donors' && (
        <div>
          <h3>Donor Retention & Lifetime Value</h3>

          {/* Chart */}
          {donors.length > 0 && (
            <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)', marginBottom: 20, maxWidth: 900 }}>
              <h4>Top Donors by Lifetime Value</h4>
              <Bar
                data={{
                  labels: donors.slice(0, 10).map(d => d.donor_name),
                  datasets: [{
                    label: 'Lifetime Value',
                    data: donors.slice(0, 10).map(d => d.lifetime_value),
                    backgroundColor: '#f57c00'
                  }]
                }}
                options={{
                  responsive: true,
                  plugins: { legend: { display: false } },
                  scales: { y: { beginAtZero: true } }
                }}
              />
            </div>
          )}

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Donor ID</th>
                  <th>Donor Name</th>
                  <th>Donations</th>
                  <th>Lifetime Value</th>
                  <th>Avg Donation</th>
                  <th>First Donation</th>
                  <th>Latest Donation</th>
                  <th>Days Active</th>
                </tr>
              </thead>
              <tbody>
                {donors.map(d => (
                  <tr key={d.Donor_ID}>
                    <td>{d.Donor_ID}</td>
                    <td>{d.donor_name}</td>
                    <td>{d.donation_count}</td>
                    <td>{currency(d.lifetime_value)}</td>
                    <td>{currency(d.avg_donation)}</td>
                    <td>{d.first_donation}</td>
                    <td>{d.latest_donation}</td>
                    <td>{d.days_active}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Donations by Type */}
      {activeTab === 'donations' && (
        <div>
          <h3>Donation Breakdown by Type</h3>

          {/* Charts */}
          {donationsByType.length > 0 && (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, marginBottom: 20 }}>
              <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
                <h4>Donation Amount by Type</h4>
                <Pie
                  data={{
                    labels: donationsByType.map(d => d.donation_type),
                    datasets: [{
                      data: donationsByType.map(d => d.total_amount),
                      backgroundColor: ['#0056b3', '#f57c00', '#7b1fa2', '#00796b', '#c2185b', '#f57f17']
                    }]
                  }}
                  options={{ responsive: true, maintainAspectRatio: true }}
                />
              </div>
              <div style={{ background: '#fff', padding: 20, borderRadius: 8, boxShadow: '0 2px 4px rgba(0,0,0,0.1)' }}>
                <h4>Donation Count by Type</h4>
                <Bar
                  data={{
                    labels: donationsByType.map(d => d.donation_type),
                    datasets: [{
                      label: 'Count',
                      data: donationsByType.map(d => d.donation_count),
                      backgroundColor: '#0a6'
                    }]
                  }}
                  options={{
                    responsive: true,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true } }
                  }}
                />
              </div>
            </div>
          )}

          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Donation Type</th>
                  <th>Count</th>
                  <th>Total Amount</th>
                  <th>Avg Amount</th>
                </tr>
              </thead>
              <tbody>
                {donationsByType.map((d, idx) => (
                  <tr key={idx}>
                    <td>{d.donation_type}</td>
                    <td>{d.donation_count}</td>
                    <td>{currency(d.total_amount)}</td>
                    <td>{currency(d.avg_amount)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  )
}
