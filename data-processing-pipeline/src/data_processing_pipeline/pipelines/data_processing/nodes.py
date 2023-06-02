import pandas as pd
import great_expectations as gx
from great_expectations.checkpoint.checkpoint import SimpleCheckpoint


def extract_tables(qld_p18_19: pd.DataFrame) -> pd.DataFrame:
    """
    Args:
        qld_p18_19: An excel sheet from the workbook
    Returns:
        A table extracted from the excel sheet.
    """

    df = qld_p18_19

    sheet_name = "p18_19"

    empty_row_index = df.index[df.isnull().all(axis=1)].insert(0, 0)

    dataframes = {}

    for i in range(len(empty_row_index) - 1):
        df_name = f"{sheet_name}_{i}"

        # Skip adjacent empty rows
        if empty_row_index[i + 1] - empty_row_index[i] == 1:
            continue

        # Extract other tables
        df_value = df.iloc[empty_row_index[i]:empty_row_index[i + 1]].dropna(how='all').reset_index(drop=True)

        # Add the dataframe into the library
        dataframes[df_name] = df_value

    # Extract the last table
    df_value = df.iloc[empty_row_index[-1]:df.index[-1] + 1].dropna(how='all').reset_index(drop=True)
    dataframes[f"{sheet_name}_{len(empty_row_index)}"] = df_value

    table = dataframes["p18_19_5"]

    return table


def set_column_index(p18_19_5: pd.DataFrame) -> pd.DataFrame:
    """
    Args:
        p18_19_5: A table extracted from the excel sheet.
    Returns:
        The table with new column index.
    """

    df = p18_19_5

    # Create a boolean is_title_mask indicating which rows have only one non-null entry
    is_title_mask = df.count(axis=1) == 1

    table_name = "None"

    # Check if the dataframe contains a row with only one non-null value.
    # The non-value is assumed to become the title of the table
    if is_title_mask.any():
        # Find the column index of the non-null value in each row by filtering the DataFrame to
        # include only the rows with one non-null entry
        row_index = df[is_title_mask].index.tolist()[0]

        # Find the column index of the non-null value in the row
        col_index = df[is_title_mask].notnull().idxmax(axis=1)

        # Extract the value of the cell as a string for naming the table
        table_name = df.loc[row_index, col_index].item()

        # Drop  the first row in the dataframe
        df = df.drop(index=0)

        # Reset the dataframe's row index
        df = df.reset_index(drop=True)

    # The row index of the last row with null values in the dataframe
    row_index_last_null = df.isna().iloc[::-1].idxmax()[0]

    # If the only first row has null values, then assume that the second row has column index values
    if row_index_last_null == 0:
        row_index_last_null = + 1

    # For first rows in the dataframe with null values, populate the null values with the preceding non-null value
    df.iloc[:row_index_last_null] = df.iloc[:row_index_last_null].fillna(method='ffill', axis=1)

    # Define a function to concatenate the non-null values
    def concat_non_null(x):
        return '_'.join([str(val) for val in x.values if not pd.isnull(val)])

    # Merge the rows of the dataframe by concatenating the non-null values
    merged_row = df.iloc[:2].apply(concat_non_null).to_frame().T

    # Drop the rows up to row_index_last_null in the dataframe
    df = df.drop(index=range(0, row_index_last_null + 1))

    # Reset the dataframe's row index
    df = df.reset_index(drop=True)

    # Set the merged_row as the dataframe's column index
    df.columns = merged_row.iloc[0]

    # Replace whitespaces in dataframe column names with underscores "_"
    df.columns = df.columns.str.replace(' ', '_')

    # Lowercase all column names in dataframe
    df.columns = df.columns.str.lower()

    return df


def validate_processed_data (processed_p18_19_5: pd.DataFrame) -> pd.DataFrame:

    df = processed_p18_19_5

    context = gx.get_context()

    # Retrieve the Data Asset
    datasource_name = "processed_datasource"
    asset = context.get_datasource(datasource_name).get_asset("processed_data_asset")

    # Build a Batch Request
    batch_request = asset.build_batch_request()

    # Instantiate a Validator
    expectation_suite_name = "processed_data_suite"

    # Set up and run a Simple Checkpoint for ad hoc validation of our data
    checkpoint_config = {
        "class_name": "SimpleCheckpoint",
        "validations": [
            {
                "batch_request": batch_request,
                "expectation_suite_name": expectation_suite_name,
            }
        ],
    }

    checkpoint_name = "processed_data_checkpoint"
    checkpoint = gx.checkpoint.SimpleCheckpoint(
        name=checkpoint_name,
        data_context=context,
        **checkpoint_config,
    )

    context.add_checkpoint(checkpoint=checkpoint)

    result = context.run_checkpoint(
        checkpoint_name=checkpoint_name,
    )

    if not result["success"]:
        print("Validation failed!")

    else:
        return df



