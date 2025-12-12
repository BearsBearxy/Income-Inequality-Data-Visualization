# Income-Inequality-Data-Visualization
Project
## Gender Income Gap Narrative Visualization

An interactive visual analytics project built with R Shiny that explores global patterns of gender income differences and representation across education and occupations.

## Overview

This project presents an interactive narrative visualization that guides users through the key factors behind the gender income gap. The application combines multiple coordinated views that reveal how educational attainment, leadership representation, and occupational composition contribute to persistent income disparities between men and women.

The narrative progresses through several pages. Each page highlights a specific dimension of the data and uses purposeful visual and textual storytelling to communicate the findings in a clear and engaging way.

## Key Features
Interactive Narrative Structure

The application is designed as a step-by-step visual story. Each page advances the narrative and focuses on a data-driven question.

### Page 1

A high-level introduction to the gender income gap with summary indicators and visual cues that set the context for deeper exploration.

### Page 2

A comparison of income distributions for men and women across four education levels. A responsive histogram and a dynamic median income bar chart reveal that men consistently show higher median income and a longer right tail across all educational groups.

### Page 3

A world map showing the percentage of firms with a female top manager. This visualization highlights global patterns of female leadership and the structural factors that influence income inequality.

### Page 4

A set of occupation-based comparisons where users can switch between many occupational categories through a dropdown selector. The bar chart shows the proportion of racial groups across occupations and supports exploration of intersectional labour distribution patterns.

## Data Sources

The application uses publicly available datasets, including

The United States Census Bureau's income and occupation data

The World Bank Gender Dataset for female leadership indicators
All datasets are included in the repository in CSV format.

## Technology Stack

```
R

R Shiny

Plotly

Tidyverse
```

## How to Run the Application

1. Clone the repository
2. Open the project folder in RStudio
3. Run the app

```
shiny::runApp()
```

## Purpose of the Project

The primary goal of this project is to demonstrate the use of narrative visualization in communicating social and economic issues. The design applies principles from information, visualization, including visual encoding, colour semantics, layout hierarchy, and narrative structure to produce an accessible and meaningful data story.

