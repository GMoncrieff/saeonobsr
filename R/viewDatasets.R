#' View datasets
#'
#' Lists datasets available in the SAEON observations database
#'
#' @param extent A spatial object of class `sf` object giving the extent over to search for datasets. Defaults to NULL
#' @param spatial Should the result be returned as a sf object? Defaults to FALSE
#'
#' @return A data.frame with available datasets and relevant details
#'
#' @examples
#' \dontrun{
#' viewDatasets()
#' }
#'
#' @export

viewDatasets <- function(extent=NULL,spatial=FALSE) {

  #check args
  if(!is.null(extent) & class(extent)[1]!="sf") stop("Please specify extent as sf object")
  if(!is.null(extent) & sf::st_crs(extent)$epsg!=4326) stop("Please specify sf object using projection EPSG:4326")
  if(!is.logical(spatial)) stop("spatial argument must be logical")

  #API endpount
  base_url = "https://observationsapi.saeon.ac.za/Api/InventoryDatasets"
  #API key
  key = Sys.getenv("OBSDB_KEY")
  if(key=="") stop("Failed to find API key. Please set API key using Sys.setenv()")
  auth_key = paste("Bearer", key, sep = " ")

  #make request
  req <- httr::GET(base_url, httr::add_headers('Authorization' = auth_key))
  httr::stop_for_status(req, task = "authenticate")
  r <-httr::content(req)

  #extract relevant columns
  dataset_id<-purrr::map(r, "id") %>% as.numeric()
  siteName<-purrr::map(r, "siteName") %>% as.character()
  stationId<-purrr::map(r, "stationId") %>% as.character()
  stationName<-purrr::map(r, "stationName") %>% as.character()
  phenomenonId<-purrr::map(r, "phenomenonId") %>% as.character()
  phenomenonName<-purrr::map(r, "phenomenonName") %>% as.character()
  phenomenonCode<-purrr::map(r, "phenomenonCode") %>% as.character()
  offeringId<-purrr::map(r, "offeringId") %>% as.character()
  offeringName<-purrr::map(r, "offeringName") %>% as.character()
  offeringCode<-purrr::map(r, "offeringCode") %>% as.character()
  unitId<-purrr::map(r, "unitId") %>% as.character()
  unitName<-purrr::map(r, "unitName") %>% as.character()
  unitCode<-purrr::map(r, "unitCode") %>% as.character()
  latitude<-purrr::map(r, "latitudeNorth") %>% as.numeric()
  longitude<-purrr::map(r, "longitudeEast") %>% as.numeric()
  startDate<-purrr::map(r, "startDate") %>% as.character()
  endDate<-purrr::map(r, "endDate") %>% as.character()
  valueCount<-purrr::map(r, "valueCount") %>% as.character()


  data <- data.frame(dataset_id,
                     siteName,
                     stationId,
                     stationName,
                     phenomenonId,
                     phenomenonName,
                     phenomenonCode,
                     unitId,
                     unitName,
                     unitCode,
                     offeringId,
                     offeringName,
                     offeringCode,
                     latitude,
                     longitude,
                     startDate,
                     endDate,
                     valueCount)
  data <- data %>%
    tidyr::unite(col="obs_type_code", phenomenonCode,offeringCode,unitCode,sep="_",remove = FALSE) %>%
    tidyr::unite(col="description", phenomenonName,offeringName,unitName,sep=" - ",remove = FALSE)


  #limit extent of results
  if(!is.null(extent)){
    projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    data <- sf::st_as_sf(x = data,
                         coords = c("longitude", "latitude"),
                         crs = projcrs)
    sf::st_agr(data) = "constant"
    data <- sf::st_intersection(data, extent)
  }

  cl<-class(data)[1]

  #return spatial df if needed
  if (spatial==TRUE & cl=='data.frame'){
    data <- sf::st_as_sf(x = data,
                         coords = c("longitude", "latitude"),
                         crs = projcrs)
  } else if (spatial==FALSE & cl=='sf') {
    sf::st_geometry(data) <- NULL
  }

  return(data)
}
