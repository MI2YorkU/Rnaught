#' Launch the Rnaught Web Application
#'
#' This is the entry point of the Rnaught web application, which creates and
#' returns a Shiny app object. When invoked directly, the web application is
#' launched.
#'
#' The following dependencies are required to run the application:
#'   * [shiny](https://shiny.posit.co)
#'   * [bslib](https://rstudio.github.io/bslib)
#'   * [DT](https://rstudio.github.io/DT)
#'   * [plotly](https://plotly-r.com)
#'
#' If any of the above packages are missing during launch, a prompt will appear
#' to install them.
#'
#' To configure settings such as the port, host or default browser, set Shiny's
#' global options (see [shiny::runApp()]).
#'
#' @return A Shiny app object for the Rnaught web application.
#'
#' @importFrom utils install.packages
#'
#' @export
web <- function() {
  missing_pkgs <- c()
  # Check for any missing, required packages.
  if (!requireNamespace("shiny", quietly = TRUE)) {
    missing_pkgs <- c(missing_pkgs, "shiny")
  }
  if (!requireNamespace("bslib", quietly = TRUE)) {
    missing_pkgs <- c(missing_pkgs, "bslib")
  }
  if (!requireNamespace("DT", quietly = TRUE)) {
    missing_pkgs <- c(missing_pkgs, "DT")
  }
  if (!requireNamespace("plotly", quietly = TRUE)) {
    missing_pkgs <- c(missing_pkgs, "plotly")
  }

  # If any of the required packages are missing,
  # prompt the user to install them.
  if (length(missing_pkgs) > 0) {
    cat("The following packages must be installed to run the",
      "Rnaught web application:\n"
    )
    writeLines(missing_pkgs)
    answer <- readline("Begin installation? [Y/n] ")

    if (answer == "Y" || answer == "y") {
      install.packages(missing_pkgs)
    } else {
      stop("Aborting due to missing, required packages.", call. = FALSE)
    }
  }

  shiny::shinyAppDir(appDir = system.file("web", package = "Rnaught"))
}
