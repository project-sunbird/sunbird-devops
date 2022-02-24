package main

import (
	"fmt"
	"os"

	"github.com/open-policy-agent/opa-envoy-plugin/plugin"
	"github.com/open-policy-agent/opa/cmd"
	"github.com/open-policy-agent/opa/runtime"
	"github.com/project-sunbird/sunbird-devops/kubernetes/opa-plugins/plugins/decisionlogs"
)

func main() {
	// opa-envoy-plugin register
	runtime.RegisterPlugin("envoy.ext_authz.grpc", plugin.Factory{})
	runtime.RegisterPlugin(plugin.PluginName, plugin.Factory{})

	// decision-logs-plugin register
	runtime.RegisterPlugin(decisionlogs.PluginName, decisionlogs.Factory{})

	if err := cmd.RootCommand.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
