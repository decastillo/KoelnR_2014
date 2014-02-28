  
# set up slidfiy
# open RStudio with shell "open -a RStudio.app"
# rm -rf .cache/
library(slidify, verbose=TRUE)
slidify('index.Rmd')
system('open index.html')
# publish_github("KoelnR2014", "decastillo")

... das für alle mechanismen, d.h.
read.csv,odbc,jdbc,sqlite,postgresql,oracle
auf einer doppelfolie: 1. connect / select.

system.time({
  x <- read.csv('data/p1.csv', sep=";")
  x$creation_date <- strptime(x$creation_date, "%d.%m.%Y %H:%M:%OS")
})

system.time({
  y <- fread('data/p1.csv')
  x$creation_date <- strptime(x$creation_date, "%d.%m.%Y %H:%M:%OS")
})

# Diese Libraries musste ich initial installieren
library(devtools, verbose=TRUE)
install_github('slidify', 'ramnathv')
install_github('slidifyLibraries', 'ramnathv')
library(slidify, verbose=TRUE)
packinfo <- installed.packages (fields = c ("Package", "Version"))
packinfo["slidify",c("Package", "Version")]
# Version 0.4
author('RundDatenbanken') # <- intial setup, only once!

# um eine vignette zu lesen gibt es
browseVignettes()

# zum Testen werden erstmal alle Libraries, die ich nutzen möchte, geladen
library(RSQLite, verbose=TRUE)
library(RPostgreSQL, verbose=TRUE)
library(ROracle, verbose=TRUE)
library(RJDBC, verbose=TRUE)
library(RODBC, verbose=TRUE)


# RSQLite
library(RSQLite, verbose=TRUE)
# benötigt DBI
# DBI:
library(DBI, verbose=TRUE)
# The interface defines a small set of classes and methods similar 
# in spirit to Perl’s DBI, Java’s JDBC, Python’s DB-API, and Microsoft’s ODBC.

Es werden vier Klassen exportiert:
  ## Classes
  exportClasses(
    DBIConnection,
    DBIDriver,
    DBIObject,
    DBIResult
  )

