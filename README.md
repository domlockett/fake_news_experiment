# Fake News Experiment

## Overall Aims of the Project

The Fake News Experiment is a comprehensive survey aimed at exploring the impacts of fake news on political participation and identifying effective strategies to prevent misperceptions. This multi-university project assesses how exposure to false information influences people's political attitudes and behaviors.

## Methods Employed

### - Data Collection and Analysis

#### `replication_materials/misinfo-review_public.rmd`
The `misinfo-review_public.rmd` file contains the RMarkdown script used for analysis. This script details the steps taken to load data, perform statistical analyses, and generate visualizations. The primary methods include:

**Content and Structure:**
- **Data Loading:** Data from the survey is loaded for analysis using the `readr` and `dplyr` packages.
- **Statistical Analysis:** Various statistical techniques are applied to analyze the impact of fake news on political behavior, including regression analysis and group comparisons. 
- **Visualization:** The script generates several plots to illustrate the findings, helping to understand the data distribution, relationships between variables, and the overall impact of fake news.

**Detailed Breakdown:**
- **Data Loading:**
  - Utilizes `readr` for reading CSV files and `dplyr` for data manipulation.
  
- **Data Cleaning:**
  - Filtering out rows with missing values in key columns.

- **Statistical Analysis:**
  - Linear regression models are used to assess the relationship between exposure to fake news and political participation.

- **Visualization:**
  - Histograms and density plots display the distribution of fake news exposure.
  - Bar charts compare prevalence across demographics.
  - Time series plots illustrate trends in fake news exposure over time.

Refer to the [publication](https://misinforeview.hks.harvard.edu/article/fake-news-limited-effects-on-political-participation/) for a comprehensive analysis.

### - Focused Analyses and Plots

The focused analyses involve deeper dives into specific aspects of the survey data, highlighting the impact of fake news and the effectiveness of fact-checking interventions.

- **Figure 4a: Impact of Fake News Exposure on Political Polarization**
  This plot demonstrates how exposure to fake news correlates with increased political polarization. It illustrates that individuals exposed to more fake news tend to have more polarized political views.

  ![Impact of Fake News Exposure](https://github.com/domlockett/fake_news_experiment/blob/main/images/fn_impact_polarization.png)
  
- **Figure 4b: Effectiveness of Fact-Checking Interventions**
  This plot shows the effectiveness of fact-checking interventions in reducing the belief in fake news. It indicates that fact-checking can significantly decrease the acceptance of false information.

  ![Effectiveness of Fact-Checking](https://github.com/domlockett/fake_news_experiment/blob/main/images/fn_impact_exposure.png)
  

By leveraging detailed statistical analyses and visualizations, the Fake News Experiment provides valuable insights into the mechanisms by which fake news influences political participation and the effectiveness of various strategies to mitigate these effects.

## Acknowledgments

This project is a collaborative effort involving significant contributions from various scholars. The provided files and scripts reflect the extensive work done to understand and address the impacts of fake news on political behavior. The project was created for academic purposes and contains anonymized data to ensure privacy and confidentiality.

For further details, you can access the repository [here](https://github.com/domlockett/fake_news_experiment) and refer to the publication [here](https://misinforeview.hks.harvard.edu/article/fake-news-limited-effects-on-political-participation/).

