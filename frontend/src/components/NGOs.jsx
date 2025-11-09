import React, { useEffect, useState } from 'react'
import axios from 'axios'

export default function NGOs() {
  const [ngos, setNgos] = useState([])
  const [form, setForm] = useState({
    name: '',
    registration: '',
    address: '',
    phone: '',
    email: '',
    type: ''
  })
  const [editing, setEditing] = useState(null)

  useEffect(() => {
    loadNgos()
  }, [])

  const loadNgos = () => {
    axios.get('http://127.0.0.1:8000/ngos').then(r => setNgos(r.data || []))
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    if (editing) {
      // Update existing NGO
      axios.put(`http://127.0.0.1:8000/ngos/${editing}`, form).then(() => {
        loadNgos()
        resetForm()
      }).catch(err => alert('Error updating NGO: ' + (err.response?.data?.detail || err.message)))
    } else {
      // Create new NGO
      axios.post('http://127.0.0.1:8000/ngos', form).then(() => {
        loadNgos()
        resetForm()
      }).catch(err => alert('Error adding NGO: ' + (err.response?.data?.detail || err.message)))
    }
  }

  const handleEdit = (ngo) => {
    setEditing(ngo.NGO_ID)
    setForm({
      name: ngo.NGO_Name,
      registration: ngo.Registration_Number,
      address: ngo.Address || '',
      phone: ngo.Phone || '',
      email: ngo.Email,
      type: ngo.Type
    })
  }

  const handleDelete = (id) => {
    if (!confirm('Delete this NGO?')) return
    axios.delete(`http://127.0.0.1:8000/ngos/${id}`).then(() => {
      loadNgos()
    }).catch(err => alert('Error deleting NGO: ' + (err.response?.data?.detail || err.message)))
  }

  const resetForm = () => {
    setForm({ name: '', registration: '', address: '', phone: '', email: '', type: '' })
    setEditing(null)
  }

  return (
    <div>
      <h2>NGO Management</h2>

      <form onSubmit={handleSubmit} className="controls" style={{ marginBottom: 20 }}>
        <input
          placeholder="NGO Name"
          value={form.name}
          onChange={e => setForm({ ...form, name: e.target.value })}
          required
        />
        <input
          placeholder="Registration Number"
          value={form.registration}
          onChange={e => setForm({ ...form, registration: e.target.value })}
          required
        />
        <input
          placeholder="Email"
          type="email"
          value={form.email}
          onChange={e => setForm({ ...form, email: e.target.value })}
          required
        />
        <input
          placeholder="Phone"
          value={form.phone}
          onChange={e => setForm({ ...form, phone: e.target.value })}
        />
        <input
          placeholder="Address"
          value={form.address}
          onChange={e => setForm({ ...form, address: e.target.value })}
        />
        <input
          placeholder="Type (e.g., Charitable, Educational)"
          value={form.type}
          onChange={e => setForm({ ...form, type: e.target.value })}
          required
        />
        <button type="submit">{editing ? 'Update NGO' : 'Add NGO'}</button>
        {editing && <button type="button" onClick={resetForm}>Cancel</button>}
      </form>

      <div className="table-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Registration Number</th>
              <th>Type</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Address</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {ngos.map(ngo => (
              <tr key={ngo.NGO_ID}>
                <td>{ngo.NGO_ID}</td>
                <td style={{ fontWeight: 'bold' }}>{ngo.NGO_Name}</td>
                <td>{ngo.Registration_Number}</td>
                <td>{ngo.Type}</td>
                <td>{ngo.Email}</td>
                <td>{ngo.Phone || 'N/A'}</td>
                <td>{ngo.Address || 'N/A'}</td>
                <td>
                  <button onClick={() => handleEdit(ngo)}>Edit</button>
                  <button onClick={() => handleDelete(ngo.NGO_ID)} style={{ marginLeft: 4 }}>Delete</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