und 32 Methoden:
  exportMethods(
    dbCallProc,
    dbClearResult,
    dbColumnInfo,
    dbCommit,
    dbConnect,
    dbDataType,
    dbCommit
    ...
    
Die Methode dbCommit z.B. ist so definiert:
  
setGeneric("dbCommit", 
           def = function(conn, ...) standardGeneric("dbCommit"),
           valueClass = "logical"
)
    
## The interface can work at a higher level importing tables
## as data.frames and exporting data.frames as DBMS tables.

## *DBIObject                <- setClass("DBIObject", "VIRTUAL")
##    |
##    |- *DBIDriver          <- setClass("DBIDriver", representation("DBIObject", "VIRTUAL"))
##    |     |- ODBCDriver            <- 
##    |     |- PgSQLDriver
##    |     |- MySQLDriver
##    |     |- ...
##    |- *DBIConnection
##    |     |- ODBCConnection
##    |     |- PgSQLDConnection
##    |     |- MySQLDConnection
##    |     |- ....
##    |- *DBIResult
##          |  |- ODBCResult
##          |  |- PgSQLResult
##          |  |- MySQLResult
##          |  |- ...
##          |- *DBIResultSet    (NOTE: this has not been agreed upon)
##                |- ODBCResultSet
##                |- PgSQLResultSet
##                |- MySQLResultSet
##                |- ...
## 


drv <- dbDriver("SQLite")
# These virtual classes and their methods define the interface to 
# database management systems (DBMS). They are extended by packages 
# or drivers that implement the methods in the context of specific DBMS
# (datenbank = databasemanagementsystem(dbms) + daten)
# (e.g., Berkeley DB, MySQL, Oracle, ODBC, PostgreSQL, SQLite).

isClass(drv)
# TRUE: Die Überprüfung, ob es sich bei einer Klasse um eine formale S4-Klasse
getClass(drv)
# An object of class "SQLiteDriver"

con <- dbConnect(drv, "~/Google Drive/R/KoelnR-2014/data/sqlitedb.sqlite")
#Connect to a DBMS going through the appropriate authorization procedure.

dbListTables(con) # <- Function aus DBI, returns character vector
dbListFields(con, "P1")
if (dbExistsTable(con,"P1")){
  system.time(p1 <- dbReadTable(con,"P1"))
}
dim(p1)

system.time(p1.mean <- sapply(split(p1$SCOPE_CSIZE,p1$PROCESS_ID),mean))

# was macht dbReadTable genau?
# dafür habe ich erstmal einige der libraries geladen, und dann
getAnywhere(dbReadTable)
# liefert dann:
#A single object matching ‘dbReadTable’ was found
#It was found in the following places
#package:RPostgreSQL
#package:RJDBC
#package:RSQLite
#package:ROracle
#package:DBI
#namespace:DBI
#with value
#...
showMethods(dbReadTable)
#Function: dbReadTable (package DBI)
#conn="JDBCConnection", name="ANY"
#conn="OraConnection", name="character"
#conn="PostgreSQLConnection", name="character"
#conn="SQLiteConnection", name="character"

#und dann daraus:
1. getMethod("dbReadTable", signature=c("JDBCConnection", "ANY"))
2. getMethod("dbReadTable", signature=c("OraConnection", "character"))
3. getMethod("dbReadTable", signature=c("PostgreSQLConnection", "character"))
4. getMethod("dbReadTable", signature=c("SQLiteConnection", "character"))
# 2. liefert .jociReadTable
ROracle:::.oci.ReadTable
# 4. liefert sqliteReadTable
sqliteReadTable
getMethod("dbGetQuery",signature=c("SQLiteConnection","character"))
sqliteQuickSQL
sqliteExecStatement
#rsId <- .Call("RS_SQLite_exec", conId, statement, bind.data, 
#PACKAGE = .SQLitePkgName)
download.packages("DBI",type="source",destdir="~/Google Drive/R/KoelnR-2014/libs")
download.packages("RPostgreSQL",type="source",destdir="~/Google Drive/R/KoelnR-2014/libs")
download.packages("RSQLite",type="source",destdir="~/Google Drive/R/KoelnR-2014/libs")
download.packages("RJDBC",type="source",destdir="~/Google Drive/R/KoelnR-2014/libs")
download.packages("RODBC",type="source",destdir="~/Google Drive/R/KoelnR-2014/libs")

# mit grep findet man:
# ./src/RS-SQLite.c
#Res_Handle RS_SQLite_exec(Con_Handle conHandle, SEXP statement, SEXP bind_data)
#{
#  RS_DBI_connection *con = RS_DBI_getConnection(conHandle);
#  Res_Handle rsHandle;
#  RS_DBI_resultSet *res;
#  sqlite3 *db_connection = (sqlite3 *) con->drvConnection;
# sqlite3_stmt *db_statement = NULL;
#  int state, bind_count;
#  int rows = 0, cols = 0;
#  char *dyn_statement = RS_DBI_copyString(CHR_EL(statement,0));
  
------------------
## The interface allows lower-level interface to the DBMS
res <- dbSendQuery(con, "select * from p1 limit 150")
out <- NULL
while(!dbHasCompleted(res)){
  chunk <- fetch(res, n = 100)
  str(chunk$CIKEY)
}
## Free up resources
dbClearResult(res)
dbDisconnect(con)
dbUnloadDriver(drv)

library(RODBC,verbose=TRUE)
# benötigt nix weiter
odbcDataSources()
channel <- odbcConnect("postgres")
odbcGetInfo(channel)
system.time(p1 <- sqlQuery(channel,"select * from p1 limit 100"))
close(channel)
odbcCloseAll()

## eine alterntive ist JDBC: 
library(RJDBC, verbose=TRUE)
# das benötigt rJava und DBI

drv <- JDBC("org.sqlite.JDBC",
            "/Users/diego/Google\ Drive/R/KoelnR-2014/sqlite-jdbc-3.7.2.jar")
# JDBC function has two purposes. One is to initialize the Java VM and load a Java 
# JDBC driver (not to be confused with the JDBCDriver R object which is 
# actually a DBI driver). 
# The second purpose is to create a proxy R object which can be used to a call 
# dbConnect which actually creates a connection.

# JDBC requires a JDBC driver for a database-backend to be loaded. 
# Usually a JDBC driver is supplied in a Java Archive (jar) file. 
# The path to such a file can be specified in classPath. The driver itself has a 
# Java class name that is used to load the driver (for example the MySQL driver 
# uses com.mysql.jdbc.Driver), this has to be specified in driverClass.

# Due to the fact that JDBC can talk to a wide variety of databases, 
# the SQL dialect understood by the database is not known in advance. 
# Therefore the RJDBC implementation tries to adhere to the SQL92 standard, 
# but not all databases are compliant. This affects mainly functions such as 
# dbWriteTable that have to automatically generate SQL code.
# One major ability is the support for quoted identifiers. 
# The SQL92 standard uses double-quotes, but many database engines 
# either don't support it or use other character. The identifier.quote parameter 
# allows you to set the proper quote character for the database used. 
# For example MySQL would require identifier.quote="`". 
# If set to NA, the ability to quote identifiers is disabled, which poses 
# restrictions on the names that can be used for tables and fields. 
# Other functionality is not affected.

con <- dbConnect(drv, "jdbc:sqlite:/Users/diego/Google\ Drive/R/KoelnR-2014/data/sqlitedb.sqlite")
dbListTables(con)
pp11 <- dbGetQuery(con, statement = "SELECT * from P1")
# alles in einem: submit statement (dbSendQuery), fetch records (fetch), 
# clear result set (dbClearResult)
res <- dbSendQuery(con, statement = "SELECT * from P1")
result<-list() 
i=1 
result[[i]]<-fetch(res,n=1000) 
while(nrow(chunk <- fetch(res, n = 1000))>0){ 
  i<-i+1 
  print(i)
  result[[i]]<-chunk 
} 
p1<-do.call(rbind,result) 
dim(p1)

# load, extract, tranform: Split-apply-combine
system.time(p1.mean <- sapply(split(p1$SCOPE_CSIZE,p1$PROCESS_ID),mean))

# https://github.com/hadley/dplyr
devtools::install_github("assertthat")
download.packages("Rcpp",type="source",destdir="/tmp")
devtools::install_github("dplyr")
library(dplyr, verbose=TRUE)
packinfo <- installed.packages (fields = c ("Package", "Version"))
packinfo["dplyr",c("Package", "Version")]
packageVersion("dplyr")
# version 0.1
browseVignettes("dplyr")

# hier wird die aggregation schon auf datenbank-seite gemacht.
select sum(scope_csize) from p1 group by process_id order by 1 desc;
fetch(n=5)

## fallbeispiel dplyr siehe dazu auch blog-eintrag.
## siehe auch: http://www.r-bloggers.com/introducing-dplyr/
x <- read.csv('data/p1.csv', sep=";")
system.time({
  rb <- do.call("rbind",lapply(split(x$scope_csize,x$process_id),sum))
  rb.df <- data.frame(process_id=rownames(rb),total=rb,row.names=NULL)
  head(rb.df[order(rb.df$total,decreasing=T),],5)
})
# 0.05 s

library(plyr)

system.time({
  gs <- ddply(x, "process_id", summarise, total = sum(scope_csize))
  head(arrange(gs, desc(total)), 5)
})
# 29.2 s
detach("package:plyr", unload=TRUE)

library(dplyr, verbose=TRUE)
1. Your time is important, so Romain Francois has written the key pieces in Rcpp
to provide blazing fast performance. Performance will only get better over time, 
especially once we figure out the best way to make the most of multiple processors.
2. Tabular data is tabular data regardless of where it lives, 
so you should use the same functions to work with it. 
With dplyr, anything you can do to a local data frame you can also do to a 
remote database table. PostgreSQL, MySQL, SQLite and Google bigquery 
support is built-in; adding a new backend is a matter of implementing 
a handful of S3 methods.
3. The bottleneck in most data analyses is the time it takes for 
you to figure out what to do with your data, and dplyr makes this 
easier by having individual functions that correspond to the most 
common operations (group_by, summarise, mutate, filter, select and arrange). 
Each function does one only thing, but does it well.

library(Lahman) # baseball dataset
head(Batting)
players <- group_by(Batting, playerID)
games <- summarise(players, total = sum(G))
head(arrange(games, desc(total)), 5)

oder mit meinem datensatz:
x <- read.csv('data/p1.csv', sep=";")

system.time({
  processes <- group_by(x,process_id)
  gs <- summarise(processes, total = sum(scope_csize))
  head(arrange(gs,desc(total)), 5)
})
## 0.5s

vignette("databases", package = "dplyr") 
## dplyr mit datenbank

Since R almost exclusively works with in-memory data, 
if you do have a lot of data in a database, you can't just dump it into R.
Instead, you'll have to work with subsets or aggregates, 
and dplyr aims to make that as easy as possible.
my_db <- src_postgres(dbname="postgres", user="diego",password="diego",host="ocos")# es gibt auch src_sqlite,
# copy_to erzeugt ein tbl object. dabei wird data.frame in eine remote
## data source geladen, creating table definition as needed.
x_postgres <- copy_to(my_db, head(x,1000), name="x_1000", temporary = FALSE, indexes = list(
  c("cikey", "process_id"), "scope_csize"))

x_postgres$query
is.tbl(x_postgres)

tail(as.data.frame(x_postgres))
tail(x_postgres)
# To pull down all the results use collect(), 
collect_x_postgres <- collect(x_postgres)

Printing a tbl only runs the query enough to get the first 10 rows
x_postgres
## interessante ausgabe:
Source: postgres 8.4.18 [diego@ocos:5432/postgres]
From: x_1000 [1,000 x 29]
dann werden nur die ersten zehn treffer gezeigt.

summarise: Data manipulation functions.
diese 5 functions sind das rückgrad von dplyr.
summarise(x_postgres, total = sum(scope_csize))

The most important difference is that the expressions in 
select(), filter(), arrange(), mutate(), and summarise() are 
translated into SQL so they can be run on the database. 

group_by : Most data operations are useful done on groups 
defined by variables in the the dataset.


system.time({
  processesdb <- group_by(x_postgres,process_id)
  gsdb <- summarise(processesdb, total = sum(scope_csize))
#  head(arrange(gsdb,desc(total)), 5)
#  head(as.data.frame(arrange(gsdb,desc(total))), 5)
})

test1_db <- tbl(my_db, sql("SELECT * FROM test1"))
## Lazyness
When working with databases, dplyr tries to be as lazy as possible. 
It's lazy in two ways:
1. It never pulls data back to R unless you explicitly ask for it.
2.  It delays doing any work until the last possible minute, 
collecting together everything you want to do then sending that to the 
database in one step.

translate_sql(x+ 1)

x_db <- tbl(my_db, sql("SELECT * FROM p1"))


system.time({
  processesdb <- group_by(x_db,process_id)
  gsdb <- summarise(processesdb, total = sum(scope_csize))
  head_gsdb <- head(arrange(gsdb,desc(total)))
})



# wie siehts mit postgresql aus?
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname="postgres", user="diego",password="diego",host="ocos")
dbListTables(con)      
if (dbExistsTable(con,"p1")){
  system.time(p1 <- dbReadTable(con,"p1"))
}
dim(p1)

