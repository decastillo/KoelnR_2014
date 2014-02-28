---
title       : R und Datenbanken
subtitle    : sqlite, postgresql und oracle
author      : Diego de Castillo
job         : Oracle DBA, IT Data Management, NetCologne
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
github      :
  user: decastillo
  repo: KoelnR2014
---


<!--
ich arbeite als Oracle DBA, d.h. Datenbank-Administrator.
hier werde ich aber nicht nur über oracle-datenbanken sprechen, sondern auch
über sqlite und postgresql sowie generische Datenbank-Verbindungen wie JDBC und OdBC. 
Es geht also hier meistens
um relationale Datenbanken. Diese weisen üblicherweise eine bestimmte Datenstruktur
und Vorhaltung auf.

Neben der reinen Verbindung und Abholung der Daten möchte ich auch auf
Performance und die ausführungsdauer von verschiedenen methoden eingehen.
und wie die man Split-apply-combine-Ansätze, die Bernd bei seinem letzten
Vortrag vorgestellt hat, einbinden kann. Das wird notwendig wenn man die
Daten in der datenbank hat oder sie wegen der größe der daten nicht am stück
in den arbeitsspeicher laden kann.

Die Folien sind mit slidify erzeugt, das ist ein R-Package zur Erzeugung
von html5 Präsentationen aus einfachen Markdown-Dateien mit R Markdown (knitr) mit eingebettetem
R-Code. Wir werden heute also recht viel R-Code in meinem Vortrag zu sehen bekommen.

zu indizierung: Nadel im Heuhaufen finden, darin sind Datenbanken gut 
ohne medienbruch: daten da abholen, wo sie eh vorliegen.
In relationalen Datenbanken versteht man unter Konsistenz die Integrität von Daten.
-->
## Warum überhaupt Datenbanken?

> - DBs sind typenkonform; Number, Character, Date, BLOB u.v.m.
> - Indizierter Zugriff auf selektive Daten
> - kein Medienbruch
> - Unterstützt parallele zeitgleiche Zugriffe (Mehrbenutzerzugriffe)
> - Konsistenzsicherheit / Datenintegrität
> - Vereinfachtes Verknüpfen von Daten  (Joins)

---
## Beispielsdatensatz : utils und data.table
  

```r
system.time({
    df <- read.csv("data/p1.csv", sep = ";")
})
```

```
##    user  system elapsed 
## 177.662   2.764 181.012
```

```r
system.time({
    df2 <- fread("data/p1.csv")
})
```

```
##    user  system elapsed 
##   4.519   0.274   5.747
```


---
## Beispielsdatensatz : Mengengerüst


```r
dim(df)
```

```
## [1] 1000000      29
```

```r
paste(round(file.info("data/p1.csv")$size/1024/1024), "Mb")
```

```
## [1] "306 Mb"
```

```r
print(object.size(df), units = "auto")
```

```
## 408.8 Mb
```


---
<!--
 hier sieht man die nachteile bei fehlendem typen-konzept und medienbruch.
 In der CSV-Datei steht in der Spalte revision_tag ...;"SiebelUpdateFlow";"1.0";... 
-->
## Beispielsdatensatz : nicht typenkonform


```r
str(df$revision_tag)
str(df2$revision_tag)
```

```
##  num [1:1000000] 1 1 1 1 1 1 1 1 1 1 ...
```

```
##  chr [1:1000000] "1.0" "1.0" "1.0" "1.0" "1.0" "1.0" ...
```


<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Tue Feb 25 20:28:54 2014 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> cikey </TH> <TH> process_id </TH> <TH> status </TH> <TH> root_id </TH> <TH> modify_date </TH> <TH> revision_tag </TH>  </TR>
  <TR> <TD align="right"> 1 </TD> <TD align="right"> 124640243 </TD> <TD> ExternalActivityFlow </TD> <TD> Scope_FindOrder </TD> <TD align="right"> 124640242 </TD> <TD> 01.09.2013 00:01:36,228000 </TD> <TD align="right"> 1.00 </TD> </TR>
  <TR> <TD align="right"> 2 </TD> <TD align="right"> 124640256 </TD> <TD> SiebelUpdateFlow </TD> <TD> Update </TD> <TD align="right"> 124640105 </TD> <TD> 01.09.2013 00:02:10,070000 </TD> <TD align="right"> 1.00 </TD> </TR>
  <TR> <TD align="right"> 3 </TD> <TD align="right"> 124640269 </TD> <TD> SiebelActivityFlow </TD> <TD> initiated </TD> <TD align="right"> 124640257 </TD> <TD> 01.09.2013 00:20:41,144000 </TD> <TD align="right"> 1.00 </TD> </TR>
   </TABLE>


