# 🏏 IPL 2017 Mega Auction Strategy – RCB Player Selection

## 📘 Project Overview :
In this project, I worked as a sports data analyst for **Royal Challengers Bangalore (RCB)** to support their decision-making process ahead of the **2017 IPL mega auction**.  
The objective was to identify **top-performing**, **consistent**, and **cost-effective players** by analyzing historical IPL data. All analysis was conducted using **SQL** for data extraction from a multi-table database, and **Excel** for organizing, cleaning, and interpreting the results.  
The focus was on generating **actionable, data-driven insights** to optimize player selection and auction investments.

---
# 🗂️ Database : <a href="https://github.com/roopsagnik/IPL-Strategy-for-RCB/blob/main/Data.sql"> Data </a>
---

# 🗂️ Database Schema : 
> The analysis is based on a relational IPL database consisting of 20+ interrelated tables such as players, matches, deliveries, teams, and performances.
![schema](https://github.com/user-attachments/assets/6a8fd041-201d-4c5d-a0aa-cc4738f2a0bc)

<ul>
  <li><strong>Table: Player</strong>
    <ul>
      <li><code>Player_Id</code> – INT, Primary Key</li>
      <li><code>Player_Name</code> – VARCHAR</li>
      <li><code>DOB</code> – DATETIME</li>
      <li><code>Batting_hand</code> – VARCHAR</li>
      <li><code>Bowling_skill</code> – VARCHAR</li>
      <li><code>Country_Name</code> – VARCHAR</li>
    </ul>
  </li>

  <li><strong>Table: Extra_Runs</strong>
    <ul>
      <li><code>Match_Id</code> – INT, NOT NULL</li>
      <li><code>Over_Id</code> – INT, NOT NULL</li>
      <li><code>Ball_Id</code> – INT, NOT NULL</li>
      <li><code>Extra_Type_Id</code> – INT</li>
      <li><code>Extra_Runs</code> – INT</li>
      <li><code>Innings_No</code> – INT</li>
    </ul>
  </li>
</ul>

<p><em>Note:</em> Many more tables exist in the database. </p>


---
## 🎯 Objective :  
<ul>
  <li><strong>Recommend</strong> top-performing and consistent players across batting, bowling, and all-rounder roles</li>
  <li><strong>Identify</strong> budget-friendly players who provide maximum impact</li>
  <li><strong>Enable</strong> data-driven team selection using structured queries and filtered insights</li>
</ul>

---

## 🔍 Areas of Analysis :
<ul>
  <li><strong>Batting Performance</strong>
    <ul>
      <li>Metrics: Total Runs, Average, Strike Rate</li>
      <li>Filtered players with consistent scoring across seasons</li>
    </ul>
  </li>
  <li><strong>Bowling Performance</strong>
    <ul>
      <li>Metrics: Total Wickets, Bowling Average, Economy Rate, Strike Rate</li>
      <li>Identified wicket-taking and economical bowlers</li>
    </ul>
  </li>
  <li><strong>All-Rounder Impact</strong>
    <ul>
      <li>Combined runs and wickets to rank multi-skill players</li>
      <li>Focused on players who contribute significantly in both roles</li>
    </ul>
  </li>
  <li><strong>Value-for-Money Evaluation</strong>
    <ul>
      <li>Matched player salaries with performance metrics</li>
      <li>Highlighted cost-efficient and underrated players</li>
    </ul>
  </li>
  <li><strong>Player Consistency</strong>
    <ul>
      <li>Prioritized players with stable, multi-season performance</li>
      <li>Avoided one-match wonders and injury-prone picks</li>
    </ul>
  </li>
</ul>

---
## 📘 PDF Report for More Insights & Charts : <a href="https://github.com/roopsagnik/IPL-Strategy-for-RCB/blob/main/Sql%20Project%20Analysis.pdf"> PDF View </a>
---
## 🛠 Tools & Techniques Used

<ul>
  <li><strong>SQL (MySQL)</strong>
    <ul>
      <li>Queried a relational IPL database with 20+ interlinked tables</li>
      <li>Used <code>JOIN</code>s, <code>GROUP BY</code>, <code>HAVING</code>, subqueries, and aggregates</li>
      <li>Retrieved data related to matches, teams, players, scores, and wickets</li>
    </ul>
  </li>
  <li><strong>Excel / Google Sheets</strong>
    <ul>
      <li>Cleaned and formatted SQL outputs for easier interpretation</li>
      <li>Applied formulas: <code>SUMIFS</code>, <code>COUNTIFS</code>, <code>VLOOKUP</code>, <code>IF</code>, <code>AVERAGEIFS</code>, etc.</li>
      <li>Created structured tables to compare performance across roles</li>
    </ul>
  </li>
  <li><strong>Data Cleaning</strong>
    <ul>
      <li>Removed duplicates, handled nulls, standardized naming formats</li>
      <li>Ensured accurate joins and aggregation in SQL analysis</li>
    </ul>
  </li>
</ul>

