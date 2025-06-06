# Main logic block for estimator-related interactions.
estimators_logic <- function(input, output, react_values) {
  # Initialize a data frame to hold estimates.
  react_values$estimates_table <- data.frame(
    Estimator = character(0),
    `Serial interval` = character(0),
    check.names = FALSE

  )
  # Initialize a list to hold added estimators.
  react_values$estimators <- list()

  add_id(input, output, react_values)
  add_idea(input, output, react_values)
  add_seq_bayes(input, output, react_values)
  add_wp(input, output, react_values)

  render_estimates(output, react_values)
  delete_estimators(input, react_values)
  export_estimates(output, react_values)
}

# If an estimator is added, ensure it is not a duplicate and add it to the list
# of estimators. This function should be called at the end of each
# estimator-specific 'add' function, after validating their parameters.
add_estimator <- function(method, new_estimator, output, react_values) {
  num_estimators <- length(react_values$estimators)

  # Check whether the new estimator is a duplicate, and warn if so.
  for (i in seq_len(num_estimators)) {
    if (identical(new_estimator, react_values$estimators[[i]])) {
      showNotification(
        "Error: This estimator has already been added.", duration = 3
      )
      return()
    }
  }

  # Add the new estimator to the list of estimators.
  react_values$estimators[[num_estimators + 1]] <- new_estimator

  showNotification("Estimator added successfully.", duration = 3)

  # Evaluate the new estimator on all existing datasets and create a new row in
  # the estimates table.
  update_estimates_row(new_estimator, react_values)
}

# Ensure serial intervals are specified as positive numbers.
validate_mu <- function(method, input, output) {
  mu <- suppressWarnings(as.numeric(trimws(input[[paste0("mu_", method)]])))
  if (is.na(mu) || mu <= 0) {
    output[[paste0("mu_", method, "_warn")]] <- renderText(
      "The serial interval must be a positive number."
    )
    return(NULL)
  }
  output[[paste0("mu_", method, "_warn")]] <- renderText("")
  mu
}

# Incidence Decay (ID).
add_id <- function(input, output, react_values) {
  observeEvent(input$add_id, {
    mu <- validate_mu("id", input, output)
    if (!is.null(mu)) {
      new_estimator <- list(
        method = "id", mu = mu, mu_units = input$mu_id_units
      )
      add_estimator("id", new_estimator, output, react_values)
    }
  })
}

# Incidence Decay and Exponential Adjustment (IDEA).
add_idea <- function(input, output, react_values) {
  observeEvent(input$add_idea, {
    mu <- validate_mu("idea", input, output)
    if (!is.null(mu)) {
      new_estimator <- list(
        method = "idea", mu = mu, mu_units = input$mu_idea_units
      )
      add_estimator("idea", new_estimator, output, react_values)
    }
  })
}

# Sequential Bayes (seqB).
add_seq_bayes <- function(input, output, react_values) {
  observeEvent(input$add_seq_bayes, {
    mu <- validate_mu("seq_bayes", input, output)

    kappa <- trimws(input$kappa)
    kappa <- if (kappa == "") 20 else suppressWarnings(as.numeric(kappa))

    if (is.na(kappa) || kappa < 1) {
      output$kappa_warn <- renderText(
        "The maximum prior must be a number greater than or equal to 1."
      )
    } else if (!is.null(mu)) {
      output$kappa_warn <- renderText("")
      new_estimator <- list(
        method = "seq_bayes", mu = mu,
        mu_units = input$mu_seq_bayes_units, kappa = kappa
      )
      add_estimator("seq_bayes", new_estimator, output, react_values)
    }
  })
}

# White and Pagano (WP).
add_wp <- function(input, output, react_values) {
  observeEvent(input$add_wp, {
    if (input$wp_mu_known == "Yes") {
      mu <- validate_mu("wp", input, output)
      if (!is.null(mu)) {
        new_estimator <- list(method = "wp",
          mu = mu, mu_units = input$mu_wp_units
        )
        add_estimator("wp", new_estimator, output, react_values)
      }
    } else {
      grid_length <- trimws(input$grid_length)
      max_shape <- trimws(input$max_shape)
      max_scale <- trimws(input$max_scale)

      suppressWarnings({
        grid_length <- if (grid_length == "") 100 else as.numeric(grid_length)
        max_shape <- if (max_shape == "") 10 else as.numeric(max_shape)
        max_scale <- if (max_scale == "") 10 else as.numeric(max_scale)
      })

      valid <- TRUE

      if (is.na(grid_length) || grid_length <= 0) {
        output$grid_length_warn <- renderText(
          "The grid length must be a positive integer."
        )
        valid <- FALSE
      } else {
        output$grid_length_warn <- renderText("")
      }

      if (is.na(max_shape) || max_shape <= 0) {
        output$max_shape_warn <- renderText(
          "The maximum shape must be a positive number."
        )
        valid <- FALSE
      } else {
        output$max_shape_warn <- renderText("")
      }

      if (is.na(max_scale) || max_scale <= 0) {
        output$max_scale_warn <- renderText(
          "The maximum scale must be a positive number."
        )
        valid <- FALSE
      } else {
        output$max_scale_warn <- renderText("")
      }

      if (valid) {
        new_estimator <- list(method = "wp", mu = NA, grid_length = grid_length,
          max_shape = max_shape, max_scale = max_scale
        )
        add_estimator("wp", new_estimator, output, react_values)
      }
    }
  })
}

