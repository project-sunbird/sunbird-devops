package decisionlogs

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"sync"

	"github.com/open-policy-agent/opa/plugins"
	"github.com/open-policy-agent/opa/plugins/logs"

	"github.com/open-policy-agent/opa/util"
	"github.com/tidwall/gjson"
)

const PluginName = "print_decision_logs_on_failure"

type Factory struct{}

func (Factory) Validate(_ *plugins.Manager, config []byte) (interface{}, error) {
	cfg := Config{}

	if err := util.Unmarshal(config, &cfg); err != nil {
		return nil, err
	}

	return cfg, util.Unmarshal(config, &cfg)
}

func (Factory) New(m *plugins.Manager, config interface{}) plugins.Plugin {

	m.UpdatePluginStatus(PluginName, &plugins.Status{State: plugins.StateNotReady})

	return &PrintlnLogger{
		manager: m,
		config:  config.(Config),
	}
}

type Config struct {
	// true => failed decision logs printed, false => failed decision logs are not printed
	Stdout bool `json:"stdout"`
}

type PrintlnLogger struct {
	manager *plugins.Manager
	mtx     sync.Mutex
	config  Config
}

func (p *PrintlnLogger) Start(ctx context.Context) error {
	p.manager.UpdatePluginStatus(PluginName, &plugins.Status{State: plugins.StateOK})
	return nil
}

func (p *PrintlnLogger) Stop(ctx context.Context) {
	p.manager.UpdatePluginStatus(PluginName, &plugins.Status{State: plugins.StateNotReady})
}

func (p *PrintlnLogger) Reconfigure(ctx context.Context, config interface{}) {
	p.mtx.Lock()
	defer p.mtx.Unlock()
	p.config = config.(Config)
}

func (p *PrintlnLogger) Log(ctx context.Context, event logs.EventV1) error {
	p.mtx.Lock()
	defer p.mtx.Unlock()
	w := os.Stdout
	if !p.config.Stdout {
		w = os.Stderr
	}
	bs, err := json.Marshal(event)
	if err != nil {
		p.manager.UpdatePluginStatus(PluginName, &plugins.Status{State: plugins.StateErr})
		return nil
	}
	result := gjson.Get(string(bs), "result.allowed")

	// Print the decision logs only when result.allowed == false && Config.Stdout == true
	if !result.Bool() && p.config.Stdout {
		_, err = fmt.Fprintln(w, string(bs))
	}

	if err != nil {
		p.manager.UpdatePluginStatus(PluginName, &plugins.Status{State: plugins.StateErr})
	}
	return nil
}