---
<!--
 Datenbanken sehr weit gefasster Begriff.
 ist nicht cutting edge, aber immer noch mit Berechtigung dabei,
 je nach Anforderungen.

Außerdem gibt es generische Datenbankzugriffe über odbc und jdbc

 odbc ist ohne dbi, der rest schon.
 DBI ist S4-Klasse für vereinheitlichten Zugriff:
-->
## Also nehmen wir Datenbanken!

Mit Datenbanken sind hier relationale Datenbanksysteme gemeint. Hier betrachten wir:

- Oracle
- PostgreSQL
- SQLite

Generische Pakete, die für viele Datenbank-Typen passen, sind:

- ODBC
- JDBC

Für einen vereinheitlichten Zugriff dient S4-Bibliothek:

- DBI 

---
<!--
 The interface defines a small set of classes and methods similar 
 in spirit to Perl’s DBI, Java’s JDBC, Python’s DB-API, and Microsoft’s ODBC.
-->
## DBI : library(DBI)

DBI ist eine generische S4-Bibliothek. Die Klassen und Methoden, die
zur Verfügung stehen, können von einer Vielzahl von Datenbanksystemen genutzt werden.

Klassen: 

- DBIConnection
- DBIDriver
- DBIObject
- DBIResult   

Methoden: 

- dbColumnInfo
- dbCommit
- dbConnect
- dbSendQuery
- ...

---
## Der erste Datenbankzugriff

Dieser erfolgt bei einem lesenden Zugriff in 4 Schritten:

> 1. Laden und Initialisieren der zugehörigen Treiber: dbDriver()
> 2. Die Verbindung herstellen: dbConnect()
> 3. Die Anfrage senden: dbSendQuery(con, "select * from p1")
> 4. Die Daten holen: fetch(rs)

---
## Oracle : library(ROracle)
    

```r
library(ROracle)
# laden und initialisieren
drv <- dbDriver("Oracle")
# verbindung herstellen: con
con <- dbConnect(drv, username = "diego", password = "diego", dbname = "ddc11")
# anfrage senden, resultset: rs
rs <- dbSendQuery(con, "select * from p1")
# alle daten holen
system.time({
    data <- fetch(rs, n = -1)
})
```

```
##    user  system elapsed 
##  27.322   4.912  58.288
```





---
<!--
Was ist jetzt aus unserem bspdatensatz geworden?
In Tabelle so definiert <pre>"REVISION_TAG" VARCHAR2(50 BYTE)</pre>.
-->
## Beispielsdatensatz : aus Datenbank-Tabelle


```r
dim(data)
str(data$REVISION_TAG)
```

```
## [1] 1000000      29
```

```
##  chr [1:1000000] "1.0" "1.0" "1.0" "1.0" "1.0" "1.0" ...
```


<!-- html table generated in R 3.0.2 by xtable 1.7-1 package -->
<!-- Tue Feb 25 20:30:27 2014 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> CIKEY </TH> <TH> PROCESS_ID </TH> <TH> STATUS </TH> <TH> ROOT_ID </TH> <TH> REVISION_TAG </TH>  </TR>
  <TR> <TD align="right"> 1 </TD> <TD align="right"> 124640243.00 </TD> <TD> ExternalActivityFlow </TD> <TD> Scope_FindOrder </TD> <TD> 124640242 </TD> <TD> 1.0 </TD> </TR>
  <TR> <TD align="right"> 2 </TD> <TD align="right"> 124640256.00 </TD> <TD> SiebelUpdateFlow </TD> <TD> Update </TD> <TD> 124640105 </TD> <TD> 1.0 </TD> </TR>
  <TR> <TD align="right"> 3 </TD> <TD align="right"> 124640269.00 </TD> <TD> SiebelActivityFlow </TD> <TD> initiated </TD> <TD> 124640257 </TD> <TD> 1.0 </TD> </TR>
   </TABLE>


