#!/usr/bin/env python3
"""
Competitive Audit Heatmap Visualization
Analyzes competitor scores across all tactics and highlights:
- Uncontested opportunities (where most competitors score low)
- Areas where you might be lagging (where competitors score high)
"""

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from pathlib import Path

# Configuration
INPUT_FILE = Path(__file__).parent.parent / "outputs/audits/master-competitive-audit.csv"
OUTPUT_DIR = Path(__file__).parent.parent / "outputs/insights"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def load_and_prepare_data(filepath):
    """Load CSV and pivot to company x tactic matrix"""
    df = pd.read_csv(filepath)

    # Create tactic label combining ID, name and theme
    df['Tactic_Label'] = df['Tactic_ID'].astype(str) + '. ' + df['Tactic_Name']

    # Pivot to get companies as columns, tactics as rows
    pivot = df.pivot_table(
        index=['Theme', 'Tactic_ID', 'Tactic_Label'],
        columns='Company',
        values='Score',
        aggfunc='first'
    ).reset_index()

    # Sort by theme and tactic ID
    pivot = pivot.sort_values(['Theme', 'Tactic_ID'])

    return df, pivot

def calculate_insights(pivot):
    """Calculate opportunity and threat metrics"""
    # Get company columns (exclude metadata)
    company_cols = [c for c in pivot.columns if c not in ['Theme', 'Tactic_ID', 'Tactic_Label']]

    # Calculate metrics for each tactic
    scores_df = pivot[company_cols]

    insights = pd.DataFrame({
        'Theme': pivot['Theme'],
        'Tactic_ID': pivot['Tactic_ID'],
        'Tactic_Label': pivot['Tactic_Label'],
        'Avg_Score': scores_df.mean(axis=1).round(2),
        'Max_Score': scores_df.max(axis=1),
        'Min_Score': scores_df.min(axis=1),
        'Std_Dev': scores_df.std(axis=1).round(2),
        'High_Scorers': (scores_df >= 4).sum(axis=1),  # Count of companies scoring 4+
        'Low_Scorers': (scores_df <= 2).sum(axis=1),   # Count of companies scoring 2 or less
    })

    # Classify opportunities
    # Uncontested = Most competitors score low (avg <= 2 or 80%+ score low)
    insights['Is_Uncontested'] = (insights['Avg_Score'] <= 2) | (insights['Low_Scorers'] >= len(company_cols) * 0.7)

    # Competitive battleground = High scores, you need to match (avg >= 4)
    insights['Is_Battleground'] = insights['Avg_Score'] >= 4

    # Mixed = High variance, some differentiation opportunity
    insights['Is_Mixed'] = insights['Std_Dev'] >= 1.5

    return insights, company_cols

def create_heatmap(pivot, insights, company_cols):
    """Create the main heatmap visualization"""

    # Prepare data for heatmap
    scores_matrix = pivot[company_cols].values
    tactic_labels = pivot['Tactic_Label'].values
    themes = pivot['Theme'].values

    # Figure setup - large enough for 68 tactics
    fig = plt.figure(figsize=(20, 28))

    # Create gridspec for layout
    gs = fig.add_gridspec(1, 2, width_ratios=[15, 1], wspace=0.02)
    ax_heatmap = fig.add_subplot(gs[0])
    ax_cbar = fig.add_subplot(gs[1])

    # Custom colormap: Red (1) -> Yellow (3) -> Green (5)
    from matplotlib.colors import LinearSegmentedColormap
    colors = ['#d73027', '#fc8d59', '#fee08b', '#d9ef8b', '#91cf60', '#1a9850']
    cmap = LinearSegmentedColormap.from_list('audit', colors, N=5)

    # Create heatmap
    im = ax_heatmap.imshow(scores_matrix, cmap=cmap, aspect='auto', vmin=1, vmax=5)

    # Add score text to each cell
    for i in range(len(tactic_labels)):
        for j in range(len(company_cols)):
            score = scores_matrix[i, j]
            text_color = 'white' if score <= 2 or score >= 4 else 'black'
            ax_heatmap.text(j, i, f'{int(score)}', ha='center', va='center',
                          fontsize=7, color=text_color, fontweight='bold')

    # Highlight rows based on classification
    for i, (is_uncontested, is_battleground) in enumerate(zip(insights['Is_Uncontested'], insights['Is_Battleground'])):
        if is_uncontested:
            # Blue border for uncontested opportunities
            rect = mpatches.Rectangle((-0.5, i-0.5), len(company_cols), 1,
                                      fill=False, edgecolor='#2166ac', linewidth=2)
            ax_heatmap.add_patch(rect)
        elif is_battleground:
            # Orange border for battlegrounds (need to match)
            rect = mpatches.Rectangle((-0.5, i-0.5), len(company_cols), 1,
                                      fill=False, edgecolor='#b2182b', linewidth=2)
            ax_heatmap.add_patch(rect)

    # Add theme separators
    current_theme = None
    theme_positions = []
    for i, theme in enumerate(themes):
        if theme != current_theme:
            if current_theme is not None:
                ax_heatmap.axhline(y=i-0.5, color='black', linewidth=2)
            theme_positions.append((i, theme))
            current_theme = theme

    # Labels
    ax_heatmap.set_xticks(range(len(company_cols)))
    ax_heatmap.set_xticklabels(company_cols, rotation=45, ha='right', fontsize=9)
    ax_heatmap.set_yticks(range(len(tactic_labels)))
    ax_heatmap.set_yticklabels(tactic_labels, fontsize=7)

    # Add theme labels on right side
    ax_theme = ax_heatmap.secondary_yaxis('right')
    ax_theme.set_yticks([])

    # Title
    ax_heatmap.set_title('Competitive Experience Audit Heatmap\n11 Companies × 68 Tactics',
                         fontsize=14, fontweight='bold', pad=20)

    # Colorbar
    cbar = plt.colorbar(im, cax=ax_cbar)
    cbar.set_ticks([1, 2, 3, 4, 5])
    cbar.set_ticklabels(['1\nNo Evidence', '2\nWeak', '3\nModerate', '4\nGood', '5\nStrong'])
    cbar.ax.tick_params(labelsize=8)

    # Legend for highlights
    legend_elements = [
        mpatches.Patch(facecolor='white', edgecolor='#2166ac', linewidth=2,
                      label='🎯 Uncontested Opportunity (most score low)'),
        mpatches.Patch(facecolor='white', edgecolor='#b2182b', linewidth=2,
                      label='⚔️ Battleground (most score high - must match)')
    ]
    ax_heatmap.legend(handles=legend_elements, loc='upper center',
                     bbox_to_anchor=(0.5, -0.02), ncol=2, fontsize=9)

    plt.tight_layout()

    # Save
    output_path = OUTPUT_DIR / 'competitive-heatmap.png'
    plt.savefig(output_path, dpi=150, bbox_inches='tight', facecolor='white')
    print(f"✓ Heatmap saved to: {output_path}")

    return fig

