# environment variables examples
# these are commented out, since you should store these 
# in your shell profile
# similar to what you'd do with terraform
# export OBSERVE_API_TOKEN=
# export OBSERVE_CUSTOMER=
# export OBSERVE_DOMAIN=

if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install jq to proceed"
    exit 1
fi

# get all users
customer_resp=`curl "https://$OBSERVE_CUSTOMER.$OBSERVE_DOMAIN/v1/meta?queryName=CurrentCustomer" \
  -H "authorization: Bearer $OBSERVE_CUSTOMER $OBSERVE_API_TOKEN" \
  -H 'content-type: application/json' \
  --data-raw '{"operationName":"CurrentCustomer", 
  "variables":{}, 
  "query":"query CurrentCustomer {\n  currentCustomer {\n    id\n    label\n    type\n    billingType\n    ingestInfo {\n      collectUrl\n      domain\n      scheme\n      port\n      __typename\n    }\n    trialInfo {\n      adminName\n      adminEmail\n      apps\n      primaryApp\n      __typename\n    }\n    users {\n      ...User\n      __typename\n    }\n    effectiveSettings {\n      queryGovernor {\n        creditsPerDay\n        throttledLimitCreditsPerDay\n        userCreditsPerDay\n        userThrottledLimitCreditsPerDay\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n\nfragment User on User {\n  id\n  type\n  email\n  label\n  role\n  status\n  comment\n  expirationTime\n  timezone\n  rbacGroups {\n    name\n    id\n    __typename\n  }\n  effectiveSettings {\n    queryGovernor {\n      userCreditsPerDay\n      userThrottledLimitCreditsPerDay\n      __typename\n    }\n    __typename\n  }\n  creditUsage {\n    last24Hours\n    throttleLimit\n    dailyUsages {\n      amount\n      time\n      __typename\n    }\n    __typename\n  }\n  __typename\n}"}'`


jq .data.currentCustomer.users <<< $customer_resp  > observe_user_list.json

# get all RBAC groups
group_resp=`curl "https://$OBSERVE_CUSTOMER.$OBSERVE_DOMAIN/v1/meta?queryName=GetAllGroups" \
  -H "authorization: Bearer $OBSERVE_CUSTOMER $OBSERVE_API_TOKEN" \
  -H 'content-type: application/json' \
  --data-raw '{"query": "{\n\n    rbacGroups {\n      id\n      name\n      description\n      memberUserIds\n      updatedDate\n      updatedBy\n    } \n\n  \n}\n\n"}'`
jq .data.rbacGroups <<< $group_resp > observe_group_list.json