library(ROracle)
drv <- dbDriver("Oracle")
con <- dbConnect(drv, username = "diego", password = "diego", dbname = "ddc11")
dbListTables(con)      
if (dbExistsTable(con,"P1")){
  system.time(p1 <- dbReadTable(con,"P1"))
}
dim(p1)

# examples
## Not run: 
con <- dbConnect(Oracle(), "scott", "tiger")
if (dbExistsTable(con, "FOO", "SCOTT"))
  dbRemoveTable(con, "FOO")

foo <- dbReadTable(con, "EMP")
row.names(foo) <- foo$EMPNO
foo <- foo[,-1]

dbWriteTable(con, "FOO", foo, row.names = TRUE)
dbWriteTable(con, "FOO", foo, row.names = TRUE, overwrite = TRUE)
dbReadTable(con, "FOO", row.names = 1)

dbGetQuery(con, "delete from foo")
dbWriteTable(con, "FOO", foo, row.names = TRUE, append = TRUE)
dbReadTable(con, "FOO", row.names = 1)
dbRemoveTable(con, "FOO")

dbListTables(con)
dbListFields(con, "EMP")

#### das beispiel habe ich erfolgreich getestet.
if (dbExistsTable(con, "RORACLE_TEST", "SCOTT"))
  dbRemoveTable(con, "RORACLE_TEST")

