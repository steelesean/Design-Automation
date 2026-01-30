import { useState, useEffect, useMemo } from 'react'
import Papa from 'papaparse'
import './App.css'

// Company categories with specific ordering
const COMPANY_CATEGORIES = [
  {
    name: 'Competitors',
    companies: ['Quilter', 'Transact', 'Aviva', 'AJ Bell', 'Aberdeen']
  },
  {
    name: 'Fintechs',
    companies: ['Monzo', 'Revolut', 'Wise']
  },
  {
    name: 'Market Leaders',
    companies: ['Netflix', 'Amazon', 'OpenAI']
  }
]

// Flatten to get ordered list
const COMPANY_ORDER = COMPANY_CATEGORIES.flatMap(cat => cat.companies)

// Color scale for scores 1-5
const getScoreColor = (score) => {
  const colors = {
    1: '#dc2626', // Red - No evidence
    2: '#f97316', // Orange - Weak
    3: '#eab308', // Yellow - Moderate
    4: '#84cc16', // Light green - Good
    5: '#22c55e', // Green - Strong
  }
  return colors[score] || '#6b7280'
}

const getScoreBg = (score) => {
  const colors = {
    1: 'rgba(220, 38, 38, 0.15)',
    2: 'rgba(249, 115, 22, 0.15)',
    3: 'rgba(234, 179, 8, 0.15)',
    4: 'rgba(132, 204, 22, 0.15)',
    5: 'rgba(34, 197, 94, 0.15)',
  }
  return colors[score] || 'transparent'
}

