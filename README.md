# Introduction
This analysis is conducted on a Mexican E-commerce store called Maven Toys and uses SQL and Tableau for querying the data and visualisation, respectively. The purpose of this is to extract insights that can shed light on current business performance and better inform future business decisions. These may range from learning about things such as which store to promote, which products tend to perform better in some months compared to others, whether or not money tied up in inventory could be managed better and more.

An easy-to-read version of this with all queries, visualisations and interpretations can be found [here](https://bit.ly/3z9HeNN)

A dashboard can be [found](https://github.com/Taimur-Shabbir/SQL-Ecommerce-Analysis/blob/main/Maven%20Toys%20Dashboard.png) in this repository

# Data

## Data Source:

The data is obtained from [Kaggle](https://www.kaggle.com/datasets/mysarahmadbhat/toy-sales?select=stores.csv)

## Tables and Observations

There are 4 tables:

1. sales_toys: contains sales information - 829262 rows
2. products: contains information on products - 35 rows
3. stores: contains information on stores -  50 rows
4. inventory: contains inventory information - 1593 rows

The date range for 'sales_toys' is from 2017-01-01 to 2018-09-30. There are no dates in any of the other tables.

## Columns:

The following shows the table, the number of columns it has and a few of the column names

- sales_toys: 5 columns - Date, Store_ID, Product_ID, Units
- products: 5 columns - Product_Name, Product_Category, Product_Price
- stores: 5 columns - Store_Name, Store_City, Store_Open_Date
- inventory: 3 columns - Store_ID, Product_ID, Stock_On_Hand

# Analysis

A few questions this analysis aims to answer are:

- Which products and product categories are most profitable?
- Is there any relationship between value of stock tied up and revenue by store?
- Do high margin products make more profit or do low margin ones do so?
- Do certain products categories perform better (as measured by profit) in different stores? Or are the same product categories most profitable across all stores, generally speaking?
- Is there a seasonality aspect to sales? If so, what is the magnitude of it?
- Are older stores able to incorporate e-commerce technology as well as their newer counterparts, or is there a possible problem of digitisation?
- In which cities is Maven Toys most successful?