---
<!--
dbDriver:
These virtual classes and their methods define the interface to 
database management systems (DBMS). They are extended by packages 
or drivers that implement the methods in the context of specific DBMS
(datenbank = databasemanagementsystem(dbms) + daten)
(e.g., Berkeley DB, MySQL, Oracle, ODBC, PostgreSQL, SQLite).

dbconnect:
Connect to a DBMS going through the appropriate authorization procedure.
-->
## PostgreSQL : library(RPostgreSQL)
    

```r
library(RPostgreSQL)
drv <- dbDriver("PostgreSQL")
# connect DBMS mittels passendem Berechtigungsverfahren
con <- dbConnect(drv, dbname = "postgres", user = "diego", password = "diego", 
    host = "ocos")
rs <- dbSendQuery(con, "select * from P1")
system.time({
    data <- fetch(rs, n = -1)
})
```

```
##    user  system elapsed 
##  190.69   36.82  237.09
```





---
## SQLite : library(RSQLite)
    

```r
library(RSQLite)
drv <- dbDriver("SQLite")
con <- dbConnect(drv, "~/Google Drive/R/KoelnR-2014/data/sqlitedb.sqlite")
rs <- dbSendQuery(con, "select * from P1")
system.time({
    data <- fetch(rs, n = -1)
})
```

```
##    user  system elapsed 
##   12.41    3.07   17.42
```




---
<!--
JDBC function has two purposes. One is to initialize the Java VM and load a Java 
JDBC driver (not to be confused with the JDBCDriver R object which is 
actually a DBI driver). 
The second purpose is to create a proxy R object which can be used to a call 
dbConnect which actually creates a connection.
JDBC requires a JDBC driver for a database-backend to be loaded. 
Usually a JDBC driver is supplied in a Java Archive (jar) file. 
The path to such a file can be specified in classPath. The driver itself has a 
Java class name that is used to load the driver (for example the MySQL driver 
uses com.mysql.jdbc.Driver), this has to be specified in driverClass.
Due to the fact that JDBC can talk to a wide variety of databases, 
the SQL dialect understood by the database is not known in advance. 
Therefore the RJDBC implementation tries to adhere to the SQL92 standard, 
but not all databases are compliant. This affects mainly functions such as 
dbWriteTable that have to automatically generate SQL code.
-->
## Java Database Connectivity : library(RJDBC)

JDBC ist eine einheitliche Schnittstelle zu verschiedenen Datenbanken. Es werden
für jede Datenbank die zugehörigen JDBC-Treiber benötigt.


```r
library(DBI)
library(rJava)
library(RJDBC)
drv <- JDBC("org.sqlite.JDBC", "~/Google Drive/R/KoelnR-2014/sqlite-jdbc-3.7.2.jar")
con <- dbConnect(drv, "jdbc:sqlite:data/sqlitedb.sqlite")
```

 

```r
rs <- dbSendQuery(con, statement = "SELECT * from P1")
data <- fetch(rs, n = 500)
```





---
## Open Database Connectivity : Konfiguration

### odbc.ini 
<pre>
[ODBC Data Sources]
postgres = postgresql

[postgres]
Driver      = PostgreSQL
ServerName   = ocos
Port = 5432
Database   = postgres
UserName     = diego
Password = diego
Protocol = 9.2
</pre>

### odbcinst.ini
<pre>
[PostgreSQL]
Driver   = /usr/local/lib/psqlodbcw.so
</pre>

---
## Open Database Connectivity : library(RODBC)

```r
# ohne DBI
library(RODBC)
odbcDataSources()
```

```
##     postgres 
## "PostgreSQL"
```

```r
channel <- odbcConnect("postgres")
data <- sqlQuery(channel, "select * from p1 limit 500")
dim(data)
```

```
## [1] 500  29
```





---
## Kürzer

