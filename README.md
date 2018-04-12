# Download film scripts from Springfield Springfield
R codes for downloading all dialogue scripts from the famous site Springfield! Springfield! (https://www.springfieldspringfield.co.uk/)

## Before you download the code
This script relies on several packages: `rvest`, `data.table`, `stringr`, and `stringi`. Use `install.packages()` to install them if you haven't had them ready. 

The work flow of this script is simple. Since all scripts are listed in an alphabetical manner (plus 0 at the very beginning, see this https://www.springfieldspringfield.co.uk/movie_scripts.php), this script will first fetch the number of webpages of scripts starting with a certain letter (0 and A-Z). Then it will retrieve all titles and title links based on the page information. Title links will be used to fetch the scripts. The scripts will be fetched and saved in a designated local disk (as `.txt`) as a result. Along with the `.txt` a `.csv` file summarizing the files will also be created.

## When you use it
1. Set up your working directory (where you store the scripts) first.
```
setwd("F:/your/lucky/directory")
```
2. Run the codes. The first step (fetching maximum page) is going to spend you less than one minute; the second step (fetching titles and title links) will take more time (roughly 10 minutes); the last step (downloading scripts) will take your several hours. The time needed varies in differnt settings.

3. Sometimes the function will return this error:
> Error in open.connection(x, “rb”) : Timeout was reached

This error happens when the website can not be openned. Hence segmenting the fetching process is recommended. This could be achieved by using the following line repeatly (around Line 92) until you reach the end of `title_info`.
```
sapply(title_info[1:1000], get_script) #fetch the first 1000 scripts
```
