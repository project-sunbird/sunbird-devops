// Copyright 2020 The OPA Authors. All rights reserved.
// Use of this source code is governed by an Apache2
// license that can be found in the LICENSE file.

package handler

import (
	"github.com/keshavprasadms/opa-plugins/plugins/decisionlogs"
	"github.com/open-policy-agent/opa/plugins"
)

// Factory defines the interface OPA uses to instantiate a plugin.
type Factory struct{}

// PluginName is the name to register with the OPA plugin manager
const PluginName = decisionlogs.PluginName

// New returns the object initialized with a valid plugin configuration.
func (Factory) New(m *plugins.Manager, config interface{}) plugins.Plugin {
	return decisionlogs.New(m, config.(*decisionlogs.Config))
}

// Validate returns a valid configuration to instantiate the plugin.
func (Factory) Validate(m *plugins.Manager, config []byte) (interface{}, error) {
	return decisionlogs.Validate(m, config)
}
