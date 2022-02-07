package main

import (
	"fmt"
	"os"

	"github.com/project-sunbird/sunbird-devops/kubernetes/opa-plugins/handler"
	"github.com/open-policy-agent/opa-envoy-plugin/plugin"
	"github.com/open-policy-agent/opa/cmd"
	"github.com/open-policy-agent/opa/runtime"
)

const PluginName = "print_decision_logs_on_failure"

func main() {
	// opa-envoy-plugin register
	runtime.RegisterPlugin("envoy.ext_authz.grpc", plugin.Factory{})
	runtime.RegisterPlugin(plugin.PluginName, plugin.Factory{})

	// decision-logs-plugin register
	runtime.RegisterPlugin(PluginName, handler.Factory{})

	if err := cmd.RootCommand.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