Um vollständig auf SQL zu verzichten, gibt es auch Funktionen,
welche die entsprechenden Statements direkt eingebunden haben:





```r
rs <- dbSendQuery(con, "select * from P1")
data <- fetch(rs)
```






```r
data <- dbReadTable(con, "P1")
```


---
## Cleanup : nach dem fetch()


```r
# löscht alle offenen Referenzen zu einem resultset
dbClearResult(rs)
# schließe connection
dbDisconnect(con)
# Treiber wird gelöscht
dbUnloadDriver(drv)
```


---
## load-extract-transform / split-apply-combine 


```r
system.time({
    rb <- do.call("rbind", lapply(split(df$scope_csize, df$process_id), sum))
    rb.df <- data.frame(process_id = rownames(rb), total = rb, row.names = NULL)
    result <- head(rb.df[order(rb.df$total, decreasing = T), ], 5)
})
result
```

```
##    user  system elapsed 
##   0.041   0.028   0.106
```

```
##                   process_id     total
## 83          SiebelUpdateFlow 308411993
## 28        ExternalStatusFlow 161350929
## 80 SiebelOrderItemUpdateFlow  70485121
## 88            SyncModuleFlow  48834012
## 89             SyncOrderFlow  45176379
```

---
## load-extract-transform : library(plyr)


```r
gs <- ddply(df, "process_id", summarise, total = sum(scope_csize))
result <- head(arrange(gs, desc(total)), 5)
```


---
## load-extract-transform : direkt via SQL


```r
drv <- dbDriver("Oracle")
con <- dbConnect(drv, username = "diego", password = "diego", dbname = "ddc11")
stmt <- "select process_id, sum(scope_csize) from p1 group by process_id order by 2 desc"
rs <- dbSendQuery(con, stmt)
system.time({
    data <- fetch(rs, n = 5)
})
data
```

```
##    user  system elapsed 
##   0.002   0.001   0.910
```

```
##                  PROCESS_ID SUM(SCOPE_CSIZE)
## 1          SiebelUpdateFlow        308411993
## 2        ExternalStatusFlow        161350929
## 3 SiebelOrderItemUpdateFlow         70485121
## 4            SyncModuleFlow         48834012
## 5             SyncOrderFlow         45176379
```


---
## load-extract-transform : library(dplyr)





```r
library(dplyr)
system.time({
    processes <- group_by(df, process_id)
    gs <- summarise(processes, total = sum(scope_csize))
    result <- arrange(gs, desc(total))
})
head(result, 5)
```

```
##    user  system elapsed 
##   0.055   0.033   0.122
```

```
## Source: local data frame [5 x 2]
## 
##                  process_id     total
## 1          SiebelUpdateFlow 308411993
## 2        ExternalStatusFlow 161350929
## 3 SiebelOrderItemUpdateFlow  70485121
## 4            SyncModuleFlow  48834012
## 5             SyncOrderFlow  45176379
```


---
## load-extract-transform : library(dplyr)

Wenn die Datenmenge so groß ist, dass nicht alle Daten in den Speicher passen,
kann man mit Teilmengen oder Aggregationen arbeiten.

dplyr funktioniert transparent und arbeitet mit Datenbankzugriffen oder lokalen data.frames,
die entsprechenden Funktionen sind die gleichen! Das generische Objekt dafür
heißt tbl.

---
## load-extract-transform : dplyr ist lazy 

dplyr versucht so lazy wie möglich zu sein:

1. Es werden Daten nur nach R geholt, wenn man explizit danach fragt.
2. Der Datenbankzugriff wird so lange wie möglich herausgezögert und
   erfolgt dann in einem Schritt.

Es gibt 5 entscheidende Daten-Manipulationen in dplyr, diese
werden bei Bedarf in SQL übersetzt und laufen dann auf der Datenbank:

- select
- filter
- arrange
- mutate
- summarise

---
## load-extract-transform : library(dplyr)




Zuerst wird ein Connect zu einer Datenbank aufgebaut. dplyr unterstützt im Moment
postgres, mysql und sqlite.


```r
my_db <- src_postgres(dbname = "postgres", user = "diego", password = "diego", 
    host = "ocos")
my_db
```

