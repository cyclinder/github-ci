#!/bin/bash

set -e

TIME_NOW=`date "+%Y%m%d_%H%M" `
BRANCH_NAME="sync_chart_"${TIME_NOW}
MULTUS_REMOTE_CHART_URL="https://github.com/k8snetworkplumbingwg/helm-charts.git"

function get_chart {
    echo "Ready to git clone remote chart to local and copy chart file"
    cd
    git clone ${MULTUS_REMOTE_CHART_URL}
    cp -rf helm-charts/multus/* ${GITHUB_WORKSPACE}/charts/multus-origin
}

function update_chart() {
    echo "Ready to update chart and push to a new branch: ${BRANCH_NAME}"
    cd ${GITHUB_WORKSPACE} && git checkout -b ${BRANCH_NAME}
    if [ -z "`git diff`" ]; then
      echo "local helm chart no changes from remote: ${MULTUS_REMOTE_CHART_URL}"
      exit 0
    fi
    git config user.name github-actions
    git config user.email github-actions@github.com
    git add .
    git commit -m "Automatic: Update multus helm chart(${TIME_NOW})"
    git push --set-upstream origin ${BRANCH_NAME}
}

get_chart
update_chart


