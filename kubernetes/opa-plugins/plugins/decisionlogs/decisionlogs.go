package decisionlogs

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"sync"

	"github.com/open-policy-agent/opa/plugins"
	"github.com/open-policy-agent/opa/plugins/logs"

	"github.com/golang-jwt/jwt"
	"github.com/open-policy-agent/opa/util"
	"github.com/tidwall/gjson"
	"github.com/tidwall/sjson"
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
	json_log := string(bs)
	result := gjson.Get(json_log, "result.allowed")
	bearer_token := gjson.Get(json_log, "input.attributes.request.http.headers.authorization")
	x_auth_token := gjson.Get(json_log, "input.attributes.request.http.headers.x-authenticated-user-token")

	json_log, _ = sjson.Delete(json_log, "input.attributes.request.http.headers.authorization")
	json_log, _ = sjson.Delete(json_log, "input.attributes.request.http.headers.x-authenticated-user-token")
	json_log, _ = sjson.Delete(json_log, "input.attributes.request.http.headers.x-auth-token")
	json_log, _ = sjson.Delete(json_log, "input.attributes.request.http.headers.cookie")

	// Print the decision logs only when result.allowed == false && Config.Stdout == true
	if !result.Bool() && p.config.Stdout {
		if bearer_token.Exists() {
			token := strings.Split(bearer_token.String(), " ")[1]
			b_token, _ := jwt.Parse(token, nil)
			if b_token != nil {
				b_claims, _ := json.Marshal(b_token.Claims)
				b_header, _ := json.Marshal(b_token.Header)
				json_log, _ = sjson.SetRaw(json_log, "input.bearer_token_claims", string(b_claims))
				json_log, _ = sjson.SetRaw(json_log, "input.bearer_token_header", string(b_header))
			}
		}

		if x_auth_token.Exists() {
			x_token, _ := jwt.Parse(x_auth_token.String(), nil)
			if x_token != nil {
				x_claims, _ := json.Marshal(x_token.Claims)
				x_header, _ := json.Marshal(x_token.Header)
				json_log, _ = sjson.SetRaw(json_log, "input.x_auth_token_claims", string(x_claims))
				json_log, _ = sjson.SetRaw(json_log, "input.x_auth_token_header", string(x_header))
			}
		}

		_, err = fmt.Fprintln(w, json_log)
	}

	if err != nil {
		p.manager.UpdatePluginStatus(PluginName, &plugins.Status{State: plugins.StateErr})
	}
	return nil
}
