#!/usr/bin/env zsh
getHourMinutesSeconds() {
  # source: https://www.shellscript.sh/tips/hms/
  # Convert Seconds to Hours, Minutes, Seconds
  local SECONDS H M S MM H_TAG M_TAG S_TAG

  # get SECONDS from provided MSSECONDS
  MSSECONDS=${1:-0}
  let SECONDS=MSSECONDS/1000

  # let's calculate the values
  let S=${SECONDS}%60
  let MM=${SECONDS}/60 # Total number of minutes
  let M=${MM}%60
  let H=${MM}/60
  
  # Display "1 hour, 2 minutes and 3 seconds" format
  [ "$H" -eq "1" ] && H_TAG="hour" || H_TAG="hours"
  [ "$M" -eq "1" ] && M_TAG="minute" || M_TAG="minutes"
  [ "$S" -eq "1" ] && S_TAG="second" || S_TAG="seconds"
  [ "$H" -gt "0" ] && printf "%d %s " $H "${H_TAG},"
  [ "$SECONDS" -ge "60" ] && printf "%d %s " $M "${M_TAG} and"
  printf "%d %s\n" $S "${S_TAG}"
}

function toggl-week() {
  # get current monday
  # inspired by
  # - https://stackoverflow.com/a/17348730/1238150
  # - https://superuser.com/a/733243 (https://stackoverflow.com/a/32669748/1238150)
  # ATTENTION: this only works on OSX
  MONDAY=$(date -v -Mon "+%Y-%m-%d")
  SUNDAY=$(date -j -v +6d -f "%Y-%m-%d" "${MONDAY}" +%Y-%m-%d)

  # get the data from toggl
  RESULT=$(curl -u "$TOGGL_API_TOKEN":api_token -s -X GET \
    'https://toggl.com/reports/api/v2/weekly?user_agent=toggl-plugin-zsh&workspace_id='"$TOGGL_WORKSPACE_ID"'&project_ids='"$TOGGL_PROJECT_IDS"'&api_token='"$TOGGL_API_TOKEN"'&since='"$MONDAY"'&until='"$SUNDAY" \
    -H 'Content-Type: application/json')

  # get the data from the response
  WEEK_TOTAL=$(jq -r '.total_grand' <<< "${RESULT}" ) 
  WEEK_TOTAL_TEXT=$(getHourMinutesSeconds $WEEK_TOTAL)

  # final output text
  echo "You've worked ${WEEK_TOTAL_TEXT} this week."  
}

alias toggl-week=toggl-week