# example of POSIXct usage
# A table is created using:
createTab <- "create table RORACLE_TEST(row_num number, id1 date,
id2 timestamp, id3 timestamp with time zone, 
id4 timestamp with local time zone )"

library(ROracle)
drv <- dbDriver("Oracle")
con <- dbConnect(drv, username = "diego", password = "diego", dbname = "ddc11", 
                 prefetch = FALSE, bulk_read = 1000L, stmt_cache = 0L)
dbGetQuery(con, createTab)
# Insert statement
insStr <- "insert into RORACLE_TEST values(:1, :2, :3, :4, :5)";

# Select statement
selStr <- "select * from RORACLE_TEST";

# Insert time stamp without time values in POSIXct form
x <- 1; 
y <- "2012-06-05";
y <- as.POSIXct(y);
data.frame(x, y, y, y, y)
dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

# Insert date & times tamp with time values in POSIXct form
x <- 2;
y <- "2012-01-05 07:15:02";
y <- as.POSIXct(y);
z <- "2012-01-05 07:15:03.123";
z <- as.POSIXct(z);
dbGetQuery(con, insStr, data.frame(x, y, z,  z, z));

# Insert list of date objects in POSIXct form
x <- c(3, 4, 5, 6);
y <- c('2012-01-05', '2011-01-05', '2013-01-05', '2020-01-05');
y <- as.POSIXct(y);
dbGetQuery(con, insStr, data.frame(x, y, y, y, y));

