# kipris
R codes to extract Korean patent information from the KIPRIS Plus (REST API) 

## What is KIPRIS? 

[KIPRIS](http://eng.kipris.or.kr/enghome/main.jsp) is an acronym Korea Intellectual Property Rights Information. 
It is a web-based portal for searching patents, utilities, designs, and trademarks in Korea. 
Using keyword-based search formula, KIPRIS offers up-to-date patents and related information. 

[KIPRIS Plus](http://plus.kipris.or.kr/) is a public API service. 
They offer 46 numbers of OpenAPI as of December 2019. 
KIPRIS Plus service is free of charge up to 1,000 cases per month. 
Please be aware that most extracted information from KIPRIS Plus would be in Korean. 

## Apply for a personal key to access the OpenAPI services 

KIPRIS Plus requires users to apply for a personal key to access the database. 
First, [join](http://plus.kipris.or.kr/eng/member/memberSelect.do?menuNo=300028) a membership as an individual (customer) or an organization (data publisher). 
If you are an individual non-profit researcher, you may prefer to join as a customer. 

After logging-in, browse their OpenAPI lists and click any service you want to access. 
Here is the api service links to extract patents or utilities information:
[Patent-Utility Model Publications](http://plus.kipris.or.kr/eng/data/service/DBII_000000000000001/view.do?menuNo=300100&kppBCode=&kppMCode=&kppSCode=&subTab=SC001&entYn=&clasKeyword=)
There are two blue square buttons: *Service* and *Service All*. 
Click the **Service All** to get a personal key to access any API services from KIPRIS Plus. 
Fill-up the provided form, and wait one or two days to get your access key. 
Your personal key can be found in *My Page* under *Subscriptions*. 
Do **NOT** share your access key with others. 

Now you are ready to get patent data. 
