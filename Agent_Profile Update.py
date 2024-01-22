import csv
import os

# Directory containing CSV files
directory_path = 'C:\\Users\\manor\\Downloads\\NA\\'

# Get a list of CSV files in the directory
csv_files = [file for file in os.listdir(directory_path) if file.endswith('.csv')]

# Process each CSV file
for input_file_name in csv_files:
    # Construct full paths for input and output files
    input_file_path = os.path.join(directory_path, input_file_name)
    output_file_path = os.path.join(directory_path, 'New folder', input_file_name)

    # Read the CSV file and filter rows
    rows_to_keep = []
    found_summary = False

    with open(input_file_path, 'r') as infile:
        reader = csv.reader(infile)
        header = next(reader)  # Read the header

        for row in reader:
            if not found_summary and 'summary' in row[0].lower():
                # Found the row with 'summary', stop adding rows to keep
                found_summary = True
            elif found_summary:
                # Already found 'summary', stop processing
                break
            else:
                # Add this row to the list to keep
                rows_to_keep.append(row)

    # Write the filtered data to a new CSV file
    with open(output_file_path, 'w', newline='') as outfile:
        writer = csv.writer(outfile)

        # Write the header
        writer.writerow(header)

        # Write the rows before the 'summary' line
        writer.writerows(rows_to_keep)

    print(f"Successfully deleted the data below the row containing 'summary' in {input_file_path}.")
    print(f"Updated the original CSV file at {input_file_path} with the new data.")


import csv
import os

# Directory containing CSV files
directory_path = 'C:\\Users\\manor\\Downloads\\NA\\New folder\\'

# Output file path for consolidated data
consolidated_output_file = 'C:\\Users\\manor\\Downloads\\NA\\New folder\\OUT\\Consolidated_Output.csv'

# Initialize a list to store all rows from different CSV files
all_rows = []

# Get a list of CSV files in the directory
csv_files = [file for file in os.listdir(directory_path) if file.endswith('.csv')]

# Process each CSV file
for input_file_name in csv_files:
    # Construct full path for the input file
    input_file_path = os.path.join(directory_path, input_file_name)

    # Read the CSV file and append rows to the list
    with open(input_file_path, 'r') as infile:
        reader = csv.reader(infile)
        header = next(reader)  # Read the header
        rows = list(reader)
        all_rows.extend(rows)

    print(f"Read data from {input_file_path}.")

# Write the consolidated data to a new CSV file
with open(consolidated_output_file, 'w', newline='') as outfile:
    writer = csv.writer(outfile)

    # Write the header
    writer.writerow(header)

    # Write all rows from different CSV files
    writer.writerows(all_rows)

print(f"Consolidated data written to {consolidated_output_file}.")
