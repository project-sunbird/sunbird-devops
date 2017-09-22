#!/bin/sh

set -e

GIT_REPO_URL={{ grafana_dashboards_git_repo_url }}

rm -rf grafana-dashboards
git clone $GIT_REPO_URL grafana-dashboards

rm -rf dashboards
cp -r grafana-dashboards/dashboards dashboards

wizzy export dashboards