def create_summary_tables(insights, company_cols):
    """Create summary analysis tables"""

    # Uncontested opportunities
    uncontested = insights[insights['Is_Uncontested']].sort_values('Avg_Score')[
        ['Theme', 'Tactic_Label', 'Avg_Score', 'Low_Scorers']
    ].head(15)

    # Battlegrounds (must match)
    battlegrounds = insights[insights['Is_Battleground']].sort_values('Avg_Score', ascending=False)[
        ['Theme', 'Tactic_Label', 'Avg_Score', 'High_Scorers']
    ].head(15)

    # Theme averages
    theme_avg = insights.groupby('Theme')['Avg_Score'].mean().round(2).sort_values(ascending=False)

    return uncontested, battlegrounds, theme_avg

def print_analysis(uncontested, battlegrounds, theme_avg, company_cols):
    """Print analysis to console"""

    print("\n" + "="*80)
    print("COMPETITIVE AUDIT ANALYSIS")
    print("="*80)

    print(f"\n📊 DATASET: {len(company_cols)} companies × 68 tactics")
    print(f"   Companies: {', '.join(company_cols)}")

    print("\n" + "-"*80)
    print("🎯 UNCONTESTED OPPORTUNITIES")
    print("   Tactics where most competitors score LOW (≤2) - potential differentiation")
    print("-"*80)

    if len(uncontested) > 0:
        for _, row in uncontested.iterrows():
            print(f"   [{row['Theme'][:15]:<15}] {row['Tactic_Label']:<45} Avg: {row['Avg_Score']}")
    else:
        print("   No clear uncontested opportunities found.")

    print("\n" + "-"*80)
    print("⚔️  BATTLEGROUNDS (Table Stakes)")
    print("   Tactics where most competitors score HIGH (≥4) - must match to compete")
    print("-"*80)

    if len(battlegrounds) > 0:
        for _, row in battlegrounds.iterrows():
            print(f"   [{row['Theme'][:15]:<15}] {row['Tactic_Label']:<45} Avg: {row['Avg_Score']}")
    else:
        print("   No clear battlegrounds found.")

    print("\n" + "-"*80)
    print("📈 THEME PERFORMANCE (Industry Average)")
    print("-"*80)
    for theme, avg in theme_avg.items():
        bar = "█" * int(avg * 4)
        print(f"   {theme:<30} {avg:.2f} {bar}")

    print("\n" + "="*80)

def save_insights_csv(insights, company_cols):
    """Save detailed insights to CSV"""
    output_path = OUTPUT_DIR / 'competitive-insights.csv'
    insights.to_csv(output_path, index=False)
    print(f"✓ Insights CSV saved to: {output_path}")

def main():
    print("Loading audit data...")
    df, pivot = load_and_prepare_data(INPUT_FILE)

    print("Calculating insights...")
    insights, company_cols = calculate_insights(pivot)

    print("Creating heatmap visualization...")
    create_heatmap(pivot, insights, company_cols)

    print("Generating summary tables...")
    uncontested, battlegrounds, theme_avg = create_summary_tables(insights, company_cols)

    print_analysis(uncontested, battlegrounds, theme_avg, company_cols)

    save_insights_csv(insights, company_cols)

    print("\n✓ Analysis complete!")

if __name__ == "__main__":
    main()