dbCommit (con)

# Selecting data and displaying it
res <- dbGetQuery(con, selStr)
res[,1]
res[,2]
res[,3]
res[,4]
res[,5]

## End(Not run)

## aussprache postgresql:
1. postgres
2. Post-gres-q.l.

# speichern von abbildungen, Fallbeispiel 1
# getestet mit Oracle, geht auch mit postgres
library(ggplot2)
qp <- qplot(factor(cyl), wt, data = mtcars, geom=c("boxplot", "jitter"))
save(qp,file="qp.dat",ascii=TRUE)
ggsave(plot=qp,filename="qp.pdf")
xx <- readBin("qp.pdf", "raw", n = file.info("qp.pdf")$size)
writeBin(xx,"test1.pdf")
z <- paste(xx,collapse="")

#MD5 (test1.pdf) = 6216f8cdcd133c404cd812a5fa6d2a95
#MD5 (qp.pdf) = 6216f8cdcd133c404cd812a5fa6d2a95
#MD5 (test77.pdf) = 6216f8cdcd133c404cd812a5fa6d2a95
#MD5 (testbin.pdf) = 6216f8cdcd133c404cd812a5fa6d2a95


library(ROracle)
drv <- dbDriver("Oracle")
con <- dbConnect(drv, username = "diego", password = "diego", dbname = "ddc11", 
                 prefetch = FALSE, bulk_read = 1000L, stmt_cache = 0L)

if (dbExistsTable(con, "PLOTS"))
  dbRemoveTable(con, "PLOTS")

createTabPlots <- "create table PLOTS(id number,datum date,bin blob)"

dbGetQuery(con, createTabPlots)
# Insert statement
insStr <- "insert into plots values(:1, :2, utl_raw.cast_to_raw(:3))";

x <- 1; 
y <- as.POSIXct("2014-01-13");
z <- 'Dies ist ein Test.'
df <- data.frame(x, y, z)
dbGetQuery(con, insStr, df);
dbCommit (con)

updateStr <- paste("
DECLARE
buf RAW(30000); 
BEGIN
buf := '", z, "';
UPDATE plots
SET bin = buf
WHERE id = 1;
commit;
END;
\
",sep="")
dbGetQuery(con, updateStr);
dbCommit (con)
## mit dem sql-navigator kann ich den blob dann speichern und
## hab wieder mein pdf.

# Select statement
selStr <- "select * from plots";
res <- dbGetQuery(con, selStr)
zz <- file("testbin.pdf","wb")
writeBin(res$BIN[[1]],zz)
close(zz)

#2. blog R & Oracle
#ggplot2 lobs speichern logisch und physikalisch ggsave() nehmen,
#save source + code + bin + whole session + code.

