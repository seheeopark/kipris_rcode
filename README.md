# kipris

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

## Update (Feb/29/2020): Introducing a function that can extract multiple pages per applicant 
The maximum number of patents per page per applicant is apparently 500 instead of 1,000. 
This newly updated Rmarkdown file offers my complete function which allows us to extract multi-paged full list of patents for multiple number of patent applicants. 
If this single function looks too complicated, please refer to the step-by-step r scripts in the `scripts` folder. 
* 01 Single applicant, single page 
* 02 Single applicant, multiple pages 
* 03 Multiple applicants, single page 
* 04 Multiple applicants, multiple pages (Final version)

Now you are ready to get patent data. 

## Update (July/31/2020): Patents by ipc number 

1. A new script to extract patents by ipc numbers is added. 
* 05 ipcNumber (multiple ipc numbers, multiple pages) 

2. A warning message is added to all r scripts if your API access was not successful. 
* Successful API access: status code == 200 
* Failed API access: status code !=200 

## Update (August/04/2020): English abstract by keyword search 
English abstracts of KIPRIS patents are now available. 

1. Keywords can take a vector of multiple keywords with search operators (AND(*), OR(+), NOT(!)).
* 06 keyword search 

2. Use the patent application numbers that are retrived from '06_keyword_search.R' to get English abstracts for the searched patents. 
* 07 Eng abstracts contents 

## Epilogue
Please create an issue if you wish me to create another r script to search patents in any other ways from the KIPRIS database. 
