#' Get data by making GET request to obs db API
#' @keywords internal
#'
getData<-function(base_url, auth_key, dataset_id,...){

  url_obs = paste0(base_url,"/",dataset_id,"/Observations")

  req <-  httr::GET(url_obs, httr::add_headers('Authorization' = auth_key))

  httr::warn_for_status(req, task = paste0("authenticate for dataset with id ",dataset_id))

  if(httr::http_status(req)$category=="Success"){
    print(paste0('received dataset with id ',dataset_id))
  }

  r<-httr::content(req)

  return(r)
}
