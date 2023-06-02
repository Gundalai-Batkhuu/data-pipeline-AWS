import re
import json
from pathlib import Path

from kedro.framework.project import pipelines
from kedro.framework.session import KedroSession
from kedro.framework.startup import bootstrap_project
from kedro.pipeline.node import Node


class KedroStepFunctions():
    """Converts Kedro pipeline to AWS Step Functions state machine definition."""

    project_path = Path.cwd()

    def __init__(self, **kwargs) -> None:
        super().__init__(*kwargs)

        self.get_kedro_pipeline()
        self.convert_kedro_pipeline_to_sfn_definition()

    def get_kedro_pipeline(self) -> None:
        """
        Extract the Kedro pipeline from the project
        """

        metadata = bootstrap_project(self.project_path)

        self.project_name = metadata.project_name
        print(self.project_name)
        self.pipeline = pipelines.get("__default__")

    def convert_kedro_pipeline_to_sfn_definition(self) -> None:
        """
        Convert Kedro pipeline into a json file that can be used to create a Step Functions state machine definition"
        """

        self.node_list = []

        self.sfn_definition = {
            "StartAt": "Start",
            "States": {
                "Start": {
                    "Type": "Pass",
                    "Next": "Group 1"
                },
            },
            "TimeoutSeconds": 300
        }

        for i, group in enumerate(self.pipeline.grouped_nodes, 1):

            next = ""
            end = True

            group_content = {
                "Type": "Parallel",
                "Branches": []
            }

            if i < len(self.pipeline.grouped_nodes):
                group_content["Next"] = f"Group {i + 1}"
            else:
                group_content["End"] = True

            for node in group:
                branch = {
                    "StartAt": clean_name(node.name),
                    "States": {
                        f"{clean_name(node.name)}": {
                            "End": True,
                            "Retry": [
                                {
                                    "ErrorEquals": [
                                        "Lambda.ServiceException",
                                        "Lambda.AWSLambdaException",
                                        "Lambda.SdkClientException"
                                    ],
                                    "IntervalSeconds": 2,
                                    "MaxAttempts": 6,
                                    "BackoffRate": 2
                                }
                            ],
                            "Type": "Task",
                            "Resource": "arn:aws:states:::lambda:invoke",
                            "Parameters": {
                                "FunctionName": f"arn:aws:lambda:ap-southeast-2:459103101106:function:{clean_name(node.name)}",
                                "Payload": {
                                    "node_name": node.name
                                }
                            }
                        }
                    }
                }
                group_content["Branches"].append(branch)

                self.node_list.append(clean_name(node.name))

            self.sfn_definition["States"][f"Group {i}"] = group_content

        print(self.sfn_definition)

        print(self.node_list)

        # Write the sfn definition to file in JSON format
        with open('sfn_definition.json', 'w') as f:
            json.dump(self.sfn_definition, f)

        with open('node_list.json', 'w') as f:
            json.dump(self.node_list, f)


def clean_name(name: str) -> str:
    """Reformat a name to be compliant with AWS requirements for their resources.

    Returns:
        name: formatted name.
    """
    return re.sub(r"[\W_]+", "-", name).strip("-")[:63]


KedroStepFunctions()