# Convert an estimator's specified serial interval to match the time units of
# the given dataset.
convert_mu_units <- function(data_units, estimator_units, mu) {
  if (data_units == "Days" && estimator_units == "Weeks") {
    return(mu * 7)
  } else if (data_units == "Weeks" && estimator_units == "Days") {
    return(mu / 7)
  }
  mu
}

# Add a row to the estimates table when a new estimator is added.
update_estimates_row <- function(estimator, react_values) {
  dataset_rows <- seq_len(nrow(react_values$data_table))
  estimates <- c()

  if (nrow(react_values$data_table) > 0) {
    estimates <- dataset_rows
    for (row in dataset_rows) {
      estimate <- eval_estimator(estimator, react_values$data_table[row, ])
      estimates[row] <- estimate
    }
  }

  new_row <- data.frame(
    t(c(estimator_name(estimator), estimator_mu_text(estimator), estimates))
  )
  colnames(new_row) <- colnames(react_values$estimates_table)

  react_values$estimates_table <- rbind(
    react_values$estimates_table, new_row
  )
}

# Evaluate the specified estimator on the given dataset.
eval_estimator <- function(estimator, dataset) {
  cases <- as.integer(unlist(strsplit(dataset[, 3], ",")))

  tryCatch(
    {
      if (estimator$method == "id") {
        mu <- convert_mu_units(dataset[, 2], estimator$mu_units, estimator$mu)
        estimate <- round(Rnaught::id(cases, mu), 2)
      } else if (estimator$method == "idea") {
        mu <- convert_mu_units(dataset[, 2], estimator$mu_units, estimator$mu)
        estimate <- round(Rnaught::idea(cases, mu), 2)
      } else if (estimator$method == "seq_bayes") {
        mu <- convert_mu_units(dataset[, 2], estimator$mu_units, estimator$mu)
        estimate <- round(Rnaught::seq_bayes(cases, mu, estimator$kappa), 2)
      } else if (estimator$method == "wp") {
        if (is.na(estimator$mu)) {
          estimate <- Rnaught::wp(cases, serial = TRUE,
            grid_length = estimator$grid_length,
            max_shape = estimator$max_shape, max_scale = estimator$max_scale
          )
          estimated_mu <- round(sum(estimate$supp * estimate$pmf), 2)
          mu_units <- if (dataset[, 2] == "Days") "day(s)" else "week(s)"
          estimate <- paste0(
            round(estimate$r0, 2), " (SI = ", estimated_mu, " ", mu_units, ")"
          )
        } else {
          mu <- convert_mu_units(dataset[, 2], estimator$mu_units, estimator$mu)
          estimate <- round(Rnaught::wp(cases, mu), 2)
        }
      }

      return(estimate)
    }, error = function(e) {
      showNotification(
        paste0(toString(e),
          " [Estimator: ", sub(" .*", "", estimator_name(estimator)),
          ", Dataset: ", dataset[, 1], "]"
        ), duration = 6
      )
      return("—")
    }
  )
}

# Create the name of an estimator to be added to the first column of the
# estimates table.
estimator_name <- function(estimator) {
  if (estimator$method == "id") {
    return("ID")
  } else if (estimator$method == "idea") {
    return("IDEA")
  } else if (estimator$method == "seq_bayes") {
    return(paste0("seqB", " (&#954; = ", estimator$kappa, ")"))
  } else if (estimator$method == "wp") {
    if (is.na(estimator$mu)) {
      return(paste0("WP (", estimator$grid_length, ", ",
        round(estimator$max_shape, 3), ", ", round(estimator$max_scale, 3), ")"
      ))
    } else {
      return("WP")
    }
  }
}

# Create the text to be displayed for the serial interval in the second column
# of the estimates table.
estimator_mu_text <- function(estimator) {
  if (is.na(estimator$mu)) {
    return("—")
  }
  mu_units <- if (estimator$mu_units == "Days") "day(s)" else "week(s)"
  paste(estimator$mu, mu_units)
}

# Render the estimates table whenever it is updated.
render_estimates <- function(output, react_values) {
  observe({
    output$estimates_table <- DT::renderDataTable(react_values$estimates_table,
      escape = FALSE, rownames = FALSE,
      options = list(
        columnDefs = list(list(className = "dt-left", targets = "_all"))
      ),
    )
  })
}

# Delete rows from the estimates table and the corresponding estimators.
delete_estimators <- function(input, react_values) {
  observeEvent(input$estimators_delete, {
    rows_selected <- input$estimates_table_rows_selected
    react_values$estimators <- react_values$estimators[-rows_selected]
    react_values$estimates_table <-
      react_values$estimates_table[-rows_selected, ]
  })
}

# Export estimates table as a CSV file.
export_estimates <- function(output, react_values) {
  output$estimates_export <- downloadHandler(
    filename = function() {
      paste0(
        "Rnaught_estimates_", format(Sys.time(), "%y-%m-%d_%H-%M-%S"), ".csv"
      )
    },
    content = function(file) {
      output_table <- data.frame(
        lapply(react_values$estimates_table, sub_entity)
      )
      colnames(output_table) <- sub_entity(
        colnames(react_values$estimates_table)
      )
      write.csv(output_table, file, row.names = FALSE)
    }
  )
}

# Substitute HTML entity codes with natural names.
sub_entity <- function(obj) {
  obj <- gsub("&#954;", "kappa", obj)
  obj
}
