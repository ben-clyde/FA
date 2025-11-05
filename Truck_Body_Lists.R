# ---- Price Digests API: Category vs Size Class Summary ----
# This script retrieves size class taxonomy data for classificationId = 8 (Truck Bodies)
# and writes a CSV summarizing distinct size class names per category,
# including a row number column and ordered size classes (Light, Medium, Heavy).

# Load required libraries
library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)

# ---- API Call ----
url <- "https://sandbox.pricedigestsapi.com/v1/taxonomy/sizes?classificationId=8"
api_key <- "bafd0058dc7a4a399deec305853250c0"

response <- GET(url, add_headers(`x-api-key` = api_key))

# Check response status
if (status_code(response) != 200) {
  stop("API request failed: ", status_code(response))
}

# ---- Parse JSON ----
data <- content(response, as = "text", encoding = "UTF-8")
json_data <- fromJSON(data, flatten = TRUE)

df <- as_tibble(json_data)

# ---- Define Custom Order for Size Classes ----
size_order <- c("Light Duty", "Medium Duty", "Heavy Duty")

summary_df <- df %>%
  group_by(categoryName) %>%
  summarize(
    sizeClasses = paste(
      unique(sizeClassName[order(match(sizeClassName, size_order))]),
      collapse = "|"
    ),
    .groups = "drop"
  ) %>%
  arrange(categoryName) %>%
  mutate(row = row_number()) %>%
  select(row, categoryName, sizeClasses)

# ---- Output CSV ----
output_file <- "FA_size_classes_by_category.csv"
write.csv(summary_df, output_file, row.names = FALSE, na = "")

# ---- Confirmation ----
message("Summary CSV created: ", output_file)
