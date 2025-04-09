flutter pub get junitreport
export PATH="$PATH":"$HOME/.pub-cache/bin"
flutter pub global activate junitreport 
junitReportFile="./junit-report.xml" # My Report file path, You can give any path suitable to you
flutter test --machine integration_test/tests/tests/sanity.test.dart -d "$DEVICE" | tojunit --output $junitReportFile

## We will parse the Junit Reporter and update the exit status based on pass and error counts

errors=$(echo 'cat //testsuites/testsuite/@errors' | xmllint --shell $junitReportFile | awk -F'[="]' '!/>/{print $(NF-1)}') ## we are getting total error count from testSuit tag
failures=$(echo 'cat //testsuites/testsuite/@failures' | xmllint --shell $junitReportFile | awk -F'[="]' '!/>/{print $(NF-1)}') ## we are getting total failure count from testSuit tag

echo "Total Tests With Error : $errors"
echo "Total Tests With Failure: $failures"

## setting up exit status. Exit ocde 0 if No error else 1
if [[ "$errors" == "0" && "$failures" == "0" ]]; then
    echo " All Tests Passed "
    STATUS=0
else
    echo " Some Test Failed "
    STATUS=1
fi

## Based on above status Code, we will exit 
exit $STATUS