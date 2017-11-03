# Command to check last log:
# sudo cd /var/log/shiny-server
# sudo cat "$(ls -rt | tail -n1)"

# ---- Install R ----
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list';
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9;
gpg -a --export E084DAB9 | sudo apt-key add -;
sudo apt-get update;

# ---- Install R packages ----
sudo su - -c "R -e \"install.packages('shiny', repos = 'http://cran.rstudio.com/')\"";
sudo su - -c "R -e \"install.packages('shinydashboard', repos = 'http://cran.rstudio.com/')\"";
sudo su - -c "R -e \"install.packages('data.table', repos = 'http://cran.rstudio.com/')\"" &
sudo su - -c "R -e \"install.packages('plotly', repos = 'http://cran.rstudio.com/')\"" &
sudo su - -c "R -e \"install.packages('DT', repos = 'http://cran.rstudio.com/')\"" &
sudo su - -c "R -e \"install.packages('rmarkdown', repos = 'http://cran.rstudio.com/')\"" &
sudo su - -c "R -e \"install.packages('ini', repos='http://cran.rstudio.com/')\"" &
sudo su - -c "R -e \"install.packages('RPostgreSQL', repos='http://cran.rstudio.com/')\"" &
sudo su - -c "R -e \"install.packages('leaflet', repos='http://cran.rstudio.com/')\"" &
sudo su - -c "R -e \"install.packages('rhandsontable', repos='http://cran.rstudio.com/')\""

# ---- Install R Shiny Server ----
sudo apt-get install -y --force-yes gdebi-core;
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.5.5.872-amd64.deb;
sudo gdebi shiny-server-1.5.5.872-amd64.deb;
sudo rm shiny-server-1.5.5.872-amd64.deb;
