from unittest.mock import patch


def handler(event, context):
    """
    This handler is used for each Lambda function in our pipeline,
    receives the name of a Kedro node from a triggering event and executes it accordingly.
    """
    from kedro.framework.project import configure_project

    configure_project("data_processing_pipeline")
    node_to_run = event["node_name"]

    with patch("multiprocessing.Lock"):
        from kedro.framework.session import KedroSession

        with KedroSession.create(env="base") as session:
            session.run(node_names=[node_to_run])


