## Read Me

### Scraping data on personal health products from Mercadona and Clarel to determine price differences between male and non-male marketed products

### 1.  Project description

This assignment aims to investigate price differences in personal care products in Spain. More specifically, are male personal care products priced differently compared to non-male products? To obtain the data needed for this analysis, data on personal health care products is scraped from the website of Mercadona and Clarel, a large Spanish supermarket and drugstore chain respectively. Then, mean comparisons are performed to determine any price differences between male and non-male products for different types of personal health products.

### 2.  Table of contents

    1.  Introduction
    2.  Libraries
    3.  Mercadona
        1.  Setting up RSelenium
        2.  Obtaining URLs
        3.  Scraping and cleaning data
        4.  Extracting brand names
        5.  Standardising prices
        6.  Assigning marketed gender to product
    4.  Clarel
        1.  Data collection
            1.  Main webpage
            2.  Scrape Hombre Category
            3.  Scrape Multiple Categories
        2.  Data cleaning
    5.  Data joining
    6.  Data balancing
    7.  Mean comparisons
    8.  Discussion and conclusion

### 3.  Technologies used

 The coding language used to create this project is R.

### 4.  Requirements

 To run the code in this project one needs to have installed the follwoing packages in R:

 -   [Tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html): Ecosystem of Packages designed for data science in R (glue, purrr)
  -   [xml2:](https://cran.r-project.org/web/packages/xml2/index.html) R package to handle xml files
 -   [RSelenium](https://cran.r-project.org/web/packages/RSelenium/index.html): R package providing bindings for the 'Selenium 2.0 WebDriver'. This package allows navigating a website using a driver immitating a regular user. Trough this navigation, one is able to collect html code from websites which would otherwise be hidden.
-   [httr:](https://cran.r-project.org/web/packages/httr/index.html) Package including tools for working with URLs and HTTP
-   [ROSE:](https://cran.r-project.org/web/packages/ROSE/index.html) *Random Over-Sampling Examples.* This package contains tools to apply a combination of under- and over-sampling techniques to balance unbalanced data sets
-   [Broom:](https://cran.r-project.org/web/packages/broom/index.html) Package to convert statistical sbjects into tidy tibbles
-   [Glue:] (https://cran.r-project.org/web/packages/glue/index.html). Package providing tools for easy and efficient string interpolation

All packages used in this assignment can be downloaded into R using the function install.packages(). For example:

  ```{r}
 install.packages("tidyverse")
 ```

 To use the package RSelenium, JAVA needs to be downloaded on the used device and correctly attached to the R. This can be done using the following code

 ```{r}
Sys.getenv("JAVA_HOME")
Sys.setenv(JAVA_HOME = "path/Oracle/Java/javapath/java.exe")
Sys.getenv("PATH")
install.packages("RSelenium", dependencies = TRUE)
```

 To scrape websites ethically, one needs to set a configuration to indicate who is scraping the website and allow the owners of the website to contact the scraper in case the scraper is causing any issues to the website. Therefore, before running the code, one needs to fill in the user agent in the following piece of code. One can obtain the user agent by simply asking the google search engine 'What is my user agent?'
 
 ```{r}
set_config(
 user_agent(""))
 ```

Note that when setting the rsdriver, one might needs to make some adjustments to the code. If the port is occupied, simply insert a different number and change the browser to the browser installed in the device used to run the code. In the developers case of this project, the browser 'Chrome' did not function well. Therefore, consider [downloading the browser Firefox](https://www.mozilla.org/en-US/firefox/new/) in case Chrome does not perform well.
```{r}
remDr <- rsDriver(port = 4467L, browser = "firefox",  verbose=F, chromever = NULL)
```