```
## src:  postgres 8.4.18 [diego@ocos:5432/postgres]
## tbls: cities, p1, test1, x_1000
```


---
## dplyr-Objekt tbl aus Datenbank-Tabelle


```r
data_db <- tbl(my_db, sql("SELECT * FROM P1"))
data_db
```

```
## Source: postgres 8.4.18 [diego@ocos:5432/postgres]
## From: <derived table> [?? x 29]
## 
##        cikey domain_ref         process_id revision_tag
## 1  124642631          0 ExternalStatusFlow          1.0
## 2  124642639          0   SiebelUpdateFlow          1.0
## 3  124642659          0   SiebelUpdateFlow          1.0
## 4  124642663          0   SiebelUpdateFlow          1.0
## 5  124642667          0      SyncOrderFlow          1.0
## 6  124642678          0   SiebelUpdateFlow          1.0
## 7  124642682          0   SiebelUpdateFlow          1.0
## 8  124642685          0   SiebelUpdateFlow          1.0
## 9  124642690          0      SyncOrderFlow          1.0
## 10 124642695          0   ODSOrderSyncFlow          1.0
## ..       ...        ...                ...          ...
## Variables not shown: creation_date (time), creator (chr), modify_date
##   (time), modifier (chr), state (int), priority (int), title (chr), status
##   (chr), stage (chr), conversation_id (chr), root_id (chr), parent_id
##   (chr), scope_revision (int), scope_csize (int), scope_usize (int),
##   process_guid (chr), process_type (int), metadata (chr), ext_string1
##   (chr), ext_string2 (chr), ext_int1 (int), test_run_id (chr), at_count_id
##   (int), at_event_id (int), at_detail_id (int)
```


---

## load-extract-transform : tbl-Objekt data_db


```r
system.time({
    processesdb <- group_by(data_db, process_id)
    gsdb <- summarise(processesdb, total = sum(scope_csize))
    result <- arrange(gsdb, desc(total))
})
```

```
##    user  system elapsed 
##   0.050   0.003   0.053
```

```r
head(collect(result), 5)
```

```
## Source: local data frame [5 x 2]
## 
##                  process_id     total
## 1          SiebelUpdateFlow 308411993
## 2        ExternalStatusFlow 161350929
## 3 SiebelOrderItemUpdateFlow  70485121
## 4            SyncModuleFlow  48834012
## 5             SyncOrderFlow  45176379
```


---
## Ergebnisse in Datenbank speichern : PDF als BLOB


```r
library(ggplot2)
qp <- qplot(y = process_id, x = total, data = head(collect(result), 5))
ggsave(plot = qp, filename = "qp.pdf")
```

```
## Saving 7 x 7 in image
```

```r
PICOBJ <- paste(readBin("qp.pdf", "raw", n = file.info("qp.pdf")$size), collapse = "")
qp
```

![plot of chunk unnamed-chunk-33](assets/fig/unnamed-chunk-33.png) 

---

## Zuerst eine Connection aufbauen


```r
library(ROracle)
drv <- dbDriver("Oracle")
con <- dbConnect(drv, username = "diego", password = "diego", dbname = "ddc11", 
    prefetch = FALSE, bulk_read = 1000L, stmt_cache = 0L)
```





---
## INSERT mit dbGetQuery()


```r
insStr <- "insert into plots values(:1, :2, utl_raw.cast_to_raw(:3))"
x <- 1
y <- as.POSIXct("2014-02-22")
z <- "Hierhin kommt das Bild"
df <- data.frame(x, y, z)
dbGetQuery(con, insStr, df)
dbCommit(con)
```


---

## UPDATE via PL/SQL als RAW BLOB


```r
updateStr <- paste0("DECLARE buf RAW(30000); BEGIN buf := '", PICOBJ, "';", 
    "UPDATE plots SET bin = buf WHERE id = 1; commit;END; ")
dbGetQuery(con, updateStr)
```

---
## Grafik ist in der Datenbank gespeichert

<div style='text-align: center;'>
    <img height='548' src='data/snap2.png' />
</div>

----
<!--
 Noch fragen oder anmerkunken
-->
## Vielen Dank !! 

## Q & A

