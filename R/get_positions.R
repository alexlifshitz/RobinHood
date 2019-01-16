#' Get Current Positions of your portfolio
#'
#'
#' @param RH object class RobinHood
#' @param simple (logical) if true, return a simplified positions table, false returns all positions details
#' @import curl jsonlite magrittr lubridate
#' @export
#' @examples
#' # Get you current positions
#' # RH <- RobinHood(username = 'your username', password = 'your password')
#' # get_positions(RH)
get_positions <- function(RH, simple = TRUE) {

  ##############################################################################
  # Get current positions
  positions <- api_positions(RH)

  ##############################################################################
  # Use instrument IDs to get the ticker symbol and name
  instrument_id <- positions$instrument
  instruments <- c()

  for (i in 1:length(instrument_id)) {
    instrument <- api_instruments(instrument_id[i])

    x <- data.frame(simple_name = instrument$simple_name,
                    symbol = instrument$symbol)

    instruments <- rbind(instruments, x)
  }

  ##############################################################################
  # Combine positions with instruments
  positions <- cbind(instruments, positions)

  ##############################################################################
  # Get latest quote
  symbols <- paste(as.character(positions$symbol), collapse = ",")

  # Quotes URL
  symbols_url <- paste(api_endpoints(endpoint = "quotes"), symbols, sep = "")

  # Get last price
  quotes <- api_quote(RH, symbols_url)
  quotes <- quotes[, c("last_trade_price", "symbol")]

  ##############################################################################
  # Combine quotes with positions
  positions <- merge(positions, quotes)

  # Get rid of arbitrary columns
  positions = subset(positions, select = -c(account, url, instrument))

  # Convert timestamp
  positions$updated_at <- ymd_hms(positions$updated_at)
  positions$created_at <- ymd_hms(positions$created_at)

  # Adjust data types
  positions$quantity <- as.numeric(positions$quantity)
  positions$average_buy_price <- as.numeric(positions$average_buy_price)
  positions$last_trade_price <- as.numeric(positions$last_trade_price)
  positions$shares_held_for_stock_grants <- as.numeric(positions$shares_held_for_stock_grants)
  positions$shares_held_for_options_events <- as.numeric(positions$shares_held_for_options_events)
  positions$shares_held_for_options_collateral <- as.numeric(positions$shares_held_for_options_collateral)
  positions$shares_held_for_buys <- as.numeric(positions$shares_held_for_buys)
  positions$shares_held_for_sells <- as.numeric(positions$shares_held_for_sells)
  positions$shares_pending_from_options_events <- as.numeric(positions$shares_pending_from_options_events)
  positions$pending_average_buy_price <- as.numeric(positions$pending_average_buy_price)
  positions$intraday_average_buy_price <- as.numeric(positions$intraday_average_buy_price)
  positions$intraday_quantity <- as.numeric(positions$intraday_quantity)

  # Calculate extended cost and value
  positions$cost <- with(positions, average_buy_price * quantity)
  positions$current_value <- with(positions, last_trade_price * quantity)

  if (simple == TRUE) {
    # Reorder dataframe
    positions <- positions[, c("simple_name",
                               "symbol",
                               "quantity",
                               "average_buy_price",
                               "last_trade_price",
                               "cost",
                               "current_value",
                               "updated_at")]
    } else {

      positions <- positions[, c("symbol",
                                 "simple_name",
                                 "quantity",
                                 "average_buy_price",
                                 "last_trade_price",
                                 "cost",
                                 "current_value",
                                 "shares_held_for_stock_grants",
                                 "shares_held_for_options_events",
                                 "shares_held_for_options_collateral",
                                 "shares_held_for_buys",
                                 "shares_held_for_sells",
                                 "shares_pending_from_options_events",
                                 "pending_average_buy_price",
                                 "intraday_average_buy_price",
                                 "intraday_quantity",
                                 "created_at",
                                 "updated_at")]
  }

  return(positions)
}