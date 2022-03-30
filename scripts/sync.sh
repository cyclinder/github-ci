#!/bin/bash

set -e

time_now=`date +"%Y-%m-%d"`
branch_name="sync_chart_"${time_now}


function get_chart {
    echo "git clone and copy chart file"
    git clone https://github.com/k8snetworkplumbingwg/helm-charts.git
    cp -rf helm-charts/multus/* ${GITHUB_WORKSPACE}/charts/multus-origin
    ls ${GITHUB_WORKSPACE}/charts/multus-origin
}

function update_chart() {
    echo "ready update chart and push to a new branch: ${branch_name}"
    cd ${GITHUB_WORKSPACE}
    git checkout -b ${branch_name}
    git config user.name github-actions
    git config user.email github-actions@github.com
    echo `pwd`
    git add .
    git commit -m "Automatic: update multus helm chart(${date}"
    git push --set-upstream origin ${branch_name}

    git symbolic-ref --short HEAD
    git log | head -n 6
}

get_chart
update_chart
echo "get_chart and update_chart both is success"


