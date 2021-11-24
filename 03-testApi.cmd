rem curl https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe -OutFile jq.exe

curl -X GET "http://127.0.0.1:4010/tasks" -H "accept: application/json" | jq -C

curl -X POST "http://127.0.0.1:4010/task?title=CreateTestRequest" -H "Accept: application/json"   -d "" | jq -C