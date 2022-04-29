#' Download datasets
#'
#' Requests and downloads datasets from the SAEON observations database
#'
#' @param df A data.frame with rows corresponding to datasets to download. Should be generated from \code{\link{viewDatasets}}. Must contain columns `stationID`, `phenomenomId`, `InstrumentId` and `UnitId`
#' @param startDate Start date for observations. Either a date or string with format 'YYYY-MM-DD' or 'YYYY-MM-DD HH-MM-SS'. Defaults to NULL.
#' @param endDate End date for observations. Either a date or string with format 'YYYY-MM-DD' or 'YYYY-MM-DD HH-MM-SS'. Defaults to NULL.
#'
#' @return A data.frame with observation data and associated details
#'
#' @examples
#' \dontrun{
#' #get dataframe with available dataset and filter based on search criteria
#'
#' df <- viewDatasets() %>%
#'       filter(siteName == 'Constantiaberg') %>%
#'       filter(description == 'Air Temperature - Daily Minimum - Degrees Celsius')
#'
#' #fetch those datasets for 2020
#'
#' obs <- getDatasets(df,startDate='2020-01-01',endDate='2020-12-31')
#' }
#'
#' @export

getDatasets<-function(df,startDate=NULL,endDate=NULL){

  #check df
  if(missing(df)) stop("datasets data.frame input missing")
  if(!is.data.frame(df)) stop("datasets input must be a data.frame")
  if(!all(c("stationId","phenomenonId","unitId","offeringId","dataset_id") %in% colnames(df))) stop("datasets data.frame missing a required column")

  #check dates, and convert format
  if(!is.null(endDate)){
    endDate <- tryCatch(
      {
        as.POSIXct(endDate)
      },
      error = function(e){
        stop("incorrect end date format")
      }
    )
    endDate <- lubridate::format_ISO8601(endDate, precision="ymdhms")
  }
  if(!is.null(startDate)){
    startDate <- tryCatch(
      {
        as.POSIXct(startDate)
      },
      error = function(e){
        stop("incorrect start date format")
      }
    )
    startDate <- lubridate::format_ISO8601(startDate, precision="ymdhms")
  }

  if(nrow(df)>10) {
    check <- menu(c("Yes","No"),title="Warning: over 10 datasets will be downloaded, this may take a long time. Do you want to proceed?")
    if(check==2) {stop("download cancelled")}
  }
  #API endpoint
  base_url = "https://observationsapi.saeon.ac.za/Api/Stations"

  #API key
  key = Sys.getenv("OBSDB_KEY")
  if(key=="") stop("Failed to find API key. Please set API key using Sys.setenv()")
  auth_key = paste("Bearer", key, sep = " ")

  df$base_url <- base_url
  df$auth_key <- auth_key

  #send request to correct API wrapper
  if(!is.null(startDate) & !is.null(endDate)){
    df$startDate <- startDate
    df$endDate <- endDate
    list_df <- purrr::pmap(df,postData)
  } else {
    list_df <- purrr::pmap(df,getData)
  }

  #tidy up result
  df_combine <- dplyr::bind_rows(list_df, .id = "column_label") %>%
    dplyr::select(id,instrumentName,sensorName,date = valueDate,latitude,longitude,dataValue,phenomenonName,phenomenonCode,offeringName,offeringCode,unitName,unitCode) %>%
    tidyr::unite(col="obs_type_code", phenomenonCode,offeringCode,unitCode,sep="_",remove=TRUE) %>%
    tidyr::unite(col="description", phenomenonName,offeringName,unitName,sep=" - ",remove=FALSE)

  if(length(unique(df_combine$obs_type_code))>1){
    warning("dataframe contains muliple observation types")
  }

  return(df_combine)
}
