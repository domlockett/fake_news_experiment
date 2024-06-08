# Fake News Experiment

## Overall Aims of the Project

The Fake News Experiment is a comprehensive survey aimed at exploring the impacts of fake news on political participation and identifying effective strategies to prevent misperceptions. This multi-university project assesses how exposure to false information influences people's political attitudes and behaviors.

## Methods Employed

### - Data Collection and Analysis

#### `replication_materials/misinfo-review_public.rmd`
The `misinfo-review_public.rmd` file contains the RMarkdown script used for the analysis. This script details the steps taken to preprocess the data, perform statistical analyses, and generate visualizations. The primary methods include:

**Content and Structure:**
- **Data Preprocessing:** Data from the survey is cleaned and formatted for analysis. This involves handling missing values, normalizing text data, and creating relevant variables.
- **Statistical Analysis:** Various statistical techniques are applied to analyze the impact of fake news on political behavior. This includes regression analysis, hypothesis testing, and the use of control variables to isolate the effects of misinformation.
- **Visualization:** The script generates several plots to illustrate the findings. These visualizations help in understanding the data distribution, relationships between variables, and the overall impact of fake news.

**Detailed Breakdown:**
- **Data Preprocessing:**
  - **Loading Data:** The script uses `readr` and `dplyr` packages to load and manipulate data efficiently.
  - **Cleaning Data:** Missing values are handled using imputation methods, and text data is normalized using regular expressions to remove unwanted characters and convert text to lowercase.
  - **Variable Creation:** New variables are created to capture the key aspects of the survey, such as exposure to fake news and political participation metrics.

- **Statistical Analysis:**
  - **Regression Analysis:** Linear and logistic regression models are used to assess the relationship between exposure to fake news and political participation.
  - **Hypothesis Testing:** The script performs t-tests and ANOVA to compare means across different groups.
  - **Control Variables:** The analysis includes control variables such as age, gender, and education to account for potential confounding factors.

- **Visualization:**
  - **Histograms and Density Plots:** These plots show the distribution of key variables like fake news exposure and political engagement.
  - **Bar Charts:** Bar charts compare the prevalence of fake news across different demographics.
  - **Time Series Plots:** These plots illustrate trends in fake news exposure and political participation over time.
  - **Packages Used:** `ggplot2` is primarily used for creating detailed and informative visualizations.

### - Focused Analyses and Plots

## Acknowledgments

This project is a collaborative effort involving significant contributions from various scholars. The provided files and scripts reflect the extensive work done to understand and address the impacts of fake news on political behavior. The project was created for academic purposes and contains anonymized data to ensure privacy and confidentiality. The project was created for the Washington University in Saint Louis Political Science Department.

For further details, you can access the repository [here](https://github.com/domlockett/fake_news_experiment) and refer to the publication [here](https://misinforeview.hks.harvard.edu/article/fake-news-limited-effects-on-political-participation/).
