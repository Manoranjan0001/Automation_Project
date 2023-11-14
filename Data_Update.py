
import pandas as pd

# Read old and new CSV files
old_csv_path = 'C:\\Users\\manor\\Downloads\\Python_Working\\MAIN_Interaction_Level_Data.csv'

new_csv_path = 'C:\\Users\\manor\\Downloads\\Python_Working\\In_Interaction_Level_data.csv'
old_df = pd.read_csv(old_csv_path)
new_df = pd.read_csv(new_csv_path)

# Find new minimum date
new_min_date = new_df['activity_date'].min()

# Filter old data
old_df = old_df[old_df['activity_date'] < new_min_date]

# Append new data
frames = [old_df, new_df]
old_df = pd.concat(frames, ignore_index=True)

# Save updated DataFrame to CSV
updated_csv_path = 'C:\\Users\\manor\\Downloads\\Python_Working\\MAIN_Interaction_Level_Data.csv'
old_df.to_csv(updated_csv_path, index=False)

print("CSV file updated successfully.")
