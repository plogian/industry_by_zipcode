library(jsonlite)

census_api_key <- "YOUR API KEY HERE"

#get census 2015 zipcode-level data for industries in each zipcode.
#EMP -total number of employees only works for the whole zipcode
vars <- c("EMP", "ESTAB", "EMPSZES", "NAICS2012_TTL")
variable_list <- paste0(vars, collapse =",")

#can only do 6 zipcodes at once. There's definitely a more efficient way, but this works
zips1 <- c(75042, 75080, 75081, 75231, 75238)
zip_list1 <- paste0(as.character(zips1), collapse=",")

zips2 <- c(75248, 75251, 75254, 75001, 75006)
zip_list2 <- paste0(as.character(zips2), collapse=",")

zips3 <- c(75230, 75234,75240, 75244, 75134)
zip_list3 <- paste0(as.character(zips3), collapse=",")

zips4 <- c(75146, 75241, 75243, 75229, 75141)
zip_list4 <- paste0(as.character(zips4), collapse=",")

url1 <- paste0("https://api.census.gov/data/2015/zbp?get=", variable_list, "&for=zipcode:", zip_list1, "&NAICS2012=*&key=", census_api_key)
industry_data_1 <- fromJSON(url1)
industry_data_1<- industry_data_1[2:nrow(industry_data_1),]
industry_data_frame_1 <- as.data.frame(industry_data_1, stringsAsFactors = F)

url2 <- paste0("https://api.census.gov/data/2015/zbp?get=", variable_list, "&for=zipcode:", zip_list2, "&NAICS2012=*&key=", census_api_key)
industry_data_2 <- fromJSON(url2)
industry_data_2<- industry_data_2[2:nrow(industry_data_2),]
industry_data_frame_2 <- as.data.frame(industry_data_2, stringsAsFactors = F)

url3 <- paste0("https://api.census.gov/data/2015/zbp?get=", variable_list, "&for=zipcode:", zip_list3, "&NAICS2012=*&key=", census_api_key)
industry_data_3 <- fromJSON(url3)
industry_data_3<- industry_data_3[2:nrow(industry_data_3),]
industry_data_frame_3 <- as.data.frame(industry_data_3, stringsAsFactors = F)

url4 <- paste0("https://api.census.gov/data/2015/zbp?get=", variable_list, "&for=zipcode:", zip_list4, "&NAICS2012=*&key=", census_api_key)
industry_data_4 <- fromJSON(url4)
industry_data_4<- industry_data_4[2:nrow(industry_data_4),]
industry_data_frame_4 <- as.data.frame(industry_data_4 , stringsAsFactors = F)

industry_data_frame_full <- rbind(industry_data_frame_1, industry_data_frame_2, industry_data_frame_3, industry_data_frame_4)

names(industry_data_frame_full) <- c("total_employees", "total_establishments", "employer_size", "NAICS_title", "NAICS", "zipcode")
class(industry_data_frame_full$total_employees) <- "numeric"
class(industry_data_frame_full$total_establishments) <- "numeric"

#separate totaled data for all industries from data for each industry
total_employment_for_zips <- subset(industry_data_frame_full, industry_data_frame_full$NAICS=="00"&industry_data_frame_full$employer_size=="001")
industry_data_frame_sep <- subset(industry_data_frame_full, industry_data_frame_full$NAICS!="00"&industry_data_frame_full$employer_size!="001"&nchar(industry_data_frame_full$NAICS)==2)

#convert employer size code to estimate #
industry_data_frame_sep$employer_estimate <- 0
industry_data_frame_sep <- transform(industry_data_frame_sep, 
                                     employer_estimate =
                                       ifelse(employer_size %in% "212", 2.5,
                                        ifelse(employer_size %in% "220", 7, 
                                               ifelse(employer_size %in% "230", 14.5,
                                                      ifelse(employer_size %in% "241", 34.5,
                                                             ifelse(employer_size %in% "242", 74.5,
                                                                    ifelse(employer_size %in% "251", 174.5,
                                                                           ifelse(employer_size %in% "252", 374.5,
                                                                                  ifelse(employer_size %in% "254", 749.5,
                                                                                         ifelse(employer_size %in% "260", 1500, 0))))))))))

#estimate the number of employees per zipcode
#first add a column to the whole data frame, then aggregate by zipcode
industry_data_frame_sep$total_employees_estimate <- industry_data_frame_sep$total_establishments * industry_data_frame_sep$employer_estimate

#check to see if error is reasonable between estimated number of employees and total. 
estimated_total_employement_for_zips <- aggregate(total_employees_estimate ~ zipcode, industry_data_frame_sep, sum)
merged_total_employment_for_zips <- merge(total_employment_for_zips, estimated_total_employement_for_zips, by = "zipcode")
merged_total_employment_for_zips$error <- merged_total_employment_for_zips$total_employees - merged_total_employment_for_zips$total_employees_estimate
mean(abs(merged_total_employment_for_zips$error))

#mean abs(error) is 2514 employees. Majority of districts are underestimates. Highest underestimates in 75006 and 75243, which also
#have the largest workforces in general and more large establishments. 

#finally, get the dataset with estimated employment by industry by zipcode and write to csv
estimated_total_employement_for_zips_by_industry <- aggregate(total_employees_estimate ~ zipcode + NAICS, industry_data_frame_sep, sum)
write.csv(estimated_total_employement_for_zips_by_industry, "industry_by_zip.csv")