#' Get data by making POST request to obs db API
#' @keywords internal
#'
postData<-function(base_url, auth_key, dataset_id, startDate,endDate,...){

  url_obs = paste0(base_url,"/",dataset_id,"/Observations")

  body_req=list(startDate=startDate,
                endDate= endDate)

  req <- httr::POST(url_obs, httr::add_headers('Authorization' = auth_key), body = body_req,encode="json")

  httr::warn_for_status(req, task = paste0("authenticate for dataset with id ",dataset_id))

  if(httr::http_status(req)$category=="Success"){
    print(paste0('received dataset with id ',dataset_id))
  }

  r<-httr::content(req)

  return(r)
}
