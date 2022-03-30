#!/bin/bash

workdir="home/runner/work/github-ci/github-ci"
time_now=$(date +"%Y-%m-%d")
branch_name="sync_chart"_$(time_now)

function get_chart {
    echo "git clone and copy chart file"
    git clone https://github.com/k8snetworkplumbingwg/helm-charts.git
    cp -rf helm-charts/multus/* $(workdir)/charts/multus-origin
}

function update_chart() {
    echo "update chart and push to a new branch: $(branch_name)"
    cd $workdir
    git checkout -b $branch_name
    git config user.name github-actions
    git config user.email github-actions@github.com
    git add .
    git commit -m "Automatic: update multus helm chart($(date)"
    git push
}

get_chart
update_chart
echo "get_chart and update_chart both is success"


