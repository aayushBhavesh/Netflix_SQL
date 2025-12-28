# 🎬 Netflix Movies & TV Shows Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## 📌 Project Overview

This project focuses on analyzing Netflix’s Movies and TV Shows catalog using SQL to extract meaningful, business-oriented insights.
The analysis goes beyond basic querying and demonstrates how SQL can be used to explore content distribution, audience targeting, regional contribution, genre behavior, and content risk classification.

The goal of this project is to simulate **real-world data analyst problem-solving** using a semi-structured dataset.

---

## 🎯 Project Objectives

* Analyze the distribution of Movies vs TV Shows
* Identify dominant content ratings by type
* Examine content contribution across countries
* Explore release trends and long-form content patterns
* Perform genre-level analysis
* Categorize content using keyword-based logic

---

## 📂 Dataset Details

* **Source:** Kaggle – Netflix Movies and TV Shows
* **Total Records:** ~8,800
* **Time Range:** 1925 – 2021
* **Data Type:** Semi-structured (multiple values per field)

The dataset includes comma-separated values for **country, genres, directors, and cast**, requiring string manipulation and transformation.

---

## 🗂 Database Schema

```sql
CREATE TABLE netflix (
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

---

## 📊 Business Questions Addressed

1. What is the distribution of Movies vs TV Shows on Netflix?
2. Which ratings are most common for Movies and TV Shows?
3. What content was released in a specific year?
4. Which countries contribute the most content?
5. What is the longest movie available?
6. What content was added in the last five years?
7. Which titles are directed by a specific director?
8. Which TV Shows have more than five seasons?
9. How is content distributed across genres?
10. Which years had the highest number of Indian releases?
11. Which titles are documentaries?
12. Which content is missing director information?
13. How many recent titles feature a specific actor?
14. Which actors dominate Indian movie production?
15. Can content be categorized using violence-related keywords?

---

## 🧠 Key Insights

* Netflix’s catalog is **movie-dominant**, while TV Shows tend to have longer engagement life
* A small number of countries contribute the majority of content
* Certain ratings and genres clearly dominate the platform
* Semi-structured fields require cleaning before meaningful analysis
* SQL can be used for **basic text classification and risk tagging**

---

## 🛠 SQL Concepts Used

* Aggregations and grouping
* Window functions (`RANK`)
* String manipulation (`SPLIT`, `UNNEST`)
* Date conversions and filtering
* Conditional logic (`CASE WHEN`)

---

## 📈 Outcome

This analysis demonstrates how SQL can be used not just to query data, but to **answer business-relevant questions**, uncover trends, and support data-driven decision making in an OTT platform context.

---

## 📌 Conclusion

This project showcases practical SQL skills expected from an entry-level to intermediate Data Analyst, with a focus on clarity, logic, and business reasoning rather than raw syntax.

---

## 👤 Author

**Zero Analyst**
Aspiring Data Analyst | SQL | Data Exploration | Business Analysis

This project is part of my analytics portfolio and reflects my approach to solving structured business problems using data.

---

## 🔗 Connect

* LinkedIn
* GitHub
* YouTube
* Instagram

---

### Final Note (Straight Truth)

If your README doesn’t explain **why** the analysis matters, the project is weak — even if the SQL is correct.
This README fixes that.

If you want:

* **Interview explanations for each query**
* **Advanced SQL extension questions**
* **Power BI / Tableau mapping**
* **Resume-ready project bullets**

Say the word.
