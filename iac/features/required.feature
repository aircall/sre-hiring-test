Feature: In order to make sure all required attributes are provided

Scenario Outline: Must contain attributes
  Given I have aws_iam_policy defined
  Then it must contain <attributes>

  Examples:
  | attributes        |
  | name              |
  | path              |
  | description       |
  | policy            |

Scenario Outline: Ensure s3 bucket is created
  Given I have aws_s3_bucket defined
  Then it must contain <key>
  And its value must match the "<value>" regex  

  Examples:
    | key    | value                        |
    | acl    | private                      |
    | bucket | aircall-resize-image-bucket |

Scenario Outline: Ensure lambda is created
  Given I have aws_lambda_function defined
  Then it must contain <key>
  And its value must match the "<value>" regex  

  Examples:
    | key     | value               |
    | publish | true                |
    | runtime | nodejs14.x          |
    | handler | app.lambdaHandler |

Scenario Outline: Ensure that specific tags are defined
  Given I have resource that supports tags defined
  When it has tags
  Then it must contain tags
  Then it must contain <tags>

  Examples:
  | tags         |
  | owner        |
  | service_name |
  | managed_by   |
  | envname      |
  | versioning   |


