#!/bin/sh

set -e

GIT_REPO_URL={{ grafana_dashboards_git_repo_url_with_credentails }}
rm -rf grafana-dashboards
git clone $GIT_REPO_URL grafana-dashboards

# Remove old dashboards
rm -rf dashboards
rm -rf grafana-dashboards/dashboards/*

# Import and copy dashboards
wizzy import dashboards
cp dashboards/* grafana-dashboards/dashboards/

cd grafana-dashboards
git config user.email "grafana-dashboards-exporter@open-sunbird.org"
git config user.name "grafana-dashboards-exporter"
git add -A
git diff-index --quiet HEAD || git commit -m "Issue #1 chore: Automated dashboards update"
git push $GIT_REPO_URL --all
