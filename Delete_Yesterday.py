import csv
from datetime import datetime, timedelta

# Input file path and output file path
input_file_path = 'C:\\Users\\manor\\Downloads\\NA\\New folder\\OUT\\Consolidated_Output.csv'
output_file_path = 'C:\\Users\\manor\\Downloads\\NA\\New folder\\OUT\\Consolidated_Output.csv'

# Read the CSV file and filter rows
rows_to_keep = []
header = []

# Define the date format in the "INTERVAL" column
date_format = '%m/%d/%Y %H:%M %z'

# Calculate yesterday's date
yesterday = datetime.now() - timedelta(days=1)
yesterday_str = yesterday.strftime('%m/%d/%Y')

def extract_start_date(interval_str):
    # Extract the start date from the "INTERVAL" format
    return interval_str.split()[0]

with open(input_file_path, 'r') as infile:
    reader = csv.reader(infile)
    header = next(reader)  # Read the header

    for row in reader:
        interval_column = row[header.index("Interval")] if "Interval" in header else None

        if interval_column and extract_start_date(interval_column) == yesterday_str:
            # Exclude rows with "INTERVAL" starting with yesterday's date
            continue

        rows_to_keep.append(row)

# Write the filtered data to a new CSV file
with open(output_file_path, 'w', newline='') as outfile:
    writer = csv.writer(outfile)

    # Write the header
    writer.writerow(header)

    # Write the rows that passed the filter
    writer.writerows(rows_to_keep)

print(f"Data with 'INTERVAL' starting with {yesterday_str} removed. Output saved to {output_file_path}.")



