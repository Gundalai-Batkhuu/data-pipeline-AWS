from kedro.pipeline import Pipeline, node
from kedro.pipeline.modular_pipeline import pipeline

from .nodes import extract_tables, set_column_index, validate_processed_data


def create_pipeline(**kwargs) -> Pipeline:
    return pipeline(
        [
            node(
                func=extract_tables,
                inputs="qld_p18_19",
                outputs="p18_19_5",
                name="extract_tables_node",
            ),
            node(
                func=set_column_index,
                inputs="p18_19_5",
                outputs="processed_p18_19_5",
                name="set_column_index_node",
            ),
            node(
                func=validate_processed_data,
                inputs="processed_p18_19_5",
                outputs="validated_p18_19_5",
                name="validate_processed_data_node",
            ),
        ],
    )
