# Copyright © 2022 - 2025 Rnaught contributors
#
# This file is part of Rnaught.
#
# Rnaught is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# Rnaught is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with Rnaught. If not, see <https://www.gnu.org/licenses/>.


#' Incidence Decay (ID)
#'
#' This function implements a least squares estimation method of R0 due to
#' Fisman et al. (PloS One, 2013). See details for implementation notes.
#'
#' The method is based on a straightforward incidence decay model. The estimate
#' of R0 is the value which minimizes the sum of squares between observed case
#' counts and cases counts expected under the model.
#'
#' This method is based on an approximation of the SIR model, which is most
#' valid at the beginning of an epidemic. The method assumes that the mean of
#' the serial distribution (sometimes called the serial interval) is known. The
#' final estimate can be quite sensitive to this value, so sensitivity testing
#' is strongly recommended. Users should be careful about units of time (e.g.,
#' are counts observed daily or weekly?) when implementing.
#'
#' @param cases Vector of case counts. The vector must be non-empty and only
#'   contain positive integers.
#' @param mu Mean of the serial distribution. This must be a positive number.
#'   The value should match the case counts in time units. For example, if case
#'   counts are weekly and the serial distribution has a mean of seven days,
#'   then `mu` should be set to `1`. If case counts are daily and the serial
#'   distribution has a mean of seven days, then `mu` should be set to `7`.
#'
#' @return An estimate of the basic reproduction number (R0).
#'
#' @references [Fisman et al. (PloS One, 2013)](
#'   https://doi.org/10.1371/journal.pone.0083622)
#'
#' @seealso [idea()] for a similar method.
#'
#' @export
#'
#' @examples
#' # Weekly data.
#' cases <- c(1, 4, 10, 5, 3, 4, 19, 3, 3, 14, 4)
#'
#' # Obtain R0 when the serial distribution has a mean of five days.
#' id(cases, mu = 5 / 7)
#'
#' # Obtain R0 when the serial distribution has a mean of three days.
#' id(cases, mu = 3 / 7)
id <- function(cases, mu) {
  validate_cases(cases, min_length = 1, min_count = 1)
  if (!is_real(mu) || mu <= 0) {
    stop("The serial interval (`mu`) must be a number greater than 0.",
      call. = FALSE
    )
  }

  exp(sum((log(cases) * mu) / seq_along(cases)) / length(cases))
}
