FROM rocker/rstudio:latest

# Mettre à jour et installer les dépendances nécessaires pour ODBC et MariaDB (compatible MySQL)
RUN apt-get update && apt-get install -y libmysqlclient-dev


# Installer les packages R nécessaires
RUN R -e "install.packages('shiny')"
RUN R -e "install.packages('httr')"
RUN R -e "install.packages('jsonlite')"
RUN R -e "install.packages('DBI')"
RUN R -e "install.packages('RMariaDB')"
RUN R -e "install.packages('DT')"
RUN R -e "install.packages('ggplot2')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('leaflet')"
RUN R -e "install.packages('lubridate')"
RUN R -e "install.packages('tidyr')"

EXPOSE 8787

CMD ["/init"]
