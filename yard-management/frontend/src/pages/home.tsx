import { useState } from 'react'
import { LoginPage } from '@/components/LoginPage'
import { Dashboard } from '@/components/Dashboard'

export default function Home() {
  const [isLoggedIn, setIsLoggedIn] = useState(() => {
    return !!localStorage.getItem('token')
  })

  const handleLoginSuccess = () => {
    setIsLoggedIn(true)
  }

  const handleLogout = () => {
    setIsLoggedIn(false)
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  if (!isLoggedIn) {
    return <LoginPage onLoginSuccess={handleLoginSuccess} />
  }

  return <Dashboard onLogout={handleLogout} />
}