function App() {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)
  const [selectedTheme, setSelectedTheme] = useState('all')
  const [hoveredCell, setHoveredCell] = useState(null)
  const [sortBy, setSortBy] = useState('tactic') // 'tactic', 'avg-asc', 'avg-desc'
  const [expandedCards, setExpandedCards] = useState({
    opportunities: false,
    battlegrounds: false,
    themes: false
  })

  const toggleCard = (card) => {
    setExpandedCards(prev => ({ ...prev, [card]: !prev[card] }))
  }

  useEffect(() => {
    Papa.parse(import.meta.env.BASE_URL + 'audit-data.csv', {
      download: true,
      header: true,
      complete: (results) => {
        setData(results.data.filter(row => row.Company && row.Tactic_ID))
        setLoading(false)
      }
    })
  }, [])

  // Extract unique values - ordered by category
  const companies = useMemo(() => {
    const dataCompanies = new Set(data.map(d => d.Company))
    // Return companies in defined order, filtering to only those in data
    return COMPANY_ORDER.filter(c => dataCompanies.has(c))
  }, [data])

  const themes = useMemo(() => {
    return [...new Set(data.map(d => d.Theme))].filter(Boolean)
  }, [data])

  // Pivot data: tactics as rows, companies as columns
  const { pivotData, insights, companyStats } = useMemo(() => {
    const tacticMap = new Map()

    data.forEach(row => {
      const key = `${row.Theme}|${row.Tactic_ID}|${row.Tactic_Name}`
      if (!tacticMap.has(key)) {
        tacticMap.set(key, {
          theme: row.Theme,
          tacticId: parseInt(row.Tactic_ID),
          tacticName: row.Tactic_Name,
          scores: {},
          evidences: {}
        })
      }
      tacticMap.get(key).scores[row.Company] = parseInt(row.Score)
      tacticMap.get(key).evidences[row.Company] = row.Evidence
    })

    let tactics = Array.from(tacticMap.values())

    // Calculate insights for each tactic
    tactics = tactics.map(tactic => {
      const scoreValues = Object.values(tactic.scores).filter(s => !isNaN(s))
      const avg = scoreValues.length > 0
        ? scoreValues.reduce((a, b) => a + b, 0) / scoreValues.length
        : 0
      const lowScorers = scoreValues.filter(s => s <= 2).length
      const highScorers = scoreValues.filter(s => s >= 4).length

      return {
        ...tactic,
        avgScore: avg,
        lowScorers,
        highScorers,
        isUncontested: avg <= 2 || lowScorers >= scoreValues.length * 0.7,
        isBattleground: avg >= 4 || highScorers >= scoreValues.length * 0.7,
      }
    })

    // Sort tactics
    tactics.sort((a, b) => {
      // First by theme
      if (a.theme !== b.theme) {
        return themes.indexOf(a.theme) - themes.indexOf(b.theme)
      }
      // Then by tactic ID
      return a.tacticId - b.tacticId
    })

    // Calculate overall insights
    const uncontested = tactics.filter(t => t.isUncontested).sort((a, b) => a.avgScore - b.avgScore)
    const battlegrounds = tactics.filter(t => t.isBattleground).sort((a, b) => b.avgScore - a.avgScore)

    // Theme averages
    const themeAvgs = themes.map(theme => {
      const themeTactics = tactics.filter(t => t.theme === theme)
      const avg = themeTactics.reduce((sum, t) => sum + t.avgScore, 0) / themeTactics.length
      return { theme, avg }
    }).sort((a, b) => b.avg - a.avg)

    // Calculate per-company stats (overall avg + per-theme avgs)
    const companyStats = {}
    const uniqueCompanies = [...new Set(data.map(d => d.Company))].filter(Boolean)

    uniqueCompanies.forEach(company => {
      const companyRows = data.filter(d => d.Company === company)
      const scores = companyRows.map(r => parseInt(r.Score)).filter(s => !isNaN(s))
      const overallAvg = scores.length > 0
        ? scores.reduce((a, b) => a + b, 0) / scores.length
        : 0

      // Per-theme averages for this company
      const themeAvgs = {}
      themes.forEach(theme => {
        const themeRows = companyRows.filter(r => r.Theme === theme)
        const themeScores = themeRows.map(r => parseInt(r.Score)).filter(s => !isNaN(s))
        themeAvgs[theme] = themeScores.length > 0
          ? themeScores.reduce((a, b) => a + b, 0) / themeScores.length
          : 0
      })

      companyStats[company] = {
        overallAvg,
        themeAvgs,
        totalTactics: scores.length
      }
    })

    return {
      pivotData: tactics,
      insights: { uncontested, battlegrounds, themeAvgs },
      companyStats
    }
  }, [data, themes])

  // Filter by theme
  const filteredData = useMemo(() => {
    if (selectedTheme === 'all') return pivotData
    return pivotData.filter(t => t.theme === selectedTheme)
  }, [pivotData, selectedTheme])

  // Sort data
  const sortedData = useMemo(() => {
    const sorted = [...filteredData]
    if (sortBy === 'avg-asc') {
      sorted.sort((a, b) => a.avgScore - b.avgScore)
    } else if (sortBy === 'avg-desc') {
      sorted.sort((a, b) => b.avgScore - a.avgScore)
    }
    return sorted
  }, [filteredData, sortBy])

  if (loading) {
    return <div className="loading">Loading audit data...</div>
  }

  return (
    <div className="dashboard">
      <header className="header">
        <h1>Competitive Experience Audit</h1>
        <p className="subtitle">{companies.length} companies × {pivotData.length} tactics</p>
      </header>

      <div className="main-layout">
        {/* Sidebar with insights */}
        <aside className="sidebar">
          <div className={`insight-card opportunities ${expandedCards.opportunities ? 'expanded' : 'collapsed'}`}>
            <button className="card-header" onClick={() => toggleCard('opportunities')}>
              <h3>Uncontested Opportunities</h3>
              <span className="card-count">{insights.uncontested.length}</span>
              <span className="toggle-icon">{expandedCards.opportunities ? '−' : '+'}</span>
            </button>
            {expandedCards.opportunities && (
              <>
                <p className="insight-desc">Most competitors score low - potential differentiation</p>
                <ul>
                  {insights.uncontested.slice(0, 8).map(t => (
                    <li key={`${t.theme}-${t.tacticId}`}>
                      <span className="tactic-name">{t.tacticId}. {t.tacticName}</span>
                      <span className="avg-badge" style={{ background: getScoreColor(Math.round(t.avgScore)) }}>
                        {t.avgScore.toFixed(1)}
                      </span>
                    </li>
                  ))}
                </ul>
              </>
            )}
          </div>

          <div className={`insight-card battlegrounds ${expandedCards.battlegrounds ? 'expanded' : 'collapsed'}`}>
            <button className="card-header" onClick={() => toggleCard('battlegrounds')}>
              <h3>Battlegrounds (Table Stakes)</h3>
              <span className="card-count">{insights.battlegrounds.length}</span>
              <span className="toggle-icon">{expandedCards.battlegrounds ? '−' : '+'}</span>
            </button>
            {expandedCards.battlegrounds && (
              <>
                <p className="insight-desc">Most competitors score high - must match to compete</p>
                <ul>
                  {insights.battlegrounds.slice(0, 8).map(t => (
                    <li key={`${t.theme}-${t.tacticId}`}>
                      <span className="tactic-name">{t.tacticId}. {t.tacticName}</span>
                      <span className="avg-badge" style={{ background: getScoreColor(Math.round(t.avgScore)) }}>
                        {t.avgScore.toFixed(1)}
                      </span>
                    </li>
                  ))}
                </ul>
              </>
            )}
          </div>

          <div className={`insight-card theme-performance ${expandedCards.themes ? 'expanded' : 'collapsed'}`}>
            <button className="card-header" onClick={() => toggleCard('themes')}>
              <h3>Theme Performance</h3>
              <span className="card-count">{insights.themeAvgs.length}</span>
              <span className="toggle-icon">{expandedCards.themes ? '−' : '+'}</span>
            </button>
            {expandedCards.themes && (
              <>
                <p className="insight-desc">Industry average by theme</p>
                <ul>
                  {insights.themeAvgs.map(({ theme, avg }) => (
                    <li key={theme}>
                      <span className="theme-name">{theme}</span>
                      <div className="theme-bar-container">
                        <div
                          className="theme-bar"
                          style={{
                            width: `${(avg / 5) * 100}%`,
                            background: getScoreColor(Math.round(avg))
                          }}
                        />
                        <span className="theme-avg">{avg.toFixed(2)}</span>
                      </div>
                    </li>
                  ))}
                </ul>
              </>
            )}
          </div>
        </aside>

        {/* Main heatmap */}
        <main className="heatmap-container">
          <div className="controls">
            <div className="filter-group">
              <label>Theme:</label>
              <select value={selectedTheme} onChange={e => setSelectedTheme(e.target.value)}>
                <option value="all">All Themes</option>
                {themes.map(theme => (
                  <option key={theme} value={theme}>{theme}</option>
                ))}
              </select>
            </div>
            <div className="filter-group">
              <label>Sort:</label>
              <select value={sortBy} onChange={e => setSortBy(e.target.value)}>
                <option value="tactic">By Tactic ID</option>
                <option value="avg-asc">Avg Score (Low → High)</option>
                <option value="avg-desc">Avg Score (High → Low)</option>
              </select>
            </div>
            <div className="legend">
              <span className="legend-item"><span className="dot" style={{background: '#dc2626'}}></span> 1 No Evidence</span>
              <span className="legend-item"><span className="dot" style={{background: '#f97316'}}></span> 2 Weak</span>
              <span className="legend-item"><span className="dot" style={{background: '#eab308'}}></span> 3 Moderate</span>
              <span className="legend-item"><span className="dot" style={{background: '#84cc16'}}></span> 4 Good</span>
              <span className="legend-item"><span className="dot" style={{background: '#22c55e'}}></span> 5 Strong</span>
            </div>
          </div>

          <div className="heatmap-scroll">
            <table className="heatmap">
              <thead>
                {/* Category header row */}
                <tr className="category-row">
                  <th className="tactic-header"></th>
                  <th className="avg-header"></th>
                  {COMPANY_CATEGORIES.map(category => (
                    <th
                      key={category.name}
                      className="category-header"
                      colSpan={category.companies.filter(c => companies.includes(c)).length}
                    >
                      {category.name}
                    </th>
                  ))}
                </tr>
                {/* Company names row */}
                <tr className="company-row">
                  <th className="tactic-header">Tactic</th>
                  <th className="avg-header">Avg</th>
                  {companies.map((company, idx) => {
                    // Check if this is the first company in a category
                    const isFirstInCategory = COMPANY_CATEGORIES.some(
                      cat => cat.companies[0] === company && companies.includes(company)
                    )
                    return (
                      <th
                        key={company}
                        className={`company-header ${isFirstInCategory ? 'category-start' : ''}`}
                      >
                        <span className="company-name">{company}</span>
                      </th>
                    )
                  })}
                </tr>
                {/* Company average scores row */}
                <tr className="company-avg-row">
                  <th className="tactic-header avg-label">Company Avg</th>
                  <th className="avg-header"></th>
                  {companies.map(company => {
                    const stats = companyStats[company]
                    const avg = stats?.overallAvg || 0
                    return (
                      <th
                        key={`avg-${company}`}
                        className="company-avg-cell"
                        style={{ background: getScoreBg(Math.round(avg)) }}
                      >
                        <div className="company-avg-wrapper">
                          <span
                            className="company-avg-score"
                            style={{ color: getScoreColor(Math.round(avg)) }}
                          >
                            {avg.toFixed(1)}
                          </span>
                          {stats && (
                            <div className="theme-breakdown-tooltip">
                              <div className="tooltip-header">{company}</div>
                              <div className="tooltip-overall">
                                Overall: <strong>{avg.toFixed(2)}</strong> / 5
                              </div>
                              <div className="tooltip-themes">
                                {themes.map(theme => {
                                  const themeAvg = stats.themeAvgs[theme] || 0
                                  return (
                                    <div key={theme} className="theme-row">
                                      <span className="theme-label">{theme}</span>
                                      <div className="theme-bar-bg">
                                        <div
                                          className="theme-bar-fill"
                                          style={{
                                            width: `${(themeAvg / 5) * 100}%`,
                                            background: getScoreColor(Math.round(themeAvg))
                                          }}
                                        />
                                      </div>
                                      <span
                                        className="theme-score"
                                        style={{ color: getScoreColor(Math.round(themeAvg)) }}
                                      >
                                        {themeAvg.toFixed(1)}
                                      </span>
                                    </div>
                                  )
                                })}
                              </div>
                            </div>
                          )}
                        </div>
                      </th>
                    )
                  })}
                </tr>
              </thead>
              <tbody>
                {sortedData.map((tactic, idx) => {
                  const prevTheme = idx > 0 ? sortedData[idx - 1].theme : null
                  const showThemeHeader = sortBy === 'tactic' && tactic.theme !== prevTheme

                  return (
                    <>
                      {showThemeHeader && (
                        <tr key={`theme-${tactic.theme}`} className="theme-row">
                          <td colSpan={companies.length + 2}>{tactic.theme}</td>
                        </tr>
                      )}
                      <tr
                        key={`${tactic.theme}-${tactic.tacticId}`}
                        className={`
                          ${tactic.isUncontested ? 'uncontested-row' : ''}
                          ${tactic.isBattleground ? 'battleground-row' : ''}
                        `}
                      >
                        <td className="tactic-cell">
                          <span className="tactic-id">{tactic.tacticId}.</span>
                          <span className="tactic-name">{tactic.tacticName}</span>
                          {tactic.isUncontested && <span className="tag opportunity">Opportunity</span>}
                          {tactic.isBattleground && <span className="tag battleground">Table Stakes</span>}
                        </td>
                        <td className="avg-cell" style={{ background: getScoreBg(Math.round(tactic.avgScore)) }}>
                          <span style={{ color: getScoreColor(Math.round(tactic.avgScore)) }}>
                            {tactic.avgScore.toFixed(1)}
                          </span>
                        </td>
                        {companies.map(company => {
                          const score = tactic.scores[company]
                          const evidence = tactic.evidences[company]
                          const isHovered = hoveredCell?.tactic === tactic.tacticId && hoveredCell?.company === company

                          return (
                            <td
                              key={company}
                              className="score-cell"
                              style={{
                                background: getScoreBg(score),
                                position: 'relative'
                              }}
                              onMouseEnter={() => setHoveredCell({ tactic: tactic.tacticId, company, evidence, score, tacticName: tactic.tacticName })}
                              onMouseLeave={() => setHoveredCell(null)}
                            >
                              <span
                                className="score"
                                style={{ color: getScoreColor(score) }}
                              >
                                {score || '-'}
                              </span>
                              {isHovered && evidence && (
                                <div className="tooltip">
                                  <strong>{company}: {tactic.tacticName}</strong>
                                  <p>{evidence}</p>
                                </div>
                              )}
                            </td>
                          )
                        })}
                      </tr>
                    </>
                  )
                })}
              </tbody>
            </table>
          </div>
        </main>
      </div>
    </div>
  )
}

export default App