# get all dataset metadata
dataset_resp=`curl "https://$OBSERVE_CUSTOMER.$OBSERVE_DOMAIN/v1/meta?queryName=DatasetSearch" \
  -H "authorization: Bearer $OBSERVE_CUSTOMER $OBSERVE_API_TOKEN" \
  -H 'content-type: application/json' \
  --data-raw '{"operationName":"DatasetSearch","variables":{},"query":"query DatasetSearch($labelMatches: [String\u0021], $projects: [ObjectId\u0021], $columnMatches: [String\u0021], $keyMatchTypes: [String\u0021], $foreignKeyTargetMatches: [String\u0021], $reachableFromDataset: ObjectId) {\\n  datasetSearch(\\n    labelMatches: $labelMatches\\n    projects: $projects\\n    columnMatches: $columnMatches\\n    keyMatchTypes: $keyMatchTypes\\n    foreignKeyTargetMatches: $foreignKeyTargetMatches\\n    reachableFromDataset: $reachableFromDataset\\n  ) {\\n    dataset {\\n      ...DatasetSearch\\n      __typename\\n    }\\n    __typename\\n  }\\n}\\n\\nfragment WorkspaceEntity on WorkspaceObject {\\n  id\\n  name\\n  description\\n  iconUrl\\n  workspaceId\\n  managedById\\n  __typename\\n}\\n\\nfragment FolderEntity on FolderObject {\\n  folderId\\n  __typename\\n}\\n\\nfragment GroupingElement on GroupingElement {\\n  type\\n  value\\n  __typename\\n}\\n\\nfragment DatasetGroupingKey on GroupingKey {\\n  elements {\\n    ...GroupingElement\\n    __typename\\n  }\\n  __typename\\n}\\n\\nfragment LinkDesc on LinkSchema {\\n  targetDataset\\n  targetStageLabel\\n  targetLabelField\\n  label\\n  src {\\n    column\\n    path\\n    __typename\\n  }\\n  dstFields\\n  __typename\\n}\\n\\nfragment DatasetFieldDesc on FieldDesc {\\n  name\\n  type {\\n    tag\\n    __typename\\n  }\\n  indexDefs {\\n    __typename\\n    column\\n  }\\n  linkDesc {\\n    ...LinkDesc\\n    __typename\\n  }\\n  isEnum\\n  isSearchable\\n  isHidden\\n  isConst\\n  isMetric\\n  __typename\\n}\\n\\nfragment UserInfo on UserInfo {\\n  userLabel\\n  userId\\n  userTimezone\\n  __typename\\n}\\n\\nfragment DatasetForeignKey on ForeignKey {\\n  targetDataset\\n  dstFields\\n  src {\\n    column\\n    path\\n    __typename\\n  }\\n  label\\n  targetStageLabel\\n  __typename\\n}\\n\\nfragment DatasetRelatedKey on RelatedKey {\\n  targetDataset\\n  srcFields\\n  dstFields\\n  label\\n  __typename\\n}\\n\\nfragment AccelerationInfo on AccelerationInfo {\\n  state\\n  stalenessSeconds\\n  alwaysAccelerated\\n  configuredTargetStalenessSeconds\\n  targetStalenessSeconds\\n  effectiveTargetStalenessSeconds\\n  rateLimitOverrideTargetStalenessSeconds\\n  acceleratedRangeStart\\n  targetAcceleratedRangeStart\\n  freshnessTime\\n  minimumDownstreamTargetStaleness {\\n    minimumDownstreamTargetStalenessSeconds\\n    datasetIds\\n    monitorIds\\n    __typename\\n  }\\n  effectiveOnDemandMaterializationLength\\n  errors {\\n    datasetId\\n    datasetName\\n    transformId\\n    time\\n    errorText\\n    __typename\\n  }\\n  __typename\\n}\\n\\nfragment DatasetInterface on ImplementedInterface {\\n  path\\n  mapping {\\n    interfaceField\\n    field\\n    __typename\\n  }\\n  __typename\\n}\\n\\nfragment DatasetCompilationError on CompilationError {\\n  error\\n  errorInDatasetId\\n  __typename\\n}\\n\\nfragment DatasetSearch on Dataset {\\n  ...WorkspaceEntity\\n  ...FolderEntity\\n  label\\n  version\\n  kind\\n  source\\n  validFromField\\n  validToField\\n  labelField\\n  primaryKey\\n  groupingKey {\\n    ...DatasetGroupingKey\\n    __typename\\n  }\\n  fieldList {\\n    ...DatasetFieldDesc\\n    __typename\\n  }\\n  keys\\n  defaultDashboardId\\n  defaultInstanceDashboardId\\n  createdDate\\n  updatedDate\\n  isSourceDataset\\n  createdByInfo {\\n    ...UserInfo\\n    __typename\\n  }\\n  updatedByInfo {\\n    ...UserInfo\\n    __typename\\n  }\\n  foreignKeys {\\n    ...DatasetForeignKey\\n    __typename\\n  }\\n  relatedKeys {\\n    ...DatasetRelatedKey\\n    __typename\\n  }\\n  accelerable\\n  accelerationInfo {\\n    ...AccelerationInfo\\n    __typename\\n  }\\n  interfaces {\\n    ...DatasetInterface\\n    __typename\\n  }\\n  compilationError {\\n    ...DatasetCompilationError\\n    __typename\\n  }\\n  __typename\\n}"}'`
jq .data.datasetSearch <<< $dataset_resp > observe_dataset_list.json