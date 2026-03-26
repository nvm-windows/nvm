import { useEffect, useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select } from '@/components/ui/select'
import { apiCall } from '@/lib/utils'

interface Container {
  id: string
  tag: string
  type: string
  locationId: string
  lastUpdatedAt: string
}

interface Slot {
  id: string
  containerId: string | null
  container: Container | null
}

interface Summary {
  totalSlots: number
  occupied: number
  empty: number
  totalContainers: number
}

interface DashboardProps {
  onLogout: () => void
}

export function Dashboard({ onLogout }: DashboardProps) {
  const token = localStorage.getItem('token') || ''
  const user = JSON.parse(localStorage.getItem('user') || 'null')

  // Fetch data
  const { data: containers = [] } = useQuery({
    queryKey: ['containers'],
    queryFn: () => apiCall<Container[]>('/containers', { token }),
  })

  const { data: slots = [] } = useQuery({
    queryKey: ['slots'],
    queryFn: () => apiCall<Slot[]>('/yard/slots', { token }),
  })

  const { data: summary } = useQuery({
    queryKey: ['summary'],
    queryFn: () => apiCall<Summary>('/yard/summary', { token }),
  })

  // Form states
  const [newContainer, setNewContainer] = useState({ tag: '', type: '', locationId: '' })
  const [moveContainer, setMoveContainer] = useState({ id: '', locationId: '' })
  const [search, setSearch] = useState('')

  const handleAddContainer = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      await apiCall('/containers', {
        method: 'POST',
        token,
        body: JSON.stringify(newContainer),
      })
      setNewContainer({ tag: '', type: '', locationId: '' })
      window.location.reload() // Refresh data
    } catch (err) {
      console.error('Failed to add container:', err)
    }
  }

  const handleMoveContainer = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      await apiCall(`/containers/${moveContainer.id}/move`, {
        method: 'PUT',
        token,
        body: JSON.stringify({ locationId: moveContainer.locationId }),
      })
      setMoveContainer({ id: '', locationId: '' })
      window.location.reload() // Refresh data
    } catch (err) {
      console.error('Failed to move container:', err)
    }
  }

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault()
    try {
      const results = await apiCall<Container[]>(
        `/containers/search?q=${encodeURIComponent(search)}`,
        { token }
      )
      console.log('Search results:', results)
    } catch (err) {
      console.error('Search failed:', err)
    }
  }

  const emptySlots = slots.filter((slot) => !slot.containerId)

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b bg-card shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-3xl font-bold">Yard Management Dashboard</h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-muted-foreground">{user?.username}</span>
            <Button onClick={onLogout} variant="destructive">
              Logout
            </Button>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-8">
        {/* Summary Section */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-lg">Total Slots</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{summary?.totalSlots || '0'}</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-lg">Occupied</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold text-red-500">{summary?.occupied || '0'}</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-lg">Empty</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold text-green-500">{summary?.empty || '0'}</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-lg">Total Containers</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{summary?.totalContainers || '0'}</p>
            </CardContent>
          </Card>
        </div>

        {/* Operations Section */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          {/* Add Container */}
          <Card>
            <CardHeader>
              <CardTitle>Add Container</CardTitle>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleAddContainer} className="space-y-4">
                <div>
                  <Label htmlFor="tag">Tag</Label>
                  <Input
                    id="tag"
                    value={newContainer.tag}
                    onChange={(e) =>
                      setNewContainer({ ...newContainer, tag: e.target.value })
                    }
                    required
                  />
                </div>
                <div>
                  <Label htmlFor="type">Type</Label>
                  <Input
                    id="type"
                    value={newContainer.type}
                    onChange={(e) =>
                      setNewContainer({ ...newContainer, type: e.target.value })
                    }
                  />
                </div>
                <div>
                  <Label htmlFor="location">Location</Label>
                  <Select
                    id="location"
                    value={newContainer.locationId}
                    onChange={(e) =>
                      setNewContainer({ ...newContainer, locationId: e.target.value })
                    }
                    required
                  >
                    <option value="">Select a slot</option>
                    {emptySlots.map((slot) => (
                      <option key={slot.id} value={slot.id}>
                        {slot.id}
                      </option>
                    ))}
                  </Select>
                </div>
                <Button type="submit" className="w-full">
                  Add Container
                </Button>
              </form>
            </CardContent>
          </Card>

          {/* Move Container */}
          <Card>
            <CardHeader>
              <CardTitle>Move Container</CardTitle>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleMoveContainer} className="space-y-4">
                <div>
                  <Label htmlFor="container">Container</Label>
                  <Select
                    id="container"
                    value={moveContainer.id}
                    onChange={(e) =>
                      setMoveContainer({ ...moveContainer, id: e.target.value })
                    }
                    required
                  >
                    <option value="">Select container</option>
                    {containers.map((c) => (
                      <option key={c.id} value={c.id}>
                        {c.tag} ({c.locationId})
                      </option>
                    ))}
                  </Select>
                </div>
                <div>
                  <Label htmlFor="to-slot">To Slot</Label>
                  <Select
                    id="to-slot"
                    value={moveContainer.locationId}
                    onChange={(e) =>
                      setMoveContainer({ ...moveContainer, locationId: e.target.value })
                    }
                    required
                  >
                    <option value="">Select target slot</option>
                    {emptySlots.map((slot) => (
                      <option key={slot.id} value={slot.id}>
                        {slot.id}
                      </option>
                    ))}
                  </Select>
                </div>
                <Button type="submit" className="w-full">
                  Move Container
                </Button>
              </form>
            </CardContent>
          </Card>

          {/* Search */}
          <Card>
            <CardHeader>
              <CardTitle>Search</CardTitle>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSearch} className="space-y-4">
                <div>
                  <Label htmlFor="search">Tag or Location</Label>
                  <Input
                    id="search"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    placeholder="Search..."
                  />
                </div>
                <Button type="submit" className="w-full">
                  Search
                </Button>
              </form>
            </CardContent>
          </Card>
        </div>

        {/* Yard Map */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle>Yard Map</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-6 gap-2">
              {slots.map((slot) => (
                <div
                  key={slot.id}
                  className={`p-4 rounded-lg border text-center font-semibold ${
                    slot.containerId
                      ? 'bg-red-50 border-red-300 text-red-900'
                      : 'bg-green-50 border-green-300 text-green-900'
                  }`}
                >
                  <div className="text-sm">{slot.id}</div>
                  {slot.container && <div className="text-xs mt-1">{slot.container.tag}</div>}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Container List */}
        <Card>
          <CardHeader>
            <CardTitle>Container List</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b">
                    <th className="text-left py-2 px-4">Tag</th>
                    <th className="text-left py-2 px-4">Type</th>
                    <th className="text-left py-2 px-4">Location</th>
                    <th className="text-left py-2 px-4">Last Updated</th>
                  </tr>
                </thead>
                <tbody>
                  {containers.map((c) => (
                    <tr key={c.id} className="border-b hover:bg-muted/50">
                      <td className="py-2 px-4">{c.tag}</td>
                      <td className="py-2 px-4">{c.type}</td>
                      <td className="py-2 px-4">{c.locationId}</td>
                      <td className="py-2 px-4">
                        {new Date(c.lastUpdatedAt).toLocaleString()}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {containers.length === 0 && (
                <div className="text-center py-8 text-muted-foreground">
                  No containers found
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  )
}
