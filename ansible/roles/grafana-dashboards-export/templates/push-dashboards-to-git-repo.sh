#!/bin/sh

GIT_REPO_URL={{ grafana_dashboards_git_repo_url_with_credentails }}

rm -rf grafana-dashboards
git clone $GIT_REPO_URL grafana-dashboards
rm -rf grafana-dashboards/dashboards/*
cp dashboards/* grafana-dashboards/dashboards/
cd grafana-dashboards
git add -A
git commit -am "Issue #1 chore: Automated dashboards update"
git push $GIT_REPO_URL --all
