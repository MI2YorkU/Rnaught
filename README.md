
<!-- README.md is generated from README.Rmd. Please edit that file. -->

# Rnaught <a href="https://MI2YorkU.github.io/Rnaught"><img src="man/figures/logo.svg" align="right" height="139" alt="Rnaught Logo"></a>

Rnaught is an R package and web application for estimating the [basic
reproduction number
(*R*<sub>0</sub>)](https://en.wikipedia.org/wiki/Basic_reproduction_number)
of infectious diseases.

Currently, this estimation can be done in the web application via four different methods: 
White and Panago (WP), sequential Bayes (seqB), incidence decay (ID), and incidence decay and exponential adjustment (IDEA).

Datasets can be uploaded as a .csv file, or can be entered manually into the application.
The data is visualized in the application through plots that show the case counts (either weekly or daily).
If multiple datasets are uploaded/manually entered, the trends corresponding to these datasets are populated in the same plot and can be compared.
This plot can be exported as a .png file.
Further, the dataset entered can be exported into a .csv file.
Two sample datasets are included: weekly Canadian COVID-19 case count data from March 3rd, 2020 to March 31st, 2020, and weekly Ontario COVID-19 case count data from March 3rd, 2020 to March 31st, 2020.

To estimate the basic reproductive number, the user can choose their preferred estimator, and if applicable, must enter the known serial interval prior to estimation.
If multiple estimates of the basic reproductive number are calculated, they are all included in a table where each row represents an estimate.
If multiple datasets are being considered, the basic reproductive number is estimated for all datasets and the columns of the table correspond to the different datasets uploaded into the application.
The table also consists of a column corresponding to the value of the serial interval. 
This table can be exported as a .csv file. 

In progress...
