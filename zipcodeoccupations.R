library(jsonlite)

#census_api_key <- "YOUR API KEY HERE"


#get census 2015 zipcode-level data for industries in each zipcode
vars <- c("EMP", "EMPSZES", "NAICS2012", "NAICS2012_TTL")
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

url1 <- paste0("https://api.census.gov/data/2015/zbp?get=", variable_list, "&for=zipcode:", zip_list1, "&key=", census_api_key)
industry_data_1 <- fromJSON(url1)
industry_data_frame_1 <- as.data.frame(industry_data_1, stringsAsFactors = F)

url2 <- paste0("https://api.census.gov/data/2015/zbp?get=", variable_list, "&for=zipcode:", zip_list2, "&key=", census_api_key)
industry_data_2 <- fromJSON(url2)
industry_data_frame_2 <- as.data.frame(industry_data_2, stringsAsFactors = F)

url3 <- paste0("https://api.census.gov/data/2015/zbp?get=", variable_list, "&for=zipcode:", zip_list3, "&key=", census_api_key)
industry_data_3 <- fromJSON(url3)
industry_data_frame_3 <- as.data.frame(industry_data_3, stringsAsFactors = F)

url4 <- paste0("https://api.census.gov/data/2015/zbp?get=", variable_list, "&for=zipcode:", zip_list4, "&key=", census_api_key)
industry_data_4 <- fromJSON(url4)
industry_data_frame_4 <- as.data.frame(industry_data_4 , stringsAsFactors = F)

industry_data_frame_full <- rbind(industry_data_frame_1, industry_data_frame_2, industry_data_frame_3, industry_data_frame_4)

write.csv(industry_data_frame_full, "industry_by_zip.csv")